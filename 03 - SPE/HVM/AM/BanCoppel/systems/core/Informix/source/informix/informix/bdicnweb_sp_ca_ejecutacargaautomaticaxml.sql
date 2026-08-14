CREATE PROCEDURE "informix".sp_ca_ejecutacargaautomaticaxml(pUsuario CHAR(8), pIdFuncion CHAR(10), pRutaCarga CHAR(100), pNumIntentos SMALLINT, pUsuarioSrvOrigen CHAR(25), pIpSrvOrigen CHAR(15), pRutaOrigenFiles CHAR(100), pCarpetaProc CHAR(50), pCarpetaNoProc CHAR(50))
	RETURNING CHAR(5) AS codret, CHAR(1) AS bandera_error;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE cIdCodRet CHAR(6);
	DEFINE cDesCodRet CHAR(250);
	DEFINE iSqlErr INTEGER;
	DEFINE iIsamErr	INTEGER;
	DEFINE cDescErr	CHAR(250);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cBanDetError CHAR(1);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE cCmd CHAR(2000);
	DEFINE cCmd2 CHAR(500);
	DEFINE cPathdbaccess CHAR(35);
	DEFINE cUsrbin CHAR(15);
	DEFINE cUsrbinServerRemoto CHAR(15);
	--
	DEFINE dFormatoFechaPeriodo DATE;
	DEFINE dFechaPeriodo DATE;
	DEFINE cPeriodo CHAR(8);
	DEFINE cNombreOficio CHAR(100);
	DEFINE cGenClaveOficio CHAR(45);
	DEFINE dFechaHoraInicio DATETIME YEAR TO FRACTION(5);
	DEFINE dFechaInicio DATE;
	DEFINE dFechaHoraFin DATETIME YEAR TO FRACTION(5);
	DEFINE iCtrlIntentos SMALLINT;
	DEFINE iTotalArchivos INTEGER;
	DEFINE iContArch INTEGER;
	DEFINE cIniciaProceso CHAR(1);
	DEFINE cContinuaProceso CHAR(1);
	DEFINE cValidaContPro CHAR(1);
	DEFINE cCodRetSpCarga CHAR(5);
	DEFINE cCodRetSpProcesa CHAR(5);
	DEFINE cNumOficioSp CHAR(60);
	DEFINE iIdOficioSp INTEGER;
	--
	DEFINE cNumOficio CHAR(60);
	DEFINE cNumExpediente CHAR(60);
	DEFINE cSolicitudSiara CHAR(60);
	DEFINE iFolio INTEGER;
	DEFINE dAnioOficio CHAR(4);
	DEFINE cArea CHAR(32);
	DEFINE iIdArea CHAR(2);
	DEFINE cDescArea CHAR(30);
	DEFINE dFechaPublicacion CHAR(25);
	DEFINE dFechaPublicacionDate DATE;
	DEFINE iDiasPlazo CHAR(2);
	DEFINE cNombreAutoridad CHAR(60);
	DEFINE cReferencia CHAR(60);
	DEFINE cUsuarioInsert CHAR(8);
	DEFINE dFechaInsert CHAR(25);
	DEFINE iIdSolEspecifica INTEGER;
	DEFINE iIdPersona INTEGER;
	DEFINE cCaracter CHAR(30);
	DEFINE cDescTipoPersona CHAR(10);
	DEFINE cNombre CHAR(150);
	DEFINE cNombre1 CHAR(60);
	DEFINE cNombre2 CHAR(60);
	DEFINE cRazonSocial CHAR(160);
	DEFINE cPrimerPalabra CHAR(150);
	DEFINE cSegundaPalabra CHAR(150);
	DEFINE cApellPaterno CHAR(26);
	DEFINE cApellMaterno CHAR(26);
	DEFINE cNombreSiCte CHAR(150);
	DEFINE cApellPaternoSiCte CHAR(26);
	DEFINE cApellMaternoSiCte CHAR(26);
	DEFINE cNom1ApPaterno CHAR(86);
	DEFINE cRFC CHAR(15);
	DEFINE cEntidad CHAR(50);
	DEFINE cCuenta CHAR(20);
	DEFINE cNumCliente CHAR(20);
	DEFINE cEstatus CHAR(1);
	DEFINE iTotalNumCliente INTEGER;
	DEFINE cFiltroRfc CHAR(15);
	--
	DEFINE cNomOfValEst CHAR(100);
	DEFINE iTotRegHomonimos INTEGER;
	DEFINE iTotRegValEst INTEGER;
	DEFINE iTotSiCteValEst INTEGER;
	DEFINE iTotNoCteValEst INTEGER;
	--
	DEFINE cIdPlantilla CHAR(10);
	DEFINE cIdUsuario CHAR(8);
	DEFINE cStr6 CHAR(100);
	DEFINE cStr7 CHAR(60);
	DEFINE dHoy DATETIME YEAR TO FRACTION(3);
	
	DEFINE cValidaSegPalabra INTEGER;
	
	DEFINE iCountInfo INTEGER;
	DEFINE iRespuesta INTEGER;
	DEFINE iCounUifPe INTEGER;
	DEFINE iCounUeaf INTEGER;
	DEFINE iCounInProc INTEGER;
	DEFINE iProcesado INTEGER;
	DEFINE bValidaHomonimo BOOLEAN;
	DEFINE cRfcCliente CHAR(15);
	DEFINE iCountH INTEGER;
	
	DEFINE vCuenta INTEGER;
	
	LET cCodRet = '00000';
	LET cIdCodRet = '00000';
	LET cDesCodRet = 'EJECUCIÓN EXITOSA DEL PROCEDIMIENTO';
	LET iSqlErr = 0;
	LET iIsamErr = 0;
	LET cDescErr = '';
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cBanDetError = 'f';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET cCmd = '';
	LET cCmd2 = '';
	LET cPathdbaccess = '/ifxsif01/bin/';
	--LET cPathdbaccess = '/informix/bin/';
	LET cUsrbin = '/usr/bin/';
	LET cUsrbinServerRemoto = '/bin/';
	--
	LET dFormatoFechaPeriodo = '';
	LET dFechaPeriodo = '';
	LET cPeriodo = '';
	LET cNombreOficio = '';
	LET cGenClaveOficio = TRIM('OFICIOS_XML_'||TO_CHAR(CURRENT, '%Y%m%d%H%M%S')||'.XML');
	LET dFechaHoraInicio = CURRENT YEAR TO FRACTION(5);
	LET dFechaInicio = DATE(CURRENT);
	LET dFechaHoraFin = '';
	LET iCtrlIntentos = 0;
	LET iTotalArchivos = 0;
	LET iContArch = 0;
	LET cIniciaProceso = 'f';
	LET cContinuaProceso = 'f';
	LET cValidaContPro = 'f';
	LET cCodRetSpCarga = '00000';
	LET cCodRetSpProcesa = '00000';
	LET cNumOficioSp = '';
	LET iIdOficioSp = 0;
	--
	LET cNumOficio = '';
	LET cNumExpediente = '';
	LET cSolicitudSiara = '';
	LET iFolio = 0;
	LET dAnioOficio = '';
	LET cArea = '';
	LET iIdArea = '';
	LET cDescArea = '';
	LET dFechaPublicacion = '';
	LET dFechaPublicacionDate = '';
	LET iDiasPlazo = '';
	LET cNombreAutoridad = '';
	LET cReferencia = '';
	LET cUsuarioInsert = '';
	LET dFechaInsert = '';
	LET iIdSolEspecifica = 0;
	LET iIdPersona = 0;
	LET cCaracter = '';
	LET cDescTipoPersona = '';
	LET cNombre = '';
	LET cNombre1 = '';
	LET cNombre2 = '';
	LET cRazonSocial = '';
	LET cPrimerPalabra = '';
	LET cSegundaPalabra = '';
	LET cApellPaterno = '';
	LET cApellMaterno = '';
	LET cNombreSiCte = '';
	LET cApellPaternoSiCte = '';
	LET cApellMaternoSiCte = '';
	LET cNom1ApPaterno = '';
	LET cRFC = '';
	LET cEntidad = '';
	LET cCuenta = '';
	LET cNumCliente = '';
	LET cEstatus = '';
	LET iTotalNumCliente = 0;
	LET cFiltroRfc = '';
	--
	LET cNomOfValEst = '';
	LET iTotRegHomonimos = 0;
	LET iTotRegValEst = 0;
	LET iTotSiCteValEst = 0;
	LET iTotNoCteValEst = 0;
	--
	LET cIdPlantilla = '';
	LET cIdUsuario = '';
	LET cStr6 = '';
	LET cStr7 = '';
	LET dHoy = '';	

	LET cValidaSegPalabra = 0;
	
	LET iCountInfo = 0;
	LET iRespuesta = 0;
	LET iCounUifPe = 0;
	LET iCounUeaf  = 0;
	LET iCounInProc = 0;
	LET iProcesado = 0;
	LET bValidaHomonimo = 'f';
	LET cRfcCliente = '';
	LET iCountH = 0;
	LET vCuenta = 0;
						
	BEGIN
		
		ON EXCEPTION SET iSqlErr, iIsamErr, cDescErr
			IF iSqlErr <> 0 THEN
				--LET cCodRet = iSqlErr;
				LET cIdCodRet = iSqlErr;
				LET cDesCodRet = cDescErr;
				LET cBanDetError = 't';
				
				IF ven_transacc = 1 THEN
					--ROLLBACK WORK;		
				END IF;
				
				INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
				VALUES(cGenClaveOficio,cNombreOficio,cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);

				IF NVL(iCtrlIntentos,0) = pNumIntentos THEN
				
					LET cIdCodRet = '01028';
					LET cDesCodRet = 'HA LLEGADO AL NÚMERO MÁXIMO DE INTENTOS PERMITIDOS PARA LA CARGA DEL ARCHIVO: '||cNombreOficio;
					
					UPDATE "informix".sw_ca_bitacoraprocesoxml
					SET clave_oficio = cGenClaveOficio, id_estatus = 'N', desc_estatus = 'NO PROCESADO', cod_error = cIdCodRet, desc_error = cDesCodRet, fecha_publicacion = dFechaPublicacion, fecha_publicacion_date = dFechaPublicacionDate, usuario_insert = pUsuario, fecha_hora_insert = dFechaHoraInicio
					WHERE nombre_oficio = cNombreOficio AND fecha_insert = dFechaInicio;
					
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						LET cIdCodRet = '01022';
						LET cDesCodRet = 'OCURRIO UN ERROR AL ACTUALIZAR EL ESTATUS DEL ARCHIVO: '||cNombreOficio;
						
						INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
						VALUES(cGenClaveOficio,cNombreOficio,cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
					END IF;
						
					-- SI EXISTEN, ELIMINA LOS ARCHIVO XML
					--SELECT DISTINCT(1) INTO iRespuesta
					SELECT COUNT(*) INTO iRespuesta
					FROM "informix".sw_ca_buscaarchivosxml
					WHERE linea = cNombreOficio;

					--IF DBINFO('sqlca.sqlerrd2') > 0 THEN
					IF iRespuesta > 0 THEN
						LET cCmd = '';
						--LET cCmd = TRIM(cUsrbin)||"rm -rf "||TRIM(pRutaCarga)||TRIM(cNombreOficio);
						--SYSTEM TRIM(cCmd);
					END IF;
					
				END IF;	
				
				UPDATE "informix".sw_ca_bitacoraprocesoxml
				SET clave_oficio = cGenClaveOficio, id_estatus = 'N', desc_estatus = 'NO PROCESADO', cod_error = cIdCodRet, desc_error = cDesCodRet, fecha_publicacion = dFechaPublicacion, fecha_publicacion_date = dFechaPublicacionDate, usuario_insert = pUsuario, fecha_hora_insert = dFechaHoraInicio
				WHERE nombre_oficio = cNombreOficio AND fecha_insert = dFechaInicio;
				
				UPDATE "informix".sw_ca_statuscargaxml
				SET status = 'E', bandera_error = cBanDetError, cod_error = cIdCodRet, desc_error = cDesCodRet, fecha_insert = dFechaInicio, fecha_hora_insert = dFechaHoraInicio
				WHERE clave_oficio = cGenClaveOficio AND usuario_insert = pUsuario;
				
				LET cCmd2 = '';
				LET cCmd2 = ''||TRIM(pRutaCarga)||TRIM(cNombreOficio)||' '||TRIM(pRutaCarga)||TRIM(pCarpetaNoProc)||'/';

				LET cCmd = '';
				LET cCmd = TRIM(cUsrbin)||'mv '||TRIM(cCmd2)||'';
				SYSTEM TRIM(cCmd);
										
				--LET cCmd = '';
				--LET cCmd = TRIM(cUsrbin)||'rm -rf '||TRIM(pRutaCarga)||TRIM(cNombreOficio);
				--SYSTEM TRIM(cCmd);
				
				RETURN cCodRet, cBanDetError;
						
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535,-255)
				LET bInTransaction = 't';
				COMMIT WORK;
				BEGIN WORK;
		END EXCEPTION WITH RESUME;		
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ca_ejecutacargaautomaticaxml.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRutaCarga = '' OR pNumIntentos IS NULL THEN
			LET cIdCodRet = '00003';
			LET cDesCodRet = 'FALTA ALGUN PARAMETRO DE ENTRADA';
			LET cBanDetError = 't';
			
			UPDATE "informix".sw_ca_statuscargaxml
			SET status = 'E', bandera_error = cBanDetError, cod_error = cIdCodRet, desc_error = cDesCodRet, fecha_insert = dFechaInicio, fecha_hora_insert = dFechaHoraInicio
			WHERE clave_oficio = cGenClaveOficio AND usuario_insert = pUsuario;
				
			RETURN cCodRet, cBanDetError;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			LET cCodRet = '00000';
			LET cIdCodRet = '00028';
			LET cDesCodRet = 'EL USUARIO NO TIENE PRIVILEGIOS PARA REALIZAR LA CONSULTA';
			LET cBanDetError = 't';
			
			UPDATE "informix".sw_ca_statuscargaxml
			SET status = 'E', bandera_error = cBanDetError, cod_error = cIdCodRet, desc_error = cDesCodRet, fecha_insert = dFechaInicio, fecha_hora_insert = dFechaHoraInicio
			WHERE clave_oficio = cGenClaveOficio AND usuario_insert = pUsuario;
		
			RETURN cCodRet, cBanDetError;
		END IF;
		
		LET pRutaCarga = TRIM(pRutaCarga) || '/';
		
		-- VALIDA SI EXISTEN REGISTROS QUE SE QUEDARON EN PROCESO
		-- SET ISOLATION TO DIRTY READ;
		SELECT COUNT(*) INTO iCounInProc
		FROM "informix".sw_ca_bitacoraprocesoxml
		WHERE id_estatus  = 'E';
		
		IF iCounInProc > 0 THEN
			FOREACH 
				SELECT nombre_oficio 
				INTO cNombreOficio
				FROM "informix".sw_ca_bitacoraprocesoxml
				WHERE id_estatus  = 'E'
				
				IF DBINFO('sqlca.sqlerrd2') > 0 THEN
					DELETE FROM "informix".sw_ca_archivosxml
					WHERE nombre_oficio = cNombreOficio;
				END IF;
			END FOREACH;
		END IF;
	
		-- SE LIMPIAN E INICIALIZAN TABLAS DE TRABAJO
		DELETE FROM "informix".sw_ca_statuscargaxml WHERE usuario_insert = pUsuario;
		
		INSERT INTO "informix".sw_ca_statuscargaxml(clave_oficio,status,bandera_error,cod_error,desc_error,usuario_insert,fecha_insert,fecha_hora_insert)
		VALUES(cGenClaveOficio,'I',cBanDetError,cIdCodRet,cDesCodRet,pUsuario,dFechaInicio,dFechaHoraInicio);
		
		--SET LOCK MODE TO WAIT 3;
		--SET ISOLATION TO DIRTY READ;
		
		BEGIN WORK;
			LET ven_transacc = 1;
		
			-- SE CREAN TABLAS DE TRABAJO TEMPORALES
			--DELETE FROM "informix".sw_ca_buscaarchivosxml;
			TRUNCATE TABLE "informix".sw_ca_buscaarchivosxml;
			
			/*
			IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'sw_ca_buscaarchivosxml') THEN
				DROP TABLE "informix".sw_ca_buscaarchivosxml;
			END IF;
			
			CREATE TABLE "informix".sw_ca_buscaarchivosxml(
																	linea CHAR(100)
																	);*/
			
			
			
			-- SE GUARDAN LOS NOMBRES DE LOS ARCHIVOS EXISTENTES EN LA RUTA ESPECIFICADA
			LET cCmd = '';
			LET cCmd = 'ls '||TRIM(pRutaCarga)||' > '||TRIM(pRutaCarga)||'carpeta.car';
			SYSTEM TRIM(cCmd);
			
			LET cCmd = '';
			LET cCmd = 'echo "LOAD FROM '||TRIM(pRutaCarga)||'carpeta.car'||' INSERT INTO bdicnweb:sw_ca_buscaarchivosxml" > '||TRIM(pRutaCarga)||'buscarchivosxml.sql';
			SYSTEM TRIM(cCmd);		
			
			LET cCmd = '';
			LET cCmd = TRIM(cPathdbaccess)||'dbaccess bdicnweb '||TRIM(pRutaCarga)||'buscarchivosxml.sql';
			COMMIT WORK;
			SYSTEM TRIM(cCmd);
			BEGIN WORK;
			
			LET cCmd = '';
			LET cCmd = TRIM(cUsrbin)||"rm -rf "||TRIM(pRutaCarga)||'carpeta.car'||" "||TRIM(pRutaCarga)||'buscarchivosxml.sql';
			SYSTEM TRIM(cCmd);
			
			-- SE VALIDA QUE EL ARCHIVO EXISTA EN LA RUTA ESPECIFICADA
			SELECT {+INDEX ("informix".sw_ca_buscaarchivosxml idx_sw_ca_buscaarchivosxml_linea)} COUNT(*) INTO iTotalArchivos
			FROM "informix".sw_ca_buscaarchivosxml
			WHERE LOWER(linea) LIKE '%.xml%';
			--WHERE RIGHT(TRIM(LOWER(linea)),4) = '.xml';
			
			IF iTotalArchivos = 0 THEN
				LET cIdCodRet = '01021';
				LET cDesCodRet = 'NO EXISTE NINGÚN ARCHIVO .XML EN LA RUTA ESPECIFICADA';
				LET cBanDetError = 't';
				
				UPDATE "informix".sw_ca_statuscargaxml
				SET status = 'E', bandera_error = cBanDetError, cod_error = cIdCodRet, desc_error = cDesCodRet, fecha_insert = dFechaInicio, fecha_hora_insert = dFechaHoraInicio
				WHERE clave_oficio = cGenClaveOficio AND usuario_insert = pUsuario;
				
				COMMIT WORK;
					
				RETURN cCodRet, cBanDetError;
			END IF;		
			
			LET vCuenta = 0;
			
			FOREACH WITH HOLD	--FOR Principal
			
				SELECT {+INDEX ("informix".sw_ca_buscaarchivosxml idx_sw_ca_buscaarchivosxml_linea)} linea 
				INTO cNombreOficio
				FROM "informix".sw_ca_buscaarchivosxml
				WHERE LOWER(linea) LIKE '%.xml%'
				--WHERE RIGHT(TRIM(LOWER(linea)),4) = '.xml'
				
				LET cNombreOficio = TRIM(cNombreOficio);
				
				--SELECT DISTINCT (1) INTO iProcesado
				SELECT COUNT(*) INTO iProcesado
				FROM bdicnweb:"informix".sw_ca_archivosxml
				WHERE nombre_oficio = cNombreOficio;
				
				--IF DBINFO('sqlca.sqlerrd2') > 0 THEN
				IF iProcesado > 0 THEN
					
					--LET iContArch = iContArch + 1;
					LET cIniciaProceso = 'f';
					LET cContinuaProceso = 'f';
					LET cValidaContPro = 'f';
					LET iCtrlIntentos = NVL(pNumIntentos,0) + 1;
					
					INSERT INTO "informix".sw_ca_bitacoraprocesoxml(clave_oficio,nombre_oficio,id_estatus,desc_estatus,num_intentos,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
					VALUES(cGenClaveOficio,cNombreOficio,'Y','YA PROCESADO',0,'','','','',pUsuario,dFechaInicio,dFechaHoraInicio);
					
					LET vCuenta = vCuenta + 1;
				
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						LET cIdCodRet = '01023';
						LET cDesCodRet = 'OCURRIO UN ERROR AL REGISTRAR EL ESTATUS DEL ARCHIVO: '||cNombreOficio;
						
						INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
						VALUES(cGenClaveOficio,cNombreOficio,cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
					END IF;
					
				ELSE
				
					-- SE LIMPIAN E INICIALIZAN TABLAS DE TRABAJO
					DELETE FROM "informix".sw_ca_bitacoraprocesoxml WHERE nombre_oficio = cNombreOficio AND fecha_insert <> dFechaInicio;
					DELETE FROM "informix".sw_ca_bitacoraerroresxml WHERE nombre_oficio = cNombreOficio;
					
					--DELETE FROM "informix".sw_ca_cuentasconocidas;
					--DELETE FROM "informix".sw_ca_personassolicitud;
					--DELETE FROM "informix".sw_ca_solicitudespecifica;
					--DELETE FROM "informix".sw_ca_solicitudpartes;
					--DELETE FROM "informix".sw_ca_encabezado;							
					
					LET iContArch = iContArch + 1;
					LET cIniciaProceso = 'f';
					LET cContinuaProceso = 'f';
					LET cValidaContPro = 'f';
					
					-- SE REGISTRA PROCESO
					--SELECT DISTINCT(1) INTO iRespuesta
					SELECT COUNT(*) INTO iRespuesta
					FROM "informix".sw_ca_bitacoraprocesoxml
					WHERE nombre_oficio = cNombreOficio
					AND fecha_insert = dFechaInicio;
			
					--IF DBINFO('sqlca.sqlerrd2') > 0 THEN
					IF iRespuesta > 0 THEN
					
						SELECT num_intentos INTO iCtrlIntentos 
						FROM "informix".sw_ca_bitacoraprocesoxml 
						WHERE nombre_oficio = cNombreOficio AND fecha_insert = dFechaInicio;
						
						IF NVL(iCtrlIntentos,0) < pNumIntentos THEN
							
							LET iCtrlIntentos = NVL(iCtrlIntentos,0) + 1;
						
							UPDATE "informix".sw_ca_bitacoraprocesoxml
							SET clave_oficio = cGenClaveOficio, id_estatus = 'R', desc_estatus = 'REPROCESO', num_intentos = iCtrlIntentos, cod_error = '', desc_error = '', usuario_insert = pUsuario, fecha_hora_insert = dFechaHoraInicio
							WHERE nombre_oficio = cNombreOficio AND fecha_insert = dFechaInicio;
						
							LET vCuenta = vCuenta + 1;
					
							IF DBINFO('sqlca.sqlerrd2') = 0 THEN
								LET cIdCodRet = '01022';
								LET cDesCodRet = 'OCURRIO UN ERROR AL ACTUALIZAR EL ESTATUS DEL ARCHIVO: '||cNombreOficio;
								
								INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
								VALUES(cGenClaveOficio,cNombreOficio,cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
							ELSE
								LET cIniciaProceso = 't';
							END IF;
						
						ELSE
							
							LET cIdCodRet = '01028';
							LET cDesCodRet = 'HA LLEGADO AL NÚMERO MÁXIMO DE INTENTOS PERMITIDOS PARA LA CARGA DEL ARCHIVO: '||cNombreOficio;
							
							--UPDATE "informix".sw_ca_bitacoraprocesoxml
							--SET clave_oficio = cGenClaveOficio, id_estatus = 'N', desc_estatus = 'NO PROCESADO', cod_error = cIdCodRet, desc_error = cDesCodRet, fecha_publicacion = dFechaPublicacion, fecha_publicacion_date = dFechaPublicacionDate, usuario_insert = pUsuario, fecha_hora_insert = dFechaHoraInicio
							--WHERE nombre_oficio = cNombreOficio AND fecha_insert = dFechaInicio;
							UPDATE "informix".sw_ca_bitacoraprocesoxml
							SET clave_oficio = cGenClaveOficio,cod_error = cIdCodRet, desc_error = cDesCodRet, fecha_publicacion = dFechaPublicacion, fecha_publicacion_date = dFechaPublicacionDate, usuario_insert = pUsuario, fecha_hora_insert = dFechaHoraInicio
							WHERE nombre_oficio = cNombreOficio AND fecha_insert = dFechaInicio;
						
							LET vCuenta = vCuenta + 1;

							IF DBINFO('sqlca.sqlerrd2') = 0 THEN
								LET cIdCodRet = '01022';
								LET cDesCodRet = 'OCURRIO UN ERROR AL ACTUALIZAR EL ESTATUS DEL ARCHIVO: '||cNombreOficio;
								
								INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
								VALUES(cGenClaveOficio,cNombreOficio,cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
							END IF;
							
							-- SE ELIMINAN TODOS LOS ARCHIVO XML
							--LET cCmd = '';
							--LET cCmd = TRIM(cUsrbin)||"rm -rf "||TRIM(pRutaCarga)||TRIM(cNombreOficio);
							--SYSTEM TRIM(cCmd);
							
						END IF;			
					
					ELSE 
					
						LET iCtrlIntentos = 1;
						
						INSERT INTO "informix".sw_ca_bitacoraprocesoxml(clave_oficio,nombre_oficio,id_estatus,desc_estatus,num_intentos,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
						VALUES(cGenClaveOficio,cNombreOficio,'E','EN PROCESO',iCtrlIntentos,'','','','',pUsuario,dFechaInicio,dFechaHoraInicio);
						
						LET vCuenta = vCuenta + 1;
					
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cIdCodRet = '01023';
							LET cDesCodRet = 'OCURRIO UN ERROR AL REGISTRAR EL ESTATUS DEL ARCHIVO: '||cNombreOficio;
							
							INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
							VALUES(cGenClaveOficio,cNombreOficio,cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
						ELSE
							LET cIniciaProceso = 't';
						END IF;
							
					END IF;
				
				END IF;
				
				-- SE INICIA EL PROCESO DE LA CARGA
				IF cIniciaProceso = 't' THEN
					
					EXECUTE PROCEDURE "informix".sp_ca_cargaarchivoxml(pUsuario, pIdFuncion, TRIM(pRutaCarga), cNombreOficio)
					INTO cCodRetSpCarga;
					
					IF cCodRetSpCarga::INTEGER < 0 THEN
					
						--RAISE EXCEPTION cCodRetSpCarga::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdicnweb:sp_ca_cargaarchivoxml';
						LET cIdCodRet = cCodRetSpCarga;
						LET cDesCodRet = 'ERROR EN LA EJECUCIÓN DEL SP bdicnweb:sp_ca_cargaarchivoxml';
						
						INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
						VALUES(cGenClaveOficio,cNombreOficio,cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
												
						-- DE OCURRIR UN ERROR LOS ARCHIVOS SON COLOCADOS EN LA CARPETA DE NO PROCESADOS (se inserta nuevo registro en bitácora procesos xml)
						INSERT INTO "informix".sw_ca_bitacoraprocesoxml(clave_oficio,nombre_oficio,id_estatus,desc_estatus,num_intentos,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
						VALUES(cGenClaveOficio,cNombreOficio,'N','NO PROCESADO',iCtrlIntentos,cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
						
						LET vCuenta = vCuenta + 1;
					
						LET cCmd2 = '';
						LET cCmd2 = ''||TRIM(pRutaCarga)||TRIM(cNombreOficio)||' '||TRIM(pRutaCarga)||TRIM(pCarpetaNoProc)||'/';

						LET cCmd = '';
						LET cCmd = TRIM(cUsrbin)||'mv '||TRIM(cCmd2)||'';
						SYSTEM TRIM(cCmd);
												
						--LET cCmd = '';
						--LET cCmd = TRIM(cUsrbin)||'rm -rf '||TRIM(pRutaCarga)||TRIM(cNombreOficio);
						--SYSTEM TRIM(cCmd);
						
						LET cCmd = '';
						LET cCmd = TRIM(cUsrbin)||'rm -rf '||TRIM(pRutaCarga)||'scriptofixml'||TO_CHAR(CURRENT, '%Y%m%d%H%M%S')||'.sql';
						SYSTEM TRIM(cCmd);
						
						BEGIN WORK;						
						
					ELIF cCodRetSpCarga::INTEGER > 0 THEN
						LET cIdCodRet = '01024';
						LET cDesCodRet = 'OCURRIO UN ERROR AL REALIZAR LA CARGA DEL ARCHIVO: '||cNombreOficio;
						
						INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
						VALUES(cGenClaveOficio,cNombreOficio,cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
						
					ELIF cCodRetSpCarga::INTEGER = 0 THEN
						
						EXECUTE PROCEDURE "informix".sp_ca_procesaarchivoxml(pUsuario, pIdFuncion)
						INTO cCodRetSpProcesa, cNumOficioSp, iIdOficioSp;
						
						LET cNumOficioSp = TRIM(cNumOficioSp);
						
						IF cCodRetSpProcesa::INTEGER < 0 THEN
						
							--RAISE EXCEPTION cCodRetSpProcesa::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdicnweb:sp_ca_procesaarchivoxml';
							LET cIdCodRet = cCodRetSpProcesa;
							LET cDesCodRet = 'ERROR EN LA EJECUCIÓN DEL SP bdicnweb:sp_ca_procesaarchivoxml';
							
							INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
							VALUES(cGenClaveOficio,cNombreOficio,cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
							
						ELIF cCodRetSpProcesa::INTEGER > 0 THEN
							LET cIdCodRet = '01025';
							LET cDesCodRet = 'OCURRIO UN ERROR AL PROCESAR LA INFORMACIÓN DEL ARCHIVO: '||cNombreOficio;
							
							INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
							VALUES(cGenClaveOficio,cNombreOficio,cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);	
						
						ELIF cCodRetSpProcesa::INTEGER = 0 THEN
						
							-- SE VALIDA QUE EL ARCHIVO TENGA INFORMACIÓN
							SELECT COUNT(id_expediente) INTO iCountInfo
							FROM "informix".sw_ca_encabezado
							WHERE id_expediente = iIdOficioSp
							AND num_oficio = cNumOficioSp;
							
							IF iCountInfo = 0 THEN	
								LET cIdCodRet = '01026';
								LET cDesCodRet = 'EL ARCHIVO SE ENCUENTRA VACÍO';
								
								INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
								VALUES(cGenClaveOficio,cNombreOficio,cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);	
							
								LET cValidaContPro = 'f';
								
							ELSE
				
								SELECT num_oficio,num_expediente,solicitud_siara,folio,anio_oficio,id_area,desc_area,
								fecha_publicacion,dias_plazo,nombre_autoridad,referencia,usuario_insert,fecha_insert
								INTO cNumOficio,cNumExpediente,cSolicitudSiara,iFolio,dAnioOficio,iIdArea,cDescArea,
								dFechaPublicacion,iDiasPlazo,cNombreAutoridad,cReferencia,cUsuarioInsert,dFechaInsert 
								FROM "informix".sw_ca_encabezado 
								WHERE id_expediente = iIdOficioSp
								AND num_oficio = cNumOficioSp;
								
								LET dFechaPublicacionDate = MDY(SUBSTR(dFechaPublicacion, 6, 2), SUBSTR(dFechaPublicacion, 9, 2), SUBSTR(dFechaPublicacion, 1, 4));
								
								FOREACH WITH HOLD	--FOR Solicitud Especifica
									
									SELECT DISTINCT(id_solicitud_especifica)
									INTO iIdSolEspecifica
									FROM "informix".sw_ca_solicitudespecifica 
									WHERE id_expediente = iIdOficioSp 
									
									FOREACH WITH HOLD	--FOR Persona Solicitud/Cuentas Conocidas
									
										SELECT id_persona,caracter,des_tipo_persona,ap_paterno,ap_materno,nombre,rfc
										INTO iIdPersona,cCaracter,cDescTipoPersona,cApellPaterno,cApellMaterno,cNombre,cRFC
										FROM "informix".sw_ca_personassolicitud 
										WHERE id_expediente = iIdOficioSp 
										AND id_solicitud_especifica = iIdSolEspecifica
										
										SELECT entidad,cuenta
										INTO cEntidad,cCuenta
										FROM "informix".sw_ca_cuentasconocidas 
										WHERE id_expediente = iIdOficioSp 
										AND id_solicitud_especifica = iIdSolEspecifica
										AND id_persona = iIdPersona;
										
										-- SE ELIMINAN ACENTOS
										LET cApellPaterno = TRIM(UPPER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(UPPER(cApellPaterno)),'Á','A'),'É','E'),'Í','I'),'Ó','O'),'Ú','U')));
										LET cApellMaterno = TRIM(UPPER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(UPPER(cApellMaterno)),'Á','A'),'É','E'),'Í','I'),'Ó','O'),'Ú','U')));
										LET cNombre = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(UPPER(cNombre)),'Á','A'),'É','E'),'Í','I'),'Ó','O'),'Ú','U');
										
										IF TRIM(UPPER(cDescTipoPersona)) = 'FISICA' THEN
											
											IF LENGTH(TRIM(cRFC)) = 13 THEN 
												LET cFiltroRfc = TRIM(UPPER(cRFC));
											ELSE 
												LET cFiltroRfc = '';
											END IF;
											
											LET cNombre2 = NVL(TRIM(UPPER(SUBSTR(cNombre, CHARINDEX(' ', cNombre) + 1))), '');
											LET cNombre1 = TRIM(UPPER(SUBSTR(cNombre, 0, CHARINDEX(' ', cNombre))));
											LET cNom1ApPaterno = '%'||TRIM(TRIM(UPPER(cNombre1))||' '||TRIM(UPPER(cApellPaterno)))||'%';
											
											IF cApellMaterno = '' THEN 
												LET cApellMaterno = '';
											ELSE
												LET cApellMaterno = cApellMaterno;
											END IF;
											
											IF cNombre2 = '' THEN 
												LET cNombre2 = '';
											ELSE
												LET cNombre2 = cNombre2;
											END IF;
											
											-- VALIDACION HOMONIMOS
											LET bValidaHomonimo = 'f';
											LET iCountH = 0;
											SELECT COUNT(numcte)
											INTO iTotalNumCliente
											FROM bdinteg:"informix".si_cliente 
											WHERE tipo_cliente = 1
											AND nombre1 = cNombre1
											AND apell_paterno = cApellPaterno
											AND apell_materno = cApellMaterno
											AND nombre2 = cNombre2;
											
											IF iTotalNumCliente > 0 THEN
											
												IF cFiltroRfc = '' THEN --NO TRAE RFC EL OFICIO
												
													FOREACH	--FOR si_cliente													
														SELECT  FIRST 1 apell_paterno,apell_materno,nombre1||' '||nombre2,numcte 
														INTO cApellPaternoSiCte,cApellMaternoSiCte,cNombreSiCte,cNumCliente
														FROM bdinteg:"informix".si_cliente 
														WHERE tipo_cliente = 1
														AND nombre1 = cNombre1
														AND apell_paterno = cApellPaterno
														AND apell_materno = cApellMaterno
														AND nombre2 = cNombre2											
											
														INSERT INTO "informix".sw_ca_archivosxml(id_oficio,nombre_oficio,num_oficio,num_expediente,solicitud_siara,folio,anio_oficio,id_area,desc_area,fecha_publicacion,fecha_publicacion_date,
														dias_plazo,nombre_autoridad,referencia,id_persona_ps,caracter_ps,des_tipo_persona_ps,ap_paterno_ps,ap_materno_ps,nombre_ps,rfc_ps,entidad,cuenta,num_cliente,estatus,usuario_insert,fecha_insert,fecha_hora_insert)
														VALUES(iIdOficioSp,cNombreOficio,cNumOficio,cNumExpediente,cSolicitudSiara,iFolio,dAnioOficio,iIdArea,cDescArea,dFechaPublicacion,dFechaPublicacionDate,
														iDiasPlazo,cNombreAutoridad,cReferencia,iIdPersona,cCaracter,cDescTipoPersona,cApellPaternoSiCte,cApellMaternoSiCte,cNombreSiCte,cRFC,cEntidad,cCuenta,cNumCliente,'H',cUsuarioInsert,dFechaInicio,dFechaHoraInicio);
														
														IF DBINFO('sqlca.sqlerrd2') = 0 THEN
														
															LET cIdCodRet = '01027';
															LET cDesCodRet = 'OCURRIO UN ERROR AL GUARDAR LA INFORMACIÓN DEL ARCHIVO PROCESADO';
															
															INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
															VALUES(cGenClaveOficio,cNombreOficio,cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
														
															LET cValidaContPro = 'f';
														
														ELSE
															LET cValidaContPro = 't';
														END IF;
														
														LET cNumCliente = '';
													
														CONTINUE FOREACH;
													END FOREACH;												
													LET bValidaHomonimo = 't';
													
												ELSE -- TRAE RFC EL OFICIO
													FOREACH	--FOR si_cliente													
														SELECT apell_paterno,apell_materno,nombre1||' '||nombre2,numcte,rfc 
														INTO cApellPaternoSiCte,cApellMaternoSiCte,cNombreSiCte,cNumCliente, cRfcCliente
														FROM bdinteg:"informix".si_cliente 
														WHERE tipo_cliente = 1
														AND nombre1 = cNombre1
														AND apell_paterno = cApellPaterno
														AND apell_materno = cApellMaterno
														AND nombre2 = cNombre2	
														
														IF cRfcCliente = cFiltroRfc THEN
															LET iCountH = iCountH + 1;
														END IF;
														
														CONTINUE FOREACH;														
													END FOREACH; --END si_cliente
													
													--IF iCountH > 1 THEN 
													IF iCountH = 0 THEN 
														INSERT INTO "informix".sw_ca_archivosxml(id_oficio,nombre_oficio,num_oficio,num_expediente,solicitud_siara,folio,anio_oficio,id_area,desc_area,fecha_publicacion,fecha_publicacion_date,
														dias_plazo,nombre_autoridad,referencia,id_persona_ps,caracter_ps,des_tipo_persona_ps,ap_paterno_ps,ap_materno_ps,nombre_ps,rfc_ps,entidad,cuenta,num_cliente,estatus,usuario_insert,fecha_insert,fecha_hora_insert)
														VALUES(iIdOficioSp,cNombreOficio,cNumOficio,cNumExpediente,cSolicitudSiara,iFolio,dAnioOficio,iIdArea,cDescArea,dFechaPublicacion,dFechaPublicacionDate,
														iDiasPlazo,cNombreAutoridad,cReferencia,iIdPersona,cCaracter,cDescTipoPersona,cApellPaterno,cApellMaterno,cNombre,cRFC,cEntidad,cCuenta,cNumCliente,'H',cUsuarioInsert,dFechaInicio,dFechaHoraInicio);
															
														IF DBINFO('sqlca.sqlerrd2') = 0 THEN
														
															LET cIdCodRet = '01027';
															LET cDesCodRet = 'OCURRIO UN ERROR AL GUARDAR LA INFORMACIÓN DEL ARCHIVO PROCESADO';
															
															INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
															VALUES(cGenClaveOficio,cNombreOficio,cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
											
															LET cValidaContPro = 'f';
														
														ELSE
															LET cValidaContPro = 't';
														END IF;
														
														LET cNumCliente = '';
														
														LET bValidaHomonimo = 't';
														
													END IF;
												
												END IF;								
													
											END IF;
											
											LET cNumCliente = '';
											
											IF bValidaHomonimo = 'f' THEN -- VALIDACION SI EVALUO HOMONIMOS FISICOS
											
											SELECT COUNT(numcte)
											INTO iTotalNumCliente
											FROM bdinteg:"informix".si_cliente 
											WHERE nombre1 = cNombre1
											AND apell_paterno = cApellPaterno
											AND apell_materno = cApellMaterno
											AND nombre2 = cNombre2
											AND rfc = cFiltroRfc 
											AND tipo_cliente = 1; 
											--AND TRIM(UPPER(apell_materno)) = (CASE WHEN TRIM(cApellMaterno) = '' THEN TRIM(UPPER(apell_materno)) ELSE TRIM(cApellMaterno) END)
											--AND TRIM(UPPER(nombre2)) = (CASE WHEN TRIM(UPPER(cNombre2)) = '' THEN TRIM(UPPER(nombre2)) ELSE TRIM(UPPER(cNombre2)) END);
											--AND TRIM(UPPER(rfc)) = (CASE WHEN TRIM(cFiltroRfc) = '' THEN TRIM(UPPER(rfc)) ELSE TRIM(cFiltroRfc) END);					
											
											IF iTotalNumCliente > 0 THEN
											
												FOREACH	--FOR si_cliente
													
													SELECT  FIRST 1 apell_paterno,apell_materno,nombre1||' '||nombre2,numcte 
													INTO cApellPaternoSiCte,cApellMaternoSiCte,cNombreSiCte,cNumCliente
													FROM bdinteg:"informix".si_cliente 
													WHERE nombre1 = cNombre1
													AND apell_paterno = cApellPaterno
													AND apell_materno = cApellMaterno
													AND nombre2 = cNombre2
													AND rfc = cFiltroRfc 
													AND tipo_cliente = 1 
													--AND TRIM(UPPER(apell_materno)) = (CASE WHEN TRIM(cApellMaterno) = '' THEN TRIM(UPPER(apell_materno)) ELSE TRIM(cApellMaterno) END)
													--AND TRIM(UPPER(nombre2)) = (CASE WHEN TRIM(UPPER(cNombre2)) = '' THEN TRIM(UPPER(nombre2)) ELSE TRIM(UPPER(cNombre2)) END)
													--AND TRIM(UPPER(rfc)) = (CASE WHEN TRIM(cFiltroRfc) = '' THEN TRIM(UPPER(rfc)) ELSE TRIM(cFiltroRfc) END)
													
													INSERT INTO "informix".sw_ca_archivosxml(id_oficio,nombre_oficio,num_oficio,num_expediente,solicitud_siara,folio,anio_oficio,id_area,desc_area,fecha_publicacion,fecha_publicacion_date,
													dias_plazo,nombre_autoridad,referencia,id_persona_ps,caracter_ps,des_tipo_persona_ps,ap_paterno_ps,ap_materno_ps,nombre_ps,rfc_ps,entidad,cuenta,num_cliente,estatus,usuario_insert,fecha_insert,fecha_hora_insert)
													VALUES(iIdOficioSp,cNombreOficio,cNumOficio,cNumExpediente,cSolicitudSiara,iFolio,dAnioOficio,iIdArea,cDescArea,dFechaPublicacion,dFechaPublicacionDate,
													iDiasPlazo,cNombreAutoridad,cReferencia,iIdPersona,cCaracter,cDescTipoPersona,cApellPaternoSiCte,cApellMaternoSiCte,cNombreSiCte,cRFC,cEntidad,cCuenta,cNumCliente,cEstatus,cUsuarioInsert,dFechaInicio,dFechaHoraInicio);
													
													IF DBINFO('sqlca.sqlerrd2') = 0 THEN
													
														LET cIdCodRet = '01027';
														LET cDesCodRet = 'OCURRIO UN ERROR AL GUARDAR LA INFORMACIÓN DEL ARCHIVO PROCESADO';
														
														INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
														VALUES(cGenClaveOficio,cNombreOficio,cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
													
														LET cValidaContPro = 'f';
													
													ELSE
														LET cValidaContPro = 't';
													END IF;
													
													LET cNumCliente = '';
													
													CONTINUE FOREACH;
												END FOREACH;	--END si_cliente
											
											ELIF iTotalNumCliente = 0 THEN
											
												INSERT INTO "informix".sw_ca_archivosxml(id_oficio,nombre_oficio,num_oficio,num_expediente,solicitud_siara,folio,anio_oficio,id_area,desc_area,fecha_publicacion,fecha_publicacion_date,
												dias_plazo,nombre_autoridad,referencia,id_persona_ps,caracter_ps,des_tipo_persona_ps,ap_paterno_ps,ap_materno_ps,nombre_ps,rfc_ps,entidad,cuenta,num_cliente,estatus,usuario_insert,fecha_insert,fecha_hora_insert)
												VALUES(iIdOficioSp,cNombreOficio,cNumOficio,cNumExpediente,cSolicitudSiara,iFolio,dAnioOficio,iIdArea,cDescArea,dFechaPublicacion,dFechaPublicacionDate,
												iDiasPlazo,cNombreAutoridad,cReferencia,iIdPersona,cCaracter,cDescTipoPersona,cApellPaterno,cApellMaterno,cNombre,cRFC,cEntidad,cCuenta,cNumCliente,cEstatus,cUsuarioInsert,dFechaInicio,dFechaHoraInicio);
													
												IF DBINFO('sqlca.sqlerrd2') = 0 THEN
												
													LET cIdCodRet = '01027';
													LET cDesCodRet = 'OCURRIO UN ERROR AL GUARDAR LA INFORMACIÓN DEL ARCHIVO PROCESADO';
													
													INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
													VALUES(cGenClaveOficio,cNombreOficio,cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
									
													LET cValidaContPro = 'f';
												
												ELSE
													LET cValidaContPro = 't';
												END IF;
												
												LET cNumCliente = '';
												
											END IF;
											END IF; -- FIN VALIDACION SI EVALUO HOMONIMOS FISICOS
										ELIF TRIM(UPPER(cDescTipoPersona)) = 'MORAL' THEN
											
											IF LENGTH(TRIM(cRFC)) = 12 THEN 
												LET cFiltroRfc = TRIM(UPPER(cRFC));
											ELSE 
												LET cFiltroRfc = '';
											END IF;
											
											LET cValidaSegPalabra = INSTR(cNombre, ' ',1,2);
											IF cValidaSegPalabra = 0 THEN
												LET cSegundaPalabra = SUBSTR(cNombre, CHARINDEX(' ', cNombre) + 1);
											ELSE
												LET cSegundaPalabra = SUBSTR(cNombre, CHARINDEX(' ', cNombre)+1, INSTR(cNombre, ' ',1,2)- CHARINDEX(' ', cNombre)-1);												
											END IF;
											LET cPrimerPalabra = SUBSTR(cNombre, 0, CHARINDEX(' ', cNombre));
											LET cRazonSocial = TRIM(UPPER(cPrimerPalabra))|| ' ' || TRIM(UPPER(cSegundaPalabra)) || '%';
											
											IF cFiltroRfc = '' THEN 
												LET cFiltroRfc = '';
											ELSE
												LET cFiltroRfc = cFiltroRfc;
											END IF;

											-- VALIDA HOMONIMOS
											LET bValidaHomonimo = 'f';
											LET iCountH = 0;
											SELECT COUNT(numcte)
											INTO iTotalNumCliente
											FROM bdinteg:"informix".si_cliente
											WHERE razon_social LIKE cRazonSocial
											AND tipo_cliente = 1;
											
											--IF iTotalNumCliente > 1 THEN
											IF iTotalNumCliente > 0 THEN
												
												IF cFiltroRfc = '' THEN --NO TRAE RFC EL OFICIO
													
													FOREACH	--FOR si_cliente														
														SELECT  FIRST 1 razon_social,numcte 
														INTO cNombreSiCte,cNumCliente
														FROM bdinteg:"informix".si_cliente
														WHERE razon_social LIKE cRazonSocial
														AND tipo_cliente = 1 
														
														INSERT INTO "informix".sw_ca_archivosxml(id_oficio,nombre_oficio,num_oficio,num_expediente,solicitud_siara,folio,anio_oficio,id_area,desc_area,fecha_publicacion,fecha_publicacion_date,
														dias_plazo,nombre_autoridad,referencia,id_persona_ps,caracter_ps,des_tipo_persona_ps,ap_paterno_ps,ap_materno_ps,nombre_ps,rfc_ps,entidad,cuenta,num_cliente,estatus,usuario_insert,fecha_insert,fecha_hora_insert)
														VALUES(iIdOficioSp,cNombreOficio,cNumOficio,cNumExpediente,cSolicitudSiara,iFolio,dAnioOficio,iIdArea,cDescArea,dFechaPublicacion,dFechaPublicacionDate,
														iDiasPlazo,cNombreAutoridad,cReferencia,iIdPersona,cCaracter,cDescTipoPersona,cApellPaterno,cApellMaterno,cNombreSiCte,cRFC,cEntidad,cCuenta,cNumCliente,'H',cUsuarioInsert,dFechaInicio,dFechaHoraInicio);
														
														IF DBINFO('sqlca.sqlerrd2') = 0 THEN
															
															LET cIdCodRet = '01027';
															LET cDesCodRet = 'OCURRIO UN ERROR AL GUARDAR LA INFORMACIÓN DEL ARCHIVO PROCESADO';
															
															INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
															VALUES(cGenClaveOficio,cNombreOficio,cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
														
															LET cValidaContPro = 'f';
														
														ELSE
															LET cValidaContPro = 't';
														END IF;
														
														LET cNumCliente = '';
														
														CONTINUE FOREACH;
													END FOREACH;	--FOR si_cliente
														
													LET bValidaHomonimo = 't';
													
												ELSE -- TRAE RFC EL OFICIO
													
													FOREACH	--FOR si_cliente														
														SELECT razon_social,numcte, rfc 
														INTO cNombreSiCte,cNumCliente, cRfcCliente
														FROM bdinteg:"informix".si_cliente
														WHERE razon_social LIKE cRazonSocial
														AND tipo_cliente = 1 
														
														IF cRfcCliente = cFiltroRfc THEN
															LET iCountH = iCountH + 1;
														END IF;

														CONTINUE FOREACH;
													END FOREACH;	--FOR si_cliente

													IF iCountH = 0 THEN 
													
														INSERT INTO "informix".sw_ca_archivosxml(id_oficio,nombre_oficio,num_oficio,num_expediente,solicitud_siara,folio,anio_oficio,id_area,desc_area,fecha_publicacion,fecha_publicacion_date,
														dias_plazo,nombre_autoridad,referencia,id_persona_ps,caracter_ps,des_tipo_persona_ps,ap_paterno_ps,ap_materno_ps,nombre_ps,rfc_ps,entidad,cuenta,num_cliente,estatus,usuario_insert,fecha_insert,fecha_hora_insert)
														VALUES(iIdOficioSp,cNombreOficio,cNumOficio,cNumExpediente,cSolicitudSiara,iFolio,dAnioOficio,iIdArea,cDescArea,dFechaPublicacion,dFechaPublicacionDate,
														iDiasPlazo,cNombreAutoridad,cReferencia,iIdPersona,cCaracter,cDescTipoPersona,cApellPaterno,cApellMaterno,cNombreSiCte,cRFC,cEntidad,cCuenta,cNumCliente,'H',cUsuarioInsert,dFechaInicio,dFechaHoraInicio);
														
														IF DBINFO('sqlca.sqlerrd2') = 0 THEN
															
															LET cIdCodRet = '01027';
															LET cDesCodRet = 'OCURRIO UN ERROR AL GUARDAR LA INFORMACIÓN DEL ARCHIVO PROCESADO';
															
															INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
															VALUES(cGenClaveOficio,cNombreOficio,cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
														
															LET cValidaContPro = 'f';
														
														ELSE
															LET cValidaContPro = 't';
														END IF;
														
														LET cNumCliente = '';
														
														LET bValidaHomonimo = 't';
														
													END IF;

												END IF;											
												
											END IF;
											
											LET cNumCliente = '';
											
											IF bValidaHomonimo = 'f' THEN -- VALIDACION SI EVALUO HOMONIMOS MORAL
										
											SELECT COUNT(numcte)
											INTO iTotalNumCliente
											FROM bdinteg:"informix".si_cliente
											WHERE razon_social LIKE cRazonSocial
											AND rfc = cFiltroRfc
											AND tipo_cliente = 1; 
											
											IF iTotalNumCliente > 0 THEN

												FOREACH	--FOR si_cliente
														
													SELECT  FIRST 1 razon_social,numcte 
													INTO cNombreSiCte,cNumCliente
													FROM bdinteg:"informix".si_cliente
													WHERE razon_social LIKE cRazonSocial
													AND rfc = cFiltroRfc
													AND tipo_cliente = 1 
													
													INSERT INTO "informix".sw_ca_archivosxml(id_oficio,nombre_oficio,num_oficio,num_expediente,solicitud_siara,folio,anio_oficio,id_area,desc_area,fecha_publicacion,fecha_publicacion_date,
													dias_plazo,nombre_autoridad,referencia,id_persona_ps,caracter_ps,des_tipo_persona_ps,ap_paterno_ps,ap_materno_ps,nombre_ps,rfc_ps,entidad,cuenta,num_cliente,estatus,usuario_insert,fecha_insert,fecha_hora_insert)
													VALUES(iIdOficioSp,cNombreOficio,cNumOficio,cNumExpediente,cSolicitudSiara,iFolio,dAnioOficio,iIdArea,cDescArea,dFechaPublicacion,dFechaPublicacionDate,
													iDiasPlazo,cNombreAutoridad,cReferencia,iIdPersona,cCaracter,cDescTipoPersona,cApellPaterno,cApellMaterno,cNombreSiCte,cRFC,cEntidad,cCuenta,cNumCliente,cEstatus,cUsuarioInsert,dFechaInicio,dFechaHoraInicio);
													
													IF DBINFO('sqlca.sqlerrd2') = 0 THEN
														
														LET cIdCodRet = '01027';
														LET cDesCodRet = 'OCURRIO UN ERROR AL GUARDAR LA INFORMACIÓN DEL ARCHIVO PROCESADO';
														
														INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
														VALUES(cGenClaveOficio,cNombreOficio,cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
													
														LET cValidaContPro = 'f';
													
													ELSE
														LET cValidaContPro = 't';
													END IF;
													
													LET cNumCliente = '';
													
													CONTINUE FOREACH;
												END FOREACH;	--FOR si_cliente
											
											ELIF iTotalNumCliente = 0 THEN
											
												INSERT INTO "informix".sw_ca_archivosxml(id_oficio,nombre_oficio,num_oficio,num_expediente,solicitud_siara,folio,anio_oficio,id_area,desc_area,fecha_publicacion,fecha_publicacion_date,
												dias_plazo,nombre_autoridad,referencia,id_persona_ps,caracter_ps,des_tipo_persona_ps,ap_paterno_ps,ap_materno_ps,nombre_ps,rfc_ps,entidad,cuenta,num_cliente,estatus,usuario_insert,fecha_insert,fecha_hora_insert)
												VALUES(iIdOficioSp,cNombreOficio,cNumOficio,cNumExpediente,cSolicitudSiara,iFolio,dAnioOficio,iIdArea,cDescArea,dFechaPublicacion,dFechaPublicacionDate,
												iDiasPlazo,cNombreAutoridad,cReferencia,iIdPersona,cCaracter,cDescTipoPersona,cApellPaterno,cApellMaterno,cNombre,cRFC,cEntidad,cCuenta,cNumCliente,cEstatus,cUsuarioInsert,dFechaInicio,dFechaHoraInicio);
													
												IF DBINFO('sqlca.sqlerrd2') = 0 THEN
												
													LET cIdCodRet = '01027';
													LET cDesCodRet = 'OCURRIO UN ERROR AL GUARDAR LA INFORMACIÓN DEL ARCHIVO PROCESADO';
													
													INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
													VALUES(cGenClaveOficio,cNombreOficio,cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
												
													LET cValidaContPro = 'f';
												
												ELSE
													LET cValidaContPro = 't';
												END IF;
												
												LET cNumCliente = '';
												
											END IF;
											END IF; -- FIN VALIDACION SI EVALUO HOMONIMOS MORAL
										ELSE --si no es ni MORAL ni FISICA
											
											INSERT INTO "informix".sw_ca_archivosxml(id_oficio,nombre_oficio,num_oficio,num_expediente,solicitud_siara,folio,anio_oficio,id_area,desc_area,fecha_publicacion,fecha_publicacion_date,
											dias_plazo,nombre_autoridad,referencia,id_persona_ps,caracter_ps,des_tipo_persona_ps,ap_paterno_ps,ap_materno_ps,nombre_ps,rfc_ps,entidad,cuenta,num_cliente,estatus,usuario_insert,fecha_insert,fecha_hora_insert)
											VALUES(iIdOficioSp,cNombreOficio,cNumOficio,cNumExpediente,cSolicitudSiara,iFolio,dAnioOficio,iIdArea,cDescArea,dFechaPublicacion,dFechaPublicacionDate,
											iDiasPlazo,cNombreAutoridad,cReferencia,iIdPersona,cCaracter,cDescTipoPersona,cApellPaterno,cApellMaterno,cNombre,cRFC,cEntidad,cCuenta,cNumCliente,cEstatus,cUsuarioInsert,dFechaInicio,dFechaHoraInicio);
												
											IF DBINFO('sqlca.sqlerrd2') = 0 THEN
											
												LET cIdCodRet = '01027';
												LET cDesCodRet = 'OCURRIO UN ERROR AL GUARDAR LA INFORMACIÓN DEL ARCHIVO PROCESADO';
												
												INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
												VALUES(cGenClaveOficio,cNombreOficio,cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
											
												LET cValidaContPro = 'f';
											
											ELSE
												LET cValidaContPro = 't';
											END IF;
										
										END IF;
										
										CONTINUE FOREACH;
									END FOREACH;	--END Persona Solicitud/Cuentas Conocidas
									
									CONTINUE FOREACH;
								END FOREACH;	--END Solicitud Especifica
							END IF;
							
							IF cValidaContPro = 'f' THEN
								LET cContinuaProceso = 'f';
							ELIF cValidaContPro = 't' THEN
								LET cContinuaProceso = 't';
							END IF;
							
						END IF;	--END SP procesa
						
					END IF;	--END SP carga
					
				END IF;	--END iniciaproceso
				
				-- VALIDA EL NÚMERO DE INTENTOS PARA ACTUALIZAR PROCESO
				IF NVL(iCtrlIntentos,0) = pNumIntentos THEN
				
					IF cContinuaProceso = 't' THEN 
					
						UPDATE "informix".sw_ca_bitacoraprocesoxml
						SET id_estatus = 'S', desc_estatus = 'PROCESADO', fecha_publicacion = dFechaPublicacion, fecha_publicacion_date = dFechaPublicacionDate, usuario_insert = pUsuario, fecha_hora_insert = dFechaHoraInicio
						WHERE nombre_oficio = cNombreOficio AND fecha_insert = dFechaInicio;
					
						LET vCuenta = vCuenta + 1;
					
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cIdCodRet = '01022';
							LET cDesCodRet = 'OCURRIO UN ERROR AL ACTUALIZAR EL ESTATUS DEL ARCHIVO: '||cNombreOficio;
							
							INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
							VALUES(cGenClaveOficio,cNombreOficio,cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
						END IF;
						
						--
						LET cCmd2 = '';
						LET cCmd2 = ''||TRIM(pRutaCarga)||TRIM(cNombreOficio)||' '||TRIM(pRutaCarga)||TRIM(pCarpetaProc)||'/';

						LET cCmd = '';
						LET cCmd = TRIM(cUsrbin)||'mv '||TRIM(cCmd2)||'';
						SYSTEM TRIM(cCmd);
						
						--LET cCmd = '';
						--LET cCmd = TRIM(cUsrbin)||'rm -rf '||TRIM(pRutaCarga)||TRIM(cNombreOficio);
						--SYSTEM TRIM(cCmd);
											
					ELIF cContinuaProceso = 'f' THEN 
						
						LET cIdCodRet = '00824';
						LET cDesCodRet = 'EL ARCHIVO DE DATOS NO TIENE EL FORMATO CORRECTO, VERIFIQUE';
						
						INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
						VALUES(cGenClaveOficio,cNombreOficio,cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
				
						LET cIdCodRet = '01028';
						LET cDesCodRet = 'HA LLEGADO AL NÚMERO MÁXIMO DE INTENTOS PERMITIDOS PARA LA CARGA DEL ARCHIVO: '||cNombreOficio;
						
						--UPDATE "informix".sw_ca_bitacoraprocesoxml
						--SET clave_oficio = cGenClaveOficio, id_estatus = 'N', desc_estatus = 'NO PROCESADO', cod_error = cIdCodRet, desc_error = cDesCodRet, fecha_publicacion = dFechaPublicacion, fecha_publicacion_date = dFechaPublicacionDate, usuario_insert = pUsuario, fecha_hora_insert = dFechaHoraInicio
						--WHERE nombre_oficio = cNombreOficio AND fecha_insert = dFechaInicio;
						UPDATE "informix".sw_ca_bitacoraprocesoxml
						SET clave_oficio = cGenClaveOficio, cod_error = cIdCodRet, desc_error = cDesCodRet, fecha_publicacion = dFechaPublicacion, fecha_publicacion_date = dFechaPublicacionDate, usuario_insert = pUsuario, fecha_hora_insert = dFechaHoraInicio
						WHERE nombre_oficio = cNombreOficio AND fecha_insert = dFechaInicio;
					
						LET vCuenta = vCuenta + 1;
						
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cIdCodRet = '01022';
							LET cDesCodRet = 'OCURRIO UN ERROR AL ACTUALIZAR EL ESTATUS DEL ARCHIVO: '||cNombreOficio;
							
							INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
							VALUES(cGenClaveOficio,cNombreOficio,cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
						END IF;
						
						-- SE ELIMINAN TODOS LOS ARCHIVO XML							
						--LET cCmd = '';
						--LET cCmd = TRIM(cUsrbin)||'rm -rf '||TRIM(pRutaCarga)||TRIM(cNombreOficio);
						--SYSTEM TRIM(cCmd);
						
					END IF;
				
				ELSE
				
					IF cContinuaProceso = 't' THEN 
					
						UPDATE "informix".sw_ca_bitacoraprocesoxml
						SET id_estatus = 'S', desc_estatus = 'PROCESADO', fecha_publicacion = dFechaPublicacion, fecha_publicacion_date = dFechaPublicacionDate, usuario_insert = pUsuario, fecha_hora_insert = dFechaHoraInicio
						WHERE nombre_oficio = cNombreOficio AND fecha_insert = dFechaInicio;
						
						LET vCuenta = vCuenta + 1;
						
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cIdCodRet = '01022';
							LET cDesCodRet = 'OCURRIO UN ERROR AL ACTUALIZAR EL ESTATUS DEL ARCHIVO: '||cNombreOficio;
							
							INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
							VALUES(cGenClaveOficio,cNombreOficio,cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
						END IF;
						
						--
						LET cCmd2 = '';
						LET cCmd2 = ''||TRIM(pRutaCarga)||TRIM(cNombreOficio)||' '||TRIM(pRutaCarga)||TRIM(pCarpetaProc)||'/';

						LET cCmd = '';
						LET cCmd = TRIM(cUsrbin)||'mv '||TRIM(cCmd2)||'';
						SYSTEM TRIM(cCmd);
						
						--LET cCmd = '';
						--LET cCmd = TRIM(cUsrbin)||'rm -rf '||TRIM(pRutaCarga)||TRIM(cNombreOficio);
						--SYSTEM TRIM(cCmd);
						
					END IF;
						
				END IF;
				
				-- SE INICIAN VALIDACIONES DE ESTATUS
				LET cNomOfValEst = TRIM(cNombreOficio);
				
				-- Validación UEAF
				SELECT COUNT(*) INTO iCounUeaf
				FROM "informix".sw_ca_archivosxml 
				WHERE nombre_oficio = cNomOfValEst
				AND fecha_hora_insert = dFechaHoraInicio
				AND UPPER(nombre_autoridad) LIKE '%UNIDAD ESPECIALIZADA EN ANALISIS FINANCIERO%'; 
				--AND TRIM(UPPER(nombre_autoridad)) LIKE '%UNIDAD ESPECIALIZADA EN ANALISIS FINANCIERO%'; 
					
				-- Validación UIF
				SELECT COUNT(*) INTO iCounUifPe
				FROM "informix".sw_ca_archivosxml 
				WHERE nombre_oficio = cNomOfValEst
				AND fecha_hora_insert = dFechaHoraInicio
				AND UPPER(nombre_autoridad) LIKE '%UNIDAD DE INTELIGENCIA FINANCIERA%';
				--AND TRIM(UPPER(nombre_autoridad)) LIKE '%UNIDAD DE INTELIGENCIA FINANCIERA%';
				
				IF iCounUifPe > 0 OR iCounUeaf > 0 THEN
					UPDATE "informix".sw_ca_archivosxml SET estatus = 'P' 
					WHERE nombre_oficio = cNomOfValEst AND fecha_hora_insert = dFechaHoraInicio;
					
				ELSE
					
					-- Validación Petición Especifica 
					SELECT COUNT(*) INTO iCounUifPe
					FROM "informix".sw_ca_archivosxml 
					WHERE nombre_oficio = cNomOfValEst
					AND fecha_hora_insert = dFechaHoraInicio
					AND UPPER(entidad) LIKE '%BANCOPPEL%' AND cuenta <> '';
					--AND TRIM(UPPER(entidad)) LIKE '%BANCOPPEL%' AND cuenta <> '';
					
					IF iCounUifPe > 0 THEN
						UPDATE "informix".sw_ca_archivosxml SET estatus = 'P' 
						WHERE nombre_oficio = cNomOfValEst AND fecha_hora_insert = dFechaHoraInicio;
					
					ELSE 
						-- REVISION DE REGISTROS HOMONIMOS 
						SELECT COUNT(*) INTO iTotRegHomonimos FROM "informix".sw_ca_archivosxml 
						WHERE nombre_oficio =  cNomOfValEst AND fecha_hora_insert = dFechaHoraInicio AND estatus = 'H';
					
						SELECT COUNT(*) INTO iTotRegValEst FROM "informix".sw_ca_archivosxml 
						WHERE nombre_oficio =  cNomOfValEst AND fecha_hora_insert = dFechaHoraInicio;
						
						SELECT COUNT(*) INTO iTotSiCteValEst FROM "informix".sw_ca_archivosxml 
						WHERE nombre_oficio = cNomOfValEst AND fecha_hora_insert = dFechaHoraInicio AND num_cliente <> ''  AND estatus <> 'H'; 
						
						SELECT COUNT(*) INTO iTotNoCteValEst FROM "informix".sw_ca_archivosxml 
						WHERE nombre_oficio = cNomOfValEst AND fecha_hora_insert = dFechaHoraInicio AND num_cliente = '' AND estatus <> 'H'; 
						
						IF iTotSiCteValEst = iTotRegValEst THEN
					
							UPDATE "informix".sw_ca_archivosxml SET estatus = 'P' 
							WHERE nombre_oficio = cNomOfValEst AND fecha_hora_insert = dFechaHoraInicio;
						
						ELIF iTotNoCteValEst = iTotRegValEst THEN
							
							FOREACH
								--SELECT DISTINCT(1) INTO iRespuesta
								SELECT COUNT(*) INTO iRespuesta
								FROM "informix".sw_ca_archivosxml
								WHERE nombre_oficio = cNomOfValEst
								AND fecha_hora_insert = dFechaHoraInicio
								GROUP BY nombre_ps,ap_paterno_ps,ap_materno_ps HAVING COUNT(*) > 1
							END FOREACH;
							
							--IF DBINFO('sqlca.sqlerrd2') > 0 THEN
							IF iRespuesta > 0 THEN
							
								UPDATE "informix".sw_ca_archivosxml SET estatus = 'P' 
								WHERE nombre_oficio = cNomOfValEst AND fecha_hora_insert = dFechaHoraInicio;
							
							ELSE 
							
								UPDATE "informix".sw_ca_archivosxml SET estatus = 'N' 
								WHERE nombre_oficio = cNomOfValEst AND fecha_hora_insert = dFechaHoraInicio;
							
							END IF;
							
						ELIF (iTotSiCteValEst + iTotNoCteValEst) = iTotRegValEst THEN
					
							UPDATE "informix".sw_ca_archivosxml SET estatus = 'M' 
							WHERE nombre_oficio = cNomOfValEst AND fecha_hora_insert = dFechaHoraInicio;
						
						ELIF iTotRegHomonimos > 0 AND (iTotSiCteValEst > 0 OR iTotNoCteValEst > 0) THEN
					
							UPDATE "informix".sw_ca_archivosxml SET estatus = 'M' 
							WHERE nombre_oficio = cNomOfValEst AND fecha_hora_insert = dFechaHoraInicio;
													
						END IF;
						
					END IF;
					
				END IF;
				-- END VALIDACIONES DE ESTATUS
				
				--Hago commit y vuelvo a iniciar
				IF vCuenta >= 300 THEN
					COMMIT WORK;
					LET vCuenta = 0;
					BEGIN WORK;
				END IF;
				
			END FOREACH;	--END Principal
			
		COMMIT WORK;
		
	    TRUNCATE TABLE "informix".sw_ca_cuentasconocidas;
		TRUNCATE TABLE "informix".sw_ca_personassolicitud;
		TRUNCATE TABLE "informix".sw_ca_solicitudespecifica;
		TRUNCATE TABLE "informix".sw_ca_solicitudpartes;
		TRUNCATE TABLE "informix".sw_ca_encabezado;
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;	
		
		IF cIdCodRet = '00000' THEN
			-- PROCESO EXITOSO
			LET cIdPlantilla = 'WEB_PLAXML';
		ELIF cIdCodRet <> '00000' THEN
			-- PROCESO CON ERRORES
			LET cIdPlantilla = 'WEB_ERRXML';
		END IF;
		
		LET cStr6 = 'NOTIFICACION CARGA AUTOMATICA DE ARCHIVOS XML';
		LET cStr7 = 'CARGA AUTOMATICA DE ARCHIVOS XML';
		LET dHoy = CURRENT;
		
		-- NOTIFICACIÓN VÍA CORREO ELECTRÓNICO
		FOREACH 
		
			SELECT id_usuario INTO cIdUsuario
			FROM bdinteg:"informix".si_seg_usuarios_funciones 
			WHERE id_funcion = 'ROA232'
			
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(
			'1',
			'WEB_PLAROF',
			TRIM(cIdPlantilla),
			cIdUsuario,
			'',
			'',
			'1',
			'',
			'',
			'',
			'',
			'',
			TRIM(cStr6),
			TRIM(cStr7),
			'',
			'',
			'',
			'',
			'',
			1,
			0,
			0,
			0,
			0,
			CURRENT,
			'') INTO cCodRetSp; 
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdimnsj:sp_registra_evento';
			ELIF iCodRetSp > 0 THEN
				
				--LET cCodRet = '01018';
				LET cIdCodRet = '01018';
				LET cDesCodRet = 'OCURRIO UN ERROR EN LA EJECUCIÓN DEL SP bdimnsj:"informix".sp_registra_evento, VERIFIQUE';
				LET cBanDetError = 't';
				
				---UPDATE "informix".sw_ca_statuscargaxml
				---SET status = 'E', bandera_error = cBanDetError, cod_error = cIdCodRet, desc_error = cDesCodRet, fecha_insert = dFechaInicio, fecha_hora_insert = dFechaHoraInicio
				---WHERE clave_oficio = cGenClaveOficio AND usuario_insert = pUsuario;
				
				INSERT INTO "informix".sw_ca_bitacoraerroresxml(clave_oficio,nombre_oficio,cod_error,desc_error,fecha_publicacion,fecha_publicacion_date,usuario_insert,fecha_insert,fecha_hora_insert)
				VALUES(cGenClaveOficio,cNombreOficio,cIdCodRet,cDesCodRet,dFechaPublicacion,dFechaPublicacionDate,pUsuario,dFechaInicio,dFechaHoraInicio);
								
			END IF;
		
		END FOREACH; 
		
		-- ACTUALIZA STATUS FINAL
		UPDATE "informix".sw_ca_statuscargaxml
		SET status = 'T', bandera_error = cBanDetError, fecha_insert = dFechaInicio, fecha_hora_insert = dFechaHoraInicio
		WHERE clave_oficio = cGenClaveOficio AND usuario_insert = pUsuario;
		
		RETURN cCodRet, cBanDetError;
			
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 27/11/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CARGA AUTOMÁTICA DE ARCHIVOS XML',
'DESCRIPCION: SPL encargado de realizar el proceso de carga automática de archivos XML.',
'AUTOR: L. Montserrat León Amador',
'FECHA: 09/02/2018',
'DESCRIPCION: Se coloca nueva validación para tratar los status del proceso y del archivo cuando éste no cuenta con el formato esperado.',
'AUTOR: L. Montserrat León Amador',
'FECHA: 15/06/2018',
'DESCRIPCION: Se coloca nueva validación para omitir procesar los archivos (por cNombreOficio) que ya fueron procesados en ejecuciones anteriores.',
'Dichos archivos no se moverán a ninguna carpeta y se bitacorean con el id_estatus Y - YA PROCESADO en la tabla sw_ca_bitacoraprocesoxml.',
'Adicional a esto se coloca un TRIM sobre la variable cNombreOficio, cuando ésta se encuentra involucrada en la función SYSTEM.',
'AUTOR: L. Montserrat León Amador',
'FECHA: 28/06/2018',
'DESCRIPCION: Se coloca nueva validación para tratar los errores ocurridos al momento de realizar la carga del archivo a tablas de paso,',
'de ocurrir un error los archivos serán colocados en la carpeta de no procesados (se inserta nuevo registro en bitácora procesos xml).',
'AUTOR: L. Montserrat León Amador',
'FECHA: 13/07/2018',
'DESCRIPCION: Se agrega un DISTINCT al query que valida si el archivo ya ha sido procesado.',
'AUTOR: L. Montserrat León Amador',
'FECHA: 10/08/2018',
'DESCRIPCION: Se agrega un FOREACH al query que clasifica los estatus como positivos o negativos.',
'Se atiende solicitud para agregar nuevamente la instrucción SET ISOLATION TO DIRTY READ en la línea 278.',
'AUTOR: Rodolfo Conde Flores',
'FECHA: 01/10/2019',
'DESCRIPCION: Se realizan ajustes a reglas para identificar los clientes como positivos, negativos y mixtos.',
'Se agrega nueva evaluación para identificación de clientes como Homonimos',
'AUTOR: Uriel Amador Islas',
'FECHA: 13/06/2024',
'DESCRIPCION: Se implementa commit por cada 300 insersiones y/o actualizaciones en la tabla sw_ca_bitacoraprocesoxml.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultahistorialstatusmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSol CHAR(20), pRegistros INTEGER, pRecuperacion INTEGER) 
	RETURNING CHAR(5) AS codigoRetorno,
		  CHAR(2) AS statusSolicitud,
		  CHAR(40) AS descricpion_status,
		  DATE AS fechaEntrada,
		  DATE AS fechaSalida,
		  CHAR(8) AS ejecutivo,
		  CHAR(45) AS nombre_ejecutivo;
		  
	
	DEFINE cCodRet			CHAR(5);
	DEFINE cCodRetSp		CHAR(6); 
	DEFINE cMensajeRet		CHAR(80);
	DEFINE cComentario		CHAR(80);
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cErrorInfo		CHAR(80);
	DEFINE cStatusSol		CHAR(2);
	DEFINE dFechaEntrada	DATE;
	DEFINE dFechaSalida		DATE;
	DEFINE iNoRegs			INTEGER;
	DEFINE iRegistros 		INTEGER;
	DEFINE iRecuperacion	INTEGER;
	DEFINE cDescStatus		CHAR(40);
	DEFINE cEjecutivo		CHAR(8);
	DEFINE cNombreEjecutivo	CHAR(45);
	DEFINE cEmpresa			CHAR(3);
	DEFINE cCanal			CHAR(1);
	
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= "";
	LET cCodRet				= "00000";
	LET cCodRetSP			= "";
	LET cMensajeRet			= "";
	LET cStatusSol			= "";
	LET dFechaEntrada		= DATE(1);
	LET dFechaSalida		= DATE(1);
	LET iNoRegs				= 0;
	LET iRegistros			= 0;
	LET iRecuperacion		= 0;
	LET cDescStatus		    = '';
	LET cEjecutivo		    = '';
	LET cNombreEjecutivo    = '';
	LET cEmpresa			= '001';
	LET cCanal              = '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cStatusSol, cDescStatus, dFechaEntrada, dFechaSalida, cEjecutivo, cNombreEjecutivo;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/home/e10000315/sp_consultahistorialstatusmc.out';
		--TRACE ON;
		
		IF NVL(pUsuario, '') = '' OR NVL(pIdFuncion, '') = '' OR NVL(pNumSol, '') = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cStatusSol, cDescStatus, dFechaEntrada, dFechaSalida, cEjecutivo, cNombreEjecutivo;
		END IF;
		
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cStatusSol, cDescStatus, dFechaEntrada, dFechaSalida, cEjecutivo, cNombreEjecutivo;
		END IF;
		
		FOREACH
			EXECUTE PROCEDURE bdisolic:'informix'.sp_mc_obtenhistorialstatus(cEmpresa, pNumSol) 
			INTO cCodRetSp, cMensajeRet,cStatusSol,dFechaEntrada,dFechaSalida
				IF	cCodRetSp = '000001' THEN
					LET cCodRet = '00017';
					RETURN cCodRet, cStatusSol, cDescStatus, dFechaEntrada, dFechaSalida, cEjecutivo, cNombreEjecutivo;
				END IF;
				IF cCodRetSp <> '000000' THEN
					LET cCodRet = cCodRetSp;
					RETURN cCodRet, cStatusSol, cDescStatus, dFechaEntrada, dFechaSalida, cEjecutivo, cNombreEjecutivo;
				ELSE
					IF iRegistros >= pRegistros THEN
						IF iRecuperacion < pRecuperacion THEN
							SET ISOLATION TO DIRTY READ;
							-- SELECCION DE LA DESCRIPCION DEL ESTATUS
							SELECT UPPER(NVL(descripcion, ''))
							INTO cDescStatus
							FROM bdisolic:ss_status_sol
							WHERE status_solicitud = cStatusSol;
							
							SELECT canal_sol 
							INTO cCanal
							FROM bdisolic:ss_solicitudes
							WHERE empresa = '001' AND num_solicitud = pNumSol;
							
							IF cCanal IN ('6','7') THEN
							    -- NOMBRE Y NUMERO DEL EJECUTIVO PARA CANAL 6 Y 7 QUITANDO EL AT DE ORIGEN PARA EVITAR ERROR -284
								SELECT Limit 1 ejecutivo_auto, UPPER(NVL(b.nombre, ''))
								INTO cEjecutivo, cNombreEjecutivo
								FROM bdisolic:ss_autorizacion a LEFT JOIN bdinteg:si_ejecut b ON b.ejecutivo = a.ejecutivo_auto
								WHERE num_solicitud = pNumSol
									AND status_solicitud = cStatusSol
									AND fecha_entrada = dFechaEntrada
									AND fecha_salida = dFechaSalida
									AND comentario <> 'Autorizada(OneClick)';
							
							ELSE
								-- NOMBRE Y NUMERO DEL EJECUTIVO
								SELECT ejecutivo_auto, UPPER(NVL(b.nombre, ''))
								INTO cEjecutivo, cNombreEjecutivo
								FROM bdisolic:ss_autorizacion a LEFT JOIN bdinteg:si_ejecut b ON b.ejecutivo = a.ejecutivo_auto
								WHERE num_solicitud = pNumSol
									AND status_solicitud = cStatusSol
									AND fecha_entrada = dFechaEntrada
									AND fecha_salida = dFechaSalida;
							END IF;
												
							LET iRecuperacion = iRecuperacion + 1;
							RETURN cCodRet, cStatusSol, cDescStatus, dFechaEntrada, dFechaSalida, cEjecutivo, cNombreEjecutivo WITH RESUME;
							LET iNoRegs = iNoRegs + 1;
						END IF;
					END IF;
					LET iRegistros = iRegistros + 1;
				END IF;
		END FOREACH;
		IF  iNoRegs = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cStatusSol, cDescStatus, dFechaEntrada, dFechaSalida, cEjecutivo, cNombreEjecutivo;
		END IF;
	END
END PROCEDURE
DOCUMENT 
'DESCRIPCION: Sp Intermedio bdisolic:sp_mc_obtenhistorialstatus para la obtencion del historial de los status de la solicitud',
'AUTOR : Esparza Brenis Fernando Martin',
'FECHA : 31/12/2013';

CREATE PROCEDURE "informix".sp_catalogodivisa(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(3) AS clave,
			CHAR(30) AS descripcion,
			CHAR(2) AS divisa;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cClave CHAR(3);
	DEFINE cDescripcion CHAR(30);
	DEFINE cDivisa CHAR(2);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cClave = '';
	LET cDescripcion = '';
	LET cDivisa = '';
	LET iNoRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cClave, cDescripcion, cDivisa;	
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogodivisa.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cClave, cDescripcion, cDivisa;	
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cClave, cDescripcion, cDivisa;	
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;	
		
		FOREACH
			SELECT cve_intl AS clave, descripcion AS descripcion, divisa AS divisa 
			INTO cClave, cDescripcion, cDivisa
			FROM bdinteg:"informix".si_divisas
			ORDER BY descripcion

			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, UPPER(cClave), UPPER(cDescripcion), cDivisa WITH RESUME;
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cClave, cDescripcion, cDivisa;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 20/02/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO DE TIPOS DE CAMBIO OFICIALES', 
'DESCRIPCION: SPL que se encarga de consultar el detalle del catï¿½logo divisa.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogomercado(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(1) AS clave,
			CHAR(40) AS descripcion;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cClave CHAR(1);
	DEFINE cDescripcion CHAR(40);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cClave = '';
	LET cDescripcion = '';
	LET iNoRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cClave, cDescripcion;	
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogomercado.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cClave, cDescripcion;	
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cClave, cDescripcion;	
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;	
		
		FOREACH
			SELECT clase_tpcambio AS clave, desc_clase_tc AS descripcion 
			INTO cClave, cDescripcion
			FROM bdinteg:"informix".si_clase_tc 
			ORDER BY desc_clase_tc

			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, UPPER(cClave), UPPER(cDescripcion) WITH RESUME;
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cClave, cDescripcion;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 20/02/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO DE TIPOS DE CAMBIO OFICIALES', 
'DESCRIPCION: SPL que se encarga de consultar el detalle del catï¿½logo mercado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultatabulartiposcambio(pUsuario CHAR(8), pIdFuncion CHAR(10), pClaveTpCambio CHAR(3), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  INTEGER AS irowid,
				  CHAR(2) AS cdivisa,
				  CHAR(3) AS cveIntl,
				  CHAR(1) AS cclase_tpcambio,
				  DATE AS dfecha_tpcambio,
				  DECIMAL(14,6) AS dprecio_compra,
				  DECIMAL(14,6) AS dprecio_venta,
				  DECIMAL(14,6) AS dtipo_cpa_div_dll,
				  DECIMAL(14,6) AS dtipo_cpa_mn_div,
				  DECIMAL(14,6) AS dtipo_vta_div_dll,
				  DECIMAL(14,6) AS dtipo_vta_mn_div;				  
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRowid INTEGER;
    DEFINE cDivisa CHAR(2);
	DEFINE cCveIntl CHAR(3);
    DEFINE dFecha_tpcambio DATE;
    DEFINE cClase_tpcambio CHAR(1);
    DEFINE dPrecio_compra DECIMAL(14,6);
    DEFINE dPrecio_venta DECIMAL(14,6);
    DEFINE dTipo_cpa_div_dll DECIMAL(14,6);
    DEFINE dTipo_cpa_mn_div DECIMAL(14,6);
    DEFINE dTipo_vta_div_dll DECIMAL(14,6);
    DEFINE dTipo_vta_mn_div DECIMAL(14,6);
 	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET iRowid = 0;
	LET cDivisa = '';
	LET cCveIntl = '';
	LET dFecha_tpcambio = NULL;
	LET cClase_tpcambio = '';
	LET dPrecio_compra = 0.000000;
	LET dPrecio_venta = 0.000000;
	LET dTipo_cpa_div_dll = 0.000000;
	LET dTipo_cpa_mn_div = 0.000000;
	LET dTipo_vta_div_dll = 0.000000;
	LET dTipo_vta_mn_div = 0.000000;
	LET iRecuperacion = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iRowid,cDivisa,cCveIntl,cClase_tpcambio,dFecha_tpcambio,dPrecio_compra,dPrecio_venta,dTipo_cpa_div_dll, 
				   dTipo_cpa_mn_div,dTipo_vta_div_dll,dTipo_vta_mn_div;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultatabulartiposcambio.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iRowid,cDivisa,cCveIntl,cClase_tpcambio,dFecha_tpcambio,dPrecio_compra,dPrecio_venta,dTipo_cpa_div_dll, 
				   dTipo_cpa_mn_div,dTipo_vta_div_dll,dTipo_vta_mn_div;
		END IF;
			
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iRowid,cDivisa,cCveIntl,cClase_tpcambio,dFecha_tpcambio,dPrecio_compra,dPrecio_venta,dTipo_cpa_div_dll, 
				   dTipo_cpa_mn_div,dTipo_vta_div_dll,dTipo_vta_mn_div;
		END IF;
				
		SET ISOLATION TO DIRTY READ;	
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
		
			SELECT SKIP pRegistros FIRST pRecuperacion	a.ROWID, a.divisa, b.cve_intl, a.clase_tpcambio, a.fecha_tpcambio, a.precio_compra,
			precio_venta, tipo_cpa_div_dll, tipo_cpa_mn_div, tipo_vta_div_dll , tipo_vta_mn_div
			INTO iRowid,cDivisa,cCveIntl,cClase_tpcambio,dFecha_tpcambio,dPrecio_compra, dPrecio_venta,dTipo_cpa_div_dll, dTipo_cpa_mn_div, 
				 dTipo_vta_div_dll,dTipo_vta_mn_div 
			FROM bdinteg:"informix".si_tpcambio a, bdinteg:"informix".si_divisas b, bdinteg:"informix".si_clase_tc c
			WHERE a.divisa = b.divisa
			AND a.clase_tpcambio = c.clase_tpcambio
			AND a.empresa = cEmpresa
			AND a.empresa = b.empresa
			AND a.clase_tpcambio = (CASE WHEN UPPER(pClaveTpCambio) = '' THEN a.clase_tpcambio ELSE UPPER(pClaveTpCambio) END)
			ORDER BY a.clase_tpcambio
			
			LET iRecuperacion = iRecuperacion + 1;
			
			RETURN cCodRet,iRowid,cDivisa,cCveIntl,cClase_tpcambio,dFecha_tpcambio,dPrecio_compra,dPrecio_venta,dTipo_cpa_div_dll, 
				   dTipo_cpa_mn_div,dTipo_vta_div_dll,dTipo_vta_mn_div WITH RESUME;
			
		END FOREACH;
		
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet,iRowid,cDivisa,cCveIntl,cClase_tpcambio,dFecha_tpcambio,dPrecio_compra,dPrecio_venta,dTipo_cpa_div_dll, 
				       dTipo_cpa_mn_div,dTipo_vta_div_dll,dTipo_vta_mn_div;
				   
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet,iRowid,cDivisa,cCveIntl,cClase_tpcambio,dFecha_tpcambio,dPrecio_compra,dPrecio_venta,dTipo_cpa_div_dll, 
				       dTipo_cpa_mn_div,dTipo_vta_div_dll,dTipo_vta_mn_div;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 22/02/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO DE TIPOS DE CAMBIO OFICIALES', 
'DESCRIPCION: SPL encargado de realizar la consulta para tabular de tipos de cambio',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultatabulartiposcambio_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pClaveTpCambio CHAR(3))
		RETURNING CHAR(5) AS codret,
				  INTEGER AS totalRegistros;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTotalRegistros INTEGER;
	DEFINE cEmpresa CHAR(3);
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET iTotalRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iTotalRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultatabulartiposcambio_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iTotalRegistros;
		END IF;
			
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iTotalRegistros;
		END IF;
				
		SET ISOLATION TO DIRTY READ;	
		SET LOCK MODE TO WAIT 3;
		
		SELECT COUNT (*)
		INTO iTotalRegistros
		FROM bdinteg:"informix".si_tpcambio a, bdinteg:"informix".si_divisas b, bdinteg:"informix".si_clase_tc c
		WHERE a.divisa = b.divisa
		AND a.clase_tpcambio = c.clase_tpcambio
		AND a.empresa = cEmpresa
		AND a.empresa = b.empresa
		AND a.clase_tpcambio = (CASE WHEN pClaveTpCambio = '' THEN a.clase_tpcambio ELSE pClaveTpCambio END);
			
		IF iTotalRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;	
			
		RETURN cCodRet, iTotalRegistros;

	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 22/02/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO DE TIPOS DE CAMBIO OFICIALES', 
'DESCRIPCION: SPL encargado de realizar la consulta de totales para tabular de tipos de cambio',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultatiposcambio(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1), pRowId INTEGER, pCveMercado CHAR(1), pDivisa CHAR(2),
 pFechaTpC DATE, pPrecioCpa DECIMAL(14,6), pPrecioVta DECIMAL(14,6), pPrecioVtaA DECIMAL(14,6), pTipoCpaMnDiv DECIMAL(14,6), pTipoVtaMnDiv DECIMAL(14,6),
 pVariacionVta DECIMAL(9,7), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  INTEGER AS irowid,
				  CHAR(3) AS cempresa,
				  CHAR(2) AS cdivisa,
				  DECIMAL(9,7) AS dvariacion_cpa,
				  DECIMAL(14,6) AS dtipo_cpa_mn_dll,
				  DECIMAL(14,6) AS dtipo_cpa_div_dll,
				  DECIMAL(14,6) AS dtipo_cpa_mn_div,
				  DECIMAL(14,6) AS dpc_abajo,
				  DECIMAL(14,6) AS dpc_arriba,
				  DECIMAL(14,6) AS dprecio_compra,
				  DECIMAL(14,6) AS dpv_abajo,
				  DECIMAL(9,7) AS dvariacion_vta,
				  DECIMAL(14,6) AS dtipo_vta_div_dll,
				  DECIMAL(14,6) AS dtipo_vta_mn_dll,
				  DECIMAL(14,6) AS dtipo_vta_mn_div,
				  DECIMAL(14,6) AS dprecio_venta,
				  DECIMAL(14,6) AS dpv_arriba,
				  DATE AS dFecha_tpcambio,
				  CHAR(1) AS cClase_tpcambio;

				  
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRowid INTEGER;
    DEFINE cDivisa char(2);
    DEFINE dFecha_tpcambio date;
    DEFINE cClase_tpcambio char(1);
    DEFINE dPrecio_compra decimal(14,6);
    DEFINE dPc_arriba decimal(14,6);
    DEFINE dPc_abajo decimal(14,6);
    DEFINE dPrecio_venta decimal(14,6);
    DEFINE dPv_abajo decimal(14,6);
    DEFINE dPv_arriba decimal(14,6);
    DEFINE dVariacion_cpa decimal(9,7);
    DEFINE dVariacion_vta decimal(9,7);
    DEFINE dTipo_cpa_div_dll decimal(14,6);
    DEFINE dTipo_cpa_mn_dll decimal(14,6);
    DEFINE dTipo_cpa_mn_div decimal(14,6);
    DEFINE dTipo_vta_div_dll decimal(14,6);
    DEFINE dTipo_vta_mn_dll decimal(14,6);
    DEFINE dTipo_vta_mn_div decimal(14,6);
 	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET iRowid = 0;
	LET cDivisa = '';
	LET dFecha_tpcambio = NULL;
	LET cClase_tpcambio = '';
	LET dPrecio_compra = 0.000000;
	LET dPc_arriba = 0.000000;
	LET dPc_abajo = 0.000000;
	LET dPrecio_venta = 0.000000;
	LET dPv_abajo = 0.000000;
	LET dPv_arriba = 0.000000;
	LET dVariacion_cpa = 0.0000000;
	LET dVariacion_vta = 0.0000000;
	LET dTipo_cpa_div_dll = 0.000000;
	LET dTipo_cpa_mn_dll = 0.000000;
	LET dTipo_cpa_mn_div = 0.000000;
	LET dTipo_vta_div_dll = 0.000000;
	LET dTipo_vta_mn_dll = 0.000000;
	LET dTipo_vta_mn_div = 0.000000;
	LET iRecuperacion = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iRowid,cEmpresa,cDivisa,dVariacion_cpa,dTipo_cpa_mn_dll,dTipo_cpa_div_dll,dTipo_cpa_mn_div,dPc_abajo,dPc_arriba,dPrecio_compra,
			dPv_abajo,dVariacion_vta,dTipo_vta_div_dll,dTipo_vta_mn_dll,dTipo_vta_mn_div,dPrecio_venta,dPv_arriba,dFecha_tpcambio,cClase_tpcambio;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultatiposcambio.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iRowid,cEmpresa,cDivisa,dVariacion_cpa,dTipo_cpa_mn_dll,dTipo_cpa_div_dll,dTipo_cpa_mn_div,dPc_abajo,dPc_arriba,dPrecio_compra,
			dPv_abajo,dVariacion_vta,dTipo_vta_div_dll,dTipo_vta_mn_dll,dTipo_vta_mn_div,dPrecio_venta,dPv_arriba,dFecha_tpcambio,cClase_tpcambio;
		END IF;
		
		IF  pIdConsulta = '1' THEN
		
			IF pRegistros IS NULL OR pRecuperacion IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet,iRowid,cEmpresa,cDivisa,dVariacion_cpa,dTipo_cpa_mn_dll,dTipo_cpa_div_dll,dTipo_cpa_mn_div,dPc_abajo,dPc_arriba,dPrecio_compra,
				dPv_abajo,dVariacion_vta,dTipo_vta_div_dll,dTipo_vta_mn_dll,dTipo_vta_mn_div,dPrecio_venta,dPv_arriba,dFecha_tpcambio,cClase_tpcambio;
			END IF;
			
		ELIF pIdConsulta = '2' THEN
		
			IF pRowId IS NULL OR  pCveMercado = '' OR pDivisa = '' OR pFechaTpC IS NULL OR pPrecioCpa IS NULL OR pPrecioVta IS NULL OR pPrecioVtaA IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet,iRowid,cEmpresa,cDivisa,dVariacion_cpa,dTipo_cpa_mn_dll,dTipo_cpa_div_dll,dTipo_cpa_mn_div,dPc_abajo,dPc_arriba,dPrecio_compra,
				dPv_abajo,dVariacion_vta,dTipo_vta_div_dll,dTipo_vta_mn_dll,dTipo_vta_mn_div,dPrecio_venta,dPv_arriba,dFecha_tpcambio,cClase_tpcambio;
			END IF;	
		
		ELIF pIdConsulta = '3' THEN
		
			IF pRowId IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet,iRowid,cEmpresa,cDivisa,dVariacion_cpa,dTipo_cpa_mn_dll,dTipo_cpa_div_dll,dTipo_cpa_mn_div,dPc_abajo,dPc_arriba,dPrecio_compra,
				dPv_abajo,dVariacion_vta,dTipo_vta_div_dll,dTipo_vta_mn_dll,dTipo_vta_mn_div,dPrecio_venta,dPv_arriba,dFecha_tpcambio,cClase_tpcambio;
			END IF;	
			
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iRowid,cEmpresa,cDivisa,dVariacion_cpa,dTipo_cpa_mn_dll,dTipo_cpa_div_dll,dTipo_cpa_mn_div,dPc_abajo,dPc_arriba,dPrecio_compra,
			dPv_abajo,dVariacion_vta,dTipo_vta_div_dll,dTipo_vta_mn_dll,dTipo_vta_mn_div,dPrecio_venta,dPv_arriba,dFecha_tpcambio,cClase_tpcambio;	
		END IF;
		
		-- Consulta
		IF pIdConsulta = '1' THEN
		
			SET ISOLATION TO DIRTY READ;	
			SET LOCK MODE TO WAIT 3;
			
			FOREACH
			
				SELECT SKIP pRegistros FIRST pRecuperacion ROWID,empresa,divisa,variacion_cpa,tipo_cpa_mn_dll,tipo_cpa_div_dll,tipo_cpa_mn_div,pc_abajo,pc_arriba,precio_compra,
				pv_abajo,variacion_vta,tipo_vta_div_dll,tipo_vta_mn_dll,tipo_vta_mn_div,precio_venta,pv_arriba,fecha_tpcambio,clase_tpcambio  
				INTO iRowid,cEmpresa,cDivisa,dVariacion_cpa,dTipo_cpa_mn_dll,dTipo_cpa_div_dll,dTipo_cpa_mn_div,dPc_abajo,dPc_arriba,dPrecio_compra,
				dPv_abajo,dVariacion_vta,dTipo_vta_div_dll,dTipo_vta_mn_dll,dTipo_vta_mn_div,dPrecio_venta,dPv_arriba,dFecha_tpcambio,cClase_tpcambio 
				FROM bdinteg:"informix".si_tpcambio WHERE empresa = '001' 
				AND divisa = (CASE WHEN TRIM(pDivisa) = '' THEN divisa ELSE pDivisa END)
				AND precio_compra = (CASE WHEN pPrecioCpa = 0 THEN precio_compra ELSE pPrecioCpa END) 
				AND precio_venta = (CASE WHEN pPrecioVta = 0 THEN precio_venta ELSE pPrecioVta END) 
				--AND pv_arriba = (CASE WHEN pPrecioVtaA = 0 THEN pv_arriba ELSE pPrecioVtaA END)  
				AND fecha_tpcambio = (CASE WHEN pFechaTpC IS NULL THEN fecha_tpcambio ELSE pFechaTpC END)  
				AND clase_tpcambio = (CASE WHEN TRIM(pCveMercado) = '' THEN clase_tpcambio ELSE pCveMercado END) 
				ORDER BY clase_tpcambio, divisa
				
				LET iRecuperacion = iRecuperacion + 1;
				
				RETURN cCodRet,iRowid,cEmpresa,cDivisa,dVariacion_cpa,dTipo_cpa_mn_dll,dTipo_cpa_div_dll,dTipo_cpa_mn_div,dPc_abajo,dPc_arriba,dPrecio_compra,
				dPv_abajo,dVariacion_vta,dTipo_vta_div_dll,dTipo_vta_mn_dll,dTipo_vta_mn_div,dPrecio_venta,dPv_arriba,dFecha_tpcambio,cClase_tpcambio WITH RESUME;
				
			END FOREACH;
			
			
			IF iRecuperacion = 0 AND pRegistros = 0 THEN
					LET cCodRet = '00017';
					RETURN cCodRet,iRowid,cEmpresa,cDivisa,dVariacion_cpa,dTipo_cpa_mn_dll,dTipo_cpa_div_dll,dTipo_cpa_mn_div,dPc_abajo,dPc_arriba,dPrecio_compra,
					dPv_abajo,dVariacion_vta,dTipo_vta_div_dll,dTipo_vta_mn_dll,dTipo_vta_mn_div,dPrecio_venta,dPv_arriba,dFecha_tpcambio,cClase_tpcambio;
				
			ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
					LET cCodRet = '1001';
					RETURN cCodRet,iRowid,cEmpresa,cDivisa,dVariacion_cpa,dTipo_cpa_mn_dll,dTipo_cpa_div_dll,dTipo_cpa_mn_div,dPc_abajo,dPc_arriba,dPrecio_compra,
					dPv_abajo,dVariacion_vta,dTipo_vta_div_dll,dTipo_vta_mn_dll,dTipo_vta_mn_div,dPrecio_venta,dPv_arriba,dFecha_tpcambio,cClase_tpcambio;				
			END IF;		
		END IF;
		
		--Modificacion
		IF pIdConsulta = '2' THEN
			
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			UPDATE bdinteg:"informix".si_tpcambio 
			SET empresa = '001', divisa = pDivisa, precio_compra = pPrecioCpa,
			precio_venta = pPrecioVta,pv_arriba = pPrecioVtaA, fecha_tpcambio = pFechaTpC,
			clase_tpcambio = pCveMercado, variacion_vta = pVariacionVta
			WHERE ROWID = pRowId;
			
			IF pDivisa = '04' THEN
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
				UPDATE bdinteg:"informix".si_tpcambio
				SET tipo_cpa_mn_dll = pTipoCpaMnDiv,
				tipo_cpa_div_dll = pTipoCpaMnDiv,
				tipo_vta_mn_dll = pTipoVtaMnDiv,
				tipo_vta_div_dll = pTipoVtaMnDiv
				WHERE divisa = '01'	AND clase_tpcambio = pCveMercado AND empresa = cempresa;
			END IF;
			
			RETURN cCodRet,iRowid,cEmpresa,cDivisa,dVariacion_cpa,dTipo_cpa_mn_dll,dTipo_cpa_div_dll,dTipo_cpa_mn_div,dPc_abajo,dPc_arriba,dPrecio_compra,
			dPv_abajo,dVariacion_vta,dTipo_vta_div_dll,dTipo_vta_mn_dll,dTipo_vta_mn_div,dPrecio_venta,dPv_arriba,dFecha_tpcambio,cClase_tpcambio;
				
		END IF;
		
		--Eliminacion
		IF pIdConsulta = '3' THEN
			
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			DELETE FROM bdinteg:"informix".si_tpcambio WHERE ROWID = pRowId;
			
			RETURN cCodRet,iRowid,cEmpresa,cDivisa,dVariacion_cpa,dTipo_cpa_mn_dll,dTipo_cpa_div_dll,dTipo_cpa_mn_div,dPc_abajo,dPc_arriba,dPrecio_compra,
			dPv_abajo,dVariacion_vta,dTipo_vta_div_dll,dTipo_vta_mn_dll,dTipo_vta_mn_div,dPrecio_venta,dPv_arriba,dFecha_tpcambio,cClase_tpcambio;
				
		END IF;

	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 22/02/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO DE TIPOS DE CAMBIO OFICIALES', 
'DESCRIPCION: SPL encargado de realizar consulta = 1 , modificacion = 2 y eliminacion = 3 para tipos de cambio',
'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 18/10/2017',
'DESCRIPCION: Se modifica spl para contemplar la actualizaciï¿½n del campo Variaciï¿½n en Puntos (venta).',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_insertatipocambio(pUsuario CHAR(8), pIdFuncion CHAR(10), pDivisa CHAR(2),pVariacion_cpa DECIMAL(9,7),
        pTipo_cpa_mn_dll DECIMAL(14,6),pTipo_cpa_div_dll DECIMAL(14,6),pTipo_cpa_mn_div DECIMAL(14,6),pPc_abajo DECIMAL(14,6),
		pPc_arriba DECIMAL(14,6),pPrecio_compra DECIMAL(14,6),pPv_abajo DECIMAL(14,6),pVariacion_vta DECIMAL(9,7),pTipo_vta_div_dll DECIMAL(14,6),
		pTipo_vta_mn_dll DECIMAL(14,6),pTipo_vta_mn_div DECIMAL(14,6),pPrecio_venta DECIMAL(14,6),pPv_arriba DECIMAL(14,6),pFecha_tpcambio DATE,
		pClase_tpcambio CHAR(1))
		
		RETURNING CHAR(5) AS codret;
				  		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
 	DEFINE iRecuperacion INTEGER; 
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_insertatipocambio.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pVariacion_cpa IS NULL OR pTipo_cpa_mn_dll IS NULL OR pTipo_cpa_div_dll IS NULL OR pTipo_cpa_mn_div IS NULL OR pPc_abajo IS NULL OR 
		   pPc_arriba IS NULL OR pPrecio_compra IS NULL OR pPv_abajo IS NULL OR pVariacion_vta IS NULL OR pTipo_vta_div_dll IS NULL OR 
		   pTipo_vta_mn_dll IS NULL OR pTipo_vta_mn_div IS NULL OR pPrecio_venta IS NULL OR pPv_arriba IS NULL OR pFecha_tpcambio IS NULL OR 
		   pClase_tpcambio IS NULL THEN
		   
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		SELECT COUNT(*) INTO iRecuperacion
		FROM bdinteg:"informix".si_tpcambio 
		WHERE divisa = pDivisa
		AND clase_tpcambio = pClase_tpcambio
		AND empresa = cEmpresa 
		AND fecha_tpcambio = pFecha_tpcambio;
			
		IF iRecuperacion > 0 THEN	
		
			LET cCodRet = '00923'; -- El tipo de cambio para Ã©sta divisa y mercado ya estÃ¡ registrado
			RETURN cCodRet;
			
		ELSE
		
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			INSERT INTO bdinteg:"informix".si_tpcambio(empresa,divisa,variacion_cpa,tipo_cpa_mn_dll,tipo_cpa_div_dll,
													   tipo_cpa_mn_div,pc_abajo,pc_arriba,precio_compra,pv_abajo,variacion_vta,
													   tipo_vta_div_dll,tipo_vta_mn_dll,tipo_vta_mn_div,precio_venta,pv_arriba,
													   fecha_tpcambio,clase_tpcambio,hora_tpcambio)
			VALUES(cEmpresa,pDivisa,pVariacion_cpa ,pTipo_cpa_mn_dll ,pTipo_cpa_div_dll ,pTipo_cpa_mn_div ,pPc_abajo ,
				   pPc_arriba ,pPrecio_compra ,pPv_abajo ,pVariacion_vta ,pTipo_vta_div_dll ,
				   pTipo_vta_mn_dll ,pTipo_vta_mn_div ,pPrecio_venta ,pPv_arriba ,pFecha_tpcambio,
				   pClase_tpcambio,CAST(CURRENT AS DATETIME HOUR TO MINUTE));
			
			IF pDivisa = '04' THEN
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
				UPDATE bdinteg:"informix".si_tpcambio
				SET tipo_cpa_mn_dll = pTipo_cpa_mn_dll,
				tipo_cpa_div_dll = pTipo_cpa_div_dll,
				tipo_vta_mn_dll = pTipo_vta_mn_dll,
				tipo_vta_div_dll = pTipo_vta_div_dll
				WHERE divisa = '01'	AND clase_tpcambio = pCveMercado AND empresa = cempresa;
			END IF;
			
			RETURN cCodRet;
			
		END IF;

	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 22/02/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO DE TIPOS DE CAMBIO OFICIALES', 
'DESCRIPCION: SPL encargado de realizar la insercion de un nuevo tipos de cambio',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_operaciones_encabezadotipocambio(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				CHAR(30) AS departamento,
				CHAR(45) AS nombre,
				CHAR(50) AS sistema,
				CHAR(30) AS empresa;
		
		
	DEFINE cCodRet 	CHAR(5);
	DEFINE iSqlErr 	INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cDepto 	CHAR(30);
	DEFINE cNombre 	CHAR(45);
	DEFINE cSistema CHAR(50);
	DEFINE cEmpres 	CHAR(30);
	
	LET cCodRet 	= '00000';
	LET iSqlErr 	= 0;	
	LET cEmpresa 	= '001';
	LET cDepto 		= '';
	LET cNombre 	= '';
	LET cSistema 	= '';
	LET cEmpres 	= '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cDepto, cNombre, cSistema, cEmpres;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_operaciones_encabezadotipocambio.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cDepto, cNombre, cSistema, cEmpres;
		END IF;
		
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cDepto, cNombre, cSistema, cEmpres;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT EJE.nombre, DEP.descripcion 
		INTO cNombre, cDepto
		FROM bdinteg:"informix".si_ejecut EJE
		LEFT JOIN  bdinteg:"informix".si_departamentos DEP ON DEP.departamento = EJE.departamento
		WHERE ejecutivo = pUsuario;
		
		SELECT razon_social
		INTO cEmpres
		FROM bdinteg:"informix".si_empresas
		WHERE empresa = cEmpresa;
		
		SELECT valor 
		INTO cSistema
		FROM bdinteg:"informix".si_vbparam 
		WHERE desc_campo="xdesc_sistema";
		
		RETURN cCodRet, NVL(cDepto,''), NVL(cNombre,''), NVL(cSistema,''), NVL(cEmpres,'');
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 27/02/2017',
'MODULO: Operaciones',
'FUNCIONALIDAD: Catalogo Tipos de Cambio',
'DESCRIPCION: Obtiene los parametros para el encabezado del Catalogo de Tipos de Cambio',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_operacionestipocambio_actualiza_mercado(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdOperacion CHAR(1))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cProceso CHAR(15);
	DEFINE cDivisa CHAR(2);
	DEFINE cClase_TpCambio CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cProceso = 'act_fecha_tc';
	LET cDivisa = '';
	LET cClase_TpCambio = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_operacionestipocambio_actualiza_mercado.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdOperacion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;	
		END IF;
		
		-- ACTUALIZACION FECHAS
		IF pIdOperacion = '1' THEN
			
			SET ISOLATION TO DIRTY READ;	
			SET LOCK MODE TO WAIT 3;
			
			FOREACH
			
				SELECT divisa
				INTO cDivisa
				FROM bdinteg:"informix".si_tpcambio
				WHERE empresa = cEmpresa
				GROUP BY 1
				HAVING COUNT(*) > 1
				
				IF NVL(cDivisa,'') <> '' THEN
					DELETE FROM bdinteg:"informix".si_tpcambio
					WHERE divisa = cDivisa AND fecha_tpcambio < DATE(CURRENT) 
					AND fecha_tpcambio <> (SELECT MAX(fecha_tpcambio) 
										   FROM bdinteg:"informix".si_tpcambio
										   WHERE divisa = cDivisa)
					AND clase_tpcambio IN (SELECT clase_tpcambio 
										   FROM bdinteg:"informix".si_tpcambio
										   WHERE divisa = cDivisa
										   AND fecha_tpcambio >= DATE(CURRENT));
					
					IF DBINFO('sqlca.sqlerrd2') <> 0 THEN
						DELETE FROM bdinteg:"informix".si_tpcambio
						WHERE divisa = cDivisa AND fecha_tpcambio < DATE(CURRENT) 
						AND hora_tpcambio <> (SELECT MAX(hora_tpcambio) 
											  FROM bdinteg:"informix".si_tpcambio
											  WHERE divisa = cDivisa
											  AND fecha_tpcambio < DATE(CURRENT)
						AND clase_tpcambio IN (SELECT clase_tpcambio 
											   FROM bdinteg:"informix".si_tpcambio
											   WHERE divisa = cDivisa));	
					END IF;
				END IF;
				
			END FOREACH;
			
			UPDATE bdinteg:"informix".si_tpcambio
			SET fecha_tpcambio = DATE(CURRENT)
			WHERE empresa = cEmpresa
			AND fecha_tpcambio < DATE(CURRENT);
			
			--Registra proceso
			IF DBINFO('sqlca.sqlerrd2') >= 1 THEN  
				SET ISOLATION TO DIRTY READ;	
				SET LOCK MODE TO WAIT 3;
				INSERT INTO bdinteg:"informix".si_contproc(empresa,proceso,fecha) VALUES (cEmpresa,cProceso,CURRENT);
			END IF;
			
			RETURN cCodRet;	
			
		END IF;
		
		-- MERCADO VOLÃTIL (GRABA HISTÃRICO)
		IF pIdOperacion = '2' THEN
		
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			
			IF EXISTS(SELECT fecha_tpcambio FROM bdinteg:"informix".si_histtcdiario WHERE fecha_tpcambio = DATE(CURRENT)) THEN
			
				LET cCodRet = '00930'; --EL PROCESO YA FUE REALIZADO
				RETURN cCodRet;
			
			ELSE
		
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
				
				INSERT INTO bdinteg:"informix".si_histtcdiario
				SELECT EMPRESA,DIVISA,FECHA_TPCAMBIO,CLASE_TPCAMBIO,PRECIO_COMPRA,PC_ARRIBA,
				PC_ABAJO,PRECIO_VENTA,PV_ABAJO,PV_ARRIBA,VARIACION_CPA,VARIACION_VTA,TIPO_CPA_DIV_DLL,
				TIPO_CPA_MN_DLL,TIPO_CPA_MN_DIV,TIPO_VTA_DIV_DLL,TIPO_VTA_MN_DLL,TIPO_VTA_MN_DIV,HORA_TPCAMBIO,
				PRECIO_BASE,VAR_CPA_BASE,VAR_VTA_BASE,REF_CLASE_TC, pUsuario AS usr, CURRENT AS tt
				FROM bdinteg:"informix".si_tpcambio
				WHERE empresa = cEmpresa;	
			
				RETURN cCodRet;
				
			END IF;
			
		END IF;
	
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 22/02/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO DE TIPOS DE CAMBIO OFICIALES', 
'DESCRIPCION: SPL encargado de realizar operaciones pIdOperacion = 1 (Actualiza fechas) y pIdOperacion = 2 (Mercado volatil)  para tipos de cambio',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 10/07/2017',
'DESCRIPCION: Se modifica spl para eliminar el CURRENT que llenaba el campo hora_tc de la tabla si_histtcdiario por HORA_TPCAMBIO recuperado de la si_tpcambio.',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 13/10/2017',
'DESCRIPCION: Se modifica spl para aplicar nuevas reglas de negocio al flujo del proceso de Actualizacion de Fechas.',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 26/10/2017',
'DESCRIPCION: Se modifica spl para considerar nuevos casos con respecto a las reglas de negocio del proceso de Actualizacion de Fechas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_reportetipocambio(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(2) AS cdivisa,
				  CHAR(1) AS cclase_tpcambio,
				  DECIMAL(14,6) AS dprecio_compra,
				  DECIMAL(14,6) AS dpc_arriba,
				  DECIMAL(14,6) AS dpc_abajo,
				  DECIMAL(14,6) AS dprecio_venta,
				  DECIMAL(14,6) AS dpv_abajo,
				  DECIMAL(14,6) AS dpv_arriba,
				  DECIMAL(14,6) AS dtipo_cpa_div_dll,
				  DECIMAL(14,6) AS dtipo_cpa_mn_dll,
				  DECIMAL(14,6) AS dtipo_cpa_mn_div,
				  DECIMAL(14,6) AS dtipo_vta_div_dll,
				  DECIMAL(14,6) AS dtipo_vta_mn_dll,
				  DECIMAL(14,6) AS dtipo_vta_mn_div,
				  CHAR(30) AS cdescripcion,
				  CHAR(30) AS cdesc_clase_tc;	  
		
	DEFINE cCodRet           CHAR(5);
	DEFINE iSqlErr 			 INTEGER;
    DEFINE cDivisa           CHAR(2);
	DEFINE cClase_tpcambio 	 CHAR(1);
	DEFINE dPrecio_compra    DECIMAL(14,6);
	DEFINE dPc_arriba        DECIMAL(14,6);
	DEFINE dPc_abajo         DECIMAL(14,6);
	DEFINE dPrecio_venta     DECIMAL(14,6);
	DEFINE dPv_abajo         DECIMAL(14,6);
	DEFINE dPv_arriba        DECIMAL(14,6);
	DEFINE dTipo_cpa_div_dll DECIMAL(14,6);
	DEFINE dTipo_cpa_mn_dll  DECIMAL(14,6);
	DEFINE dTipo_cpa_mn_div  DECIMAL(14,6);
	DEFINE dTipo_vta_div_dll DECIMAL(14,6);
	DEFINE dTipo_vta_mn_dll  DECIMAL(14,6);
	DEFINE dTipo_vta_mn_div  DECIMAL(14,6);
	DEFINE cDescripcion      CHAR(30);
	DEFINE cDesc_clase_tc    CHAR(30);
	DEFINE iRecuperacion INTEGER;
	
	
	LET cCodRet           = '00000';
	LET iSqlErr           = 0;
	LET cDivisa           = '';
	LET cClase_tpcambio   = '';
	LET dPrecio_compra    = 0.000000;
	LET dPc_arriba        = 0.000000;
	LET dPc_abajo         = 0.000000;
	LET dPrecio_venta     = 0.000000;
	LET dPv_abajo         = 0.000000;
	LET dPv_arriba        = 0.000000;
	LET dTipo_cpa_div_dll = 0.000000;
	LET dTipo_cpa_mn_dll  = 0.000000;
	LET dTipo_cpa_mn_div  = 0.000000;
	LET dTipo_vta_div_dll = 0.000000;
	LET dTipo_vta_mn_dll  = 0.000000;
	LET dTipo_vta_mn_div  = 0.000000;
	LET cDescripcion      = '';
	LET cDesc_clase_tc    = '';
	LET iRecuperacion     = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cDivisa,cClase_tpcambio,dPrecio_compra,dPc_arriba,dPc_abajo,dPrecio_venta,dPv_abajo,dPv_arriba,
			dTipo_cpa_div_dll,dTipo_cpa_mn_dll,dTipo_cpa_mn_div,dTipo_vta_div_dll,dTipo_vta_mn_dll,dTipo_vta_mn_div,
			cDescripcion,cDesc_clase_tc;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_reportetipocambio.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cDivisa,cClase_tpcambio,dPrecio_compra,dPc_arriba,dPc_abajo,dPrecio_venta,dPv_abajo,dPv_arriba,
			dTipo_cpa_div_dll,dTipo_cpa_mn_dll,dTipo_cpa_mn_div,dTipo_vta_div_dll,dTipo_vta_mn_dll,dTipo_vta_mn_div,
			cDescripcion,cDesc_clase_tc;
		END IF;
			
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cDivisa,cClase_tpcambio,dPrecio_compra,dPc_arriba,dPc_abajo,dPrecio_venta,dPv_abajo,dPv_arriba,
			dTipo_cpa_div_dll,dTipo_cpa_mn_dll,dTipo_cpa_mn_div,dTipo_vta_div_dll,dTipo_vta_mn_dll,dTipo_vta_mn_div,
			cDescripcion,cDesc_clase_tc;
		END IF;
				
		SET ISOLATION TO DIRTY READ;	
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
		
			SELECT {+INDEX (bdinteg:"informix".si_tpcambio i256_616)} SKIP pRegistros FIRST pRecuperacion si_tpcambio.divisa, si_tpcambio.clase_tpcambio, si_tpcambio.precio_compra, si_tpcambio.pc_arriba,
			   si_tpcambio.pc_abajo,  si_tpcambio.precio_venta, si_tpcambio.pv_abajo, si_tpcambio.pv_arriba, 
			   si_tpcambio.tipo_cpa_div_dll, si_tpcambio.tipo_cpa_mn_dll,  si_tpcambio.tipo_cpa_mn_div, 
			   si_tpcambio.tipo_vta_div_dll, si_tpcambio.tipo_vta_mn_dll, si_tpcambio.tipo_vta_mn_div, 
			   si_divisas.descripcion,si_clase_tc.desc_clase_tc
			INTO cDivisa,cClase_tpcambio,dPrecio_compra,dPc_arriba,dPc_abajo,dPrecio_venta,dPv_abajo,dPv_arriba,
			   dTipo_cpa_div_dll,dTipo_cpa_mn_dll,dTipo_cpa_mn_div,dTipo_vta_div_dll,dTipo_vta_mn_dll,dTipo_vta_mn_div,
			   cDescripcion,cDesc_clase_tc
			FROM (bdinteg:"informix".si_tpcambio si_tpcambio LEFT OUTER JOIN bdinteg:"informix".si_clase_tc si_clase_tc ON si_tpcambio.clase_tpcambio = si_clase_tc.clase_tpcambio)       
			LEFT OUTER JOIN bdinteg:"informix".si_divisas si_divisas ON si_tpcambio.divisa = si_divisas.divisa  
			ORDER BY si_tpcambio.divisa ASC, si_tpcambio.clase_tpcambio ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			
			RETURN cCodRet,cDivisa,cClase_tpcambio,dPrecio_compra,dPc_arriba,dPc_abajo,dPrecio_venta,dPv_abajo,dPv_arriba,
			dTipo_cpa_div_dll,dTipo_cpa_mn_dll,dTipo_cpa_mn_div,dTipo_vta_div_dll,dTipo_vta_mn_dll,dTipo_vta_mn_div,
			cDescripcion,cDesc_clase_tc WITH RESUME;
			
		END FOREACH;
		
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cDivisa,cClase_tpcambio,dPrecio_compra,dPc_arriba,dPc_abajo,dPrecio_venta,dPv_abajo,dPv_arriba,
			dTipo_cpa_div_dll,dTipo_cpa_mn_dll,dTipo_cpa_mn_div,dTipo_vta_div_dll,dTipo_vta_mn_dll,dTipo_vta_mn_div,
			cDescripcion,cDesc_clase_tc;
				   
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			RETURN cCodRet,cDivisa,cClase_tpcambio,dPrecio_compra,dPc_arriba,dPc_abajo,dPrecio_venta,dPv_abajo,dPv_arriba,
			dTipo_cpa_div_dll,dTipo_cpa_mn_dll,dTipo_cpa_mn_div,dTipo_vta_div_dll,dTipo_vta_mn_dll,dTipo_vta_mn_div,
			cDescripcion,cDesc_clase_tc;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 22/02/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO DE TIPOS DE CAMBIO OFICIALES', 
'DESCRIPCION: SPL encargado de realizar la consulta para generar reporte en tipos de cambio',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_respaldohistoricotpcambio(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1), pFecha DATE)
		RETURNING CHAR(5) AS codret;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	
	DEFINE c_empresa CHAR(3);
	DEFINE c_divisa CHAR(3);
	DEFINE dt_fecha_tpcambio DATE;
	DEFINE dt_hora_tpcambio DATETIME HOUR TO MINUTE;
	DEFINE c_clase_tpcambio CHAR(1);
	DEFINE d_precio_compra DECIMAL (14,6);
	DEFINE d_pc_arriba DECIMAL (14,6);
	DEFINE d_pc_abajo DECIMAL (14,6);
	DEFINE d_precio_venta DECIMAL (14,6);
	DEFINE d_pv_abajo DECIMAL (14,6);
	DEFINE d_pv_arriba DECIMAL (14,6);
	DEFINE d_variacion_cpa DECIMAL (9,7);
	DEFINE d_variacion_vta DECIMAL (9,7);
	DEFINE d_tipo_cpa_div_dll DECIMAL (14,6);
	DEFINE d_tipo_cpa_mn_dll DECIMAL (14,6);
	DEFINE d_tipo_cpa_mn_div DECIMAL (14,6);
	DEFINE d_tipo_vta_div_dll DECIMAL (14,6);
	DEFINE d_tipo_vta_mn_dll DECIMAL (14,6);
	DEFINE d_tipo_vta_mn_div DECIMAL (14,6);
	DEFINE d_precio_base DECIMAL (14,6);
	DEFINE d_var_cpa_base DECIMAL (9,7);
	DEFINE d_var_vta_base DECIMAL (9,7);
	DEFINE c_ref_clase_tc CHAR(1);
	DEFINE c_user_insert CHAR(30);
	DEFINE dt_fecha_insert DATE;
	
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	
	LET c_empresa = '';
	LET c_divisa = '';
	LET dt_fecha_tpcambio = '';
	LET dt_hora_tpcambio = '';
	LET c_clase_tpcambio = '';
	LET d_precio_compra = NULL;
	LET d_pc_arriba = NULL;
	LET d_pc_abajo = NULL;
	LET d_precio_venta = NULL;
	LET d_pv_abajo = NULL;
	LET d_pv_arriba = NULL;
	LET d_variacion_cpa = NULL;
	LET d_variacion_vta = NULL;
	LET d_tipo_cpa_div_dll = NULL;
	LET d_tipo_cpa_mn_dll = NULL;
	LET d_tipo_cpa_mn_div = NULL;
	LET d_tipo_vta_div_dll = NULL;
	LET d_tipo_vta_mn_dll = NULL;
	LET d_tipo_vta_mn_div = NULL;
	LET d_precio_base = NULL;
	LET d_var_cpa_base = NULL;
	LET d_var_vta_base = NULL;
	LET c_ref_clase_tc = '';
	LET c_user_insert = '';
	LET dt_fecha_insert = '';
	
	LET iNoRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;	
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_respaldohistoricotpcambio.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' OR pFecha IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;	
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;	
		END IF;
		
		SET ISOLATION TO DIRTY READ;	
		
		--Respaldo al histï¿½rico de tipos de cambio
		IF pIdConsulta = '1' THEN 
		
			IF EXISTS(SELECT 1 FROM bdinteg:"informix".si_contproc WHERE proceso = 'tp_cambio' AND fecha = pFecha AND empresa = cEmpresa) THEN
				LET cCodRet = '00992'; --EL PROCESO DE RESPALDO AL HISTï¿½RICO DE TIPOS DE CAMBIO YA FUE REALIZADO HOY, VERIFIQUE
				RETURN cCodRet;	
			END IF;
			
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			
			FOREACH
			
				SELECT empresa, divisa, fecha_tpcambio, hora_tpcambio, clase_tpcambio
				INTO c_empresa, c_divisa, dt_fecha_tpcambio, dt_hora_tpcambio, c_clase_tpcambio			
				FROM bdinteg:"informix".si_tpcambio WHERE empresa = cEmpresa
				
				IF NOT EXISTS(SELECT 1 FROM bdinteg:"informix".si_histdiv 
							  WHERE clase_tpcambio = c_clase_tpcambio AND divisa = c_divisa AND empresa = c_empresa
							  AND fecha_tc = dt_fecha_tpcambio AND hora_tc = dt_hora_tpcambio) THEN
				
					INSERT INTO bdinteg:"informix".si_histdiv
					SELECT * FROM bdinteg:"informix".si_tpcambio 
					WHERE clase_tpcambio = c_clase_tpcambio AND divisa = c_divisa AND empresa = c_empresa
					AND fecha_tpcambio = dt_fecha_tpcambio AND hora_tpcambio = dt_hora_tpcambio;
					
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						LET cCodRet = '00993'; --OCURRIO UN ERROR AL REALIZAR EL RESPALDO AL HISTï¿½RICO DE DIVISAS
						RETURN cCodRet;					
					END IF;				
					
				END IF;			
			
			END FOREACH;
			
			SET ISOLATION TO DIRTY READ;
			INSERT INTO bdinteg:"informix".si_contproc (empresa,proceso,fecha)
			VALUES (cEmpresa,'tp_cambio',pFecha);
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00282';
			END IF;
			
			RETURN cCodRet;	
			
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 10/07/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO DE TIPOS DE CAMBIO OFICIALES', 
'DESCRIPCION: SPL encargo de realizar el proceso de respaldo al histï¿½rico de tipos de cambio.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validaejecucion(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1), pFecha DATE)
		RETURNING CHAR(5) AS codret,
			CHAR(1) AS ejecuta_proceso;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cEjecutaProceso CHAR(1);
	DEFINE cPuesto CHAR(3);
	DEFINE cSucursal CHAR(4);
	DEFINE cNombre CHAR(40);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cEjecutaProceso = '';
	LET cPuesto = '';
	LET cSucursal = '';
	LET cNombre = '';
	LET iNoRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cEjecutaProceso;	
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_validaejecucion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' OR pFecha IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cEjecutaProceso;	
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cEjecutaProceso;	
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--Valida si el usuario en sesiï¿½n es administrador 
		IF pIdConsulta = '1' THEN 
		
			SELECT puesto, sucursal 
			INTO cPuesto, cSucursal
			FROM bdinteg:"informix".si_ejecut
			WHERE UPPER(ejecutivo) = UPPER(pUsuario) 
			AND puesto = (SELECT valor FROM bdinteg:"informix".si_vbparam WHERE desc_campo = 'cve_admon');
		
			IF DBINFO('sqlca.sqlerrd2') <> 0 THEN
			
				LET cEjecutaProceso = '1';
			
			ELSE 
			
				LET cEjecutaProceso = '0';
				
				SELECT sucursal, nombre 
				INTO cSucursal, cNombre
				FROM bdinteg:"informix".si_sucursales 
				WHERE sucursal = (SELECT {+AVOID_FULL(bdinteg:"informix".si_ejecut)} sucursal FROM bdinteg:"informix".si_ejecut WHERE UPPER(ejecutivo) = UPPER(pUsuario));
				
			END IF;
		
		--Respaldo al histï¿½rico de tipos de cambio
		ELIF pIdConsulta = '2' THEN 
		
			IF EXISTS(SELECT 1 FROM bdinteg:"informix".si_contproc WHERE proceso = 'tp_cambio' AND fecha = pFecha AND empresa = '001') THEN
				LET cEjecutaProceso = '0';
			ELSE
				LET cEjecutaProceso = '1';
			END IF;
		
		--Actualizaciï¿½n automï¿½tica de fechas a los tipos de cambio
		ELIF pIdConsulta = '3' THEN 
		
			IF EXISTS(SELECT 1 FROM bdinteg:"informix".si_contproc WHERE proceso = 'act_fecha_tc' AND fecha = pFecha AND empresa = '001') THEN
				LET cEjecutaProceso = '0';
			ELSE 
				LET cEjecutaProceso = '1';
			END IF;
		
		END IF;
		
		RETURN cCodRet, cEjecutaProceso;	
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 20/02/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: MANTENIMIENTO DE TIPOS DE CAMBIO OFICIALES', 
'DESCRIPCION: SPL encargo de verificar si ya se ejecutaron los proceso de actualizaciï¿½n para habilitar o deshabilitar botones.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_registractualizacelulascclb5(pEmpleado CHAR(8), pNombre CHAR(104), pStatus CHAR(1), 
pFuncion SMALLINT, pCedula SMALLINT,  pTipo SMALLINT, pFuncionAnt SMALLINT, pCedulaAnt SMALLINT, pStatusAnt SMALLINT)
		RETURNING CHAR(5) AS codret;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNoRegistros INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET iNoRegistros = 0;
	LET pNombre = UPPER(TRIM(pNombre));

	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_registractualizacelulasccl.out';
		--TRACE ON;
		
		IF pEmpleado = '' OR pNombre = '' OR pStatus = '' OR pFuncion IS NULL OR  pCedula IS NULL OR  pTipo  IS NULL OR pFuncionAnt IS NULL OR pCedulaAnt IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3; 		
		
		EXECUTE PROCEDURE bdicnweb:'informix'.sp_usuarioscedulasmantto(pEmpleado, pNombre, pStatus, pFuncion, pCedula, pTipo, pFuncionAnt, pCedulaAnt, pStatusAnt)
		INTO cCodRetSp;
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
		RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicnweb:sp_usuarioscedulasmantto ";
		ELIF cCodRetSp::INTEGER = 110  THEN
			LET cCodRet = '00582';
		ELIF cCodRetSp::INTEGER = 200  THEN
			LET cCodRet = '00004';
		END IF;
		LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet;		
		END;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;				
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 05/10/2015',
'MODULO: CONCILIACIONES  ',
'FUNCIONALIDAD: CATALOGO FIRMAS CEDULA CONTABLE',
'DESCRIPCION:SPL para registrar o actualizar los usuarios de la revisiï¿½n de las Cedulas Contables',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ris_actualizainsertaprodtransaccionb5(pBandera CHAR(1),
		pCccmayor CHAR(10), pCccsub CHAR(10), pCccsubsub CHAR(10), pCccsssub CHAR(10), pCccssssub CHAR(10), pCsector CHAR(10), 
		pAccmayor CHAR(10),	pAccsub CHAR(10), pAccsubsub CHAR(10), pAccsssub CHAR(10), pAccssssub CHAR(10), pAsector CHAR(10),
		pSistema CHAR(10), pSecuencia CHAR(10), pTransaccion CHAR(10), pProducto CHAR(10),pUsuario CHAR(8))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iTotales INTEGER;
    DEFINE iMaxCommit INTEGER;
    DEFINE iContBloque INTEGER;
    DEFINE cAux CHAR(10);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET iTotales = 0;
    LET iMaxCommit = 5000;
    LET iContBloque = 0;
    LET cAux='';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/Antonio/sp_ris_actualizainsertaprodtransaccion.out';
		--TRACE ON;
		
		IF pBandera = '' OR pCccmayor = '' OR pCccsub = '' OR pCccsubsub = '' OR pCccsssub = '' OR pCccssssub = '' OR pCsector = '' OR 
		pAccmayor = '' OR pAccsub = '' OR  pAccsubsub = '' OR pAccsssub = '' OR pAccssssub = '' OR  pAsector = '' OR pSistema = '' OR pSecuencia = '' OR pTransaccion = '' OR pProducto  = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pBandera = '1' THEN
          
            FOREACH WITH HOLD
            select c_ccmayor into cAux from bdinteg:"informix".si_prodtran 
            WHERE empresa = cEmpresa
			AND sistema = pSistema
			AND producto = pProducto
			AND transaccion = pTransaccion
			AND secuencia = pSecuencia
            
			UPDATE bdinteg:"informix".si_prodtran SET
			c_ccmayor = pCccmayor,
			c_ccsub = pCccsub,
			c_ccsubsub = pCccsubsub,
			c_ccsssub = pCccsssub,
			c_ccssssub = pCccssssub,
			c_sector = pCsector,
			a_ccmayor = pAccmayor,
			a_ccsub = pAccsub,
			a_ccsubsub = pAccsubsub,
			a_ccsssub = pAccsssub,
			a_ccssssub = pAccssssub,
			a_sector = pAsector
			WHERE empresa = cEmpresa
			AND sistema = pSistema
			AND producto = pProducto
			AND transaccion = pTransaccion
			AND secuencia = pSecuencia;

            
            LET iContBloque = iContBloque + 1;
				IF iContBloque = iMaxCommit THEN
					LET iContBloque = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
          END FOREACH;
		
		ELIF pBandera = '2' THEN

              FOREACH WITH HOLD
            select c_ccmayor into cAux from bdinteg:"informix".si_prodtran 
            WHERE empresa = cEmpresa
			AND sistema = pSistema
			AND producto = pProducto
			AND transaccion = pTransaccion
			AND secuencia = pSecuencia
		
			DELETE FROM bdinteg:"informix".si_prodtran 
			WHERE empresa = cEmpresa
			AND sistema = pSistema
			AND producto = pProducto
			AND transaccion = pTransaccion
			AND secuencia = pSecuencia;

             LET iContBloque = iContBloque + 1;
				IF iContBloque = iMaxCommit THEN
					LET iContBloque = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
          END FOREACH;
			
		ELIF pBandera = '3' THEN

            
		
		INSERT INTO bdinteg:"informix".si_prodtran (empresa,  producto,  sistema,  transaccion,  secuencia,  c_ccmayor,  c_ccsub, c_ccsubsub,  c_ccsssub,  c_ccssssub,  c_sector, 
			a_ccmayor,  a_ccsub,  a_ccsubsub, a_ccsssub,  a_ccssssub,  a_sector, user_insert, fecha_insert)
		VALUES (cEmpresa, pProducto, pSistema, pTransaccion, pSecuencia, pCccmayor, pCccsub, pCccsubsub, pCccsssub, pCccssssub, pCsector,  
		pAccmayor,	pAccsub, pAccsubsub, pAccsssub, pAccssssub, pAsector, pUsuario, CURRENT);

         
		
		ELSE 
		
			SELECT COUNT(*) 
			INTO iTotales
			FROM bdinteg:"informix".si_prodtran
            WHERE empresa = cEmpresa
			AND sistema = pSistema
			AND producto = pProducto
			AND transaccion = pTransaccion
			AND secuencia = pSecuencia;
			
			IF iTotales > 0 THEN
		
				LET cCodRet = '99999';
		
			END IF
		END IF;
		
		RETURN cCodRet;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 21/12/2020',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: Mantenimiento a Transacciones por Producto',
'DESCRIPCION: SPL encargado de Insertar, Actualizar y eliminar una transacciÃ³n',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ris_consultacatalogo(pUsuario CHAR(8), pIdFuncion CHAR(10), pCcmayor CHAR(10), pCcsub CHAR(10), pCcsubsub CHAR(10), pCcssubsub CHAR(10), pCcsssubsub CHAR(10), pSector CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(10) AS cCccmayor,
			CHAR(10) AS cCccsub,
			CHAR(10) AS cCccsubsub,
			CHAR(10) AS cCccsssub,
			CHAR(10) AS cCccssssub,
			CHAR(10) AS cCsector,
			CHAR(50) AS nombre;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cCccmayor CHAR(10);
	DEFINE cCccsub CHAR(10);
	DEFINE cCccsubsub CHAR(10);
	DEFINE cCccsssub CHAR(10);
	DEFINE cCccssssub CHAR(10);
	DEFINE cCsector CHAR(10);
	DEFINE cNombre CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNombre = '';
	LET cEmpresa = '001';
	LET cCccmayor = '';
	LET cCccsub = '';
	LET cCccsubsub = '';
	LET cCccsssub = '';
	LET cCccssssub = '';
	LET cCsector = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCccmayor, cCccsub, cCccsubsub, cCccsssub, cCccssssub, cCsector, cNombre;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_ris_consultacatalogo.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCccmayor, cCccsub, cCccsubsub, cCccsssub, cCccssssub, cCsector, cNombre;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
		
		SELECT {+INDEX (bdinteg:"informix".si_catalog catalog)} ccmayor, ccsub,  ccsubsub, ccssubsub, ccsssubsub, sector, nombre
		INTO cCccmayor, cCccsub, cCccsubsub, cCccsssub, cCccssssub, cCsector, cNombre
		FROM bdinteg:"informix".si_catalog 
		WHERE empresa = cEmpresa
		AND tipo_cuenta = 'D'
		AND cancelacion = 'N'
		AND ccmayor LIKE CASE WHEN pCcmayor = '' THEN ccmayor ELSE pCcmayor || '%' END 
		AND ccsub LIKE CASE WHEN pCcsub = '' THEN ccsub ELSE pCcsub || '%' END 
		AND ccsubsub LIKE CASE WHEN pCcsubsub = '' THEN ccsubsub ELSE pCcsubsub || '%' END 
		AND ccssubsub LIKE CASE WHEN pCcssubsub = '' THEN ccssubsub ELSE pCcssubsub || '%' END 
		AND ccsssubsub LIKE CASE WHEN pCcsssubsub = '' THEN ccsssubsub ELSE pCcsssubsub || '%' END 
		AND sector LIKE CASE WHEN pSector = '' THEN sector ELSE pSector || '%' END
		
		RETURN cCodRet, cCccmayor, cCccsub, cCccsubsub, cCccsssub, cCccssssub, cCsector, cNombre WITH RESUME;
		
		END FOREACH;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00030';
		END IF;

	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃÂ¡nchez',
'FECHA: 21/12/2020',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: Mantenimiento a Transacciones por Producto',
'DESCRIPCION: SPL encargado de Consultar EL CATALOGO',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ris_consultacriteriostransaccionesb5(pSistema CHAR(2), pProducto CHAR(10),  pTransaccion CHAR(4), pDescripcion CHAR(50),pUsuario CHAR(8))
		RETURNING CHAR(5) AS codret,
				CHAR(100) AS dato1,
				CHAR(100) AS dato2,
				CHAR(100) AS dato3,
				CHAR(10) AS dato4,
				CHAR(10) AS dato5,
				CHAR(10) AS dato6,
				CHAR(10) AS dato7,
				CHAR(10) AS dato8,
				CHAR(10) AS dato9,
				CHAR(10) AS dato10,
				CHAR(10) AS dato11,
				CHAR(10) AS dato12,
				CHAR(10) AS dato13,
				CHAR(10) AS dato14,
				CHAR(10) AS dato15,
				CHAR(10) AS dato16,
				CHAR(10) AS transaccion,
				CHAR(100) AS descripcion;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iInicioReg INTEGER;
	DEFINE iTamReg INTEGER;
	DEFINE iPosCaracter INTEGER;
	DEFINE iPosCaracter2 INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cTabla CHAR(50);
	DEFINE cDato2 CHAR(50);
	DEFINE cCampo1 CHAR(50);
	DEFINE cCampo2 CHAR(50);
	DEFINE cBase CHAR(50);
	DEFINE cDescripcion CHAR(100);
	DEFINE cUsrBin CHAR(15);
	DEFINE cIfxBin CHAR(15);
	DEFINE cCmd1 CHAR(2000);
	DEFINE cCmd2 CHAR(2000);
	DEFINE cCmd3 CHAR(2000);
	DEFINE cCmd4 CHAR(2000);
	DEFINE cCmd5 CHAR(2000);
	DEFINE cCmd6 CHAR(2000);
	DEFINE cFile CHAR(100);
	DEFINE cCodigo CHAR(10);
	DEFINE cDescProd CHAR(100);
	DEFINE cDato1 CHAR(100);
	DEFINE cDato2_2 CHAR(100);
	DEFINE cDato3 CHAR(100);
	DEFINE cDato4 CHAR(10);
	DEFINE cDato5 CHAR(10);
	DEFINE cDato6 CHAR(10);
	DEFINE cDato7 CHAR(10);
	DEFINE cDato8 CHAR(10);
	DEFINE cDato9 CHAR(10);
	DEFINE cDato10 CHAR(10);
	DEFINE cDato11 CHAR(10);
	DEFINE cDato12 CHAR(10);
	DEFINE cDato13 CHAR(10);
	DEFINE cDato14 CHAR(10);
	DEFINE cDato15 CHAR(10);
	DEFINE cDato16 CHAR(10);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iInicioReg = 1;
	LET iTamReg = 0;
	LET iPosCaracter = 0;
	LET iRecuperacion = 0;
	LET cEmpresa = '001';
	LET cTabla = '';
	LET cDato2 = '';
	LET cCampo1 = '';
	LET cCampo2 = '';
	LET iPosCaracter2 = '';
	LET cBase = '';
	LET cDescripcion = '';
	LET cUsrBin = '/usr/bin/';
	LET cIfxBin = '/ifxsif01/bin/';
	LET cCmd1 = '';
	LET cCmd2 = '';
	LET cCmd3 = '';
	LET cCmd4 = '';
	LET cCmd5 = '';
	LET cCmd6 = '';
	LET cFile = 'Data_'||TO_CHAR(CURRENT,'%Y%m%d%H%M%S')||'.sql';
	LET cCodigo = '';
	LET cDescProd = '';
	LET cDato1 = '';
	LET cDato2_2 = '';
	LET cDato3 = '';
	LET cDato4 = '';
	LET cDato5 = '';
	LET cDato6 = '';
	LET cDato7 = '';
	LET cDato8 = '';
	LET cDato9 = '';
	LET cDato10 = '';
	LET cDato11 = '';
	LET cDato12 = '';
	LET cDato13 = '';
	LET cDato14 = '';
	LET cDato15 = '';
	LET cDato16 = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cDato1, cDato2_2, cDato3, cDato4, cDato5, cDato6, cDato7, cDato8, cDato9, cDato10, cDato11, cDato12, cDato13, cDato14, cDato15, cDato16, cCodigo,cDescProd;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ris_consultacriteriostransacciones.out';
		--TRACE ON;
		
		IF pSistema = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cDato1, cDato2_2, cDato3, cDato4, cDato5, cDato6, cDato7, cDato8, cDato9, cDato10, cDato11, cDato12, cDato13, cDato14, cDato15, cDato16, cCodigo,cDescProd;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		
			DELETE FROM bdicnweb:"informix".sw_ristras_consultacriteriostransacciones WHERE usuario_insert = pUsuario;
		
			SELECT base_datos, NVL(tabla_productos, 'SIN DATO') descripcion 
			INTO cBase, cDescripcion
			FROM bdinteg:"informix".si_sistema 
			WHERE sistema = pSistema;
			
			LET iTamReg = LENGTH(TRIM(cDescripcion));
			LET iPosCaracter = INSTR(cDescripcion, ":");
			LET cTabla = SUBSTR(TRIM(cDescripcion), iInicioReg, (iPosCaracter - 1));
			LET cDato2 = SUBSTR(TRIM(cDescripcion), (iPosCaracter + 1), (iTamReg - iPosCaracter));
			LET iPosCaracter2 = INSTR(cDato2, ":");
			LET cCampo1 = SUBSTR(TRIM(cDato2), iInicioReg, (iPosCaracter2 - 1));
			LET cCampo2 = SUBSTR(TRIM(cDato2), (iPosCaracter2 + 1), (iTamReg - iPosCaracter2));
		
			LET cCmd1 = TRIM(cUsrBin)||"echo " || '"' || "INSERT INTO bdicnweb:""informix"".sw_ristras_consultacriteriostransacciones (usuario_insert,dato1,dato2,dato3,dato4,dato5,dato6,dato7,dato8,dato9,dato10,dato11,dato12,dato13,dato14,dato15,dato16) SELECT '" || pUsuario || "'," || " TRIM(b.descripcion) || ' [' || TRIM(a.sistema) || ']', " || "d." || Trim(cCampo2) || "|| ' [' || a.producto || ']', '[' || transaccion || '] ' || TRIM(c.descripcion), secuencia, c_ccmayor, c_ccsub, c_ccsubsub, c_ccsssub, c_ccssssub, c_sector, a_ccmayor, a_ccsub, a_ccsubsub, a_ccsssub, a_ccssssub, a_sector FROM bdinteg:si_prodtran a, bdinteg:si_sistema b, bdinteg:si_transacc c, " || Trim(cBase) || ":" || Trim(cTabla) || " d";		
			LET cCmd2 = "" || TRIM(cCmd1) || " WHERE d.empresa = a.empresa AND d." || Trim(cCampo1) || " = a.producto AND c.empresa = a.empresa AND c.numero = a.transaccion AND b.sistema = a.sistema";
		
			IF pProducto <> '' THEN
				LET cCmd3 = TRIM(cCmd2) || " AND a.producto LIKE '" || TRIM(pProducto) || "%'";
			ELSE
				LET cCmd3 = TRIM(cCmd2);
			END IF;
		
			IF pTransaccion <> '' THEN
				LET cCmd4 = TRIM(cCmd3) || " AND a.transaccion LIKE '" || TRIM(pTransaccion) || "%'";
			ELSE
				LET cCmd4 = TRIM(cCmd3);
			END IF;
		
			IF pDescripcion <> '' THEN
				LET cCmd5 = TRIM(cCmd4) || " AND c.descripcion LIKE '" || TRIM(pDescripcion) || "%'";
			ELSE
				LET cCmd5 = TRIM(cCmd4);
			END IF;
		
			LET cCmd6 = TRIM(cCmd5) || " ORDER BY 1,2,3, a.secuencia"" > /tmp/mfinis/" || cFile;
		
			SYSTEM TRIM(cCmd6);
		
			LET cCmd1 = "";
			LET cCmd1 = TRIM(cIfxBin)||"dbaccess bdicnweb < /tmp/mfinis/" || cFile;
			SYSTEM TRIM(cCmd1);
		
			LET cCmd1 = "";
			LET cCmd1 = TRIM(cUsrBin)||"rm -rf /tmp/mfinis/" || TRIM(cFile);
			SYSTEM TRIM(cCmd1);

		
		FOREACH
			SELECT 
			dato1, dato2, dato3, dato4, dato5, dato6, dato7, dato8, dato9, dato10, dato11, dato12, dato13, dato14, dato15, dato16
			INTO cDato1, cDato2_2, cDato3, cDato4, cDato5, cDato6, cDato7, cDato8, cDato9, cDato10, cDato11, cDato12, cDato13, cDato14, cDato15, cDato16
			FROM bdicnweb:"informix".sw_ristras_consultacriteriostransacciones
			WHERE usuario_insert = pUsuario
			ORDER BY 3,4
						
			RETURN cCodRet, cDato1, cDato2_2, cDato3, cDato4, cDato5, cDato6, cDato7, cDato8, cDato9, cDato10, cDato11, cDato12, cDato13, cDato14, cDato15, cDato16, cCodigo,cDescProd WITH RESUME;
		
		END FOREACH;
			
		IF DBINFO('sqlca.sqlerrd2') = 0  THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, cDato1, cDato2_2, cDato3, cDato4, cDato5, cDato6, cDato7, cDato8, cDato9, cDato10, cDato11, cDato12, cDato13, cDato14, cDato15, cDato16, cCodigo,cDescProd;
		END IF;	
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sï¿½?ï¿½?ï¿½?Â¡nchez',
'FECHA: 21/12/2020',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: Mantenimiento a Transacciones por Producto',
'DESCRIPCION: SPL encargado de Consultar los por diferentes criterios de busqueda',
'AUTOR: Verï¿½?ï¿½?ï¿½?Â³nica Sï¿½?ï¿½?ï¿½?Â¡nchez Tlacomulco',
'FECHA: 04/03/2021',
'DESCRIPCION: Se realiza ajuste a SP para realizar ordenamiento de informaciï¿½?ï¿½?ï¿½?Â³n por secuencia.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ris_consultaprodtransaccionb5(pSistema CHAR(10), pSecuencia CHAR(10), pTransaccion CHAR(10), pProducto CHAR(10))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iTotales INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET iTotales = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--DEBUG FILE TO '/tmp/mfinis/sp_ris_consultaprodtransaccion.out';
		--TRACE ON;
		
		IF  pSistema = '' OR pSecuencia = '' OR pTransaccion = '' OR pProducto  = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		SELECT COUNT(*) 
		INTO iTotales
		FROM bdinteg:"informix".si_prodtran
        WHERE empresa = cEmpresa
		AND sistema = pSistema
		AND producto = pProducto
		AND transaccion = pTransaccion
		AND secuencia = pSecuencia;
			
		IF iTotales > 0 THEN
			LET cCodRet = '99999';
		END IF;
		
		RETURN cCodRet;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sï¿½?Â¡nchez',
'FECHA: 25/02/2020',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: Mantenimiento a Transacciones por Producto',
'DESCRIPCION: SPL encargado de Consultar una transacciï¿½?Â³n',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ris_consultaproductosb5(pSistema CHAR(2),pUsuario char(8))
		RETURNING CHAR(5) AS codret,
				CHAR(10) AS codigo,
				CHAR(100) AS descProd;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iInicioReg INTEGER;
	DEFINE iTamReg INTEGER;
	DEFINE iPosCaracter INTEGER;
	DEFINE iPosCaracter2 INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cTabla CHAR(50);
	DEFINE cDato2 CHAR(50);
	DEFINE cCampo1 CHAR(50);
	DEFINE cCampo2 CHAR(50);
	DEFINE cBase CHAR(50);
	DEFINE cDescripcion CHAR(100);
	DEFINE cUsrBin CHAR(15);
	DEFINE cIfxBin CHAR(15);
	DEFINE cCmd1 CHAR(1000);
	DEFINE cFile CHAR(100);
	DEFINE cCodigo CHAR(10);
	DEFINE cDescProd CHAR(100);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iInicioReg = 1;
	LET iTamReg = 0;
	LET iPosCaracter = 0;
	LET iRecuperacion = 0;
	LET cEmpresa = '001';
	LET cTabla = '';
	LET cDato2 = '';
	LET cCampo1 = '';
	LET cCampo2 = '';
	LET iPosCaracter2 = '';
	LET cBase = '';
	LET cDescripcion = '';
	LET cUsrBin = '/usr/bin/';
	LET cIfxBin = '/ifxsif01/bin/';
	--LET cIfxBin = '/informix/bin/';
	LET cCmd1 = '';
	LET cFile = 'Data_'||TO_CHAR(CURRENT,'%Y%m%d%H%M%S')||'.sql';
	LET cCodigo = '';
	LET cDescProd = '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodigo, cDescProd;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_ris_consultaproductos.out';
		--TRACE ON;

		IF  pSistema = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodigo, cDescProd;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		DELETE FROM  bdicnweb:"informix".sw_ristras_cmbproducto WHERE usuario_insert = pUsuario;

		SELECT base_datos, NVL(tabla_productos, 'SIN DATO') descripcion
		INTO cBase, cDescripcion
		FROM bdinteg:"informix".si_sistema
		WHERE sistema = pSistema;

		LET iTamReg = LENGTH(TRIM(cDescripcion));
		LET iPosCaracter = INSTR(cDescripcion, ":");
		LET cTabla = SUBSTR(TRIM(cDescripcion), iInicioReg, (iPosCaracter - 1));
		LET cDato2 = SUBSTR(TRIM(cDescripcion), (iPosCaracter + 1), (iTamReg - iPosCaracter));
		LET iPosCaracter2 = INSTR(cDato2, ":");
		LET cCampo1 = SUBSTR(TRIM(cDato2), iInicioReg, (iPosCaracter2 - 1));
		LET cCampo2 = SUBSTR(TRIM(cDato2), (iPosCaracter2 + 1), (iTamReg - iPosCaracter2));

		IF TRIM(cBase) = 'bditransfe' THEN
			let cBase = 'bditransfer';
		END IF;

		LET cCmd1 = TRIM(cUsrBin)||"echo " || '"' || "INSERT INTO bdicnweb:""informix"".sw_ristras_cmbproducto (usuario_insert, codigo, descripcion) SELECT '" || pUsuario || "'," || TRIM(cCampo1) || ", " || TRIM(cCampo2) || " FROM " || TRIM(cBase) || ":""informix""." || TRIM(cTabla) || " WHERE empresa = '" || cEmpresa || "'; "" > /tmp/mfinis/" || cFile;

		SYSTEM TRIM(cCmd1);

		LET cCmd1 = "";
		LET cCmd1 = TRIM(cIfxBin)||"dbaccess bdicnweb < /tmp/mfinis/" || cFile;
		SYSTEM TRIM(cCmd1);

		LET cCmd1 = "";
		LET cCmd1 = TRIM(cUsrBin)||"rm -rf /tmp/mfinis/" || TRIM(cFile);
		SYSTEM TRIM(cCmd1);

		FOREACH
			SELECT codigo, descripcion
			INTO cCodigo, cDescProd
			FROM bdicnweb:"informix".sw_ristras_cmbproducto
			WHERE usuario_insert = pUsuario
            ORDER BY codigo ASC

			LET cDescProd = cDescProd || " [" || cCodigo || "]";

			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cCodigo, cDescProd WITH RESUME;

		END FOREACH;

		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCodigo, cDescProd;
		END IF;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sï¿½?Â¡nchez',
'FECHA: 21/12/2020',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: Mantenimiento a Transacciones por Producto',
'DESCRIPCION: SPL encargado de Consultar los Productos por Sistema',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ris_consultasistemasb5()
		RETURNING CHAR(5) AS codret,
			 CHAR(2) AS sistema,
			 CHAR(35) AS descripcion;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cSistema CHAR(2);
	DEFINE cDescripcion CHAR(35);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cSistema = '';
	LET cDescripcion = '';
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cSistema, cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ris_consultasistemas.out';
		--TRACE ON;
				
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
		
			SELECT sistema, descripcion  
			INTO cSistema, cDescripcion 
			FROM bdinteg:"informix".si_sistema
			WHERE utiliza_productos = 'S' 
			AND descripcion NOT IN ('TRANSFERENCIAS') 
			ORDER BY descripcion
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cSistema, cDescripcion WITH RESUME;
			
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, cSistema, cDescripcion;
		END IF;	
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 21/12/2020',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: Mantenimiento a Transacciones por Producto',
'DESCRIPCION: SPL encargado de Consultar los Sistemas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ris_consultatransaccionb5(pSistema CHAR(10), pSecuencia CHAR(10), pTransaccion CHAR(10), pProducto CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(3) AS sistema, 
			CHAR(4) AS producto, 
			CHAR(4) AS transaccion,
			CHAR(50) AS descTran,
			CHAR(1) AS naturaleza,
			INTEGER AS secuencia, 
			CHAR(10) AS c_ccmayor, 
			CHAR(10) AS c_ccsub, 
			CHAR(10) AS c_ccsubsub, 
			CHAR(10) AS c_ccsssub, 
			CHAR(10) AS c_ccssssub, 
			CHAR(10) AS c_sector, 
			CHAR(10) AS a_ccmayor, 
			CHAR(10) AS a_ccsub, 
			CHAR(10) AS a_ccsubsub, 
			CHAR(10) AS a_ccsssub, 
			CHAR(10) AS a_ccssssub, 
			CHAR(10) AS a_sector,
			CHAR(200) AS descProd;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	--DEFINE iNoRegistros INTEGER;
	--DEFINE iRegistros INTEGER;
	--DEFINE iRecuperacion INTEGER;
	DEFINE cSistema CHAR(3);
	DEFINE cProducto CHAR(4);
	DEFINE cDescProd CHAR(200);
	DEFINE cTransaccion CHAR(4);
	DEFINE cDescTran CHAR(50);
	DEFINE cNaturaleza CHAR(1);
	DEFINE iSecuencia INTEGER;
	DEFINE cCccmayor CHAR(10);
	DEFINE cCccsub CHAR(10);
	DEFINE cCccsubsub CHAR(10);
	DEFINE cCccsssub CHAR(10);
	DEFINE cCccssssub CHAR(10);
	DEFINE cCsector CHAR(10);
	DEFINE cAccmayor CHAR(10);
	DEFINE cAccsub CHAR(10);
	DEFINE cAccsubsub CHAR(10);
	DEFINE cAccsssub CHAR(10);
	DEFINE cAccssssub CHAR(10); 
	DEFINE cAsector CHAR(10);

	DEFINE cDescripcionProducto CHAR(200);
	DEFINE cDescripcionTrans CHAR(200);

	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	--LET iNoRegistros = 0;
	--LET iRegistros = 0;
	--LET iRecuperacion = 0;
	LET cSistema = '';
	LET cProducto = '';
	LET cDescProd = '';
	LET cTransaccion = '';
	LET cDescTran = '';
	LET cNaturaleza = '';
	LET iSecuencia = 0;
	LET cCccmayor = '';
	LET cCccsub = '';
	LET cCccsubsub = '';
	LET cCccsssub = '';
	LET cCccssssub = '';
	LET cCsector = '';
	LET cAccmayor = '';
	LET cAccsub = '';
	LET cAccsubsub = '';
	LET cAccsssub = '';
	LET cAccssssub = '';
	LET cAsector = '';
	LET cDescripcionProducto ="";
	LET cDescripcionTrans = "";

	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cSistema, cProducto, cTransaccion, cDescTran, cNaturaleza, iSecuencia, cCccmayor, cCccsub, cCccsubsub, cCccsssub, cCccssssub, cCsector, cAccmayor, cAccsub, cAccsubsub, cAccsssub, cAccssssub, cAsector, cDescProd;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ris_consultatransaccion.out';
		--TRACE ON;
		
		IF pSistema = '' OR pSecuencia = '' OR pTransaccion = '' OR pProducto = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cSistema, cProducto, cTransaccion, cDescTran, cNaturaleza, iSecuencia, cCccmayor, cCccsub, cCccsubsub, cCccsssub, cCccssssub, cCsector, cAccmayor, cAccsub, cAccsubsub, cAccsssub, cAccssssub, cAsector, cDescProd;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT a.sistema, a.producto, transaccion, TRIM(c.descripcion)trandesc, NVL(DECODE(naturaleza, 'A','ABONO','C','CARGO','R','REFERENCIAL'), 'ABONO') naturaleza, 
		secuencia, c_ccmayor, c_ccsub, c_ccsubsub, c_ccsssub, c_ccssssub, c_sector, a_ccmayor, a_ccsub, a_ccsubsub, a_ccsssub, a_ccssssub, a_sector
		INTO cSistema, cProducto, cTransaccion, cDescripcionTrans, cNaturaleza, iSecuencia, cCccmayor, cCccsub, cCccsubsub, cCccsssub, cCccssssub, cCsector, cAccmayor, cAccsub, cAccsubsub, cAccsssub, cAccssssub, cAsector
		FROM bdinteg:"informix".si_prodtran a, bdinteg:"informix".si_transacc c 
		WHERE c.empresa = a.empresa 
		AND c.numero = a.transaccion 
		AND c.sistema = a.sistema 
		AND a.secuencia = pSecuencia
		AND a.transaccion = pTransaccion
		AND a.producto = pProducto 
		AND a.sistema = pSistema
		AND a.empresa = cEmpresa;

		
		SELECT NVL(nombre_prod, "N/A") 
		INTO cDescripcionProducto
		FROM bdicred:"informix".sd_definicion 
        WHERE num_producto = pProducto;

		LET cDescTran = cDescripcionTrans;

		IF cDescripcionProducto IS NULL THEN 
			LET cDescProd = "N/A";
			RETURN cCodRet, cSistema, cProducto, cTransaccion, cDescTran, cNaturaleza, iSecuencia, cCccmayor, cCccsub, cCccsubsub, cCccsssub, cCccssssub, cCsector, cAccmayor, cAccsub, cAccsubsub, cAccsssub, cAccssssub, cAsector, cDescProd;
		END IF

		LET cDescProd = TRIM(cDescripcionProducto) || " [" || TRIM(cProducto::CHAR(5)) || "]";
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, cSistema, cProducto, cTransaccion, cDescTran, cNaturaleza, iSecuencia, cCccmayor, cCccsub, cCccsubsub, cCccsssub, cCccssssub, cCsector, cAccmayor, cAccsub, cAccsubsub, cAccsssub, cAccssssub, cAsector, cDescProd;
		
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 21/12/2020',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: Mantenimiento a Transacciones por Producto',
'DESCRIPCION: SPL encargado de Consultar una Transaccion',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ris_consultatransaccionesb5(pSistema CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(4) AS numero,
			CHAR(50) AS descripcion,
			CHAR(15) AS naturaleza;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNumero CHAR(4);
	DEFINE cDescripcion CHAR(50);
	DEFINE cNaturaleza CHAR(15);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cNumero = '';
	LET cDescripcion = '';
	LET cNaturaleza = '';
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumero, cDescripcion, cNaturaleza;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ris_consultatransacciones.out';
		--TRACE ON;
		
		IF pSistema = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumero, cDescripcion, cNaturaleza;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT 
			numero, descripcion, NVL(DECODE(naturaleza, 'A','ABONO','C','CARGO','R','REFERENCIAL'), 'ABONO') naturaleza 
			INTO cNumero, cDescripcion, cNaturaleza
			FROM bdinteg:"informix".si_transacc
			WHERE empresa = cEmpresa 
			AND sistema = pSistema 
			ORDER BY numero ASC

			RETURN cCodRet, cNumero, cDescripcion, cNaturaleza WITH RESUME;
			
		END FOREACH;
		
		IF DBINFO('sqlca.sqlerrd2') = 0  THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, cNumero, cDescripcion, cNaturaleza;
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 21/12/2020',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: Mantenimiento a Transacciones por Producto',
'DESCRIPCION: SPL encargado de Consultar los las Transacciones por sistema',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_conciliaciontotalporconveniosac(pUsuario CHAR(8), pIdFuncion CHAR(10),cConvenio CHAR(5), dFechaIni DATE, dFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING
    CHAR(5)         AS retorno,
    CHAR(40)        AS nomconvenio,
    DATE            AS fecha_pago,
    DECIMAL(16,2)   AS importe_archivo,
    CHAR(30)        AS cuenta_cheques,	
    DECIMAL(16,2)   AS importe_cheq,
    CHAR(30)        AS cuenta_contable,
    DECIMAL(16,2)   AS importe_conta;
	
	DEFINE cCodRet				CHAR(5);
	DEFINE cCodRetSp			CHAR(5);
	DEFINE iSqlErr				INTEGER;
	DEFINE cNomConvenio			CHAR(40);
	DEFINE dFechapago			DATE;
	DEFINE deImporteArchivo		DECIMAL(16,2);
	DEFINE cCuentaCheques		CHAR(30);
	DEFINE deImporteCheq		DECIMAL(16,2);
	DEFINE cCuentaContable		CHAR(30);
	DEFINE deImporteConta		DECIMAL(16,2);
	DEFINE iRegistros			INTEGER;
	DEFINE iRecuperacion		INTEGER;
	DEFINE iNoRegs				INTEGER;

	LET cCodRet = "00000";
	LET cCodRetSp = "";
	LET iSqlErr = 0;
	LET cNomConvenio  = "";
	LET dFechapago  = "";
	LET deImporteArchivo  = 0;
	LET cCuentaCheques   = "";
	LET deImporteCheq  = 0;
	LET cCuentaContable  = "";
	LET deImporteConta =  0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET iNoRegs = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			UPDATE "informix".sw_verificastatusconveniosac
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet, cNomConvenio,  dFechapago,  deImporteArchivo,  cCuentaCheques, deImporteCheq, cCuentaContable, deImporteConta;
        END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/bdicnweb/sac/sp_conciliaciontotalporconveniosac2.out';
		--TRACE ON;

     SET ISOLATION TO DIRTY READ;
     SET LOCK MODE TO WAIT 3;
		
		IF cConvenio = "" OR LENGTH(cConvenio) <> 5 OR pUsuario = '' OR pIdFuncion = '' OR  cConvenio = '' OR dFechaIni = '' OR dFechaFin = '' OR pRegistros = '' OR pRecuperacion = '' THEN
			LET cCodRet = "00003";
            RETURN cCodRet, cNomConvenio,  dFechapago,  deImporteArchivo,  cCuentaCheques, deImporteCheq, cCuentaContable, deImporteConta;
		END IF;
		
		IF pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNomConvenio,  dFechapago,  deImporteArchivo,  cCuentaCheques, deImporteCheq, cCuentaContable, deImporteConta;
		END IF;

		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF	cCodRet <> '00000' THEN
			RETURN cCodRet, cNomConvenio,  dFechapago,  deImporteArchivo,  cCuentaCheques, deImporteCheq, cCuentaContable, deImporteConta;
		END IF;

		DELETE FROM "informix".sw_verificastatusconveniosac WHERE usuario_insert = TRIM(pUsuario);
		DELETE FROM "informix".sw_conciliaciontotalporconveniosacinfo WHERE usuario = TRIM(pUsuario) AND tipoOperacion = '2';
		INSERT INTO "informix".sw_verificastatusconveniosac(usuario_insert, status, error_proceso, error, registros) 
		VALUES(pUsuario,'I','',cCodRet,0);

        IF cConvenio = "" OR LENGTH(cConvenio) <> 5 THEN
			LET cCodRet = "00003";
            RETURN cCodRet, cNomConvenio,  dFechapago,  deImporteArchivo,  cCuentaCheques, deImporteCheq, cCuentaContable, deImporteConta;
		ELSE
			SET ISOLATION TO DIRTY READ;
			FOREACH EXECUTE PROCEDURE bdisac:sp_conciliaciontotalporconvenio(cConvenio, dFechaIni, dFechaFin)
				INTO cCodRetSp, cNomConvenio,  dFechapago,  deImporteArchivo,  cCuentaCheques, deImporteCheq, cCuentaContable, deImporteConta
						   -- ValidaciÃÂ³n de los codigos de retorno
				IF cCodRetSp::INTEGER < 0 THEN
					UPDATE "informix".sw_verificastatusconveniosac
					SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL bdisac:sp_conciliaciontotalporconvenio.sql';

				ELIF cCodRetSp::INTEGER = 2 THEN	
					LET cCodRet = '00017';
					UPDATE "informix".sw_verificastatusconveniosac
					SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;

					RETURN cCodRet, cNomConvenio,  dFechapago,  deImporteArchivo,  cCuentaCheques, deImporteCheq, cCuentaContable, deImporteConta;

				END IF;
				IF cCodRetSp = '00000' THEN
					--IF iRegistros >= pRegistros THEN
					--	IF iRecuperacion < pRecuperacion THEN
							LET iRecuperacion = iRecuperacion + 1;
							LET iNoRegs = iNoRegs + 1;
							LET iRegistros = iRegistros + 1;

							INSERT INTO "informix".sw_conciliaciontotalporconveniosacinfo
        					(nomconvenio, fecha_pago, importe_archivo, cuenta_cheques, importe_cheq, cuenta_contable, importe_conta, usuario, tipooperacion) 
   							VALUES(cNomConvenio, dFechapago, deImporteArchivo, cCuentaCheques, deImporteCheq, cCuentaContable, deImporteConta, pUsuario ,'2');

							RETURN cCodRet, cNomConvenio,  dFechapago,  deImporteArchivo,  cCuentaCheques, deImporteCheq, cCuentaContable, deImporteConta WITH RESUME;
							
					--	END IF;
					--END IF;
						
				ELSE
					LET cCodRet = cCodRetSp;
					RETURN cCodRet, '', '', '', '', '','', '';
				END IF;
			END FOREACH;
		END IF;

		UPDATE "informix".sw_verificastatusconveniosac
		SET status = 'T', error_proceso = 'N', registros = iRegistros WHERE usuario_insert = pUsuario;

		IF iNoRegs = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNomConvenio,  dFechapago,  deImporteArchivo,  cCuentaCheques, deImporteCheq, cCuentaContable, deImporteConta;
		ELIF iNoRegs = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNomConvenio,  dFechapago,  deImporteArchivo,  cCuentaCheques, deImporteCheq, cCuentaContable, deImporteConta;
		END IF;
	END;
END PROCEDURE
DOCUMENT
'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 09/11/2023',
'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'DESCRIPCIÃN: SP encargado de obtener el reporte de conciliaciÃ³n por convenio',
'FECHA: 25/07/2024',
'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'DESCRIPCIÃN: Se actualiza el paginado del procedimiento almacenado para que valide cuando ya no haya mas registros con el codigo 1001';

CREATE PROCEDURE "informix".sp_conciliaciontotalporconveniosacinfo(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoOperacion INTEGER,pRegistros INTEGER, pRecuperacion INTEGER)
   RETURNING
    CHAR(5)         AS retorno,
    CHAR(40)        AS nomconvenio,
    DATE            AS fecha_pago,
    DECIMAL(16,2)   AS importe_archivo,
    CHAR(30)        AS cuenta_cheques,	
    DECIMAL(16,2)   AS importe_cheq,
    CHAR(30)        AS cuenta_contable,
    DECIMAL(16,2)   AS importe_conta,
    INTEGER         AS numpagos,
	MONEY(16,2)     AS importepago,
	MONEY(16,2)     AS importecomisionconvenio, 
	MONEY(16,2)     AS ivacomisionconvenio,
	MONEY(16,2)     AS importecomisioncte,
	MONEY(16,2)     AS ivacomisioncte,
	INTEGER         AS flagconfirmacioncentral,
	INTEGER         AS flagconfirmacionsucursal;

    DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNumPagos INTEGER;
	DEFINE cNomConvenio CHAR(40);
	DEFINE mImportePago  MONEY(16,2);
	DEFINE mImporteComisionConvenio MONEY(16,2);
	DEFINE mIvaComisionConvenio MONEY(16,2);
	DEFINE mImporteComisionCte MONEY(16,2);
	DEFINE mIvaComisionCte MONEY(16,2);
	DEFINE iFlagConfirmacionCentral INTEGER;
	DEFINE iFlagConfirmacionSucursal INTEGER;

	DEFINE dFechapago			DATE;
	DEFINE deImporteArchivo		DECIMAL(16,2);
	DEFINE cCuentaCheques		CHAR(30);
	DEFINE deImporteCheq		DECIMAL(16,2);
	DEFINE cCuentaContable		CHAR(30);
	DEFINE deImporteConta		DECIMAL(16,2);
    DEFINE iRegistros INTEGER;

	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iSqlErr = 0;
	LET iNumPagos = 0;
	LET cNomConvenio = '';
	LET mImportePago = 0;
	LET mImporteComisionConvenio = 0;
	LET mIvaComisionConvenio = 0;
	LET mImporteComisionCte = 0;
	LET mIvaComisionCte = 0;
	LET iFlagConfirmacionCentral = 0;
	LET iFlagConfirmacionSucursal = 0;
	LET iRegistros = 0;

	LET dFechapago  = "";
	LET deImporteArchivo  = 0;
	LET cCuentaCheques   = "";
	LET deImporteCheq  = 0;
	LET cCuentaContable  = "";
	LET deImporteConta =  0;


    BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNomConvenio,  dFechapago,  deImporteArchivo,  cCuentaCheques, deImporteCheq, cCuentaContable, deImporteConta,
                    iNumPagos, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio, mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
        END EXCEPTION;

        IF pUsuario = '' OR pIdFuncion = '' OR pTipoOperacion = '' THEN
            LET cCodRet = '00003';
            RETURN cCodRet, cNomConvenio,  dFechapago,  deImporteArchivo,  cCuentaCheques, deImporteCheq, cCuentaContable, deImporteConta,
                    iNumPagos, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio, mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
        END IF;
        
        --SET DEBUG FILE TO '/tmp/mfinis/sp_conciliaciontotalporconveniosacinfo.out';
		--TRACE ON;

        EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
				IF cCodret <> '00000' THEN
				RETURN cCodRet, cNomConvenio,  dFechapago,  deImporteArchivo,  cCuentaCheques, deImporteCheq, cCuentaContable, deImporteConta,
                iNumPagos, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio, mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
		END IF;
			
			SET ISOLATION TO DIRTY READ;
            SET LOCK MODE TO WAIT 3;


        FOREACH
            SELECT SKIP pRegistros FIRST pRecuperacion nomconvenio ,fecha_pago  ,importe_archivo ,cuenta_cheques ,importe_cheq ,cuenta_contable ,importe_conta ,
                    numpagos ,importe_pago ,importe_comision_convenio ,iva_comision_convenio ,importe_comision_cte ,iva_comision_cte ,flag_confirmacion_central ,
                    flag_confirmacion_sucursal
            INTO    cNomConvenio,  dFechapago,  deImporteArchivo,  cCuentaCheques, deImporteCheq, cCuentaContable, deImporteConta,
                    iNumPagos, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio, mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal
            FROM bdicnweb:"informix".sw_conciliaciontotalporconveniosacinfo
            WHERE usuario = pUsuario AND tipoOperacion = pTipoOperacion

            LET iRegistros = iRegistros + 1;

            RETURN cCodRet, cNomConvenio,  dFechapago,  deImporteArchivo,  cCuentaCheques, deImporteCheq, cCuentaContable, deImporteConta,
                iNumPagos, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio, mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal WITH RESUME;
        END FOREACH;

        IF iRegistros = 0 AND pRegistros = 0 THEN
            LET cCodRet = '00017';
            RETURN cCodRet, cNomConvenio,  dFechapago,  deImporteArchivo,  cCuentaCheques, deImporteCheq, cCuentaContable, deImporteConta,
                iNumPagos, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio, mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
        
		ELIF iRegistros = 0 AND pRegistros > 0 THEN
            LET cCodRet = '1001';
			RETURN cCodRet, cNomConvenio,  dFechapago,  deImporteArchivo,  cCuentaCheques, deImporteCheq, cCuentaContable, deImporteConta,
                iNumPagos, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio, mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
        
        END IF;
    END
END PROCEDURE
DOCUMENT
'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 09/11/2023',
'DESCRIPCIÃN: SP encargado de obtener el los valores del reporte',
'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 25/07/2024',
'DESCRIPCIÃN: Se actualiza el paginado del procedimiento almacenado';

CREATE PROCEDURE "informix".sp_reportemensualconveniosac(pUsuario CHAR(8), pIdFuncion CHAR(10), pConvenio CHAR(5), pPeriodo CHAR(6), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR (5) AS retorno,
        CHAR(6) AS aniomes,
        DATE AS fecha,
        INTEGER AS num_operaciones,
        MONEY (16,2) AS comision,
        MONEY (16,2) AS iva;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSP CHAR(6);
	DEFINE iSqlErr INTEGER;
	DEFINE cAniomes CHAR(6);
	DEFINE dFecha DATE;
	DEFINE iNumOperaciones INTEGER;
	DEFINE mComision MONEY (16,2);
	DEFINE mIva MONEY(16,2);
	DEFINE cTabla CHAR(1500);
	DEFINE cQuery CHAR(1500);
	DEFINE iNumRows INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iNoRegs INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET cCodRetSP = '';
	LET iSqlErr = 0;
	LET cAniomes = '';
	LET dFecha = NULL;
	LET iNumOperaciones = 0;
	LET mComision = 0;
	LET mIva = 0;
	LET cTabla = '';
	LET cQuery = '';
	LET iNumRows = 0;
	LET iRegistros = 0;
	LET iNoRegs = 0;
	LET iRecuperacion = 0;
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cAniomes, dFecha, iNumOperaciones, mComision, mIva;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/reportes_Mensuales.out';
		--TRACE ON;

                        SET ISOLATION TO DIRTY READ;
            SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pConvenio = '' OR pPeriodo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cAniomes, dFecha, iNumOperaciones, mComision, mIva;
		END IF;
		
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cAniomes, dFecha, iNumOperaciones, mComision, mIva;
		END IF;
		
		SELECT COUNT(aniomes) INTO iNumRows FROM bdisac:sac_liquidacionmensual WHERE aniomes = pPeriodo AND id_convenio = pConvenio;
			IF iNumRows <> 0 THEN
				FOREACH EXECUTE PROCEDURE bdisac:sp_sacreportemensual(pConvenio, pPeriodo) INTO cCodRetSp, cAnioMes, dFecha, iNumOperaciones, mComision, mIva
							   -- ValidaciÃ³n de los codigos de retorno
					IF cCodRetSp = '00001' THEN
							LET cCodRet = '00003';
							RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva;
						ELIF cCodRetSp = '000000' THEN
							IF iRegistros >= pRegistros THEN
								IF iRecuperacion < pRecuperacion THEN
									LET iRecuperacion = iRecuperacion + 1;
									RETURN cCodRet,cAnioMes, dFecha, iNumOperaciones, mComision, mIva WITH RESUME;
									LET iNoRegs = iNoRegs + 1;
								END IF;
							END IF;
								LET iRegistros = iRegistros + 1;
					ELSE
						LET cCodRet = cCodRetSp;
						RETURN cCodRet, '', '', 0, 0, 0;
					END IF;
				END FOREACH

				IF iRegistros = 0 AND pRegistros > 0 THEN
					LET cCodRet = '1001';
					RETURN cCodRet, cAniomes, dFecha, iNumOperaciones, mComision, mIva;
				END IF; 
			ELSE
				LET cCodRet = '00017';
				RETURN cCodRet, cAniomes, dFecha, iNumOperaciones, mComision, mIva;
			END IF;
	END;
END PROCEDURE
DOCUMENT
'FECHA: 25/07/2024',
'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'DESCRIPCIÃN: Se coloca la validaciÃ³n del paginado codigo 1001 cuando no encuentre elementos que regresar.';

CREATE PROCEDURE "informix".sp_reportetotalporconveniossac(pUsuario CHAR(8), pIdFuncion CHAR(10), cConvenio CHAR (5), cSucursal CHAR(4), 
dFechaIni DATE, dFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
RETURNING CHAR(5)  AS retorno,
	INTEGER AS numpagos,
	CHAR(40) AS nomconvenio,
	MONEY(16,2) AS importepago,
	MONEY(16,2) AS importecomisionconvenio, 
	MONEY(16,2) AS ivacomisionconvenio,
	MONEY(16,2) AS importecomisioncte,
	MONEY(16,2) AS ivacomisioncte,
	INTEGER AS flagconfirmacioncentral,
	INTEGER AS flagconfirmacionsucursal;		
	
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNumPagos INTEGER;
	DEFINE cNomConvenio CHAR(40);
	DEFINE mImportePago  MONEY(16,2);
	DEFINE mImporteComisionConvenio MONEY(16,2);
	DEFINE mIvaComisionConvenio MONEY(16,2);
	DEFINE mImporteComisionCte MONEY(16,2);
	DEFINE mIvaComisionCte MONEY(16,2);
	DEFINE iFlagConfirmacionCentral INTEGER;
	DEFINE iFlagConfirmacionSucursal INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iNoRegs INTEGER;
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iSqlErr = 0;
	LET iNumPagos = 0;
	LET cNomConvenio = '';
	LET mImportePago = 0;
	LET mImporteComisionConvenio = 0;
	LET mIvaComisionConvenio = 0;
	LET mImporteComisionCte = 0;
	LET mIvaComisionCte = 0;
	LET iFlagConfirmacionCentral = 0;
	LET iFlagConfirmacionSucursal = 0;
	LET iRegistros = 0;
	LET iNoRegs = 0;
	LET iRecuperacion = 0;
		
		BEGIN
			ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE "informix".sw_verificastatusconveniosac
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;

				RETURN cCodRet, iNumPagos, cNomConvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
				mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
			END iF;
			END EXCEPTION;
			
			--SET DEBUG FILE TO '/tmp/mfinis/sp_reportetotalporconveniossac.out';
			--TRACE ON;
			
			IF pUsuario = '' OR pIdFuncion = '' OR LENGTH(cConvenio) <> 5 OR LENGTH(cSucursal) <> 4 OR dFechaIni = '' OR dFechaFin = '' OR pRegistros = '' OR pRecuperacion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iNumPagos, cNomConvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
				mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
			END IF;
			IF pRecuperacion < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet, iNumPagos, cNomConvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
				mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
			END IF;
			
			EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
				IF cCodret <> '00000' THEN
					RETURN cCodRet, iNumPagos, cNomConvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
					mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
				END IF;
			
			SET ISOLATION TO DIRTY READ;
            SET LOCK MODE TO WAIT 3;

			--
			DELETE FROM "informix".sw_verificastatusconveniosac WHERE usuario_insert = TRIM(pUsuario);
			DELETE FROM "informix".sw_conciliaciontotalporconveniosacinfo WHERE usuario = TRIM(pUsuario) AND tipoOperacion = '1';
			INSERT INTO "informix".sw_verificastatusconveniosac(usuario_insert, status, error_proceso, error, registros) 
			VALUES(pUsuario,'I','',cCodRet,0);

			FOREACH EXECUTE PROCEDURE bdisac:sp_sacreportetotalporconvenios (cConvenio, cSucursal, dFechaIni, dFechaFin) 
			INTO cCodRetSp, iNumPagos, cNomConvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
			mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal

			IF cCodRetSp::INTEGER < 0 THEN
				UPDATE "informix".sw_verificastatusconveniosac
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL bdisac:sp_sacreportetotalporconvenios.sql';
			ELIF cCodRetSp::INTEGER = 2 THEN	
				LET cCodRet = '00017';
				UPDATE "informix".sw_verificastatusconveniosac
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;

				RETURN cCodRet, iNumPagos, cNomConvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
				mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
			ELSE
				IF cCodRetSp = '00000' THEN
					--IF iRegistros >= pRegistros THEN
					--	IF iRecuperacion < pRecuperacion THEN
					LET iRecuperacion = iRecuperacion + 1;
					LET iNoRegs = iNoRegs + 1;
					LET iRegistros = iRegistros + 1;

					INSERT INTO "informix".sw_conciliaciontotalporconveniosacinfo(numpagos, nomconvenio, importe_pago, importe_comision_convenio, iva_comision_convenio, importe_comision_cte, iva_comision_cte, flag_confirmacion_central, flag_confirmacion_sucursal, usuario, tipoOperacion) 
					VALUES(iNumPagos, cNomConvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio, mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal, pUsuario, '1');

					RETURN cCodRet, iNumPagos, cNomConvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
					mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal WITH RESUME;
				
				ELSE
					LET cCodRet = cCodRetSp;
					RETURN cCodRet, 0, '', 0, 0, 0, 0, 0, 0, 0;
				END IF;
			END IF;
			END FOREACH;
			
			UPDATE "informix".sw_verificastatusconveniosac
			SET status = 'T', error_proceso = 'N', registros = iRegistros WHERE usuario_insert = pUsuario;
			
			IF iNoRegs = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iNumPagos, cNomConvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
				mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;         
			
			ELIF iNoRegs = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, iNumPagos, cNomConvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
				mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;         
			
			END IF;
	END;
END PROCEDURE
DOCUMENT
'AUTOR: ESparza Brenis Fernando Martin',
'FECHA: 09/11/2023',
'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'DESCRIPCIÃN: SP encargado de obtener el reporte de conciliaciÃ³n por convenio totales',
'FECHA: 25/07/2024',
'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'DESCRIPCIÃN: se modifica el paginado del procedimiento almacenado para que realice saltos cada bloque';

CREATE PROCEDURE "informix".sp_ope_consultacomprobante_web(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera CHAR(1), pRemesadora CHAR(10), pFechaInicio DATE, pFechaFin DATE, pCveRemesa CHAR(20),
													pNumCliente CHAR(9), pRegistros INTEGER, pRecuperacion INTEGER, pFolioSuc CHAR(16), pHuella CHAR(1), cParam1 CHAR(50), cParam2 CHAR(100), 
													cParam3 CHAR(150))
    RETURNING CHAR(5)	AS codret,
	CHAR(3) AS numconvenio,
	CHAR(40) AS nomconvenio,
	CHAR(2) AS numcategoria,
	CHAR(20) AS num_cte,
	DATE AS fech_oper,
	CHAR(4) AS sucursal,
	CHAR(16) AS folio_suc,
	CHAR(40) AS referencia1,
	INTEGER AS totRegistros,
    CHAR(1) AS formaPago,
    MONEY AS importePago,
    CHAR(10) AS fechaInsert,
    CHAR(8) AS usuario,
    CHAR(16) AS folioSuc,
	CHAR(15) AS origen, 
    CHAR(20) AS numCuenta,
    CHAR(16) AS numTarjeta,
    CHAR(40) AS nomSucursal,
    CHAR(40) AS nombre1Ben,
    CHAR(40) AS nombre2Ben,
    CHAR(40) AS apPaternoBen,
    CHAR(40) AS apMaternoBen,
    CHAR(20) AS numCteBen,
    CHAR(20) AS numcliente,
	CHAR(10) AS telefono, 
    CHAR(942) AS cadenaTran,
    CHAR(3) AS plaza,
    CHAR(40) AS nomPlaza,
	VARCHAR(250) AS dirCompleta,
	CHAR(100) AS nomCliente,
	CHAR(50) AS retorno1,
	CHAR(100) AS retorno2,
	CHAR(150) AS retorno3;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTotalReg INTEGER;
	DEFINE cNumconvenio CHAR(3);
	DEFINE cNomconvenio CHAR(40);
	DEFINE cNumcategoria CHAR(2);
	DEFINE cNum_cte CHAR(20);
	DEFINE dFech_oper DATE;
	DEFINE cSucursal CHAR(4);
	DEFINE cFolio_suc CHAR(16);
	DEFINE cReferencia1 CHAR(40);
	DEFINE iTotRegistros INTEGER;
    DEFINE cFormaPago CHAR(1);
    DEFINE mImportePago MONEY;
    DEFINE cFechaInsert CHAR(10);
    DEFINE cUsuario CHAR(8);
    DEFINE cFolioSuc CHAR(16);
	DEFINE cOrigen CHAR(10); 
    DEFINE cNombre1Ben CHAR(40);
    DEFINE cNombre2Ben CHAR(40);
    DEFINE cApPaternoBen CHAR(40);
    DEFINE cApMaternoBen CHAR(40);
    DEFINE cNumCteBen CHAR(20);
    DEFINE cNumcliente CHAR(20);
	DEFINE cTelefono CHAR(10); 
    DEFINE cCadenaTran CHAR(942);
    DEFINE cNomSucursal CHAR(40);
    DEFINE cPlaza CHAR(3);
    DEFINE cNomPlaza CHAR(40);
    DEFINE cNumcuenta CHAR(20);
    DEFINE cNumTarjeta CHAR(16);
	DEFINE cDirCompleta VARCHAR(250);
	DEFINE cNomCliente CHAR(100);
	DEFINE cRetorno1 CHAR(50);
	DEFINE cRetorno2 CHAR(100);
	DEFINE cRetorno3 CHAR(150);

	LET cCodRet			= '00000';
	LET iSqlErr			= 0;
	LET iTotalReg = 0;
	
	LET cNumconvenio = '';
	LET cNomconvenio = '';
	LET cNumcategoria = '';
	LET cNum_cte = '';
	LET dFech_oper = '';
	LET cSucursal = '';
	LET cFolio_suc = '';
	LET cReferencia1 = '';
	LET iTotRegistros = 0;
	
    LET cFormaPago = '';
    LET mImportePago = 0;
    LET cFechaInsert = '';
    LET cUsuario = '';
    LET cFolioSuc = '';
	LET cOrigen = ''; 
    LET cNombre1Ben = '';
    LET cNombre2Ben = '';
    LET cApPaternoBen = '';
    LET cApMaternoBen = '';
    LET cNumCteBen = '';
    LET cNumcliente = '';
	LET cTelefono = ''; 
    LET cCadenaTran = '';
    LET cNomSucursal = '';
    LET cPlaza = '';
    LET cNomPlaza = '';
    LET cNumcuenta = '';
    LET cNumTarjeta = '';
	LET cDirCompleta = '';
	LET cNomCliente = '';
	LET cRetorno1 = '';
	LET cRetorno2 = '';
	LET cRetorno3 = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;			
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNumcategoria, cNum_cte, dFech_oper, cSucursal, cFolio_suc,  cReferencia1, iTotRegistros, cFormaPago,
			mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cNomSucursal, cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran,
			cPlaza, cNomPlaza, cDirCompleta, cNomCliente, cRetorno1, cRetorno2, cRetorno3;
			
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultacomprobante.out';
		--TRACE ON;

		IF pBandera = '' THEN	
			LET cCodRet = '00003';
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNumcategoria, cNum_cte, dFech_oper, cSucursal, cFolio_suc,  cReferencia1, iTotRegistros, cFormaPago,
			mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cNomSucursal, cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran,
			cPlaza, cNomPlaza, cDirCompleta, cNomCliente, cRetorno1, cRetorno2, cRetorno3;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--Realiza la consulta para el llenado del combo
		IF pBandera = '1' THEN 
		FOREACH 
		
			EXECUTE PROCEDURE bdicnweb:"informix".sp_tk_consultaremesadoras(pUsuario, pIdFuncion) 
			INTO cCodRet, cNumconvenio, cNomconvenio, cNumcategoria
							
			LET iTotalReg = iTotalReg + 1;
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNumcategoria, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, iTotRegistros, cFormaPago,
			mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cNomSucursal, cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran,
			cPlaza, cNomPlaza, cDirCompleta, cNomCliente, cRetorno1, cRetorno2, cRetorno3 WITH RESUME;
			
		END FOREACH;

		IF iTotalReg = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNumcategoria, cNum_cte, dFech_oper, cSucursal, cFolio_suc,  cReferencia1, iTotRegistros, cFormaPago,
			mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cNomSucursal, cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran,
			cPlaza, cNomPlaza, cDirCompleta, cNomCliente, cRetorno1, cRetorno2, cRetorno3;
		END IF;
		
		--Reliza la consulta para obtener datos para el llenado del grid
		ELIF pBandera = '2' THEN
			FOREACH 
			EXECUTE PROCEDURE sp_ope_consmovimientos_web(pUsuario, pIdFuncion, pRemesadora, pFechaInicio, pFechaFin, pCveRemesa, pNumCliente, pRegistros, pRecuperacion) 
			INTO cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario
				
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNumcategoria, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, iTotRegistros, cFormaPago,
			mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cNomSucursal, cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran,
			cPlaza, cNomPlaza, cDirCompleta, cNomCliente, cRetorno1, cRetorno2, cRetorno3 WITH RESUME;
		END FOREACH;
		
		ELIF pBandera = '4' THEN -- Formato Abono Ventanilla 

			EXECUTE PROCEDURE bdicnweb:"informix".sp_ope_cons_ticketAbonoVent_web(pUsuario, pIdFuncion, pCveRemesa, pHuella, pNumCliente) 
			INTO cCodRet, cNumconvenio, cNomconvenio, dFech_oper, cReferencia1, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolio_suc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal,
			cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno2, cRetorno3;
			
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNumcategoria, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, iTotRegistros, cFormaPago,
			mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cNomSucursal, cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran,
			cPlaza, cNomPlaza, cDirCompleta, cNomCliente, cRetorno1, cRetorno2, cRetorno3;
		
		ELIF pBandera = '5' THEN -- Formato Efectivo Ventanilla

			EXECUTE PROCEDURE bdicnweb:"informix".sp_ope_cons_ticketEfectivoVent_web(pUsuario, pIdFuncion, pCveRemesa, pHuella) 
			INTO cCodRet, cNumconvenio, cNomconvenio, dFech_oper, cReferencia1, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolio_suc, cOrigen, cSucursal, cNomSucursal,
			cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cNumcuenta, cNumTarjeta, cRetorno2, cRetorno3;

			RETURN cCodRet, cNumconvenio, cNomconvenio, cNumcategoria, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, iTotRegistros, cFormaPago,
			mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cNomSucursal, cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran,
			cPlaza, cNomPlaza, cDirCompleta, cNomCliente, cRetorno1, cRetorno2, cRetorno3;
			
		ELIF pBandera = '6' THEN -- Formato Abono APP 
		
			EXECUTE PROCEDURE bdicnweb:"informix".sp_ope_cons_ticketAbonoApp_web(pUsuario, pIdFuncion, pCveRemesa, pFolioSuc, pHuella, pNumCliente) 
			INTO cCodRet, cNumconvenio, cNomconvenio, dFech_oper, cReferencia1, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolio_suc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal,
			cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno2, cRetorno3;
			
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNumcategoria, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, iTotRegistros, cFormaPago,
			mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cNomSucursal, cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran,
			cPlaza, cNomPlaza, cDirCompleta, cNomCliente, cRetorno1, cRetorno2, cRetorno3;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: FG',
'FECHA: 29/07/2024',
'MODULO: Ticket Digital',
'FUNCIONALIDAD: Ticket Digital - Consulta Comprobante',
'DESCRIPCION: SPL Maestro encargado de ejecutar los procedimientos para la funcionalidad consulta comprobante de ticket digital';

CREATE PROCEDURE "informix".sp_ope_reversodetallechequecodigo40(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(50))
		RETURNING CHAR(5) AS codret;

		DEFINE cCodRet 			CHAR(5);
		DEFINE iSqlErr 			INTEGER;
		DEFINE dFechaHoy 		DATE;
		DEFINE cFechaAlta 		CHAR(10);
		DEFINE cNumCuenta 		CHAR(20);
		DEFINE cNumCheque 		CHAR(20);
		DEFINE icodSeguridad 	INTEGER;
		
		LET cCodRet 		= '00000';
		LET iSqlErr 		= 0;
		LET dFechaHoy 		= '';
		LET cFechaAlta 		= '';
		LET cNumCheque 		= '';
		LET cNumCuenta 		= '';
		LET icodSeguridad 	= 0;

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_ope_reversodetallechequecodigo40.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
            END IF;

			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN				
				RETURN cCodRet;
			END IF;

            
            SELECT fecha_hoy, TO_CHAR(fecha_hoy, "%Y%m%d") 
			INTO dFechaHoy, cFechaAlta
			FROM bdicheq:'informix'.sc_fechas
			WHERE empresa = '001';

			FOREACH 
				SELECT numcuenta, numcheque, cce.codseguridad 
				INTO cNumCuenta, cNumCheque, icodSeguridad
				FROM bditef:cce_cheques_det  cce 
				INNER JOIN bdicnweb:sw_cc_consultadetallecheque40 sw
				ON cce.numcheque = sw.num_cheque 
				AND cce.codseguridad = sw.chq_cod_seguridad
				AND cce.numcuenta = sw.cuenta_referencia
				WHERE fechapresenta = dFechaHoy
				AND cce.presentado = '1'
				AND sw.ejecutivo = pUsuario


				--Revertimos el codigo de presentado
				UPDATE bditef:cce_cheques_det SET presentado = "0" 
				WHERE fechapresenta = dFechaHoy
				AND numcuenta = cNumCuenta
				AND numcheque = cNumCheque
				AND codseguridad = icodSeguridad;
			
			END FOREACH;

			IF cFechaAlta <> '' OR cFechaAlta IS NOT NULL THEN 

				IF EXISTS (SELECT 1 FROM bditef:cce_gransumario where fecha = cFechaAlta AND nombrearchivo = pNombreArchivo) THEN 
					DELETE FROM bditef:cce_gransumario where fecha = cFechaAlta AND nombrearchivo = pNombreArchivo;
				END IF;

				IF pNombreArchivo IS NOT NULL OR pNombreArchivo <> '' THEN
					DELETE FROM bditef:cce_sumario where nombrearchivo = TRIM(pNombreArchivo);

					DELETE FROM bditef:cce_encabezado WHERE fecha_alta = dFechaHoy AND nombrearchivo = TRIM(pNombreArchivo);

				END IF

				IF EXISTS (SELECT 1 FROM bditef:cce_detalle where fecha_presini = cFechaAlta AND nombrearchivo = TRIM(pNombreArchivo)) THEN
					DELETE FROM bditef:cce_detalle where fecha_presini = cFechaAlta AND nombrearchivo = TRIM(pNombreArchivo);
				END IF;

			END IF;

            RETURN cCodRet;

		END;
	
END PROCEDURE 
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 26/07/2024',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Generador de Archivos', 
'DESCRIPCION: SPL encargado de realizar el Reverso a la funcionalidad del codigo 40 en caso de un error inesperado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultadetallechequecodigo40_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pDireccionMac CHAR(18))
		RETURNING CHAR(5) AS codret,
			INTEGER AS num_registros,
			INTEGER AS doc_incompletos,
			MONEY(16,2) AS monto_total_invalido,
			INTEGER AS total_validos,
			MONEY(16,2) AS monto_total_valido,
			INTEGER AS noImagenesDesc;

		DEFINE cCodRet CHAR(5);
		DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
		DEFINE iSqlErr INTEGER;
		DEFINE dFechaHoy DATE;
		DEFINE dMontoImagen DECIMAL(16,2);
		DEFINE cEmpresa CHAR(3);
		DEFINE cCveBanco CHAR(3);
		DEFINE cDescBanco CHAR(40);
		DEFINE cCtaReferencia CHAR(40);
		DEFINE iNumCheque INTEGER;
		DEFINE mImporte MONEY(14,2);
		DEFINE cCuentaDeposito CHAR(20);
		DEFINE cSucursal CHAR(44);
		DEFINE cNoTransaccion CHAR(4);
		DEFINE cChqCompensacion CHAR(3);
		DEFINE cChqTransaccion CHAR(2);
		DEFINE cChqCodSeguridad CHAR(3);
		DEFINE cChqDigVerPre CHAR(1);
		DEFINE cChqDigVerInter CHAR(1);
		DEFINE iTamImgChqAnverso INTEGER;
		DEFINE iTamImgChqReverso INTEGER;
		DEFINE cIsImagenCheque CHAR(1);
		DEFINE cTipoCuentaDep CHAR(2);
		DEFINE cCampoCliente CHAR(20);
		DEFINE cCampoCuenta CHAR(20);
		DEFINE cTablaClientes CHAR(30);
		DEFINE cNoCliente CHAR(20);
		DEFINE cNombreCte CHAR(60);
		DEFINE cRfcCte CHAR(13);
		DEFINE cCurpCte CHAR(20);
		DEFINE cChequeProcesado CHAR(1);
		DEFINE iIdNoCheque INTEGER;
		DEFINE bIsChequeDuplicado BOOLEAN;
		
		DEFINE iNoRegistros INTEGER;
		DEFINE iNoImagenes INTEGER;
		DEFINE iNoChequesValidos INTEGER;
		DEFINE iNoDocsIncompletos INTEGER;
		DEFINE mMontoTotalValido MONEY(16,2);
		DEFINE mMontoTotalInvalido MONEY(16,2);
		DEFINE cStatusProceso CHAR(1);
		
		DEFINE bImagenF BLOB;
		DEFINE bImagenT BLOB;
		DEFINE cImagenFormatoT CHAR(3);
		DEFINE cImagenFormatoF CHAR(3);
		
		
		LET cCodRet = '00000';
		LET cCodRetSp = '';
		LET iCodRetSp = 0;
		LET iSqlErr = 0;
		LET dFechaHoy = NULL;
		LET dMontoImagen = 0;
		LET cEmpresa = '001';
		LET cCveBanco = '';
		LET cDescBanco = '';
		LET cCtaReferencia = '';
		LET iNumCheque = 0;
		LET mImporte = 0;
		LET cCuentaDeposito = '';
		LET cSucursal = '';
		LET cNoTransaccion = '';
		LET cChqCompensacion = '';
		LET cChqTransaccion = '';
		LET cChqCodSeguridad = '';
		LET cChqDigVerPre = '';
		LET cChqDigVerInter = '';
		LET iTamImgChqAnverso = 0;
		LET iTamImgChqReverso = 0;
		LET cIsImagenCheque = '';
		LET cTipoCuentaDep = '';
		LET cCampoCliente = '';
		LET cCampoCuenta = '';
		LET cTablaClientes = '';
		LET cNoCliente = '';
		LET cNombreCte = '';
		LET cRfcCte = '';
		LET cCurpCte = '';
		LET cChequeProcesado = '';
		LET iNoRegistros = 0;
		LET iNoImagenes = 0;
		LET iNoChequesValidos = 0;
		LET iNoDocsIncompletos = 0;
		LET mMontoTotalValido = 0.0;
		LET mMontoTotalInvalido = 0.0;
		LET cStatusProceso = '';
		LET iIdNoCheque = 0;
		LET bIsChequeDuplicado = 'f';
		LET bImagenF = NULL;
		LET bImagenT = NULL;
		LET cImagenFormatoT = '';
		LET cImagenFormatoF = '';
		
		
		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, 0, 0, 0, 0, 0, 0;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultadetallechequecodigo40_totales.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pDireccionMac = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, 0, 0, 0, 0, 0, 0;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN				
				RETURN cCodRet, 0, 0, 0, 0, 0, 0;
			END IF;
			
			--Consulta fecha
			SELECT fecha_hoy 
			INTO dFechaHoy
			FROM bdicheq:'informix'.sc_fechas
			WHERE empresa = cEmpresa;
			
			
			IF dFechaHoy IS NULL THEN
				LET cCodRet = '00533'; --EL PARÃ¯Â¿Â½METRO FECHA_HOY NO SE ENCUENTRA EN LA TABLA SC_FECHA				
				RETURN cCodRet, 0, 0, 0, 0, 0, 0;
			END IF;			
			
			-- VALOR IMPORTE PARA ENVIO DE IMAGEN A CECOBAN
			SELECT valor::DECIMAL(16,2)
			INTO dMontoImagen
			FROM bditef:'informix'.cce_param 
			WHERE empresa = '001' AND cod_param = '2'; 
		
			IF dMontoImagen IS NULL THEN
				LET cCodRet = '00530'; --EL IMPORTE MÃ¯Â¿Â½XIMO DE CECOBAN NO EXISTE				
				RETURN cCodRet, 0, 0, 0, 0, 0, 0;
			END IF;	
			
			-- LIMPIAMOS TABLA
			DELETE FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40 
			WHERE ejecutivo = pUsuario AND direccion_mac = pDireccionMac;
			
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			
			
			LET iNoImagenes = 0;
			-- SE CONSULTAN LOS CHEQUES PARA ENVIAR (CODIGO 40)
			FOREACH SELECT cod_ret::integer, cve_banco, desc_banco, cuenta_referencia AS cuenta_referencia, num_cheque, monto_orig, cuenta_deposito, sucursal, transaccion
					INTO iCodRetSp, cCveBanco, cDescBanco, cCtaReferencia, iNumCheque, mImporte, cCuentaDeposito, cSucursal, cNoTransaccion
					FROM TABLE(PROCEDURE bdicheq:'informix'.sp_cce_consultar_cheques40(cEmpresa, dFechaHoy)) 
						AS sc_cce_presentada(cod_ret, cve_banco, desc_banco, cuenta_referencia, num_cheque, monto_orig, cuenta_deposito, sucursal, transaccion)
					
					-- VALIDACIÃ¯Â¿Â½N DE LOS CODIGOS DE RETORNO
					IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicheq:sp_cce_consultar_cheques40';
					ELIF iCodRetSp = 1 THEN
						LET cCodRet = '00003';
						RETURN cCodRet, 0, 0, 0, 0, 0, 0;
					END IF;
					
					LET cChequeProcesado = '0';
					LET cIsImagenCheque = '2';
					
					-- SE CONSULTA EL DETALLE DE L0S CHEQUES
					FOREACH SELECT cod_ret::INTEGER AS codret, compensacion, transaccion, cod_seguridad, digverpre, digverinter
							INTO iCodRetSp, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, cChqDigVerInter
							FROM TABLE (PROCEDURE bditef:'informix'.sp_cce_consultar_detallecheques(cEmpresa, cCveBanco, cCtaReferencia, iNumCheque))
							AS detalle_cheque(cod_ret, compensacion, transaccion, cod_seguridad, digverpre, digverinter)
							
							-- VALIDACIÃ¯Â¿Â½N DE CODIGO DE RETORNO
							
							LET cChequeProcesado = '1';
							LET cIsImagenCheque = '2';
							
							
							LET iTamImgChqAnverso = NULL;
							LET iTamImgChqReverso = NULL;
							LET bImagenF= NULL;
							LET cImagenFormatoF = NULL;
							LET bImagenT = NULL;
							LET cImagenFormatoT = NULL;
							
							-- VALIDACIÃ¯Â¿Â½N DEL MONTO DEL CHEQUE
							IF mImporte > dMontoImagen THEN
								--LET iNoImagenes = iNoImagenes + 2;
								-- SE CONSULTA EL TAMAÃ¯Â¿Â½O DEL ANVERSO DEL CHEQUE
								SELECT FIRST 1 imagen_tam, imagen, imagen_formato
								INTO iTamImgChqAnverso, bImagenF ,cImagenFormatoF
								FROM (
								SELECT imagen_tam, imagen, imagen_formato
								FROM bditef:'informix'.cce_cheques_img
								WHERE empresa = cEmpresa
									AND cvebanco = cCveBanco
									AND numcuenta = cCtaReferencia
									AND numcheque = iNumCheque
									--AND fechapresenta = TO_DATE("05-01-2023", "%m-%d-%Y")
									AND fechapresenta = dFechaHoy
									AND lado_ft in ('F','A')
									ORDER BY imagen_tam ASC);
									
								IF iTamImgChqAnverso IS NOT NULL THEN
									-- SE CONSULTA EL TAMAÃ¯Â¿Â½O DEL REVERSO DEL CHEQUE
									SELECT FIRST 1 imagen_tam, imagen, imagen_formato
									INTO iTamImgChqReverso, bImagenT, cImagenFormatoT
									FROM (
								    SELECT imagen_tam, imagen, imagen_formato
								    FROM bditef:'informix'.cce_cheques_img
									WHERE empresa = cEmpresa
										AND cvebanco = cCveBanco
										AND numcuenta = cCtaReferencia
										AND numcheque = iNumCheque
										--AND fechapresenta = TO_DATE("05-01-2023", "%m-%d-%Y")
										AND fechapresenta = dFechaHoy
										AND lado_ft in ('T','B')
										ORDER BY imagen_tam ASC);
									
									
									LET cIsImagenCheque = '1';
								ELSE
									LET cIsImagenCheque = '0';
								END IF;
	
							END IF;
							
							-- CONSULTAR EL NOMBRE Y EL RFC (MAPEO)
							SELECT tipo_cta_dep, campo_cliente, campo_cuenta, tabla_clientes
							INTO cTipoCuentaDep, cCampoCliente, cCampoCuenta, cTablaClientes
							FROM bditef:'informix'.cce_mapeo_cecoban
							WHERE empresa = cEmpresa
								AND transacc = cNoTransaccion;
								
							IF cTipoCuentaDep IS NULL THEN -- ERROR DE QUE NO SE ENCONTRO EL MAPEO CECOBAN
								RETURN cCodRet, 0, 0, 0, 0, 0, 0;
							END IF;
							
							SELECT FIRST 1 num_cte
							INTO cNoCliente
							FROM bdicheq:sc_maechq WHERE cuenta = TRIM(cCuentaDeposito);
							/*
							---- CONSULTA PREPARADA
							PREPARE noClienteStmt FROM 'SELECT '||TRIM(cCampoCliente)||' FROM '||TRIM(cTablaClientes)||' WHERE '||TRIM(cCampoCuenta)||" = '"||TRIM(cCuentaDeposito)||"';";
							DECLARE noClienteCur CURSOR FOR noClienteStmt;
							OPEN noClienteCur;
							FETCH noClienteCur INTO cNoCliente;
							CLOSE noClienteCur;*/
							
							SELECT cod_ret::integer, nombre, rfc, curp
							INTO iCodRetSp, cNombreCte, cRfcCte, cCurpCte
							FROM TABLE (PROCEDURE bditef:'informix'.consnomcte(cEmpresa, cNoCliente))
								AS tmp_nombre_cte(cod_ret, nombre, rfc, curp);
								
							LET cStatusProceso = 'P';
							
							IF  cIsImagenCheque = '0' THEN
								LET cStatusProceso = 'F';
							END IF;

							
							INSERT INTO bdicnweb:'informix'.sw_cc_consultadetallecheque40(banco, desc_banco, cuenta_referencia, num_cheque, importe, cuenta_deposito, sucursal_operadora, 
										chq_procesado, chq_compensacion, chq_transaccion, chq_cod_seguridad, chq_dig_ver_pre, chq_dig_ver_inter,
										transaccion, nombre_cte, rfc_cte, curp_cte, tipo_cuenta_dep, ind_img_cheque, tam_anv_img_cheque, tam_rev_img_cheque, ejecutivo, 
										direccion_mac, id_status_proceso, imagenf,imagent,imagen_formatof,imagen_formatot)
							VALUES(cCveBanco, cDescBanco, cCtaReferencia, iNumCheque, mImporte, cCuentaDeposito, cSucursal, cChequeProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad,
									cChqDigVerPre, cChqDigVerInter, cNoTransaccion, cNombreCte, cRfcCte, cCurpCte, cTipoCuentaDep, cIsImagenCheque, iTamImgChqAnverso, iTamImgChqReverso, pUsuario, 
									pDireccionMac, cStatusProceso, bImagenF,bImagenT,cImagenFormatoF,cImagenFormatoT);
					END FOREACH;
					
					/*FREE noClienteCur;
					FREE noClienteStmt;*/
					
					IF cChequeProcesado = '0' THEN
						LET cStatusProceso = 'C';
						INSERT INTO bdicnweb:'informix'.sw_cc_consultadetallecheque40(banco, desc_banco, cuenta_referencia, num_cheque, importe, cuenta_deposito, sucursal_operadora, 
										chq_procesado, chq_compensacion, chq_transaccion, chq_cod_seguridad, chq_dig_ver_pre, chq_dig_ver_inter,
										transaccion, nombre_cte, rfc_cte, curp_cte, tipo_cuenta_dep, ind_img_cheque, tam_anv_img_cheque, tam_rev_img_cheque, 
										ejecutivo, direccion_mac, id_status_proceso, imagenf,imagent,imagen_formatof,imagen_formatot)
						VALUES(cCveBanco, cDescBanco, cCtaReferencia, iNumCheque, mImporte, cCuentaDeposito, cSucursal, cChequeProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad,
								cChqDigVerPre, cChqDigVerInter, cNoTransaccion, cNombreCte, cRfcCte, cCurpCte, cTipoCuentaDep, cIsImagenCheque, iTamImgChqAnverso, iTamImgChqReverso, pUsuario, 
								pDireccionMac, cStatusProceso, bImagenF,bImagenT,cImagenFormatoF,cImagenFormatoT);
					END IF;
		
			END FOREACH;
			
			-- VALIDACION DE CHEQUE DUPLICADO
			FOREACH SELECT id_consultadetallecheque40
					INTO iIdNoCheque
					FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
					WHERE ejecutivo = pUsuario
					AND direccion_mac = pDireccionMac
					AND chq_procesado = '1'
					AND ind_img_cheque IN ('1', '2')
				
				EXECUTE PROCEDURE bdicnweb:"informix".sp_ope_chequeduplicado(pUsuario, pIdFuncion, iIdNoCheque, dFechaHoy, '40') INTO cCodRetSp, bIsChequeDuplicado;
				
				LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicnweb:"informix".sp_ope_chequeduplicado';
				END IF;
				
				IF iCodRetSp = 0 THEN
					UPDATE {+AVOID_FULL(bdicnweb:"informix".sw_cc_consultadetallecheque40)} bdicnweb:'informix'.sw_cc_consultadetallecheque40
					SET ind_duplicado = DECODE(bIsChequeDuplicado, 'f', '0', 't', '1')
					WHERE id_consultadetallecheque40 = iIdNoCheque;
				END IF;
			END FOREACH
			
			
			
			-- NUMERO TOTAL DE REGISTROS
			SELECT COUNT(*)
			INTO iNoRegistros
			FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
			WHERE ejecutivo = pUsuario
				AND direccion_mac = pDireccionMac;
				
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, 0, 0, 0, 0, 0, 0;
			END IF;
			
			-- NUMERO TOTAL DE IMAGENES
			--SELECT SUM(ind_img_cheque::integer)
			SELECT COUNT(ind_img_cheque)
			INTO iNoImagenes
			FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
			WHERE ejecutivo = pUsuario
			AND direccion_mac = pDireccionMac
			AND ind_img_cheque = '1';			
			LET iNoImagenes = iNoImagenes * 2;	
				
			-- CHEQUES VALIDOS
			SELECT COUNT(*)
			INTO iNoChequesValidos
			FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
			WHERE ejecutivo = pUsuario
				AND direccion_mac = pDireccionMac
				AND chq_procesado = '1';
				
			LET iNoDocsIncompletos = iNoRegistros - iNoChequesValidos;
			
			-- MONTO TOTAL VALIDO
			SELECT SUM(importe)
			INTO mMontoTotalValido
			FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
			WHERE ejecutivo = pUsuario
				AND direccion_mac = pDireccionMac
				AND chq_procesado = '1';
			
			-- MONTO TOTAL INVALIDO
			SELECT SUM(importe)
			INTO mMontoTotalInvalido
			FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
			WHERE ejecutivo = pUsuario
				AND direccion_mac = pDireccionMac
				AND chq_procesado = '0';
			
			RETURN cCodRet, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes;
			
		END;
	
END PROCEDURE 
DOCUMENT 'AUTOR: Saul Ortiz Baeza',
'FECHA: 11/01/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Generador de Archivos', 
'DESCRIPCION: SPL que se encarga de obtener el nÃ¯Â¿Â½mero total de registros correspondientes a los cheques de cÃ¯Â¿Â½digo 40.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_chequeduplicado(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdCheque INTEGER, pFecha DATE, pCodigo CHAR(2))
		RETURNING CHAR(5) AS codret,
				BOOLEAN AS esta_duplicado;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE bIsChequeDuplicado BOOLEAN;
	DEFINE iChequeDuplicado SMALLINT;
	DEFINE cEmpresa CHAR(3);
	DEFINE cCveBanco CHAR(3);
	DEFINE cCuentaReferencia CHAR(20);
	DEFINE iNumCheque INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET bIsChequeDuplicado = 'f';
	LET iChequeDuplicado = 0;
	LET cEmpresa = '001';
	LET cCveBanco = '';
	LET cCuentaReferencia = '';
	LET iNumCheque = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, bIsChequeDuplicado;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_chequeduplicado.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdCheque IS NULL OR pFecha IS NULL OR pCodigo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, bIsChequeDuplicado;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, bIsChequeDuplicado;
		END IF;
		
		IF pCodigo NOT IN ('40', '41', '46', '47') THEN
			LET cCodRet = '00003'; -- PARAMETRO INCORRECTO (CAMBIAR)
			RETURN cCodRet, bIsChequeDuplicado;
		END IF;
		
		-- BUSCAMOS EL ID
		IF EXISTS (SELECT 1 FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40 WHERE id_consultadetallecheque40 = pIdCheque) THEN
		
			SELECT banco, cuenta_referencia, num_cheque
			INTO cCveBanco, cCuentaReferencia,iNumCheque
			FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
			WHERE id_consultadetallecheque40 = pIdCheque;
			
			-- SE BUSCA QUE NO EXISTA EL CHEQUE EN CCE_DETALLE
			SELECT COUNT(nombrearchivo)
			INTO iChequeDuplicado
			FROM bditef:'informix'.cce_detalle
			WHERE cod_operacion = pCodigo
				AND bco_receptor = cCveBanco
				AND num_cuenta = cCuentaReferencia
				AND num_cheque = iNumCheque
				AND fecha_presini = TO_CHAR(pFecha, '%Y%m%d');
				
			IF iChequeDuplicado = 0 THEN
				RETURN cCodRet, bIsChequeDuplicado;
			ELSE 
				-- SE MARCA COMO DUPLICADO
				UPDATE bditef:'informix'.cce_cheques_det
				SET presentado = '1'
				WHERE empresa = cEmpresa
					AND cvebanco = cCveBanco
					AND numcuenta = cCuentaReferencia
					AND numcheque = iNumCheque
					AND fechapresenta = pFecha;
				
				LET bIsChequeDuplicado = 't';
				RETURN cCodRet, bIsChequeDuplicado;
			END IF;
		
		ELSE
			LET cCodRet = '00002'; --EL REGISTRO QUE DESEA CONSULTAR NO EXISTE
			RETURN cCodRet, bIsChequeDuplicado;
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 15/03/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Generador de Archivos', 
'DESCRIPCION: Realiza la consulta para verificar si el cheque esta duplicado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_generarchivopresentado(pUsuario CHAR(8), pIdFuncion CHAR(10), pNoBloque INTEGER, pRutaDescarga CHAR(50), pDireccionMac CHAR(15))
	RETURNING CHAR(5) AS codret,
			  INTEGER AS totalRegTruncados,
			  CHAR(50) AS nombreArchivo;

				
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNombreArchivo CHAR(30);
	DEFINE iExistenImgsDigitalizadas INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iChequeDuplicado SMALLINT;
	DEFINE dFechaHoy DATE;
	DEFINE iBloqueInicial SMALLINT;
	DEFINE bIsChequeDuplicado BOOLEAN;
	DEFINE cTipoRegistro CHAR(2);
	DEFINE iNumeroSecuenca INTEGER;
	DEFINE cNumeroBanco CHAR(3);
	DEFINE cSentidoTransfer CHAR(1);
	DEFINE cPlazaCecoban CHAR(2);
	DEFINE cServicioTEI CHAR(1);
	DEFINE iDiaMesTransfer SMALLINT;
	DEFINE cFechaPresenta CHAR(8);
	DEFINE cUsoFuturo1 CHAR(1);
	DEFINE cTipoArchivo CHAR(1);
	DEFINE cUsoFuturo2 CHAR(1);
	DEFINE cCveBanco CHAR(3);
	DEFINE iNumCheque INTEGER;	
	DEFINE iIdConsultaDetalleCheque40 INTEGER;
	DEFINE cBanco CHAR(3);
	DEFINE cDescBanco CHAR (40);
	DEFINE cCuentaReferencia CHAR(20);
	DEFINE cNumCheque INTEGER;
	DEFINE mImporte DECIMAL(14,2);
	DEFINE cCuentaDeposito CHAR(20);
	DEFINE cSucursalOperadora CHAR(44);
	DEFINE cChqProcesado CHAR(1);
	DEFINE cChqCompensacion CHAR(3);
	DEFINE cChqTransaccion CHAR(2);
	DEFINE cChqCodSeguridad CHAR(3);
	DEFINE cChqDigVerPre CHAR(1);
	DEFINE cChqDigVerInter CHAR(1);
	DEFINE cTransaccion CHAR(4);
	DEFINE cNombreCte CHAR(60);
	DEFINE cRfcCte CHAR(13);
	DEFINE cCurpCte CHAR(20);
	DEFINE cTipoCuentaDep CHAR(2);
	DEFINE cIndImgCheque CHAR(1);
	DEFINE iTamAnvImgCheque INTEGER;
	DEFINE iTamRevImgCheque INTEGER;
	DEFINE cEjecutivo CHAR(8);
	DEFINE cDireccionMac CHAR(15);
	DEFINE cIndDuplicado CHAR(1);
	DEFINE cIdStatusProceso CHAR(1);
	DEFINE iTotalChqProcesar INTEGER;
	DEFINE cNumSecuencia CHAR(7);
	DEFINE cCodOperacion CHAR(2);
	DEFINE cFechatrasnfer CHAR(8);
	DEFINE cBancoCedente CHAR(3);
	DEFINE cBancoLibrado CHAR(3);
	DEFINE cImporte CHAR(16);
	DEFINE cMonto CHAR(13);
	DEFINE cCents CHAR(2);
	DEFINE cLoteEntrada CHAR(7);
	DEFINE cSecEntrada CHAR(4);
	DEFINE cLoteSAlida CHAR(7);
	DEFINE cSecSalida CHAR(4);
	DEFINE cUbicFis CHAR(8);
	DEFINE iTotalRegTruncados INTEGER;
	DEFINE cTruncado CHAR(1);
	DEFINE mMontoImagen DECIMAL(14,2);
	DEFINE cMotivoDevol CHAR(2);
	DEFINE cFechaInicial CHAR(8);
	DEFINE cPlazaIntercam CHAR(2);
	DEFINE cCtaAlertamiento CHAR(2);
	DEFINE cTranSBCcheque CHAR(4);
	DEFINE cCodRetTrasacc CHAR(3);
	DEFINE cCodAlertamiento CHAR(2);
	DEFINE cFolioSeguro CHAR(1);
	DEFINE cUsoFuturo CHAR(1);
	DEFINE iTotalCheques INTEGER;
	DEFINE mTotalImporte DECIMAL(20,2);
	DEFINE cTipoSumario CHAR(2);
	DEFINE cTotalRegs CHAR(7);
	DEFINE cTotalRegTruncados CHAR(7);
	DEFINE cTipoGranSumario CHAR(2);
	DEFINE cSentido CHAR(1);
	DEFINE cNumOperaciones CHAR(7);
	DEFINE cNumBloques CHAR(2);
	DEFINE cFolio CHAR(9);
	DEFINE cFecha CHAR(8);
	DEFINE cImported CHAR(15);
	DEFINE cImportes CHAR(18);
	DEFINE cMontos CHAR(16);
	DEFINE cCodExc CHAR(5);
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cNombreArchivo = '';
	LET iExistenImgsDigitalizadas = 0;
	LET iNoRegistros = 0;
	LET iChequeDuplicado = 0;
	LET dFechaHoy = NULL;
	LET iBloqueInicial = 1;
	LET bIsChequeDuplicado = 'f';	
	LET iIdConsultaDetalleCheque40 =0;
	LET cCveBanco = '';
	LET iNumCheque = 0;
	LET cBanco = '';
	LET cDescBanco = '';
	LET cCuentaReferencia = '';
	LET cNumCheque = 0;
	LET mImporte = 0.0;
	LET cCuentaDeposito = '';
	LET cSucursalOperadora = '';
	LET cChqProcesado = '';
	LET cChqCompensacion = '';
	LET cChqTransaccion = '';
	LET cChqCodSeguridad = '';
	LET cChqDigVerPre = '';
	LET cChqDigVerInter = '';
	LET cTransaccion = '';
	LET cNombreCte = '';
	LET cRfcCte = '';
	LET cCurpCte = '';
	LET cTipoCuentaDep = '';
	LET cIndImgCheque = '';
	LET iTamAnvImgCheque = 0;
	LET iTamRevImgCheque = 0;
	LET cEjecutivo = '';
	LET cDireccionMac = '';
	LET cIndDuplicado = '';
	LET cIdStatusProceso = '';
	LET iTotalChqProcesar = 0;
	LET cNumSecuencia = '';
	LET cCodOperacion = '';
	LET cFechatrasnfer = '';
	LET cBancoCedente = '';
	LET cBancoLibrado = '';
	LET cImporte = '';
	LET cMonto ='';
	LET cCents = '';
	LET cLoteEntrada ='';
	LET cSecEntrada = '';
	LET cLoteSAlida = '';
	LET cSecSalida = '';
	LET cUbicFis = '';
	LET iTotalRegTruncados = 0;
	LET cTruncado = '';
	LEt mMontoImagen = 0.0;
	LET cMotivoDevol = '';
	LET cFechaInicial = '';
	LET cPlazaIntercam = '';
	LET cCtaAlertamiento = '';
	LET cTranSBCcheque = '';
	LET cCodRetTrasacc = '';
	LET cCodAlertamiento = '';
	LET cFolioSeguro = '';
	LET cUsoFuturo = '';
	LET iTotalCheques = 0;	
	LET mTotalImporte = 0.0;
	LET cTipoSumario = '';
	LET cTotalRegs = '';
	LET cTotalRegTruncados = '';
	LET cTipoGranSumario = '';
	LET cSentido = '';
	LET cNumOperaciones = '';
	LET cNumBloques = '';
	LET cFolio = '';
	LET cFecha = '';
	LET cImported = '';
	LET cImportes = '';
	LET cMontos = '';
	LET cCodExc = '00000';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			IF (iSqlErr=-268) THEN
				--BEGIN WORK;
				EXECUTE PROCEDURE "informix".sp_ope_reversodetallechequecodigo40(pUsuario, pIdFuncion, cNombreArchivo)
				INTO cCodExc;
				COMMIT;
			END IF
			RETURN cCodRet,iTotalRegTruncados,'';
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_generarchivopresentado.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNoBloque IS NULL OR pRutaDescarga = '' OR pDireccionMac = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iTotalRegTruncados,'';
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iTotalRegTruncados,'';
		END IF;
		
		
		-- LA FECHA SE OBTIENE SE TABLA
		SELECT fecha_hoy INTO dFechaHoy from bdicheq:sc_fechas where empresa = '001';
		LET cNombreArchivo = 'PRE_'||TO_CHAR(DATE(dFechaHoy), '%d%m%Y')||'_MN_'||LPAD(pNoBloque, 2, '0');
		
		
		
		-- SE VALIDA QUE EXISTAN IMAGENES DIGITALIZADAS
		SET ISOLATION TO DIRTY READ;
		
		SELECT COUNT(ind_img_cheque)
		INTO iExistenImgsDigitalizadas
		FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
		WHERE ejecutivo = pUsuario
			AND direccion_mac = pDireccionMac
			AND ind_img_cheque = '2';
			
		IF iExistenImgsDigitalizadas = 0 THEN
			-- MANDASR MENSAJE DE QUE NO EXISTEN REGISTROS COMPLETOS
			LET iExistenImgsDigitalizadas = 0;
			SELECT COUNT(ind_img_cheque)
			INTO iExistenImgsDigitalizadas
			FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
			WHERE ejecutivo = pUsuario
				AND direccion_mac = pDireccionMac
				AND ind_img_cheque = '1';
			
			IF iExistenImgsDigitalizadas = 0 THEN
				LET cCodRet = '00780';
				RETURN cCodRet,iTotalRegTruncados,'';
			END IF;
		
		END IF;
		
		-- VALIDACIÃN DEL NUMERO DE REGISTROS
		SELECT COUNT(*)
		INTO iNoRegistros
		FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
		WHERE ejecutivo = pUsuario
			AND direccion_mac = pDireccionMac;
			
		IF iNoRegistros = 1 THEN -- SI SOLO ES UN REGISTRO, SE VALIDA QUE NO ESTE DUPLICADO
		
			SELECT banco, cuenta_referencia, num_cheque
			INTO cCveBanco, cCuentaReferencia,iNumCheque
			FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
			WHERE ejecutivo = pUsuario
				AND direccion_mac = pDireccionMac;
				
			-- SE BUSCA QUE NO EXISTA EL CHEQUE EN CCE_DETALLE
			SELECT COUNT(*)
			INTO iChequeDuplicado
			FROM bditef:'informix'.cce_detalle
			WHERE cod_operacion = '40'
				AND bco_receptor = cCveBanco
				AND num_cuenta = cCuentaReferencia
				AND num_cheque = iNumCheque
				AND fecha_presini = TO_CHAR(dFechaHoy, '%Y%m%d');
			
			IF iChequeDuplicado <> 0 THEN
				-- SE MARCA EL CHEQUE COMO PROCESADO
				UPDATE bditef:'informix'.cce_cheques_det
				SET presentado = '1'
				WHERE empresa = cEmpresa
					AND cvebanco = cCveBanco
					AND numcuenta = cCuentaReferencia
					AND numcheque = iNumCheque
					AND fecha_presenta = dFechaHoy;
					
				-- SE AJUSTA EL MONTO TOTAL DE OPERACIONES
				-- (rEVISAR SI SE HACE EN VISTA EL AJUSTE)
				
				LET cCodRet = '99999';
				RETURN cCodRet,iTotalRegTruncados,''; --ERROR DE CHEQUE DUPLICADO
			END IF;
				
		END IF;
				
		--==============================
		-- PROCESAMIENTO GRABAR ENCABEZADO
		--==============================
		LET cTipoRegistro = '01';
		LET iNumeroSecuenca = iBloqueInicial;
		
		SELECT LPAD(valor::INTEGER, 3, '0')
		INTO cNumeroBanco
		FROM bdinteg:'informix'.si_param
		WHERE empresa = cEmpresa
			AND cod_param = '5';
		
		LET cSentidoTransfer = 'E';
		LET cPlazaCecoban = '01';
		LET cServicioTEI = '1';
		LET iDiaMesTransfer = DAY(dFechaHoy);
		LET cFechaPresenta = TO_CHAR(dFechaHoy, '%Y%m%d');
		LET cUsoFuturo1 = ' ';
		LET cTipoArchivo = '0'; -- 0 = Archivo real, 1 = Archivo de prueba
		LET cUsoFuturo2 = ' ';
		
		-- ESCRITURA DE LA CADENA DE TEXTO EN UN ARCHIVO
		SYSTEM 'echo "'||cTipoRegistro||LPAD(iNumeroSecuenca, 7, '0')||LPAD(cNumeroBanco,3,'0')||cSentidoTransfer||cPlazaCecoban||
		cServicioTEI||LPAD(iDiaMesTransfer, 2, '0')||LPAD(pNoBloque, 5, '0')||cFechaPresenta||LPAD(cUsoFuturo1,9,' ')||cTipoArchivo||
		LPAD(cUsoFuturo2,302,' ')||'" > '||TRIM(pRutaDescarga)||TRIM(cNombreArchivo)||'.cce';
		
		-- GRABADO EN BASE DEL ENCABEZADO

        INSERT INTO bditef:cce_encabezado (nombrearchivo, tipo_registro, num_secuencia, num_banco, sentido, plaza_cce, servicio_tei, dia_transferencia, num_bloque, fecha_presenta, tipo_archivo, procesado, usuario_alta, fecha_alta) 
        VALUES (cNombreArchivo, cTipoRegistro, LPAD(iNumeroSecuenca, 7, '0'), 
		cNumeroBanco, cSentidoTransfer, cPlazaCecoban, cServicioTEI, LPAD(iDiaMesTransfer, 2, '0'), LPAD(pNoBloque, 5, '0'),
		cFechaPresenta, cTipoArchivo, "1", pUsuario, dFechaHoy);

		--==============================
		-- PROCESAMIENTO DEL DETALLE
		--==============================		
		SELECT  valor INTO cBancoCedente FROM bdinteg:si_param WHERE empresa = cEmpresa AND cod_param ='5';
		SELECT valor INTO mMontoImagen  FROM bditef:cce_param WHERE empresa = cEmpresa AND cod_param = '2';	
		LET iTotalChqProcesar = 1;
		FOREACH SELECT id_consultadetallecheque40, banco, desc_banco, cuenta_referencia, num_cheque, importe, cuenta_deposito, sucursal_operadora, chq_procesado, chq_compensacion,
				chq_transaccion, chq_cod_seguridad, chq_dig_ver_pre, chq_dig_ver_inter, transaccion, nombre_cte, rfc_cte,curp_cte,tipo_cuenta_dep, ind_img_cheque, tam_anv_img_cheque,
				tam_rev_img_cheque, ejecutivo,direccion_mac,ind_duplicado,id_status_proceso 
				INTO iIdConsultaDetalleCheque40,cBanco,cDescBanco,cCuentaReferencia, cNumCheque,mImporte,cCuentaDeposito,cSucursalOperadora,cChqProcesado,cChqCompensacion,
				cChqTransaccion,cChqCodSeguridad,cChqDigVerPre,cChqDigVerInter,cTransaccion,cNombreCte,cRfcCte,cCurpCte,cTipoCuentaDep,cIndImgCheque,iTamAnvImgCheque,iTamRevImgCheque,
				cEjecutivo,cDireccionMac,cIndDuplicado,cIdStatusProceso
				FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
				WHERE ejecutivo = pUsuario
				AND direccion_mac = pDireccionMac
				--AND chq_procesado = '1'
				
				IF cIdStatusProceso = 'P' OR cIdStatusProceso = 'R'  THEN
					
				 SELECT COUNT(cNombreArchivo)
					INTO iChequeDuplicado
					FROM bditef:'informix'.cce_detalle
					WHERE cod_operacion = '40'
							AND bco_receptor = cBanco
							AND num_cuenta = cCuentaReferencia
							AND num_cheque = cNumCheque
							AND fecha_presini = TO_CHAR(DATE(dFechaHoy), '%Y%m%d');
									
									
					IF iChequeDuplicado > 0 THEN
							LET cIndDuplicado= '1';
					END IF;
					
					IF cIndDuplicado = '1' THEN
						
						UPDATE {+AVOID_FULL(bdicnweb:"informix".sw_cc_consultadetallecheque40)}
						bdicnweb:'informix'.sw_cc_consultadetallecheque40
						SET (ind_img_cheque,ind_duplicado)=('3','1')
						WHERE id_consultadetallecheque40 = iIdConsultaDetalleCheque40;
						
					ELSE			
						LET cTipoRegistro='02';
						LET cCodOperacion = '40';
						LET cNumSecuencia = LPAD(TO_CHAR(iBloqueInicial + iTotalChqProcesar),7,'0');											
						LET cFechatrasnfer = TO_CHAR(DATE(dFechaHoy), '%Y%m%d');						
						LET cBancoCedente = LPAD(TRIM(cBancoCedente),3,'0');
						LET cBancoLibrado = LPAD(TRIM(cBanco),3,'0');
						
						-- formateo importe
						LET cImported = '';
						LET cImported = TO_CHAR(mImporte);
						LET cMonto = substr(cImported, 1, CHARINDEX('.', cImported) - 1);
						LET cMonto = LPAD(TRIM(cMonto),13,'0');
						LET cCents = substr(cImported, CHARINDEX('.', cImported) + 1);
						LET cImported = TRIM(cMonto || LPAD(TRIM(cCents),2,'0'));
						
						
						LET cLoteEntrada ='0000000';
						LET cSecEntrada = '0000';
						LET cLoteSAlida = '0000000';
						LET cSecSalida = '0000';
						LET cUbicFis = '00000000';											
						
						IF mImporte > mMontoImagen THEN
							LET cTruncado = '0';
							LET iTotalRegTruncados = iTotalRegTruncados + 1;
						ELSE
							LET cTruncado = '1';
						END IF;
						
						LET cMotivoDevol = '00'; -- fase de presentacion
						LET cFechaInicial = TO_CHAR(DATE(dFechaHoy), '%Y%m%d');
						LET cPlazaIntercam = '01'; -- mexico df
						
						IF cRfcCte IS NULL OR  TRIM(cRfcCte) = '' THEN
							LET cRfcCte = 'RFC NO DISP';
						ELSE	
							LET cRfcCte = TRIM(cRfcCte);
						END IF;
						
						IF TRIM(cCurpCte) = '' OR cCurpCte IS NULL THEN
							LET cCurpCte = ' ';
						ELSE
							LET cCurpCte = TRIM(cCurpCte);
						END IF;
						
						LET cCtaAlertamiento = '00';
						
						SELECT numero INTO cTranSBCcheque FROM bdinteg:si_transacc where empresa= cEmpresa and abreviatura = 'DEPLOCALREGCC';
						
						IF cTransaccion <> 	cTranSBCcheque THEN
							LET cCtaAlertamiento = '99';
						ELSE
							EXECUTE PROCEDURE bditef:cta_alertamiento(cEmpresa, cCuentaDeposito) INTO cCodRetTrasacc, cCodAlertamiento;
							
							IF cCodRetTrasacc = '000' THEN
								LET cCtaAlertamiento = cCodAlertamiento;
							END IF;
							
						END IF;
						
						LET cFolioSeguro = ' ';
						LET cUsoFuturo = ' ';
						
						
						-- ESCRITURA DE LA CADENA DE TEXTO EN EL ARCHIVO
						SYSTEM 'echo "'||cTipoRegistro||cNumSecuencia||cCodOperacion||cFechatrasnfer||cBancoCedente||cBancoLibrado||cImported||
										cLoteEntrada||cSecEntrada||cLoteSAlida||cSecSalida||LPAD(cChqTransaccion,2,'0')||LPAD(TRIM(NVL(cChqCompensacion,'')),3,'0')||
										LPAD(TRIM(NVL(cCuentaReferencia,'')),13,'0')||LPAD(TRIM(NVL(cNumCheque,'')),10,'0')||LPAD(cChqDigVerInter,1,'0')||LPAD(cChqDigVerPre,1,'0')||
										LPAD(TRIM(NVL(cChqCodSeguridad,'')),3,'0')||cUbicFis||cTruncado||cMotivoDevol||cFechaInicial||cPlazaIntercam||LPAD(cRfcCte,13,' ')||
										LPAD(cCurpCte,18,' ')||LPAD(cTipoCuentaDep,2,'0')||LPAD(TRIM(NVL(cCuentaDeposito,'')),20,'0')||LPAD(cNombreCte,40,' ')||cCtaAlertamiento||
										LPAD(cFolioSeguro,12,' ')||LPAD(cUsoFuturo,120,' ')||'" >> '||TRIM(pRutaDescarga)||TRIM(cNombreArchivo)||'.cce';
										
						
					
						LET iTotalCheques = iTotalCheques + 1;	
						LET mTotalImporte = mTotalImporte + mImporte;

						
						-- GRABADO EN BASE DEL DETALLE
						EXECUTE PROCEDURE bditef:sp_cce_guardar_detalle(cNombreArchivo,cTipoRegistro,cNumSecuencia,cCodOperacion,cFechatrasnfer,
						cBancoCedente,cBancoLibrado,mImporte,cLoteEntrada,cSecEntrada,cLoteSAlida,cSecSalida,LPAD(cChqTransaccion,2,'0'),LPAD(cChqCompensacion,3,'0'),
						LPAD(cCuentaReferencia,13,'0'),LPAD(cNumCheque,10,'0'),LPAD(cChqDigVerInter,1,'0'),LPAD(cChqDigVerPre,1,'0'),LPAD(cChqCodSeguridad,3,'0'),
						cUbicFis,cTruncado,cMotivoDevol,cFechaInicial,cPlazaIntercam,cRfcCte,cCurpCte,LPAD(cTipoCuentaDep,2,'0'),
						cCuentaDeposito,cNombreCte,cCtaAlertamiento,cFolioSeguro) INTO cCodRetSp;
						
						LET iCodRetSp = cCodRetSp::INTEGER;
						IF iCodRetSp < 0 THEN
							RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:sp_cce_guardar_detalle';
						END IF;
						
						UPDATE bditef:cce_cheques_det 
						SET presentado = '1'
						WHERE empresa = cEmpresa AND
						cvebanco = cBanco AND
						numcheque = cNumCheque AND
						numcuenta = cCuentaReferencia AND
						fechapresenta = dFechaHoy; --TO_CHAR(DATE(dFechaHoy), 'MM/dd/YYYY');
						
						UPDATE {+AVOID_FULL(bdicnweb:"informix".sw_cc_consultadetallecheque40)}
						bdicnweb:'informix'.sw_cc_consultadetallecheque40
						SET chq_procesado='2'
						WHERE id_consultadetallecheque40 = iIdConsultaDetalleCheque40;
						
						LET iTotalChqProcesar = iTotalChqProcesar + 1;
					END IF;
				END IF;
					LET cIndDuplicado= '0';
		END FOREACH;
		
		
		--==============================
		-- PROCESAMIENTO CCE SUMARIO
		--==============================
		LET cTipoSumario = '09';
		LET cNumSecuencia = LPAD(TO_CHAR(iTotalCheques + 2),7,'0');
		LET cCodOperacion = '40';
                                 --12 presentacion de consulta interbancaria - 46 Reverso presentacion
		LET cTotalRegs = LPAD(TO_CHAR(iTotalCheques),7,'0');
		
		LET cImportes = '';                 
		LET cImportes = TO_CHAR(mTotalImporte);
		LET cMontos = substr(cImportes, 1, CHARINDEX('.', cImportes) - 1);
		LET cMontos = LPAD(TRIM(cMontos),16,'0');
		LET cCents = substr(cImportes, CHARINDEX('.', cImportes) + 1);
		LET cImportes = TRIM(cMontos || LPAD(cCents,2,'0'));
		
		LET cTotalRegTruncados = TO_CHAR(iTotalRegTruncados);	
		LET cTotalRegTruncados = LPAD(TRIM(NVL(cTotalRegTruncados,'')),7,'0');
		LET cUsoFuturo = ' ';
		
		-- ESCRITURA DE LA CADENA DE TEXTO EN EL ARCHIVO
		SYSTEM 'echo "'||cTipoSumario||cNumSecuencia||cCodOperacion||cTotalRegs||cImportes||cTotalRegTruncados||LPAD(cUsoFuturo,300,' ')||'" >> '||TRIM(pRutaDescarga)||TRIM(cNombreArchivo)||'.cce';
		
		EXECUTE PROCEDURE bditef:sp_cce_guardar_sumario(cNombreArchivo,cTipoSumario,cNumSecuencia,cCodOperacion,cTotalRegs,mTotalImporte,cTotalRegTruncados)INTO cCodRetSp;
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:sp_cce_guardar_sumario';
		END IF;
		
		--==============================
		-- PROCESAMIENTO CCE GRAN  SUMARIO
		--==============================
		LET cTipoGranSumario = '51';
		LET cSentido = 'E';
		LET cCodOperacion = '40';
		LET cNumOperaciones =  LPAD(TRIM(NVL(TO_CHAR(iTotalCheques),'')),7,'0');
		LET cNumBloques = '01';
		
		LET cFolio = LPAD(pNoBloque,9,'0');
		LET cFecha = TO_CHAR(DATE(dFechaHoy), '%Y%m%d');
		
		LET cImportes = '';                 
		LET cImportes = TO_CHAR(mTotalImporte);
		LET cMontos = substr(cImportes, 1, CHARINDEX('.', cImportes) - 1);
		LET cMontos = LPAD(TRIM(cMontos),16,'0');
		LET cCents = substr(cImportes, CHARINDEX('.', cImportes) + 1);
		LET cImportes = TRIM(cMontos || LPAD(cCents,2,'0'));
		LET cUsoFuturo=' ';
		
		-- ESCRITURA DE LA CADENA DE TEXTO EN EL ARCHIVO
		SYSTEM 'echo "'||cTipoGranSumario||cSentido||cCodOperacion||cNumOperaciones||cNumBloques||cBancoCedente||cFolio||cFecha||cImportes||cTotalRegTruncados||LPAD(cUsoFuturo,284,' ')||'" >> '||TRIM(pRutaDescarga)||TRIM(cNombreArchivo)||'.cce';
		

		EXECUTE PROCEDURE bditef:sp_cce_guardar_gransumario(cNombreArchivo,cTipoGranSumario,cSentido,cCodOperacion,cNumOperaciones,cNumBloques,
		cBancoCedente,cFolio,cFecha,mTotalImporte,cTotalRegTruncados)INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:sp_cce_guardar_gransumario';
		END IF;
		
		RETURN cCodRet,iTotalRegTruncados,TRIM(cNombreArchivo)||'.cce';
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Saul Ortiz Baeza',
'FECHA: 18/02/2016',
'MODULO: Camara de Compensacion Electonica Presentada',
'FUNCIONALIDAD: Generacion de Archivo',
'DESCRIPCION: realiza la generacion del archivo Cod 40 a presentar',
'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 26/07/2024',
'DESCRIPCION: Se aÃ±ade el procedimiento almacenado de Reverso cuando el proceso del archivo llegue a fallar.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnsif_consultatotalregtransacciontarjeta(cID_USUARIOC CHAR(8),cID_FUNCIONC CHAR(10),cNUMEROTARJETA CHAR(16),	cSECUENCIA CHAR(7),cREFERENCIA CHAR(12),
																cPOS_ATM CHAR(2),dPERIODOI DATE, dPERIODOF DATE)
							
			returning   CHAR(5)         AS  Cod_Retorno,	        
						INTEGER         AS  Num_registros;	   	

							
DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;							
	

--VARIABLES DE PAGINACION
DEFINE iCont            INT;
DEFINE iMes int;
DEFINE iDia int;
DEFINE iAnio int;
DEFINE iMesF int;
DEFINE iDiaF int;
DEFINE iAnioF int;

--inicializando variables
LET  iexiste 		 = 0;
LET cCodRet 		 = "00000";
LET iSql_err 		 = 0 ;	

--VARIABLES DE PAGINACION 
LET iCont       = 0;

LET iMes =0;
LET iDia =0;
LET iAnio =0;

LET iMesF =0;
LET iDiaF =0;
LET iAnioF =0;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,iexiste;

		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/ifxsif01/emm/sp_cnsif_consultatotalregtransacciontarjeta.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
		
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMEROTARJETA  = '' OR 
		cPOS_ATM     = ''   OR
		dPERIODOI    = ''   OR 
		dPERIODOF 	 = ''	THEN 
		LET cCodRet = "00064";
		RETURN cCodRet,iexiste;
	END IF;	

	--VALIDACION
	EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMEROTARJETA,'25','3')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
	    RETURN cCodRet,iexiste;
	END IF;
	-- TERMINA VALIDACION		
	
	SELECT {+INDEX(intercard:movimiento idx_movimientonew1a)} NVL(COUNT(numtarjeta),0)	INTO iexiste FROM intercard:movimiento WHERE numtarjeta = cNUMEROTARJETA ;
	IF iexiste  = 0 THEN 
		SELECT {+INDEX(intercard:movimientohistorico idx_movimiento1)} NVL(COUNT(numtarjeta),0)	INTO iexiste FROM intercard:movimientohistorico WHERE numtarjeta = cNUMEROTARJETA ;
		IF iexiste  = 0 THEN
						LET cCodRet = "00065";
						RETURN cCodRet,iexiste;					
		END IF;
	END IF;
	
	
	LET iMes  = MONTH(dPERIODOI);
    LET iDia  = DAY(dPERIODOI);
    LET iAnio = YEAR(dPERIODOI);
	
	LET iMesF  = MONTH(dPERIODOF);
    LET iDiaF  = DAY(dPERIODOF);
    LET iAnioF = YEAR(dPERIODOF);

	IF (cSECUENCIA = '' AND cREFERENCIA = '') THEN
        FOREACH
			SELECT {+INDEX(intercard:movimiento idx_movimientonew1a)} {+INDEX(intercard:movimiento idx_fechahorainauth)} LIMIT 1 NVL(COUNT(*),0) AS CONT INTO iexiste 
				FROM intercard:movimiento  
				WHERE numtarjeta = cNUMEROTARJETA
				AND FechaHoraInAuth::DATE BETWEEN dPERIODOI AND dPERIODOF
				AND prodind = cPOS_ATM
			UNION
				SELECT {+INDEX(intercard:movimientohistorico idx_movimiento1)}  {+INDEX(intercard:movimientohistorico idx_movimiento3)} NVL(COUNT(*),0) AS CONT
				FROM intercard:movimientohistorico  
				WHERE numtarjeta = cNUMEROTARJETA
				AND FechaHoraInAuth::DATE BETWEEN dPERIODOI AND dPERIODOF
				AND prodind = cPOS_ATM
			ORDER BY CONT DESC
				
        END FOREACH;              
		IF iexiste  = 0 THEN 
            LET cCodRet = "00091";
            RETURN cCodRet,iexiste;
		ELSE
			RETURN cCodRet,iexiste;
		END IF;

	ELIF (cSECUENCIA != '' AND cREFERENCIA = '') THEN
        FOREACH
			SELECT {+INDEX(intercard:movimiento idx_movimientonew1a)} {+INDEX(intercard:movimiento idx_fechahorainauth)} LIMIT 1 NVL(COUNT(*),0) AS CONT INTO iexiste 
				FROM intercard:movimiento  
				WHERE numtarjeta = cNUMEROTARJETA
				AND FechaHoraInAuth::DATE BETWEEN dPERIODOI AND dPERIODOF
				AND prodind = cPOS_ATM
				AND secuencia = cSECUENCIA
			UNION
				SELECT {+INDEX(intercard:movimientohistorico idx_movimiento1)}  {+INDEX(intercard:movimientohistorico idx_movimiento3)} NVL(COUNT(*),0) AS CONT
				FROM intercard:movimientohistorico  
				WHERE numtarjeta = cNUMEROTARJETA
				AND FechaHoraInAuth::DATE BETWEEN dPERIODOI AND dPERIODOF
				AND prodind = cPOS_ATM
				AND secuencia = cSECUENCIA
			ORDER BY CONT DESC
				
        END FOREACH;
		IF iexiste  = 0 THEN 
            LET cCodRet = "00091";
            RETURN cCodRet,iexiste;
		ELSE
			RETURN cCodRet,iexiste;
		END IF;
		
	ELIF (cSECUENCIA = '' AND cREFERENCIA != '') THEN	

        FOREACH
			SELECT {+INDEX(intercard:movimiento idx_movimientonew1a)} {+INDEX(intercard:movimiento idx_fechahorainauth)}  LIMIT 1 NVL(COUNT(*),0) AS CONT INTO iexiste 
				FROM intercard:movimiento  
				WHERE numtarjeta = cNUMEROTARJETA
				AND FechaHoraInAuth::DATE BETWEEN dPERIODOI AND dPERIODOF
				AND prodind = cPOS_ATM
				AND referencia = cREFERENCIA
			UNION
				SELECT {+INDEX(intercard:movimientohistorico idx_movimiento1)}  {+INDEX(intercard:movimientohistorico idx_movimiento3)} NVL(COUNT(*),0) AS CONT
				FROM intercard:movimientohistorico  
				WHERE numtarjeta = cNUMEROTARJETA
				AND FechaHoraInAuth::DATE BETWEEN dPERIODOI AND dPERIODOF
				AND prodind = cPOS_ATM
				AND referencia = cREFERENCIA
			ORDER BY CONT DESC
				
        END FOREACH;
		IF iexiste  = 0 THEN 
            LET cCodRet = "00091";
            RETURN cCodRet,iexiste;
		ELSE
			RETURN cCodRet,iexiste;
		END IF;

	ELIF (cSECUENCIA != '' AND cREFERENCIA != '') THEN	
        FOREACH
			SELECT {+INDEX(intercard:movimiento idx_movimientonew1a)} {+INDEX(intercard:movimiento idx_fechahorainauth)} LIMIT 1 NVL(COUNT(*),0) AS CONT INTO iexiste 
				FROM intercard:movimiento  
				WHERE numtarjeta = cNUMEROTARJETA
				AND FechaHoraInAuth::DATE BETWEEN dPERIODOI AND dPERIODOF
				AND prodind = cPOS_ATM
				AND secuencia = cSECUENCIA
				AND referencia = cREFERENCIA
			UNION
				SELECT {+INDEX(intercard:movimientohistorico idx_movimiento1)}  {+INDEX(intercard:movimientohistorico idx_movimiento3)} NVL(COUNT(*),0) AS CONT
				FROM intercard:movimientohistorico  
				WHERE numtarjeta = cNUMEROTARJETA
				AND FechaHoraInAuth::DATE BETWEEN dPERIODOI AND dPERIODOF
				AND prodind = cPOS_ATM
				AND secuencia = cSECUENCIA
				AND referencia = cREFERENCIA
				
        END FOREACH;
		IF iexiste  = 0 THEN 
            LET cCodRet = "00091";
            RETURN cCodRet,iexiste;
		ELSE
			RETURN cCodRet,iexiste;
		END IF;
	END IF		
	
END
END PROCEDURE
DOCUMENT
"AutOR : OSCAR FLORES CONDE	",
"FUNCIONAMIENTO:Obtiene el numero de registros con la informaciÃ³n de los Movimientos de Tarjeta POS/ATM. ",
"El SP obtendrÃ¡ la informaciÃ³n de la Base de Datos central de Informix, enviando como parÃ¡metro el  No. de Tarjeta o Secuencia/Referencia.",
"FECHA : 25-11-2013",
"BD    : bdicnweb",
"VER   : 1.0",
'AUTOR: KARLOS GOMEZ D',
'FECHA: 23/08/2024',
'DESCRIPCION: Se eliminaron las consultas a las tablas inexistentes intercard:movimientohistorico_2014, intercard:movimientohistorico_2013, e intercard:movimientohistorico_2012.',
"VER   : 2.0"
;

CREATE PROCEDURE "informix".sp_cnsif_consdetallemovimientos_totales_pba4(pUsuario CHAR(8), pIdFuncion CHAR(10), pSistemaCuenta CHAR(20), 
pFechaInicial DATE, pFechaFinal DATE, pNumCuenta CHAR(20), pEjecutivo CHAR(8), pSucursal CHAR(4), pImporte MONEY(14,2), pEjecucion CHAR(1), pClaveMov CHAR(50))
    RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);	
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreArchivo CHAR(45);
	DEFINE iRecuperacion INTEGER;
	
	DEFINE dFecha DATE;
	DEFINE dHora DATETIME HOUR TO FRACTION(3);
	DEFINE cCveTransacc CHAR(4);
	DEFINE cDescTransacc CHAR(50);
	DEFINE cFolio CHAR(16);
	DEFINE dPeriodoInicial DATE;
	DEFINE mMonto MONEY(14,2);
	DEFINE dPeriodoFinal DATE;
	DEFINE cSisCuenta CHAR(20);
	DEFINE cNaturaleza CHAR(1);
	DEFINE cReferencia CHAR(40);
	DEFINE cReversos CHAR(1);
	DEFINE cSucursal CHAR(4);
	DEFINE cCveProc CHAR(20);
	DEFINE cDescProc CHAR(50);
	DEFINE mSaldo MONEY(14,2);
	DEFINE cNumTarjeta CHAR(20);
	DEFINE cReversados CHAR(1);
	DEFINE cUsuario CHAR(8);
	DEFINE cReferencia23 CHAR(23);
	DEFINE iContReg INTEGER;
	DEFINE iNumRegistros INTEGER;
	DEFINE dFechaHora DATETIME YEAR TO FRACTION(5);
	DEFINE dFechaInicial  DATE;
	DEFINE dFechaFinal  DATE;
	DEFINE cClaveMov CHAR(50);
	DEFINE iPid INTEGER;
	DEFINE cTmpTable CHAR(5000);
	
	DEFINE iCont INTEGER;
	
	LET iPid = DBINFO('sessionid');
	LET cTmpTable = '';
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';	
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cNombreArchivo = '';
	LET iRecuperacion = 0;
	
	LET dFecha = '';
	LET dHora = '';
	LET cCveTransacc = '';
	LET cDescTransacc = '';
	LET cFolio = '';
	LET dPeriodoInicial = '';
	LET mMonto = 0.00;
	LET dPeriodoFinal = '';
	LET cSisCuenta = '';
	LET cNaturaleza = '';
	LET cReferencia = '';
	LET cReversos = '';
	LET cSucursal = '';
	LET cCveProc = '';
	LET cDescProc = '';
	LET mSaldo = 0.00;
	LET cNumTarjeta = '';
	LET cReversados = '';
	LET cUsuario = '';
	LET cReferencia23 = '';
	LET iContReg = 0;
	LET iNumRegistros = 0;
	LET dFechaHora = CURRENT YEAR TO FRACTION(5);
	LET dFechaInicial =null;
	LET dFechaFinal   =null;
	LET cClaveMov = 'ArchivosMov_'||TRIM(pUsuario)||TO_CHAR(CURRENT, '%Y%m%d%H%M%S');
	
	LET iCont = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				IF pEjecucion = '1' OR pEjecucion = '3' THEN
					UPDATE bdicnweb:"informix".sw_cons_statusproceso
					SET status = 'E', error_proceso = 'S', error = cCodRet WHERE clave_mov = pClaveMov;
				END IF;
				
				RETURN cCodRet, iNumRegistros;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-958)
		END EXCEPTION WITH RESUME;
		
		ON EXCEPTION IN (-668, -535, -255)
		END EXCEPTION WITH RESUME;
		
		
		--SET EXPLAIN FILE TO "sqexplain.bdicnweb.sp_cnsif_consdetallemovimientos_totales.out";
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
			
		SET DEBUG FILE TO '/controlcambios/P-BD-20240904-01/sp_cnsif_consdetallemovimientos_totales.out';
		TRACE ON;
		
		IF pEjecucion = '1' OR pEjecucion = '3' THEN
			-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
			INSERT INTO bdicnweb:"informix".sw_cons_statusproceso(usuario,status,num_registros,clave_mov,error_proceso,error)
			VALUES(pUsuario,'I',0,pClaveMov,'',cCodRet);  
		END IF;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSistemaCuenta = '' OR pFechaInicial IS NULL OR pFechaFinal IS NULL OR pNumCuenta = '' OR pEjecucion = '' OR pClaveMov = '' THEN
			LET cCodRet = '00003';
			UPDATE bdicnweb:"informix".sw_cons_statusproceso
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE clave_mov = pClaveMov;
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE bdicnweb:"informix".sw_cons_statusproceso
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE clave_mov = pClaveMov;
			RETURN cCodRet, iNumRegistros;
		END IF;	
				
		-- CONSULTA TOTALES
		IF pEjecucion = '1' THEN
			
			EXECUTE PROCEDURE bdicnweb:"informix".sp_cnsif_consultatotalmovtosdiarioscta_2(pUsuario,pIdFuncion,pNumCuenta,pFechaInicial,pFechaFinal,pSistemaCuenta,pEjecutivo,pSucursal,pImporte)
			INTO cCodRetSp,iNumRegistros;
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_cnsif_consultatotalmovtosdiarioscta_2';
			ELIF iCodRetSp > 0 THEN
				LET cCodRet = cCodRetSp;
				UPDATE bdicnweb:"informix".sw_cons_statusproceso
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE clave_mov = pClaveMov;
				RETURN cCodRet, iNumRegistros;
			END IF;
			
			UPDATE bdicnweb:"informix".sw_cons_statusproceso
			SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE clave_mov = pClaveMov;
			
			RETURN cCodRet, iNumRegistros;
		
		-- TOTALES PARA MASIVO
		ELIF pEjecucion = '2' THEN 
			
			LET dFechaInicial= TO_DATE((LPAD(MONTH(pFechaInicial),2,0)||'/'||LPAD(DAY(pFechaInicial),2,0)||'/'||YEAR(pFechaInicial)), '%m/%d/%Y');
			LET dFechaFinal  = TO_DATE((LPAD(MONTH(pFechaFinal),2,0)||'/'||LPAD(DAY(pFechaFinal),2,0)||'/'||YEAR(pFechaFinal)) , '%m/%d/%Y');
						
			EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_consultamovtosdiarioscta3_2(pUsuario,pIdFuncion,pNumCuenta,dFechaInicial,dFechaFinal,pSistemaCuenta,pEjecutivo,pSucursal,pImporte,pClaveMov)
			INTO cCodRetSp,dFecha,dHora,cCveTransacc,cDescTransacc,cFolio,dPeriodoInicial,mMonto,dPeriodoFinal,cSisCuenta,
			cNaturaleza,cReferencia,cReversos,cSucursal,cCveProc,cDescProc,mSaldo,cNumTarjeta,cReversados,cUsuario,cReferencia23;
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_cnsif_consultamovtosdiarioscta3_2';
			ELIF iCodRetSp > 0 THEN
				LET cCodRet = cCodRetSp;
				RETURN cCodRet, iNumRegistros;
			END IF;
				
{-OPTIMIZACION STK202404+}
			SELECT COUNT(*)		
			  INTO iNumRegistros
			  FROM bdicnweb:"informix".sw_cons_movimientos		
			 WHERE sis_cuenta = pSistemaCuenta
			   AND clave_mov = pClaveMov;
		
			IF NVL(iNumRegistros,0) = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iNumRegistros;
			END IF;
{-OPTIMIZACION STK202404+}
			
			RETURN cCodRet, iNumRegistros;
			
		-- TOTALES PARA NO MASIVOS
		ELIF pEjecucion = '3' THEN 
			
			LET dFechaInicial= TO_DATE((LPAD(MONTH(pFechaInicial),2,0)||'/'||LPAD(DAY(pFechaInicial),2,0)||'/'||YEAR(pFechaInicial)), '%m/%d/%Y');
			LET dFechaFinal  = TO_DATE((LPAD(MONTH(pFechaFinal),2,0)||'/'||LPAD(DAY(pFechaFinal),2,0)||'/'||YEAR(pFechaFinal)) , '%m/%d/%Y');
						
				EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_consultamovtosdiarioscta3_2(pUsuario,pIdFuncion,pNumCuenta,dFechaInicial,dFechaFinal,pSistemaCuenta,pEjecutivo,pSucursal,pImporte,pClaveMov)
				INTO cCodRetSp,dFecha,dHora,cCveTransacc,cDescTransacc,cFolio,dPeriodoInicial,mMonto,dPeriodoFinal,cSisCuenta,
				cNaturaleza,cReferencia,cReversos,cSucursal,cCveProc,cDescProc,mSaldo,cNumTarjeta,cReversados,cUsuario,cReferencia23;
				
				LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_cnsif_consultamovtosdiarioscta3_2';
				ELIF iCodRetSp > 0 THEN
					LET cCodRet = cCodRetSp;
					UPDATE bdicnweb:"informix".sw_cons_statusproceso
					SET status = 'E', error_proceso = 'S', error = cCodRet WHERE clave_mov = pClaveMov;
					RETURN cCodRet, iNumRegistros;
				END IF;
				
{-OPTIMIZACION STK202404}
			SELECT COUNT(*)
			INTO iNumRegistros
			FROM bdicnweb:"informix".sw_cons_movimientos
			WHERE sis_cuenta = pSistemaCuenta
              AND clave_mov = pClaveMov; 			
		
			IF NVL(iNumRegistros,0) = 0 THEN
				LET cCodRet = '00017';
				UPDATE bdicnweb:"informix".sw_cons_statusproceso
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE clave_mov = pClaveMov;
				RETURN cCodRet, iNumRegistros;
			END IF;
{ -OPTIMIZACION STK202404}
			
			UPDATE bdicnweb:"informix".sw_cons_statusproceso
			SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE clave_mov = pClaveMov;
						
			RETURN cCodRet, iNumRegistros;
		
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA 24/10/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE MOVIMIENTOS DE CAPTACION/CREDITO/INVERSIONES',
'DESCRIPCION: SPL encargado de consultar el nÃºmero total de registros que regresara la busqueda por sistema de cuenta ingresado (CAPTACION/CREDITO/INVERSIONES).',
'AUTOR: L. Montserrat Leon Amador',
'FECHA 06/11/2017',
'DESCRIPCION: Se modifica SPL para agregar como filtro el sistema cuenta cuando se hace la limpieza de la tabla sw_cons_movimientos.',
'MODIFICACION: Martha Salgado',
'FECHA MODIFICACION: 27/11/2017',
'DESCRIPCION MODIFICACION :  Se agregan variables cFechaInicial  y  cFechaFinal, para tratar la fecha como MM/DD/YYYY ',
'MODIFICACION: Martha Salgado',
'FECHA MODIFICACION: 30/11/2017',
'DESCRIPCION MODIFICACION :  Se cambian variables cFechaInicial  y  cFechaFinal a Date ',
'AUTOR: Rodolfo Conde Flores',
'FECHA 08/01/2018',
'DESCRIPCION MODIFICACION: Se implementa el llamado de un spl que retorna el numero total de registros antes de inicar el llenado de la tabla principal.',
'Se crea la estructura de nuevas tablas espejo para evitar el bloqueo de la tabla principal.',
'AUTOR: Martha Salgado',
'FECHA 11/01/2018',
'DESCRIPCION MODIFICACION: Se validan valores null cuando pEjecucion = 2.',
'AUTOR: Rodolfo Conde Flores',
'FECHA 30/01/2018',
'DESCRIPCION MODIFICACION: Se elimina creacion de tabla temporal por tabla fisica para almacenamiento de informacion de movimientos.',
'AUTOR: Rodolfo Conde Flores',
'FECHA 30/01/2018',
'DESCRIPCION MODIFICACION: Se elimina creacion de tabla temporal por tabla fisica para almacenamiento de informacion de movimientos.',
'AUTOR: Rodolfo Conde Flores',
'FECHA 06/02/2017',
'DESCRIPCION MODIFICACION: Se elimina el campo usuario_insert de la tabla bdicnweb:sw_cons_movimientos.',
'AUTOR: Martha Salgado',
'FECHA 18/01/2019',
'DESCRIPCION MODIFICACION: Se elimina tabla sw_cons_tempo_movimientos y se agrega variable iCont.',
'AUTOR: L. Montserrat Leon Amador',
'FECHA 25/01/2019',
'DESCRIPCION MODIFICACION: Se modifica implementacion de ejecuciÃ³n COMMIT sobre SPL sp_cnsif_consultamovtosdiarioscta3_2.',
'BD: bdicnweb',
'OPTIMIZACION STK202404',
'Modificado: Softtek / A.Canseco 04,07.2024',
'OPTIMIZACION STK202404';

CREATE PROCEDURE "informix".sp_cnsif_consdetallemovimientos_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pSistemaCuenta CHAR(20), 
pFechaInicial DATE, pFechaFinal DATE, pNumCuenta CHAR(20), pEjecutivo CHAR(8), pSucursal CHAR(4), pImporte MONEY(14,2), pEjecucion CHAR(1), pClaveMov CHAR(50))
    RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);	
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreArchivo CHAR(45);
	DEFINE iRecuperacion INTEGER;
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	
	DEFINE dFecha DATE;
	DEFINE dHora DATETIME HOUR TO FRACTION(3);
	DEFINE cCveTransacc CHAR(4);
	DEFINE cDescTransacc CHAR(50);
	DEFINE cFolio CHAR(16);
	DEFINE dPeriodoInicial DATE;
	DEFINE mMonto MONEY(14,2);
	DEFINE dPeriodoFinal DATE;
	DEFINE cSisCuenta CHAR(20);
	DEFINE cNaturaleza CHAR(1);
	DEFINE cReferencia CHAR(40);
	DEFINE cReversos CHAR(1);
	DEFINE cSucursal CHAR(4);
	DEFINE cCveProc CHAR(20);
	DEFINE cDescProc CHAR(50);
	DEFINE mSaldo MONEY(14,2);
	DEFINE cNumTarjeta CHAR(20);
	DEFINE cReversados CHAR(1);
	DEFINE cUsuario CHAR(8);
	DEFINE cReferencia23 CHAR(23);
	DEFINE iContReg INTEGER;
	DEFINE iNumRegistros INTEGER;
	DEFINE dFechaHora DATETIME YEAR TO FRACTION(5);
	DEFINE dFechaInicial  DATE;
	DEFINE dFechaFinal  DATE;
	DEFINE cClaveMov CHAR(50);
	DEFINE iPid INTEGER;
	DEFINE cTmpTable CHAR(5000);
	--DEFINE iCont  INT;
	
	DEFINE iCont INTEGER;
    DEFINE sCommit SMALLINT;
	
	LET iPid = DBINFO('sessionid');
	LET cTmpTable = '';
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';	
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cNombreArchivo = '';
	LET iRecuperacion = 0;
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	
	LET dFecha = '';
	LET dHora = '';
	LET cCveTransacc = '';
	LET cDescTransacc = '';
	LET cFolio = '';
	LET dPeriodoInicial = '';
	LET mMonto = 0.00;
	LET dPeriodoFinal = '';
	LET cSisCuenta = '';
	LET cNaturaleza = '';
	LET cReferencia = '';
	LET cReversos = '';
	LET cSucursal = '';
	LET cCveProc = '';
	LET cDescProc = '';
	LET mSaldo = 0.00;
	LET cNumTarjeta = '';
	LET cReversados = '';
	LET cUsuario = '';
	LET cReferencia23 = '';
	LET iContReg = 0;
	LET iNumRegistros = 0;
	LET dFechaHora = CURRENT YEAR TO FRACTION(5);
	LET dFechaInicial =null;
	LET dFechaFinal   =null;
	LET cClaveMov = 'ArchivosMov_'||TRIM(pUsuario)||TO_CHAR(CURRENT, '%Y%m%d%H%M%S');
	--LET iCont = 0;
	
	LET iCont = 0;
    LET sCommit = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				--IF sCommit = -1 THEN
				--	ROLLBACK WORK;
				--END IF;
								
				IF ven_transacc = 1 THEN
					--ROLLBACK WORK;		
				END IF;
				
				
				LET cCodRet = iSqlErr;
				IF pEjecucion = '1' OR pEjecucion = '3' THEN
					UPDATE bdicnweb:"informix".sw_cons_statusproceso
					SET status = 'E', error_proceso = 'S', error = cCodRet WHERE clave_mov = pClaveMov;
				END IF;
				
				RETURN cCodRet, iNumRegistros;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-958)
		END EXCEPTION WITH RESUME;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
			
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnsif_consdetallemovimientos_totales.out';
		--TRACE ON;
		
		IF pEjecucion = '1' OR pEjecucion = '3' THEN
			-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
			INSERT INTO bdicnweb:"informix".sw_cons_statusproceso(usuario,status,num_registros,clave_mov,error_proceso,error)
			VALUES(pUsuario,'I',0,pClaveMov,'',cCodRet);  
		END IF;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSistemaCuenta = '' OR pFechaInicial IS NULL OR pFechaFinal IS NULL OR pNumCuenta = '' OR pEjecucion = '' OR pClaveMov = '' THEN
			LET cCodRet = '00003';
			UPDATE bdicnweb:"informix".sw_cons_statusproceso
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE clave_mov = pClaveMov;
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE bdicnweb:"informix".sw_cons_statusproceso
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE clave_mov = pClaveMov;
			RETURN cCodRet, iNumRegistros;
		END IF;	
				
		-- CONSULTA TOTALES
		IF pEjecucion = '1' THEN
			
			EXECUTE PROCEDURE bdicnweb:"informix".sp_cnsif_consultatotalmovtosdiarioscta_2(pUsuario,pIdFuncion,pNumCuenta,pFechaInicial,pFechaFinal,pSistemaCuenta,pEjecutivo,pSucursal,pImporte)
			INTO cCodRetSp,iNumRegistros;
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_cnsif_consultatotalmovtosdiarioscta_2';
			ELIF iCodRetSp > 0 THEN
				LET cCodRet = cCodRetSp;
				UPDATE bdicnweb:"informix".sw_cons_statusproceso
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE clave_mov = pClaveMov;
				RETURN cCodRet, iNumRegistros;
			END IF;
			
			UPDATE bdicnweb:"informix".sw_cons_statusproceso
			SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE clave_mov = pClaveMov;
			
			RETURN cCodRet, iNumRegistros;
		
		-- TOTALES PARA MASIVO
		ELIF pEjecucion = '2' THEN 
			
			LET dFechaInicial= TO_DATE((LPAD(MONTH(pFechaInicial),2,0)||'/'||LPAD(DAY(pFechaInicial),2,0)||'/'||YEAR(pFechaInicial)), '%m/%d/%Y');
			LET dFechaFinal  = TO_DATE((LPAD(MONTH(pFechaFinal),2,0)||'/'||LPAD(DAY(pFechaFinal),2,0)||'/'||YEAR(pFechaFinal)) , '%m/%d/%Y');
						
			FOREACH
				
				EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_consultamovtosdiarioscta3_2(pUsuario,pIdFuncion,pNumCuenta,dFechaInicial,dFechaFinal,pSistemaCuenta,pEjecutivo,pSucursal,pImporte,pClaveMov)
				INTO cCodRetSp,dFecha,dHora,cCveTransacc,cDescTransacc,cFolio,dPeriodoInicial,mMonto,dPeriodoFinal,cSisCuenta,
				cNaturaleza,cReferencia,cReversos,cSucursal,cCveProc,cDescProc,mSaldo,cNumTarjeta,cReversados,cUsuario,cReferencia23
				
				LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_cnsif_consultamovtosdiarioscta3_2';
				ELIF iCodRetSp > 0 THEN
					LET cCodRet = cCodRetSp;
					RETURN cCodRet, iNumRegistros;
				END IF;
				
			END FOREACH;
						
			SELECT COUNT(*)
			INTO iNumRegistros
			FROM bdicnweb:"informix".sw_cons_movimientos		
			WHERE sis_cuenta = pSistemaCuenta AND clave_mov = pClaveMov; 
		
			IF NVL(iNumRegistros,0) = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iNumRegistros;
			END IF;
			
			RETURN cCodRet, iNumRegistros;
			
		-- TOTALES PARA NO MASIVOS
		ELIF pEjecucion = '3' THEN 
			
			LET dFechaInicial= TO_DATE((LPAD(MONTH(pFechaInicial),2,0)||'/'||LPAD(DAY(pFechaInicial),2,0)||'/'||YEAR(pFechaInicial)), '%m/%d/%Y');
			LET dFechaFinal  = TO_DATE((LPAD(MONTH(pFechaFinal),2,0)||'/'||LPAD(DAY(pFechaFinal),2,0)||'/'||YEAR(pFechaFinal)) , '%m/%d/%Y');
						
			FOREACH
				
				EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_consultamovtosdiarioscta3_2(pUsuario,pIdFuncion,pNumCuenta,dFechaInicial,dFechaFinal,pSistemaCuenta,pEjecutivo,pSucursal,pImporte,pClaveMov)
				INTO cCodRetSp,dFecha,dHora,cCveTransacc,cDescTransacc,cFolio,dPeriodoInicial,mMonto,dPeriodoFinal,cSisCuenta,
				cNaturaleza,cReferencia,cReversos,cSucursal,cCveProc,cDescProc,mSaldo,cNumTarjeta,cReversados,cUsuario,cReferencia23
				
				LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_cnsif_consultamovtosdiarioscta3_2';
				ELIF iCodRetSp > 0 THEN
					LET cCodRet = cCodRetSp;
					UPDATE bdicnweb:"informix".sw_cons_statusproceso
					SET status = 'E', error_proceso = 'S', error = cCodRet WHERE clave_mov = pClaveMov;
					RETURN cCodRet, iNumRegistros;
				END IF;
				
			END FOREACH;
									
			SELECT COUNT(*)
			INTO iNumRegistros
			FROM bdicnweb:"informix".sw_cons_movimientos 
			WHERE sis_cuenta = pSistemaCuenta AND clave_mov = pClaveMov; 			
		
			IF NVL(iNumRegistros,0) = 0 THEN
				LET cCodRet = '00017';
				UPDATE bdicnweb:"informix".sw_cons_statusproceso
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE clave_mov = pClaveMov;
				RETURN cCodRet, iNumRegistros;
			END IF;
			
			UPDATE bdicnweb:"informix".sw_cons_statusproceso
			SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE clave_mov = pClaveMov;
						
			RETURN cCodRet, iNumRegistros;
		
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA 24/10/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE MOVIMIENTOS DE CAPTACIÃN/CRÃDITO/INVERSIONES',
'DESCRIPCION: SPL encargado de consultar el nÃºmero total de registros que regresarÃ¡ la bÃºsqueda por sistema de cuenta ingresado (CAPTACION/CREDITO/INVERSIONES).',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA 06/11/2017',
'DESCRIPCION: Se modifica SPL para agregar como filtro el sistema cuenta cuando se hace la limpieza de la tabla sw_cons_movimientos.',
'MODIFICACION: Martha Salgado',
'FECHA MODIFICACION: 27/11/2017',
'DESCRIPCION MODIFICACION :  Se agregan variables cFechaInicial  y  cFechaFinal, para tratar la fecha como MM/DD/YYYY ',
'MODIFICACION: Martha Salgado',
'FECHA MODIFICACION: 30/11/2017',
'DESCRIPCION MODIFICACION :  Se cambian variables cFechaInicial  y  cFechaFinal a Date ',
'AUTOR: Rodolfo Conde Flores',
'FECHA 08/01/2018',
'DESCRIPCION MODIFICACION: Se implementa el llamado de un spl que retorna el numero total de registros antes de inicar el llenado de la tabla principal.',
'Se crea la estructura de nuevas tablas espejo para evitar el bloqueo de la tabla principal.',
'AUTOR: Martha Salgado',
'FECHA 11/01/2018',
'DESCRIPCION MODIFICACION: Se validan valores null cuando pEjecucion = 2.',
'AUTOR: Rodolfo Conde Flores',
'FECHA 30/01/2018',
'DESCRIPCION MODIFICACION: Se elimina creaciÃ³n de tabla temporal por tabla fÃ­sica para almacenamiento de informaciÃ³n de movimientos.',
'AUTOR: Rodolfo Conde Flores',
'FECHA 30/01/2018',
'DESCRIPCION MODIFICACION: Se elimina creaciÃ³n de tabla temporal por tabla fÃ­sica para almacenamiento de informaciÃ³n de movimientos.',
'AUTOR: Rodolfo Conde Flores',
'FECHA 06/02/2017',
'DESCRIPCION MODIFICACION: Se elimina el campo usuario_insert de la tabla bdicnweb:sw_cons_movimientos.',
'AUTOR: Martha Salgado',
'FECHA 18/01/2019',
'DESCRIPCION MODIFICACION: Se elimina tabla sw_cons_tempo_movimientos y se agrega variable iCont.',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA 25/01/2019',
'DESCRIPCION MODIFICACION: Se modifica implementaciÃ³n de ejecuciÃ³n COMMIT sobre SPL sp_cnsif_consultamovtosdiarioscta3_2.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnsif_consctedetalle_3(cID_USUARIOC char(8),cID_FUNCIONC char(10),cnumcte char(20),cTPERSONA CHAR(6))
    RETURNING 	CHAR(5)  AS Cod_Retorno,  
				CHAR(20) AS Numero_Cliente, 
				CHAR(15) AS Nacionalidad, 
				CHAR(100) AS E_Mail, 
				CHAR(8)  AS Ejecutivo,  
				CHAR(1)  AS Cve_Domiciliacion,   
				CHAR(30) AS Desc_Domiciliacion, 
				CHAR(1)  AS Cve_BPI,  
				CHAR(30) AS Desc_BPI, 
				CHAR(1)  AS Cve_Pagos, 
				CHAR(30) AS Desc_Pagos,  
				CHAR(20) AS Estado_Civil,  
				CHAR(2)  AS Cve_Lugar_Nacimiento,  
				CHAR(18) AS FM3, 
				CHAR(20) AS CURP, 
				CHAR(30) AS Escolaridad, 
				CHAR(60) AS Profesion,
                CHAR(20) AS Cliente_Co, 
				CHAR(60) AS Puesto_PPES, 
				CHAR(45) AS Actividad_Especial, 
				CHAR(20) AS Familiar_PPES, 
				CHAR(60) AS Razon_Social, 
				CHAR(60) AS Sufijo,  
				CHAR(30) AS Pagina_Internet, 
				CHAR(40) AS Giro, 
				CHAR(45) AS Actividad_Social, 
				CHAR(48) AS Nombre_Titular, 
				CHAR(25) AS SAT_FEA, 
				CHAR(15) AS Telefono_Contacto,  
				CHAR(30) AS Escritura_Constitutiva, 
				CHAR(30) AS Nombre_Notario_CT, 
				CHAR(5)  AS Numero_Notario_CT,  
				CHAR(30) AS Ciudad_Notario_CT, 
				DATE     AS Fecha_Inscripcion_CT,
                DATE     AS Fecha_Contit_CT, 
				CHAR(30) AS Escritura_Poderes, 
				CHAR(30) AS Nombre_Notario_PD, 
				CHAR(5)  AS Numero_Notario_PD,  
				CHAR(30) AS Ciudad_Notario_PD, 
				DATE     AS Fecha_Inscripcion_PD, 
				CHAR(50) AS Nombre_Sociedad,  
				CHAR(4)  AS Sucursal, 
				DATE     AS Fecha_Alta,
				CHAR(30) AS Desc_Lugar_Nacimiento,
				CHAR(50) AS Desc_ActividadEco, 
				CHAR(50) AS Desc_subActividadEco;

				
	--Variables en comun
	DEFINE iexiste 			INT;
	DEFINE cCodRet 			CHAR(5);
	DEFINE iSql_err 		INT;
	DEFINE cNumeroCliente	CHAR(20);
	DEFINE cNacionalidad 	CHAR(15);
	DEFINE cCdomiciliacion	CHAR(1);
	DEFINE cDDomiliciacion	CHAR(30);
	DEFINE cCBPI			CHAR(1);
	DEFINE cDBPI			CHAR(30);
	DEFINE cCpagos			CHAR(1);
	DEFINE cDpagos			CHAR(30);
	DEFINE cTpo_persona 	CHAR(2);
	DEFINE cActividadEc		CHAR(50);
	DEFINE cSubActividadEc	CHAR(50);

	--VARIABLES CORREO ELECTRONICO
	DEFINE vcodret1         CHAR(3);
	DEFINE vtipocorreo      SMALLINT;
	DEFINE vstatuscorreo    CHAR(1);
	
	--Variables persona fisica 
	DEFINE cEstado_civil  	CHAR(20);
	DEFINE clugar_nac 		CHAR(2);
	DEFINE cNo_fm3 			CHAR(18);
	DEFINE cCurp			CHAR(20);
	DEFINE cEscolaridad 	CHAR(30);
	DEFINE cProfesion 		CHAR(60);
	DEFINE cEmail			CHAR(100);
	DEFINE cClienteCop		CHAR(20);
	DEFINE cEjecutivo		CHAR(8);
	DEFINE cPuesto_ppes		CHAR(2);
	DEFINE CDPuesto_ppes    CHAR(60);
	DEFINE cActividad_esp	CHAR(45);
	DEFINE cFamiliar_ppes	CHAR(20);


    --Variables persona moral
	DEFINE crazon_social		CHAR(120);
	DEFINE csufijo				CHAR(60);
	DEFINE cpagina_internet		CHAR(30);
	DEFINE cgiro				CHAR(40);
	DEFINE cDActividad_social 	CHAR(45);
	DEFINE cnombre_titular		CHAR(48);
	DEFINE csat_fea				CHAR(25);
	DEFINE ctelefono_contacto 	CHAR(15);
	DEFINE cemailpm				CHAR(100);
	DEFINE cescritura_constitutiva CHAR(30);
	DEFINE cnombre_notarioct	CHAR(30);
	DEFINE cnumero_notarioct	CHAR(5);
	DEFINE cciudad_notarioct	CHAR(30);
	DEFINE cfecha_inscrip		DATE;
	DEFINE cfecha_constitct		DATE;
	DEFINE cescritura_poderes	CHAR(30);
	DEFINE cnombre_notariopd	CHAR(30);
	DEFINE cnumero_notariopd	CHAR(5);
	DEFINE cciudad_notariopd	CHAR(30);
	DEFINE cfecha_inscrippd		DATE;
	DEFINE cnombre_sociedad		CHAR(50);	
	DEFINE cSucursal			CHAR(4);
	DEFINE dFecha_alta			DATE;
	DEFINE cEjecutivo_alta		CHAR(8);
	DEFINE iTpo_cliente			INT;
	DEFINE cNumCtePrincipal 	CHAR(20);
	DEFINE cDescLugarNacimiento CHAR(30);
	--Variables persona fisica 
	LET cEstado_civil = "";  	
	LET clugar_nac 	= "";
	LET cNo_fm3 		= "";
	LET cCurp			= "";
	LET cEscolaridad 	= "";
	LET cProfesion 		= "";
	LET cEmail			= "";
	LET cClienteCop		= "";
	LET cEjecutivo		= "";
	LET cPuesto_ppes	= "";
	LET cDPuesto_ppes	= "";
	LET cActividad_esp	= "";
	LET cFamiliar_ppes	= "";

    --Variables persona moral
	LET crazon_social		= "";
	LET csufijo				= "";
	LET cpagina_internet	= "";
	LET cgiro				= "";
	LET cDActividad_social 	= "";
	LET cnombre_titular		= "";
	LET csat_fea			= "";
	LET ctelefono_contacto 	= "";
	LET cemailpm			= "";
	LET cescritura_constitutiva = "";
	LET cnombre_notarioct	= "";
	LET cnumero_notarioct	= "";
	LET cciudad_notarioct	= "";
	LET cfecha_inscrip		= "";
	LET cfecha_constitct	= "";
	LET cescritura_poderes	= "";
	LET cnombre_notariopd	= "";
	LET cnumero_notariopd	= "";
	LET cciudad_notariopd	= "";
	LET cfecha_inscrippd	= "";
	LET cnombre_sociedad	= "";	
	LET cSucursal			= "";
	LET cEjecutivo_alta		= "";
	LET dFecha_alta			= "";
	
	--Variables en comun
	LET iexiste 		= 0;
	LET cCodRet 		= "00000";
	LET iSql_err 		= 0;
	LET cNumeroCliente	= "";
	LET cNacionalidad 	= "";
	LET cCdomiciliacion	= "";
	LET cDDomiliciacion	= "";
	LET cCBPI			= "";
	LET cDBPI			= "";
	LET cCpagos			= "";
	LET cDpagos			= "";
	LET cTpo_persona    = "";
	LET cActividadEc 	= "";
	LET cSubActividadEc	= "";

	--VARIABLES CORREO ELECTRONICO
	LET vcodret1       = "";
	LET vtipocorreo    = 0;
	LET vstatuscorreo  = "";
	LET iTpo_cliente=0;
	LET cNumCtePrincipal = "";
	LET cDescLugarNacimiento="";
	
	
	BEGIN
	
		ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN 
						cCodRet,cNumeroCliente,cNacionalidad,cEmail,cEjecutivo_alta,cCdomiciliacion,cDDomiliciacion,cCBPI,cDBPI,cCpagos,cDpagos,cEstado_civil,clugar_nac,
                        cNo_fm3,cCurp,cEscolaridad,cProfesion,cClienteCop,CDPuesto_ppes,cActividad_esp,cFamiliar_ppes,crazon_social,csufijo,cpagina_internet,cgiro,cDActividad_social,
                        cnombre_titular,csat_fea,ctelefono_contacto,cescritura_constitutiva,cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip,cfecha_constitct,
                        cescritura_poderes,cnombre_notariopd,cnumero_notariopd,cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,dFecha_alta,cDescLugarNacimiento, cActividadEc, cSubActividadEc;

            END IF;
        END EXCEPTION;
			--SET DEBUG FILE TO "/tmp/mfinis/Antonio/sp_cnsif_consctedetalle3.out";
			--TRACE ON;	

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

		IF 	cID_USUARIOC ='' 	OR 
			cID_FUNCIONC = '' 	OR 
			cNumcte = '' 		OR 
			cTPERSONA = '' 		THEN
			LET cCodRet = "00054";
			RETURN 
						cCodRet,cNumeroCliente,cNacionalidad,cEmail,cEjecutivo_alta,cCdomiciliacion,cDDomiliciacion,cCBPI,cDBPI,cCpagos,cDpagos,cEstado_civil,clugar_nac,
                        cNo_fm3,cCurp,cEscolaridad,cProfesion,cClienteCop,CDPuesto_ppes,cActividad_esp,cFamiliar_ppes,crazon_social,csufijo,cpagina_internet,cgiro,cDActividad_social,
                        cnombre_titular,csat_fea,ctelefono_contacto,cescritura_constitutiva,cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip,cfecha_constitct,
                        cescritura_poderes,cnombre_notariopd,cnumero_notariopd,cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,dFecha_alta,cDescLugarNacimiento, cActividadEc, cSubActividadEc;	
		END IF;		
		IF  cTPERSONA <>'MORAL' AND cTPERSONA <>'FISICA' THEN
			LET cCodRet = "00052";
			RETURN 
						cCodRet,cNumeroCliente,cNacionalidad,cEmail,cEjecutivo_alta,cCdomiciliacion,cDDomiliciacion,cCBPI,cDBPI,cCpagos,cDpagos,cEstado_civil,clugar_nac,
                        cNo_fm3,cCurp,cEscolaridad,cProfesion,cClienteCop,CDPuesto_ppes,cActividad_esp,cFamiliar_ppes,crazon_social,csufijo,cpagina_internet,cgiro,cDActividad_social,
                        cnombre_titular,csat_fea,ctelefono_contacto,cescritura_constitutiva,cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip,cfecha_constitct,
                        cescritura_poderes,cnombre_notariopd,cnumero_notariopd,cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,dFecha_alta,cDescLugarNacimiento, cActividadEc, cSubActividadEc;	
		END IF;
		
		--VALIDACION
		EXECUTE PROCEDURE bdinteg:sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cnumcte,'11','2')
		INTO
		cCodRet;
		IF (cCodRet != '00000')  THEN
			RETURN  cCodRet,cNumeroCliente,cNacionalidad,cEmail,cEjecutivo_alta,cCdomiciliacion,cDDomiliciacion,cCBPI,cDBPI,cCpagos,cDpagos,cEstado_civil,clugar_nac,
					cNo_fm3,cCurp,cEscolaridad,cProfesion,cClienteCop,CDPuesto_ppes,cActividad_esp,cFamiliar_ppes,crazon_social,csufijo,cpagina_internet,cgiro,cDActividad_social,
					cnombre_titular,csat_fea,ctelefono_contacto,cescritura_constitutiva,cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip,cfecha_constitct,
					cescritura_poderes,cnombre_notariopd,cnumero_notariopd,cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,dFecha_alta,cDescLugarNacimiento, cActividadEc, cSubActividadEc;
		END IF;
	-- TERMINA VALIDACION		
	
--TRANSFER
	EXECUTE PROCEDURE bdicnweb:"informix".sp_validacte_transfer(cNUMCTE) INTO cCodRet,iTpo_cliente,cNumCtePrincipal;
	IF cNumCtePrincipal IS NOT NULL THEN
		LET cNUMCTE = cNumCtePrincipal;
	END IF;

		FOREACH
		SELECT FIRST 1 NVL(COUNT(numcte),0) INTO iexiste  FROM bdinteg:si_cliente where numcte = cnumcte
		UNION
		SELECT NVL(COUNT(numcte_tf),0)  FROM bditransfer:tf_maecte where numcte_tf = cnumcte
		ORDER BY 1 DESC
		END FOREACH;		
--TRANSFER			
		IF iexiste = 0 THEN
			LET cCodRet = "00055";
			RETURN 
						cCodRet,cNumeroCliente,cNacionalidad,cEmail,cEjecutivo_alta,cCdomiciliacion,cDDomiliciacion,cCBPI,cDBPI,cCpagos,cDpagos,cEstado_civil,clugar_nac,
                        cNo_fm3,cCurp,cEscolaridad,cProfesion,cClienteCop,CDPuesto_ppes,cActividad_esp,cFamiliar_ppes,crazon_social,csufijo,cpagina_internet,cgiro,cDActividad_social,
                        cnombre_titular,csat_fea,ctelefono_contacto,cescritura_constitutiva,cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip,cfecha_constitct,
                        cescritura_poderes,cnombre_notariopd,cnumero_notariopd,cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,dFecha_alta,cDescLugarNacimiento, cActividadEc, cSubActividadEc;	
		END IF;
		SELECT NVL(COUNT(num_cte),0) INTO iexiste FROM bdidomi:dom_autorizaciones WHERE num_cte = cnumcte  and cve_estatus = '01';
		IF iexiste = 0 THEN
			LET cCdomiciliacion = "0";
			LET cDDomiliciacion = "Domiciliacion";
			LET iexiste  = 0;
		ELIF iexiste >=  1 THEN 
			LET cCdomiciliacion = "1";
			LET cDDomiliciacion = "Domiciliacion";
			LET iexiste  = 0;
		END IF	
		select NVL(COUNT(numcliente),0) INTO iexiste FROM  bdibpi:bpi_usuario WHERE numcliente = cnumcte AND st_portal='activo';
		IF iexiste = 0 THEN 
			LET cCBPI = '0';
			LET cDBPI = "Banca por internet";
			LET iexiste = 0;
		ELIF iexiste >=  1 THEN 
			LET cCBPI = '1';
			LET cDBPI = "Banca por internet";
			LET iexiste = 0;
		END IF
		SELECT  NVL(COUNT(num_cte),0) INTO iexiste FROM  bdiprog:pp_pagoprog WHERE num_cte = cnumcte;
		IF iexiste = 0 THEN 
			LET cCpagos ='0';
			LET cDpagos = "Pagos programados";
			LET iexiste = 0;
		ELIF iexiste >=  1 THEN 
			LET cCpagos ='1';
			LET cDpagos = "Pagos programados";
			LET iexiste = 0;
		END IF 
		--VERIFICA EXISTENCIA EN ctppes
		SELECT NVL(COUNT(numcte),0) INTO iexiste FROM bdinteg:"informix".si_cteppes WHERE numcte = cnumcte;
		IF iexiste > 0 AND cTPERSONA ='FISICA' THEN 
			SELECT LIMIT 1 puesto_ppes
			INTO cPuesto_ppes
			FROM bdinteg:"informix".si_cteppes			
			WHERE numcte = cnumcte
			AND numeroregistro = (SELECT max(numeroregistro) FROM bdinteg:"informix".si_cteppes WHERE numcte = cnumcte);
			
		    SELECT descripcion 
			INTO cDPuesto_ppes
			FROM bdinteg:"informix".si_puestosppes
			WHERE puesto_ppes = cPuesto_ppes;
			
			LET iexiste = 0;
		END IF
		SELECT tpo_persona INTO cTpo_persona FROM bdinteg:si_cliente where numcte =  cnumcte;
		IF cTPERSONA ='FISICA' THEN -- si el tipo de cliente es persona fisica	
			IF cTpo_persona = '01' THEN 
				SELECT LIMIT 1 CL.numcte,NA.descripcion,CF.estado_civil,CF.lugar_nac,CF.no_fm3,CF.curp,ES.descripcion,NVL(PRO.descripcion, ''),
					   CL.ejecutivo,AE.descripcion, PA.descripcion,CL.numcte_ref,EDO.NOMBRE
						
				INTO cNumeroCliente, cNacionalidad,	cEstado_civil,clugar_nac,cNo_fm3, cCurp, cEscolaridad,cProfesion, 
					 cEjecutivo_alta,cActividad_esp,cFamiliar_ppes,cClienteCop,cDescLugarNacimiento
						
				FROM bdinteg:si_cliente CL 
				LEFT JOIN bdinteg:si_ctepf CF
				ON CL.numcte = CF.numcte
				LEFT JOIN bdinteg:si_nacion NA
				ON NA.nacion = CF.nacionalidad
				LEFT JOIN bdinteg:si_escolaridad ES
				ON ES.escolaridad = CF.escolaridad
				LEFT JOIN bdinteg:si_profesion PRO
				ON PRO.profesion = CF.profesion --> ProfesiÃ³n
				LEFT JOIN bdinteg:si_ingresos PR 
				ON PR.numcte = CL.numcte
				LEFT JOIN bdinteg:si_actsubact PRD 
				ON PRD.id_act = PR.claveopcionpuesto and PRD.id_subact = 0
				LEFT JOIN bdinteg:si_actesp AE
				ON  AE.codigo = CL.actividad_esp
				LEFT JOIN bdinteg:si_parentesco PA
				ON PA.parentesco = CL.familiar_ppes
				LEFT JOIN bdinteg:si_estados EDO 
				ON EDO.ESTADO=CF.lugar_nac
				
				WHERE CL.numcte = cnumcte; 
				IF cEstado_civil ='D' THEN
					LET cEstado_civil ='DIVORCIADO';
				END IF;
				IF cEstado_civil ='C' THEN
					LET cEstado_civil ='CASADO';
				END IF;
				IF cEstado_civil ='S' THEN
					LET cEstado_civil ='SOLTERO';
				END IF;
				IF cEstado_civil ='V' THEN
					LET cEstado_civil ='VIUDO';
				END IF;
				IF cEstado_civil ='U' THEN
					LET cEstado_civil ='UNION LIBRE';
				END IF;
                --BUSCA CORREO ELECTRONICO
				FOREACH
					EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_correos('001',cnumcte,1,'0')
					INTO
					vcodret1,cEmail,vtipocorreo,vstatuscorreo
				END FOREACH;

				--BUSCA LA ACTIVIDAD ECONOMICA.
				
				SELECT LIMIT 1 NVL(descrip, '') 
				INTO cActividadEc
				FROM bdinteg:si_ingresos si
				INNER JOIN bdinteg:si_actsubact act 
				ON si.claveopcionpuesto = act.id_act 
				AND id_subact in ('0','99')
				WHERE sec_ingreso = (SELECT MAX(sec_ingreso) FROM  bdinteg:si_ingresos WHERE numcte = TRIM(cnumcte))
				AND numcte = cnumcte;

				--BUSCA LA SUB ACTIVIDAD ECONOMICA.     
				SELECT LIMIT 1 NVL(descrip, '') 
				INTO cSubActividadEc
				FROM bdinteg:si_ingresos si
				INNER JOIN bdinteg:si_actsubact act 
				ON si.claveopcionpuesto = act.id_act 
				AND id_subact = clavesubopcionpuesto
				WHERE sec_ingreso = (SELECT MAX(sec_ingreso) FROM  bdinteg:si_ingresos WHERE numcte = TRIM(cnumcte))
				AND numcte = cnumcte;
				
                --SELECT LIMIT 1 nvl(co_numcte,'') INTO cClienteCop FROM bdisolic:ss_solicitudes WHERE numcte =cnumcte AND empresa='001' AND co_numcte is not null;

                RETURN 
						cCodRet,cNumeroCliente,cNacionalidad,cEmail,cEjecutivo_alta,cCdomiciliacion,cDDomiliciacion,cCBPI,cDBPI,cCpagos,cDpagos,cEstado_civil,clugar_nac,
                        cNo_fm3,cCurp,cEscolaridad,cProfesion,cClienteCop,CDPuesto_ppes,cActividad_esp,cFamiliar_ppes,crazon_social,csufijo,cpagina_internet,cgiro,cDActividad_social,
                        cnombre_titular,csat_fea,ctelefono_contacto,cescritura_constitutiva,cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip,cfecha_constitct,
                        cescritura_poderes,cnombre_notariopd,cnumero_notariopd,cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,dFecha_alta,cDescLugarNacimiento, cActividadEc, cSubActividadEc with resume;
			ELIF cTpo_persona <> '01' THEN 
				LET cCodRet = "00052";
				RETURN 
						cCodRet,cNumeroCliente,cNacionalidad,cEmail,cEjecutivo_alta,cCdomiciliacion,cDDomiliciacion,cCBPI,cDBPI,cCpagos,cDpagos,cEstado_civil,clugar_nac,
                        cNo_fm3,cCurp,cEscolaridad,cProfesion,cClienteCop,CDPuesto_ppes,cActividad_esp,cFamiliar_ppes,crazon_social,csufijo,cpagina_internet,cgiro,cDActividad_social,
                        cnombre_titular,csat_fea,ctelefono_contacto,cescritura_constitutiva,cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip,cfecha_constitct,
                        cescritura_poderes,cnombre_notariopd,cnumero_notariopd,cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,dFecha_alta,cDescLugarNacimiento, cActividadEc, cSubActividadEc;	
			END IF		
		ELIF  cTPERSONA='MORAL' THEN -- si el cliente es de tipo moral 
			IF cTpo_persona ='02' THEN 
				SELECT {+INDEX (bdinteg:"informix".si_ctepm 461_1018)} CL.numcte,CL.razon_social,SU.descripcion, PM.nacionalidad,PM.pagina_internet,AC.nombre,SA.descripcion,
				PM.sat_fea,PM.telefono_contacto,PM.escritura_constitutiva,PM.nombre_notarioct,PM.numero_notarioct,PM.ciudad_notarioct,
				PM.fecha_inscrip, PM.fecha_constitct,PM.escritura_poderes,PM.nombre_notariopd,PM.numero_notariopd,PM.ciudad_notariopd,
				PM.fecha_inscrippd,PM.nombre_sociedad,PM.sucursal,CL.ejecutivo,CL.fecha_alta
				INTO
				cNumeroCliente,crazon_social,csufijo,cNacionalidad,cpagina_internet,cgiro,cDActividad_social,csat_fea,ctelefono_contacto,cescritura_constitutiva,
					cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip, cfecha_constitct,cescritura_poderes,cnombre_notariopd,cnumero_notariopd,
					cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,cEjecutivo_alta,dFecha_alta
				FROM bdinteg:si_cliente CL
				LEFT JOIN bdinteg:si_ctepm PM
				ON PM.numcte = CL.numcte
				LEFT JOIN bdinteg:si_sufijos SU
				ON SU.codigo=PM.sufijo
				LEFT JOIN bdinteg:si_actecon AC
				ON AC.actividad = SUBSTRING(PM.giro FROM 1 FOR 3)
				LEFT JOIN bdinteg:si_actividadsocial SA
				ON SA.codigo = PM.actividadsocial
				WHERE  PM.numcte = cnumcte;

                IF LENGTH(cNacionalidad)=1 THEN
                    LET cNacionalidad='00'||TRIM(cNacionalidad);
                ELIF LENGTH(cNacionalidad)=2 THEN
                    LET cNacionalidad='0'||TRIM(cNacionalidad);
                ELIF LENGTH(cNacionalidad)=3 THEN
                    LET cNacionalidad=TRIM(cNacionalidad);
                ELSE
                    LET cNacionalidad='025';
                END IF;
                				
                SELECT descripcion INTO cNacionalidad FROM bdinteg:si_nacion
                WHERE nacion=cNacionalidad;
				
				SELECT nombreapoderado
				INTO cnombre_titular
				FROM bdinteg:si_apoderado
				WHERE empresa = '001' 
				AND numcte = cnumcte
				AND secuencia = 1;
				
				SELECT correo_elec
				INTO cEmail
				FROM bdinteg:si_correos
				WHERE numcte = cnumcte 
				AND status_correo = 'A' 
				AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:si_correos WHERE numcte = cnumcte);

								
				RETURN 
						cCodRet,cNumeroCliente,cNacionalidad,cEmail,cEjecutivo_alta,cCdomiciliacion,cDDomiliciacion,cCBPI,cDBPI,cCpagos,cDpagos,cEstado_civil,clugar_nac,
                        cNo_fm3,cCurp,cEscolaridad,cProfesion,cClienteCop,CDPuesto_ppes,cActividad_esp,cFamiliar_ppes,crazon_social,csufijo,cpagina_internet,cgiro,cDActividad_social,
                        cnombre_titular,csat_fea,ctelefono_contacto,cescritura_constitutiva,cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip,cfecha_constitct,
                        cescritura_poderes,cnombre_notariopd,cnumero_notariopd,cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,dFecha_alta,cDescLugarNacimiento, cActividadEc, cSubActividadEc with resume;
			ELIF cTpo_persona <> '02' THEN 
				LET cCodRet = "00052";
				RETURN 
						cCodRet,cNumeroCliente,cNacionalidad,cEmail,cEjecutivo_alta,cCdomiciliacion,cDDomiliciacion,cCBPI,cDBPI,cCpagos,cDpagos,cEstado_civil,clugar_nac,
                        cNo_fm3,cCurp,cEscolaridad,cProfesion,cClienteCop,CDPuesto_ppes,cActividad_esp,cFamiliar_ppes,crazon_social,csufijo,cpagina_internet,cgiro,cDActividad_social,
                        cnombre_titular,csat_fea,ctelefono_contacto,cescritura_constitutiva,cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip,cfecha_constitct,
                        cescritura_poderes,cnombre_notariopd,cnumero_notariopd,cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,dFecha_alta,cDescLugarNacimiento, cActividadEc, cSubActividadEc;	
			END IF			
		END IF
		IF 	cTpo_persona IS NULL THEN 
			RETURN 
			cCodRet,cNumeroCliente,cNacionalidad,cEmail,cEjecutivo_alta,cCdomiciliacion,cDDomiliciacion,cCBPI,cDBPI,cCpagos,cDpagos,cEstado_civil,clugar_nac,
            cNo_fm3,cCurp,cEscolaridad,cProfesion,cClienteCop,CDPuesto_ppes,cActividad_esp,cFamiliar_ppes,crazon_social,csufijo,cpagina_internet,cgiro,cDActividad_social,
            cnombre_titular,csat_fea,ctelefono_contacto,cescritura_constitutiva,cnombre_notarioct,cnumero_notarioct,cciudad_notarioct,cfecha_inscrip,cfecha_constitct,
            cescritura_poderes,cnombre_notariopd,cnumero_notariopd,cciudad_notariopd,cfecha_inscrippd,cnombre_sociedad,cSucursal,dFecha_alta,cDescLugarNacimiento, cActividadEc, cSubActividadEc;
		END IF
    END
END PROCEDURE
DOCUMENT		
"AUTOR : JosÃ© Antonio Ramirez Franco",
"FUNCIONAMIENTO:SP Clon de sp_cnsif_consctedetalle se encarga de Realizar la busqueda de los datos del cliente dependiendo si es persona fisica o moral, evaluar el numero de cliente y dependiendo del tipo cliente",
"haga la busqueda ya sea persona fisica o moral y regrese los valores correspondientes",
"FECHA : 23-10-2023",
"MODIFICO : JosÃ© Antonio Ramirez Franco",
"DESCRIPCION: Se agrega ID de subactividad economica al momento de consultar la actividad economica",
"FECHA : 20-08-2024",
"BD    : bdicnweb";

CREATE PROCEDURE "informix".sp_consproductoscap(pIdProducto INT)
    RETURNING CHAR(5)  AS codret,
			  INT AS idProducto, 
			  CHAR(200) AS tasaintvariable, 
			  CHAR(10) AS gatNominal, 
			  CHAR(10) AS gatReal, 
			  CHAR(200) AS comisionRel1, 
			  CHAR(200) AS comisionRel2, 
			  CHAR(200) AS mediosDisposicion, 
			  CHAR(200) AS lugEfectRetiros;

    --DECLARACÃON DE VARIABLES
    DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdProducto INT;
	DEFINE cTasaintvariable CHAR(200);
	DEFINE cGatNominal CHAR(10);
	DEFINE cGatReal CHAR(10);
	DEFINE cComisionRel1 CHAR(200);
	DEFINE cComisionRel2 CHAR(200);
	DEFINE cMediosDisposicion CHAR(200);
	DEFINE cLugEfectRetiros CHAR(200);
	
    --INICIALIZACIÃN
    LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdProducto = 0;
	LET cTasaintvariable = ''; 	
	LET cGatNominal = '';
	LET cGatReal = '';
	LET cComisionRel1 = '';
	LET cComisionRel2 = '';
	LET cMediosDisposicion = '';
	LET cLugEfectRetiros = '';
	
    BEGIN
        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdProducto, cTasaintvariable, cGatNominal, cGatReal, cComisionRel1, cComisionRel2, cMediosDisposicion, cLugEfectRetiros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consproductoscap.out';
		--TRACE ON;
		
		IF pIdProducto = 0 THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdProducto, cTasaintvariable, cGatNominal, cGatReal, cComisionRel1, cComisionRel2, cMediosDisposicion, cLugEfectRetiros;
		END IF;
		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		SELECT id_prod, tasa_interes_variable, gat_nominal, gat_real, comision_relevante1, comision_relevante2, medios_disposicion, lugares_efectuar_retiros
		INTO iIdProducto, cTasaintvariable, cGatNominal, cGatReal, cComisionRel1, cComisionRel2, cMediosDisposicion, cLugEfectRetiros
		FROM bdicnweb:"informix".sw_cons_productoscaptacion
		WHERE id_prod = pIdProducto;

		IF DBINFO('sqlca.sqlerrd2') = 0  THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iIdProducto, cTasaintvariable, cGatNominal, cGatReal, cComisionRel1, cComisionRel2, cMediosDisposicion, cLugEfectRetiros;
		END IF;
		
		RETURN cCodRet, iIdProducto, cTasaintvariable, cGatNominal, cGatReal, cComisionRel1, cComisionRel2, cMediosDisposicion, cLugEfectRetiros;
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Veronica Sanchez',
'FECHA: 15/08/2024',
'DESCRIPCION: SPL encargado de realizar la consulta para obtener los valores de los productos de captaciÃ³n.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_generaportadactamec(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(20), pNumCta CHAR(20))
    RETURNING CHAR(5) 	AS      codret,                 --Codigo de retorno
		CHAR(4)         AS      codProducto,            --CODIGO DEL PRODUCTO
		CHAR(40)        AS      nomProducto,            --NOMBRE DEL PRODUCTO
		CHAR(254)       AS      razonSoc,               --RAZON SOCIAL
		CHAR(20)        AS      numCliente,             --NUMERO DEL CLIENTE
		CHAR(20)        AS      numCuenta,              --NUMERO DE LA CUENTA
		CHAR(18)        AS      clabe,                  --NUMERO CLABE
		CHAR(1)         AS      claveRegimen,           --CLAVE DEL REGIMEN DE FIRMAS
		CHAR(20)        AS      regimenFirmas,          --REGIMEN DE FIRMAS
		CHAR(20)        AS      especiManejo,           --ESPECIFICACIONES DE MANEJO, COMBINACION
		CHAR(13)        AS      rfc,                    --RFC
		DATE            AS      fechaOperacion,     --FECHA DE LA OPERACION
		CHAR(104)       AS      nombreFirmante,         --NOMBRE DE EL FIRMANTE
		CHAR(1)         AS      tipoFirma,              --TIPO DE FIRMA
		CHAR(4)         AS      sucursal,               --NUMERO DE SUCURSAL
		CHAR(40)        AS      nomsuc,                 --NOMBRE DE SUCURSAL
		CHAR(60)        AS      reca,                   --DESCRIPCION DEL RECA
		CHAR(10)        AS      hora_operacion, 
		CHAR(20)        AS      folio_operacion, 
		CHAR(3)         AS      codigo_empresa,
		CHAR(20)        AS      cuenta_ligada;
                
                
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(3);
	DEFINE iCodRetSp INTEGER;
	DEFINE  cCodProducto            CHAR(4);        --CODIGO DEL PRODUCTO   
	DEFINE  cNomProducto            CHAR(40);       --NOMBRE DEL PRODUCTO   
	DEFINE  cRazonSoc               CHAR(254);      --RAZON SOCIAL  
	DEFINE  cNumCliente             CHAR(20);       --NUMERO DEL CLIENTE    
	DEFINE  cNumCuenta              CHAR(20);       --NUMERO DE LA CUENTA   
	DEFINE  cClabe                  CHAR(18);       --NUMERO CLABE  
	DEFINE  cClaveRegimen           CHAR(1);        --CLAVE DEL REGIMEN DE FIRMAS   
	DEFINE  cRegimenFirmas          CHAR(20);       --REGIMEN DE FIRMAS     
	DEFINE  cEspeciManejo           CHAR(20);       --ESPECIFICACIONES DE MANEJO, COMBINACION       
	DEFINE  cRfc                    CHAR(13);       --RFC   
	DEFINE  dFechaOperacion     DATE;               --FECHA DE LA OPERACION 
	DEFINE  cNombreFirmante         CHAR(104);      --NOMBRE DE EL FIRMANTE 
	DEFINE  cTipoFirma              CHAR(1);        --TIPO DE FIRMA 
	DEFINE  cSucursal               CHAR(4);        --NUMERO DE SUCURSAL    
	DEFINE  cNomsuc                 CHAR(40);       --NOMBRE DE SUCURSAL    
	DEFINE  cReca                   CHAR(60);       --RECA
	DEFINE cHoraOperacion           CHAR(10);       --HORA DE GENERACIï¿½N DE LA CONSULTA
	DEFINE cFolioOperacion          CHAR(20);       --NUMERO DE CUENTA + PREFIJO P
	DEFINE cCodigoEmpresa           CHAR(3);
	DEFINE cCuentaLigada            CHAR(20);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET     cCodProducto    = "";
	LET     cNomProducto    = "";
	LET     cRazonSoc       = "";
	LET     cNumCliente     = "";
	LET     cNumCuenta      = "";
	LET     cClabe          = "";
	LET     cClaveRegimen   = "";
	LET     cRegimenFirmas  = "";
	LET     cEspeciManejo   = "";
	LET     cRfc            = "";
	LET     dFechaOperacion = "";
	LET     cNombreFirmante = "";
	LET     cTipoFirma      = "";
	LET     cSucursal       = "";
	LET     cNomsuc         = "";
	LET     cReca           = "";
	LET     cHoraOperacion  = "";
	LET     cFolioOperacion = "";
	LET     cCodigoEmpresa  = "";
	LET     cCuentaLigada   = "";

		--, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada
        
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo, cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
		END EXCEPTION;
                
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_generaportadactamec.out';
		--TRACE ON;
                
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo, cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
		ELIF pNumCta = '' AND pNumCte = '' THEN
			LET cCodRet = '00003';
			RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo, cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
		END IF;
        
                
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_permisosejecutivo(pUsuario, pIdFuncion, pNumCta, '01', '1') INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo, cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
		END IF;
                
		-- SE BUSCAN LOS DATOS DE HORA DE OPERACION, FOLIO DE OPERACION, CODIGO DE LA EMPRESA Y CUENTA LIGADA
		LET cHoraOperacion = SUBSTR(TO_CHAR(CURRENT, '%r'), 0, 8);
		LET cFolioOperacion = 'P'||TRIM(pNumCta);
				
        FOREACH 
			EXECUTE PROCEDURE bdicheq:"informix".sp_ctamec_generarptportada2('001', pNumCte, pNumCta)
            INTO cCodRetSp, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo, cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca

			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp = 110 THEN --VERIFICA QUE HAYA ALMENOS UN PARAMETRO DE BUSQUEDA
				LET cCodRet = '00003';
				RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
			ELIF iCodRetSp = 310 THEN --SOLAMENTE DEBE ENVIAR UN SOLO PARAMETRO.
				LET cCodRet = '00335';
				RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo, cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
			ELIF iCodRetSp = 104 THEN --NO EXISTE EL CLIENTE
				LET cCodRet = '00022';
				RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo, cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
			ELIF iCodRetSp = 200 THEN --NO EXISTE EL NUMERO DE CUENTA
				LET cCodRet = '00009';
				RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo, cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
			ELIF iCodRetSp = 210 THEN --NO EXISTE EL PRODUCTO
				LET cCodRet = '00016';
				RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo, cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
			ELIF iCodRetSp = 250 THEN --NO EXISTE EL NUMERO DE CUENTA
				LET cCodRet = '00009';
				RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo, cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
			ELIF iCodRetSp = 260 THEN --NO EXISTE EL NUMERO DE CUENTA EN TABLA MAENOC
				LET cCodRet = '00303';
				RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo, cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
			ELIF iCodRetSp = 270 THEN --NO EXISTE EL TIPO DE REGIMEN
				LET cCodRet = '00332';
				RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo, cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
			ELIF iCodRetSp = 300 THEN --NO HAY DATOS DE FIRMANTES CON ESOS CRITERIOS
				LET cCodRet = '00017';
				RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo, cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
			END IF;
                        
			SELECT codigo, cuenta
			INTO cCodigoEmpresa, cCuentaLigada
			FROM bdicheq:"informix".sc_nominaempresas
			WHERE numcte = cNumCliente;
			--WHERE cuenta = cNumCuenta;
						
            RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo, cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada WITH RESUME;
                        
        END FOREACH;
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angélica Hernández Pérez',
'FECHA: 29/08/2016',
'MODULO: DEBITO',
'FUNCIONALIDAD: REIMPRESION DOCUMENTOS',
'DESCRIPCION: Spl que genera la portada',
'BD: bdicnweb',
'AUTOR: Guadalupe Angélica Hernández Pérez',
'FECHA: 15/08/2024',
'DESCRIPCION: Ajuste a SP para cambiar longitud del campo razon social 104 1 254';

CREATE PROCEDURE "informix".sp_generaportadactamec2(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(20), pNumCta CHAR(20))
                RETURNING CHAR(5)       AS      codret,                 --Codigo de retorno
                                                CHAR(4)         AS      codProducto,            --CODIGO DEL PRODUCTO
                                                CHAR(40)        AS      nomProducto,            --NOMBRE DEL PRODUCTO
                                                CHAR(254)       AS      razonSoc,               --RAZON SOCIAL
                                                CHAR(20)        AS      numCliente,             --NUMERO DEL CLIENTE
                                                CHAR(20)        AS      numCuenta,              --NUMERO DE LA CUENTA
                                                CHAR(18)        AS      clabe,                  --NUMERO CLABE
                                                CHAR(1)         AS      claveRegimen,           --CLAVE DEL REGIMEN DE FIRMAS
                                                CHAR(20)        AS      regimenFirmas,          --REGIMEN DE FIRMAS
                                                CHAR(20)        AS      especiManejo,           --ESPECIFICACIONES DE MANEJO, COMBINACION
                                                CHAR(13)        AS      rfc,                    --RFC
                                                DATE            AS      fechaOperacion,     --FECHA DE LA OPERACION
                                                CHAR(104)       AS      nombreFirmante,         --NOMBRE DE EL FIRMANTE
                                                CHAR(1)         AS      tipoFirma,              --TIPO DE FIRMA
                                                CHAR(4)         AS      sucursal,               --NUMERO DE SUCURSAL
                                                CHAR(40)        AS      nomsuc,                 --NOMBRE DE SUCURSAL
                                                CHAR(60)        AS      reca,                   --DESCRIPCION DEL RECA
												CHAR(10)        AS      hora_operacion, 
												CHAR(20)        AS      folio_operacion, 
												CHAR(3)         AS      codigo_empresa,
												CHAR(20)        AS      cuenta_ligada;
                
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(3);
        DEFINE iCodRetSp INTEGER;
        DEFINE  cCodProducto            CHAR(4);        --CODIGO DEL PRODUCTO   
        DEFINE  cNomProducto            CHAR(40);       --NOMBRE DEL PRODUCTO   
        DEFINE  cRazonSoc               CHAR(254);      --RAZON SOCIAL  
        DEFINE  cNumCliente             CHAR(20);       --NUMERO DEL CLIENTE    
        DEFINE  cNumCuenta              CHAR(20);       --NUMERO DE LA CUENTA   
        DEFINE  cClabe                  CHAR(18);       --NUMERO CLABE  
        DEFINE  cClaveRegimen           CHAR(1);        --CLAVE DEL REGIMEN DE FIRMAS   
        DEFINE  cRegimenFirmas          CHAR(20);       --REGIMEN DE FIRMAS     
        DEFINE  cEspeciManejo           CHAR(20);       --ESPECIFICACIONES DE MANEJO, COMBINACION       
        DEFINE  cRfc                    CHAR(13);       --RFC   
        DEFINE  dFechaOperacion     DATE;               --FECHA DE LA OPERACION 
        DEFINE  cNombreFirmante         CHAR(104);      --NOMBRE DE EL FIRMANTE 
        DEFINE  cTipoFirma              CHAR(1);        --TIPO DE FIRMA 
        DEFINE  cSucursal               CHAR(4);        --NUMERO DE SUCURSAL    
        DEFINE  cNomsuc                 CHAR(40);       --NOMBRE DE SUCURSAL    
        DEFINE  cReca                   CHAR(60);       --RECA
		DEFINE cHoraOperacion           CHAR(10);       --HORA DE GENERACIÃN DE LA CONSULTA
		DEFINE cFolioOperacion          CHAR(20);       --NUMERO DE CUENTA + PREFIJO P
		DEFINE cCodigoEmpresa           CHAR(3);
		DEFINE cCuentaLigada            CHAR(20);
		
		

        
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET     cCodProducto    = "";
        LET     cNomProducto    = "";
        LET     cRazonSoc       = "";
        LET     cNumCliente     = "";
        LET     cNumCuenta      = "";
        LET     cClabe          = "";
        LET     cClaveRegimen   = "";
        LET     cRegimenFirmas  = "";
        LET     cEspeciManejo   = "";
        LET     cRfc            = "";
        LET     dFechaOperacion = "";
        LET     cNombreFirmante = "";
        LET     cTipoFirma      = "";
        LET     cSucursal       = "";
        LET     cNomsuc         = "";
        LET     cReca           = "";
		LET     cHoraOperacion  = "";
		LET     cFolioOperacion = "";
		LET     cCodigoEmpresa  = "";
		LET     cCuentaLigada   = "";
                
				
		--, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,
                        cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
                END EXCEPTION;
                
           --     SET DEBUG FILE TO '/informix/vamilan/sp_generaportadactamec2.out';
             --   TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = ''  THEN
                        LET cCodRet = '00003';
                        RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,
                        cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
                ELIF pNumCta = '' AND pNumCte = '' THEN
                        LET cCodRet = '00003';
                        RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,
                        cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
                END IF;
        
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_permisosejecutivo(pUsuario, pIdFuncion, pNumCta, '01', '1') INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,
                        cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
                END IF;
                
				-- SE BUSCAN LOS DATOS DE HORA DE OPERACION, FOLIO DE OPERACION, CODIGO DE LA EMPRESA Y CUENTA LIGADA
				LET cHoraOperacion = SUBSTR(TO_CHAR(CURRENT, '%r'), 0, 8);
				LET cFolioOperacion = 'P'||TRIM(pNumCta);
				
                FOREACH EXECUTE PROCEDURE bdicheq:"informix".sp_ctamec_generarptportadaproducto2_1('001', pNumCte, pNumCta)
                        INTO cCodRetSp, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,
                                cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca

                        LET iCodRetSp = cCodRetSp::INTEGER;
                        IF iCodRetSp = 110 THEN --VERIFICA QUE HAYA ALMENOS UN PARAMETRO DE BUSQUEDA
                                LET cCodRet = '00003';
                                RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,
                                        cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
                        ELIF iCodRetSp = 310 THEN --SOLAMENTE DEBE ENVIAR UN SOLO PARAMETRO.
                                LET cCodRet = '00335';
                                RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,
                                        cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
                        ELIF iCodRetSp = 104 THEN --NO EXISTE EL CLIENTE
                                LET cCodRet = '00022';
                                RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,
                                        cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
                        ELIF iCodRetSp = 200 THEN --NO EXISTE EL NUMERO DE CUENTA
                                LET cCodRet = '00009';
                                RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,
                                        cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
                        ELIF iCodRetSp = 210 THEN --NO EXISTE EL PRODUCTO
                                LET cCodRet = '00016';
                                RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,
                                        cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
                        ELIF iCodRetSp = 250 THEN --NO EXISTE EL NUMERO DE CUENTA
                                LET cCodRet = '00009';
                                RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,
                                        cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
                        ELIF iCodRetSp = 260 THEN --NO EXISTE EL NUMERO DE CUENTA EN TABLA MAENOC
                                LET cCodRet = '00303';
                                RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,
                                        cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
                        ELIF iCodRetSp = 270 THEN --NO EXISTE EL TIPO DE REGIMEN
                                LET cCodRet = '00332';
                                RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,
                                        cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
                        ELIF iCodRetSp = 300 THEN --NO HAY DATOS DE FIRMANTES CON ESOS CRITERIOS
                                LET cCodRet = '00017';
                                RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,
                                        cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada;
                        END IF;
                        
						SELECT codigo, cuenta
						INTO cCodigoEmpresa, cCuentaLigada
						FROM bdicheq:"informix".sc_nominaempresas
						WHERE numcte = cNumCliente;
						--WHERE cuenta = cNumCuenta;
						
                        RETURN  cCodRet, cCodProducto, cNomProducto, cRazonSoc, cNumCliente, cNumCuenta, cClabe, cClaveRegimen, cRegimenFirmas, cEspeciManejo,
                                        cRfc, dFechaOperacion, cNombreFirmante, cTipoFirma, cSucursal, cNomSuc, cReca, cHoraOperacion, cFolioOperacion, cCodigoEmpresa, cCuentaLigada WITH RESUME;
                        
                END FOREACH;
        END;
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando MartÃ­n',
'FECHA: 03/07/2014',
'DESCRIPCION: Sp que genera la portada',
'AUTOR: Oscar Flores Conde',
'FECHA: 17/12/2014',
'DESCRIPCION: Se agrega el dato de salida del RECA (Registro de Contratos de AdhesiÃ³n)',
'AUTOR: Oscar Flores Conde',
'FECHA: 21/01/2016',
'DESCRIPCION: Se agregan los parametros de salida hora de operacion, folio de operacion, codigo de la empresa y cuenta ligada',
'BD: bdicnweb',
'AUTOR MODIFICACION: Uriel CaamaÃ±o Mejia',
'BD: bdicnweb',
'FECHA: 01/12/2017',
'DESCRIPCION: Se clona el SPL y se agregan nuevas reglas de negocio para el comportamiento de los productos';

CREATE PROCEDURE "informix".sp_generareportemedianainflacion(pUsuario CHAR(8), pIdFuncion CHAR(10))
RETURNING CHAR(5) 		AS codret,
		  CHAR(4) 		AS producto,
		  CHAR(30)		AS desc_producto,
		  DECIMAL(9,6) 	AS tasa,
		  DECIMAL (9,6) AS med_inflacion,
		  CHAR(2) 		AS periodo,
		  DECIMAL(9,6)  AS gat_nominal,
		  DECIMAL(9,6)  AS gat_real;

/*=====================================
|     DEFINICIÓN DE VARIABLES         |
=====================================*/
	DEFINE iSqlErr 			INTEGER;
	DEFINE cCodRet 			CHAR(5);

	DEFINE cProducto       	CHAR(5);
	DEFINE cDescProducto   	CHAR(30);
    DEFINE dTasa           	DECIMAL (9,6);
    DEFINE dMedInflacion   	DECIMAL(9,6);
    DEFINE cPeriodo        	CHAR (2);
    DEFINE dGatNominal      DECIMAL (9,6);
    DEFINE dGatReal         DECIMAL (9,6);
	DEFINE dFecha 			DATE;
	DEFINE iTotalReg		INTEGER;

/*======================================
|     INICIALIZACIÓN DE VARIABLES      |
======================================*/
	LET iSqlErr = 0;
	LET cCodRet = "00000";

	LET cProducto       = '';
	LET cDescProducto	= '';
    LET dTasa           = 0.0;
    LET dMedInflacion   = 0.0;
    LET cPeriodo         = '';
    LET dGatNominal      = 0.0;
    LET dGatReal         = 0.0;	
	LET dFecha			 = '';
	LET iTotalReg		 = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cProducto, cDescProducto, dTasa, dMedInflacion, cPeriodo, dGatNominal, dGatReal;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_generareportemedianainflacion.out';
		--TRACE ON;

		IF  pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cProducto, cDescProducto, dTasa, dMedInflacion, cPeriodo, dGatNominal, dGatReal;
		END IF;

		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet, cProducto, cDescProducto, dTasa, dMedInflacion, cPeriodo, dGatNominal, dGatReal;
			END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF EXISTS (SELECT med_inflacion FROM bdicheq:sc_medianainflacion) THEN

			DELETE FROM sw_reportemediainflacion_tmp WHERE usuario = pUsuario;

			SELECT (med.med_inflacion)  
			INTO dMedInflacion 
			FROM bdicheq:sc_medianainflacion med 
			WHERE med.fecha_publicacion = (SELECT MAX(fecha_publicacion) FROM bdicheq:sc_medianainflacion);

			FOREACH
				--Generamos la lista de producto pagare,
				SELECT tasa, periodo, gat_nomina, gat_real, fecha_publicacion
				INTO dTasa, cPeriodo, dGatNominal, dGatReal, dFecha
				FROM bdinvers:"informix".sv_gat
				ORDER BY fecha_publicacion DESC

				INSERT INTO sw_reportemediainflacion_tmp(producto,desc_producto, tasa, med_inflacion, periodo, gat_nominal, gat_real, fecha ,usuario)
				VALUES ('3000', "PAGARÉ", dTasa, dMedInflacion, cPeriodo, dGatNominal, dGatReal, dFecha, pUsuario);

				LET iTotalReg = iTotalReg + 1;

			END FOREACH;

			FOREACH
			--Generamos los registros de los demas productos
				SELECT producto, desc_producto,tasa, periodo, gat_nominal, gat_real, fecha_publicacion
				INTO cProducto, cDescProducto, dTasa, cPeriodo, dGatNominal, dGatReal, dFecha
				FROM bdicheq:"informix".sc_gat sc 
				INNER JOIN bdicnweb:"informix".sw_cap_tipoproductogat cat
				ON sc.producto = cat.num_producto
				ORDER BY sc.producto

				INSERT INTO sw_reportemediainflacion_tmp(producto,desc_producto, tasa, med_inflacion, periodo, gat_nominal, gat_real, fecha, usuario)
				VALUES (cProducto, cDescProducto, dTasa, dMedInflacion, cPeriodo, dGatNominal, dGatReal, dFecha, pUsuario);

				LET iTotalReg = iTotalReg + 1;
			END FOREACH;

			IF iTotalReg > 0 THEN
				FOREACH
					SELECT producto, desc_producto, tasa, med_inflacion, periodo, gat_nominal, gat_real
					INTO cProducto, cDescProducto, dTasa, dMedInflacion, cPeriodo, dGatNominal, dGatReal
					FROM sw_reportemediainflacion_tmp
					WHERE usuario = pUsuario
					ORDER BY producto, tasa

					RETURN cCodRet, cProducto, cDescProducto, dTasa, dMedInflacion, cPeriodo, dGatNominal, dGatReal WITH RESUME;
				END FOREACH;
	
			ELSE
				LET cCodRet = '00017'; --No existe información 
				RETURN cCodRet, cProducto, cDescProducto, dTasa, dMedInflacion, cPeriodo, dGatNominal, dGatReal;
			END IF;
		ELSE
			LET cCodRet = '00001'; --No existe mediana Inflacion
			RETURN cCodRet, cProducto, cDescProducto, dTasa, dMedInflacion, cPeriodo, dGatNominal, dGatReal;
		END IF;
	END
END PROCEDURE

DOCUMENT 'AUTOR: ING. JOSÉ ANTONIO RAMÍREZ FRANCO',
'FECHA: 30/06/2023',
'MODULO: DÉBITO',
'FUNCIONALIDAD: MEDIANA INFLACIÓN ',
'DESCRIPCION: SP ENCARGADO DE REALIZAR CONSULTAR TODOS LOS PRODUCTOS CON SUS GATS NOMINALES Y REALES DE LAS TABLAS. bdicheq:sc_gat y bdinvers:"informix".sv_gat',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_genera_archivo_img_presentado(pUsuario CHAR(8), pIdFuncion CHAR(10), pNoBloque INTEGER, pRutaDescarga CHAR(50), pDireccionMac CHAR(15), totalRegTrunc INTEGER)
                RETURNING CHAR(5) AS codret,
                          CHAR(50) AS nombreArchivoImg;

        DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
        DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
        DEFINE cEmpresa CHAR(3);
        DEFINE cNombreArchivo CHAR(30);
        DEFINE iTotalCheques INTEGER;
        DEFINE mTotalImporte DECIMAL(20,2);
        DEFINE cArchivoAI CHAR(30);
        DEFINE cBanco CHAR(3);
        DEFINE cMiBanco CHAR(3);
        DEFINE pFechaHoy DATE;
        DEFINE iDayFecha INTEGER;
        DEFINE iNumBloqueImg INTEGER;
        DEFINE cNumBloqueImg CHAR(7);
        DEFINE cCadenaImgEncabezado CHAR(250);
        DEFINE cTipoRegistro CHAR(2);
        DEFINE cNumSecuencia CHAR(7);
        DEFINE cVersion CHAR(3);
        DEFINE cCodOperacion CHAR(2);
        DEFINE cSentido CHAR(1);
        DEFINE cMoneda CHAR(1);
        DEFINE cFechaProceso CHAR(8);
        DEFINE cUsoFuturo CHAR(1);
        DEFINE cCadenaImgDetalle CHAR(5000);
        DEFINE mMontoImagen DECIMAL(14,2);
        DEFINE iContIntercambio INTEGER;
        DEFINE cCodigoSeguridad CHAR(3);
        DEFINE cImported CHAR(15);
        DEFINE cImportes CHAR(16);
        DEFINE cMonto CHAR(12);
        DEFINE cMontos CHAR(13);
        DEFINE cCents CHAR(2);
        DEFINE bImagenF BLOB;
        DEFINE bImagenT BLOB;
        DEFINE cImagenFormatoT CHAR(3);
        DEFINE cImagenFormatoF CHAR(3);
        DEFINE iTotalChq INTEGER;
        DEFINE cTotalRegistros CHAR(9);
        DEFINE cCadenaImgSumario CHAR(100);
        DEFINE iExistenImgsDigitalizadas INTEGER;
        DEFINE iIdConsultaDetalleCheque40 INTEGER;
        DEFINE cDescBanco CHAR (40);
        DEFINE cCuentaReferencia CHAR(20);
        DEFINE cNumCheque INTEGER;
        DEFINE mImporte DECIMAL(14,2);
        DEFINE cCuentaDeposito CHAR(20);
        DEFINE cSucursalOperadora CHAR(44);
        DEFINE cChqProcesado CHAR(1);
        DEFINE cChqCompensacion CHAR(3);
        DEFINE cChqTransaccion CHAR(2);
        DEFINE cChqCodSeguridad CHAR(3);
        DEFINE cChqDigVerPre CHAR(1);
        DEFINE cChqDigVerInter CHAR(1);
        DEFINE cTransaccion CHAR(4);
        DEFINE cNombreCte CHAR(60);
        DEFINE cRfcCte CHAR(13);
        DEFINE cCurpCte CHAR(20);
        DEFINE cTipoCuentaDep CHAR(2);
        DEFINE cIndImgCheque CHAR(1);
        DEFINE iTamAnvImgCheque INTEGER;
        DEFINE iTamRevImgCheque INTEGER;
        DEFINE cEjecutivo CHAR(8);
        DEFINE cDireccionMac CHAR(15);
        DEFINE cIndDuplicado CHAR(1);
        DEFINE cIdStatusProceso CHAR(1);
        DEFINE cRowId INTEGER;
        DEFINE cSQL CHAR(1000);
        DEFINE cSumario CHAR(117);
        DEFINE cEncabezado CHAR(117);
        DEFINE cCommand CHAR(500);
        DEFINE cRutaArchivo CHAR(500);
        DEFINE cRutaJava CHAR(500);

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET cEmpresa = '001';
        LET cNombreArchivo = '';
        LET iTotalCheques = 0;
        LET mTotalImporte = 0.0;
        LET iContIntercambio = 0;
        LET cArchivoAI = '';
        LET cBanco = '';
        LET cMiBanco = '';
        LET pFechaHoy = NULL;
        LET iDayFecha = 0;
        LET cNombreArchivo = '';
        LET iNumBloqueImg = 0;
        LET cCadenaImgEncabezado = '';
        LET cTipoRegistro = '';
        LET cNumSecuencia = '';
        LET cVersion = '';
        LET cCodOperacion = '';
        LET cSentido= '';
        LET cMoneda = '';
        LET cFechaProceso = '';
        LET cUsoFuturo = '';
        LET cCadenaImgDetalle = '';
        LET mMontoImagen = 0.0;
        LET iContIntercambio = 0;
        LET cCodigoSeguridad = '';
        LET cMonto = '';
        LET cCents = '';
        LET bImagenF = null;
        LET bImagenT = null;
        LET cImagenFormatoT = '';
        LET cImagenFormatoF = '';
        LET iTotalChq = 0;
        LET mTotalImporte = 0.0;
        LET cTotalRegistros = '';
        LET cCadenaImgSumario = '';
        LET iExistenImgsDigitalizadas = 0;
        LET iIdConsultaDetalleCheque40 = 0;
        LET cDescBanco = '';
        LET cCuentaReferencia = '';
        LET cNumCheque = 0;
        LET mImporte = 0.0;
        LET cCuentaDeposito = '';
        LET cSucursalOperadora ='';
        LET cChqProcesado = '';
        LET cChqCompensacion = '';
        LET cChqTransaccion = '';
        LET cChqCodSeguridad = '';
        LET cChqDigVerPre = '';
        LET cChqDigVerInter = '';
        LET cTransaccion = '';
        LET cNombreCte = '';
        LET cRfcCte = '';
        LET cCurpCte = '';
        LET cTipoCuentaDep = '';
        LET cIndImgCheque = '';
        LET iTamAnvImgCheque = 0;
        LET iTamRevImgCheque = 0;
        LET cEjecutivo = '';
        LET cDireccionMac = '';
        LET cIndDuplicado = '';
        LET cIdStatusProceso = '';
        LET cRowId = 0;
        LET cSQL = '';
        LET cImported = '';
        LET cImportes = '';
        LET cMontos = '';
        LET cNumBloqueImg = '';
        LET cSumario = '';
        LET cEncabezado = '';
        LET cCommand = '';
        LET cRutaArchivo = '/home/intersoc/';
        LET cRutaJava = '/usr/java8'; --Parametrizar produccion

        BEGIN

                ON EXCEPTION SET iSqlErr
                    LET cCodRet = iSqlErr;
                    RETURN cCodRet,'';
                END EXCEPTION;
                
                ON EXCEPTION IN (-668, -535, -255)
                END EXCEPTION WITH RESUME;

                --SET DEBUG FILE TO '/tmp/mfinis/sp_ope_genera_archivo_img_presentado.out';
                --TRACE ON;

                IF pUsuario = '' OR pIdFuncion = '' OR pNoBloque IS NULL OR pRutaDescarga = '' OR pDireccionMac = '' OR totalRegTrunc IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet,'';
                END IF;

                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet,'';
                END IF;

               
                -- SE VALIDA QUE EXISTAN IMAGENES DIGITALIZADAS
                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;

                SELECT COUNT(ind_img_cheque)
				INTO iExistenImgsDigitalizadas
				FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
				WHERE ejecutivo = pUsuario
					AND direccion_mac = pDireccionMac
					AND ind_img_cheque = '2';

				IF iExistenImgsDigitalizadas = 0 THEN
					-- MANDASR MENSAJE DE QUE NO EXISTEN REGISTROS COMPLETOS
					LET iExistenImgsDigitalizadas = 0;
					SELECT COUNT(ind_img_cheque)
					INTO iExistenImgsDigitalizadas
					FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
					WHERE ejecutivo = pUsuario
						AND direccion_mac = pDireccionMac
						AND ind_img_cheque = '1';

					IF iExistenImgsDigitalizadas = 0 THEN
						LET cCodRet = '00780';
						 RETURN cCodRet,TRIM(cArchivoAI);
					END IF;

				END IF;



                SELECT  valor INTO cBanco FROM bdinteg:si_param WHERE empresa = cEmpresa AND cod_param ='5';
                SELECT fecha_hoy INTO pFechaHoy from bdicheq:sc_fechas where empresa = '001';
                LET iDayFecha = DAY(pFechaHoy);
                LET iContIntercambio = 1;
                LET cNombreArchivo = 'PRE_'||TO_CHAR(DATE(pFechaHoy), '%d%m%Y');
                LET cMiBanco = LPAD(cBanco,3,'0');

                SELECT count(nombrearchivo) INTO iNumBloqueImg FROM bditef:cce_gransumario WHERE nombrearchivo[1,12] =cNombreArchivo AND total_reg_ti <> '0';

                LET iNumBloqueImg = iNumBloqueImg;

                LET cArchivoAI ="EAI"||cMiBanco||"A1.AI"||LPAD(TO_CHAR(iDayFecha),2,'0')||LPAD(TO_CHAR(iNumBloqueImg),3,'0');



                IF totalRegTrunc > 0 THEN
                        --=========================
                        -- AI ENCABEZADO IMAGENES
                        --=========================
                        LET cCadenaImgEncabezado = '';

                        LET cTipoRegistro = '01';
                        LET cNumSecuencia = '0000001';
                        LET cVersion = '051';
                        LET cCodOperacion = '40';

                        LET cSentido= 'E';
                        LET cMoneda = '1';
                        LET cNumBloqueImg = LPAD(iNumBloqueImg,7,'0');
                        LET cUsoFuturo = ' ';


                        LET cFechaProceso = TO_CHAR(DATE(pFechaHoy), '%Y%m%d');

                        LET cEncabezado = cTipoRegistro||cNumSecuencia||cVersion||cCodOperacion||cMiBanco||cSentido||cMoneda||cNumBloqueImg||cFechaProceso||LPAD(cUsoFuturo,83,' ');

                        --=========================
                        -- AI DETALLE IMAGENES
                        --=========================

                        LET cCadenaImgDetalle = '';

                        SELECT valor INTO mMontoImagen  FROM bditef:cce_param WHERE empresa = cEmpresa AND cod_param = '2';
                        LET iTotalChq = 0;
                        LET mTotalImporte = 0.0;

                        DELETE FROM bdicnweb:"informix".ccep_procesdetalleimg_tmp;
                        
                        BEGIN WORK;

                        FOREACH SELECT id_consultadetallecheque40, banco, desc_banco, cuenta_referencia, num_cheque, importe, cuenta_deposito, sucursal_operadora,
                                chq_procesado, chq_compensacion,chq_transaccion, chq_cod_seguridad, chq_dig_ver_pre, chq_dig_ver_inter, transaccion, nombre_cte, rfc_cte,
                                curp_cte,tipo_cuenta_dep, ind_img_cheque, tam_anv_img_cheque,tam_rev_img_cheque, ejecutivo,direccion_mac,ind_duplicado,id_status_proceso,
                                imagenf,imagent,imagen_formatof,imagen_formatot
                                INTO iIdConsultaDetalleCheque40,cBanco,cDescBanco,cCuentaReferencia, cNumCheque,mImporte,cCuentaDeposito,cSucursalOperadora,cChqProcesado,
                                cChqCompensacion,cChqTransaccion,cChqCodSeguridad,cChqDigVerPre,cChqDigVerInter,cTransaccion,cNombreCte,cRfcCte,cCurpCte,cTipoCuentaDep,
                                cIndImgCheque,iTamAnvImgCheque,iTamRevImgCheque,cEjecutivo,cDireccionMac,cIndDuplicado,cIdStatusProceso,
                                bImagenF,bImagenT,cImagenFormatoF,cImagenFormatoT
                                FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
                                WHERE ejecutivo = pUsuario
                                AND direccion_mac = pDireccionMac
                                AND imagenf IS NOT NULL
                                AND imagent IS NOT NULL


                                IF mImporte > mMontoImagen AND cIndImgCheque = '1'  THEN
                                        IF iTamAnvImgCheque IS NOT NULL AND iTamRevImgCheque IS NOT NULL THEN
                                                LET iContIntercambio = iContIntercambio + 1;
                                                LET cTipoRegistro = '02';
                                                LET cNumSecuencia = LPAD(TO_CHAR(iContIntercambio),7,'0');
                                                LET cCodOperacion = '40';
                                                LET cCodigoSeguridad = LPAD(TRIM(cChqCodSeguridad),3,'0');
                                                --TRACE cCodigoSeguridad;
                                                --TRACE cImported;
                                                LET cImported = '';
                                                LET cImported = TO_CHAR(mImporte);
                                                LET cMonto = substr(cImported, 1, CHARINDEX('.', cImported) - 1);
                                                LET cMonto = LPAD(TRIM(cMonto),12,'0');
                                                LET cCents = substr(cImported, CHARINDEX('.', cImported) + 1);
                                                LET cCents = LPAD(TRIM(cCents),2,'0');
                                                LET cImported = TRIM(cMonto || cCents);
                                                
                                                --TRACE cImported;
                                                LET cUsoFuturo = '_';


                                                INSERT INTO bdicnweb:"informix".ccep_procesdetalleimg_tmp
                                                (tipoRegistro,numSecuencia,codOperacion,fechaProceso,bancoPropio,moneda,codigoSeguridad,
                                                chqDigVerPre,chqTransaccion,chqCompensacion,cBanco,chqDigInter,
                                                cuentaReferencia,numCheque,importeStr,usoFuturo,tamAnvImgCheque,
                                                tamRevImgCheque,imagenF,imagenT
                                                )VALUES
                                                (cTipoRegistro,cNumSecuencia,cCodOperacion,cFechaProceso,cMiBanco,cMoneda,cCodigoSeguridad,
                                                cChqDigVerPre,LPAD(cChqTransaccion,2,'0'),LPAD(cChqCompensacion,3,'0'),LPAD(cBanco,3,'0'),cChqDigVerInter,
                                                LPAD(cCuentaReferencia,13,'0'),LPAD(cNumCheque,10,'0'),cImported,LPAD(cUsoFuturo,13,'_'),LPAD(TO_CHAR(iTamAnvImgCheque),15,'0'),
                                                LPAD(TO_CHAR(iTamRevImgCheque),15,'0'),bImagenF,bImagenT);


                                                LET iTotalChq = iTotalChq + 1;
                                                LET mTotalImporte = mTotalImporte + mImporte;

                                        END IF;
                                END IF;
                        END FOREACH;
                        COMMIT;

                        
                        --=========================
                        -- AI SUMARIO IMAGENES
                        --=========================
                        LET cTipoRegistro = '09';
                        LET cNumSecuencia = LPAD(TO_CHAR(iContIntercambio + 1),7,'0');
                        LET cTotalRegistros = LPAD(TO_CHAR(iTotalChq ),9,'0');
                        LET cImportes = '';
                        LET cImportes = TO_CHAR(mTotalImporte);
                        LET cMontos = substr(cImportes, 1, CHARINDEX('.', cImportes) - 1);
                        LET cMontos = LPAD(TRIM(cMontos),13,'0');
                        LET cCents = substr(cImportes, CHARINDEX('.', cImportes) + 1);
                        LET cCents = LPAD(TRIM(cCents),2,'0');
                        LET cImportes = '0'||cMontos || cCents;
                  
                        LET cUsoFuturo = ' ';


                        LET cSumario = cTipoRegistro||cNumSecuencia||cTotalRegistros||cImportes||LPAD(cUsoFuturo,83,' ');
                        
                        SET ISOLATION TO DIRTY READ;
                        SET LOCK MODE TO WAIT 3;
						
                        LET cCommand = TRIM(cRutaJava)||"/bin/java -jar "||TRIM(cRutaArchivo)||"GeneraArchivoCCEAI.jar '"||TRIM(cArchivoAI)||"' '"|| cSumario ||"' '"|| cEncabezado||"' '"|| TRIM(pRutaDescarga)||"'";
        
                        SYSTEM(TRIM(cCommand));

                END IF;		
                RETURN cCodRet,TRIM(cArchivoAI);
        END;

END PROCEDURE
DOCUMENT 'AUTOR: Saul Ortiz Baeza',
'FECHA: 18/02/2016',
'MODULO: Camara de Compensacion Electonica Presentada',
'FUNCIONALIDAD: Generacion de Archivo',
'DESCRIPCION: realiza la generacion del archivo de intercambio Codigo 40 a presentar',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_remesasguardarespuestawu2(
pUsuario                CHAR(8), 
pIdFuncion              CHAR(10), 
pMarca					CHAR(2),
pForeignRsRefNumRq    	CHAR(16),
pMtcn              	    CHAR(10),
pFechaHoraRq       	    CHAR(25),
pRetCode         		CHAR(5),
pEmisorNameType     	CHAR(1),
pEmisorNombre1          CHAR(40),
pEmisorNombre2          CHAR(40),
pEmisorApPaterno    	CHAR(40),
pEmisorApMaterno    	CHAR(40),
pEmisorCiudad       	CHAR(20),
pEmisorEdo          	CHAR(40),
pEmisorCodPais      	CHAR(3),
pEmisorCodMoneda    	CHAR(3),
pEmisorCp           	CHAR(8), 
pEmisorCalle        	CHAR(30), 
pEmisorTel          	CHAR(15), 
pBenefNameType 			CHAR(1),
pBenefNombre1           CHAR(40),
pBenefNombre2           CHAR(40),
pBenefApaterno      	CHAR(40), 
pBenefAmaterno      	CHAR(40),
pBenefCiudad        	CHAR(20), 
pBenefEdo           	CHAR(40), 
pBenefCodPais       	CHAR(3),
pBenefCodMoneda     	CHAR(3), 
pBenefCp            	CHAR(8), 
pBenefCalle         	CHAR(30), 
pBenefTelPart       	CHAR(15),
pBenefTelCel       		CHAR(10), 
pMontoTotalOrigen  		CHAR(10),
pMontoToTDestino    	CHAR(10),
pMontoOrigen        	CHAR(10),
pMontoCargos        	CHAR(10), 
pCdOrigenPago       	CHAR(30), 
pTipoCambio         	CHAR(10),
pFechaAltaRemesa    	CHAR(8),
pHoraAltaRemesa     	CHAR(16), 
pMoneyTransKey      	CHAR(10),
pEstatusRemesa      	CHAR(4), 
pNewMtcn            	CHAR(16),
pFusionStatus       	CHAR(4),
pNoPaginas          	CHAR(2),
pPaginaActual       	CHAR(2), 
pNumCoincidencias   	CHAR(2), 
pForeignRsSystemIdRp  	CHAR(11), 
pForeignRsRefNumRp      CHAR(16), 
pForeingRsCantIdRp      CHAR(11),
pDescError              CHAR(250),
pPartnerIdErr           CHAR(10) 
)
RETURNING CHAR(5) AS codret;

DEFINE cCodRet   CHAR(5);
DEFINE iSqlErr   INTEGER;
DEFINE cCodRetSp CHAR(3);
DEFINE iCodRetSp INTEGER;
DEFINE iNoRegistros INTEGER;
DEFINE cEmpresa     CHAR(3);
DEFINE cError_Desc  CHAR(30);
	
	
LET cCodRet = '00000';
LET iSqlErr = 0;
LET cCodRetSp = '';
LET iCodRetSp = 0;
LET iNoRegistros = 0;
LET cEmpresa='001';
LET cError_Desc	 = '';

BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_remesasguardarespuestawu2.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		EXECUTE PROCEDURE bdisac:"informix".sp_sac_wu_guardarespuesta_search_web(cEmpresa,pUsuario,pMarca,pForeignRsRefNumRq,pMtcn,pFechaHoraRq,pRetCode,pEmisorNameType,pEmisorNombre1,
		pEmisorNombre2,pEmisorApPaterno,pEmisorApMaterno,pEmisorCiudad,pEmisorEdo,pEmisorCodPais,pEmisorCodMoneda,pEmisorCp,pEmisorCalle,pEmisorTel,pBenefNameType,pBenefNombre1,
		pBenefNombre2,pBenefApaterno,pBenefAmaterno,pBenefCiudad,pBenefEdo,pBenefCodPais,pBenefCodMoneda,pBenefCp,pBenefCalle,pBenefTelPart,pBenefTelCel,pMontoTotalOrigen,pMontoToTDestino,
		pMontoOrigen,pMontoCargos,pCdOrigenPago,pTipoCambio,pFechaAltaRemesa,pHoraAltaRemesa,pMoneyTransKey,pEstatusRemesa,pNewMtcn,pFusionStatus,pNoPaginas,pPaginaActual,
		pNumCoincidencias,pForeignRsSystemIdRp,pForeignRsRefNumRp,pForeingRsCantIdRp,pDescError,pPartnerIdErr,current,pUsuario,current, '')
		INTO cCodRetSp ,cError_Desc;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdisac:sp_sac_wu_guardarespuesta_search_web";
		ELIF iCodRetSp = 27 THEN
			LET cCodRet = '00976'; -- USUARIO NO TIENE ID. ASIGNADO
		ELIF iCodRetSp = 26 THEN
			LET cCodRet = '00025'; -- NO EXISTE USUARIO, 			 	EL USUARIO NO EXISTE
		ELIF iCodRetSp = 23 THEN
			LET cCodRet = '00978'; -- SE TIENE QUE REVERSAR PRIMERO ANTES DE INTENTAR EL PAGO NUEVAMENTE	
		ELIF iCodRetSp = 3 THEN
			LET cCodRet = '00977'; -- NO EXISTE MARCA EN SAC PARAM	
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00770'; -- ERROR EN EL PROCESO, 				PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
		END IF;
				
		RETURN cCodRet; 
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 05/05/2017',
'MODULO: Remesas',
'FUNCIONALIDAD: Remesas - Consulta Remesas WU',
'DESCRIPCION: Guarda respuesta de transaccion en bdisac:sac_wu_search',
'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 06/08/2024',
'DESCRIPCION: SP clon de sp_remesasguardarespuestawu que se encarda de Guarda respuesta de la transaccion en bdisac:sac_wu_search, llamando al SP sp_sac_wu_guardarespuesta_search_web',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_bccc_reenviosreptotales(pUsuario CHAR(8), pIdFuncion CHAR(10), pModo SMALLINT, pTipoSolicitud CHAR(1), 
pNumSolicitud CHAR(20), pNumCte CHAR(20),pEstatus CHAR(2), pFechaIni DATE, pFechaFin DATE)
			RETURNING
			CHAR(5) AS codigo_ret,
			INTEGER AS num_registros;
		
	DEFINE iFolio     INTEGER;
	DEFINE iSqlErr    INTEGER;
	DEFINE cCodRet    CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE cRetorno01 CHAR(20); --tiposol / numanalista
	DEFINE cRetorno02 CHAR(104); --producto /  nomanalista
	DEFINE cRetorno03 CHAR(25); --numsolic / perfilusuario
	DEFINE cRetorno04 CHAR(20); --numcte / errorcve01
	DEFINE cRetorno05 CHAR(4); --numsuc / errorcve02 
	DEFINE cRetorno06 CHAR(104); --nomcte / errorcve03
	DEFINE cRetorno07 CHAR(10); --fechasol / errorcve04
	DEFINE cRetorno08 CHAR(12); --hora / errorcve05
	DEFINE cRetorno09 CHAR(4); --estatus / errorcve06
	DEFINE cRetorno10 CHAR(4); --reenvio_exit SI o NO / errorcve07
	DEFINE cRetorno11 CHAR(10); --fecha_reenvio / errorcve08
	DEFINE cRetorno12 CHAR(4); --estatus fin / errorcve09
	DEFINE cRetorno13 CHAR(80); --motivo_reenvio/ totalbc
	DEFINE cRetorno14 CHAR(104); --nombre_analista / totalcc
	DEFINE cRetorno15 CHAR(10); -- totalglobal	
	DEFINE vCont	SMALLINT; -- Contador de solicitudes

	LET iFolio = 0;
	LET iSqlErr = 0;
	LET cCodRet = '00000';
	LET cCodRetSp = '000000';
	LET iCodRetSp = 0;
	LET iNoRegistros = 0;
	LET cRetorno01 = ''; --tiposol / numanalista
	LET cRetorno02 = ''; --producto /  nomanalista
	LET cRetorno03 = ''; --numsolic / perfilusuario
	LET cRetorno04 = ''; --numcte / errorcve01
	LET cRetorno05 = ''; --numsuc / errorcve02 
	LET cRetorno06 = ''; --nomcte / errorcve03
	LET cRetorno07 = ''; --fechasol / errorcve04
	LET cRetorno08 = ''; --hora / errorcve05
	LET cRetorno09 = ''; --estatus / errorcve06
	LET cRetorno10 = ''; --reenvio_exit SI o NO / errorcve07
	LET cRetorno11 = ''; --fecha_reenvio / errorcve08
	LET cRetorno12 = '' ; --estatus fin / errorcve09
	LET cRetorno13 = ''; --motivo_reenvio/ totalbc
	LET cRetorno14 = ''; --nombre_analista / totalcc
	LET cRetorno15 = ''; -- totalglobal	
	LET vCont	= 0; -- Contador de solicitudes
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_bccc_reenviosreptotales.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		--LIMPIA TABLA
		DELETE FROM bdicnweb:"informix".sw_mon_buro_reenviosrep WHERE usuario_inserta = pUsuario;
		
		--REALIZA CONSULTA Y LLENA TABLA 
		FOREACH 
			EXECUTE PROCEDURE bdicred:"informix".sp_mon_buro_reenviosrep(pModo, pTipoSolicitud, pNumSolicitud, pNumCte, pEstatus, pFechaIni, pFechaFin)
			INTO cCodRetSp, cRetorno01, cRetorno02, cRetorno03, cRetorno04, cRetorno05, cRetorno06, cRetorno07, cRetorno08, cRetorno09, cRetorno10, cRetorno11, 
			cRetorno12, cRetorno13, cRetorno14, cRetorno15
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicred:sp_mon_buro_reenviosrep";
			ELIF cCodRetSp::INTEGER = 3 THEN
				LET cCodRet = '00017';
			END IF;
			
			IF(cCodRet = '00000') THEN
				--SET LOCK MODE TO WAIT 3;
				INSERT INTO bdicnweb:"informix".sw_mon_buro_reenviosrep(retorno_01,retorno_02,retorno_03,retorno_04,retorno_05,retorno_06,retorno_07,retorno_08,retorno_09,retorno_10,retorno_11,retorno_12,retorno_13,retorno_14,retorno_15,usuario_inserta,fecha_insert)
				VALUES(cRetorno01, cRetorno02, cRetorno03, cRetorno04, cRetorno05, cRetorno06, cRetorno07, cRetorno08, cRetorno09, cRetorno10, cRetorno11, cRetorno12, cRetorno13, cRetorno14, cRetorno15, pUsuario, CURRENT);
				
				LET vCont = vCont + 1;
				
				IF vCont = 3500 THEN EXIT FOREACH; END IF;
			END IF;
		END FOREACH;
		
		--REALIZA CONSULTA DE TOTAL DE REGISTROS
		SELECT COUNT(*)
		INTO iNoRegistros
		FROM bdicnweb:"informix".sw_mon_buro_reenviosrep
		WHERE usuario_inserta = pUsuario;
		
		IF iNoRegistros = 0 THEN			
			LET cCodRet = '00017';
			RETURN cCodRet, iNoRegistros;			
		END IF;
		
		RETURN cCodRet, iNoRegistros; 
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 25/11/2016',
'MODULO: CREDITO',
'FUNCIONALIDAD: REPORTE SOLICITUDES EN BC Y CC',
'DESCRIPCION:SPL que ejecuta sp productivo e inserta los datos en tabla auxiliar para obtener los totales del Reporte de Solicitudes en BC y CC',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_hojafirmactamec_complementoinfo(pCuenta CHAR(20))

RETURNING CHAR(5)   AS cCodRet,
		  CHAR(100) AS cMensaje,
		  CHAR(20)  AS numcliente,
		  CHAR(50)   AS tipofirma;
		  


--****************************************************************************************************
-- Objetivo:Spl que obtiene informaciÃ³n de clientes y tipo se firma
-- Autor: Nadia Ordaz
-- FECHA : 24/07/2024
-- SOLICITO : Ismael Hernandez
-- BD: bdicnweb
--***************************************************************************************************

--DEFINICIONES
	DEFINE iSql_Err                     INTEGER;
	DEFINE cCodRet         			    CHAR(5);
	DEFINE cMensaje                     CHAR(50);
	
	DEFINE numcliente         			CHAR(20);
	DEFINE tipofirma                    CHAR(50);
            
--INICIALIZACIONES			  
    LET iSql_Err           	= 0;
    LET cCodRet           	= '00000';
    LET cMensaje          	= 'SE EJECUTO CORRECTAMENTE';
	
    LET numcliente          = '';
    LET tipofirma           = '';
	
BEGIN

    ON EXCEPTION SET iSql_Err
        LET cCodRet = iSql_Err;
        LET cMensaje = '';
		RETURN cCodRet, cMensaje, numcliente, tipofirma;
    END EXCEPTION;
	
	-- SET DEBUG FILE TO "/home/sysifx/vlv/hojafirmaCtaMEC.out";
	-- TRACE ON;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF TRIM(NVL(pCuenta,'')) = '' THEN
		LET cCodRet = '00001';
		LET cMensaje = 'FALTAN PARAMETROS PARA SU EJECUCION';
		RETURN cCodRet, cMensaje, numcliente, tipofirma;
	END IF;

	FOREACH cur for							
		SELECT numcte, tipo_firma
		INTO numcliente, tipofirma
		FROM bdicheq:"informix".sc_firmantes
		WHERE empresa = '001'
			AND cuenta = pCuenta
		ORDER BY secuencia ASC
		
		RETURN cCodRet, cMensaje, numcliente, tipofirma WITH RESUME;
		
	END FOREACH;	
END;

END PROCEDURE;
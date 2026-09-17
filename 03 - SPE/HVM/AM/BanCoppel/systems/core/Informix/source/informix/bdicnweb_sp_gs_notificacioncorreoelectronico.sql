CREATE PROCEDURE "informix".sp_gs_notificacioncorreoelectronico(pUsuario CHAR(8), pIdFuncion CHAR(10), pOpcionEnvio CHAR(1), pTipoOperacion SMALLINT, pIdSolicitud INTEGER, pPlantilla CHAR(10), pTitulo CHAR(60))
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cJefeAreaUsuarioSolic CHAR(8);
	DEFINE cUsuarioSolic CHAR(8);
	DEFINE cUsuarioResponsable CHAR(8);
	DEFINE iIdAreaResponsable INTEGER;
	DEFINE cJefeUsuarioResponsable CHAR(8);
	DEFINE iIdSolicitudAnterior INTEGER;
	
	-- VARIABLES PARA EL SP DE NOTIFICACIÃ?N
	DEFINE cTipoMsj CHAR(1);
	DEFINE cIdMsj CHAR(10);
	DEFINE cNumclt CHAR(20);
	DEFINE cNumcta CHAR(20);
	DEFINE cNumTarjeta CHAR(16);
	DEFINE cTipoproc CHAR(1);
	DEFINE cStr1 CHAR(30);
	DEFINE cStr2 CHAR(30);
	DEFINE cStr3 CHAR(30);
	DEFINE cStr4 CHAR(30);
	DEFINE cStr5 CHAR(150);
	DEFINE cStr6 CHAR(100);
	DEFINE cStr7 CHAR(60);
	DEFINE cStr8 CHAR(60);
	DEFINE cStr9 CHAR(15);
	DEFINE cStr10 CHAR(100);
	DEFINE cCorreoAlterno CHAR(100);
	DEFINE cCelularAlterno CHAR(10);
	DEFINE mImporte1 MONEY(16,2);
	DEFINE mImporte2 MONEY(16,2);
	DEFINE mImporte3 MONEY(16,2);
	DEFINE mImporte4 MONEY(16,2);
	DEFINE mImporte5 MONEY(16,2);
	DEFINE dFecha1 DATETIME YEAR TO FRACTION(3);
	DEFINE dFecha2 DATETIME YEAR TO FRACTION(3);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cJefeAreaUsuarioSolic = '';
	LET cUsuarioSolic = '';
	LET cUsuarioResponsable = '';
	LET iIdAreaResponsable = 0;
	LET cJefeUsuarioResponsable = '';
	LET iIdSolicitudAnterior = 0;
	-- VARIABLES DEL SP DE NOTIFICACIÃ?N
	LET cTipoMsj = '1';
	LET cIdMsj = pPlantilla;
	LET cNumclt = '';
	LET cNumcta = '';
	LET cNumTarjeta = '';
	LET cTipoproc = '1';
	LET cStr1 = '';
	LET cStr2 = '';
	LET cStr3 = '';
	LET cStr4 = '';
	LET cStr5 = '';
	LET cStr6 = '';
	LET cStr7 = pTitulo;
	LET cStr8 = '';
	LET cStr9 = '';
	LET cStr10 = '';
	LET cCorreoAlterno = '';
	LET cCelularAlterno = '';
	LET mImporte1 = 1;
	LET mImporte2 = 0.00;
	LET mImporte3 = 0.00;
	LET mImporte4 = 0.00;
	LET mImporte5 = 0.00;
	LET dFecha1 = NULL;
	LET dFecha2 = NULL;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_notificacioncorreoelectronico.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoOperacion IS NULL OR pPlantilla = '' OR pIdSolicitud IS NULL OR pTitulo = '' OR pOpcionEnvio = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		IF pOpcionEnvio NOT IN ('S', 'R') THEN
			LET cCodRet = '00148';
			RETURN cCodRet;
		END IF;
		
		IF pTipoOperacion NOT IN (1, 2, 3, 4, 5) THEN
			LET cCodRet = '00148';
			RETURN cCodRet;
		END IF;
		
		
		IF pOpcionEnvio = 'S' THEN
			IF pTipoOperacion IN (1, 3, 4) THEN -- ENVIO DE SOLICITUD, REINTENTO, CANCELACIÃ?N
				SET ISOLATION TO DIRTY READ;
			
				-- CONSULTA DE DATOS PARA EL CORREO
				SELECT TRIM(a.folio_solicitud||' '||b.descripcion_solicitud) AS solicitud,
					TRIM(a.usuario_solicitante)||' '||c.nombre AS usuario_solicitante,
					d.desc_status_solicitud,
					(SELECT ejecutivo||' '||nombre FROM bdinteg:si_ejecut WHERE ejecutivo = a.usuario_responsable) AS usuario_responsable,
					(SELECT descripcion_area FROM sw_gs_area WHERE id_area = a.id_area_responsable) AS area_responable,
					fecha_solicitud as fecha_solicitud,
					EXTEND(fecha_solicitud, hour to second) as hora_solicitud
				INTO cStr8,
					cStr5,
					cStr9, 
					cStr6, 
					cStr3, 
					dFecha1, 
					dFecha2
				FROM bdicnweb:sw_gs_registrosolicitud a, 
					bdicnweb:sw_gs_solicitudes b,
					bdinteg:si_ejecut c,
					bdicnweb:sw_gs_catstatussolicitud d
				WHERE a.id_registro_solicitud = pIdSolicitud
					AND b.id_solicitud = a.id_solicitud
					AND c.ejecutivo = a.usuario_solicitante
					AND d.id_status_solicitud = a.id_status_solicitud;
					
			ELIF pTipoOperacion = 2 THEN -- ES UNA REASIGNACION
				SELECT TRIM(a.folio_solicitud||' '||b.descripcion_solicitud) AS solicitud,
					TRIM(a.usuario_solicitante)||' '||c.nombre AS usuario_solicitante,
					fecha_solicitud as fecha_solicitud,
					fecha_solicitud as hora_solicitud
				INTO cStr8, 
					cStr5, 
					dFecha1, 
					dFecha2
				FROM bdicnweb:sw_gs_registrosolicitud a, 
					bdicnweb:sw_gs_solicitudes b,
					bdinteg:si_ejecut c
				WHERE a.id_registro_solicitud = pIdSolicitud
					AND b.id_solicitud = a.id_solicitud
					AND c.ejecutivo = a.usuario_solicitante;
				
				-- BUSQUEDA DE LA SOLICITUD ANTERIOR
				SELECT MAX(id_registro_solicitud)
				INTO iIdSolicitudAnterior
				FROM bdicnweb:sw_gs_registrosolicitud
				WHERE folio_solicitud = (SELECT folio_solicitud FROM bdicnweb:sw_gs_registrosolicitud WHERE id_registro_solicitud = pIdSolicitud)
					AND id_registro_solicitud <> pIdSolicitud;
				
				-- RESPONSABLE ANTERIOR
				SELECT TRIM(TRIM(a.usuario_responsable)||' '||b.nombre), c.descripcion_area
				INTO cStr6, cStr3
				FROM bdicnweb:sw_gs_registrosolicitud a,
					bdinteg:si_ejecut b,
					bdicnweb:sw_gs_area c
				WHERE a.id_registro_solicitud = iIdSolicitudAnterior
					AND b.ejecutivo = a.usuario_responsable
					AND c.id_area = a.id_area_responsable;

				-- RESPONSABLE ACTUAL
				SELECT TRIM(TRIM(a.usuario_responsable)||' '||b.nombre), c.descripcion_area
				INTO cStr10, cStr4
				FROM bdicnweb:sw_gs_registrosolicitud a,
					bdinteg:si_ejecut b,
					bdicnweb:sw_gs_area c
				WHERE a.id_registro_solicitud = pIdSolicitud
					AND b.ejecutivo = a.usuario_responsable
					AND c.id_area = a.id_area_responsable;
				
			END IF;
			
			IF pTipoOperacion IN (1, 3, 4) THEN
			
				FOREACH SELECT usuario_responsable
						INTO cNumclt
						FROM bdicnweb:sw_gs_registrosolicitud a   
						WHERE a.id_registro_solicitud = pIdSolicitud
						UNION
						SELECT c.id_usuario 
						FROM bdicnweb:sw_gs_registrosolicitud b,
							bdicnweb:sw_gs_area_usuario c
						WHERE b.id_registro_solicitud = pIdSolicitud
							AND c.id_area = b.id_area_responsable
							AND c.jefe_area = 't'
							AND c.status = 't'
						UNION
						SELECT e.id_usuario 
						FROM bdicnweb:sw_gs_registrosolicitud d,
							bdicnweb:sw_gs_area_usuario e
						WHERE d.id_registro_solicitud = pIdSolicitud
							AND e.id_area = d.id_area_solicitante
							AND e.jefe_area = 't'
							AND e.status = 't'
						
						
					EXECUTE PROCEDURE bdimnsj:sp_registra_evento(
																	cTipoMsj, 
																	cIdMsj, 
																	cNumclt, 
																	cNumcta, 
																	cNumTarjeta, 
																	cTipoproc, 
																	cStr1, 
																	cStr2, 
																	cStr3, 
																	cStr4, 
																	cStr5, 
																	cStr6, 
																	cStr7, 
																	cStr8, 
																	cStr9, 
																	cStr10, 
																	cCorreoAlterno, 
																	cCelularAlterno, 
																	mImporte1, 
																	mImporte2, 
																	mImporte3, 
																	mImporte4, 
																	mImporte5, 
																	dFecha1, 
																	dFecha2) INTO cCodRetSp;
				
					LET iCodRetSp = cCodRetSp::INTEGER;
					IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_registra_evento';
					ELIF iCodRetSp > 0 THEN
						LET cCodRet = LPAD(iCodRetSp, 5, '0');
						RETURN cCodRet;
					END IF;	

				END FOREACH;
				
				RETURN cCodRet;
			
			ELIF pTipoOperacion = 2 THEN -- REASIGNACIÃ?N
				
				SET ISOLATION TO DIRTY READ;
				FOREACH SELECT a.usuario_responsable
						INTO cNumclt
						FROM bdicnweb:sw_gs_registrosolicitud a
						WHERE a.id_registro_solicitud = iIdSolicitudAnterior
						UNION
						SELECT a.id_usuario
						FROM sw_gs_area_usuario a, 
							bdicnweb:sw_gs_registrosolicitud b
						WHERE b.id_registro_solicitud = iIdSolicitudAnterior
							AND a.id_area = b.id_area_responsable
							AND a.jefe_area = 't'
							AND a.status = 't'
						UNION
						SELECT a.usuario_responsable
						FROM bdicnweb:sw_gs_registrosolicitud a
						WHERE a.id_registro_solicitud = pIdSolicitud
						UNION
						SELECT a.id_usuario
						FROM sw_gs_area_usuario a, 
							bdicnweb:sw_gs_registrosolicitud b
						WHERE b.id_registro_solicitud = pIdSolicitud
							AND a.id_area = b.id_area_responsable
							AND a.jefe_area = 't'
							AND a.status = 't'
						UNION
						SELECT e.id_usuario 
						FROM bdicnweb:sw_gs_registrosolicitud d,
							bdicnweb:sw_gs_area_usuario e
						WHERE d.id_registro_solicitud = pIdSolicitud
							AND e.id_area = d.id_area_solicitante
							AND e.jefe_area = 't'
							AND e.status = 't'
							
							
					EXECUTE PROCEDURE bdimnsj:sp_registra_evento(
																	cTipoMsj, 
																	cIdMsj, 
																	cNumclt, 
																	cNumcta, 
																	cNumTarjeta, 
																	cTipoproc, 
																	cStr1, 
																	cStr2, 
																	cStr3, 
																	cStr4, 
																	cStr5, 
																	cStr6, 
																	cStr7, 
																	cStr8, 
																	cStr9, 
																	cStr10, 
																	cCorreoAlterno, 
																	cCelularAlterno, 
																	mImporte1, 
																	mImporte2, 
																	mImporte3, 
																	mImporte4, 
																	mImporte5, 
																	dFecha1, 
																	dFecha2) INTO cCodRetSp;
				
					LET iCodRetSp = cCodRetSp::INTEGER;
					IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_registra_evento';
					ELIF iCodRetSp > 0 THEN
						LET cCodRet = LPAD(iCodRetSp, 5, '0');
						RETURN cCodRet;
					END IF;	
						
				END FOREACH;
				
				RETURN cCodRet;
			
			END IF;
			
		ELIF pOpcionEnvio = 'R' THEN
			IF pTipoOperacion IN (4,5) THEN -- CANCELACIÃ?N O ATENCIÃ?N
				SET ISOLATION TO DIRTY READ;
			
				-- CONSULTA DE DATOS PARA EL CORREO
				SELECT TRIM(a.folio_solicitud||' '||b.descripcion_solicitud) AS solicitud,
					TRIM(a.usuario_solicitante)||' '||c.nombre AS usuario_solicitante,
					d.desc_status_solicitud,
					(SELECT ejecutivo||' '||nombre FROM bdinteg:si_ejecut WHERE ejecutivo = a.usuario_responsable) AS usuario_responsable,
					(SELECT descripcion_area FROM sw_gs_area WHERE id_area = a.id_area_responsable) AS area_responable,
					fecha_solicitud as fecha_solicitud,
					fecha_solicitud as hora_solicitud
				INTO cStr8,
					cStr5,
					cStr9, 
					cStr6, 
					cStr3, 
					dFecha1, 
					dFecha2
				FROM bdicnweb:sw_gs_registrosolicitud a, 
					bdicnweb:sw_gs_solicitudes b,
					bdinteg:si_ejecut c,
					bdicnweb:sw_gs_catstatussolicitud d
				WHERE a.id_registro_solicitud = pIdSolicitud
					AND b.id_solicitud = a.id_solicitud
					AND c.ejecutivo = a.usuario_solicitante
					AND d.id_status_solicitud = a.id_status_solicitud;
					
			ELIF pTipoOperacion = 2 THEN -- ES UNA REASIGNACION
				SELECT TRIM(a.folio_solicitud||' '||b.descripcion_solicitud) AS solicitud,
					TRIM(a.usuario_solicitante)||' '||c.nombre AS usuario_solicitante,
					fecha_solicitud as fecha_solicitud,
					fecha_solicitud as hora_solicitud
				INTO cStr8, 
					cStr5, 
					dFecha1, 
					dFecha2
				FROM bdicnweb:sw_gs_registrosolicitud a, 
					bdicnweb:sw_gs_solicitudes b,
					bdinteg:si_ejecut c
				WHERE a.id_registro_solicitud = pIdSolicitud
					AND b.id_solicitud = a.id_solicitud
					AND c.ejecutivo = a.usuario_solicitante;
				
				-- BUSQUEDA DE LA SOLICITUD ANTERIOR
				SELECT MAX(id_registro_solicitud)
				INTO iIdSolicitudAnterior
				FROM bdicnweb:sw_gs_registrosolicitud
				WHERE folio_solicitud = (SELECT folio_solicitud FROM bdicnweb:sw_gs_registrosolicitud WHERE id_registro_solicitud = pIdSolicitud)
					AND id_registro_solicitud <> pIdSolicitud;
				
				-- RESPONSABLE ANTERIOR
				SELECT TRIM(TRIM(a.usuario_responsable)||' '||b.nombre), c.descripcion_area
				INTO cStr6, cStr3
				FROM bdicnweb:sw_gs_registrosolicitud a,
					bdinteg:si_ejecut b,
					bdicnweb:sw_gs_area c
				WHERE a.id_registro_solicitud = iIdSolicitudAnterior
					AND b.ejecutivo = a.usuario_responsable
					AND c.id_area = a.id_area_responsable;

				-- RESPONSABLE ACTUAL
				SELECT TRIM(TRIM(a.usuario_responsable)||' '||b.nombre), c.descripcion_area
				INTO cStr10, cStr4
				FROM bdicnweb:sw_gs_registrosolicitud a,
					bdinteg:si_ejecut b,
					bdicnweb:sw_gs_area c
				WHERE a.id_registro_solicitud = pIdSolicitud
					AND b.ejecutivo = a.usuario_responsable
					AND c.id_area = a.id_area_responsable;
				
			END IF;
			
			IF pTipoOperacion IN (4,5) THEN
			
				FOREACH SELECT usuario_solicitante
						INTO cNumclt
						FROM bdicnweb:sw_gs_registrosolicitud a   
						WHERE a.id_registro_solicitud = pIdSolicitud
						UNION
						SELECT c.id_usuario 
						FROM bdicnweb:sw_gs_registrosolicitud b,
							bdicnweb:sw_gs_area_usuario c
						WHERE b.id_registro_solicitud = pIdSolicitud
							AND c.id_area = b.id_area_responsable
							AND c.jefe_area = 't'
							AND c.status = 't'
						UNION
						SELECT e.id_usuario 
						FROM bdicnweb:sw_gs_registrosolicitud d,
							bdicnweb:sw_gs_area_usuario e
						WHERE d.id_registro_solicitud = pIdSolicitud
							AND e.id_area = d.id_area_solicitante
							AND e.jefe_area = 't'
							AND e.status = 't'
						
						
					EXECUTE PROCEDURE bdimnsj:sp_registra_evento(
																	cTipoMsj, 
																	cIdMsj, 
																	cNumclt, 
																	cNumcta, 
																	cNumTarjeta, 
																	cTipoproc, 
																	cStr1, 
																	cStr2, 
																	cStr3, 
																	cStr4, 
																	cStr5, 
																	cStr6, 
																	cStr7, 
																	cStr8, 
																	cStr9, 
																	cStr10, 
																	cCorreoAlterno, 
																	cCelularAlterno, 
																	mImporte1, 
																	mImporte2, 
																	mImporte3, 
																	mImporte4, 
																	mImporte5, 
																	dFecha1, 
																	dFecha2) INTO cCodRetSp;
				
					LET iCodRetSp = cCodRetSp::INTEGER;
					IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_registra_evento';
					ELIF iCodRetSp > 0 THEN
						LET cCodRet = LPAD(iCodRetSp, 5, '0');
						RETURN cCodRet;
					END IF;	

				END FOREACH;
				
				RETURN cCodRet;
			
			ELIF pTipoOperacion = 2 THEN -- REASIGNACIÃ?N
				
				SET ISOLATION TO DIRTY READ;
				FOREACH SELECT a.usuario_solicitante
						INTO cNumclt
						FROM bdicnweb:sw_gs_registrosolicitud a
						WHERE a.id_registro_solicitud = iIdSolicitudAnterior
						UNION
						SELECT a.id_usuario
						FROM sw_gs_area_usuario a, 
							bdicnweb:sw_gs_registrosolicitud b
						WHERE b.id_registro_solicitud = iIdSolicitudAnterior
							AND a.id_area = b.id_area_responsable
							AND a.jefe_area = 't'
							AND a.status = 't'
						UNION
						SELECT a.usuario_responsable
						FROM bdicnweb:sw_gs_registrosolicitud a
						WHERE a.id_registro_solicitud = pIdSolicitud
						UNION
						SELECT a.id_usuario
						FROM sw_gs_area_usuario a, 
							bdicnweb:sw_gs_registrosolicitud b
						WHERE b.id_registro_solicitud = pIdSolicitud
							AND a.id_area = b.id_area_responsable
							AND a.jefe_area = 't'
							AND a.status = 't'
						UNION
						SELECT e.id_usuario 
						FROM bdicnweb:sw_gs_registrosolicitud d,
							bdicnweb:sw_gs_area_usuario e
						WHERE d.id_registro_solicitud = pIdSolicitud
							AND e.id_area = d.id_area_solicitante
							AND e.jefe_area = 't'
							AND e.status = 't'
							
					EXECUTE PROCEDURE bdimnsj:sp_registra_evento(
																	cTipoMsj, 
																	cIdMsj, 
																	cNumclt, 
																	cNumcta, 
																	cNumTarjeta, 
																	cTipoproc, 
																	cStr1, 
																	cStr2, 
																	cStr3, 
																	cStr4, 
																	cStr5, 
																	cStr6, 
																	cStr7, 
																	cStr8, 
																	cStr9, 
																	cStr10, 
																	cCorreoAlterno, 
																	cCelularAlterno, 
																	mImporte1, 
																	mImporte2, 
																	mImporte3, 
																	mImporte4, 
																	mImporte5, 
																	dFecha1, 
																	dFecha2) INTO cCodRetSp;
				
					LET iCodRetSp = cCodRetSp::INTEGER;
					IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_registra_evento';
					ELIF iCodRetSp > 0 THEN
						LET cCodRet = LPAD(iCodRetSp, 5, '0');
						RETURN cCodRet;
					END IF;	
						
				END FOREACH;
				
				RETURN cCodRet;
			
			END IF;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 19/08/2014',
'DESCRIPCION: pTipoOperacion = 1: Envio de solicitud; 2: ReasignaciÃ³n de solicitud, 3: Reintento, 4: Cancelacion, 5: Atencion',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_reporteconciliacionconveniosucursal_pba(pUsuario CHAR(8), pIdfuncion CHAR(10), pConvenio CHAR(5), pSucursal CHAR(4), pFechaIni DATE, pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codigoretorno,
	CHAR(4) AS idsucursal,
	INTEGER AS numpagos, 
	CHAR(40) AS nomconvenio, 
	MONEY(16,2) AS importepago, 
	MONEY(16,2) AS importecomisionconvenio,
	MONEY(16,2) AS ivacomisionconvenio, 
	MONEY(16,2) AS importecomisioncte,
	MONEY(16,2) AS iva_comisioncte,
	INTEGER AS flagconfirmacioncentral,
	INTEGER AS flagconfirmacionsucursal;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE cIdSucursal CHAR(5);
	DEFINE cNumPagos INTEGER; 
	DEFINE cNomconvenio CHAR(40); 
	DEFINE mImportePago MONEY(16,2); 
	DEFINE mImporteComisionConvenio MONEY(16,2);
	DEFINE mIvaComisionConvenio MONEY(16,2);
	DEFINE mImporteComisionCte MONEY(16,2);
	DEFINE mIvaComisionCte MONEY(16,2);
	DEFINE iFlagConfirmacionCentral INTEGER;
	DEFINE iFlagConfirmacionSucursal INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iNoRegs  INTEGER;
	DEFINE iRecuperacion  INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cIdSucursal = '';
	LET cNumPagos = 0;
	LET cNomconvenio = '';
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
			LET cCodret = iSqlErr;
			RETURN cCodRet, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
			mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_reporteconciliacionconveniosucursal.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdfuncion = '' OR LENGTH(pConvenio) <> 5 OR LENGTH(pSucursal) <> 4 OR pFechaIni = '' OR pFechaFin = '' OR pRegistros = '' OR pRecuperacion = ''THEN
			LET cCodret = '00003';
			RETURN cCodRet, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
			mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
		END IF;
		IF pRecuperacion < 0 THEN
			LET cCodret = '00098';
			RETURN cCodRet, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
			mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
		END IF;

		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
			mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH EXECUTE PROCEDURE bdisac:sp_sacreporteconciliacionconveniosucursal(pConvenio, pSucursal, pFechaIni, pFechaFin) INTO
			cCodRetSp, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
			mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal

			IF 	NVL(cIdSucursal, '') = '' AND 
				NVL(cNumPagos, '') = '' AND 
				NVL(cNomconvenio, '')  = '' AND 
				NVL(mImportePago, '') = ''  AND 
				NVL(mImporteComisionConvenio, '') = '' AND
				NVL(mIvaComisionConvenio, '') = '' AND 
				NVL(mImporteComisionCte, '') = '' AND 
				NVL(mIvaComisionCte,'') = '' AND 
				NVL(iFlagConfirmacionCentral,'') = '' AND 
				NVL(iFlagConfirmacionSucursal,'') = '' THEN
				
				LET cCodRet = '00017';
				RETURN cCodRet, '', '', '', 0, 0, 0, 0, 0, 0, 0;
			ELSE
				IF cCodRetSp <> '00000' THEN
					LET cCodRet = cCodRetSp;
					RETURN cCodRet, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio, mImporteComisionCte, mIvaComisionCte,
					iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
				ELSE
					IF iRegistros >= pRegistros THEN
						IF iRecuperacion < pRecuperacion THEN
							LET iRecuperacion = iRecuperacion + 1;
							RETURN cCodRet, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio,
							mIvaComisionConvenio, mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal WITH RESUME;
							LET iNoRegs = iNoRegs + 1;
						END IF;
					END IF;
						LET iRegistros = iRegistros + 1;
				END IF;
			END IF;
		END FOREACH;
		 IF iNoRegs = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, '', '', '', 0, 0, 0, 0, 0, 0, 0;
		ELIF iNoRegs = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, '', '', '', 0, 0, 0, 0, 0, 0, 0;
		END IF;
	END;
END PROCEDURE
DOCUMENT "AUTOR:Esparza Brenis Fernando Martin",
"FECHA: 12/12/2013",
"DESCRIPCION: SP para el reporte de conciliaciÃ³n por convenios",
"DB: bdicnweb";

CREATE PROCEDURE "informix".sp_reversioncap_pba(pUsuario char(10), 
					    pIdFuncion char(10), 
					    pFolioMovimiento char(16), 
					    pSucursalFolio char(4),
						pTransacc char(4))
       RETURNING char(5) as codret;
	
DEFINE cCodRet char(5);
DEFINE cConstante char(1);
DEFINE cEmpresa char(3);
DEFINE iSqlErr int;
DEFINE cReversable char(1);
	
LET cCodRet = '00000';
LET cConstante = 'M';
LET cEmpresa = '001';
LET iSqlErr = 0;
LET cReversable = '';
	
BEGIN
		
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;


	IF pUsuario = ''
	 OR pIdFuncion = '' 
	 OR pFolioMovimiento = '' 
	 OR pSucursalFolio = ''  
	 OR pTransacc = ''
	THEN
		LET cCodRet = '00003';
		RETURN cCodRet;
	END IF;
		
	-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
	EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, 
							               pIdFuncion) 
		INTO cCodRet;
	IF cCodRet <> '00000' THEN
		RETURN cCodRet;
	END IF;
	
	-- Validacion de la transaccion para ver si puede ser reversable
	SELECT reversable
	INTO cReversable
	FROM bdinteg:"informix".si_transacc
	WHERE numero = pTransacc;

	IF cReversable IS NULL OR cReversable='' THEN
		LET cReversable='N';
	END IF;
	
	IF cReversable <> "S" THEN
		LET cCodRet = '00152'; -- No se permite realizar un reverso de esta transaccion
		RETURN cCodRet;
	END IF;
		
	EXECUTE PROCEDURE bdicheq:"informix".reversion(cEmpresa, 
					    		pSucursalFolio, 
					    		pUsuario, 
					    		pFolioMovimiento, 
					    		cConstante) 
		INTO cCodRet;
		
	IF cCodRet = '000' THEN
                LET cCodRet = '00000';
        END IF;
        IF cCodRet = '170' THEN
		LET cCodRet = '00112';
	END IF;
	IF cCodRet = '413' THEN
		LET cCodRet = '00113';
	END IF;
	IF cCodRet = '00036' THEN
		LET cCodRet = '00003';
	END IF;
	IF cCodRet = '00030' THEN
		LET cCodRet = '00114';
	END IF;
	IF cCodRet = '00037' THEN
		LET cCodRet = '00115';
	END IF;
	IF cCodRet = '00035' THEN
		LET cCodRet = '00116';
	END IF;
	IF cCodRet = '001' THEN
		LET cCodRet = '00117';
	END IF;
		
	RETURN cCodRet;
		
END;

END PROCEDURE;
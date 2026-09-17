CREATE PROCEDURE "informix".sp_consultarinforeporteanalistamc(pUsuario CHAR(8), pIdFuncion CHAR(10), pProducto CHAR(4), pFechaInicio DATE, pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5)     AS codret,
			CHAR(8)       AS ejecutivo,
			CHAR(80)      AS nombre,
			INTEGER       AS no_analizadas,
			DECIMAL(14,2) AS porcentaje_analizadas,
			INTEGER       AS num_reevaluadas,
			DECIMAL(14,2) AS porcentaje_revaluadas,
			INTEGER       AS num_revaluadas,
			DECIMAL(14,2) AS porcentaje_num_revaluadas,
			INTEGER       AS num_siguen_proceso,
			DECIMAL(14,2) AS porcentaje_sigue_proc,
			INTEGER       AS num_rechazadas,
			DECIMAL(14,2) AS porcentaje_rechazadas,
			INTEGER       AS canceladas,
			DECIMAL(14,2) AS porcentaje_canceladas,      
			INTEGER       AS num_mixta,
			DECIMAL(14,2) AS porcentaje_mixta,
			INTEGER       AS num_unica,
			DECIMAL(14,2) AS porcentaje_unica,   
			CHAR(80)      AS nombre_producto;
			
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRet INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cEjecutivo CHAR(8);
	DEFINE cNombre CHAR(80);
	DEFINE iNoAnalizadas INTEGER;
	DEFINE dPorcentajeAnalizadas DECIMAL(14,2);
	DEFINE iNumReevaluadas INTEGER;      
	DEFINE dPorcentajeRevaluadas DECIMAL(14,2);
	DEFINE iNumRevaluadas INTEGER;
	DEFINE dPorcentajeNumRevaluadas DECIMAL(14,2);
	DEFINE iNumSiguenProceso INTEGER;      
	DEFINE dPorcentajeSigueProc DECIMAL(14,2);
	DEFINE iNumRechazadas INTEGER;
	DEFINE dPorcentajeRechazadas DECIMAL(14,2);
	DEFINE iCanceladas INTEGER;
	DEFINE dPorcentajeCanceladas DECIMAL(14,2);
	DEFINE iNumMixta INTEGER;
	DEFINE dPorcentajeMixta DECIMAL(14,2);
	DEFINE iNumUnica INTEGER;
	DEFINE dPorcentajeUnica DECIMAL(14,2);
	DEFINE cNombreProducto CHAR(80);
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iCodRet = 0;
	LET iSqlErr = 0;
	LET cEjecutivo = '';
	LET cNombre = '';
	LET iNoAnalizadas = 0;
	LET dPorcentajeAnalizadas = NULL;
	LET iNumReevaluadas = 0;      
	LET dPorcentajeRevaluadas = NULL;
	LET iNumRevaluadas = 0;
	LET dPorcentajeNumRevaluadas = NULL;
	LET iNumSiguenProceso = 0;      
	LET dPorcentajeSigueProc = NULL;
	LET iNumRechazadas = 0;
	LET dPorcentajeRechazadas = NULL;
	LET iCanceladas = 0;
	LET dPorcentajeCanceladas = NULL;
	LET iNumMixta = 0;
	LET dPorcentajeMixta = NULL;
	LET iNumUnica = 0;
	LET dPorcentajeUnica = NULL;
	LET cNombreProducto = '';
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cEjecutivo, cNombre, iNoAnalizadas, 
				dPorcentajeAnalizadas, iNumReevaluadas, dPorcentajeRevaluadas, iNumRevaluadas, 
				dPorcentajeNumRevaluadas, iNumSiguenProceso, dPorcentajeSigueProc, iNumRechazadas, 
				dPorcentajeRechazadas, iCanceladas, dPorcentajeCanceladas, iNumMixta, 
				dPorcentajeMixta, iNumUnica, dPorcentajeUnica, cNombreProducto;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultarinforeporteanalistamc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cEjecutivo, cNombre, iNoAnalizadas, 
				dPorcentajeAnalizadas, iNumReevaluadas, dPorcentajeRevaluadas, iNumRevaluadas, 
				dPorcentajeNumRevaluadas, iNumSiguenProceso, dPorcentajeSigueProc, iNumRechazadas, 
				dPorcentajeRechazadas, iCanceladas, dPorcentajeCanceladas, iNumMixta, 
				dPorcentajeMixta, iNumUnica, dPorcentajeUnica, cNombreProducto;
		END IF;
		
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cEjecutivo, cNombre, iNoAnalizadas, 
				dPorcentajeAnalizadas, iNumReevaluadas, dPorcentajeRevaluadas, iNumRevaluadas, 
				dPorcentajeNumRevaluadas, iNumSiguenProceso, dPorcentajeSigueProc, iNumRechazadas, 
				dPorcentajeRechazadas, iCanceladas, dPorcentajeCanceladas, iNumMixta, 
				dPorcentajeMixta, iNumUnica, dPorcentajeUnica, cNombreProducto;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cEjecutivo, cNombre, iNoAnalizadas, 
				dPorcentajeAnalizadas, iNumReevaluadas, dPorcentajeRevaluadas, iNumRevaluadas, 
				dPorcentajeNumRevaluadas, iNumSiguenProceso, dPorcentajeSigueProc, iNumRechazadas, 
				dPorcentajeRechazadas, iCanceladas, dPorcentajeCanceladas, iNumMixta, 
				dPorcentajeMixta, iNumUnica, dPorcentajeUnica, cNombreProducto;
		END IF;
		
		
		FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_consultaporanalistamc(pFechaInicio, pFechaFin, pProducto)
				INTO cCodRetSp, cEjecutivo, cNombre, iNoAnalizadas, 
						dPorcentajeAnalizadas, iNumReevaluadas, dPorcentajeRevaluadas, iNumRevaluadas, 
						dPorcentajeNumRevaluadas, iNumSiguenProceso, dPorcentajeSigueProc, iNumRechazadas, 
						dPorcentajeRechazadas, iCanceladas, dPorcentajeCanceladas, iNumMixta, 
						dPorcentajeMixta, iNumUnica, dPorcentajeUnica, cNombreProducto
			
			LET iCodRet = cCodRetSp::INTEGER;
			IF iCodRet < 0 THEN
				RAISE EXCEPTION iCodRet, 0, 'ERROR EN LA EJECUCION DEL SP sp_consultaporanalistamc';
			ELIF iCodRet = 0 THEN
				IF iRegistros >= pRegistros THEN
					IF iRecuperacion < pRecuperacion THEN
						RETURN cCodRet, cEjecutivo, cNombre, iNoAnalizadas, 
							dPorcentajeAnalizadas, iNumReevaluadas, dPorcentajeRevaluadas, iNumRevaluadas, 
							dPorcentajeNumRevaluadas, iNumSiguenProceso, dPorcentajeSigueProc, iNumRechazadas, 
							dPorcentajeRechazadas, iCanceladas, dPorcentajeCanceladas, iNumMixta, 
							dPorcentajeMixta, iNumUnica, dPorcentajeUnica, cNombreProducto WITH RESUME;
						LET iRecuperacion = iRecuperacion + 1;
					ELSE
						EXIT FOREACH;
					END IF;
				END IF;
				LET iRegistros = iRegistros + 1;
			END IF;
				
		END FOREACH;
		
		IF pRegistros = 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cEjecutivo, cNombre, iNoAnalizadas, 
				dPorcentajeAnalizadas, iNumReevaluadas, dPorcentajeRevaluadas, iNumRevaluadas, 
				dPorcentajeNumRevaluadas, iNumSiguenProceso, dPorcentajeSigueProc, iNumRechazadas, 
				dPorcentajeRechazadas, iCanceladas, dPorcentajeCanceladas, iNumMixta, 
				dPorcentajeMixta, iNumUnica, dPorcentajeUnica, cNombreProducto;
		ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cEjecutivo, cNombre, iNoAnalizadas, 
				dPorcentajeAnalizadas, iNumReevaluadas, dPorcentajeRevaluadas, iNumRevaluadas, 
				dPorcentajeNumRevaluadas, iNumSiguenProceso, dPorcentajeSigueProc, iNumRechazadas, 
				dPorcentajeRechazadas, iCanceladas, dPorcentajeCanceladas, iNumMixta, 
				dPorcentajeMixta, iNumUnica, dPorcentajeUnica, cNombreProducto;
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 05/03/2014',
'DESCRIPCION: Hace un reporte de las solicitudes que fueron analizadas por analista para Mesa de Control, SOCWEB',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultartotalinforeporteanalistamc(pUsuario CHAR(8), pIdFuncion CHAR(10), pProducto CHAR(4), pFechaInicio DATE, pFechaFin DATE)
	RETURNING CHAR(5)     AS codret,
			INTEGER AS total_registros;
			
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRet INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cEjecutivo CHAR(8);
	DEFINE cNombre CHAR(80);
	DEFINE iNoAnalizadas INTEGER;
	DEFINE dPorcentajeAnalizadas DECIMAL(14,2);
	DEFINE iNumReevaluadas INTEGER;      
	DEFINE dPorcentajeRevaluadas DECIMAL(14,2);
	DEFINE iNumRevaluadas INTEGER;
	DEFINE dPorcentajeNumRevaluadas DECIMAL(14,2);
	DEFINE iNumSiguenProceso INTEGER;      
	DEFINE dPorcentajeSigueProc DECIMAL(14,2);
	DEFINE iNumRechazadas INTEGER;
	DEFINE dPorcentajeRechazadas DECIMAL(14,2);
	DEFINE iCanceladas INTEGER;
	DEFINE dPorcentajeCanceladas DECIMAL(14,2);
	DEFINE iNumMixta INTEGER;
	DEFINE dPorcentajeMixta DECIMAL(14,2);
	DEFINE iNumUnica INTEGER;
	DEFINE dPorcentajeUnica DECIMAL(14,2);
	DEFINE cNombreProducto CHAR(80);
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iCodRet = 0;
	LET iSqlErr = 0;
	LET cEjecutivo = '';
	LET cNombre = '';
	LET iNoAnalizadas = 0;
	LET dPorcentajeAnalizadas = NULL;
	LET iNumReevaluadas = 0;      
	LET dPorcentajeRevaluadas = NULL;
	LET iNumRevaluadas = 0;
	LET dPorcentajeNumRevaluadas = NULL;
	LET iNumSiguenProceso = 0;      
	LET dPorcentajeSigueProc = NULL;
	LET iNumRechazadas = 0;
	LET dPorcentajeRechazadas = NULL;
	LET iCanceladas = 0;
	LET dPorcentajeCanceladas = NULL;
	LET iNumMixta = 0;
	LET dPorcentajeMixta = NULL;
	LET iNumUnica = 0;
	LET dPorcentajeUnica = NULL;
	LET cNombreProducto = '';
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultartotalinforeporteanalistamc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iRegistros;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iRegistros;
		END IF;
		
		FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_consultaporanalistamc(pFechaInicio, pFechaFin, pProducto)
				INTO cCodRetSp, cEjecutivo, cNombre, iNoAnalizadas, 
						dPorcentajeAnalizadas, iNumReevaluadas, dPorcentajeRevaluadas, iNumRevaluadas, 
						dPorcentajeNumRevaluadas, iNumSiguenProceso, dPorcentajeSigueProc, iNumRechazadas, 
						dPorcentajeRechazadas, iCanceladas, dPorcentajeCanceladas, iNumMixta, 
						dPorcentajeMixta, iNumUnica, dPorcentajeUnica, cNombreProducto
			
			LET iCodRet = cCodRetSp::INTEGER;
			IF iCodRet < 0 THEN
				RAISE EXCEPTION iCodRet, 0, 'ERROR EN LA EJECUCION DEL SP sp_consultaporanalistamc';
			ELIF iCodRet = 0 THEN
				LET iRegistros = iRegistros + 1;
			END IF;
				
		END FOREACH;
		
		IF iRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iRegistros;
		END IF;
		
		RETURN cCodRet, iRegistros;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 05/03/2014',
'DESCRIPCION: Hace un conteo de las solicitudes que fueron analizadas por analista para Mesa de Control, SOCWEB',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultas_cac_central_ctemc(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombre1 CHAR(30), pNombre2 CHAR(30), 
			pApellidoPaterno CHAR(30), pApellidoMaterno CHAR(30), pNumCliente CHAR(20), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			CHAR(80) AS mensaje_error,
			CHAR(20) AS num_solicitud,
			CHAR(20) AS num_cliente,
			CHAR(104) AS nombre_cliente,
			CHAR(13) AS rfc,
			CHAR(4) AS sucursal,
			DATE AS fecha_solicitud,
			DATE AS fecha_cambio,
			DECIMAL(18,2) AS importe_linea,
			DECIMAL(5,2) AS eficiencia,
			INTEGER AS historial,
			DECIMAL(5,2) AS puntos_1a_seccion,
			DECIMAL(5,2) AS puntos_2a_seccion,
			CHAR(2) AS status,
			CHAR(511) AS observaciones,
			DECIMAL(8,2) AS sum_secciones,
			CHAR(3) AS causa_solicitud;
		
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iSqlErr INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cEmpresa CHAR(3);
	
	-- VARIABLES DEL SP PRODUCTIVO
	DEFINE cMensajeError CHAR(80);
	DEFINE cNumSolicitud CHAR(20);
	DEFINE cNumCliente CHAR(20);
	DEFINE cNombreCliente CHAR(104);
	DEFINE cRfc CHAR(13);
	DEFINE cSucursal CHAR(4);
	DEFINE dFechaSolicitud DATE;
	DEFINE dFechaCambio DATE;
	DEFINE dImporteLinea DECIMAL(18,2);
	DEFINE dEficiencia DECIMAL(5,2);
	DEFINE iHistorial INTEGER;
	DEFINE dPuntos1Seccion DECIMAL(5,2);
	DEFINE dPuntos2Seccion DECIMAL(5,2);
	DEFINE cStatus CHAR(2);
	DEFINE cObservaciones CHAR(511);
	DEFINE dSumaSecciones DECIMAL(8,2);
	DEFINE cCausaSolicitud CHAR(3);
	
	LET cCodRet = '';
	LET cCodRetSp = '';
	LET iSqlErr = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET cEmpresa = '001';
	
	-- VARIABLES DEL SP PRODUCTIVO
	LET cMensajeError = '';
	LET cNumSolicitud = '';
	LET cNumCliente = '';
	LET cNombreCliente = '';
	LET cRfc = '';
	LET cSucursal = '';
	LET dFechaSolicitud = NULL;
	LET dFechaCambio = NULL;
	LET dImporteLinea = NULL;
	LET dEficiencia = NULL;
	LET iHistorial = 0;
	LET dPuntos1Seccion = NULL;
	LET dPuntos2Seccion = NULL;
	LET cStatus = '';
	LET cObservaciones = '';
	LET dSumaSecciones = NULL;
	LET cCausaSolicitud = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cMensajeError, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaSolicitud, 
				dFechaCambio, dImporteLinea, dEficiencia, iHistorial, dPuntos1Seccion, dPuntos2Seccion, 
				cStatus, cObservaciones, dSumaSecciones, cCausaSolicitud;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultas_cac_central_ctemc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cMensajeError, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaSolicitud, 
				dFechaCambio, dImporteLinea, dEficiencia, iHistorial, dPuntos1Seccion, dPuntos2Seccion, 
				cStatus, cObservaciones, dSumaSecciones, cCausaSolicitud;
		END IF;
		
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cMensajeError, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaSolicitud, 
				dFechaCambio, dImporteLinea, dEficiencia, iHistorial, dPuntos1Seccion, dPuntos2Seccion, 
				cStatus, cObservaciones, dSumaSecciones, cCausaSolicitud;
		END IF;
		
		-- ValidacciÃ³n de acceso a la funcionalidad
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cMensajeError, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaSolicitud, 
				dFechaCambio, dImporteLinea, dEficiencia, iHistorial, dPuntos1Seccion, dPuntos2Seccion, 
				cStatus, cObservaciones, dSumaSecciones, cCausaSolicitud;
		END IF;
		
		FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_consultas_cac_central_cte(cEmpresa, pNombre1, pNombre2, pApellidoPaterno, pApellidoMaterno, pNumCliente)
			INTO cCodRetSp, cMensajeError, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaSolicitud, dFechaCambio, 
					dImporteLinea, dEficiencia, iHistorial, dPuntos1Seccion, dPuntos2Seccion, cStatus, cObservaciones, dSumaSecciones, cCausaSolicitud
			
			IF cCodRetSp::INTEGER = 0 THEN
				
				IF iRegistros >= pRegistros THEN
					IF iRecuperacion < pRecuperacion THEN						
						RETURN cCodRet, cMensajeError, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaSolicitud, 
							dFechaCambio, dImporteLinea, dEficiencia, iHistorial, dPuntos1Seccion, dPuntos2Seccion, 
							cStatus, cObservaciones, dSumaSecciones, cCausaSolicitud WITH RESUME;
						LET iRecuperacion = iRecuperacion + 1;
					END IF;
				END IF;
				LET iRegistros = iRegistros + 1;
				
			ELIF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER;
			END IF;
		
		END FOREACH;
		
		IF pRegistros = 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cMensajeError, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaSolicitud, 
							dFechaCambio, dImporteLinea, dEficiencia, iHistorial, dPuntos1Seccion, dPuntos2Seccion, 
							cStatus, cObservaciones, dSumaSecciones, cCausaSolicitud;
		ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cMensajeError, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaSolicitud, 
							dFechaCambio, dImporteLinea, dEficiencia, iHistorial, dPuntos1Seccion, dPuntos2Seccion, 
							cStatus, cObservaciones, dSumaSecciones, cCausaSolicitud;
		END IF;
		
	END;
		
END PROCEDURE;
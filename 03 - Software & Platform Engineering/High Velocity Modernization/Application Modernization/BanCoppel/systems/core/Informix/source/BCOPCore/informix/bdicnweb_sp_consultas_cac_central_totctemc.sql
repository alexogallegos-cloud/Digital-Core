CREATE PROCEDURE "informix".sp_consultas_cac_central_totctemc(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombre1 CHAR(30), pNombre2 CHAR(30), 
			pApellidoPaterno CHAR(30), pApellidoMaterno CHAR(30), pNumCliente CHAR(20))
		RETURNING CHAR(5) AS codret,
			INTEGER AS total_solicitudes_x_cliente;
		
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
			RETURN cCodRet, iRecuperacion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultas_cac_central_totctemc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iRecuperacion;
		END IF;
		
		-- ValidacciÃ³n de acceso a la funcionalidad
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iRecuperacion;
		END IF;
		
		FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_consultas_cac_central_cte(cEmpresa, pNombre1, pNombre2, pApellidoPaterno, pApellidoMaterno, pNumCliente)
			INTO cCodRetSp, cMensajeError, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaSolicitud, dFechaCambio, 
					dImporteLinea, dEficiencia, iHistorial, dPuntos1Seccion, dPuntos2Seccion, cStatus, cObservaciones, dSumaSecciones, cCausaSolicitud
			
			IF cCodRetSp::INTEGER = 0 THEN
				LET iRecuperacion = iRecuperacion + 1;
			ELIF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER;
			END IF;
		
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iRecuperacion;
		ELSE
			RETURN cCodRet, iRecuperacion;
		END IF;
		
	END;
		
END PROCEDURE;
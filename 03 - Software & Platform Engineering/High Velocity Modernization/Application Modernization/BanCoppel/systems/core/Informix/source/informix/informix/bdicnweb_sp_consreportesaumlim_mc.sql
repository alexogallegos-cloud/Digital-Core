CREATE PROCEDURE "informix".sp_consreportesaumlim_mc(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(100) AS nombre_reporte,
		DATE AS fecha_reporte,
		DATETIME HOUR TO SECOND AS hr_reporte;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE dFecha DATE;
	DEFINE cNombre_reporte CHAR(100);
	DEFINE dFecha_reporte DATE;
	DEFINE dHr_reporte DATETIME HOUR TO SECOND;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET dFecha = '';
	LET cNombre_reporte = '';
	LET dFecha_reporte = '';
	LET dHr_reporte = '';
	LET iRecuperacion = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consreportesaumlim_mc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte;
		END IF;
		
		-- VALIDACIÃN DE LOS DATOS DE PAGINACION
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			
			SELECT SKIP pRegistros FIRST pRecuperacion 
			nombre_reporte, fecha_reporte, hr_reporte
			INTO cNombre_reporte,dFecha_reporte,dHr_reporte
			FROM bdicnweb:"informix".sw_ctrlgenreportesaumlimcred_mc
			WHERE fecha_reporte = DATE(CURRENT)
			AND usuario_insert = pUsuario
			ORDER BY hr_reporte ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte WITH RESUME;
			
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cNombre_reporte,dFecha_reporte,dHr_reporte;
		END IF;	
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 31/07/2019',
'MODULO: CRÃDITO',
'FUNCIONALIDAD: REPORTE DE INCREMENTO DE LÃNEAS DE CRÃDITO',
'DESCRIPCION: Spl encargado de consultar los archivo csv generados de reportes de incremento de lÃ­neas de crÃ©dito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consreportesaumlim_mc_totales(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE dFecha DATE;
	DEFINE cNombre_reporte CHAR(100);
	DEFINE dFecha_reporte DATE;
	DEFINE dHr_reporte DATETIME HOUR TO SECOND;
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET dFecha = '';
	LET cNombre_reporte = '';
	LET dFecha_reporte = '';
	LET dHr_reporte = '';
	LET iNumRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNumRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consreportesaumlim_mc_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT COUNT(*)
		INTO iNumRegistros
		FROM bdicnweb:"informix".sw_ctrlgenreportesaumlimcred_mc
		WHERE fecha_reporte = DATE(CURRENT)
		AND usuario_insert = pUsuario;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;	
		
		RETURN cCodRet,iNumRegistros;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 31/07/2019',
'MODULO: CRÃDITO',
'FUNCIONALIDAD: REPORTE DE INCREMENTO DE LÃNEAS DE CRÃDITO',
'DESCRIPCION: Spl encargado de consultar total de archivo csv generados de reportes de incremento de lÃ­neas de crÃ©dito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultagralautaumlincred_rep(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechainicial DATE, pFechaFinal DATE, pStatus CHAR(2), pOrigen CHAR(1))
	RETURNING 
		CHAR(5) 	AS codret,
        INT         AS iTotalReg,
        CHAR(50)    AS cNombreReporte;
								  
        DEFINE cCodRet 				CHAR(5);
        DEFINE iSqlErr 				INTEGER;
        DEFINE cCodRetSp 			CHAR(6);
        DEFINE iCodRetSp 			INTEGER;
        DEFINE iRecuperacion 		INTEGER;
        DEFINE cMensajeRetorno  	CHAR(80);
        DEFINE dFechaOrigen     	DATE;
        DEFINE cNumeroSolicitud 	CHAR(20);
        DEFINE cOrigen          	CHAR(1);
        DEFINE cNumeroCliente   	CHAR(20);
        DEFINE cApellidoPaterno 	CHAR(26);
        DEFINE cApellidoMaterno 	CHAR(26);
        DEFINE cNombre          	CHAR(53);
        DEFINE dLincredActual   	DECIMAL(18,2);
        DEFINE dLincredSugerida 	DECIMAL(18,2);
        DEFINE dIncremento      	DECIMAL(18,2);
        DEFINE Status           	CHAR(2);
        DEFINE AnalistaCac      	CHAR(45);
        DEFINE Analista2nivel   	CHAR(45);
        DEFINE Analista3nivel   	CHAR(45);
        DEFINE Analista4nivel   	CHAR(45);
        DEFINE motivo           	CHAR(106);
        DEFINE dFechaIngresoAC  	DATE;
        DEFINE dHoraIngresoAC 		DATETIME HOUR TO FRACTION(3);
        DEFINE dFechaAtencion 		DATE;
        DEFINE dHoraAtencion 		DATETIME HOUR TO FRACTION(3);
        DEFINE cTipoIncremento 			CHAR(10);
		DEFINE cNombreReporte 		CHAR(50);
		
        LET cCodRet 				= '00000';
        LET iSqlErr 				= 0;
        LET cCodRetSp 				= '';
        LET iCodRetSp 				= 0;
        LET iRecuperacion 			= 0;
        LET cMensajeRetorno  		= '';
        LET dFechaOrigen     		= '';
        LET cNumeroSolicitud 		= '';
        LET cOrigen          		= '';
        LET cNumeroCliente   		= '';
        LET cApellidoPaterno 		= '';
        LET cApellidoMaterno 		= '';
        LET cNombre          		= '';
        LET dLincredActual       	= 0;
        LET dLincredSugerida 		= 0;
        LET dIncremento      		= 0;
        LET Status                  = '';  
        LET AnalistaCac      		= '';
        LET Analista2nivel   		= '';
        LET Analista3nivel   		= '';
        LET Analista4nivel   		= '';
        LET motivo           		= '';
        LET dFechaIngresoAC  		= '';
        LET dHoraIngresoAC   		= '';
        LET dFechaAtencion   		= '';
        LET dHoraAtencion    		= '';
		LET cTipoIncremento   		= '';
		LET cNombreReporte			= '';
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, iRecuperacion, cNombreReporte;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_consultagralautaumlincred_rep.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicial = '' OR pFechaFinal = '' OR pStatus = '' OR pOrigen = ''THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, iRecuperacion, cNombreReporte;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, iRecuperacion, cNombreReporte;
                END IF;
				
				LET cNombreReporte = 'DET_INCREMENTO_'||pUsuario||'_'||TO_CHAR(CURRENT,'%d%m%Y%H%M%S')||'.csv';
                
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
				
                FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_consulta_gral_aumlincred_aut3(pFechainicial, pFechaFinal, pStatus, pUsuario, pOrigen)
                        INTO cCodRetSp, cMensajeRetorno, dFechaOrigen, cNumeroSolicitud, cOrigen, cNumeroCliente, cApellidoPaterno, cApellidoMaterno, 
                        cNombre, dLincredActual, dLincredSugerida, dIncremento, Status, AnalistaCac, Analista2nivel, Analista3nivel, Analista4nivel, 
                        motivo,dFechaIngresoAC, dHoraIngresoAC, dFechaAtencion,dHoraAtencion, cTipoIncremento
                        
                        LET iCodRetSp = cCodRetSp::INTEGER;
                        IF iCodRetSp < 0 THEN
                                RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_consulta_gral_aumlincred_aut3';
                        ELIF iCodRetSp = 000001 THEN
                                LET cCodRet = '00003';
                               RETURN cCodRet, iRecuperacion, cNombreReporte;
                        ELIF iCodRetSp = 000002 THEN
                                LET cCodRet = '00154';
                                RETURN cCodRet, iRecuperacion, cNombreReporte;
                        ELIF iCodRetSp = 000003 THEN
                                LET cCodRet = '00017';
                                RETURN cCodRet, iRecuperacion, cNombreReporte;
                        ELSE
                            LET iRecuperacion = iRecuperacion + 1;
							INSERT INTO bdicnweb:"informix".sw_cons_aumlim_incremento_mc(usuario_insert, report_name, fechahora_insert, fecha_origen, numero_solicitud, origen, numero_cliente, apellido_paterno, apellido_materno, nombre, lincredactual, lincredsugerida, incremento, status, analistacac, analista2nivel, analista3nivel, analista4nivel, motivo, fechaingresoac, horaingresoac, fechaatencion, horaatencion, tipoincremento) 
							VALUES(pUsuario, cNombreReporte, CURRENT, dFechaOrigen, cNumeroSolicitud, cOrigen, cNumeroCliente, cApellidoPaterno, cApellidoMaterno, cNombre, dLincredActual, dLincredSugerida, dIncremento, Status, AnalistaCac, Analista2nivel, Analista3nivel, Analista4nivel, motivo, dFechaIngresoAC, dHoraIngresoAC, dFechaAtencion, dHoraAtencion, cTipoIncremento);

                        END IF;
						
                END FOREACH;
				
				RETURN cCodRet, iRecuperacion, cNombreReporte;
        END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 30/07/2019',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTE DE INCREMENTO DE LÍNEAS DE CRÉDITO',
'DESCRIPCION: Spl que consulta registros para reporte por Detalle Incremento en reportes de incremento de líneas de crédito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultagralstatusaumlincred_rep(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechainicial DATE, pFechaFinal DATE, pOrigen CHAR(2))
		RETURNING 
			CHAR(5) AS codret,
			INT AS iTotalReg,
			CHAR(50) AS cNombreReporte;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE iNoRegs INTEGER;
	DEFINE cMensajeRetorno CHAR(80);
	DEFINE iTieneCausa INTEGER;
	DEFINE cDescripcion CHAR(100);
	DEFINE iTotalStatus INTEGER;
	DEFINE dPorcentaje DECIMAL(18,2);
	DEFINE iTotalGeneral INTEGER;
	DEFINE cNombreReporte CHAR(50);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET iNoRegs = 0;
	LET cMensajeRetorno = '';
	LET iTieneCausa 	= 0;
	LET cDescripcion 	= '';
	LET iTotalStatus 	= 0;
	LET dPorcentaje 	= '';
	LET iTotalGeneral 	= 0;
	LET cNombreReporte	= '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iRecuperacion, cNombreReporte;
		END EXCEPTION;
		
		ON EXCEPTION IN (-206)
		END EXCEPTION WITH RESUME;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultagralstatusaumlincred_rep.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicial = '' OR pFechaFinal = '' OR pOrigen = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iRecuperacion, cNombreReporte;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iRecuperacion, cNombreReporte;
		END IF;
		
		LET cNombreReporte = 'STATUS_'||pUsuario||'_'||TO_CHAR(CURRENT,'%d%m%Y%H%M%S')||'.csv';                
				
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		DROP TABLE tme_consultaincrementos;
		
		FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_rep_gral_status3(pFechainicial, pFechaFinal, pOrigen)
			INTO cCodRetSp, cMensajeRetorno, iTieneCausa, cDescripcion, iTotalStatus, dPorcentaje, iTotalGeneral
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_rep_gral_status2';
			ELIF iCodRetSp = 000001 THEN
				LET cCodRet = '00003';
			ELIF iCodRetSp = 000002 THEN
				LET cCodRet = '00388';
			ELIF iCodRetSp = 000003 THEN
				LET cCodRet = '00003';
			ELSE
				LET iRecuperacion = iRecuperacion + 1;
				INSERT INTO bdicnweb:"informix".sw_cons_aumlim_status_mc(usuario_insert, report_name, fechahora_insert, tiene_causa, descripcion, total_status, porcentaje, total_general) 
				VALUES(pUsuario, cNombreReporte, CURRENT, iTieneCausa, cDescripcion, iTotalStatus, dPorcentaje, iTotalGeneral);
				
			END IF;
		END FOREACH;
		
		RETURN cCodRet, iRecuperacion, cNombreReporte;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 30/07/2019',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTE DE INCREMENTO DE LÍNEAS DE CRÉDITO',
'DESCRIPCION: Spl que consulta registros para reporte por Estatus en reportes de incremento de líneas de crédito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultaperfilusuarioaumlincred_rep(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechainicial DATE, pFechaFinal DATE)
		RETURNING 
			CHAR(5) AS codret,
			INT AS iTotalReg,
			CHAR(50) AS cNombreReporte;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE iNoRegs INTEGER;
	DEFINE cMensajeRetorno       CHAR(80);
	DEFINE cNumempleado          CHAR(8);
	DEFINE cNombre               CHAR(45);
	DEFINE cPerfilPuesto         CHAR (25);
	DEFINE iAtendidas            INTEGER;
	DEFINE iPorcAtendidas        DECIMAL(18,2);
	DEFINE iCanceladas           INTEGER;
	DEFINE iPorcCanceladas       DECIMAL(18,2);
	DEFINE iRechazadas           INTEGER;
	DEFINE iPorcRechazadas       DECIMAL(18,2);
	DEFINE iAutorizadas          INTEGER;
	DEFINE iPorcAutorizadas      DECIMAL(18,2);
	DEFINE iTotalAtendidas       INTEGER;
	DEFINE iTotalPorcAtendidas   DECIMAL(18,2);
	DEFINE iTotalCanceladas      INTEGER;
	DEFINE iTotalPorcCanceladas  DECIMAL(18,2);
	DEFINE iTotalRechazadas      INTEGER;
	DEFINE iTotalPorcRechazadas  DECIMAL(18,2);
	DEFINE iTotalAutorizadas     INTEGER;
	DEFINE iTotalPorcAutorizadas DECIMAL(18,2);
	DEFINE cNombreReporte        CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET iNoRegs = 0;
	LET cMensajeRetorno       = '';
	LET cNumempleado          = '';
	LET cNombre               = '';
	LET cPerfilPuesto         = '';
	LET iAtendidas            = 0;
	LET iPorcAtendidas        = 0;
	LET iCanceladas           = 0;
	LET iPorcCanceladas       = 0;
	LET iRechazadas           = 0;
	LET iPorcRechazadas       = 0;
	LET iAutorizadas          = 0;
	LET iPorcAutorizadas      = 0;
	LET iTotalAtendidas       = 0;
	LET iTotalPorcAtendidas   = 0;
	LET iTotalCanceladas      = 0;
	LET iTotalPorcCanceladas  = 0;
	LET iTotalRechazadas      = 0;
	LET iTotalPorcRechazadas  = 0;
	LET iTotalAutorizadas     = 0;
	LET iTotalPorcAutorizadas = 0;
	LET cNombreReporte	      = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iRecuperacion, cNombreReporte;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultaperfilusuarioaumlincred_rep.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicial = '' OR pFechaFinal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iRecuperacion, cNombreReporte;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iRecuperacion, cNombreReporte;
		END IF;
		
		
		LET cNombreReporte = 'PERFIL_USUARIO_'||pUsuario||'_'||TO_CHAR(CURRENT,'%d%m%Y%H%M%S')||'.csv';
        
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_cac_rep_perfil_usuario3(pFechainicial, pFechaFinal)
			INTO cCodRetSp, cMensajeRetorno, cNumempleado, cNombre, cPerfilPuesto, iAtendidas, iPorcAtendidas, iCanceladas, iPorcCanceladas, 
				iRechazadas, iPorcRechazadas, iAutorizadas, iPorcAutorizadas, iTotalAtendidas, iTotalPorcAtendidas, 
				iTotalCanceladas, iTotalPorcCanceladas, iTotalRechazadas, iTotalPorcRechazadas, iTotalAutorizadas, 
				iTotalPorcAutorizadas 
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_cac_rep_perfil_usuario3';
			ELIF iCodRetSp = 000001 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iRecuperacion, cNombreReporte;
			ELIF iCodRetSp = 000003 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iRecuperacion, cNombreReporte;
			ELSE
				LET iRecuperacion = iRecuperacion + 1;
				INSERT INTO informix.sw_cons_aumlim_perfil_mc(usuario_insert, report_name, fechahora_insert, numempleado, nombre, perfil_puesto, atendidas, porcatendidas, canceladas,
				porccanceladas, rechazadas, porcrechazadas, autorizadas, porcautorizadas, totalatendidas, totalporcatendidas, totalcanceladas, totalporccanceladas,
				totalrechazadas, totalporcrechazadas, totalautorizadas, totalporcautorizadas) 
				VALUES(pUsuario, cNombreReporte, CURRENT, cNumempleado, cNombre, cPerfilPuesto, iAtendidas, iPorcAtendidas, iCanceladas, iPorcCanceladas, 
				iRechazadas, iPorcRechazadas, iAutorizadas, iPorcAutorizadas, iTotalAtendidas, iTotalPorcAtendidas, 
				iTotalCanceladas, iTotalPorcCanceladas, iTotalRechazadas, iTotalPorcRechazadas, iTotalAutorizadas, 
				iTotalPorcAutorizadas);
			END IF;
		END FOREACH;
		
		RETURN cCodRet, iRecuperacion, cNombreReporte;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 30/07/2019',
'MODULO: CRÃDITO',
'FUNCIONALIDAD: REPORTE DE INCREMENTO DE LÃNEAS DE CRÃDITO',
'DESCRIPCION: Spl que consulta registros para reporte por Perfil Usuario en reportes de incremento de lÃ­neas de crÃ©dito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultarevisioncacaumlincred_rep(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechainicial DATE, pFechaFinal DATE)
		RETURNING 
			CHAR(5) AS codret,
			INT AS iTotalReg,
			CHAR(50) AS cNombreReporte;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cMensajeRetorno		CHAR(80);
	DEFINE dTieneCausa			INTEGER;
	DEFINE cDescripcion			CHAR(100);
	DEFINE iTotalRegCentral		INTEGER;
	DEFINE dPorcentajeCentral	DECIMAL(18,2);
	DEFINE iTotalCentral		INTEGER;
	DEFINE dTotPorCentral		DECIMAL(18,2);
	DEFINE iTotalRegSucursal	INTEGER;
	DEFINE dPorcentajeSucursal	DECIMAL(18,2);
	DEFINE iTotalSucursal		INTEGER;
	DEFINE dTotPorSucursal		DECIMAL(18,2);
	DEFINE cNombreReporte       CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iRecuperacion = 0;
	LET cMensajeRetorno 	= '';
	LET dTieneCausa         = 0;
	LET cDescripcion        = '';
	LET iTotalRegCentral    = 0;
	LET dPorcentajeCentral  = 0;
	LET iTotalCentral       = 0;
	LET dTotPorCentral      = 0;
	LET iTotalRegSucursal   = 0;
	LET dPorcentajeSucursal = 0;
	LET iTotalSucursal      = 0;
	LET dTotPorSucursal     = 0;
	LET cNombreReporte	    = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iRecuperacion, cNombreReporte;
		END EXCEPTION;
		
		ON EXCEPTION IN (-206)
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultarevisioncacaumlincred_rep.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechainicial = '' OR pFechaFinal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iRecuperacion, cNombreReporte;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iRecuperacion, cNombreReporte;
		END IF;
		
		LET cNombreReporte = 'MC_'||pUsuario||'_'||TO_CHAR(CURRENT,'%d%m%Y%H%M%S')||'.csv';
                
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		DROP TABLE tme_consultaincrementos;

		FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_cac_rep_revisioncac3(pFechainicial, pFechaFinal)
			INTO cCodRetSp, cMensajeRetorno, dTieneCausa, cDescripcion, iTotalRegCentral, dPorcentajeCentral, iTotalCentral, 
			dTotPorCentral, iTotalRegSucursal, dPorcentajeSucursal, iTotalSucursal, dTotPorSucursal
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_cac_rep_revisioncac3';
			ELIF iCodRetSp = 000002 THEN
				LET cCodRet = '00388'; --PARÃMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA
				RETURN cCodRet, iRecuperacion, cNombreReporte;
			ELIF iCodRetSp = 000001 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iRecuperacion, cNombreReporte;
			ELSE
				LET iRecuperacion = iRecuperacion + 1;
				INSERT INTO bdicnweb:"informix".sw_cons_aumlim_mesac_mc(usuario_insert, report_name, fechahora_insert, tiene_causa, descripcion, totalregcentral, porcentajecentral, totalcentral, totporcentral, totalregsucursal, porcentajesucursal, totalsucursal, totporsucursal) 
				VALUES(pUsuario, cNombreReporte, CURRENT, dTieneCausa, cDescripcion, iTotalRegCentral, dPorcentajeCentral, iTotalCentral, dTotPorCentral, iTotalRegSucursal, dPorcentajeSucursal, iTotalSucursal, dTotPorSucursal);
			END IF;
		END FOREACH;
		
		RETURN cCodRet, iRecuperacion, cNombreReporte;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 30/07/2019',
'MODULO: CRÃDITO',
'FUNCIONALIDAD: REPORTE DE INCREMENTO DE LÃNEAS DE CRÃDITO',
'DESCRIPCION: Spl que consulta registros para reporte por Mesa de Control Central en reportes de incremento de lÃ­neas de crÃ©dito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultarevisioncentralaumlincred_rep(pUsuario CHAR(8), pIdFuncion CHAR(10),pFechainicial DATE, pFechaFinal DATE)
		RETURNING 
			CHAR(5) AS codret,
			INT AS iTotalReg,
			CHAR(50) AS cNombreReporte;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE iNoRegs INTEGER;
	DEFINE cMensajeRetorno      CHAR(80);
	DEFINE iTieneCausa          INTEGER;
	DEFINE cDescripcion         CHAR(100);
	DEFINE iTotalRegCasosCac    INTEGER;
	DEFINE dPorcentajeCasosCac  DECIMAL(18,2);
	DEFINE iTotCAC              INTEGER;
	DEFINE dPorCAC              DECIMAL(18,2);
	DEFINE iTotalRegCasosAuto   INTEGER;
	DEFINE dDorcentajeCasosAuto DECIMAL(18,2);
	DEFINE iTotAUTO             INTEGER;
	DEFINE dPorAUTO             DECIMAL(18,2);
	DEFINE cNombreReporte       CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET iNoRegs = 0;
	LET cMensajeRetorno      = '';
	LET iTieneCausa          = 0;
	LET cDescripcion         = '';
	LET iTotalRegCasosCac    = 0;
	LET dPorcentajeCasosCac  = 0;
	LET iTotCAC              = 0;
	LET dPorCAC              = 0;
	LET iTotalRegCasosAuto   = 0;
	LET dDorcentajeCasosAuto = 0;
	LET iTotAUTO             = 0;
	LET dPorAUTO             = 0;
	LET cNombreReporte	     = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iRecuperacion, cNombreReporte;
		END EXCEPTION;
		
		ON EXCEPTION IN (-206)
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultarevisioncentralaumlincred_rep.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicial = '' OR pFechaFinal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iRecuperacion, cNombreReporte;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iRecuperacion, cNombreReporte;
		END IF;
		
		LET cNombreReporte = 'STATUS_CENTRAL_'||pUsuario||'_'||TO_CHAR(CURRENT,'%d%m%Y%H%M%S')||'.csv';
                
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		DROP TABLE tme_consultaincrementos;
		
		FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_cac_rep_revisioncentral3(pFechainicial, pFechaFinal)
			INTO cCodRetSp, cMensajeRetorno, iTieneCausa, cDescripcion, iTotalRegCasosCac, dPorcentajeCasosCac, iTotCAC, 
				dPorCAC, iTotalRegCasosAuto, dDorcentajeCasosAuto, iTotAUTO, dPorAUTO
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_cac_rep_revisioncentral';
			ELIF iCodRetSp = 000002 THEN
				LET cCodRet = '00388'; --PARAMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA
				RETURN cCodRet, iRecuperacion, cNombreReporte;
			ELIF iCodRetSp = 000001 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iRecuperacion, cNombreReporte;
			ELSE
				LET iRecuperacion = iRecuperacion + 1;
				INSERT INTO bdicnweb:"informix".sw_cons_aumlim_statuscentral_mc(usuario_insert, report_name, fechahora_insert, tiene_causa, descripcion, totalregcasoscac, porcentajecasoscac, totcac, porcac, totalregcasosauto, porcentajecasosauto, totauto, porauto) 
				VALUES(pUsuario, cNombreReporte, CURRENT, iTieneCausa, cDescripcion, iTotalRegCasosCac, dPorcentajeCasosCac, iTotCAC, dPorCAC, iTotalRegCasosAuto, dDorcentajeCasosAuto, iTotAUTO, dPorAUTO);
			END IF;
		END FOREACH;
		
		RETURN cCodRet, iRecuperacion, cNombreReporte;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 30/07/2019',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTE DE INCREMENTO DE LÍNEAS DE CRÉDITO',
'DESCRIPCION: Spl que consulta registros para reporte por Status Central en reportes de incremento de líneas de crédito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genreportessolicitudessupmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1), 
pNumCliente CHAR(20), pNumSolicitud CHAR(20), pFechaInicio DATE, pFechaFin DATE, pStatus CHAR(2), pProducto CHAR(4),
pRutaDescarga CHAR(100), pIdPlantilla CHAR(10), pTituloPlantilla CHAR(60))
    RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDesCodRetSp CHAR(80);
	DEFINE cEmpresa CHAR(3);	
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaInformix CHAR(100);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreReporte CHAR(100);
	DEFINE cNombreReporteHist CHAR(100);
	DEFINE cFechaHoraArchivo CHAR(15);
	DEFINE dFechaHoy DATE;
	DEFINE dHoraHoy DATETIME HOUR TO MINUTE;
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE dHoy DATETIME YEAR TO FRACTION(3);
	--DEFINE dFecha DATE;
	--DEFINE cFecha CHAR(10);
	DEFINE dHora DATETIME HOUR TO FRACTION(3);
	DEFINE cStr7 CHAR(60);
	DEFINE cStr8 CHAR(60);	
	DEFINE iRegistros INTEGER;
	DEFINE iCountRep INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE iNumRegistros INTEGER;
	--
	DEFINE cNumSolicitud CHAR(20);
	DEFINE cNumCliente CHAR(20);
	DEFINE cNombreCliente CHAR(130);
	DEFINE dFechaSolicitud DATE;
	DEFINE dFechaCambioStatus DATE;
	DEFINE cStatus CHAR(2);
	DEFINE cRespuestaOs CHAR(8);
	DEFINE cTotss_solsuperv_paso INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDesCodRetSp = '';
	LET cEmpresa = '001';	
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaInformix = '/ifxsif01/bin/';
	LET cRutaGral = '';
	LET cNombreReporte = '';
	LET cNombreReporteHist = '';
	LET cFechaHoraArchivo = '';
	LET dFechaHoy = '';
	LET dHoraHoy = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET dHoy = '';
	--LET dFecha = '';
	--LET cFecha = '';
	LET dHora = '';
	LET cStr7 = ''; 
	LET cStr8 = ''; 
	LET iRegistros = 0;
	LET iCountRep = 0;
    LET iRecuperacion = 0;
	LET iNumRegistros = 0;
	--
	LET cNumSolicitud = '';
	LET cNumCliente = '';
	LET cNombreCliente = '';
	LET dFechaSolicitud = '';
	LET dFechaCambioStatus = '';
	LET cStatus = '';
	LET cRespuestaOs = '';
	LET cTotss_solsuperv_paso = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;

			IF ven_transacc = 1 THEN
				ROLLBACK WORK;		
			END IF;
			
			RETURN cCodRet;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/gpe/sp_genreportessolicitudessupmc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' OR pRutaDescarga = '' OR pIdPlantilla = '' OR pTituloPlantilla = '' THEN	
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		-- SE ASIGNAN VALORES PARA LA GENERACIÃ?N DEL REPORTE
		LET cNombreReporte = 'SOLICITUDES_SUPERVISION_'||pUsuario||'_'||TO_CHAR(CURRENT,'%d%m%Y_%H%M%S')||'.txt';
		LET dFechaHoy = CURRENT;
		LET dHoraHoy = CURRENT;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- SE LIMPIA TABLA PRINCIPAL
		BEGIN WORK;
			LET ven_transacc = 1;
			DELETE FROM bdicnweb:"informix".sw_consdetallereportesolsupmc WHERE usuario_insert = pUsuario;
		COMMIT;
		
		LET ven_transacc = 0;
		
		SELECT COUNT(*) 
		INTO cTotss_solsuperv_paso
		FROM bdisolic:"informix".ss_solsuperv_paso;
		
			IF cTotss_solsuperv_paso > 0 THEN
				DELETE FROM bdisolic:"informix".ss_solsuperv_paso;
			END IF;
		
		IF TRIM(pIdConsulta) = '1' THEN
			
			FOREACH 
			
				EXECUTE PROCEDURE bdisolic:"informix".sp_busca_sol_supervision(cEmpresa, pUsuario, pNumSolicitud, pNumCliente, pFechaInicio, pFechaFin, pStatus, pProducto)
				INTO cCodRetSp, cDesCodRetSp, cNumSolicitud, cNumCliente, cNombreCliente, dFechaSolicitud, dFechaCambioStatus, cStatus, cRespuestaOs
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃ?N DEL SP bdisolic:"informix".sp_busca_sol_supervision';
				ELIF cCodRetSp::INTEGER = 1 THEN
					LET cCodRet = '00003';
					RETURN cCodRet;
				ELIF cCodRetSp::INTEGER = 2 THEN
					LET cCodRet = '00787';
					RETURN cCodRet;
				ELIF cCodRetSp::INTEGER = 3 THEN
					LET cCodRet = '00788';
					RETURN cCodRet;
				ELIF cCodRetSp::INTEGER = 4 THEN
					LET cCodRet = '00789';
					RETURN cCodRet;
				ELSE
					
					LET iRegistros = iRegistros + 1;
					INSERT INTO bdicnweb:"informix".sw_consdetallereportesolsupmc(num_solicitud, num_cliente, nombre_cliente, fecha_solicitud, fecha_cambio_status, status, respuesta_os, usuario_insert, fecha_insert)
					VALUES(cNumSolicitud, cNumCliente, cNombreCliente, dFechaSolicitud, dFechaCambioStatus, cStatus, cRespuestaOs, pUsuario, dFechaHoy);
					
				END IF;
				
			END FOREACH;
		
		ELIF TRIM(pIdConsulta) = '2' THEN
			
			EXECUTE PROCEDURE bdicred:"informix".sp_consulta_supervision_mc_totales(cEmpresa, pNumSolicitud, pNumCliente, pFechaInicio, pFechaFin, pStatus, pProducto)
			INTO cCodRetSp, iNumRegistros;
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃ?N DEL SP bdicred:"informix".sp_consulta_supervision_mc_totales';
			ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 2 THEN
				LET cCodRet = '00021';
				RETURN cCodRet;
			ELSE
				
				FOREACH
					EXECUTE PROCEDURE bdicred:"informix".sp_consulta_supervision_mc(cEmpresa, pNumSolicitud, pNumCliente, pFechaInicio, pFechaFin, 
					pStatus, pProducto, 0, iNumRegistros)
					INTO cCodRetSp, cNumSolicitud, cNumCliente, cNombreCliente, dFechaSolicitud, dFechaCambioStatus, cStatus, cRespuestaOs
					
					IF cCodRetSp::INTEGER < 0 THEN 
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃ?N DEL SP bdicred:"informix".sp_consulta_supervision_mc';
					ELIF cCodRetSp::INTEGER = 1 THEN
						LET cCodRet = '00003';
						RETURN cCodRet;
					ELIF cCodRetSp::INTEGER = 2 THEN
						LET cCodRet = '00021';
						RETURN cCodRet;
					ELSE 
						
						LET iRegistros = iRegistros + 1;
						INSERT INTO bdicnweb:"informix".sw_consdetallereportesolsupmc(num_solicitud, num_cliente, nombre_cliente, fecha_solicitud, fecha_cambio_status, status, respuesta_os, usuario_insert, fecha_insert)
						VALUES(cNumSolicitud, cNumCliente, cNombreCliente, dFechaSolicitud, dFechaCambioStatus, cStatus, cRespuestaOs, pUsuario, dFechaHoy);
						
					END IF;
					
				END FOREACH;
				
			END IF;
			
		END IF;
		
		--SELECT COUNT(*) INTO iTotalRegistros FROM bdicnweb:"informix".sw_consdetallereportesolsupmc WHERE usuario_insert = pUsuario;
		
		LET cCmd1 ="";
		--LET cCmd1 =""||TRIM(cCmd1)||" SELECT NVL(TO_CHAR(pFechaInicio, '%d/%m/%Y'), ''), NVL(TO_CHAR(pFechaFin, '%d/%m/%Y'), ''), pDescProducto, NVL(TO_CHAR(dFechaHoy, '%d/%m/%Y'), ''),";
		LET cCmd1 = "SELECT 'NO. SOLICITUD','NO. CLIENTE','NOMBRE CLIENTE','FECHA SOLICITUD','FECHA CAMBIO ESTATUS','ESTATUS','RESPUESTA OS CAMBIOS'";
		LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1";
		LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT * FROM (SELECT num_solicitud, num_cliente, nombre_cliente, NVL(TO_CHAR(fecha_solicitud, '%d/%m/%Y'), ''), NVL(TO_CHAR(fecha_cambio_status, '%d/%m/%Y'), ''), status, respuesta_os";
		LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_consdetallereportesolsupmc";
		LET cCmd1 =""||TRIM(cCmd1)||" WHERE usuario_insert = '"|| pUsuario ||"'";	
		LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY id_registro ASC)";
		
		--SET ISOLATION TO DIRTY READ;
		--SET LOCK MODE TO WAIT 3;
			
		LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
		LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreReporte);
		
		BEGIN WORK;
			LET ven_transacc = 1;
			
			LET cSql = '';
			--LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER ''|'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
			LET cSql = '/usr/bin/echo "UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER ''|'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = TRIM(cRutaInformix)||'dbaccess bdicnweb '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			-- Se manipula el archivo para agregar el salto de lÃ­nea
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el archivo original
			LET cSql = '';
			LET cSql = "rm -rf "||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el caracter delimitador ';' al final de la lÃ­nea
			LET cSql = '';
			LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			-- Se manipula el archivo para agregar el salto de lÃ­nea
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
								
			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
							
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/usr/bin/rm -rf '||TRIM(cRutaGral)||'; /usr/bin/mv '||TRIM(cRutaGral)||'.tmp '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			-- SE ELIMINAN TODOS LOS REGISTROS GENERADOS MENORES A LA FECHA HOY (T-1)
			FOREACH
			
				SELECT nombre_reporte
				INTO cNombreReporteHist
				FROM bdicnweb:"informix".sw_ctrlgenreportesolsupmc 
				WHERE usuario_insert = pUsuario --AND nombre_reporte = TRIM(cNombreReporte) 
				AND fecha_reporte < dFechaHoy
				
				LET cSql = '';
				LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||TRIM(cNombreReporteHist);
				SYSTEM TRIM(cSql);
				
				LET cNombreReporteHist = TRIM(cNombreReporteHist);
				DELETE FROM bdicnweb:"informix".sw_ctrlgenreportesolsupmc WHERE nombre_reporte = TRIM(cNombreReporteHist);
				
			END FOREACH;
			
		COMMIT WORK;
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		-- SE REGISTRA EN BITÃCORA				
		LET iCountRep = iCountRep + 1;
		LET cNombreReporte = TRIM(cNombreReporte);
		DELETE FROM bdicnweb:"informix".sw_ctrlgenreportesolsupmc WHERE nombre_reporte = TRIM(cNombreReporte);
		INSERT INTO bdicnweb:"informix".sw_ctrlgenreportesolsupmc(nombre_reporte,fecha_reporte,hr_reporte,usuario_insert)
		VALUES(TRIM(cNombreReporte),dFechaHoy,dHoraHoy,pUsuario);		
		
		/*
		-- NOTIFICACIÃ?N VÃA CORREO ELECTRÃ?NICO
		LET cStr7 = 'GENERACIÃ?N DEL ARCHIVO TXT';
		LET cStr9 = 'SOLICITUDES EN SUPERVISIÃ?N';
		LET dHoy = CURRENT;
		
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(
		'1', 
		TRIM(pIdPlantilla),
		TRIM(pIdPlantilla), 
		pUsuario, 
		'',
		'', 
		'1', 
		'',
		'',
		'',
		'',
		'',
		TRIM(pTituloPlantilla),
		TRIM(cStr7),
		'',
		TRIM(cStr9),
		'',
		'',
		'',
		'0',
		'0',
		'0',
		'0',
		'0',
		dHoy,
		dHoy) INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdimnsj:sp_registra_evento';
		ELIF iCodRetSp > 0 THEN
			LET cCodRet = '01018'; --OCURRIO UN ERROR EN LA EJECUCIÃ?N DEL SP bdimnsj:"informix".sp_registra_evento, VERIFIQUE
		END IF;
		*/
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 28/03/2019',
'MODULO: CRÃ?DITO',
'FUNCIONALIDAD: SOLICITUDES DE CRÃ?DITO EN SUPERVISIÃ?N MESA DE CONTROL',
'DESCRIPCION: SPL encargado de generar los reportes en formato txt y notificar vÃ­a correo electrÃ³nico al usuario que lo generÃ³.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultas_cac_central_total(pEmpresa          CHAR(3),
                                                     pSucursal         CHAR(4),
                                                     pFechaInicial     DATE,
                                                     pFechaFinal       DATE,
                                                     pNumSol           CHAR(20),
                                                     pBanCac           CHAR(1),
                                                     pCac_Opt1_1       DECIMAL(5,2),
                                                     pCac_Opt3_1       INTEGER,
                                                     pArea             CHAR(2),
                                                     pStatus           CHAR(2),
                                                     pCausa            CHAR(3),
													 pProducto         CHAR(4))
RETURNING
          CHAR(6),          -- Codigo de Retorno
          INTEGER           -- Total de Registros

DEFINE cNumSolicitud           CHAR(20);
DEFINE cNumCte                 CHAR(20);
DEFINE cSucursal               CHAR(4);
DEFINE dtFechaInsert           DATE;
DEFINE dtFechaModificacion     DATE;
DEFINE dMontoSolicitado        DECIMAL(18,2);
DEFINE cStatusSol              CHAR(2);
DEFINE cTipoSolicitud          CHAR(1);
DEFINE iInfoBuro               INTEGER;
DEFINE cComentarioAut          CHAR(511);
DEFINE iRevisionCac            INTEGER;
DEFINE cNombreCte              CHAR(104);
DEFINE cRFC                    CHAR(13);
DEFINE dSituacionPago          DECIMAL(5,2);
DEFINE iMesesHistoria          INTEGER;
DEFINE dSeccion1               DECIMAL(18,2);
DEFINE dSeccion2               DECIMAL(18,2);
DEFINE dSeccionAux             DECIMAL(18,2);
DEFINE dSumaSecciones          DECIMAL(18,2);
DEFINE iCantidad               INTEGER;
DEFINE icuantos                INTEGER;
DEFINE iSecAux                 INTEGER;
DEFINE cEmpAux                 CHAR(3);
DEFINE iSqlErr                 INTEGER;
DEFINE iIsamErr                INTEGER;
DEFINE cErrorInfo              CHAR(80);
DEFINE cCodRet                 CHAR(6);
DEFINE cMensajeRet             CHAR(80);
DEFINE cFecha                  CHAR(10);
DEFINE cCausa				   CHAR(3);
DEFINE dECValor1			   DECIMAL(5,2);
DEFINE dECValor2			   DECIMAL(5,2);
DEFINE dMACValor1			   DECIMAL(5,2);
DEFINE dMACValor2			   DECIMAL(5,2);
DEFINE dPSValor1			   DECIMAL(5,2);
DEFINE dPSValor2			   DECIMAL(5,2);
DEFINE iTotReg                 INTEGER;
DEFINE iMeseshist              INTEGER;
DEFINE cProducto               CHAR(4);

DEFINE sol_pBanCac				CHAR(20);
DEFINE sol_pCac_Opt3_1			CHAR(20);
DEFINE sol_sucursal				CHAR(20);
DEFINE sol_pProducto			CHAR(20);
DEFINE sol_status				CHAR(20);
DEFINE sol_causa				CHAR(20);
DEFINE sol_InfoBuro				CHAR(20);
DEFINE sol_InfoBuro2			CHAR(20);
DEFINE sol_resum				CHAR(20);
DEFINE sol_conteo				INTEGER;
DEFINE count_InfoBuro			INTEGER;
DEFINE count_InfoBuro2			INTEGER;
LET cNumSolicitud              = '';
LET cNumCte                    = '';
LET cSucursal                  = '';
LET dtFechaInsert              = DATE(1);
LET dtFechaModificacion        = DATE(1);
LET dMontoSolicitado           = 0;
LET cStatusSol                 = '';
LET cTipoSolicitud             = '';
LET iInfoBuro                  = 0;
LET cComentarioAut             = '';
LET iRevisionCac               = 0;
LET cNombreCte                 = '';
LET cRFC                       = '';
LET dSituacionPago             = 0;
LET iMesesHistoria             = 0;
LET dSeccion1                  = 0;
LET dSeccion2                  = 0;
LET dSeccionAux                = 0;
LET dSumaSecciones             = 0;
LET iCantidad                  = 0;
LET icuantos                   = 0;
LET iSecAux                    = 0;
LET cEmpAux                    = '';
LET iSqlErr                    = 0;
LET iIsamErr                   = 0;
LET cErrorInfo                 = '';
LET cCodRet                    = '';
LET cMensajeRet                = '';
LET cFecha                     = '';
LET cCausa					   = '10';
LET dECValor1				   = 0.0;
LET dECValor2				   = 0.0;
LET dMACValor1				   = 0.0;
LET dMACValor2				   = 0.0;
LET dPSValor1				   = 0.0;
LET dPSValor2				   = 0.0;
LET iMeseshist                 = 0;
LET cProducto                  = "";
LET iTotReg                    = 0;


LET sol_pBanCac				= '';
LET sol_pCac_Opt3_1			= '';
LET sol_sucursal			= '';
LET sol_pProducto			= '';
LET sol_status				= '';
LET sol_causa				= '';
LET sol_InfoBuro			= '';
LET sol_InfoBuro2			= '';
LET sol_resum				= '';
LET sol_conteo 				= 0;
LET count_InfoBuro			= 0;
LET count_InfoBuro2			= 0;



-- ** HISTORIAL DE CAMBIOS ** --
--  Autor: Roque Solis.
--  Fecha : 02/25/2009.
--  Comentarios: Se quitaron las restricciones de comprobacion de ingresos.
-- Autor: Paul Ivan Quintero Varela.
-- Fecha: 04/05/2009.
-- Comentarios: Se modifica para contemplar en la seleccion principal los 3 tipos de consulta
--                        adicionales (Numero cte, Nombre y Numero de solicitud).
--Autor Roque Solis
--25/05/2009
--Comentarios: Se quitaron las consultas por nombre y numero de cliente,
-- se agrego el rfc
--
--Autor Mohamed Carreon
--07/06/ 2010
--Comentarios: se agrego la causa del status y los filtros para los criterios del cac y mc.
--Autor: Viridiana Osobampo Aguilar
--24/01/ 2011
--Comentarios: Se modifica para que la validacion de eficiencia, meses de historia y puntuacion scoring
--                        solo se realice cuando se trate de una consulta por CAC o MC.

BEGIN
ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      RETURN cCodRet,iTotReg;
   END IF;
END EXCEPTION;

--  Se genera archivo DEBUG!
----SET DEBUG FILE TO '/home/sysifx/Viridiana/sp_consultas_CAC_central.out';
----TRACE ON;
-- SET DEBUG FILE TO '/informix/Israel/sp_consultas_cac_central_total_itd.out';
-- TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

LET cCodRet= "000000";
LET cMensajeRet= "Se realizo la consulta al central correctamente.";

 IF NVL(pSucursal,'') = '' THEN
    LET pSucursal = NULL;
 END IF;

 IF pFechaInicial = '' THEN
    LET pFechaInicial = DATE(1);
 END IF;

 IF pFechaFinal = '' THEN
    LET pFechaFinal = CURRENT;
 END IF;

 IF pFechaInicial IS NOT NULL AND pFechaFinal IS NULL THEN
     SELECT valor
           INTO cFecha
           FROM bdicred:"informix".sd_param
          WHERE cod_param='030';
     LET pFechaInicial=DATE(cFecha);
  END IF;

 IF pNumSol = '' THEN
    LET pNumSol = NULL;
 END IF;

IF NVL(pNumSol,"")  <> "" THEN 

		-- Se obtienen los datos de la solicitud.
		 SELECT
				sol.num_solicitud,         -- Numero de Solicitud
				sol.numcte,                -- Numero Cte
				sol.status_solicitud,      -- Status Solicitud
				sol.tipo_solicitud,        -- Tipo Solicitud
				sol.num_producto,
				aut.revision_cac,
				sol.sucursal,
				aut.causa_solicitud
			FROM bdisolic:"informix".ss_solicitudes sol
			JOIN bdisolic:"informix".ss_autorizacion aut ON (aut.num_solicitud= sol.num_solicitud AND aut.empresa= sol.empresa  AND aut.status_solicitud= sol.status_solicitud)
			FULL OUTER JOIN bdisolic:"informix".ss_autorizacion_especial esp ON (esp.empresa= sol.empresa AND esp.num_solicitud= sol.num_solicitud 
				AND esp.numcte=sol.numcte and sol.status_solicitud= esp.status_nvo)
		 WHERE sol.num_solicitud=  pNumSol 
		   AND sol.empresa= pEmpresa
		   AND sol.status_solicitud NOT IN ("PC","AN")
---		   AND sol.fecha_insert between pFechaInicial and pFechaFinal
		INTO temp paso1; 
				   
--			SELECT count (*) INTO v_conteo FROM paso1

			
			IF pBanCac <> 'N' THEN
				---- Si es diferente de N solo se dejan RT
				FOREACH
					SELECT num_solicitud
					INTO sol_pBanCac
					FROM paso1
					WHERE status_solicitud <> 'RT'		

					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_pBanCac;
					COMMIT;
				END FOREACH;
				
			END IF;
		
			IF pCac_Opt3_1 = 1 THEN			
				FOREACH
					SELECT num_solicitud
					INTO sol_pCac_Opt3_1
					FROM paso1
					WHERE revision_cac = 0
				
					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_pCac_Opt3_1;
					COMMIT;
				END FOREACH;
			END IF;
	
			IF pSucursal IS NOT NULL THEN			
				FOREACH
					SELECT num_solicitud
					INTO sol_sucursal
					FROM paso1
					WHERE sucursal <> pSucursal
				
					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_sucursal;
					COMMIT;
				END FOREACH;
			END IF;	

			IF pProducto <> '' THEN			
				FOREACH
					SELECT num_solicitud
					INTO sol_pProducto
					FROM paso1
					WHERE num_producto <> pProducto
				
					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_pProducto;
					COMMIT;
				END FOREACH;
			END IF;				

			IF pStatus <> '' THEN			
				FOREACH
					SELECT num_solicitud
					INTO sol_status
					FROM paso1
					WHERE status_solicitud <> pStatus
				
					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_status;
					COMMIT;
				END FOREACH;
			END IF;	

			IF pCausa <> '' THEN			
				FOREACH
					SELECT num_solicitud
					INTO sol_causa
					FROM paso1
					WHERE causa_solicitud <> pCausa
				
					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_causa;
					COMMIT;
				END FOREACH;
			END IF;	

			SELECT count (a.num_solicitud)
			INTO count_InfoBuro  
			FROM paso1 a
			join bdiburo:"informix".br_traslado AS tras on (a.num_solicitud = tras.num_solicitud)
			LEFT OUTER JOIN  bdiburo:"informix".sb_regreso AS reg ON (a.num_solicitud = reg.num_solicitud)
			WHERE status_solicitud in ('BC','CC');
			
			IF count_InfoBuro > 0 THEN
				FOREACH WITH HOLD
					SELECT a.num_solicitud
						INTO sol_InfoBuro  
						FROM paso1 a
						join bdiburo:"informix".br_traslado AS tras on (a.num_solicitud = tras.num_solicitud)
						LEFT OUTER JOIN  bdiburo:"informix".sb_regreso AS reg ON (a.num_solicitud = reg.num_solicitud)
						WHERE status_solicitud in ('BC','CC')
					
					BEGIN;
						DELETE FROM paso1 WHERE num_solicitud = sol_InfoBuro;
					COMMIT;
				
				END FOREACH;
			END IF;
			
				
				SELECT count (a.num_solicitud)
				INTO count_InfoBuro2  
				FROM paso1 a
				join bdiburo:"informix".br_traslado AS tras on (a.num_solicitud = tras.num_solicitud)
				LEFT OUTER JOIN  bdiburo:"informix".sb_regreso_2011 AS reg ON (a.num_solicitud = reg.num_solicitud)
				WHERE status_solicitud in ('BC','CC');
				
				IF count_InfoBuro2 > 0 THEN 
			
					FOREACH WITH HOLD
						SELECT a.num_solicitud
							INTO sol_InfoBuro2  
							FROM paso1 a
							join bdiburo:"informix".br_traslado AS tras on (a.num_solicitud = tras.num_solicitud)
							LEFT OUTER JOIN  bdiburo:"informix".sb_regreso_2011 AS reg ON (a.num_solicitud = reg.num_solicitud)
							WHERE status_solicitud in ('BC','CC')
						
						BEGIN;
							DELETE FROM paso1 WHERE num_solicitud = sol_InfoBuro2;
						COMMIT;
					
					END FOREACH;
				END IF;
				
			   SELECT count (a.num_solicitud)
				  INTO sol_conteo
				  FROM paso1 a 
				  join bdisolic:"informix".ss_resum_scor_fin ef on (a.num_solicitud = ef.num_solicitud)
				 WHERE ef.situacion_pago IS NULL AND ef.meses_historia IS NULL AND a.num_producto <> '6011';
			
				IF sol_conteo > 0 THEN 
					FOREACH WITH HOLD			
						SELECT a.num_solicitud
						  INTO sol_resum
						  FROM paso1 a 
						  join bdisolic:"informix".ss_resum_scor_fin ef on (a.num_solicitud = ef.num_solicitud)
						 WHERE ef.situacion_pago  AND ef.meses_historia AND a.num_producto <> '6011'

						BEGIN;
							DELETE FROM paso1 WHERE num_solicitud = sol_resum;
						COMMIT;
						  
					END FOREACH;
				END IF;
				
		Select count (*) INTO iTotReg FROM paso1;

	RETURN cCodRet,iTotReg;
				
ELSE
		-- Se obtienen los datos de la solicitud.
		 SELECT
				sol.num_solicitud,         -- Numero de Solicitud
				sol.numcte,                -- Numero Cte
				sol.status_solicitud,      -- Status Solicitud
				sol.tipo_solicitud,        -- Tipo Solicitud
				sol.num_producto,
				aut.revision_cac,
				sol.sucursal,
				aut.causa_solicitud
			FROM bdisolic:"informix".ss_solicitudes sol
			JOIN bdisolic:"informix".ss_autorizacion aut ON (aut.num_solicitud= sol.num_solicitud AND aut.empresa= sol.empresa  AND aut.status_solicitud= sol.status_solicitud)
			FULL OUTER JOIN bdisolic:"informix".ss_autorizacion_especial esp ON (esp.empresa= sol.empresa AND esp.num_solicitud= sol.num_solicitud 
				AND esp.numcte=sol.numcte and sol.status_solicitud= esp.status_nvo)
		 WHERE sol.empresa= pEmpresa
		   AND sol.status_solicitud NOT IN ("PC","AN")
		   AND sol.fecha_insert between pFechaInicial and pFechaFinal
		INTO temp paso1 ;
				   
--			SELECT count (*) INTO v_conteo FROM paso1

			
			IF pBanCac <> 'N' THEN
				---- Si es diferente de N solo se dejan RT
				FOREACH
					SELECT num_solicitud
					INTO sol_pBanCac
					FROM paso1
					WHERE status_solicitud <> 'RT'		

					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_pBanCac;
					COMMIT;
				END FOREACH;
				
			END IF;
		
			IF pCac_Opt3_1 = 1 THEN			
				FOREACH
					SELECT num_solicitud
					INTO sol_pCac_Opt3_1
					FROM paso1
					WHERE revision_cac = 0
				
					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_pCac_Opt3_1;
					COMMIT;
				END FOREACH;
			END IF;
	
			IF pSucursal IS NOT NULL THEN			
				FOREACH
					SELECT num_solicitud
					INTO sol_sucursal
					FROM paso1
					WHERE sucursal <> pSucursal
				
					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_sucursal;
					COMMIT;
				END FOREACH;
			END IF;	

			IF pProducto <> '' THEN			
				FOREACH
					SELECT num_solicitud
					INTO sol_pProducto
					FROM paso1
					WHERE num_producto <> pProducto
				
					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_pProducto;
					COMMIT;
				END FOREACH;
			END IF;				

			IF pStatus <> '' THEN			
				FOREACH
					SELECT num_solicitud
					INTO sol_status
					FROM paso1
					WHERE status_solicitud <> pStatus
				
					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_status;
					COMMIT;
				END FOREACH;
			END IF;	

			IF pCausa <> '' THEN			
				FOREACH
					SELECT num_solicitud
					INTO sol_causa
					FROM paso1
					WHERE causa_solicitud <> pCausa
				
					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_causa;
					COMMIT;
				END FOREACH;
			END IF;	
			
			SELECT count (a.num_solicitud)
			INTO count_InfoBuro  
			FROM paso1 a
			join bdiburo:"informix".br_traslado AS tras on (a.num_solicitud = tras.num_solicitud)
			LEFT OUTER JOIN  bdiburo:"informix".sb_regreso AS reg ON (a.num_solicitud = reg.num_solicitud)
			WHERE status_solicitud in ('BC','CC');
			
			IF count_InfoBuro > 0 THEN
				FOREACH WITH HOLD
					SELECT a.num_solicitud
						INTO sol_InfoBuro  
						FROM paso1 a
						join bdiburo:"informix".br_traslado AS tras on (a.num_solicitud = tras.num_solicitud)
						LEFT OUTER JOIN  bdiburo:"informix".sb_regreso AS reg ON (a.num_solicitud = reg.num_solicitud)
						WHERE status_solicitud in ('BC','CC')
					
					BEGIN;
						DELETE FROM paso1 WHERE num_solicitud = sol_InfoBuro;
					COMMIT;
				
				END FOREACH;
			END IF;
			
				
				SELECT count (a.num_solicitud)
				INTO count_InfoBuro2  
				FROM paso1 a
				join bdiburo:"informix".br_traslado AS tras on (a.num_solicitud = tras.num_solicitud)
				LEFT OUTER JOIN  bdiburo:"informix".sb_regreso_2011 AS reg ON (a.num_solicitud = reg.num_solicitud)
				WHERE status_solicitud in ('BC','CC');
				
				IF count_InfoBuro2 > 0 THEN 
			
					FOREACH WITH HOLD
						SELECT a.num_solicitud
							INTO sol_InfoBuro2  
							FROM paso1 a
							join bdiburo:"informix".br_traslado AS tras on (a.num_solicitud = tras.num_solicitud)
							LEFT OUTER JOIN  bdiburo:"informix".sb_regreso_2011 AS reg ON (a.num_solicitud = reg.num_solicitud)
							WHERE status_solicitud in ('BC','CC')
						
						BEGIN;
							DELETE FROM paso1 WHERE num_solicitud = sol_InfoBuro2;
						COMMIT;
					
					END FOREACH;
				END IF;
				
			   SELECT count (a.num_solicitud)
				  INTO sol_conteo
				  FROM paso1 a 
				  join bdisolic:"informix".ss_resum_scor_fin ef on (a.num_solicitud = ef.num_solicitud)
				 WHERE ef.situacion_pago IS NULL AND ef.meses_historia IS NULL AND a.num_producto <> '6011';
			
				IF sol_conteo > 0 THEN 
					FOREACH WITH HOLD			
						SELECT a.num_solicitud
						  INTO sol_resum
						  FROM paso1 a 
						  join bdisolic:"informix".ss_resum_scor_fin ef on (a.num_solicitud = ef.num_solicitud)
						 WHERE ef.situacion_pago  AND ef.meses_historia AND a.num_producto <> '6011'

						BEGIN;
							DELETE FROM paso1 WHERE num_solicitud = sol_resum;
						COMMIT;
						  
					END FOREACH;
				END IF;
				
		Select count (*) INTO iTotReg FROM paso1;

	RETURN cCodRet,iTotReg;
			
END IF

END

END PROCEDURE;
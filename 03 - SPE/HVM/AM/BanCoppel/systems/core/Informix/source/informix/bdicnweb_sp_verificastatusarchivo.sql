CREATE PROCEDURE "informix".sp_verificastatusarchivo(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoProceso CHAR(12), pNombreArchivo CHAR(22))
	RETURNING CHAR(5) AS codret,
			  CHAR(1) AS status,
			  CHAR(1) AS bandera_det_error,
			  CHAR(1) AS muestra_msn,
			  CHAR(1) AS error_proceso,
			  CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cBanDetError CHAR(1);
	DEFINE cMuestraMsn CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cBanDetError = '';
	LET cMuestraMsn = '';
	LET cErrorProceso = '';
	LET cError = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			--LET cCodRet = iSqlErr;
			LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,cBanDetError,cMuestraMsn,cErrorProceso,cError;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_verificastatusarchivo.out';
		--TRACE ON;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoProceso = '' OR pNombreArchivo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,cBanDetError,cMuestraMsn,cErrorProceso,cError;	
		END IF;		
			
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,cBanDetError,cMuestraMsn,cErrorProceso,cError;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT status,bandera_det_error,muestra_msn,error_proceso,error
		INTO cStatus,cBanDetError,cMuestraMsn,cErrorProceso,cError
		FROM bdicnweb:"informix".sw_cr_statuslecturaarchivos
		WHERE usuario = TRIM(pUsuario) 
		AND tipo_proceso = TRIM(UPPER(pTipoProceso)) 
		AND archivo = TRIM(pNombreArchivo);
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,cBanDetError,cMuestraMsn,cErrorProceso,cError;			
		ELSE 			
			RETURN cCodRet,cStatus,cBanDetError,cMuestraMsn,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 15/08/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Carga manual de archivos recibidos', 
'DESCRIPCION: SPL encargado de hacer la validaciï¿½n inicio/fin para el proceso de lectura de archivos.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consarchrecibidos(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaConsulta DATE, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,                       
			CHAR(22) AS nombre_archivo,                               
			CHAR(3) AS cod_operacion,                           
			CHAR(25) AS hora_entrada,                               
			CHAR(10) AS lectura,                           
			INTEGER AS tot_reg,                      
			CHAR(100) AS comentario,                
			CHAR(10) AS fecha_aplic,                     
			CHAR(25) AS hora_aplic,
			CHAR(16) AS status,
			CHAR(1) AS procesado;                  
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE dFechaHoy DATE;
	DEFINE cNombreArch CHAR(22);
	DEFINE cCodOperacion CHAR(3);
	DEFINE cHoraEntrada CHAR(25);
	DEFINE cTipoIngreso CHAR(1);
	DEFINE iTotalRegistros INTEGER;
	DEFINE cComentario CHAR(100);
	DEFINE cFechaAplic CHAR(10);
	DEFINE cHoraAplic CHAR(25);
	DEFINE cCveStatus CHAR(2);
	DEFINE cProcesado CHAR(1);
	DEFINE cLectura CHAR(10);
	DEFINE cStatus CHAR(16);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET dFechaHoy = ''; 
	LET cNombreArch = '';
	LET cCodOperacion = '';
	LET cHoraEntrada = '';
	LET cTipoIngreso = '';
	LET iTotalRegistros = 0;
	LET cComentario = '';
	LET cFechaAplic = '';
	LET cHoraAplic = '';
	LET cCveStatus = '';
	LET cProcesado = '';
	LET cLectura = '';
	LET cStatus = '';	
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombreArch, cCodOperacion, cHoraEntrada, cLectura, iTotalRegistros, cComentario, cFechaAplic, cHoraAplic, cStatus, cProcesado;   
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consarchrecibidos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaConsulta IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreArch, cCodOperacion, cHoraEntrada, cLectura, iTotalRegistros, cComentario, cFechaAplic, cHoraAplic, cStatus, cProcesado;  
		END IF;
		
		-- VALIDACIï¿½N DE LOS DATOS DE PAGINACIï¿½N
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNombreArch, cCodOperacion, cHoraEntrada, cLectura, iTotalRegistros, cComentario, cFechaAplic, cHoraAplic, cStatus, cProcesado;  
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		--EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombreArch, cCodOperacion, cHoraEntrada, cLectura, iTotalRegistros, cComentario, cFechaAplic, cHoraAplic, cStatus, cProcesado;  
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			
			SELECT SKIP pRegistros FIRST pRecuperacion nombrearchivo, cod_oper, hora_entrada, tipo_ingreso, tot_reg, ult_error, fecha_aplic, hora_aplic, cve_status, procesado 
			INTO cNombreArch, cCodOperacion, cHoraEntrada, cTipoIngreso, iTotalRegistros, cComentario, cFechaAplic, cHoraAplic, cCveStatus, cProcesado
			FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaConsulta ORDER BY secuencia
			IF TRIM(cTipoIngreso) = 'A' THEN
				LET cLectura = 'AUTOMï¿½TICO';
			ELSE
				LET cLectura = 'MANUAL';
			END IF;
			
			IF TRIM(cCveStatus) = '00' THEN
				LET cStatus = '00 PEND PROCESAR';
			ELIF TRIM(cCveStatus) = '01' THEN
				LET cStatus = '01 PROCESADO';
			ELSE
				LET cStatus = cLectura;
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, UPPER(cNombreArch), UPPER(cCodOperacion), cHoraEntrada, cLectura, iTotalRegistros, UPPER(cComentario), cFechaAplic, cHoraAplic, cStatus, cProcesado WITH RESUME;
			
			LET cLectura = '';
			LET cStatus = '';
			
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00782'; 
			RETURN cCodRet, cNombreArch, cCodOperacion, cHoraEntrada, cLectura, iTotalRegistros, cComentario, cFechaAplic, cHoraAplic, cStatus, cProcesado;  
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNombreArch, cCodOperacion, cHoraEntrada, cLectura, iTotalRegistros, cComentario, cFechaAplic, cHoraAplic, cStatus, cProcesado;  
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 26/04/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Monitor de archivos recibidos', 
'DESCRIPCION: SPL encargado de consultar el detalle de los archivos importados y procesados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultadetallearchivo(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(22), 
pTipo CHAR(3), pStatus CHAR(16), pFechaConsulta DATE, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,                       
			CHAR(20) AS cuenta,                               
			INTEGER AS num_cheque,                           
			MONEY(16,2) AS importe,                               
			CHAR(2) AS cod_operacion,                           
			CHAR(3) AS img_f,                      
			CHAR(3) AS img_t,                
			CHAR(16) AS status,                     
			CHAR(5) AS codigo_ret,
			DATE AS fecha_proceso,
			CHAR(2) AS motivo_dev,
			CHAR(35) AS desc_motivodev;     

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE dFechaHoy DATE;
	DEFINE cCuenta CHAR(20);
	DEFINE iNumCheque INTEGER;
	DEFINE mImporte MONEY(16,2);
	DEFINE cCodOperacion CHAR(2);
	DEFINE cImgStat1 CHAR(1);
	DEFINE cImgStat2 CHAR(1);
	DEFINE cStatus CHAR(2);
	DEFINE cCodigoRet CHAR(5);
	DEFINE dFechaProceso DATE;
	DEFINE cMotivoDev CHAR(2);
	DEFINE cTruncamiento CHAR(1);
	DEFINE cImgF CHAR(3);
	DEFINE cImgT CHAR(3);
	DEFINE cDescStatus CHAR(16);
	DEFINE iTotImagenRec INTEGER;
	DEFINE cDescMotivoDev CHAR(35);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET dFechaHoy = ''; 
	LET cCuenta = '';
	LET iNumCheque = 0;
	LET mImporte = 0.00;
	LET cCodOperacion = '';
	LET cImgStat1 = '';
	LET cImgStat2 = '';
	LET cStatus = '';
	LET cCodigoRet = '';
	LET dFechaProceso = '';
	LET cMotivoDev = '';
	LET cTruncamiento = '';
	LET cImgF = '';
	LET cImgT = '';
	LET cDescStatus = '';
	LET iTotImagenRec = 0;
	LET cDescMotivoDev = '';
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCuenta, iNumCheque, mImporte, cCodOperacion, cImgF, cImgT, cDescStatus, cCodigoRet, dFechaProceso, cMotivoDev, cDescMotivoDev;   
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultadetallearchivo.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' OR pFechaConsulta IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCuenta, iNumCheque, mImporte, cCodOperacion, cImgF, cImgT, cDescStatus, cCodigoRet, dFechaProceso, cMotivoDev, cDescMotivoDev; 
		END IF;
		
		-- VALIDACIï¿½N DE LOS DATOS DE PAGINACIï¿½N
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cCuenta, iNumCheque, mImporte, cCodOperacion, cImgF, cImgT, cDescStatus, cCodigoRet, dFechaProceso, cMotivoDev, cDescMotivoDev;
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCuenta, iNumCheque, mImporte, cCodOperacion, cImgF, cImgT, cDescStatus, cCodigoRet, dFechaProceso, cMotivoDev, cDescMotivoDev; 
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pTipo = 'IMG' THEN
			LET cCodRet = '00783';
			RETURN cCodRet, cCuenta, iNumCheque, mImporte, cCodOperacion, cImgF, cImgT, cDescStatus, cCodigoRet, dFechaProceso, cMotivoDev, cDescMotivoDev;  
		END IF;
		IF pStatus = '' THEN
			LET cCodRet = '00784';
			RETURN cCodRet, cCuenta, iNumCheque, mImporte, cCodOperacion, cImgF, cImgT, cDescStatus, cCodigoRet, dFechaProceso, cMotivoDev, cDescMotivoDev; 
		END IF;
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion 
			c_cuenta, c_cheque, c_importe, cod_operacion, 
			img1_stat, img2_stat, status, 
			cod_ret, fecha_proceso, mot_devol, truncamiento 
			INTO cCuenta, iNumCheque, mImporte, cCodOperacion, cImgStat1, cImgStat2, cStatus, cCodigoRet, dFechaProceso, cMotivoDev, cTruncamiento
			FROM bditef:"informix".cce_propios_det 
			WHERE nombrearchivo = pNombreArchivo 
			AND fecha_entrada = pFechaConsulta 
			ORDER BY secuencia 
			
			IF TRIM(cImgStat1) = '3' THEN
				LET cImgF = 'SI';
				LET iTotImagenRec = iTotImagenRec + 1;
			ELSE
				LET cImgF = 'NO';
			END IF;
			
			IF TRIM(cImgStat2) = '3' THEN
				LET cImgT = 'SI';
				LET iTotImagenRec = iTotImagenRec + 1;
			ELSE
				LET cImgT = 'NO';
			END IF;
			
			IF TRIM(cTruncamiento) = '1' THEN
			
				IF TRIM(cImgStat1) = '' THEN
					LET cImgF = 'N/A';
				END IF;
				
				IF TRIM(cImgStat2) = '' THEN
					LET cImgT = 'N/A';
				END IF;
				
			END IF;
			
			IF TRIM(cStatus) = '01' THEN
				LET cDescStatus = '01 PEND PROCESAR';
			ELIF TRIM(cStatus) = '02' THEN
				LET cDescStatus = '02 PROCESADO';
			ELIF TRIM(cStatus) = '04' THEN
				LET cDescStatus = '04 ELIMINADO';
			ELIF TRIM(cStatus) = '05' THEN
				LET cDescStatus = '05 PAGADO';
			ELIF TRIM(cStatus) = '07' THEN
				LET cDescStatus = '07 REVERSADO';
			ELIF TRIM(cStatus) = '10' THEN
				LET cDescStatus = '10 DEV Lï¿½GICA';
			ELIF TRIM(cStatus) = '11' THEN
				LET cDescStatus = '11 DEV Fï¿½SICA';			
			END IF;
			
			SELECT descripcion INTO cDescMotivoDev
			FROM bdinteg:"informix".si_coddevcam
			WHERE codigo = cMotivoDev;
					
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cCuenta, iNumCheque, mImporte, cCodOperacion, TRIM(cImgF), TRIM(cImgT), TRIM(cDescStatus), cCodigoRet, dFechaProceso, cMotivoDev, UPPER(cDescMotivoDev) WITH RESUME;
			
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00785'; 
			RETURN cCodRet, cCuenta, iNumCheque, mImporte, cCodOperacion, cImgF, cImgT, cDescStatus, cCodigoRet, dFechaProceso, cMotivoDev, cDescMotivoDev;  
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cCuenta, iNumCheque, mImporte, cCodOperacion, cImgF, cImgT, cDescStatus, cCodigoRet, dFechaProceso, cMotivoDev, cDescMotivoDev;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 27/04/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Monitor de archivos recibidos', 
'DESCRIPCION: SPL encargado de consultar el detalle del archivo.',
'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 24/05/2017',
'DESCRIPCION: Se modifica SPL para agregar el retorno de la descripciï¿½n del motivo devoluciï¿½n.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consdetallesumarioarch(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(22), pTipo CHAR(3), pStatus CHAR(16), pFechaConsulta DATE)
	RETURNING CHAR(5) AS codret,                       
		INTEGER AS num_operaciones,                                                          
		MONEY(16,2) AS importe_total,                               
		INTEGER AS total_reg_truncados,                           
		INTEGER AS img_recibidas,                      
		INTEGER AS img_faltates;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE dFechaHoy DATE;
	DEFINE cCuenta CHAR(20);
	DEFINE iNumCheque INTEGER;
	DEFINE mImporte MONEY(16,2);
	DEFINE cCodOperacion CHAR(2);
	DEFINE cImgStat1 CHAR(1);
	DEFINE cImgStat2 CHAR(1);
	DEFINE cStatus CHAR(2);
	DEFINE cCodigoRet CHAR(5);
	DEFINE dFechaProceso DATE;
	DEFINE cMotivoDev CHAR(2);
	DEFINE cTruncamiento CHAR(1);
	DEFINE cImgF CHAR(3);
	DEFINE cImgT CHAR(3);
	DEFINE cDescStatus CHAR(16);
	DEFINE iTotImagenRec INTEGER;
	DEFINE iTotalImgRec INTEGER;
	DEFINE iNumOperaciones INTEGER;
	DEFINE mImporteTotal MONEY(16,2);
	DEFINE iTotalRegistrosTi INTEGER;
	DEFINE iTotalImgGsum INTEGER;
	DEFINE iTotalImgFalt INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET dFechaHoy = ''; 
	LET cCuenta = '';
	LET iNumCheque = 0;
	LET mImporte = 0.00;
	LET cCodOperacion = '';
	LET cImgStat1 = '';
	LET cImgStat2 = '';
	LET cStatus = '';
	LET cCodigoRet = '';
	LET dFechaProceso = '';
	LET cMotivoDev = '';
	LET cTruncamiento = '';
	LET cImgF = '';
	LET cImgT = '';
	LET cDescStatus = '';
	LET iTotImagenRec = 0;
	LET iTotalImgRec = 0;
	LET iNumOperaciones = 0;
	LET mImporteTotal = 0.00;
	LET iTotalRegistrosTi = 0;
	LET iTotalImgGsum = 0;
	LET iTotalImgFalt = 0;
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumOperaciones, mImporteTotal, iTotalRegistrosTi, iTotalImgRec, iTotalImgFalt;   
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consdetallesumarioarch.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' OR pFechaConsulta IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumOperaciones, mImporteTotal, iTotalRegistrosTi, iTotalImgRec, iTotalImgFalt;
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNumOperaciones, mImporteTotal, iTotalRegistrosTi, iTotalImgRec, iTotalImgFalt;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pTipo = 'IMG' THEN
			LET cCodRet = '00783';
			RETURN cCodRet, iNumOperaciones, mImporteTotal, iTotalRegistrosTi, iTotalImgRec, iTotalImgFalt;
		END IF;
		IF pStatus = '' THEN
			LET cCodRet = '00784';
			RETURN cCodRet, iNumOperaciones, mImporteTotal, iTotalRegistrosTi, iTotalImgRec, iTotalImgFalt;
		END IF;
		
		FOREACH
			SELECT img1_stat, img2_stat	INTO cImgStat1, cImgStat2
			FROM bditef:"informix".cce_propios_det WHERE nombrearchivo = pNombreArchivo AND fecha_entrada = pFechaConsulta
			
			IF TRIM(cImgStat1) = '3' THEN
				LET iTotImagenRec = iTotImagenRec + 1;
			END IF;
			
			IF TRIM(cImgStat2) = '3' THEN
				LET iTotImagenRec = iTotImagenRec + 1;
			END IF;
			
			LET iTotalImgRec = NVL(iTotImagenRec,0);
		END FOREACH;
		
		SELECT num_operaciones, importe_total, total_reg_ti 
		INTO iNumOperaciones, mImporteTotal, iTotalRegistrosTi
		FROM bditef:"informix".cce_propios_gsum WHERE nombrearchivo = pNombreArchivo AND fecha_entrada = pFechaConsulta;
		
		LET iTotalImgGsum = NVL(iTotalRegistrosTi,0) * 2;
		LET iTotalImgFalt = NVL(iTotalImgGsum,0) - NVL(iTotalImgRec,0);
		
		IF iNumOperaciones = 0 THEN
			LET cCodRet = '00785'; 
		END IF;
		
		RETURN cCodRet, iNumOperaciones, mImporteTotal, iTotalRegistrosTi, iTotalImgRec, iTotalImgFalt;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 27/04/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Monitor de archivos recibidos', 
'DESCRIPCION: SPL encargado de consultar el detalle del sumario.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consarchrecibidos_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaConsulta DATE)
		RETURNING CHAR(5) AS codret,                       
			INTEGER AS num_registros;                  
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE dFechaHoy DATE;
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET dFechaHoy = ''; 	
	LET iNumRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumRegistros;   
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consarchrecibidos_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaConsulta IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumRegistros;  
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNumRegistros;  
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT COUNT(*) INTO iNumRegistros
		FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaConsulta;
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00782'; --NO SE ENCOTRARON ELEMENTOS
		END IF;
		
		RETURN cCodRet, iNumRegistros;  
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 26/04/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Monitor de archivos recibidos', 
'DESCRIPCION: SPL encargado de consultar el nï¿½mero total de registros del detalle del grid ...',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultadetallearchivo_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(22), 
pTipo CHAR(3), pStatus CHAR(16), pFechaConsulta DATE)
		RETURNING CHAR(5) AS codret,                       
				   INTEGER AS num_registros;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE dFechaHoy DATE;
	DEFINE cCuenta CHAR(20);
	DEFINE iNumCheque INTEGER;
	DEFINE mImporte MONEY(16,2);
	DEFINE cCodOperacion CHAR(2);
	DEFINE cImgStat1 CHAR(1);
	DEFINE cImgStat2 CHAR(1);
	DEFINE cStatus CHAR(2);
	DEFINE cCodigoRet CHAR(5);
	DEFINE dFechaProceso DATE;
	DEFINE cMotivoDev CHAR(2);
	DEFINE cTruncamiento CHAR(1);
	DEFINE cImgF CHAR(3);
	DEFINE cImgT CHAR(3);
	DEFINE cDescStatus CHAR(16);
	DEFINE iTotImagenRec INTEGER;
	
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET dFechaHoy = ''; 
	LET cCuenta = '';
	LET iNumCheque = 0;
	LET mImporte = 0.00;
	LET cCodOperacion = '';
	LET cImgStat1 = '';
	LET cImgStat2 = '';
	LET cStatus = '';
	LET cCodigoRet = '';
	LET dFechaProceso = '';
	LET cMotivoDev = '';
	LET cTruncamiento = '';
	LET cImgF = '';
	LET cImgT = '';
	LET cDescStatus = '';
	LET iTotImagenRec = 0;
	
	LET iNumRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumRegistros;   
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultadetallearchivo_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' OR pFechaConsulta IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumRegistros;  
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNumRegistros;  
		END IF; 
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pTipo = 'IMG' THEN
			LET cCodRet = '00783';
			RETURN cCodRet, iNumRegistros;   
		END IF;
		IF pStatus = '' THEN
			LET cCodRet = '00784';
			RETURN cCodRet, iNumRegistros; 
		END IF;
		SELECT COUNT(*)	INTO iNumRegistros
		FROM bditef:"informix".cce_propios_det WHERE nombrearchivo = pNombreArchivo AND fecha_entrada = pFechaConsulta; 
			
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00785';  
		END IF;
		
		RETURN cCodRet, iNumRegistros;  
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 27/04/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Monitor de archivos recibidos', 
'DESCRIPCION: SPL encargado de consultar el nï¿½mero total de registros del detalle del archivo.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consdetallemovchequespropios(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,                       
			CHAR(4) AS sucursal,                               
			CHAR(40) AS nombre_suc,                           
			CHAR(20) AS cuenta,                               
			INTEGER AS num_cheque,                           
			MONEY(16,2) AS monto,                      
			CHAR(21) AS fecha_hora,                
			CHAR(16) AS folio_suc,                     
			CHAR(4) AS transaccion,
			CHAR(1) AS digitalizado;                
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE dFechaHoy DATE;  
	DEFINE cSucursal CHAR(4);                                                   
	DEFINE cNombreSuc CHAR(40);      
	DEFINE cCuenta CHAR(20);
	DEFINE iNumCheque INTEGER;
	DEFINE mMonto MONEY(16,2); 
	DEFINE cFechaAlta CHAR(10);  
	DEFINE cHoraAlta CHAR(10);
	DEFINE cFolioSuc CHAR(16);
	DEFINE cTransaccion CHAR(4); 
	DEFINE cFechaHora CHAR(21);
	DEFINE cHora CHAR(8);
	DEFINE dFechaPresenta DATE;
	DEFINE cDigitalizado CHAR(1);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET dFechaHoy = ''; 
	LET cSucursal = '';                                                  
	LET cNombreSuc = '';
	LET cCuenta = '';
	LET iNumCheque = 0;
	LET mMonto = 0.00; 
	LET cFechaAlta = ''; 
	LET cHoraAlta = '';
	LET cFolioSuc = '';
	LET cTransaccion = '';
	LET cFechaHora = '';
	LET cHora = '';
	LET dFechaPresenta = '';
	LET cDigitalizado = '';
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cSucursal, cNombreSuc, cCuenta, iNumCheque, mMonto, cFechaHora, cFolioSuc, cTransaccion, cDigitalizado;   
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consdetallemovchequespropios.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cSucursal, cNombreSuc, cCuenta, iNumCheque, mMonto, cFechaHora, cFolioSuc, cTransaccion, cDigitalizado;  
		END IF;
		
		-- VALIDACIï¿½N DE LOS DATOS DE PAGINACIï¿½N
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cSucursal, cNombreSuc, cCuenta, iNumCheque, mMonto, cFechaHora, cFolioSuc, cTransaccion, cDigitalizado;  
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cSucursal, cNombreSuc, cCuenta, iNumCheque, mMonto, cFechaHora, cFolioSuc, cTransaccion, cDigitalizado;  
		END IF;
		
		SELECT fecha_hoy INTO dFechaHoy 
		FROM bdicheq:"informix".sc_fechas WHERE empresa = '001';
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
		
			SELECT SKIP pRegistros FIRST pRecuperacion suc.sucursal, suc.nombre, doc.cuenta, doc.numchq, doc.monto, doc.fecha_alta, doc.hora_alta, doc.folio_suc, doc.transaccion 
			INTO cSucursal, cNombreSuc, cCuenta, iNumCheque, mMonto, cFechaAlta, cHoraAlta, cFolioSuc, cTransaccion
			FROM bdicheq:"informix".sc_contch_hist AS doc, bdinteg:"informix".si_sucursales AS suc, bdicheq:"informix".sc_movhis AS mov 
			WHERE doc.empresa = '001' AND doc.sucursal = suc.sucursal AND doc.status = 'P' 
			AND doc.fecha_alta = dFechaHoy AND mov.empresa = '001' AND mov.cuenta = doc.cuenta 
			AND mov.transacc_suc = doc.transaccion AND mov.folio_suc = doc.folio_suc 
			AND mov.cancelad <> 'S' ORDER BY doc.fecha_alta, doc.hora_alta
			
			LET cFechaHora = NVL(TRIM(TO_CHAR(DATE(cFechaAlta), '%d/%m/%Y')),'')||' '||NVL(TRIM(cHoraAlta),'');
			LET cDigitalizado = '0';
			FOREACH
				SELECT FIRST 1 fechapresenta INTO dFechaPresenta
				FROM bditef:"informix".cce_cheques_img WHERE empresa = '001' AND cvebanco = '137' 
				AND numcuenta = TRIM(cCuenta) AND numcheque = iNumCheque AND fecha_alta = dFechaHoy
				
				IF NVL(dFechaPresenta,'') <> '' THEN
					LET cDigitalizado = '1';
					LET cHora = NVL(TO_CHAR(dFechaPresenta,'%H:%M:%S'),'');
					
					IF cHora = '00:00:00' THEN
						LET cFechaHora = TO_CHAR(dFechaPresenta,'%d/%m/%Y');
					ELSE
						LET cFechaHora = TO_CHAR(dFechaPresenta,'%d/%m/%Y')||' '||cHora;
					END IF;
				END IF;
			END FOREACH;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cSucursal, UPPER(cNombreSuc), cCuenta, iNumCheque, mMonto, cFechaHora, cFolioSuc, cTransaccion, cDigitalizado WITH RESUME;
			
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, cSucursal, cNombreSuc, cCuenta, iNumCheque, mMonto, cFechaHora, cFolioSuc, cTransaccion, cDigitalizado;  
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '10001';
			RETURN cCodRet, cSucursal, cNombreSuc, cCuenta, iNumCheque, mMonto, cFechaHora, cFolioSuc, cTransaccion, cDigitalizado;  
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 25/04/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Monitor de los cheques propios recibidos en sucursal y central', 
'DESCRIPCION: SPL encargado de consultar el detalle del grid cheques.',
'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 08/02/2016',
'DESCRIPCION: Se modifica SPL para corregir el formato de fechas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consresumenmovcheques(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,                       
			INTEGER AS operados,
			INTEGER AS digitalizados,
			INTEGER AS por_recibir;                
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE dFechaHoy DATE;   
	DEFINE iNumRegistros INTEGER;
	DEFINE cCuenta CHAR(20);
	DEFINE iNumCheque INTEGER;
	DEFINE dFechaPresenta DATE;
	DEFINE iRegDigitalizados INTEGER;
	DEFINE iOperados INTEGER;
	DEFINE iDigitalizados INTEGER;
	DEFINE iPorRecibir INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET dFechaHoy = '';
	LET iNumRegistros = 0;	
	LET cCuenta = '';
	LET iNumCheque = 0;
	LET iRegDigitalizados = 0;
	LET dFechaPresenta = '';
	LET iOperados = 0;
	LET iDigitalizados = 0;
	LET iPorRecibir = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iOperados, iDigitalizados, iPorRecibir;   
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consresumenmovcheques.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iOperados, iDigitalizados, iPorRecibir;   
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iOperados, iDigitalizados, iPorRecibir; 
		END IF;
		
		SELECT fecha_hoy INTO dFechaHoy 
		FROM bdicheq:"informix".sc_fechas WHERE empresa = '001';
		
		SELECT COUNT(*) INTO iNumRegistros
		FROM bdicheq:"informix".sc_contch_hist AS doc, bdinteg:"informix".si_sucursales AS suc, bdicheq:"informix".sc_movhis AS mov 
		WHERE doc.empresa = '001' AND doc.sucursal = suc.sucursal AND doc.status = 'P' 
		AND doc.fecha_alta = dFechaHoy AND mov.empresa = '001' AND mov.cuenta = doc.cuenta 
		AND mov.transacc_suc = doc.transaccion AND mov.folio_suc = doc.folio_suc 
		AND mov.cancelad <> 'S';
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT doc.cuenta, doc.numchq
			INTO cCuenta, iNumCheque
			FROM bdicheq:"informix".sc_contch_hist AS doc, bdinteg:"informix".si_sucursales AS suc, bdicheq:"informix".sc_movhis AS mov 
			WHERE doc.empresa = '001' AND doc.sucursal = suc.sucursal AND doc.status = 'P' 
			AND doc.fecha_alta = dFechaHoy AND mov.empresa = '001' AND mov.cuenta = doc.cuenta 
			AND mov.transacc_suc = doc.transaccion AND mov.folio_suc = doc.folio_suc 
			AND mov.cancelad <> 'S'			
			
			IF EXISTS (SELECT fechapresenta FROM bditef:"informix".cce_cheques_img WHERE empresa = '001' AND cvebanco = '137' 
			AND numcuenta = TRIM(cCuenta) AND numcheque = iNumCheque AND fecha_alta = dFechaHoy) THEN
				LET iRegDigitalizados = 1;
			ELSE 
				LET iRegDigitalizados = 0;
			END IF;
			
			LET iOperados = NVL(iNumRegistros,0);
			LET iDigitalizados = iDigitalizados + iRegDigitalizados;
			LET iPorRecibir = iOperados - iDigitalizados;
		END FOREACH;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iOperados, iDigitalizados, iPorRecibir;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 25/04/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Monitor de los cheques propios recibidos en sucursal y central', 
'DESCRIPCION: SPL encargado de consultar el resumen de las operaciones realizadas durante el dï¿½a.',
'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 08/02/2016',
'DESCRIPCION: Se modifica SPL para corregir el cï¿½lculo de las operaciones realizadas durante el dï¿½a.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catrevisoresfirmas(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(8) AS ejecutivo,
			CHAR(45) AS nombre_ejecutivo;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDesCodRetSp CHAR(80);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iPerfil INTEGER;
	DEFINE cEjecutivo CHAR(8);
	DEFINE cNombreEjecutivo CHAR(45);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cDesCodRetSp = '';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET iPerfil = 0;
	LET cEjecutivo = '';
	LET cNombreEjecutivo = '';
	LET iRecuperacion = 0;
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cEjecutivo, cNombreEjecutivo;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catrevisoresfirmas.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cEjecutivo, cNombreEjecutivo;	
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cEjecutivo, cNombreEjecutivo;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		
		
		-- Perfil Revisor de Firmas
		SELECT valor INTO iPerfil
		FROM bditef:"informix".cce_param WHERE empresa = cEmpresa AND cod_param = '6';
		FOREACH
			SELECT eje.ejecutivo, TRIM(eje.nombre)
			INTO cEjecutivo, cNombreEjecutivo
			FROM bdinteg:"informix".si_ejecut AS eje, bdinteg:"informix".si_perfil_ejecut AS per 
			WHERE eje.ejecutivo = per.ejecutivo AND empresa = '001'
			AND per.perfil = iPerfil
			AND sistema = '01' AND eje.ejecutivo <> "informix"
			ORDER BY eje.nombre
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cEjecutivo, UPPER(cNombreEjecutivo) WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00798'; --NO EXISTEN EJECUTIVOS PARA EL PERFIL DE REVISIï¿½N DE FIRMAS, VERIFIQUE
			RETURN cCodRet, cEjecutivo, cNombreEjecutivo;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 04/05/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Asignaciï¿½n de Revisiï¿½n de Firmas Cheques', 
'DESCRIPCION: SPL encargado de consultar el nï¿½mero y nombre de los ejecutivos revisores de firmas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catguardasignaciones(pUsuario CHAR(8), pIdFuncion CHAR(10), pCheques CHAR(250), pEjecutivo CHAR(8), pFecha CHAR(8))
		RETURNING CHAR(5) AS codret;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNombreCheque CHAR(22);
	DEFINE cNombreChequeSecuencia CHAR(80);
	DEFINE cSecuencia CHAR(22);
	DEFINE iTotal INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNombreCheque = '';
	LET cNombreChequeSecuencia = '';
	LET cSecuencia = '';
	LET iTotal = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_catguardasignaciones.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pCheques = '' OR pEjecutivo = '' OR pFecha = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;

		FOREACH EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena(pCheques, '|')
			INTO cNombreChequeSecuencia
			FOREACH EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena(cNombreChequeSecuencia, ',')
				INTO cSecuencia
				LET cNombreCheque = SUBSTR(TRIM(cNombreChequeSecuencia),LENGTH(cSecuencia)+2,LENGTH(cNombreChequeSecuencia));

				UPDATE bditef:"informix".cce_propios_det
				SET usuario_valida = pEjecutivo
				WHERE nombrearchivo = cNombreCheque
				AND secuencia = cSecuencia
				AND cod_operacion = '40'
				AND fecha_presini = pFecha;

				EXIT FOREACH;
			END FOREACH;
		END FOREACH;
		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 02/06/2016',
'DESCRIPCION: spl que asigna el los documentos a los usuarios',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catchequespendientes(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha CHAR(8), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
		INTEGER AS totalChequesPendientes,
		CHAR(22) AS nombreArchivo,
		INTEGER AS cSecuencia,
		CHAR(8) AS cUsuarioValida;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iCodRetSp INTEGER;
	DEFINE cNombreArchivo CHAR(22);
	DEFINE cSecuencia INTEGER;
	DEFINE cUsuarioValida CHAR(8);
	DEFINE iTotalChequesPendientes INTEGER;
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iCodRetSp = 0;
	LET cNombreArchivo = '';
	LET cSecuencia  = 0;
	LET cUsuarioValida  = '';
	LET iTotalChequesPendientes = 0;
	LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotalChequesPendientes, cNombreArchivo, cSecuencia, cUsuarioValida;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_catchequespendientes.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pFecha = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotalChequesPendientes, cNombreArchivo, cSecuencia, cUsuarioValida;
		END IF;

		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iTotalChequesPendientes, cNombreArchivo, cSecuencia, cUsuarioValida;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotalChequesPendientes, cNombreArchivo, cSecuencia, cUsuarioValida;
		END IF;

		SELECT COUNT(*) INTO iTotalChequesPendientes
		FROM bditef:"informix".cce_propios_det
		WHERE fecha_presini = pFecha
		AND cod_operacion='40'
		AND truncamiento='0'
		AND status='05'
		AND mot_devol='00'
		AND revisado_firmas='N'
		AND TRIM(usuario_valida)='';

		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion
			nombrearchivo,secuencia,usuario_valida
			INTO cNombreArchivo, cSecuencia, cUsuarioValida
			FROM bditef:"informix".cce_propios_det
			WHERE fecha_presini = pFecha
			AND cod_operacion='40'
			AND truncamiento='0'
			AND status='05'
			AND mot_devol='00'
			AND revisado_firmas='N'
			AND TRIM(usuario_valida)=''
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, iTotalChequesPendientes, cNombreArchivo, cSecuencia, cUsuarioValida WITH RESUME;
		END FOREACH;

		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet ='00017';
			RETURN cCodRet, iTotalChequesPendientes, cNombreArchivo, cSecuencia, cUsuarioValida;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet ='1001';
			RETURN cCodRet, iTotalChequesPendientes, cNombreArchivo, cSecuencia, cUsuarioValida;
		END IF;
	END;

END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 01/06/2016',
'DESCRIPCION: spl que consulta los cheques pendientes',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catchequesdetalle(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha CHAR(8), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				CHAR(20) AS cuenta,
				INTEGER AS cheque,
				DECIMAL(16,2) AS importe,
				CHAR(2) AS revisadoFirmas,
				CHAR(54) AS usuarioValida,
				CHAR(38) AS motivoDevol;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iCodRetSp INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cCuenta CHAR(20);
	DEFINE iCheque INTEGER;
	DEFINE dImporte DECIMAL(16,2);
	DEFINE cRevisadoFirmas CHAR(2);
	DEFINE cUsuarioValida CHAR(8);
	DEFINE cMotivoDevol CHAR(2);
	DEFINE cMotivoDevolucion CHAR(38);
	DEFINE cNombre CHAR(45);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iCodRetSp = 0;
	LET iRecuperacion = 0;
	LET cCuenta = "";
	LET iCheque = 0;
	LET dImporte = 0;
	LET cRevisadoFirmas = "";
	LET cUsuarioValida = "";
	LET cMotivoDevol = "";
	LET cMotivoDevolucion = "";
	LET cNombre = "";
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCuenta, iCheque, dImporte, cRevisadoFirmas, TRIM(cUsuarioValida)||' '||TRIM(cNombre), cMotivoDevolucion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catchequesdetalle.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCuenta, iCheque, dImporte, cRevisadoFirmas, TRIM(cUsuarioValida)||' '||TRIM(cNombre), cMotivoDevolucion;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cCuenta, iCheque, dImporte, cRevisadoFirmas, TRIM(cUsuarioValida)||' '||TRIM(cNombre), cMotivoDevolucion;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCuenta, iCheque, dImporte, cRevisadoFirmas, TRIM(cUsuarioValida)||' '||TRIM(cNombre), cMotivoDevolucion;
		END IF;
		
		FOREACH 
			SELECT SKIP pRegistros FIRST pRecuperacion
			c_cuenta, c_cheque, c_importe, revisado_firmas, usuario_valida, mot_devol
			INTO cCuenta, iCheque, dImporte, cRevisadoFirmas, cUsuarioValida, cMotivoDevol
			FROM bditef:"informix".cce_propios_det
			WHERE fecha_presini = pFecha AND
			cod_operacion='40' AND 
			truncamiento='0' AND
			status='05' AND
			revisado_firmas in ('N','S')
			LET iRecuperacion = iRecuperacion + 1;
			
			IF TRIM(cRevisadoFirmas) = "S" THEN
				LET cRevisadoFirmas = "SI";
			ELSE
				LET cRevisadoFirmas = "NO";
			END IF;
			
			IF TRIM(cUsuarioValida) = "" THEN 
				LET cNombre = "Por Asignar...";
			ELSE
				SELECT nombre 
				INTO cNombre
				FROM bdinteg:"informix".si_ejecut 
				WHERE empresa = '001'
				AND ejecutivo = cUsuarioValida;
			END IF;
			
			SELECT codigo || " " || descripcion  INTO cMotivoDevolucion
			FROM bdinteg:"informix".si_coddevcam WHERE codigo = cMotivoDevol;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cMotivoDevolucion = cMotivoDevol;
			END IF;
			
			RETURN cCodRet, cCuenta, iCheque, dImporte, cRevisadoFirmas, TRIM(TRIM(cUsuarioValida)||' '||TRIM(cNombre)), cMotivoDevolucion WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN 
			LET cCodRet ='00017';
			RETURN cCodRet, cCuenta, iCheque, dImporte, cRevisadoFirmas, TRIM(cUsuarioValida)||' '||TRIM(cNombre), cMotivoDevolucion;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet ='1001';
			RETURN cCodRet, cCuenta, iCheque, dImporte, cRevisadoFirmas, TRIM(cUsuarioValida)||' '||TRIM(cNombre), cMotivoDevolucion;
		END IF;	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 01/06/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Asignaciï¿½n de Revisiï¿½n de Firmas Cheques',
'DESCRIPCION: sp que consulta el avance de los cheques',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cattotalchequesdetalle(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha CHAR(8))
		RETURNING CHAR(5) AS codret,
		INTEGER AS totalCheques,
		INTEGER AS totalChequesPorRevisar,
		INTEGER AS totalChequesRevisados;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iCodRetSp INTEGER;
	DEFINE iTotalCheques INTEGER;
	DEFINE iTotalChequesPorRevisar INTEGER;
	DEFINE iTotalChequesRevisados INTEGER;
	
	DEFINE cCuenta CHAR(20);
	DEFINE iCheque INTEGER;
	DEFINE dImporte DECIMAL(16,2);
	DEFINE cRevisadoFirmas CHAR(1);
	DEFINE cUsuarioValida CHAR(8);
	DEFINE cMotivoDevol CHAR(2);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iCodRetSp = 0;
	LET iTotalCheques  = 0;
	LET iTotalChequesPorRevisar = 0;
	LET iTotalChequesRevisados = 0;
	
	LET cCuenta = "";
	LET iCheque = 0;
	LET dImporte = 0;
	LET cRevisadoFirmas = "";
	LET cUsuarioValida = "";
	LET cMotivoDevol = "";

	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotalCheques, iTotalChequesPorRevisar, iTotalChequesRevisados;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cattotalchequesdetalle.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotalCheques, iTotalChequesPorRevisar, iTotalChequesRevisados;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotalCheques, iTotalChequesPorRevisar, iTotalChequesRevisados;
		END IF;
		
		FOREACH 
			SELECT c_cuenta, c_cheque, c_importe, revisado_firmas, usuario_valida, mot_devol
			INTO cCuenta, iCheque, dImporte, cRevisadoFirmas, cUsuarioValida, cMotivoDevol
			FROM bditef:"informix".cce_propios_det
			WHERE fecha_presini = pFecha
			AND cod_operacion='40'
			AND truncamiento='0'
			AND status='05'
			AND revisado_firmas in ('N','S')
			LET iTotalCheques = iTotalCheques + 1;
			
			IF TRIM(cRevisadoFirmas) = "S" THEN
				LET iTotalChequesRevisados = iTotalChequesRevisados + 1;
			ELSE
				LET iTotalChequesPorRevisar = iTotalChequesPorRevisar + 1;
			END IF;
		END FOREACH;
		
		IF iTotalCheques == 0 THEN 
			LET cCodRet = '00017';
		END IF;
				
		RETURN cCodRet, iTotalCheques, iTotalChequesPorRevisar, iTotalChequesRevisados;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 01/06/2016',
'DESCRIPCION: spl que consulta el total de chques revisados y por revisar',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultafirmascomb(pUsuario CHAR(8), pIdFuncion CHAR(10), pCliente CHAR(20), pCuenta CHAR(20), pCheque CHAR(7))
		RETURNING CHAR(5) AS codret,
			CHAR(2) AS numero_firmas,
			CHAR(120) AS combinacion,
			CHAR(20) AS tipo_firma,
			CHAR(20) AS cuenta,
			CHAR(7) AS cheque,
			CHAR(3) AS banco,
			DATE AS fecha_presenta,
			CHAR(20) AS cliente,
			CHAR(4) AS codigo_docto,
			SMALLINT AS secuencia_docto,
			CHAR(1) AS hay_imgfirmas;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDesCodRetSp CHAR(50);
	DEFINE cEmpresa CHAR(3);
	DEFINE cNumFirmas CHAR(2);
	DEFINE cCombFirmas CHAR(120);
	DEFINE cTipoFirma CHAR(20);
	DEFINE cCuenta CHAR(20);
	DEFINE iCheque CHAR(7);
	DEFINE cCveBanco CHAR(3);
	DEFINE dFechaPresenta DATE;
	DEFINE cCliente CHAR(20);
	DEFINE cCodDocumento CHAR(4);
	DEFINE iSecDocto SMALLINT;
	DEFINE cHayImgFirmas CHAR(1);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cDesCodRetSp = '';
	LET cEmpresa = '001';
	LET cNumFirmas = '';
	LET cCombFirmas = '';
	LET cTipoFirma = '';
	LET cCuenta = '';
	LET iCheque = '';
	LET cCveBanco = '';
	LET dFechaPresenta = '';
	LET cCliente = '';
	LET cCodDocumento = '';
	LET iSecDocto = 0;
	LET cHayImgFirmas = 'f';
	LET iRecuperacion = 0;
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, NVL(cNumFirmas,''),NVL(cCombFirmas,''),NVL(cTipoFirma,''),
			cCuenta,iCheque,cCveBanco,dFechaPresenta,cCliente,cCodDocumento,iSecDocto,cHayImgFirmas;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultafirmascomb.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCliente = '' OR pCuenta = '' OR pCheque = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, NVL(cNumFirmas,''),NVL(cCombFirmas,''),NVL(cTipoFirma,''),
			cCuenta,iCheque,cCveBanco,dFechaPresenta,cCliente,cCodDocumento,iSecDocto,cHayImgFirmas;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, NVL(cNumFirmas,''),NVL(cCombFirmas,''),NVL(cTipoFirma,''),
			cCuenta,iCheque,cCveBanco,dFechaPresenta,cCliente,cCodDocumento,iSecDocto,cHayImgFirmas;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdicntchq:"informix".sp_obtienefirmascomb(TRIM(pCuenta))
		INTO cCodRetSp, cNumFirmas, cCombFirmas, cTipoFirma;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIï¿½N DEL SP bdicntchq:sp_obtienefirmascomb';
		ELIF cCodRetSp::INTEGER = 1 THEN 
			LET cCodRet = '00009'; --EL NUMERO DE CUENTA NO EXISTE
			RETURN cCodRet, NVL(cNumFirmas,''),NVL(cCombFirmas,''),NVL(cTipoFirma,''),
			cCuenta,iCheque,cCveBanco,dFechaPresenta,cCliente,cCodDocumento,iSecDocto,cHayImgFirmas;
		ELIF cCodRetSp::INTEGER = 2 THEN 
			LET cCodRet = '00003';
			RETURN cCodRet, NVL(cNumFirmas,''),NVL(cCombFirmas,''),NVL(cTipoFirma,''),
			cCuenta,iCheque,cCveBanco,dFechaPresenta,cCliente,cCodDocumento,iSecDocto,cHayImgFirmas;
		END IF;
		
		SELECT UNIQUE ch.numcuenta, ch.numcheque, ch.cvebanco, ch.fechapresenta
		INTO cCuenta, iCheque, cCveBanco, dFechaPresenta
		FROM bditef:"informix".cce_cheques_img AS ch
		WHERE ch.numcuenta = TRIM(pCuenta) AND ch.numcheque = TRIM(pCheque);
		
		IF DBINFO('sqlca.sqlerrd2') <> 0 THEN
		
			SELECT FIRST 1 cod_docto INTO cCodDocumento
			FROM bdidigital@coppelimg_tcp:"informix".dg_tipodocumento 
			WHERE cod_grupo = '030' AND descripcion = 'Hoja de Firmas';
		
			SELECT MAX(ex.secuencia)
			INTO iSecDocto
			FROM bditef:"informix".cce_cheques_img AS ch, bdidigital@coppelimg_tcp:"informix".dg_expediente AS ex
			WHERE ch.numcuenta = TRIM(cCuenta) AND ch.numcheque = TRIM(iCheque)
			AND ex.cod_docto = cCodDocumento AND ex.cliente = TRIM(pCliente) AND ex.cuenta = ch.numcuenta;
			
			LET cCliente = TRIM(pCliente);
			IF NVL(iSecDocto,0) = 0 THEN
				LET cHayImgFirmas = 'f';
			ELSE
				LET cHayImgFirmas = 't';
			END IF;
			
		END IF;
		
		RETURN cCodRet, NVL(cNumFirmas,''),NVL(cCombFirmas,''),NVL(cTipoFirma,''),
		cCuenta,iCheque,cCveBanco,dFechaPresenta,cCliente,cCodDocumento,iSecDocto,cHayImgFirmas;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 03/08/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Consulta de cheques pagados por sucursal', 
'DESCRIPCION: SPL encargado de obtener el nï¿½mero de firmas y la combinaciï¿½n de firmas, de los cheques pagados por sucursal.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consdetallechequespagadossuc_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio CHAR(10), pFechaFin CHAR(10))
		RETURNING CHAR(5) AS codret,
			INTEGER AS num_registros;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDesCodRetSp CHAR(50);
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cDesCodRetSp = '';
	LET cEmpresa = '001';
	LET iNumRegistros = 0;
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consdetallechequespagadossuc_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio = '' OR pFechaFin = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		--SET LOCK MODE TO WAIT 3;		
		EXECUTE PROCEDURE bdicntchq:"informix".sp_obtienechqpag2_totales(pFechaInicio, pFechaFin)
		INTO cCodRetSp, iNumRegistros;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdicntchq:sp_obtienechqpag2_totales';
		ELIF cCodRetSp::INTEGER = 2 THEN 
			LET cCodRet = '00003';
			RETURN cCodRet, iNumRegistros;
		ELIF cCodRetSp::INTEGER = 3 THEN 
			LET cCodRet = '00017';
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iNumRegistros;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 03/08/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Consulta de cheques pagados por sucursal', 
'DESCRIPCION: SPL encargado de obtener el número total de cheques pagados por sucursal.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consdetallechequespagadossuc(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio CHAR(10), pFechaFin CHAR(10), 
pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			CHAR(4) AS sucursal,
			CHAR(40) AS nombre_suc,
			CHAR(20) AS cuenta,
			CHAR(5) AS cheque,
			MONEY(16,2) AS importe,
		    CHAR(20) AS fecha_hora,
			CHAR(16) AS folio_suc,
			CHAR(4) AS transacc,
			CHAR(20) AS cliente,
			SMALLINT AS secuencia,
			CHAR(1) AS bandera_visor;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDesCodRetSp CHAR(50);
	DEFINE cEmpresa CHAR(3);
	DEFINE cCveBanco CHAR(3);
	DEFINE cSucursal CHAR(4);
	DEFINE cNombreSuc CHAR(40);
	DEFINE cCuenta CHAR(20);
	DEFINE cNumCheque CHAR(5);
	DEFINE mMonto MONEY(16,2);
	DEFINE cFechaHora CHAR(60);
	DEFINE cFolioSuc CHAR(16);
	DEFINE cTransacc CHAR(4);
	DEFINE cCliente CHAR(20);
	DEFINE sSecuencia SMALLINT;
	DEFINE dFechaHora CHAR(20);
	DEFINE cFormatoImg CHAR(3);
	DEFINE cBanco CHAR(3);
	DEFINE cDescripcion CHAR(40);
	DEFINE cNumcta CHAR(20);
	DEFINE cNumchq CHAR(7);
	DEFINE cLado CHAR(1);
	DEFINE dFechaAlta DATE;
	DEFINE dFechaPresenta DATE;
	DEFINE cUsuarioAlta CHAR(8);
	DEFINE cHayImg CHAR(1);
	DEFINE iContRegs INTEGER;
	DEFINE cHayFecha CHAR(1);
	DEFINE cBanderaVisor CHAR(1);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cDesCodRetSp = '';
	LET cEmpresa = '001';
	LET cCveBanco = '';
	LET cSucursal = '';
	LET cNombreSuc = '';
	LET cCuenta = '';
	LET cNumCheque = '';
	LET mMonto = 0.00;
	LET cFechaHora = '';
	LET cFolioSuc = '';
	LET cTransacc = '';
	LET cCliente = '';
	LET sSecuencia = 0;
	LET dFechaHora = '';
	LET cFormatoImg = '';
	LET cBanco = '';
	LET cDescripcion = '';
	LET cNumcta = '';
	LET cNumchq = '';
	LET cLado = '';
	LET dFechaAlta = '';
	LET dFechaPresenta = '';
	LET cUsuarioAlta = '';
	LET cHayImg = 'f';
	LET iContRegs = 0;
	LET cHayFecha = 'f';
	LET cBanderaVisor = 'f';
	LET iRecuperacion = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cSucursal, cNombreSuc, cCuenta, cNumCheque, mMonto, dFechaHora, cFolioSuc, cTransacc, cCliente, sSecuencia, cBanderaVisor;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consdetallechequespagadossuc.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio = '' OR pFechaFin = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cSucursal, cNombreSuc, cCuenta, cNumCheque, mMonto, dFechaHora, cFolioSuc, cTransacc, cCliente, sSecuencia, cBanderaVisor;
		END IF;
		
		-- VALIDACIï¿½N DE LOS DATOS DE PAGINACIï¿½N
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cSucursal, cNombreSuc, cCuenta, cNumCheque, mMonto, dFechaHora, cFolioSuc, cTransacc, cCliente, sSecuencia, cBanderaVisor;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cSucursal, cNombreSuc, cCuenta, cNumCheque, mMonto, dFechaHora, cFolioSuc, cTransacc, cCliente, sSecuencia, cBanderaVisor;
		END IF;
		
		SELECT valor INTO cCveBanco FROM bdinteg:"informix".si_param WHERE empresa = '001' AND cod_param = '5';
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		

		FOREACH
			EXECUTE PROCEDURE bdicntchq:"informix".sp_obtienechqpag2(pFechaInicio, pFechaFin, pRegistros, pRecuperacion)
			INTO cCodRetSp, cSucursal, cNombreSuc, cCuenta, cNumCheque, mMonto, cFechaHora, cFolioSuc, cTransacc, cCliente, sSecuencia
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIï¿½N DEL SP bdicntchq:sp_obtienechqpag2';
			ELIF cCodRetSp::INTEGER = 2 THEN 
				LET cCodRet = '00003';
				RETURN cCodRet, cSucursal, cNombreSuc, cCuenta, cNumCheque, mMonto, cFechaHora, cFolioSuc, cTransacc, cCliente, sSecuencia, cBanderaVisor;
			ELIF cCodRetSp::INTEGER = 3 THEN 
				LET cCodRet = '00017';
				RETURN cCodRet, cSucursal, cNombreSuc, cCuenta, cNumCheque, mMonto, cFechaHora, cFolioSuc, cTransacc, cCliente, sSecuencia, cBanderaVisor;
			END IF;
		
			LET dFechaHora = SUBSTR(cFechaHora,4,2)||'/'||SUBSTR(cFechaHora,1,2)||'/'||SUBSTR(cFechaHora,7,4)||SUBSTR(cFechaHora,11,10);
			
			-- VERIFICA SI EXISTE LA IMAGEN DEL CHEQUE
			EXECUTE PROCEDURE bditef:"informix".sp_validaimagencheque(cCveBanco,cCuenta,cNumCheque)
			INTO cCodRetSp, cDesCodRetSp, cFormatoImg;
			
			IF cCodRetSp::INTEGER = 0 THEN
				LET cHayImg = 't';
			ELSE 
				LET cHayImg = 'f';
			END IF;
			
			-- VERIFICA SI TRAE LA FECHA PRESENTACIï¿½N			
			SELECT COUNT(a.fechapresenta) INTO iContRegs
			FROM bditef:"informix".cce_cheques_img AS a, bdinteg:"informix".si_bancos AS b 
			WHERE a.empresa = '001' AND a.cvebanco = b.banco
			AND a.cvebanco = NVL(cCveBanco,'') AND a.numcuenta = NVL(cCuenta,'') AND a.numcheque = NVL(cNumCheque,'');
			
			IF NVL(iContRegs,0) = 2 THEN
				LET cHayFecha = 't';
			END IF;
			
			IF cHayImg = 'f' OR cHayFecha = 'f' THEN
				LET cBanderaVisor = 'f';
			ELSE 
				LET cBanderaVisor = 't';
			END IF;
				
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cSucursal, UPPER(cNombreSuc), cCuenta, cNumCheque, NVL(mMonto,0), dFechaHora, cFolioSuc, cTransacc, cCliente, sSecuencia, cBanderaVisor WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, cSucursal, cNombreSuc, cCuenta, cNumCheque, mMonto, dFechaHora, cFolioSuc, cTransacc, cCliente, sSecuencia, cBanderaVisor;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cSucursal, cNombreSuc, cCuenta, cNumCheque, mMonto, dFechaHora, cFolioSuc, cTransacc, cCliente, sSecuencia, cBanderaVisor;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 02/08/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Consulta de cheques pagados por sucursal', 
'DESCRIPCION: SPL encargado de obtener la informacion de los cheques pagados por sucursal.',
'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 08/03/2017',
'DESCRIPCION: Se homologa el declaracion de la variable cNumCheque.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_validaimagencheque(pUsuario CHAR(8), pIdFuncion CHAR(10), pClaveBanco CHAR(3), pCuenta CHAR(20), pNumCheque CHAR(7))
		RETURNING CHAR(5) AS codret,
				  CHAR(3) AS imgFormato;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cMensaje CHAR(50);
	DEFINE cImgFormato CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cMensaje = '';
    LET cImgFormato = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cImgFormato;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_validaimagencheque.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pClaveBanco = '' OR pCuenta = '' OR pNumCheque = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cImgFormato;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cImgFormato;
		END IF;
		
		EXECUTE PROCEDURE bditef:"informix".sp_validaimagenescheques(pClaveBanco, pCuenta, pNumCheque)
		INTO cCodRetSp, cMensaje, cImgFormato;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_validaimagenescheques';
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '00754';
			RETURN cCodRet, cImgFormato;
		END IF;
		
		RETURN cCodRet, cImgFormato;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 18/02/2016',
'DESCRIPCION: sp que valida si la imagen del cheque existe o no',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validaimagenchequesfirmas(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha CHAR(8), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			CHAR(20) AS cuenta,
			INTEGER AS cheque,
			CHAR(20) AS num_cliente,
			CHAR(125) AS cliente,
			CHAR(45) AS sucursal,
			MONEY(16,2) AS importe,
			CHAR(1) AS reg_firmas,
			CHAR(120) AS comb_firmantes,
			CHAR(3) AS cve_banco,
			DATE AS fechapresenta,
			CHAR(4) AS cod_documento,
			SMALLINT AS secuencia,
			INTEGER AS consecutivo_cheque,
			INTEGER AS id_registro;			
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iIdConsCheque INTEGER;
	DEFINE cCuenta CHAR(20);
	DEFINE iCheque INTEGER;
	DEFINE mImporte MONEY(16,2);
	DEFINE cCveSucursal CHAR(4);
	DEFINE cDescSucursal CHAR(40);
	DEFINE cNumCliente CHAR(20);
	DEFINE cNombreCliente CHAR(107);
	DEFINE cRfc CHAR(13);
	DEFINE cCombFirmantes CHAR(120);
	DEFINE cRegFirmas CHAR(1);
	DEFINE cCveBanco CHAR(3);
	DEFINE dFechaPresenta DATE;
	DEFINE cCodDocumento CHAR(4);
	DEFINE cSecuencia SMALLINT;
	DEFINE cSucursal CHAR(45);
	DEFINE cCliente CHAR(125);	
	DEFINE iRecuperacion INTEGER;
	DEFINE dFechaPres CHAR(10);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET iIdConsCheque = 0;
	LET cCuenta = '';
	LET iCheque = 0;
	LET mImporte = 0.00;
	LET cCveSucursal = '';
	LET cDescSucursal = '';
	LET cNumCliente = '';
	LET cNombreCliente = '';
	LET cRfc = '';
	LET cCombFirmantes = '';
	LET cRegFirmas = '';
	LET cCveBanco = '';
	LET dFechaPresenta = '';
	LET cCodDocumento = '';
	LET cSecuencia = '';
	LET cSucursal = '';
	LET cCliente = '';
	LET iRecuperacion = 0;
	LET dFechaPres = '';
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cCuenta,iCheque,cNumCliente,cCliente,cSucursal,mImporte,cRegFirmas,cCombFirmantes,
			cCveBanco,dFechaPresenta,cCodDocumento,cSecuencia,iIdConsCheque,iRecuperacion;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_validaimagenchequesfirmas.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cCuenta,iCheque,cNumCliente,cCliente,cSucursal,mImporte,cRegFirmas,cCombFirmantes,
			cCveBanco,dFechaPresenta,cCodDocumento,cSecuencia,iIdConsCheque,iRecuperacion;
		END IF;
			
		-- VALIDACIÃN DE LOS DATOS DE PAGINACIÃN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cCuenta,iCheque,cNumCliente,cCliente,cSucursal,mImporte,cRegFirmas,cCombFirmantes,
			cCveBanco,dFechaPresenta,cCodDocumento,cSecuencia,iIdConsCheque,iRecuperacion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cCuenta,iCheque,cNumCliente,cCliente,cSucursal,mImporte,cRegFirmas,cCombFirmantes,
			cCveBanco,dFechaPresenta,cCodDocumento,cSecuencia,iIdConsCheque,iRecuperacion;
		END IF;
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;	
		
		LET dFechaPres =  SUBSTRING(pFecha from  5 for 2) || '/' ||  SUBSTRING(pFecha from 7 for 2) || '/' ||  SUBSTRING(pFecha from 1 for 4);
	
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion 
			id_consecutivo,num_cuenta,num_cheque,importe,cve_sucursal,desc_sucursal,num_cliente,nombre_cliente,rfc,
			combinacion_firmantes,reg_firmas,cvebanco,fechapresenta,cod_docto,max_secuencia
			INTO iIdConsCheque,cCuenta,iCheque,mImporte,cCveSucursal,cDescSucursal,cNumCliente,cNombreCliente,cRfc,
			cCombFirmantes,cRegFirmas,cCveBanco,dFechaPresenta,cCodDocumento,cSecuencia
			FROM 
				(SELECT DISTINCT va.id_consecutivo,va.num_cuenta,va.num_cheque,va.importe,va.cve_sucursal,va.desc_sucursal,
					va.num_cliente,va.nombre_cliente,va.rfc,va.combinacion_firmantes,
					(SELECT reg_firma FROM bdicheq:"informix".sc_firmantes WHERE cuenta = va.num_cuenta AND numcte = va.num_cliente) AS reg_firmas,
					ch.cvebanco,ch.fechapresenta,ex.cod_docto,va.max_secuencia
				FROM bdicnweb:"informix".sw_ccer_validadetallecheques AS va, 
				bditef:"informix".cce_cheques_img AS ch, bdidigital@coppelimg_tcp:"informix".dg_expediente AS ex
				WHERE va.usuario = pUsuario AND va.fecha = pFecha AND va.descarga = 'N'
				AND TRIM(va.motivo_dev) = '00' AND TRIM(va.firmas) = 'SI' AND NVL(va.revisado,'') = ''
				AND ch.numcuenta = va.num_cuenta AND ch.numcheque = va.num_cheque
				AND ex.cliente = va.num_cliente	AND ex.cuenta = ch.numcuenta AND ch.imagen IS NOT NULL
				AND DATE(ch.fechapresenta) = dFechaPres
				)
		
			LET cCliente = TRIM(cNombreCliente)||' RFC '||cRfc;
			LET cSucursal = TRIM(cCveSucursal)||' '||TRIM(cDescSucursal);
			LET iRecuperacion = iRecuperacion + 1;		
			
			RETURN cCodRet,TRIM(cCuenta),NVL(iCheque,0),TRIM(cNumCliente),TRIM(UPPER(cCliente)),TRIM(cSucursal),NVL(mImporte,0),
			NVL(cRegFirmas,'0'),cCombFirmantes,TRIM(cCveBanco),dFechaPresenta,cCodDocumento,cSecuencia,iIdConsCheque,iRecuperacion WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00832'; --NO SE ENCONTRARON ELEMENTOS PARA LA VALIDACIÃN DE FIRMAS
			RETURN cCodRet,cCuenta,iCheque,cNumCliente,cCliente,cSucursal,mImporte,cRegFirmas,cCombFirmantes,
			cCveBanco,dFechaPresenta,cCodDocumento,cSecuencia,iIdConsCheque,iRecuperacion;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cCuenta,iCheque,cNumCliente,cCliente,cSucursal,mImporte,cRegFirmas,cCombFirmantes,
			cCveBanco,dFechaPresenta,cCodDocumento,cSecuencia,iIdConsCheque,iRecuperacion;
		END IF;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 15/06/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: ValidaciÃ³n visual de cheques', 
'DESCRIPCION: SPL encargado de hacer las validaciones de imagen de cheques y firmas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validadetallerevcheques_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha CHAR(8))
		RETURNING CHAR(5) AS codret,
			INTEGER AS num_registros,
			INTEGER AS contador_imagenes;
			
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cInstImagenes CHAR(25);
	DEFINE cTabla CHAR(38);
	DEFINE cCodDocumento CHAR(4);
	DEFINE cCuenta CHAR(20);
	DEFINE iCheque INTEGER;
	DEFINE mImporte MONEY(16,2);
	DEFINE cMotivoDevol CHAR(38);
	DEFINE cBancoReceptor CHAR(3);
	DEFINE cNombreArchivo CHAR(22);
	DEFINE iSecuencia INTEGER;
	DEFINE cNumCliente CHAR(20);
	DEFINE cNombreCliente CHAR(107);
	DEFINE cRfc CHAR(13);
	DEFINE cCveSucursal CHAR(4);
	DEFINE cDescSucursal CHAR(40);
	DEFINE cNumCte CHAR(20);
	DEFINE cCliente CHAR(125);
	DEFINE cSucursal CHAR(45);
	DEFINE cCombFirmantes CHAR(120);
	DEFINE iImgF SMALLINT;
	DEFINE iImgT SMALLINT;
	DEFINE iSecExpediente SMALLINT;
	DEFINE iTieneImgsFT SMALLINT;
	DEFINE cFirmas CHAR(32);
	DEFINE cHayFirmas CHAR(1);
	DEFINE iContFirmas INTEGER;
	DEFINE cRevisado CHAR(1);
	DEFINE cAbonoAplicado CHAR(1);
	DEFINE iIdConsCheque INTEGER;
	DEFINE cCmd1 CHAR(500);
	DEFINE iContImagenes INTEGER;
	DEFINE iNumRegistros INTEGER;
	--NUEVO
	DEFINE iExiste INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cInstImagenes = '';
	LET cTabla = '';
	LET cCodDocumento = '';
	LET cCuenta = '';
	LET iCheque = 0;
	LET mImporte = 0.00;
	LET cMotivoDevol = '';
	LET cBancoReceptor = '';
	LET cNombreArchivo = '';
	LET iSecuencia = 0;
	LET cNumCliente = '';
	LET cNombreCliente = '';
	LET cRfc = '';
	LET cCveSucursal = '';
	LET cDescSucursal = '';
	LET cNumCte = '';
	LET cCliente = '';
	LET cSucursal = '';
	LET cCombFirmantes = '';
	LET iImgF = 0;
	LET iImgT = 0;
	LET iSecExpediente = 0;
	LET iTieneImgsFT = 0;
	LET cFirmas = '';
	LET cHayFirmas = '';
	LET iContFirmas = 0;
	LET cRevisado = '';
	LET cAbonoAplicado = '';
	LET iIdConsCheque = 0;
	LET cCmd1 = '';
	LET iContImagenes = 0;
	LET iNumRegistros = 0;
	LET iExiste = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNumRegistros,iContImagenes;
		END EXCEPTION;
	
		SET DEBUG FILE TO '/tmp/mfinis/sp_validadetallerevcheques_totales.out';
		TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNumRegistros,iContImagenes;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNumRegistros,iContImagenes;
		END IF;
	
		-- INSTANCIA DE IMÃGENES
		SELECT valor INTO cInstImagenes 
		FROM bditef:"informix".cce_param WHERE empresa = cEmpresa AND cod_param = '14';
		IF NVL(cInstImagenes,'') = '' THEN 
			LET cCodRet = '00828'; --NO SE ENCUENTRAN LOS PARÃMETROS DE LA INSTANCIA DE IMAGENES
			RETURN cCodRet,iNumRegistros,iContImagenes;
		END IF;
		LET cTabla = cInstImagenes||'dg_expediente';
		
		-- DOCUMENTO DE FIRMAS
		SELECT valor INTO cCodDocumento
		FROM bditef:"informix".cce_param WHERE empresa = cEmpresa AND cod_param = '5';
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;	
		
		DELETE FROM bdicnweb:"informix".tmp_img_cheques where usuario = pUsuario;
		DELETE FROM bdicnweb:"informix".sw_ccer_validadetallecheques WHERE usuario = pUsuario;

		-- Insertar datos con conteo de imÃ¡genes
		INSERT INTO bdicnweb:"informix".tmp_img_cheques
		SELECT 	TO_CHAR(fechapresenta,'%Y%m%d'),	cvebanco, numcheque,
			SUM(CASE WHEN UPPER(lado_ft) = 'F' THEN 1 ELSE 0 END),
			SUM(CASE WHEN UPPER(lado_ft) = 'T' THEN 1 ELSE 0 END), pUsuario
		FROM bditef:"informix".cce_cheques_img
		WHERE empresa = cEmpresa
		GROUP BY fechapresenta, cvebanco, numcheque;
		
		LET cCmd1 = "SELECT MAX(secuencia)";
		LET cCmd1 = ""||TRIM(cCmd1)||" FROM "||TRIM(cTabla);
		LET cCmd1 = ""||TRIM(cCmd1)||" WHERE empresa = "||TRIM(cEmpresa)||" AND cliente = ? AND cuenta = ? AND cod_docto = '"||cCodDocumento||"' ORDER BY 1";
		
		PREPARE reporteQry FROM TRIM(cCmd1);
		DECLARE selectCur CURSOR FOR reporteQry;
	
		FOREACH
			SELECT cdet.c_cuenta, cdet.c_cheque, cdet.c_importe, cdet.mot_devol, cdet.bco_receptor, cdet.nombrearchivo, cdet.secuencia,
				c.numcte, (TRIM(c.nombre1)|| ' ' ||TRIM(c.nombre2)|| ' ' ||TRIM(c.apell_paterno)|| ' ' ||TRIM(c.apell_materno)) AS nomcliente,
				c.rfc, su.sucursal, su.nombre, fi.combinacion,
				NVL(imgs.imgF, 0), NVL(imgs.imgT, 0)
			INTO cCuenta, iCheque, mImporte, cMotivoDevol, cBancoReceptor, cNombreArchivo, iSecuencia,
				cNumCliente, cNombreCliente, cRfc, cCveSucursal, cDescSucursal, cCombFirmantes,
				iImgF, iImgT
			FROM bditef:"informix".cce_propios_det cdet
			INNER JOIN bdicheq:"informix".sc_maechq ma ON ma.cuenta = cdet.c_cuenta
			INNER JOIN bdinteg:"informix".si_cliente c ON c.numcte = ma.num_cte
			INNER JOIN bdinteg:"informix".si_sucursales su ON su.sucursal = ma.sucursal
			INNER JOIN bdicheq:"informix".sc_firmantes fi ON fi.cuenta = cdet.c_cuenta AND fi.secuencia = '1'
			INNER JOIN bdicnweb:"informix".tmp_img_cheques imgs
			ON imgs.fechapresenta = cdet.fecha_presini AND imgs.numcheque = cdet.c_cheque AND imgs.usuario = pUsuario
			WHERE cdet.fecha_presini = pFecha
				AND cdet.cod_operacion = '40'
				AND cdet.truncamiento = '0'
				AND cdet.status = '05'
				AND cdet.mot_devol = '00'
				AND cdet.revisado_firmas = 'N'
				AND cdet.usuario_valida = pUsuario
			ORDER BY cdet.c_cuenta, cdet.secuencia
			
			OPEN selectCur USING cNumCliente, cCuenta;
			FETCH selectCur INTO iSecExpediente;
			CLOSE selectCur;
			
			IF NVL(iSecExpediente,0) = 0 THEN
				LET cFirmas = 'NO EXISTEN FIRMAS PARA LA CUENTA';
				LET cHayFirmas = 'N';
			ELSE
				IF NVL(iImgF,0) <> 0 THEN
					IF NVL(iImgT,0) <> 0 THEN
						LET cFirmas = 'SI';
						LET cHayFirmas = 'S';
						LET cRevisado = '';
						LET iContImagenes = iContImagenes + 1;
					ELSE
						LET cFirmas = 'NO EXISTE LA IMAGEN DEL CHEQUE';
						LET cHayFirmas = 'N';
					END IF;
				ELSE
					LET cFirmas = 'NO EXISTE LA IMAGEN DEL CHEQUE';
					LET cHayFirmas = 'N';
				END IF;
			END IF;
			
			LET iIdConsCheque = iIdConsCheque + 1;
			
			INSERT INTO bdicnweb:"informix".sw_ccer_validadetallecheques(id_consecutivo,usuario,fecha,num_cuenta,num_cheque,importe,motivo_dev,firmas,banco_receptor,
			nombre_archivo,secuencia,num_cliente,nombre_cliente,rfc,cve_sucursal,desc_sucursal,revisado,combinacion_firmantes,max_secuencia,hay_firmas,fecha_insert) 
			VALUES (iIdConsCheque,pUsuario,pFecha,cCuenta,NVL(iCheque,0),NVL(mImporte,0),cMotivoDevol,cFirmas,cBancoReceptor,cNombreArchivo,
			NVL(iSecuencia,0),cNumCliente,cNombreCliente,cRfc,cCveSucursal,cDescSucursal,cRevisado,cCombFirmantes,iSecExpediente,cHayFirmas,CURRENT);
		
			UPDATE bdicnweb:"informix".sw_ccer_validadetallecheques 
			SET descarga = 'N' WHERE usuario = pUsuario AND fecha = pFecha AND hay_firmas = 'S' AND id_consecutivo = iIdConsCheque;	
		END FOREACH;
		
		FREE selectCur;
		FREE reporteQry;
		
		LET iNumRegistros = iIdConsCheque;
		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '00829'; --NO HAY FIRMAS PENDIENTES POR REVISAR PARA ESTE USUARIO
		END IF;
		
		RETURN cCodRet,iNumRegistros,iContImagenes;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 09/06/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: ValidaciÃ³n visual de cheques', 
'DESCRIPCION: SPL encargado de consultar el nÃºmero total de los cheques a revisar.',
'AUTOR: Veronica Sanchez',
'FECHA: 12/08/2025',
'DESCRIPCION: Se ajusta procedimiento almacenado para eliminar sentencia create de la tabla tmp_img_cheques',
'AUTOR: Veronica Sanchez',
'FECHA: 28/08/2025',
'DESCRIPCION: Se ajusta procedimiento almacenado para mapear el valor fechapresenta de tabla tmp_img_cheques',
'AUTOR: Veronica Sanchez',
'FECHA: 05/09/2025',
'DESCRIPCION: Se ajusta procedimiento almacenado para eliminar condiciÃ³n de cvebanco de la consulta principal',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validadetallerevcheques(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha CHAR(8), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			CHAR(20) AS cuenta,
			INTEGER AS cheque,
			MONEY(16,2) AS importe,
			CHAR(45) AS sucursal,
			CHAR(20) AS num_cliente,
			CHAR(125) AS cliente,
			CHAR(38) AS motivo_devol,
			CHAR(32) AS firmas,
			CHAR(1) AS hay_firmas,
			INTEGER AS id_consecutivo;
			
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cCuenta CHAR(20);
	DEFINE iCheque INTEGER;
	DEFINE mImporte MONEY(16,2);
	DEFINE cMotivoDevol CHAR(38);
	DEFINE cNumCte CHAR(20);
	DEFINE cCliente CHAR(125);
	DEFINE cSucursal CHAR(45);
	DEFINE cFirmas CHAR(32);
	DEFINE cHayFirmas CHAR(1);
	DEFINE iIdConsCheque INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cCuenta = '';
	LET iCheque = 0;
	LET mImporte = 0.00;
	LET cMotivoDevol = '';
	LET cNumCte = '';
	LET cCliente = '';
	LET cSucursal = '';
	LET cFirmas = '';
	LET cHayFirmas = '';
	LET iIdConsCheque = 0;
	LET iRecuperacion = 0;
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cCuenta,iCheque,mImporte,cSucursal,cNumCte,cCliente,cMotivoDevol,cFirmas,cHayFirmas,iIdConsCheque;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_validadetallerevcheques.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cCuenta,iCheque,mImporte,cSucursal,cNumCte,cCliente,cMotivoDevol,cFirmas,cHayFirmas,iIdConsCheque;
		END IF;
		
		-- VALIDACIÃN DE LOS DATOS DE PAGINACIÃN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cCuenta,iCheque,mImporte,cSucursal,cNumCte,cCliente,cMotivoDevol,cFirmas,cHayFirmas,iIdConsCheque;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cCuenta,iCheque,mImporte,cSucursal,cNumCte,cCliente,cMotivoDevol,cFirmas,cHayFirmas,iIdConsCheque;
		END IF;
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;	
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion id_consecutivo, num_cuenta,num_cheque,importe,TRIM(cve_sucursal)||' '||TRIM(desc_sucursal),
			TRIM(num_cliente),TRIM(nombre_cliente)||' RFC '||rfc,motivo_dev,firmas,hay_firmas
			INTO iIdConsCheque,cCuenta,iCheque,mImporte,cSucursal,cNumCte,cCliente,cMotivoDevol,cFirmas,cHayFirmas
			FROM bdicnweb:"informix".sw_ccer_validadetallecheques WHERE usuario = pUsuario AND fecha = pFecha ORDER BY id_consecutivo ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,TRIM(cCuenta),iCheque,mImporte,TRIM(cSucursal),TRIM(cNumCte),TRIM(UPPER(cCliente)),TRIM(cMotivoDevol),UPPER(cFirmas),cHayFirmas,iIdConsCheque WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00829'; --NO HAY FIRMAS PENDIENTES POR REVISAR PARA ESTE USUARIO
			RETURN cCodRet,cCuenta,iCheque,mImporte,cSucursal,cNumCte,cCliente,cMotivoDevol,cFirmas,cHayFirmas,iIdConsCheque;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cCuenta,iCheque,mImporte,cSucursal,cNumCte,cCliente,cMotivoDevol,cFirmas,cHayFirmas,iIdConsCheque;
		END IF;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 09/06/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: ValidaciÃ³n visual de cheques', 
'DESCRIPCION: SPL encargado de consultar el detalle de los cheques a revisar.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_statusdescarga(pUsuario CHAR(8), pIdFuncion CHAR(10), pTramaConsecutivo CHAR(250))
		RETURNING CHAR(5) AS codret;


	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iCodRetSp INTEGER;
	DEFINE iConsecutivo INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iCodRetSp = 0;
	LET iConsecutivo = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_statusdescarga.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pTramaConsecutivo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;

		FOREACH EXECUTE PROCEDURE bdicnweb:sp_split_cadena(pTramaConsecutivo, '|')
			INTO iConsecutivo
			UPDATE bdicnweb:"informix".sw_ccer_validadetallecheques
			SET descarga = 'S',
			hay_firmas = 'D'
			WHERE descarga = 'N'
			AND id_consecutivo = iConsecutivo
			AND usuario = pUsuario;
		END FOREACH;
		RETURN cCodRet;
	END;

END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 02/06/2016',
'DESCRIPCION: spl que actualiza el status de descarga',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_aplicabonocuenta(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha CHAR(8), pTramaConsecutivo CHAR(250))
		RETURNING CHAR(5) AS codret;			
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(35);
	DEFINE cEmpresa CHAR(3);
	DEFINE iIdConsCheque INTEGER;
	DEFINE cFechaHoy CHAR(10);
	DEFINE cFormatFechaHoy CHAR(10);
	DEFINE cCuenta CHAR(20);
	DEFINE iCheque INTEGER;
	DEFINE mImporte MONEY(16,2);
	DEFINE cMotivoDevolucion CHAR(38);
	DEFINE cRevisado CHAR(1);
	DEFINE cAbonoAplicado CHAR(1);
	DEFINE cNombreArchivo CHAR(22);
	DEFINE iSecuencia INTEGER;
	DEFINE cCodMotivo CHAR(2);
	DEFINE cDescMotivo CHAR(35);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '000';
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET iIdConsCheque = 0;
	LET cFechaHoy ='';
	LET cFormatFechaHoy = '';
	LET cCuenta = '';
	LET iCheque = 0;
	LET mImporte = 0.00;
	LET cMotivoDevolucion = '';
	LET cRevisado = '';
	LET cAbonoAplicado = ''; 
	LET cNombreArchivo = '';
	LET iSecuencia = '';
	LET cCodMotivo = '';
	LET cDescMotivo = '';
	LET iRecuperacion = 0;
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_aplicabonocuenta.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha = '' OR pTramaConsecutivo = '' THEN
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
		
		FOREACH 
			EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena(pTramaConsecutivo, '|')
			INTO iIdConsCheque
			
			SELECT num_cuenta,num_cheque,importe,motivo_dev,revisado,abono_aplicado,nombre_archivo,secuencia 
			INTO cCuenta,iCheque,mImporte,cMotivoDevolucion,cRevisado,cAbonoAplicado,cNombreArchivo,iSecuencia
			FROM bdicnweb:"informix".sw_ccer_validadetallecheques 
			WHERE usuario = pUsuario AND fecha = pFecha AND id_consecutivo = iIdConsCheque;
			IF SUBSTR(cMotivoDevolucion,1,2) <> '00' AND TRIM(cAbonoAplicado) = 'N' THEN
			
				EXECUTE PROCEDURE bditef:"informix".abono_cta(cEmpresa,cCuenta,iCheque,mImporte,'01',pUsuario)
				INTO cCodRetSp, cDescCodRetSp;
				
				UPDATE bditef:"informix".cce_propios_det SET cod_ret = TRIM(cCodRetSp)
				WHERE nombrearchivo = TRIM(cNombreArchivo) AND  secuencia = iSecuencia
				AND cod_operacion = '40' AND fecha_presini = pFecha;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '00283';
					RETURN cCodRet;
				END IF;
				
				IF SUBSTR(cCodRetSp,1,3) <> '000' THEN
					UPDATE bdicnweb:"informix".sw_ccer_validadetallecheques 
					SET cve_sucursal = '', desc_sucursal = 'ERR: ' ||TRIM(cCodRetSp)||' '||TRIM(cDescCodRetSp)
					WHERE usuario = pUsuario AND fecha = pFecha AND id_consecutivo = iIdConsCheque;
				END IF;
				
				UPDATE bdicnweb:"informix".sw_ccer_validadetallecheques SET abono_aplicado = 'S', hay_firmas = 'A'
				WHERE usuario = pUsuario AND fecha = pFecha AND id_consecutivo = iIdConsCheque;			
				
			END IF;
		END FOREACH;
		
		RETURN cCodRet;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 21/06/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: ValidaciÃ³n visual de cheques', 
'DESCRIPCION: SPL encargado de abonar al cliente el monto del cheque.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_actualizadatoscheque(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha CHAR(8), pMotivoDev CHAR(2), 
pIdConsCheque INTEGER, pIdEjecucion CHAR(1))
		RETURNING CHAR(5) AS codret;			
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cFechaHoy CHAR(10);
	DEFINE cFormatFechaHoy CHAR(10);
	DEFINE cCuenta CHAR(20);
	DEFINE iCheque INTEGER;
	DEFINE mImporte MONEY(16,2);
	DEFINE cNombreArchivo CHAR(22);
	DEFINE iSecuencia INTEGER;
	DEFINE cCodMotivo CHAR(2);
	DEFINE cDescMotivo CHAR(35);
	DEFINE cMotivoDevolucion CHAR(38);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cFechaHoy ='';
	LET cFormatFechaHoy = '';
	LET cCuenta = '';
	LET iCheque = 0;
	LET mImporte = 0.00;
	LET cNombreArchivo = '';
	LET iSecuencia = '';
	LET cCodMotivo = '';
	LET cDescMotivo = '';
	LET cMotivoDevolucion = '';
	LET iRecuperacion = 0;
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_actualizadatoscheque.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha = '' OR pIdConsCheque IS NULL OR pIdEjecucion = '' THEN
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
		
		SELECT num_cuenta,num_cheque,importe,nombre_archivo,secuencia INTO cCuenta,iCheque,mImporte,cNombreArchivo,iSecuencia
		FROM bdicnweb:"informix".sw_ccer_validadetallecheques WHERE usuario = pUsuario AND fecha = pFecha AND id_consecutivo = pIdConsCheque;
	
		--Acepta firma
		IF pIdEjecucion = '1' THEN
		
			UPDATE bdicnweb:"informix".sw_ccer_validadetallecheques 
			SET revisado = 'S', hay_firmas = 'R'
			WHERE usuario = pUsuario AND fecha = pFecha AND id_consecutivo = pIdConsCheque;
			
			UPDATE bditef:"informix".cce_propios_det SET revisado_firmas = 'S'
			WHERE nombrearchivo = TRIM(cNombreArchivo) AND secuencia = iSecuencia
			AND cod_operacion = '40' AND fecha_presini = pFecha;
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00283';
				RETURN cCodRet;
			END IF;
			
		--Rechaza firma
		ELIF pIdEjecucion = '2' THEN
		
			IF pMotivoDev = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
			END IF;
		
			SELECT TRIM(codigo)||' '||TRIM(descripcion) INTO cMotivoDevolucion FROM bdinteg:"informix".si_coddevcam
			WHERE codigo = pMotivoDev;
			
			UPDATE bdicnweb:"informix".sw_ccer_validadetallecheques 
			SET motivo_dev = TRIM(cMotivoDevolucion), revisado = 'S', abono_aplicado = 'N', hay_firmas = 'R'
			WHERE usuario = pUsuario AND fecha = pFecha AND id_consecutivo = pIdConsCheque;
			
			UPDATE bditef:"informix".cce_propios_det SET revisado_firmas = 'S',	mot_devol = pMotivoDev,	status = '11'
			WHERE nombrearchivo = TRIM(cNombreArchivo) AND  secuencia = iSecuencia
			AND cod_operacion = '40' AND fecha_presini = pFecha;
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00283';
				RETURN cCodRet;
			END IF;
				
			LET cFormatFechaHoy = SUBSTR(pFecha,5,2) ||'/'||SUBSTR(pFecha,7,2)||'/'||SUBSTR(pFecha,1,4);
			
			UPDATE bdicheq:"informix".sc_contch SET estado = 'N', fecha_alta = cFormatFechaHoy, importe = mImporte
            WHERE empresa = cEmpresa AND cuenta = cCuenta AND numero = iCheque;
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00283';
				RETURN cCodRet;
			END IF;
		
			UPDATE bdicheq:"informix".sc_maechq SET chq_dev = chq_dev + 1 WHERE empresa = cEmpresa AND cuenta = cCuenta;
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00283';
				RETURN cCodRet;
			END IF;
		
		END IF;
		
		RETURN cCodRet;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 15/06/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Validaciï¿½n visual de cheques', 
'DESCRIPCION: SPL encargado de hacer la actualizaciï¿½n a las tablas correspondientes, dependiendo de la aceptaciï¿½n o rechazo de la firma del cheque.',
'Donde con pIdEjecucion = 1 acepta el cheque y con pIdEjecucion = 2 se rechaza el cheque.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_catalogomotivos(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				  CHAR(2) AS codigo,
				  CHAR(35) AS descripcion;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cCodigo CHAR(2);
	DEFINE cDescripcion CHAR(35);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cCodigo = '';
	LET cDescripcion = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodigo, cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_catalogomotivos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodigo, cDescripcion;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCodigo, cDescripcion;
		END IF;
		
		FOREACH EXECUTE PROCEDURE bdinteg:"informix".sp_consultadevcam()
			INTO cCodRetSp, cCodigo, cDescripcion
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_consultadevcam';
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cCodigo, cDescripcion;
			ELSE
				RETURN cCodRet, cCodigo, cDescripcion WITH RESUME;
			END IF;
		END FOREACH;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 17/02/2016',
'DESCRIPCION: spl que consulta el catalogo motivos de devoluciÃ³n',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_aplicadevolucioncheque(pUsuario CHAR(8), pIdFuncion CHAR(10), pMotivoDev CHAR(2), pFecha CHAR(8), pIdConsCheque INTEGER)
		RETURNING CHAR(5) AS codret;			
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(35);
	DEFINE cEmpresa CHAR(3);
	DEFINE iIdConsCheque INTEGER;
	DEFINE cFechaHoy CHAR(10);
	DEFINE cFormatFechaHoy CHAR(10);
	DEFINE cCuenta CHAR(20);
	DEFINE iCheque INTEGER;
	DEFINE mImporte2 MONEY(16,2);
	DEFINE cMotivoDevolucion CHAR(38);
	DEFINE cRevisado CHAR(1);
	DEFINE cAbonoAplicado CHAR(1);
	DEFINE cNombreArchivo CHAR(22);
	DEFINE iSecuencia INTEGER;
	
	DEFINE cCodMotivo CHAR(2);
	DEFINE cDescMotivo CHAR(35);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '000';
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET iIdConsCheque = 0;
	LET cFechaHoy ='';
	LET cFormatFechaHoy = '';
	LET cCuenta = '';
	LET iCheque = 0;
	LET mImporte2 = 0.00;
	LET cMotivoDevolucion = '';
	LET cRevisado = '';
	LET cAbonoAplicado = ''; 
	LET cNombreArchivo = '';
	LET iSecuencia = '';
	
	LET cCodMotivo = '';
	LET cDescMotivo = '';
	LET iRecuperacion = 0;
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_aplicadevolucioncheque.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pMotivoDev = '' OR pFecha = '' OR pIdConsCheque = '' THEN
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
		
		--FOREACH 
		
			--EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena(pTramaConsecutivo, '|')
			--INTO iIdConsCheque
			
			SELECT num_cuenta,num_cheque,causa_dev,importe2,secuencia,nombre_archivo
			INTO cCuenta,iCheque,cMotivoDevolucion,mImporte2,iSecuencia,cNombreArchivo
			FROM bdicnweb:"informix".sw_ccer_aplicaabonocheques 
			WHERE usuario = pUsuario AND fecha = pFecha AND id_consecutivo = pIdConsCheque;
			
			IF NVL(cMotivoDevolucion,'') <> '' THEN
				LET cCodRet = '00834'; --ESTE CHEQUE YA FUE DEVUELTO, VERIFIQUE
				RETURN cCodRet;
			END IF;
			
			EXECUTE PROCEDURE bditef:"informix".abono_cta(cEmpresa,cCuenta,iCheque,mImporte2,'01',pUsuario)
			INTO cCodRetSp, cDescCodRetSp;
			
			IF SUBSTR(cCodRetSp,1,3) = '000' THEN
			
				UPDATE bditef:"informix".cce_propios_det SET mot_devol = pMotivoDev, status = '11'
				WHERE c_cuenta = TRIM(cCuenta) AND c_cheque = iCheque AND cod_operacion = '40' 
				AND secuencia = iSecuencia AND nombrearchivo = TRIM(cNombreArchivo);
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '00283';
					RETURN cCodRet;
				END IF;
					
				SELECT fecha_hoy INTO cFormatFechaHoy FROM bdinteg:"informix".si_fechas WHERE empresa = cEmpresa;
			
				UPDATE bdicheq:"informix".sc_contch SET estado = 'N', fecha_alta = cFormatFechaHoy, importe = mImporte2
				WHERE empresa = cEmpresa AND cuenta = cCuenta AND numero = iCheque;
			
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '00283';
					RETURN cCodRet;
				END IF;
				
				UPDATE bdicheq:"informix".sc_maechq SET chq_dev = chq_dev + 1 WHERE empresa = cEmpresa AND cuenta = cCuenta;
		
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '00283';
					RETURN cCodRet;
				END IF;
				
				SELECT TRIM(codigo)||' '||TRIM(descripcion) INTO cMotivoDevolucion 
				FROM bdinteg:"informix".si_coddevcam WHERE codigo = pMotivoDev;
			
				UPDATE bdicnweb:"informix".sw_ccer_aplicaabonocheques SET estatus = 'N Presentado no Pag', causa_dev = TRIM(cMotivoDevolucion)
				WHERE usuario = pUsuario AND fecha = pFecha AND id_consecutivo = pIdConsCheque;	
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '00283';
					RETURN cCodRet;
				END IF;
			
			ELSE
			
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIï¿½N DEL SP bditef:abono_cta';
				ELIF cCodRetSp::INTEGER = 100  OR cCodRetSp::INTEGER = 110 THEN 
					LET cCodRet = '00003';
					RETURN cCodRet;
				ELIF cCodRetSp::INTEGER = 101 THEN 
					LET cCodRet = '00009'; --EL NUMERO DE CUENTA NO EXISTE
					RETURN cCodRet;
				ELIF cCodRetSp::INTEGER = 102 THEN 
					LET cCodRet = '00619'; --CUENTA ABONO INVALIDA
					RETURN cCodRet;
				ELIF cCodRetSp::INTEGER = 301 THEN
					LET cCodRet = '00389'; --LA CUENTA ESTA BLOQUEADA NO PERMITE REALIZAR ABONOS. FAVOR DE VERIFICAR
					RETURN cCodRet;
				ELSE
					LET cCodRet = '00842'; --OCURRIO UN ERROR AL PROCESAR EL ABONO
					RETURN cCodRet;
				END IF;
				
			END IF;
			
		--END FOREACH;
		
		RETURN cCodRet;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 04/07/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Devoluciones Forzadas',  
'DESCRIPCION: SPL que se encarga de devolver el cheque y aplicar el abono.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consdetallechequespagados(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1), pNumero CHAR(20), pFecha CHAR(8), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			CHAR(20) AS no_cliente,
			CHAR(107) AS nombre_cliente,
			CHAR(13) AS rfc,
			DATE AS fecha_nac,
			CHAR(44) AS banco,
			CHAR(20) AS no_cuenta,
			INTEGER AS no_cheque,
			MONEY(16,2) AS importe,
			CHAR(2) AS truncado,
			CHAR(19) AS estatus,
			CHAR(38) AS causa_dev,
			CHAR(18) AS importe2,
			INTEGER AS secuencia, 
			CHAR(22) AS nombre_archivo, 
			INTEGER AS id_consecutivo;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNumCte CHAR(20);
	DEFINE cNombreCte CHAR(107);
	DEFINE cRfc CHAR(13);
	DEFINE dFechaNac DATE;
	DEFINE cBanco CHAR(44);
	DEFINE cNoCuenta CHAR(20);
	DEFINE iNoCheque INTEGER;
	DEFINE mImporte MONEY(16,2);
	DEFINE cTruncamiento CHAR(1);
    DEFINE iSecuencia INTEGER;
	DEFINE cNombreArchivo CHAR(22);
	DEFINE cTruncado CHAR(2);
	DEFINE cEstatus CHAR(19);
	DEFINE cCausaDev CHAR(38);
	DEFINE cImporte2 CHAR(18);
	DEFINE iIdConsCheque INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cNumCte = '';
	LET cNombreCte = '';
	LET cRfc = '';
	LET dFechaNac = '';
	LET cBanco = '';
	LET cNoCuenta = '';
	LET iNoCheque = 0;
	LET mImporte = 0.00;
	LET cTruncamiento = '';
    LET iSecuencia = 0;
	LET cNombreArchivo = '';
	LET cTruncado = '';
	LET cEstatus = '';
	LET cCausaDev = '';
	LET cImporte2 = '';
	LET iIdConsCheque = 0;
	LET iRecuperacion = 0;
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumCte, cNombreCte, cRfc, dFechaNac, cBanco, cNoCuenta, iNoCheque, mImporte, cTruncado, cEstatus, cCausaDev, cImporte2, iSecuencia, cNombreArchivo, iIdConsCheque;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consdetallechequespagados.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' OR pNumero = '' OR pFecha = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumCte, cNombreCte, cRfc, dFechaNac, cBanco, cNoCuenta, iNoCheque, mImporte, cTruncado, cEstatus, cCausaDev, cImporte2, iSecuencia, cNombreArchivo, iIdConsCheque;
		END IF;
		
		-- VALIDACIï¿½N DE LOS DATOS DE PAGINACIï¿½N
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNumCte, cNombreCte, cRfc, dFechaNac, cBanco, cNoCuenta, iNoCheque, mImporte, cTruncado, cEstatus, cCausaDev, cImporte2, iSecuencia, cNombreArchivo, iIdConsCheque;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumCte, cNombreCte, cRfc, dFechaNac, cBanco, cNoCuenta, iNoCheque, mImporte, cTruncado, cEstatus, cCausaDev, cImporte2, iSecuencia, cNombreArchivo, iIdConsCheque;
		END IF;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--No. Cuenta
		IF pIdConsulta = '1' THEN
		
			FOREACH
			
				SELECT SKIP pRegistros FIRST pRecuperacion id_consecutivo,num_cliente,nombre_cliente,rfc,fecha_nacimiento,
				TRIM(banco_presenta)||' '||TRIM(desc_banco),num_cuenta,num_cheque,importe,truncado,estatus,causa_dev,importe2,secuencia,nombre_archivo
				INTO iIdConsCheque,cNumCte,cNombreCte,cRfc,dFechaNac,cBanco,cNoCuenta,iNoCheque,mImporte,cTruncado,cEstatus,cCausaDev,cImporte2,iSecuencia,cNombreArchivo
				FROM bdicnweb:"informix".sw_ccer_aplicaabonocheques WHERE usuario = pUsuario AND fecha = pFecha AND num_cuenta = TRIM(pNumero) 
				ORDER BY id_consecutivo ASC
				
				-- Formateo importe2
				LET cImporte2 = SUBSTR(cImporte2, CHARINDEX('$', cImporte2) + 1);
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, cNumCte, UPPER(NVL(cNombreCte,'')), NVL(cRfc,''), NVL(dFechaNac,''),
				cBanco, cNoCuenta, iNoCheque, mImporte, cTruncado, cEstatus, cCausaDev, cImporte2, iSecuencia, cNombreArchivo, iIdConsCheque WITH RESUME;
			
			END FOREACH;
			
		--No. Cheque
		ELIF pIdConsulta = '2' THEN
		
			FOREACH
			
				SELECT SKIP pRegistros FIRST pRecuperacion id_consecutivo,num_cliente,nombre_cliente,rfc,fecha_nacimiento,
				TRIM(banco_presenta)||' '||TRIM(desc_banco),num_cuenta,num_cheque,importe,truncado,estatus,causa_dev,importe2,secuencia,nombre_archivo
				INTO iIdConsCheque,cNumCte,cNombreCte,cRfc,dFechaNac,cBanco,cNoCuenta,iNoCheque,mImporte,cTruncado,cEstatus,cCausaDev,cImporte2,iSecuencia,cNombreArchivo
				FROM bdicnweb:"informix".sw_ccer_aplicaabonocheques WHERE usuario = pUsuario AND fecha = pFecha AND num_cheque = TRIM(pNumero) 
				ORDER BY id_consecutivo ASC
				
				-- Formateo importe2
				LET cImporte2 = SUBSTR(cImporte2, CHARINDEX('$', cImporte2) + 1);
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, cNumCte, UPPER(NVL(cNombreCte,'')), NVL(cRfc,''), NVL(dFechaNac,''),
				cBanco, cNoCuenta, iNoCheque, mImporte, cTruncado, cEstatus, cCausaDev, cImporte2, iSecuencia, cNombreArchivo, iIdConsCheque WITH RESUME;
			
			END FOREACH;
			
		END IF;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00835'; --NO HAY CHEQUES PAGADOS POR Cï¿½MARA CON LOS CRITERIOS SELECCIONADOS, VERIFIQUE
			RETURN cCodRet, cNumCte, cNombreCte, cRfc, dFechaNac, cBanco, cNoCuenta, iNoCheque, mImporte, cTruncado, cEstatus, cCausaDev, cImporte2, iSecuencia, cNombreArchivo, iIdConsCheque;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNumCte, cNombreCte, cRfc, dFechaNac, cBanco, cNoCuenta, iNoCheque, mImporte, cTruncado, cEstatus, cCausaDev, cImporte2, iSecuencia, cNombreArchivo, iIdConsCheque;
		END IF;
	
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 01/07/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Devoluciones forzadas',  
'DESCRIPCION: SPL que se encarga de consultar el detalle de los cheques pagados.',
'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 10/05/2017',  
'DESCRIPCION: Se modifica SPL para retornar columnas faltantes (cImporte2,iSecuencia,cNombreArchivo).',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consdetallechequespagados_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1), pNumero CHAR(20), pFecha CHAR(8))
RETURNING CHAR(5) AS codret,
INTEGER AS num_registros;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNumCte CHAR(20);
	DEFINE cNombreCte CHAR(107);
	DEFINE cRfc CHAR(13);
	DEFINE dFechaNac DATE;
	DEFINE cBancoPresenta CHAR(3);
	DEFINE cDescBanco CHAR(40);
	DEFINE cNoCuenta CHAR(20);
	DEFINE iNoCheque INTEGER;
	DEFINE mImporte MONEY(16,2);
	DEFINE cTruncamiento CHAR(1);
    DEFINE iSecuencia INTEGER;
	DEFINE cNombreArchivo CHAR(22);
	DEFINE cTruncado CHAR(2);
	DEFINE cEstatus CHAR(19);
	DEFINE cCausaDev CHAR(38);
	DEFINE iIdConsCheque INTEGER;
	DEFINE iNumRegistros INTEGER;
	--NUEVO
	DEFINE cIdMotivoDev CHAR(2);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cNumCte = '';
	LET cNombreCte = '';
	LET cRfc = '';
	LET dFechaNac = '';
	LET cBancoPresenta = '';
	LET cDescBanco = '';
	LET cNoCuenta = '';
	LET iNoCheque = 0;
	LET mImporte = 0.00;
	LET cTruncamiento = '';
    LET iSecuencia = 0;
	LET cNombreArchivo = '';
	LET cTruncado = '';
	LET cEstatus = '';
	LET cCausaDev = '';	
	LET iIdConsCheque = 0;
	LET iNumRegistros = 0;
	--NUEVO
	LET cIdMotivoDev = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumRegistros;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consdetallechequespagados_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' OR pNumero = '' OR pFecha = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNumRegistros;
		END IF;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		DELETE {+AVOID_FULL(bdicnweb:"informix".sw_ccer_aplicaabonocheques)} bdicnweb:"informix".sw_ccer_aplicaabonocheques WHERE usuario = pUsuario;
		
		--No. Cuenta
		IF pIdConsulta = '1' THEN
		
			SELECT num_cte INTO cNumCte FROM bdicheq:"informix".sc_maechq WHERE cuenta = TRIM(pNumero);
			
			IF NVL(cNumCte,'') = '' THEN
				LET cCodRet = '00854'; --EL Nï¿½MERO DE CUENTA NO EXISTE
				RETURN cCodRet, iNumRegistros;
			END IF;
			
			SELECT TRIM(c.nombre1)||' '||TRIM(c.nombre2)||' '||TRIM(c.apell_paterno)||' '||TRIM(c.apell_materno), c.rfc, pf.fecha_nac 
			INTO cNombreCte, cRfc, dFechaNac
			FROM bdinteg:"informix".si_cliente AS c, bdinteg:"informix".si_ctepf AS pf 
			WHERE c.numcte = pf.numcte AND c.numcte = cNumCte;
			--IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			--	LET cCodRet = '00765'; --NO EXISTE EL CLIENTE
			--	RETURN cCodRet, iNumRegistros;
			--END IF;
			
			FOREACH
				SELECT mot_devol, bco_presenta, ba.descripcion, c_cuenta, c_cheque, c_importe, truncamiento, secuencia, nombrearchivo 
				INTO cIdMotivoDev, cBancoPresenta, cDescBanco, cNoCuenta, iNoCheque, mImporte, cTruncamiento, iSecuencia, cNombreArchivo
				FROM bditef:"informix".cce_propios_det, bdinteg:"informix".si_bancos AS ba 
				WHERE fecha_presini = pFecha AND c_cuenta = TRIM(pNumero) AND cod_operacion = '40' AND status = '05' AND ba.banco = bco_presenta
			
				IF NVL(cTruncamiento,'') = '1' THEN
					LET cTruncado = 'NO';
				ELSE
					LET cTruncado = 'SI';
				END IF;
				
				LET cEstatus = 'M Pagado por Camara';
				
				SELECT descripcion 
				INTO cCausaDev 
				FROM bdinteg:"informix".si_coddevcam 
				WHERE codigo = cIdMotivoDev;

				LET cCausaDev = NVL(cCausaDev,'');			
				
				LET iIdConsCheque = iIdConsCheque + 1;			
			
				--LLENADO DE LA TABLA
				INSERT INTO bdicnweb:"informix".sw_ccer_aplicaabonocheques(id_consecutivo,usuario,fecha,
				num_cliente,nombre_cliente,rfc,fecha_nacimiento,banco_presenta,desc_banco,num_cuenta,num_cheque,importe,
				truncado,estatus,causa_dev,importe2,secuencia,nombre_archivo,abono_aplicado,fecha_insert) 
				VALUES (iIdConsCheque,pUsuario,pFecha,cNumCte,cNombreCte,cRfc,dFechaNac,cBancoPresenta,cDescBanco,
				cNoCuenta,NVL(iNoCheque,0),NVL(mImporte,0),cTruncado,cEstatus,cCausaDev,NVL(mImporte,0),NVL(iSecuencia,0),cNombreArchivo,'',CURRENT);
			END FOREACH;
			
		--No. Cheque
		ELIF pIdConsulta = '2' THEN
		
			FOREACH
				SELECT mot_devol, bco_presenta, ba.descripcion, c_cuenta, c_cheque, c_importe, truncamiento, secuencia, nombrearchivo 
				INTO cIdMotivoDev, cBancoPresenta, cDescBanco, cNoCuenta, iNoCheque, mImporte, cTruncamiento, iSecuencia, cNombreArchivo
				FROM bditef:"informix".cce_propios_det, bdinteg:"informix".si_bancos AS ba 
				WHERE fecha_presini = pFecha AND c_cheque = TRIM(pNumero) AND cod_operacion = '40' AND status = '05' AND ba.banco = bco_presenta
	
				IF NVL(cTruncamiento,'') = '1' THEN
					LET cTruncado = 'NO';
				ELSE
					LET cTruncado = 'SI';
				END IF;
				
				LET cEstatus = 'M Pagado por Camara';
				
				SELECT descripcion 
				INTO cCausaDev 
				FROM bdinteg:"informix".si_coddevcam 
				WHERE codigo = cIdMotivoDev;

				LET cCausaDev = NVL(cCausaDev,'');
	
				SELECT num_cte INTO cNumCte FROM bdicheq:"informix".sc_maechq WHERE cuenta = cNoCuenta;
	
				--IF NVL(cNumCte,'') = '' THEN
				--	LET cCodRet = '00854'; --EL Nï¿½MERO DE CUENTA NO EXISTE
				--	RETURN cCodRet, iNumRegistros;
				--END IF;
				IF NVL(cNumCte,'') <> '' THEN
					SELECT TRIM(c.nombre1)||' '||TRIM(c.nombre2)||' '||TRIM(c.apell_paterno)||' '||TRIM(c.apell_materno), c.rfc, pf.fecha_nac 
					INTO cNombreCte, cRfc, dFechaNac
					FROM bdinteg:"informix".si_cliente AS c, bdinteg:"informix".si_ctepf AS pf 
					WHERE c.numcte = pf.numcte AND c.numcte = cNumCte;
				END IF;
				--IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				--	LET cCodRet = '00765'; --NO EXISTE EL CLIENTE
				--	RETURN cCodRet, iNumRegistros;
				--END IF;
	
				LET iIdConsCheque = iIdConsCheque + 1;			
			
				--LLENADO DE LA TABLA
				INSERT INTO bdicnweb:"informix".sw_ccer_aplicaabonocheques(id_consecutivo,usuario,fecha,
				num_cliente,nombre_cliente,rfc,fecha_nacimiento,banco_presenta,desc_banco,num_cuenta,num_cheque,importe,
				truncado,estatus,causa_dev,importe2,secuencia,nombre_archivo,abono_aplicado,fecha_insert) 
				VALUES (iIdConsCheque,pUsuario,pFecha,cNumCte,cNombreCte,cRfc,dFechaNac,cBancoPresenta,cDescBanco,
				cNoCuenta,NVL(iNoCheque,0),NVL(mImporte,0),cTruncado,cEstatus,cCausaDev,NVL(mImporte,0),NVL(iSecuencia,0),cNombreArchivo,'',CURRENT);
			END FOREACH;
			
		END IF;
		
		LET iNumRegistros = iIdConsCheque;
		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '00835'; --NO HAY CHEQUES PAGADOS POR Cï¿½MARA CON LOS CRITERIOS SELECCIONADOS, VERIFIQUE
		END IF;
		RETURN cCodRet, iNumRegistros;
	
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 01/07/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Devoluciones Forzadas',  
'DESCRIPCION: SPL que se encarga de consultar el nï¿½mero total de los cheques pagados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_procesacargoscuenta(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdProceso CHAR(1), pFecha DATE)
		RETURNING CHAR(5) AS codret,
			INTEGER AS total_registros;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE cEmpresa CHAR(3);
	DEFINE iTotalRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE bInTransaccion BOOLEAN;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cEmpresa = '001';
	LET iTotalRegistros = 0;
	LET iRecuperacion = 0;
	LET bInTransaccion = 'f';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			UPDATE bdicnweb:"informix".sw_cr_statuscargocta
			SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
			
			RETURN cCodRet,iTotalRegistros;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			COMMIT WORK;
			LET bInTransaccion = 't';			
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_procesacargoscuenta.out';
		--TRACE ON;
		
		-- SE LIMPIA TABLA POR USUARIO
		SET LOCK MODE TO WAIT 3;
		DELETE FROM bdicnweb:"informix".sw_cr_statuscargocta WHERE usuario = pUsuario;
		
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		SET LOCK MODE TO WAIT 3; 
		INSERT INTO bdicnweb:"informix".sw_cr_statuscargocta(usuario,status,total_reg,error_proceso,error)
		VALUES(pUsuario,'I',0,'','');
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdProceso = '' OR pFecha IS NULL THEN
			LET cCodRet = '00003';
			
			UPDATE bdicnweb:"informix".sw_cr_statuscargocta
			SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
			
			RETURN cCodRet,iTotalRegistros; 
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
		
			UPDATE bdicnweb:"informix".sw_cr_statuscargocta
			SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
			
			RETURN cCodRet,iTotalRegistros; 
		END IF;		
		
		BEGIN WORK;
		IF bInTransaccion = 'f' THEN
			COMMIT;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		
	
		EXECUTE PROCEDURE bditef:"informix".procesa_cargos(cEmpresa, pUsuario, pFecha, pIdProceso)
		INTO cCodRetSp, iTotalRegistros;
		
		IF bInTransaccion = 't' THEN
			BEGIN WORK;
		END IF;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIï¿½N DEL SP bditef:procesa_cargos';
		ELIF cCodRetSp::INTEGER = 0 THEN 
			
			UPDATE bdicnweb:"informix".sw_cr_statuscargocta
			SET status = 'T', error_proceso = 'N', total_reg = NVL(iTotalRegistros,0) WHERE usuario = pUsuario;
			
			RETURN cCodRet,NVL(iTotalRegistros,0);
		
		ELSE
		
			IF cCodRetSp::INTEGER = 101 THEN 
				LET cCodRet = '00837'; --YA SE EJECUTO ESTE PROCESO PARA ESTE Dï¿½A, VERIFIQUE
			ELIF cCodRetSp::INTEGER = 102 THEN 
				LET cCodRet = '00838'; --NO SE HA EJECUTADO EL CIERRE DE CHEQUES PARA ESTE Dï¿½A
			ELIF cCodRetSp::INTEGER = 150 THEN 
				LET cCodRet = '00840'; --NO SE HA EJECUTADO EL CIERRE DE CHEQUERAS
			ELIF cCodRetSp::INTEGER = 549 THEN 
				LET cCodRet = '00133'; --LA FECHA DE PROCESO REGISTRO ES MENOR A LA FECHA 
			ELSE
				LET cCodRet = TRIM(cCodRetSp); --ocurrio un error al procesar
			END IF;
			
			UPDATE bdicnweb:"informix".sw_cr_statuscargocta
			SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario = pUsuario;
			
			-- Nueva referencia
			COMMIT;
			BEGIN WORK;
			
			RETURN cCodRet,NVL(iTotalRegistros,0);
			
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 25/07/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Proceso manual de cargo a cuenta', 
'DESCRIPCION: SPL encargado de realizar el proceso de cargo a cuentas propias.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificastatuscargocta(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
			  CHAR(1) AS status,
			  INTEGER AS total_reg,
			  CHAR(1) AS error_proceso,
			  CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE iTotalRegistros INTEGER;
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET iTotalRegistros = 0;
	LET cErrorProceso = '';
	LET cError = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			--LET cCodRet = iSqlErr;
			LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,iTotalRegistros,cErrorProceso,cError;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_verificastatuscargocta.out';
		--TRACE ON;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iTotalRegistros,cErrorProceso,cError;	
		END IF;		
			
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iTotalRegistros,cErrorProceso,cError;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		SELECT status,total_reg,error_proceso,error
		INTO cStatus,iTotalRegistros,cErrorProceso,cError
		FROM bdicnweb:"informix".sw_cr_statuscargocta WHERE usuario = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,iTotalRegistros,cErrorProceso,cError;			
		ELSE 			
			RETURN cCodRet,cStatus,iTotalRegistros,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 28/09/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Proceso manual de cargo a cuenta', 
'DESCRIPCION: SPL encargado de hacer el monitoreo para el proceso de cargo a cuenta.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consdetallechequesprocnocturno(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			CHAR(20) AS cuenta,
			INTEGER AS cheque,
			CHAR(20) AS proceso,
			DATETIME HOUR TO SECOND AS hora,
			CHAR(5) AS codret_sp;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cCuenta CHAR(20);
	DEFINE iCheque INTEGER;
	DEFINE cProceso CHAR(20);
	DEFINE dHora DATETIME HOUR TO SECOND;
	DEFINE cCodretSp CHAR(5);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cCuenta = '';
	LET iCheque = 0;
	LET cProceso = '';
	LET dHora = '';
	LET cCodretSp = '';
	LET iRecuperacion = 0;
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCuenta, iCheque, cProceso, dHora, cCodretSp;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consdetallechequesprocnocturno.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCuenta, iCheque, cProceso, dHora, cCodretSp;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cCuenta, iCheque, cProceso, dHora, cCodretSp;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCuenta, iCheque, cProceso, dHora, cCodretSp;
		END IF;
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;	
		
		FOREACH			
			SELECT SKIP pRegistros FIRST pRecuperacion cuenta, cheque, proceso, hora, codret
			INTO cCuenta, iCheque, cProceso, dHora, cCodretSp
            FROM bditef:"informix".cce_bitacora
            WHERE fecha = pFecha ORDER BY secuencia
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cCuenta, iCheque, cProceso, dHora, cCodretSp WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00839'; --NO HAY REGISTROS EN LA BITÁCORA PARA ESTA FECHA, VERIFIQUE
			RETURN cCodRet, cCuenta, iCheque, cProceso, dHora, cCodretSp;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cCuenta, iCheque, cProceso, dHora, cCodretSp;
		END IF;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 02/08/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Cargo a cuenta proceso nocturno', 
'DESCRIPCION: SPL encargado de consultar la bitácora de cheques procesados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consdetallechequesprocnocturno_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE)
		RETURNING CHAR(5) AS codret,
			INTEGER AS num_registros;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET iNumRegistros = 0;
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumRegistros;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consdetallechequesprocnocturno_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumRegistros;
		END IF;
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNumRegistros;
		END IF;
		SET ISOLATION TO DIRTY READ;
		--SET LOCK MODE TO WAIT 3;	
		
		SELECT COUNT(*)	INTO iNumRegistros
		FROM bditef:"informix".cce_bitacora
		WHERE fecha = pFecha;
		
		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '00839'; ----NO HAY REGISTROS EN LA BITÁCORA PARA ESTA FECHA, VERIFIQUE
		END IF;
		
		RETURN cCodRet, iNumRegistros;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 02/08/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Cargo a cuenta proceso nocturno', 
'DESCRIPCION: SPL encargado de consultar el número total de registros de la bitácora de cheques procesados.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consdetalleaplicacioncargoscta(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE)
		RETURNING CHAR(5) AS codret,
			CHAR(20) AS proceso,
			CHAR(10) AS status,
			CHAR(8) AS ejecutivo,
			DATETIME HOUR TO SECOND AS hora_ini,
			DATETIME HOUR TO SECOND AS hora_fin,
			CHAR(5) AS codret_sp;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cProceso CHAR(20);
	DEFINE cStatusProc CHAR(1);
	DEFINE cEjecutivo CHAR(8);
	DEFINE dHoraIni DATETIME HOUR TO SECOND; 
	DEFINE dHoraFin DATETIME HOUR TO SECOND;
	DEFINE cCodretSp CHAR(5);
	DEFINE cStatus CHAR(10);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cProceso = '';
	LET cStatusProc = '';
	LET cEjecutivo = '';
	LET dHoraIni = ''; 
	LET dHoraFin = '';
	LET cCodretSp = '';
	LET cStatus = '';
	LET iRecuperacion = 0;
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cProceso,cStatus,cEjecutivo,NVL(dHoraIni,''),NVL(dHoraFin,''),cCodretSp;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consdetalleaplicacioncargoscta.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cProceso,cStatus,cEjecutivo,NVL(dHoraIni,''),NVL(dHoraFin,''),cCodretSp;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cProceso,cStatus,cEjecutivo,NVL(dHoraIni,''),NVL(dHoraFin,''),cCodretSp;
		END IF;
		SET ISOLATION TO DIRTY READ;
		--SET LOCK MODE TO WAIT 3;	
		
		SELECT proceso, status_proc, ejecutivo, hora_ini, hora_fin, codret
		INTO cProceso, cStatusProc, cEjecutivo, dHoraIni, dHoraFin, cCodretSp
		FROM bditef:"informix".cce_contproc WHERE empresa = cEmpresa AND fecha = pFecha;
		
		IF UPPER(cStatusProc) = 'I' THEN
			LET cStatus = 'Iniciado';
		ELSE
			LET cStatus = 'Finalizado';
		END IF;
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00782'; --NO HAY REGISTROS PARA ESTA FECHA, VERIFIQUE
		END IF;
		
		RETURN cCodRet,cProceso,cStatus,cEjecutivo,NVL(dHoraIni,''),NVL(dHoraFin,''),TRIM(cCodretSp);
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 02/08/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Cargo a cuenta proceso nocturno', 
'DESCRIPCION: SPL encargado de consultar el detalle de la aplicación de cargos a cuentas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consgeneralfechas(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1))
		RETURNING CHAR(5) AS codret,
			DATE AS fecha_hoy,
			DATE AS fecha_ant,
			DATE AS prox_fecha;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE dFechaHoy DATE;
	DEFINE dFechaAnt DATE; 
	DEFINE dProxFecha DATE;  
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET dFechaHoy = '';
	LET dFechaAnt = '';
	LET dProxFecha = ''; 
	LET iRecuperacion = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFechaHoy, dFechaAnt, dProxFecha;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consgeneralfechas.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFechaHoy, dFechaAnt, dProxFecha;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFechaHoy, dFechaAnt, dProxFecha;
		END IF;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pIdConsulta = '1' THEN
		
			SELECT fecha_hoy, fecha_ant, prox_fecha 
			INTO dFechaHoy, dFechaAnt, dProxFecha
			FROM bdicheq:"informix".sc_fechas WHERE empresa = cEmpresa;
			
		ELIF pIdConsulta = '2' THEN
		
			SELECT fecha_hoy, fecha_ant, prox_fecha 
			INTO dFechaHoy, dFechaAnt, dProxFecha
			FROM bdinteg:"informix".si_fechas WHERE empresa = cEmpresa;
			
		ELIF pIdConsulta = '3' THEN
		
			SELECT fecha_hoy, fecha_ant, prox_fecha 
			INTO dFechaHoy, dFechaAnt, dProxFecha
			FROM bdicont:"informix".co_fechas WHERE empresa = cEmpresa;
			
		ELIF pIdConsulta = '4' THEN
		
			SELECT fecha_hoy, fecha_ant, prox_fecha 
			INTO dFechaHoy, dFechaAnt, dProxFecha
			FROM bdicred:"informix".sd_fechas WHERE empresa = cEmpresa;
			
		END IF;
		
		IF dFechaHoy IS NULL AND dFechaAnt IS NULL AND dProxFecha IS NULL THEN
			LET cCodRet = '00017';
		END IF;
		
        RETURN cCodRet, TODAY, TODAY-1, TODAY+1;
		--RETURN cCodRet, dFechaHoy, dFechaAnt, dProxFecha;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 28/06/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Validación visual de cheques',  
'DESCRIPCION: SPL que se encarga de consultar la fecha hoy, fecha anterior y proxima fecha de diferentes tablas, según el id de consulta.',
'AUTOR: L. Montserrat León Amador',
'FECHA: 14/11/2016',
'DESCRIPCION: Se agrega id consulta 4 para tabla bdicred:sd_fechas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_deb_verificastatusarchivotxt(pUsuario CHAR(9), pIdFuncion CHAR(8), pProducto CHAR(4), pBandera CHAR(1))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error,
		CHAR(1) AS hayErrores,
		CHAR(4) AS producto,
		CHAR(1) AS emergente;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE cHayErrores CHAR(1);
	DEFINE cProducto CHAR(4);
	DEFINE cEmergente CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET cHayErrores = '';
	LET cProducto = '';
	LET cEmergente = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,cErrorProceso,cError,cHayErrores,cProducto, cEmergente;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	 
		--SET DEBUG FILE TO '/sp_ope_verificastatusxml.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pBandera = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,cErrorProceso,cError,cHayErrores, cProducto, cEmergente;
		END IF;		
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,cErrorProceso,cError,cHayErrores, cProducto, cEmergente;
		END IF;
		
		IF pBandera = 1 THEN 
			IF pProducto = '' THEN 
				SELECT status, error_proceso, error, codError, producto, emergente
				INTO cStatus, cErrorProceso, cError, cHayErrores, cProducto, cEmergente
				FROM "informix".sw_verificastatus_validarchivotxt WHERE usuario_insert = pUsuario;
			ELSE 
				SELECT status, error_proceso, error, codError
				INTO cStatus, cErrorProceso, cError, cHayErrores
				FROM "informix".sw_verificastatus_validarchivotxt WHERE usuario_insert = pUsuario AND producto = pProducto;
			END IF;
		ELSE
			DELETE FROM "informix".sw_verificastatus_validarchivotxt WHERE usuario_insert = pUsuario AND producto = pProducto;
		END IF;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,cErrorProceso,cError,cHayErrores,cProducto, cEmergente;
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 05/07/2025',
'MODULO: DEBITO',
'FUNCIONALIDAD: CARGA DE COMPAÃIAS',
'DESCRIPCION: SPL encargado verificar el status del proceso de validaciÃ³n de archivo txt [xls]',
'Se agrega validacion para obtener los datos y eliminar informacion:',
'Bandera 1 - Recuperacion de datos por producto o por usuario | Bandera 2 - Eliminacion de registro';

CREATE PROCEDURE "informix".sp_validadecimales(cadena CHAR(50), pProducto CHAR(4), pBandera CHAR(1))
	RETURNING BOOLEAN;

	DEFINE resultado BOOLEAN;
	DEFINE d DECIMAL;

	ON EXCEPTION
		LET resultado = 'f';
		RETURN resultado;
	END EXCEPTION

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO '/sp_cap_capturaeactulizagat.out';
	--TRACE ON;

	LET d = cadena;
	IF pProducto = '1100' THEN 
		IF d > 0 THEN
			LET resultado = 't';
		ELSE
			LET resultado = 'f';
		END IF;
	ELSE 
		LET resultado = 't';
	END IF;

	IF pBandera = '1' THEN
		IF ROUND(d, 2) = d THEN
			LET resultado = 't'; -- TRUE
		ELSE
			LET resultado = 'f'; -- FALSE
		END IF;
	END IF;
	
	RETURN resultado;
END PROCEDURE
DOCUMENT 'AUTOR: Veronica Sanchez',
'FECHA: 16/07/2025',
'MODULO: DEBITO',
'FUNCIONALIDAD: CARGA DE CAMPAÃAS',
'DESCRIPCION: Procedimiento almacenado encargado de validar los valores decimales',
'AUTOR: Veronica Sanchez',
'FECHA: 27/11/2025',
'DESCRIPCION: Se ajusta procedimiento almacenado para validar el numero de decimales',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validaenteros(cadena CHAR(50))
	RETURNING BOOLEAN;

	DEFINE resultado BOOLEAN;
	DEFINE d INTEGER;

	ON EXCEPTION
		LET resultado = 'f';
		RETURN resultado;
	END EXCEPTION
	
	--SET DEBUG FILE TO '/sp_ope_verificastatusxml.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;


	LET d = cadena;
	
	IF d > 0 THEN
        LET resultado = 't';
    ELSE
        LET resultado = 'f';
    END IF;


	RETURN resultado;
END PROCEDURE
DOCUMENT 'AUTOR: Veronica Sanchez',
'FECHA: 15/09/2025',
'MODULO: DEBITO',
'FUNCIONALIDAD: CARGA DE CAMPAÃAS',
'DESCRIPCION: Procedimiento almacenado encargado de validar los valores enteros';

CREATE PROCEDURE "informix".sp_validafechacarga(cadena CHAR(10))
	RETURNING BOOLEAN;

	DEFINE fecha DATE;
	DEFINE valido BOOLEAN;

    ON EXCEPTION
        LET valido = 'f';
		RETURN valido;
    END EXCEPTION

	--SET DEBUG FILE TO '/sp_ope_verificastatusxml.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	LET cadena = TRIM(cadena);
	LET fecha = TO_DATE(cadena, '%d-%m-%Y');
	LET valido = 't';
	
    RETURN valido;
	
END PROCEDURE
DOCUMENT 'AUTOR: Veronica Sanchez',
'FECHA: 03/09/2025',
'MODULO: DEBITO',
'FUNCIONALIDAD: CARGA DE CAMPAÃAS',
'DESCRIPCION: Procedimiento almacenado encargado de validar el formato de fecha';

CREATE PROCEDURE "informix".sp_admintasas_detallegat(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera CHAR(1), pPromocion INTEGER, pMes SMALLINT, 
pGatNominal DECIMAL (9,6), pGatReal DECIMAL(9,6), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			      SMALLINT AS mes,
				  DECIMAL(4,2) AS tasa,
				  DECIMAL(9,6) AS gatNominal,
				  DECIMAL(9,6) AS gatReal,
				  INTEGER AS totalRegistros;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	---Variables
	DEFINE iRecuperacion INTEGER;
	DEFINE sMesDetalle SMALLINT;
	DEFINE dTasaDetalle DECIMAL(4,2);
	DEFINE dGatNominalDetalle DECIMAL(9,6);
	DEFINE dGatRealDetalle DECIMAL(9,6);
	DEFINE iTotalRegistros INTEGER;
	DEFINE sCodEstatus SMALLINT;
	DEFINE iRegSeleccionado INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	---Variables
	LET iRecuperacion = 0;
	LET sMesDetalle = 0;
	LET dTasaDetalle = 0;
	LET dGatNominalDetalle = 0;
	LET dGatRealDetalle = 0;
	LET iTotalRegistros = 0;
	LET sCodEstatus = 0;
	LET iRegSeleccionado = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, sMesDetalle, dTasaDetalle, dGatNominalDetalle, dGatRealDetalle, iTotalRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/admintasas/sp_admintasas_detallegat.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pBandera = '' OR pPromocion IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, sMesDetalle, dTasaDetalle, dGatNominalDetalle, dGatRealDetalle, iTotalRegistros;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, sMesDetalle, dTasaDetalle, dGatNominalDetalle, dGatRealDetalle, iTotalRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, sMesDetalle, dTasaDetalle, dGatNominalDetalle, dGatRealDetalle, iTotalRegistros;
		END IF;
		
		IF pBandera = '1' THEN --TOTALES
			SELECT COUNT(*)
			INTO iTotalRegistros 
			FROM bdinteg:si_admintasas_inv_tasames 
			WHERE id_promocion = pPromocion;
			
			IF NVL(iTotalRegistros,0) = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, sMesDetalle, dTasaDetalle, dGatNominalDetalle, dGatRealDetalle, iTotalRegistros;
			ELSE
				RETURN cCodRet, sMesDetalle, dTasaDetalle, dGatNominalDetalle, dGatRealDetalle, iTotalRegistros;
			END IF;
			
		ELIF pBandera = '2' THEN -- CONSULTA
			FOREACH
				
				SELECT SKIP pRegistros FIRST pRecuperacion mes, valor_tasa, gat_nominal, gat_real 
				INTO sMesDetalle, dTasaDetalle, dGatNominalDetalle, dGatRealDetalle
				FROM bdinteg:si_admintasas_inv_tasames 
				WHERE id_promocion = pPromocion 
				ORDER BY mes ASC
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, sMesDetalle, dTasaDetalle, dGatNominalDetalle, dGatRealDetalle, iTotalRegistros WITH RESUME;
				
			END FOREACH;
			
			IF iRecuperacion = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017'; 
				RETURN cCodRet, sMesDetalle, dTasaDetalle, dGatNominalDetalle, dGatRealDetalle, iTotalRegistros;
			ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, sMesDetalle, dTasaDetalle, dGatNominalDetalle, dGatRealDetalle, iTotalRegistros;
			END IF;			
		ELSE -- 3 ACTUALIZACION
			SELECT gat_nominal, gat_real 
			INTO dGatNominalDetalle, dGatRealDetalle
			FROM bdinteg:si_admintasas_inv_tasames 
			WHERE id_promocion = pPromocion AND mes = pMes;
			
			IF dGatNominalDetalle <> pGatNominal THEN 
				INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, campoanterior, descripcion, producto)
				VALUES (TODAY, CURRENT, pUsuario, 'DETALLE GAT', 1, dGatNominalDetalle, "SE REALIZÃ LA MODIFICACIÃN DEL CAMPO gat_nominal DE LA CAMPAÃA "||pPromocion, '1100');		
			END IF;
			
			IF dGatRealDetalle <> pGatReal THEN 
				INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, campoanterior, descripcion, producto)
				VALUES (TODAY, CURRENT, pUsuario, 'DETALLE GAT', 1, dGatNominalDetalle, "SE REALIZÃ LA MODIFICACIÃN DEL CAMPO [gat_real] DE LA CAMPAÃA "||pPromocion, '1100');	
			END IF;
			
			UPDATE bdinteg:si_admintasas_inv_tasames 
			SET gat_nominal = pGatNominal, gat_real = pGatReal
			WHERE id_promocion = pPromocion AND mes = pMes;
			
			IF dGatNominalDetalle <> pGatNominal THEN 
				UPDATE bdinvers:"informix".sv_camp_bitacora 
				SET fecha = TODAY, hora = CURRENT, camponuevo = TO_CHAR(pGatNominal), usuario_mod = pUsuario 
				WHERE campoanterior = TO_CHAR(dGatNominalDetalle) AND producto = '1100';
			END IF;
			
			IF dGatRealDetalle <> pGatReal THEN 
				UPDATE bdinvers:"informix".sv_camp_bitacora 
				SET fecha = TODAY, hora = CURRENT, camponuevo = TO_CHAR(pGatReal), usuario_mod = pUsuario 
				WHERE campoanterior = TO_CHAR(dGatRealDetalle) AND producto = '1100';	
			END IF;
			
			SELECT limit 1 rowid, cod_estatus 
			INTO iRegSeleccionado, sCodEstatus 
			FROM bdicheq:sc_admintasas_inv_estatus 
			WHERE id_promocion = pPromocion
			AND fecha_cambio = (SELECT MAX(fecha_cambio) FROM bdicheq:sc_admintasas_inv_estatus WHERE id_promocion = pPromocion);
			
			IF NVL(sCodEstatus,0) = 1 THEN --Actualizacion de Estatus
				UPDATE bdicheq:sc_admintasas_inv_estatus  
				SET id_usuario = pUsuario, cod_estatus = 2, fecha_cambio = CURRENT
				WHERE id_promocion = pPromocion AND rowid = iRegSeleccionado;
			END IF;
			
			RETURN cCodRet, sMesDetalle, dTasaDetalle, dGatNominalDetalle, dGatRealDetalle, iTotalRegistros;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Veronica Sanchez',
'FECHA: 15/03/2025',
'MODULO: DEBITO',
'FUNCIONALIDAD: DETALLE GAT',
'DESCRIPCION: SPL encargado de de: ',
' 1 - Recuperar el total de registros',
' 2 - Recuperacion de datos a mostrar en grid de datos',
' 3 - Actualizacion de gat nominal y real de acuerdo a la promocion',
'AUTOR: Veronica Sanchez',
'FECHA: 15/04/2025',
'DESCRIPCION: Se modifica procedimiento almacenado para aplicar conversion de intero a cadena. ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_adminitasas_cargarchivo(pUsuario CHAR(9), pIdFuncion CHAR(8), pRutaArchivo CHAR(120), pNombreArchivo CHAR(35), pBandera CHAR(1), pProducto CHAR(4))
RETURNING CHAR(5)   AS codret,
          CHAR(200) AS Mensaje,
          CHAR(1)   AS errores;
    
    DEFINE cCodRet              CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE cSQL                 CHAR(500);
    DEFINE cRuta                CHAR(200);
    DEFINE cMensaje             CHAR(200);
    DEFINE cCanal               CHAR(20);
    DEFINE dTasa                DECIMAL(14,6);
    DEFINE iContador            INTEGER;
    DEFINE dCapitalmax          CHAR(10);
    DEFINE dCapitalmin          CHAR(10);
    DEFINE iplazoInicio         INTEGER;
    DEFINE iplazoVencimiento    INTEGER;
    DEFINE cErrores             CHAR(1);
    DEFINE iPromocion           INTEGER;
    DEFINE iPromocion2          INTEGER;
    DEFINE cSucursal            CHAR(5);
    DEFINE cCuenta              CHAR(20); 
    DEFINE iBanCuenta           SMALLINT; --bandera para saber si son cuentas   
    DEFINE iRenovacion          SMALLINT;
    DEFINE cNumcte              CHAR(20);
    DEFINE cNombre              CHAR(150);
    DEFINE iBanPromo            SMALLINT;
    DEFINE iNumFila             INTEGER;
    DEFINE iValido              INTEGER;
    DEFINE cTasaReno            CHAR(10);
    DEFINE cArchivo_dbld        CHAR(50);
    DEFINE cArchivo_log         CHAR(50);
	--Nuevos
	DEFINE cMes					CHAR(2);
	DEFINE cMesAux				CHAR(2);
	DEFINE dInicioVigente       CHAR(11);
    DEFINE dTerminoVigente      CHAR(11);
	DEFINE es_numerico			BOOLEAN;
	DEFINE esNumProm			BOOLEAN;
	DEFINE iContadorCeros		INTEGER;
	DEFINE iTotalCeros			INTEGER;
	DEFINE cValorCero			CHAR(10);
	DEFINE isDecimal			BOOLEAN;
	DEFINE cPlazoInicio         CHAR(50);
	DEFINE cPlazoVencimiento	CHAR(50);
    DEFINE cPromocion			CHAR(10);
	DEFINE dFechaHoraProceso	DATETIME YEAR TO SECOND;
	--Nuevos Campos
	DEFINE cRequiereSdoNuevo	CHAR(2);
	DEFINE cMontoSdoNuevo		CHAR(50);
	DEFINE cRequiereInstrApertura	CHAR(2);
	DEFINE cInstrumentoApertura	CHAR(60);
	DEFINE cParCteNuevo			CHAR(2);
	DEFINE cDiasVigenciaCteNuevo	CHAR(50);
	DEFINE iTotalRegErrores		INTEGER;
	DEFINE cPromocionTasa		CHAR(10);
	DEFINE cTasa				CHAR(15);

    LET cCodRet = '00000';
	LET iSqlErr = 0;
    LET cMensaje = 'EJECUCION EXITOSA';
    LET iContador = 0;
    LET cCanal = '';
    LET dTasa = '';
    LET dCapitalmax = '';
    LET dCapitalmin = '';
    LET iplazoInicio = '';
    LET iplazoVencimiento = '';
    LET iContador = 0;
    LET cErrores = 'f';
    LET iPromocion = 0;
    LET cSucursal = '';
    LET iPromocion2 = 0;
    LET cCuenta = '';
    LET iBanCuenta = 0;
    LET iRenovacion = 0;
    LET cNumcte  = '';
    LET cNombre  = '';
    LET iBanPromo = 0;
    LET iNumFila = 0;
    LET iValido = 0;
    LET cTasaReno = '';
    LET cArchivo_dbld = "sw_admintasascarga_temp.com";
    LET cArchivo_log = "sw_admintasascarga_temp.log";
	--Nuevos
	LET cMes = '';
	LET cMesAux = '';
    LET dInicioVigente = '';
    LET dTerminoVigente = '';
	LET es_numerico = 't';
	LET esNumProm = 't';
	LET iContadorCeros = 0;
	LET iTotalCeros = 0;
	LET cValorCero = '';
	LET isDecimal = 'f';
	LET cPlazoInicio = '';
	LET cPlazoVencimiento = '';
    LET cPromocion = '';
	LET dFechaHoraProceso = CURRENT;
	--Nuevos Campos
	LET cRequiereSdoNuevo	= '';
	LET cMontoSdoNuevo		= '';
	LET cRequiereInstrApertura	= '';
	LET cInstrumentoApertura	= '';
	LET cParCteNuevo			= '';
	LET cDiasVigenciaCteNuevo	= '';
	LET iTotalRegErrores		= 0;
	LET cPromocionTasa			= '';
	LET cTasa					= '';

    BEGIN
        ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
			
				SELECT COUNT(*) 
				INTO iTotalRegErrores 
				FROM bdinvers:"informix".sv_admintasas_bitacoraerror;
				
				IF NVL(iTotalRegErrores, 0) <> 0 THEN 
					UPDATE "informix".sw_verificastatus_validarchivotxt 
					SET error_proceso = 'N', error = cCodRet, status = 'T', coderror = cErrores, emergente = pBandera, fecha_hora_fin = CURRENT
					WHERE usuario_insert = pUsuario AND producto = pProducto;
					LET cMensaje = 'EJECUCIÃN FINALIZADA CON ERRORES REVISE LA MODAL DE ERRORES';
				ELSE
					LET cCodRet = '01282';
					LET cMensaje = 'OCURRIO UN ERROR EN EL PROCESO ' || iSqlErr;
					LET cErrores = 't';
					LET dFechaHoraProceso = CURRENT;
					UPDATE "informix".sw_verificastatus_validarchivotxt 
					SET error_proceso = 'S', error = cCodRet, status = 'E', coderror = cErrores, emergente = pBandera, fecha_hora_fin = dFechaHoraProceso
					WHERE usuario_insert = pUsuario AND producto = pProducto;
				END IF;
				
                RETURN cCodRet, cMensaje, cErrores;
            END IF;
		END EXCEPTION;		
		

       --SET DEBUG FILE TO '/RESPALDOSNEW/admintasas/sp_adminitasas_cargarchivo.out';
       --TRACE ON;

        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		DELETE FROM bdicnweb:"informix".sw_verificastatus_validarchivotxt WHERE usuario_insert = pUsuario;
		-- INSERCION DE DATOS DE TABLA DE TRABAJO DE VERIFICACION
		INSERT INTO bdicnweb:"informix".sw_verificastatus_validarchivotxt (usuario_insert,producto,status,error_proceso,error,codError, emergente, fecha_hora_ini, fecha_hora_fin) 
		VALUES (pUsuario, pProducto, 'I', '', cCodRet, '', '', CURRENT, NULL);
			
        IF pUsuario = '' OR pIdFuncion = '' OR pRutaArchivo = '' OR pNombreArchivo = '' OR pBandera = '' OR pProducto = '' THEN
			LET cCodRet = '00003';
			LET dFechaHoraProceso = CURRENT;
			UPDATE "informix".sw_verificastatus_validarchivotxt 
			SET error_proceso = 'S', error = cCodRet, status = 'E', coderror = cErrores, emergente = pBandera, fecha_hora_fin = dFechaHoraProceso
			WHERE usuario_insert = pUsuario AND producto = pProducto;
			
			RETURN cCodRet, cMensaje, cErrores;
		END IF;

            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		    EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		    IF cCodRet <> '00000' THEN
				LET dFechaHoraProceso = CURRENT;
				UPDATE "informix".sw_verificastatus_validarchivotxt 
				SET error_proceso = 'S', error = cCodRet, status = 'E', coderror = cErrores, emergente = pBandera, fecha_hora_fin = dFechaHoraProceso
				WHERE usuario_insert = pUsuario AND producto = pProducto;
				
			    RETURN cCodRet, cMensaje, cErrores;
		    END IF;

			--ELIMINACION DE DATOS 
            DELETE FROM bdicnweb:"informix".sw_admintasascarga_promociones WHERE usuario = pUsuario;
            DELETE FROM bdicnweb:"informix".sw_admintasascarga_tasas WHERE usuario = pUsuario;
            DELETE FROM bdicnweb:"informix".sw_admintasascarga_sucursales WHERE usuario = pUsuario;
            DELETE FROM bdicnweb:"informix".sw_admintasascarga_clientes WHERE usuario = pUsuario;
            DELETE FROM bdicnweb:"informix".sw_admintasascarga_cuentas WHERE usuario = pUsuario;
            DELETE FROM bdicnweb:"informix".sw_admintasascarga_renovaciones WHERE usuario = pUsuario;

            LET cSQL = '';
            LET cSQL = 'tr "\r" " " < '||TRIM(pRutaArchivo)||TRIM(pNombrearchivo)||' > '||TRIM(pRutaArchivo)||TRIM(pNombrearchivo)||'.tr';
            SYSTEM TRIM(cSQL);
			
            LET cSQL = '';
            LET cSQL = 'chmod 777 ' || TRIM(pRutaArchivo)||TRIM(pNombrearchivo)||'.tr';
            SYSTEM TRIM(cSQL);


            LET cSQL = '';
            LET cSQL = "mv "||TRIM(pRutaArchivo)||TRIM(pNombrearchivo)||'.tr '||TRIM(pRutaArchivo)||REPLACE(pNombrearchivo, '.txt', '.unl');
            SYSTEM TRIM(cSQL);

/*
            -- CARGA DE ARCHIVO LOAD
            LET cSQL = '';
            LET cSQL = "echo 'SET ISOLATION TO DIRTY READ; LOAD FROM "||TRIM(pRutaArchivo)||''||TRIM(pNombrearchivo)||" DELIMITER "||'"|"'||" INSERT INTO 'informix'.sw_admintasascarga_temp";
*/           

            LET pNombreArchivo = REPLACE(pNombrearchivo, '.txt', '.unl');
            -- CARGA DE ARCHIVO DBLOAD
            system 'echo "file '||TRIM(pRutaArchivo)||''||TRIM(pNombrearchivo)||' delimiter ''|'' 20; INSERT INTO informix.sw_admintasascarga_temp;" > '||TRIM(pRutaArchivo)||TRIM(cArchivo_dbld);
			SYSTEM 'chmod 777 ' || TRIM(pRutaArchivo) || TRIM(cArchivo_dbld);
            system 'echo "" > ' || TRIM(pRutaArchivo)|| TRIM(cArchivo_log);
            system 'chmod 777 ' || TRIM(pRutaArchivo)|| TRIM(cArchivo_log);
            

            SYSTEM 'echo "date ' || '">' || TRIM(pRutaArchivo) || 'dbload_sw_admintasascarga_temp.sh';
            --PRODUCCION
			system 'echo "/ifxsif01/bin/dbload -d bdicnweb -c ' || TRIM(pRutaArchivo) || TRIM(cArchivo_dbld) || ' -l ' || TRIM(pRutaArchivo) || TRIM(cArchivo_log) || ' -n 1000 -r' || ' " >> ' || TRIM(pRutaArchivo)|| 'dbload_sw_admintasascarga_temp.sh';
            --DESARROLLO
			--system 'echo "/informix/bin/dbload -d bdicnweb -c ' || TRIM(pRutaArchivo) || TRIM(cArchivo_dbld) || ' -l ' || TRIM(pRutaArchivo) || TRIM(cArchivo_log) || ' -n 1000 -r' || ' " >> ' || TRIM(pRutaArchivo)|| 'dbload_sw_admintasascarga_temp.sh';
            system 'echo "date ' || '">>' || TRIM(pRutaArchivo)|| 'dbload_sw_admintasascarga_temp.sh';
            -- PRODUCCION
			system 'echo "/ifxsif01/bin/dbaccess bdicnweb -<<EOF ' || '">>' || TRIM(pRutaArchivo)|| 'dbload_sw_admintasascarga_temp.sh';
            -- DESARROLLO
			--system 'echo "/informix/bin/dbaccess bdicnweb -<<EOF ' || '">>' || TRIM(pRutaArchivo)|| 'dbload_sw_admintasascarga_temp.sh';
            system 'echo "update statistics medium for table sw_admintasascarga_temp; ' || '">>' || TRIM(pRutaArchivo)|| 'dbload_sw_admintasascarga_temp.sh';
            system 'echo "EOF' || '">>' || TRIM(pRutaArchivo)|| 'dbload_sw_admintasascarga_temp.sh';
            system 'echo "date ' || '">>' || TRIM(pRutaArchivo)|| 'dbload_sw_admintasascarga_temp.sh';
            system 'chmod 777 ' || TRIM(pRutaArchivo)|| 'dbload_sw_admintasascarga_temp.sh';
            

            -- EJECUCIÃN DEL SHELL CON DBLOAD
            LET cSQL = '';
			LET cSQL = TRIM(pRutaArchivo)|| 'dbload_sw_admintasascarga_temp.sh';
            SYSTEM TRIM(cSQL);
            
            
            -- SE ELIMINA EL ARCHIVO .COM
            LET cSQL = '';
            LET cSQL = 'rm -rf '||TRIM(pRutaArchivo)||'sw_admintasascarga_temp.com';
            SYSTEM TRIM(cSQL);


            -- SE ELIMINA EL ARCHIVO ORIGINAL UNL
            LET cSQL = '';
            LET cSQL = 'rm -rf '||TRIM(pRutaArchivo)||TRIM(pNombrearchivo);
            SYSTEM TRIM(cSQL);

            -- SE ELIMINA EL ARCHIVO SH
            LET cSQL = '';
            LET cSQL = 'rm -rf '||TRIM(pRutaArchivo)|| 'dbload_sw_admintasascarga_temp.sh';
            SYSTEM TRIM(cSQL);
			
			-- SE ELIMINA EL ARCHIVO TXT
            LET cSQL = '';
            LET cSQL = 'rm -rf '||TRIM(pRutaArchivo)||REPLACE(TRIM(pNombrearchivo), '.unl', '.txt');
            SYSTEM TRIM(cSQL);


			--PASE DE INFORMACIÃN EN TABLAS DE TRABAJO 
			-- PROMOCIONES
			INSERT INTO bdicnweb:"informix".sw_admintasascarga_promociones 
			SELECT idcamp, TRIM(campo1), campo2, campo3, campo4, campo5, campo6, campo7, campo8, campo9, campo10, campo11, campo12,
			campo13, campo14, campo15, numfila, emergente, usuario
			FROM  bdicnweb:"informix".sw_admintasascarga_temp  
			WHERE hoja = "PROMOCIONES" AND usuario = pUsuario;
			-- TASAS
			INSERT INTO bdicnweb:"informix".sw_admintasascarga_tasas 
			SELECT idcamp, TRIM(campo1), TRIM(campo2), numfila, emergente, usuario
			FROM  bdicnweb:"informix".sw_admintasascarga_temp  
			WHERE hoja = 'TASAS' AND usuario = pUsuario;
			--SUCURSALES
			INSERT INTO bdicnweb:"informix".sw_admintasascarga_sucursales 
			SELECT idcamp, TRIM(campo1), numfila, emergente, usuario
			FROM  bdicnweb:"informix".sw_admintasascarga_temp  
			WHERE hoja = 'SUCURSALES' AND usuario = pUsuario;
			--CLIENTES
			INSERT INTO bdicnweb:"informix".sw_admintasascarga_clientes 
			SELECT idcamp, TRIM(campo1), numfila, emergente, usuario
			FROM  bdicnweb:"informix".sw_admintasascarga_temp  
			WHERE hoja = 'CLIENTES' AND usuario = pUsuario;
			-- CUENTAS
			INSERT INTO bdicnweb:"informix".sw_admintasascarga_cuentas 
			SELECT idcamp, TRIM(campo1), numfila, emergente, usuario
			FROM  bdicnweb:"informix".sw_admintasascarga_temp  
			WHERE hoja = 'CUENTAS' AND usuario = pUsuario; 
			-- RENOVACIONES
			INSERT INTO bdicnweb:"informix".sw_admintasascarga_renovaciones 
			SELECT idcamp, TRIM(campo1), TRIM(campo2), numfila, emergente, usuario
			FROM  bdicnweb:"informix".sw_admintasascarga_temp  
			WHERE hoja = 'RENOVACIONES' AND usuario = pUsuario;

			-- ELIMINACION DE DATOS EN TABLA TEMPORAL
			DELETE FROM {+INDEX ("informix".sw_admintasascarga_temp idx_sw_admintasascarga_temp)} "informix".sw_admintasascarga_temp 
			WHERE usuario = pUsuario;
			
            --*************** VALIDACIONES PROMOCIONES*******************************
			IF pProducto = '3000' THEN --VALIDACIONES DEL PRODUCTO 3000
				FOREACH
					SELECT idcamp, nombre, canal, tasa, capital_min, capital_max, plazo_min, plazo_max, fecha_inicio, fecha_fin, 
					requiere_sdo_nuevo, monto_saldo_nuevo, requiere_instruccion_apertura, instrumento_ven, para_cte_nuevo, dias_vigenciacte_nuevo, numfila
					INTO   iPromocion, cNombre, cCanal, dTasa, dCapitalmin, dCapitalmax, cPlazoInicio, cPlazoVencimiento, dInicioVigente, dTerminoVigente, 
					cRequiereSdoNuevo, cMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, cDiasVigenciaCteNuevo, iNumFila
					FROM "informix".sw_admintasascarga_promociones
					WHERE usuario = pUsuario
	
					LET iContador = iContador + 1;
	
					IF (iPromocion IS NULL OR iPromocion = '')  THEN
		
						LET cMensaje = 'EL CAMPO [ID] SE ENCUENTRA VACÃO/SIN INFORMACIÃN';
						LET cErrores = 't';
						LET iBanPromo = 1;
						LET iPromocion = 0;
	
						INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
						VALUES ('PROMOCIONES', 'ID', iNumFila, TRIM(cMensaje), pUsuario);
	
					
					END IF; 
	
					IF (cNombre IS NULL OR cNombre = '')  THEN
		
						LET cMensaje = 'EL CAMPO [NOMBRE CAMPAÃA] SE ENCUENTRA VACÃO/SIN INFORMACION';
						LET cErrores = 't';
						LET iBanPromo = 1;
						LET cNombre = '';
	
						INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
						VALUES ('PROMOCIONES', 'NOMBRE CAMPAÃA', iNumFila, TRIM(cMensaje), pUsuario);
					END IF; 
					
					IF pBandera <> '1' THEN -- SI NO ES EMERGENTE
						IF NVL(cCanal,'') = '' THEN
							LET cMensaje = 'EL CAMPO [CANAL] SE ENCUENTRA VACÃO/SIN INFORMACION';
							LET cErrores = 't';
							LET iBanPromo = 1;
							LET cCanal = '';
			
							INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
							VALUES ('PROMOCIONES', 'CANAL', iNumFila, TRIM(cMensaje), pUsuario);
						END IF; 
						
						IF NVL(dTasa,0) = 0 THEN
							LET cMensaje = 'EL CAMPO [TASA] SE ENCUENTRA VACÃO/SIN INFORMACION';
							LET cErrores = 't';
							LET iBanPromo = 1;
							LET dTasa = 0;
			
							INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
							VALUES ('PROMOCIONES', 'TASA', iNumFila, TRIM(cMensaje), pUsuario);
						END IF; 
						
						IF NVL(dCapitalmin,'') = ''  THEN
							LET cMensaje = 'EL CAMPO [CAPITAL MÃNIMO] SE ENCUENTRA VACÃO/SIN INFORMACION';
							LET cErrores = 't';
							LET iBanPromo = 1;
							LET dCapitalmin = '';
		
							INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
							VALUES ('PROMOCIONES', 'CAPITAL MÃNIMO', iNumFila, TRIM(cMensaje), pUsuario);
						ELSE
							EXECUTE PROCEDURE sp_validaDecimales (dCapitalmin, pProducto, '') INTO isDecimal;
							IF isDecimal = 't' THEN
								LET es_numerico = 't';
							ELSE
								LET es_numerico = 'f';
								LET cMensaje = 'EL VALOR INGRESADO NO ES CORRECTO, SOLO SE PERMITE INGRESAR VALORES NUMÃRICOS.';
								LET cErrores = 't';
		
								INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror (nombreHoja, nombreCampo, numerofila, descripcion, usuario)
								VALUES ('PROMOCIONES', 'CAPITAL MÃNIMO', iNumFila, TRIM(cMensaje), pUsuario); 
							END IF;
						END IF;
					
						IF NVL(dCapitalmax,'') = ''  THEN
							LET cMensaje = 'EL CAMPO [CAPITAL MÃXIMO] SE ENCUENTRA VACÃO/SIN INFORMACION';
							LET cErrores = 't';
							LET iBanPromo = 1;
							LET dCapitalmax = '';
			
							INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
							VALUES ('PROMOCIONES', 'CAPITAL MÃXIMO', iNumFila, TRIM(cMensaje), pUsuario);
						ELSE 
							EXECUTE PROCEDURE sp_validaDecimales (dCapitalmax, pProducto, '') INTO isDecimal;
							IF isDecimal = 't' THEN
								LET es_numerico = 't';
							ELSE
								LET es_numerico = 'f';
								LET cMensaje = 'EL VALOR INGRESADO NO ES CORRECTO, SOLO SE PERMITE INGRESAR VALORES NUMÃRICOS.';
								LET cErrores = 't';
		
								INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror (nombreHoja, nombreCampo, numerofila, descripcion, usuario)
								VALUES ('PROMOCIONES', 'CAPITAL MÃXIMO', iNumFila, TRIM(cMensaje), pUsuario); 
							END IF;
						END IF;
						
						IF NVL(cPlazoInicio,'') = ''  THEN
							LET cMensaje = 'EL CAMPO [PLAZO MÃNIMO] SE ENCUENTRA VACÃO/SIN INFORMACION';
							LET cErrores = 't';
							LET iBanPromo = 1;
							LET iplazoInicio = '';
		
							INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
							VALUES ('PROMOCIONES', 'PLAZO MÃNIMO', iNumFila, TRIM(cMensaje), pUsuario);
						ELSE 
							IF cPlazoInicio MATCHES "*[0-9]*" THEN
								LET es_numerico = 't';
								LET iplazoInicio = cPlazoInicio;
							ELSE
								LET es_numerico = 'f';
								LET cMensaje = 'EL VALOR INGRESADO NO ES CORRECTO, SOLO SE PERMITE INGRESAR VALORES NUMÃRICOS.';
								LET cErrores = 't';
		
								INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror (nombreHoja, nombreCampo, numerofila, descripcion, usuario)
								VALUES ('PROMOCIONES', 'PLAZO MÃNIMO', iNumFila, TRIM(cMensaje), pUsuario); 
							END IF;
						END IF;
						
						IF NVL(cPlazoVencimiento, '') = ''  THEN
							LET cMensaje = 'EL CAMPO [PLAZO MÃXMO] SE ENCUENTRA VACÃO/SIN INFORMACION';
							LET cErrores = 't';
							LET iBanPromo = 1;
							LET iplazoVencimiento = '';
			
							INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
							VALUES ('PROMOCIONES', 'PLAZO MÃXIMO', iNumFila, TRIM(cMensaje), pUsuario);
						ELSE 
							IF cPlazoVencimiento MATCHES "*[0-9]*" THEN
								LET es_numerico = 't';
								LET iplazoVencimiento = cPlazoVencimiento;
							ELSE
								LET es_numerico = 'f';
								LET cMensaje = 'EL VALOR INGRESADO NO ES CORRECTO, SOLO SE PERMITE INGRESAR VALORES NUMÃRICOS.';
								LET cErrores = 't';
		
								INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror (nombreHoja, nombreCampo, numerofila, descripcion, usuario)
								VALUES ('PROMOCIONES', 'PLAZO MÃXIMO', iNumFila, TRIM(cMensaje), pUsuario); 
							END IF;
						END IF;
						
						IF NVL(dInicioVigente, '') = ''  THEN
							LET cMensaje = 'EL CAMPO [INICIO VIGENCIA] SE ENCUENTRA VACÃO/SIN INFORMACION';
							LET cErrores = 't';
							LET iBanPromo = 1;
							LET dInicioVigente = '';
			
							INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
							VALUES ('PROMOCIONES', 'INICIO VIGENCIA', iNumFila, TRIM(cMensaje), pUsuario);
						ELSE 
							LET dInicioVigente = LTRIM(dInicioVigente);
							EXECUTE PROCEDURE sp_validaFechaCarga (dInicioVigente) INTO isDecimal;
							IF isDecimal = 'f' THEN
								LET cMensaje = 'EL VALOR INGRESADO NO ES CORRECTO, SOLO PERMITE INGRESAR UNA FECHA CON EL FORMATO DD-MM-YYYY';
								LET cErrores = 't';
			
								INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
								VALUES ('PROMOCIONES', 'INICIO VIGENCIA', iNumFila, TRIM(cMensaje), pUsuario);
							END IF;
						END IF;
						
						IF NVL(dTerminoVigente, '') = ''  THEN
							LET cMensaje = 'EL CAMPO [TÃRMINO VIGENCIA] SE ENCUENTRA VACÃO/SIN INFORMACION';
							LET cErrores = 't';
							LET iBanPromo = 1;
							LET dTerminoVigente = '';
			
							INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
							VALUES ('PROMOCIONES', 'TÃRMINO VIGENCIA', iNumFila, TRIM(cMensaje), pUsuario);
						ELSE
							LET dTerminoVigente = LTRIM(dTerminoVigente);
							EXECUTE PROCEDURE sp_validaFechaCarga (dTerminoVigente) INTO isDecimal;
							IF isDecimal = 'f' THEN
								LET cMensaje = 'EL VALOR INGRESADO NO ES CORRECTO, SOLO PERMITE INGRESAR UNA FECHA CON EL FORMATO DD-MM-YYYY';
								LET cErrores = 't';
			
								INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
								VALUES ('PROMOCIONES', 'TERMINO VIGENCIA', iNumFila, TRIM(cMensaje), pUsuario);
							END IF;
						END IF;
						
						IF cCanal IS NULL OR UPPER(TRIM(cCanal)) NOT IN  ('SUCURSAL', 'APP', 'PORTAL', 'ATM')THEN 
							--LET cMensaje = 'EL VALOR INGRESADO NO ES CORRECTO UNICAMENTE SE PERMITE SUCURSAL, APP, PORTAL Y ATM';
							LET cMensaje = 'EL CANAL INGRESADO NO ES CORRECTO, ÃNICAMENTE SE PERMITE INGRESAR LOS CANALES SUCURSAL, APP, PORTAL Y ATM';
							LET cErrores = 't';
	
							INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
							VALUES ('PROMOCIONES', 'CANAL', iNumFila, TRIM(cMensaje), pUsuario);
						END IF;
						
						IF dTasa < 0 OR dTasa > 100 THEN
							LET cMensaje = 'EL VALOR DE LA TASA INGRESADO NO ES CORRECTO, SOLO SE PERMITEN VALORES DE 0 A 100';
							LET cErrores = 't';
		
							INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
							VALUES ('PROMOCIONES', 'TASA', iNumFila, TRIM(cMensaje), pUsuario);
						END IF;
						
						IF dTasa > (SELECT MAX(valor) FROM bdinteg:si_tasavlor  WHERE tasa = 'EJEMP') THEN
							LET cMensaje = 'EL VALOR DE LA TASA INGRESADO ES SUPERIOR A LA TASA DE REFERENCIA CETES';
							IF cErrores = 'f' THEN
								LET cErrores = 'v';
							END IF;
		
							INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
							VALUES ('PROMOCIONES', 'TASA', iNumFila, cMensaje, pUsuario);
						END IF;
						
						IF  (iplazoInicio = 14 AND iplazoVencimiento = 27) OR
							(iplazoInicio = 28 AND iplazoVencimiento = 59) OR
							(iplazoInicio = 60 AND iplazoVencimiento = 90) OR
							(iplazoInicio = 91 AND iplazoVencimiento = 119) OR
							(iplazoInicio = 120 AND iplazoVencimiento = 149) OR
							(iplazoInicio = 150 AND iplazoVencimiento = 179) OR
							(iplazoInicio = 180 AND iplazoVencimiento = 209) OR
							(iplazoInicio = 210 AND iplazoVencimiento = 239) OR
							(iplazoInicio = 240 AND iplazoVencimiento = 269) OR
							(iplazoInicio = 270 AND iplazoVencimiento = 299) OR
							(iplazoInicio = 300 AND iplazoVencimiento = 329) OR
							(iplazoInicio = 330 AND iplazoVencimiento = 360) THEN
							LET cMensaje = 'EJECUCION EXITOSA';
						ELSE
							LET cMensaje = 'EL VALOR DE LOS PLAZOS NO ES CORRECTO SOLO SE PERMITEN LAS SIGUIENTES COMBINACIONES: 14-27, 28-59, 60-90, 91-119, 120-149, 150-179, 180-209, 210-239, 240-269, 270-299, 300-329, 330-360';
							LET cErrores = 't';
							INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
							VALUES ('PROMOCIONES', 'PLAZOS', iNumFila, TRIM(cMensaje), pUsuario);
						END IF;
						
						-- NUEVAS VALIDACIONES
						LET cRequiereSdoNuevo = UPPER(TRIM(cRequiereSdoNuevo));
						IF NVL(cRequiereSdoNuevo,'') <> '' THEN
							IF cRequiereSdoNuevo = 'SI' THEN 
								IF NVL(cMontoSdoNuevo,'') = '' THEN 
									LET cMensaje = 'DEBE INGRESAR UN MONTO EN El CAMPO MONTO SALDO NUEVO CUANDO REQUIERE SALDO NUEVO SEA IGUAL A SI';
									LET cErrores = 't';
									INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
									VALUES ('PROMOCIONES', 'MONTO SALDO NUEVO', iNumFila, TRIM(cMensaje), pUsuario);
								ELSE 
									EXECUTE PROCEDURE sp_validaDecimales (cMontoSdoNuevo, pProducto, '1') INTO isDecimal;
									IF isDecimal = 'f' THEN
										LET cMensaje = 'FORMATO INCORRECTO, MAXIMO DOS DECIMALES';
										LET cErrores = 't';
										INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
										VALUES ('PROMOCIONES', 'MONTO SALDO NUEVO', iNumFila, TRIM(cMensaje), pUsuario);
									END IF;
								END IF;
							END IF;
							IF cRequiereSdoNuevo = 'NO' THEN 
								IF NVL(cMontoSdoNuevo,'') <> '' THEN 
									LET cMensaje = 'EL VALOR INGRESADO NO ES CORRECTO. EL CAMPO MONTO SALDO NUEVO DEBE CONTENER UN VALOR ÃNICAMENTE CUANDO REQUIERE SALDO NUEVO SEA IGUAL A SI';
									LET cErrores = 't';
									INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
									VALUES ('PROMOCIONES', 'MONTO SALDO NUEVO', iNumFila, TRIM(cMensaje), pUsuario);
								ELSE 
									LET cMontoSdoNuevo = '0.00';
								END IF;
							END IF;
						ELSE
							IF NVL(cMontoSdoNuevo,'') <> '' THEN 
								LET cMensaje = 'EL VALOR INGRESADO NO ES CORRECTO. EL CAMPO MONTO SALDO NUEVO DEBE CONTENER UN VALOR ÃNICAMENTE CUANDO REQUIERE SALDO NUEVA SEA IGUAL A SI';
								LET cErrores = 't';
								INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
								VALUES ('PROMOCIONES', 'MONTO SALDO NUEVO', iNumFila, TRIM(cMensaje), pUsuario);
							ELSE 
								LET cMontoSdoNuevo = '0.00';
							END IF;
						END IF;
						
						-- NUEVAS VALIDACIONES
						LET cRequiereInstrApertura = UPPER(TRIM(cRequiereInstrApertura));
						IF NVL(cRequiereInstrApertura,'') <> '' THEN
							IF cRequiereInstrApertura = 'SI' THEN 
								IF NVL(cInstrumentoApertura,'') = '' THEN 
									LET cMensaje = 'DEBE INGRESAR UN VALOR EN EL CAMPO INSTRUCCION AL VENCIMIENTO CUANDO REQUIERE INSTRUCCION ESPECIFICA EN APERTURA SEA IGUAL A SI';
									LET cErrores = 't';
									INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
									VALUES ('PROMOCIONES', 'INSTRUCCION AL VENCIMIENTO', iNumFila, TRIM(cMensaje), pUsuario);
								END IF;
							ELSE 
								IF NVL(cInstrumentoApertura,'') <> '' THEN 
									LET cMensaje = 'EL VALOR INGRESADO NO ES CORRECTO. EL CAMPO INSTRUCCIÃN AL VENCIMIENTO SOLO APLICA CUANDO REQUIERE INSTRUCCION ESPECIFICA EN APERTURA SEA IGUAL A SI';
									LET cErrores = 't';
									INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
									VALUES ('PROMOCIONES', 'INSTRUCCION AL VENCIMIENTO', iNumFila, TRIM(cMensaje), pUsuario);
								ELSE 
									LET cInstrumentoApertura = NULL;
								END IF;
							END IF;	
						ELSE
							IF NVL(cInstrumentoApertura,'') <> '' THEN 
								LET cMensaje = 'EL VALOR INGRESADO NO ES CORRECTO. EL CAMPO INSTRUCCIÃN AL VENCIMIENTO SOLO APLICA CUANDO REQUIERE INSTRUCCION ESPECIFICA EN APERTURA SEA IGUAL A SI';
								LET cErrores = 't';
								INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
								VALUES ('PROMOCIONES', 'INSTRUCCION AL VENCIMIENTO', iNumFila, TRIM(cMensaje), pUsuario);
							ELSE 
								LET cInstrumentoApertura = NULL;
							END IF;
						END IF;
						
						-- NUEVAS VALIDACIONES
						LET cParCteNuevo = UPPER(TRIM(cParCteNuevo));
						IF NVL(cParCteNuevo,'') <> '' THEN
							IF cParCteNuevo = 'SI' THEN 
								IF NVL(cDiasVigenciaCteNuevo,'') = '' THEN 
									LET cMensaje = 'DEBE INGRESAR UN VALOR EN EL CAMPO DIAS VIGENCIA (CLIENTE NUEVO) CUANDO PARA CLIENTE NUEVO SEA IGUAL A SI';
									LET cErrores = 't';
									INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
									VALUES ('PROMOCIONES', 'DIAS VIGENCIA (CLIENTE NUEVO)', iNumFila, TRIM(cMensaje), pUsuario);
								ELSE
									EXECUTE PROCEDURE bdicnweb:"informix".sp_validaEnteros(cDiasVigenciaCteNuevo) INTO isDecimal;
									IF isDecimal = 'f' THEN
										LET cMensaje = 'DIAS VIGENCIA (CLIENTE NUEVO) DEBE SER ENTERO POSITIVO';
										LET cErrores = 't';
										INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
										VALUES ('PROMOCIONES', 'DIAS VIGENCIA (CLIENTE NUEVO)', iNumFila, TRIM(cMensaje), pUsuario); 
									END IF;
								END IF;
							ELSE 
								IF NVL(cDiasVigenciaCteNuevo,'') <> '' THEN 
									LET cMensaje = 'EL VALOR INGRESADO NO ES CORRECTO. EL CAMPO DIAS VIGENCIA (CLIENTE NUEVO) DEBE CONTENER UN VALOR UNICAMENTE CUANDO PARA CLIENTE NUEVO SEA IGUAL A SI';
									LET cErrores = 't';
									INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
									VALUES ('PROMOCIONES', 'DIAS VIGENCIA (CLIENTE NUEVO)', iNumFila, TRIM(cMensaje), pUsuario);
								END IF;
							END IF;	
						ELSE
							IF NVL(cDiasVigenciaCteNuevo,'') <> '' THEN 
								LET cMensaje = 'EL VALOR INGRESADO NO ES CORRECTO. EL CAMPO DIAS VIGENCIA (CLIENTE NUEVO) DEBE CONTENER UN VALOR UNICAMENTE CUANDO PARA CLIENTE NUEVO SEA IGUAL A SI';
								LET cErrores = 't';
								INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
								VALUES ('PROMOCIONES', 'DIAS VIGENCIA (CLIENTE NUEVO)', iNumFila, TRIM(cMensaje), pUsuario);
							ELSE 
								LET cDiasVigenciaCteNuevo = NULL;
							END IF;
						END IF;
						
					END IF;
	
				END FOREACH
	
				IF iContador = 0 THEN
					LET cCodRet = '00017';
					LET cMensaje = 'NO SE ENCONTRARON REGISTROS EN LA HOJA DE PROMOCIONES';
					LET dFechaHoraProceso = CURRENT;
					UPDATE "informix".sw_verificastatus_validarchivotxt 
					SET error_proceso = 'S', error = cCodRet, status = 'E', coderror = cErrores, emergente = pBandera, fecha_hora_fin = dFechaHoraProceso
					WHERE usuario_insert = pUsuario AND producto = pProducto;
					
					RETURN cCodRet, cMensaje, cErrores;
				END IF;
	
				FOREACH
					SELECT idcamp,numfila
					INTO iPromocion, iNumFila
					FROM bdicnweb:"informix".sw_admintasascarga_promociones
					WHERE usuario = pUsuario
					AND idcamp IN (	SELECT idcamp 
									FROM bdicnweb:"informix".sw_admintasascarga_promociones
									WHERE usuario = pUsuario 
									GROUP BY idcamp HAVING COUNT(*) > 1)
	
					ORDER BY numfila
	
					IF iPromocion > 0 OR iPromocion IS NOT NULL THEN 
						
						LET cMensaje = 'EL ID DE PROMOCIÃN ['|| iPromocion ||'] SE ENCUENTRA DUPLICADO';
						LET cErrores = 't';
						INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
						VALUES ('PROMOCIONES', 'ID', iNumFila, TRIM(cMensaje), pUsuario);
					END IF
				END FOREACH
	
	
				FOREACH
	
					SELECT nombre,numfila
					INTO cNombre, iNumFila
					FROM bdicnweb:"informix".sw_admintasascarga_promociones
					WHERE usuario = pUsuario
					AND nombre IN (	SELECT nombre 
									FROM bdicnweb:"informix".sw_admintasascarga_promociones
									WHERE usuario = pUsuario 
									GROUP BY nombre HAVING COUNT(*) > 1)
					ORDER BY numfila
					
					LET cNombre = NVL(cNombre,'');
					IF cNombre <> '' THEN 
						
						LET cMensaje = 'EL NOMBRE PROMOCIÃN ['|| TRIM(cNombre) ||'] SE ENCUENTRA DUPLICADO';
						LET cErrores = 't';
						INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
						VALUES ('PROMOCIONES', 'NOMBRE CAMPAÃA', iNumFila, TRIM(cMensaje), pUsuario);
					END IF
				
				END FOREACH
				
			ELIF pProducto = '1100' THEN --VALIDACIONES DEL PRODUCTO 1100
				FOREACH
					SELECT idcamp, nombre, canal, tasa, capital_min, capital_max, plazo_min, numfila
					INTO cPromocion, cNombre, cCanal, dCapitalmin, dCapitalmax, dInicioVigente, dTerminoVigente, iNumFila
					FROM bdicnweb:"informix".sw_admintasascarga_promociones
					WHERE usuario = pUsuario
	
					LET iContador = iContador + 1;
	
					IF NVL(cPromocion,'') = ''  THEN
		
						LET cMensaje = 'EL CAMPO [ID] SE ENCUENTRA VACÃO/SIN INFORMACIÃN';
						LET cErrores = 't';
						LET iBanPromo = 1;
						LET iPromocion = 0;
	
						INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
						VALUES ('PROMOCIONES', 'ID', iNumFila, TRIM(cMensaje), pUsuario);
					ELSE 
						IF cPromocion MATCHES "*[0-9]*" THEN
							LET esNumProm = 't';
							LET iPromocion = cPromocion;
						ELSE
							LET esNumProm = 'f';
							LET cMensaje = 'EL VALOR DEL CAMPO [ID] NO ES CORRECTO, SOLO SE PERMITEN VALORES NUMÃRICOS.';
							LET cErrores = 't';
							INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror (nombreHoja, nombreCampo, numerofila, descripcion, usuario)
							VALUES ('PROMOCIONES', 'ID', iNumFila, TRIM(cMensaje), pUsuario); 
						END IF;
					END IF;
					
					IF (cNombre IS NULL OR cNombre = '')  THEN
		
						LET cMensaje = 'EL CAMPO [NOMBRE CAMPAÃA] SE ENCUENTRA VACÃO/SIN INFORMACION';
						LET cErrores = 't';
						LET iBanPromo = 1;
						LET cNombre = '';
	
						INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
						VALUES ('PROMOCIONES', 'NOMBRE CAMPAÃA', iNumFila, TRIM(cMensaje), pUsuario);
					END IF; 
					
					IF LENGTH(cNombre) > 100 THEN
						LET cMensaje = 'LA LONGITUD DEL CAMPO NOMBRE CAMPAÃA NO ES CORRECTA, SOLO SE PERMITEN COMO MÃXIMO 100 CARACTERES';
						LET cErrores = 't';
						LET iBanPromo = 1;
						LET cNombre = '';
			
						INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
						VALUES ('PROMOCIONES', 'NOMBRE CAMPAÃA', iNumFila, TRIM(cMensaje), pUsuario);
					END IF;
					
					IF NVL(cCanal,'') = '' THEN
						LET cMensaje = 'EL CAMPO [CANAL] SE ENCUENTRA VACÃO/SIN INFORMACION';
						LET cErrores = 't';
						LET iBanPromo = 1;
						LET cCanal = '';
						INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
						VALUES ('PROMOCIONES', 'CANAL', iNumFila, TRIM(cMensaje), pUsuario);
					END IF; 
					
					IF NVL(dCapitalmin,'') = ''  THEN
							LET cMensaje = 'EL CAMPO [CAPITAL MÃNIMO] SE ENCUENTRA VACÃO/SIN INFORMACION';
							LET cErrores = 't';
							LET iBanPromo = 1;
							LET dCapitalmin = '';
		
						INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
						VALUES ('PROMOCIONES', 'CAPITAL MÃNIMO', iNumFila, TRIM(cMensaje), pUsuario);
					ELSE
						EXECUTE PROCEDURE sp_validaDecimales (dCapitalmin, pProducto, '')  INTO isDecimal;
						IF isDecimal = 't' THEN
							LET es_numerico = 't';
						ELSE
							LET es_numerico = 'f';
							LET cMensaje = 'EL VALOR INGRESADO NO ES CORRECTO, SOLO SE PERMITE INGRESAR VALORES NUMÃRICOS.';
							LET cErrores = 't';
		
							INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror (nombreHoja, nombreCampo, numerofila, descripcion, usuario)
							VALUES ('PROMOCIONES', 'CAPITAL MÃNIMO', iNumFila, TRIM(cMensaje), pUsuario); 
						END IF;
					END IF;
					
					IF NVL(dCapitalmax,'') = ''  THEN
						LET cMensaje = 'EL CAMPO [CAPITAL MÃXIMO] SE ENCUENTRA VACÃO/SIN INFORMACION';
						LET cErrores = 't';
						LET iBanPromo = 1;
						LET dCapitalmax = '';
					
						INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
						VALUES ('PROMOCIONES', 'CAPITAL MÃXIMO', iNumFila, TRIM(cMensaje), pUsuario);
					ELSE 
						EXECUTE PROCEDURE sp_validaDecimales (dCapitalmax, pProducto, '') INTO isDecimal;
						IF isDecimal = 't' THEN
							LET es_numerico = 't';
						ELSE
							LET es_numerico = 'f';
							LET cMensaje = 'EL VALOR INGRESADO NO ES CORRECTO, SOLO SE PERMITE INGRESAR VALORES NUMÃRICOS.';
							LET cErrores = 't';
					
							INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror (nombreHoja, nombreCampo, numerofila, descripcion, usuario)
							VALUES ('PROMOCIONES', 'CAPITAL MÃXIMO', iNumFila, TRIM(cMensaje), pUsuario); 
						END IF;
					END IF;
						
					IF NVL(dInicioVigente, '') = ''  THEN
						LET cMensaje = 'EL CAMPO [INICIO VIGENCIA] SE ENCUENTRA VACÃO/SIN INFORMACION';
						LET cErrores = 't';
						LET iBanPromo = 1;
						LET dInicioVigente = '';
					
						INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
						VALUES ('PROMOCIONES', 'INICIO VIGENCIA', iNumFila, TRIM(cMensaje), pUsuario);
					ELSE 
						LET dInicioVigente = LTRIM(dInicioVigente);
						EXECUTE PROCEDURE sp_validaFechaCarga (dInicioVigente) INTO isDecimal;
						IF isDecimal = 'f' THEN
							LET cMensaje = 'EL VALOR INGRESADO NO ES CORRECTO, SOLO PERMITE INGRESAR UNA FECHA CON EL FORMATO DD-MM-YYYY';
							LET cErrores = 't';
			
							INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
							VALUES ('PROMOCIONES', 'INICIO VIGENCIA', iNumFila, TRIM(cMensaje), pUsuario);
						END IF;
					END IF;
					
					IF NVL(dTerminoVigente, '') = ''  THEN
						LET cMensaje = 'EL CAMPO [TÃRMINO VIGENCIA] SE ENCUENTRA VACÃO/SIN INFORMACION';
						LET cErrores = 't';
						LET iBanPromo = 1;
						LET dTerminoVigente = '';
					
						INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
						VALUES ('PROMOCIONES', 'TÃRMINO VIGENCIA', iNumFila, TRIM(cMensaje), pUsuario);
					ELSE
						LET dTerminoVigente = LTRIM(dTerminoVigente);
						EXECUTE PROCEDURE sp_validaFechaCarga (dTerminoVigente) INTO isDecimal;
						IF isDecimal = 'f' THEN
							LET cMensaje = 'EL VALOR INGRESADO NO ES CORRECTO, SOLO PERMITE INGRESAR UNA FECHA CON EL FORMATO DD-MM-YYYY';
							LET cErrores = 't';
			
							INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
							VALUES ('PROMOCIONES', 'TERMINO VIGENCIA', iNumFila, TRIM(cMensaje), pUsuario);
						END IF;
					END IF;	
					
					IF cCanal IS NULL OR UPPER(TRIM(cCanal)) NOT IN  ("SUCURSAL", 'APP', 'PORTAL', 'ATM')THEN 
						LET cMensaje = 'EL CANAL INGRESADO NO ES CORRECTO, UNICAMENTE SE PERMITE INGRESAR LOS CANALES SUCURSAL, APP, PORTAL Y ATM';
						LET cErrores = 't';
			
						INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
						VALUES ('PROMOCIONES', 'CANAL', iNumFila, TRIM(cMensaje), pUsuario);
					END IF;
					
					IF TO_DATE(dInicioVigente, '%d-%m-%Y') > TO_DATE(dTerminoVigente, '%d-%m-%Y') THEN
						LET cMensaje = 'EL VALOR INGRESADO EN EL CAMPO INICIO VIGENCIA NO DEBE SER MAYOR AL VALOR INGRESADO EN EL CAMPO TERMINO VIGENCIA';
						LET cErrores = 't';
						LET iBanPromo = 1;
					
						INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
						VALUES ('PROMOCIONES', 'INICIO VIGENCIA', iNumFila, TRIM(cMensaje), pUsuario);
					END IF;
					
					IF TO_DATE(dTerminoVigente,'%d-%m-%Y') < TO_DATE(dInicioVigente,'%d-%m-%Y') THEN
						LET cMensaje = 'EL VALOR INGRESADO EN EL CAMPO TERMINO VIGENCIA NO DEBE SER MENOR AL VALOR INGRESADO EN EL CAMPO INICIO VIGENCIA';
						LET cErrores = 't';
						LET iBanPromo = 1;
					
						INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
						VALUES ('PROMOCIONES', 'TERMINO VIGENCIA', iNumFila, TRIM(cMensaje), pUsuario);
					END IF;
					
					IF NVL(dCapitalmin,'') <> '' AND NVL(dCapitalmax,'') <> '' THEN
						IF dCapitalmin::INTEGER > dCapitalmax::INTEGER THEN
							LET cMensaje = 'EL VALOR INGRESADO EN EL CAMPO CAPITAL MINIMO NO DEBE SER MAYOR AL VALOR INGRESADO EN EL CAMPO CAPITAL MAXIMO';
							LET cErrores = 't';
							LET iBanPromo = 1;
						
							INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
							VALUES ('PROMOCIONES', 'CAPITAL MINIMO', iNumFila, TRIM(cMensaje), pUsuario);
						END IF;
						
						IF dCapitalmax::INTEGER < dCapitalmin::INTEGER THEN
							LET cMensaje = 'EL VALOR INGRESADO EN EL CAMPO CAPITAL MAXIMO NO DEBE SER MENOR AL VALOR INGRESADO EN EL CAMPO CAPITAL MINIMO';
							LET cErrores = 't';
							LET iBanPromo = 1;
						
							INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
							VALUES ('PROMOCIONES', 'CAPITAL MAXIMO', iNumFila, TRIM(cMensaje), pUsuario);
						END IF;
					END IF;
				END FOREACH
	
				IF iContador = 0 THEN
					LET cCodRet = '00017';
					LET cMensaje = 'NO SE ENCONTRARON REGISTROS EN LA HOJA DE PROMOCIONES';
					LET dFechaHoraProceso = CURRENT;
					UPDATE "informix".sw_verificastatus_validarchivotxt 
					SET error_proceso = 'S', error = cCodRet, status = 'E', coderror = cErrores, emergente = pBandera, fecha_hora_fin = dFechaHoraProceso
					WHERE usuario_insert = pUsuario AND producto = pProducto;
					
					RETURN cCodRet, cMensaje, cErrores;
				END IF;
	
				FOREACH
				
					SELECT idcamp,numfila
					INTO iPromocion, iNumFila
					FROM bdicnweb:"informix".sw_admintasascarga_promociones
					WHERE usuario = pUsuario
					AND idcamp IN ( SELECT idcamp 
									FROM bdicnweb:"informix".sw_admintasascarga_promociones
									WHERE usuario = pUsuario 
									GROUP BY idcamp HAVING COUNT(*) > 1)
					ORDER BY numfila
	
					IF iPromocion > 0 OR iPromocion IS NOT NULL THEN 
						
						LET cMensaje = 'EL ID DE PROMOCIÃN ['|| iPromocion ||'] SE ENCUENTRA DUPLICADO';
						LET cErrores = 't';
						INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
						VALUES ('PROMOCIONES', 'ID', iNumFila, TRIM(cMensaje), pUsuario);
					END IF
				
				END FOREACH
	
	
				FOREACH
					SELECT nombre,numfila
					INTO cNombre, iNumFila
					FROM bdicnweb:"informix".sw_admintasascarga_promociones
					WHERE usuario = pUsuario
					AND nombre IN (	SELECT nombre 
									FROM bdicnweb:"informix".sw_admintasascarga_promociones
									WHERE usuario = pUsuario 
									GROUP BY nombre HAVING COUNT(*) > 1)
					ORDER BY numfila
					
					LET cNombre = NVL(cNombre,'');
					
					IF cNombre <> '' THEN 
						
						LET cMensaje = 'EL NOMBRE PROMOCIÃN ['|| TRIM(cNombre) ||'] SE ENCUENTRA DUPLICADO';
						LET cErrores = 't';
						INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
						VALUES ('PROMOCIONES', 'NOMBRE CAMPAÃA', iNumFila, TRIM(cMensaje), pUsuario);
					END IF
				
				END FOREACH
			END IF;

            --*************** VALIDACIONES SUCURSALES*******************************
			IF pBandera = '0' AND (pProducto = '3000' OR pProducto = '1100') AND esNumProm = 't' THEN 
				LET iContador = 0;
				LET iPromocion2 = 0;
				LET iNumFila = 0;
				LET iValido = 0;
	
				FOREACH 
					SELECT idcamp as id, TRIM(sucursal), numfila
					INTO  iPromocion, cSucursal, iNumFila
					FROM bdicnweb:"informix".sw_admintasascarga_sucursales
					WHERE usuario = pUsuario
	
					LET iContador = iContador + 1;
	
					-- VALIDAMOS QUE EL ID EXISTA EN LA HOJA DE PROMOCIONES
					SELECT COUNT(idcamp)
					INTO  iPromocion2
					FROM bdicnweb:"informix".sw_admintasascarga_promociones
					WHERE idcamp = iPromocion
					AND usuario = pUsuario;
					
					LET iPromocion2 = NVL(iPromocion2,0);
					
					IF iPromocion2 = 0 THEN
						IF pProducto = '1100' THEN 
							LET cMensaje = 'EL VALOR INGRESADO EN EL CAMPO ID NO EXISTE, DEBE INGRESAR UN ID QUE CORRESPONDA A UNA CAMPAÃA PROMOCIONAL DE LA HOJA PROMOCIONES';
						ELSE
							LET cMensaje = 'ID DE CAMPAÃA NO ENCONTRADA EN LA HOJA DE PROMOCIONES';
						END IF;
						LET cErrores = 't';
					
						INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
						VALUES ('SUCURSALES', 'ID', iNumFila, TRIM(cMensaje), pUsuario); 
					END IF;
					
					IF pProducto = '1100' THEN 
						IF NVL(cSucursal,'') <> '' THEN 
							IF cSucursal MATCHES "*[0-9]*" THEN
								LET es_numerico = 't';
							ELSE
								LET es_numerico = 'f';
								LET cMensaje = 'EL VALOR INGRESADO NO ES CORRECTO, SOLO SE PERMITE INGRESAR VALORES NUMÃRICOS.';
								LET cErrores = 't';
						
								INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror (nombreHoja, nombreCampo, numerofila, descripcion, usuario)
								VALUES ('SUCURSALES', 'SUCURSAL', iNumFila, TRIM(cMensaje), pUsuario); 
							END IF;
							---
							LET cValorCero = '';
							LET iTotalCeros = 4 - LENGTH(TRIM(cSucursal));
							LET iContadorCeros = 0;
							IF iTotalCeros > 0 THEN 
								LET cValorCero = LPAD(TRIM(cSucursal), 4, 0);
							END IF;
							
							IF NVL(cValorCero,'') <> '' THEN 
								LET cSucursal = cValorCero;
								UPDATE "informix".sw_admintasascarga_sucursales
								SET sucursal = cValorCero
								WHERE usuario = pUsuario AND numfila = iNumFila;
							END IF;
						END IF;
					END IF;
					
					IF LENGTH(TRIM(cSucursal)) > 4 OR LENGTH(TRIM(cSucursal)) < 4 THEN
						LET cMensaje = 'EL VALOR INGRESADO NO ES CORRECTO, LA LONGITUD PERMITIDA DEBE SER DE 4 DÃGITOS';
						LET cErrores = 't';
	
						INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
						VALUES ('SUCURSALES', 'SUCURSAL', iNumFila, TRIM(cMensaje), pUsuario); 
					END IF;
				END FOREACH
	
				FOREACH
					SELECT idcamp
					INTO iPromocion2
					FROM bdicnweb:"informix".sw_admintasascarga_promociones
					WHERE usuario = pUsuario
	
					--Validar que no haya registros duplicados
					FOREACH
						SELECT sucursal, numfila
						INTO cSucursal, iNumFila
						FROM bdicnweb:"informix".sw_admintasascarga_sucursales
						WHERE usuario = pUsuario
						AND idcamp = iPromocion2
						AND sucursal IN (	SELECT sucursal 
											FROM bdicnweb:"informix".sw_admintasascarga_sucursales 
											WHERE usuario = pUsuario AND idcamp = iPromocion2
											GROUP BY sucursal HAVING COUNT(*) > 1)
						ORDER BY numfila
						
						LET cSucursal = NVL(cSucursal,'');
						
						IF cSucursal <> '' THEN 
	
							IF pProducto = '3000' THEN
								LET cMensaje = 'LA SUCURSAL ['|| TRIM(cSucursal) ||'] SE ENCUENTRA DUPLICADO';
							ELSE
								LET cMensaje = 'EL VALOR INGRESADO NO ES CORRECTO, LA SUCURSAL DEBE SER ÃNICA POR CAMPAÃA PROMOCIONAL';
							END IF;
							LET cErrores = 't';
							INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
							VALUES ('SUCURSALES', 'SUCURSAL', iNumFila, TRIM(cMensaje), pUsuario);
						END IF
					END FOREACH
				END FOREACH
			END IF;
            --*************** VALIDACIONES CUENTAS*******************************
			IF esNumProm = 't' THEN 
				LET iContador = 0;
				LET iPromocion2 = 0;
				LET iNumFila = 0;
				
				FOREACH
					SELECT idcamp as id, cuenta, numfila
					INTO  iPromocion, cCuenta, iNumFila
					FROM bdicnweb:"informix".sw_admintasascarga_cuentas
					WHERE usuario = pUsuario
				
					LET iContador = iContador + 1;
					-- VALIDAMOS QUE EL ID EXISTA EN LA HOJA DE PROMOCIONES
					SELECT COUNT(idcamp)
					INTO  iPromocion2
					FROM bdicnweb:"informix".sw_admintasascarga_promociones
					WHERE idcamp = iPromocion
					AND usuario = pUsuario;
					
					LET iPromocion2 = NVL(iPromocion2,0);
					
					IF iPromocion2 = 0 THEN
						LET cMensaje = 'ID DE CAMPAÃA NO ENCONTRADA EN LA HOJA DE PROMOCIONES';
						LET cErrores = 't';
				
						INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
						VALUES ('CUENTAS', 'ID', iNumFila, TRIM(cMensaje), pUsuario); 
					END IF;
					
					IF pBandera = '1' THEN --SI ES EMERGENTE
						IF NVL (iPromocion,'') = '' THEN
							LET cMensaje = 'EL CAMPO [ID] SE ENCUENTRA VACÃO/SIN INFORMACIÃN';
							LET cErrores = 't';
							INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror (nombreHoja, nombreCampo, numerofila, descripcion, usuario)
							VALUES ('CUENTAS', '# CUENTA', iNumFila, TRIM(cMensaje), pUsuario); 
						END IF;
						
						IF NVL (cCuenta,'') = '' THEN
							LET cMensaje = 'EL CAMPO [# CUENTA] SE ENCUENTRA VACÃO/SIN INFORMACIÃN';
							LET cErrores = 't';
							INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror (nombreHoja, nombreCampo, numerofila, descripcion, usuario)
							VALUES ('CUENTAS', '# CUENTA', iNumFila, TRIM(cMensaje), pUsuario); 
						END IF;
						
					END IF;
					
					IF cCuenta MATCHES "*[0-9]*" THEN
						LET es_numerico = 't';
					ELSE
						LET es_numerico = 'f';
						LET cMensaje = 'EL VALOR INGRESADO NO ES CORRECTO, SOLO SE PERMITE INGRESAR VALORES NUMÃRICOS.';
						LET cErrores = 't';
						INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror (nombreHoja, nombreCampo, numerofila, descripcion, usuario)
						VALUES ('CUENTAS', '# CUENTA', iNumFila, TRIM(cMensaje), pUsuario); 
					END IF;
						
					IF LENGTH(TRIM(cCuenta)) > 11 OR LENGTH(TRIM(cCuenta)) < 11 THEN
						LET cMensaje = 'EL VALOR INGRESADO NO ES CORRECTO, LA LONGITUD PERMITIDA DEBE SER DE 11 DÃGITOS';
						LET cErrores = 't';
				
						INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror (nombreHoja, nombreCampo, numerofila, descripcion, usuario)
						VALUES ('CUENTAS', '# CUENTA', iNumFila, TRIM(cMensaje), pUsuario); 
					END IF;
				END FOREACH
				
				IF iContador = 0 THEN
					LET iBanCuenta = 0;
				ELIF iContador > 0 THEN
					LET iBanCuenta = 1;
				END IF;
				
				FOREACH
					SELECT idcamp
					INTO iPromocion2
					FROM bdicnweb:"informix".sw_admintasascarga_promociones
					WHERE usuario = pUsuario
					
					--Validar que no haya registros duplicados
					FOREACH
				
						SELECT cuenta, numfila
						INTO cCuenta, iNumFila
						FROM bdicnweb:"informix".sw_admintasascarga_cuentas
						WHERE usuario = pUsuario
						AND idcamp = iPromocion2
						AND cuenta IN (	SELECT cuenta 
										FROM bdicnweb:"informix".sw_admintasascarga_cuentas 
										WHERE usuario = pUsuario AND idcamp = iPromocion2
										GROUP BY cuenta HAVING COUNT(*) > 1)
						ORDER BY numfila
						
						LET cCuenta = NVL(cCuenta,''); 
						
						IF cCuenta <> '' THEN 
				
							LET cMensaje = 'LA CUENTA ['|| TRIM(cCuenta) ||'] SE ENCUENTRA DUPLICADO';
							LET cErrores = 't';
							INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
							VALUES ('CUENTAS', '# CUENTA', iNumFila, TRIM(cMensaje), pUsuario);
						END IF
				
					END FOREACH
				END FOREACH
            END IF;
            --*************** VALIDACIONES RENOVACIONES *******************************
			IF esNumProm = 't' THEN
				LET iContador = 0;
				LET iPromocion2 = 0;
				LET iNumFila = 0;
	
				FOREACH
					SELECT idcamp as id, renovacion, numfila
					INTO  iPromocion, iRenovacion, iNumFila
					FROM bdicnweb:"informix".sw_admintasascarga_renovaciones
					WHERE usuario = pUsuario
	
					LET iContador = iContador + 1;
					
					-- VALIDAMOS QUE EL ID EXISTA EN LA HOJA DE PROMOCIONES
					SELECT COUNT(idcamp)
					INTO  iPromocion2
					FROM bdicnweb:"informix".sw_admintasascarga_promociones
					WHERE idcamp = iPromocion
					AND usuario = pUsuario;
					
					LET iPromocion2 = NVL(iPromocion2,0);
					
					IF iPromocion2 = 0 THEN
						LET cMensaje = 'ID DE CAMPAÃA NO ENCONTRADA EN LA HOJA DE PROMOCIONES';
						LET cErrores = 't';
	
						INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
						VALUES ('RENOVACIONES', 'ID', iNumFila, TRIM(cMensaje), pUsuario); 
					END IF;
					
					IF iRenovacion NOT IN (1,2,3) THEN
						LET cMensaje = 'EL VALOR INGRESADO NO ES CORRECTO, SOLO SE PERMITE INGRESAR VALORES NUMÃRICOS DEL 1 AL 3';
						LET cErrores = 't';
	
						INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
						VALUES ('RENOVACIONES', '# RENOVACIÃN', iNumFila, TRIM(cMensaje), pUsuario); 
					END IF;
	
	
				END FOREACH
	
				LET iPromocion2 = 0;
				LET iNumFila = 0;
				-- SI EXISTEN RENOVACIONES, CONTINUA
				IF iContador > 0 THEN
					FOREACH
		
						SELECT idcamp
						INTO iPromocion
						FROM bdicnweb:"informix".sw_admintasascarga_promociones
						WHERE usuario = pUsuario
		
						--VALIDACION DE SECUENCIAS:
						IF  (SELECT COUNT(idcamp) FROM bdicnweb:"informix".sw_admintasascarga_renovaciones WHERE usuario = pUsuario AND idcamp = iPromocion) > 3 OR 
							(SELECT COUNT(idcamp) FROM bdicnweb:"informix".sw_admintasascarga_renovaciones WHERE usuario = pUsuario AND idcamp = iPromocion) < 3 THEN
							IF pBandera = '1' THEN -- ES EMERGENTE
								LET cMensaje = 'NO SE PERMITE INGRESAR MÃS DE 3 SECUENCIAS';
							ELSE 
								LET cMensaje = 'EL NÃMERO DE SECUENCIAS DE LA RENOVACIÃN CON ID ['|| TO_CHAR(iPromocion)||'] NO ES CORRECTO, SOLO SE PERMITE INGRESAR 3 SECUENCIAS POR RENOVACION';
							END IF;
							LET cErrores = 't';
		
							INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
							VALUES ('RENOVACIONES', '# RENOVACIÃN', iNumFila, TRIM(cMensaje), pUsuario); 
		
						END IF;
						
						FOREACH
							--VALIDACIÃN DE QUE NO HAYA RENOVACIONES DUPLICADAS
							SELECT renovacion, numfila
							INTO iPromocion2, iNumFila
							FROM bdicnweb:"informix".sw_admintasascarga_renovaciones
							WHERE usuario = pUsuario AND idcamp = iPromocion
							AND iPromocion2 IN (	SELECT renovacion 
													FROM bdicnweb:"informix".sw_admintasascarga_renovaciones
													WHERE usuario = pUsuario AND idcamp = iPromocion
													GROUP BY renovacion
													HAVING COUNT(*) > 1 )
							ORDER BY numfila
								
							IF NVL(iPromocion2,0) > 0 THEN
									IF pBandera = '1' THEN 
										LET cMensaje = 'EL VALOR INGRESADO NO ES CORRECTO, NO SE DEBE REPETIR EL NÃMERO DE RENOVACIÃN';
									ELSE
										LET cMensaje = 'EL VALOR INGRESADO EN LA RENOVACIÃN CON ID ['|| iPromocion ||'] NO ES CORRECTO, NO SE DEBE REPETIR EL NÃMERO DE RENOVACIÃN';
									END IF;
								
								LET cErrores = 't';
				
								INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
								VALUES ('RENOVACIONES', '# RENOVACIÃN', iNumFila, TRIM(cMensaje), pUsuario); 
							END IF;
						END FOREACH
					END FOREACH
				END IF;
	
				LET iPromocion2 = 0;
				LET iNumFila = 0;
	
				IF iBanCuenta = 1 AND iContador > 0 THEN
		
					-- VALIDAMOS QUE EN LOS IDS DE CUENTAS TAMBIEN EXISTAN EN RENOVACIONES
					FOREACH
						SELECT idcamp
						INTO iPromocion
						FROM bdicnweb:"informix".sw_admintasascarga_cuentas
						WHERE usuario = pUsuario
						GROUP BY idcamp
						
	
						FOREACH
							SELECT COUNT(idcamp)
							INTO  iPromocion2
							FROM bdicnweb:"informix".sw_admintasascarga_renovaciones
							WHERE idcamp = iPromocion
							AND usuario = pUsuario
							
							LET iPromocion2 = NVL(iPromocion2,0);
							IF iPromocion2 = 0  THEN
								LET cMensaje = 'LA RENOVACIÃN ASOCIADA A LA CAMPAÃA [' || iPromocion || '] NO SE ENCUENTRA EN LA HOJA DE RENOVACIONES';
								LET cErrores = 't';
	
								INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
								VALUES ('RENOVACIONES', 'ID', 0, TRIM(cMensaje), pUsuario); 
							END IF;
	
						END FOREACH 
					END FOREACH
				END IF;
	
				/*IF iBanCuenta = 0 AND iContador > 0 THEN
	
					-- VALIDAMOS QUE EN LOS IDS DE RENOVACIONES TAMBIEN EXISTAN EN RENOVACIONES
					FOREACH
						SELECT idcamp
						INTO iPromocion
						FROM bdicnweb:"informix".sw_admintasascarga_renovaciones
						WHERE usuario = pUsuario
						GROUP BY idcamp
	
						FOREACH
							SELECT COUNT(idcamp)
							INTO  iPromocion2
							FROM bdicnweb:"informix".sw_admintasascarga_cuentas
							WHERE idcamp = iPromocion
							AND usuario = pUsuario
	
	
							IF iPromocion2 = 0 AND iPromocion IS NOT NULL THEN
								LET cMensaje = 'LA CUENTA ASOCIADA A LA CAMPAÃA [' || iPromocion || '] NO SE ENCUENTRA EN LA HOJA DE CUENTAS PARA APLICAR UNA RENOVACIÃN';
								LET cErrores = 't';
	
								INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
								VALUES ('RENOVACIONES', 'ID', 0, TRIM(cMensaje), pUsuario); 
							END IF;
	
						END FOREACH 
					END FOREACH
				END IF;*/
				
				--SI EXISTEN CUENTAS PERO NO RENOVACIONES SE NOTIFICA EL ERROR
				IF iBanCuenta = 1 AND iContador = 0 THEN
					LET cMensaje = 'NO EXISTE INFORMACIÃN EN LA HOJA DE âRENOVACIONESâ, FAVOR DE REVISAR, ES NECESARIO PARA QUE SEA UNA CAMPAÃA PROMOCIONAL VALIDA';
					LET cErrores = 't';
	
					INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
					VALUES ('RENOVACIONES', '# RENOVACIÃN', iNumFila, TRIM(cMensaje), pUsuario); 
				END IF;
	
				LET iPromocion2 = 0;
				LET iNumFila = 0;
	
				/*FOREACH
					SELECT idcamp
					INTO iPromocion2
					FROM bdicnweb:"informix".sw_admintasascarga_promociones
					WHERE usuario = pUsuario
					group by idcamp
					order by idcamp
	
					--Validar que no haya registros duplicados
					FOREACH
	
						SELECT tasa, numfila
						INTO cTasaReno, iNumFila
						FROM bdicnweb:"informix".sw_admintasascarga_renovaciones
						WHERE usuario = pUsuario
						AND idcamp = iPromocion2
						AND tasa IN (	SELECT tasa 
										FROM bdicnweb:"informix".sw_admintasascarga_renovaciones
										WHERE usuario = pUsuario AND idcamp = iPromocion2
										GROUP BY tasa HAVING COUNT(*) > 1)
						ORDER BY numfila
						
						LET cTasaReno = NVL(cTasaReno,'');
	
						IF cTasaReno <> '' THEN 
	
							LET cMensaje = 'LA TASA DE RENOVACION ['|| TRIM(cTasaReno) ||'] SE ENCUENTRA DUPLICADO';
							LET cErrores = 't';
							INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
							VALUES ('RENOVACIONES', 'TASA', iNumFila, TRIM(cMensaje), pUsuario);
						END IF
	
					END FOREACH
				END FOREACH*/
			END IF;
			
            --*************** VALIDACIONES CLIENTE *******************************
			IF esNumProm = 't' THEN 
				LET iContador = 0;
				LET iPromocion2 = 0;
				LET iNumFila = 0;
	
				FOREACH
					SELECT idcamp as id, cliente, numfila
					INTO  iPromocion, cNumcte, iNumFila
					FROM bdicnweb:"informix".sw_admintasascarga_clientes
					WHERE usuario = pUsuario
					
					IF NVL(cNumcte,'') <> '' AND LENGTH(TRIM(cNumcte)) < 7 THEN
						LET iTotalCeros = 9 - LENGTH(TRIM(cNumcte));
						LET iContadorCeros = 1;
						LET cValorCero = '';
						IF iTotalCeros > 0 THEN 
							LET cValorCero = LPAD(TRIM(cNumcte), 9, 0);
						END IF;
						
						IF NVL(cValorCero,'') <> '' THEN 
							UPDATE bdicnweb:"informix".sw_admintasascarga_clientes
							SET cliente = cValorCero 
							WHERE usuario = pUsuario AND numfila = iNumFila;
						END IF;
					END IF;
					
					LET iContador = iContador + 1;
					-- VALIDAMOS QUE EL ID EXISTA EN LA HOJA DE PROMOCIONES
					SELECT count(idcamp)
					INTO  iPromocion2
					FROM bdicnweb:"informix".sw_admintasascarga_promociones
					WHERE idcamp = iPromocion
					AND usuario = pUsuario;
	
					IF NVL(iPromocion2,0) = 0 THEN
						IF pProducto = '1100' THEN 		
						LET cMensaje = 'EL VALOR INGRESADO EN EL CAMPO ID NO EXISTE, DEBE INGRESAR UN ID QUE CORRESPONDA A UNA CAMPAÃA PROMOCIONAL DE LA HOJA PROMOCIONES';	ELSE		LET cMensaje = 'ID DE CAMPAÃA NO ENCONTRADA EN LA HOJA DE PROMOCIONES';	END IF;
						LET cErrores = 't';
	
						INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
						VALUES ('CLIENTES', 'ID', iNumFila, TRIM(cMensaje), pUsuario); 
					END IF;
	
					
					IF cNumcte MATCHES "*[0-9]*" THEN
						LET es_numerico = 't';
					ELSE
						LET es_numerico = 'f';
						LET cMensaje = 'EL VALOR INGRESADO NO ES CORRECTO, SOLO SE PERMITE INGRESAR VALORES NUMÃRICOS.';
						LET cErrores = 't';
		
						INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror (nombreHoja, nombreCampo, numerofila, descripcion, usuario)
						VALUES ('CLIENTES', '# CLIENTE', iNumFila, TRIM(cMensaje), pUsuario); 
					END IF;
					
					IF LENGTH(TRIM(cNumcte)) > 9 OR LENGTH(TRIM(cNumcte)) < 9 THEN
	
						LET cMensaje = 'EL VALOR INGRESADO NO ES CORRECTO, LA LONGITUD PERMITIDA DEBE SER DE 9 DIGITOS';
						LET cErrores = 't';
	
						INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
						VALUES ('CLIENTES', '# CLIENTE', iNumFila, TRIM(cMensaje), pUsuario); 					
					END IF;
				END FOREACH
	
				FOREACH
					SELECT idcamp
					INTO iPromocion2
					FROM bdicnweb:"informix".sw_admintasascarga_promociones
					WHERE usuario = pUsuario
					GROUP BY idcamp
					ORDER BY idcamp
	
					--Validar que no haya registros duplicados
					FOREACH
						SELECT cliente, numfila
						INTO cNumcte, iNumFila
						FROM bdicnweb:"informix".sw_admintasascarga_clientes
						WHERE usuario = pUsuario
						AND idcamp = iPromocion2
						AND cliente IN ( SELECT cliente 
										FROM bdicnweb:"informix".sw_admintasascarga_clientes
										WHERE usuario = pUsuario AND idcamp = iPromocion2
										GROUP BY cliente HAVING COUNT(*) > 1)
						ORDER BY numfila
						
						LET cNumcte = NVL(cNumcte,'');
						
						IF cNumcte <> '' THEN 
	
							LET cMensaje = 'EL CLIENTE ['|| TRIM(cNumcte) ||'] SE ENCUENTRA DUPLICADO';
							LET cErrores = 't';
							INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
							VALUES ('CLIENTES', '# CLIENTE', iNumFila, TRIM(cMensaje), pUsuario);
						END IF
	
					END FOREACH
				END FOREACH
			END IF;
			--*************** VALIDACIONES TASAS *******************************
			IF pProducto = '1100' AND esNumProm = 't' THEN 
				LET iContador = 0;
				LET iPromocion2 = 0;
				LET iNumFila = 0;
				FOREACH
					SELECT idcamp as id, mes, tasa, numfila
					INTO  cPromocionTasa, cMes, cTasa, iNumFila
					FROM bdicnweb:"informix".sw_admintasascarga_tasas
					WHERE usuario = pUsuario 
					
					LET iContador = iContador + 1;
					
					LET esNumProm = 't';
					IF NVL(cMes, '') = '' THEN
						LET cMensaje = 'EL VALOR DEL MES INGRESADO POR CAMPAÃA NO ES CORRECTO, DEBE DE INGRESAR 13 MESES POR CAMPAÃA';
                        LET cErrores = 't';
                        INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
                        VALUES ('TASAS', 'MES', iNumFila, TRIM(cMensaje), pUsuario);
						LET esNumProm = 'f';
					ELSE 
						EXECUTE PROCEDURE bdicnweb:"informix".sp_validaEnteros(cMes) INTO isDecimal;
						IF isDecimal = 'f' THEN
							LET esNumProm = 'f';
							LET cMensaje = 'EL VALOR DEL CAMPO [MES] NO ES CORRECTO, SOLO SE PERMITEN VALORES NUMÃRICOS.';
							LET cErrores = 't';
							INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror (nombreHoja, nombreCampo, numerofila, descripcion, usuario)
							VALUES ('TASAS', 'MES', iNumFila, TRIM(cMensaje), pUsuario); 
						END IF;
					END IF;
					
					EXECUTE PROCEDURE bdicnweb:"informix".sp_validaEnteros(cPromocionTasa) INTO isDecimal;
					IF isDecimal = 'f' THEN
						LET esNumProm = 'f';
						LET cMensaje = 'EL VALOR DEL CAMPO [ID] NO ES CORRECTO, SOLO SE PERMITEN VALORES NUMÃRICOS.';
						LET cErrores = 't';
						INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror (nombreHoja, nombreCampo, numerofila, descripcion, usuario)
						VALUES ('TASAS', 'ID', iNumFila, TRIM(cMensaje), pUsuario); 
					ELSE	
						LET iPromocion = cPromocionTasa::INTEGER;
					END IF;
					
					EXECUTE PROCEDURE sp_validaDecimales (cTasa, pProducto, '') INTO isDecimal;
					IF isDecimal = 't' THEN
						LET es_numerico = 't';
						LET dTasa = cTasa;
					ELSE
						LET es_numerico = 'f';
						LET cMensaje = 'EL VALOR DE LA TASA INGRESADO NO ES CORRECTO, SOLO SE PERMITEN VALORES NUMÃRICOS ENTEROS O DECIMALES.';
						LET cErrores = 't';
						INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror (nombreHoja, nombreCampo, numerofila, descripcion, usuario)
						VALUES ('TASAS', 'TASA', iNumFila, TRIM(cMensaje), pUsuario); 
					END IF;
					
					IF es_numerico = 't' AND dTasa > (SELECT MAX(valor) FROM bdinteg:si_tasavlor  WHERE tasa = 'EJEMP') THEN
						LET cMensaje = 'EL VALOR DE LA TASA INGRESADO ES SUPERIOR A LA TASA DE REFERENCIA CETES';
						IF cErrores = 'f' THEN
							LET cErrores = 'v';
						END IF;
						INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
						VALUES ('TASAS', 'TASA', iNumFila, cMensaje, pUsuario);
					END IF;
					IF esNumProm = 't' THEN 
						SELECT COUNT(idcamp)
						INTO  iPromocion2
						FROM bdicnweb:"informix".sw_admintasascarga_promociones
						WHERE idcamp = iPromocion
						AND usuario = pUsuario;
							
						IF NVL(iPromocion2,0) = 0 THEN
							LET cMensaje = 'EL VALOR INGRESADO EN EL CAMPO ID NO EXISTE, DEBE INGRESAR UN ID QUE CORRESPONDA A UNA CAMPAÃA PROMOCIONAL DE LA HOJA PROMOCIONES';
							LET cErrores = 't';
		
							INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
							VALUES ('TASAS', 'ID', iNumFila, TRIM(cMensaje), pUsuario); 
						END IF;
					END IF;
					
				END FOREACH;
				
				IF esNumProm = 't' THEN 
					FOREACH
						SELECT idcamp as id
						INTO  iPromocion
						FROM bdicnweb:"informix".sw_admintasascarga_promociones
						WHERE usuario = pUsuario 
						
						SELECT COUNT(idcamp) 
						INTO iPromocion2
						FROM bdicnweb:"informix".sw_admintasascarga_tasas
						WHERE usuario = pUsuario
						AND idcamp = iPromocion;
						
						IF iPromocion2 > 13 OR iPromocion2 < 13 THEN 
							LET cMensaje = 'EL VALOR MES INGRESADO POR CAMPAÃA NO ES CORRECTO, DEBE INGRESAR 13 MESES POR CAMPAÃA';
							LET cErrores = 't';
							INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
							VALUES ('TASAS', 'MES', iNumFila, TRIM(cMensaje), pUsuario);
						END IF;
						
						FOREACH
							SELECT mes,numfila
							INTO cMes, iNumFila
							FROM bdicnweb:"informix".sw_admintasascarga_tasas
							WHERE usuario = pUsuario
							AND idcamp = iPromocion
							AND mes IN (	SELECT mes 
											FROM bdicnweb:"informix".sw_admintasascarga_tasas
											WHERE usuario = pUsuario  AND idcamp =  iPromocion 
											GROUP BY mes HAVING COUNT(*) > 1)
							ORDER BY numfila
		
							IF NVL(cMes,'') <> '' THEN
								LET cMensaje = 'EL VALOR DEL MES INGRESADO SE ENCUENTRA REPETIDO, DEBE INGRESAR VALORES DEL 1 AL 13';
								LET cErrores = 't';
								INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
								VALUES ('TASAS', 'MES', iNumFila, TRIM(cMensaje), pUsuario);
							END IF
		
						END FOREACH
					END FOREACH
				END IF;
			END IF;
			LET dFechaHoraProceso = CURRENT;
            IF cErrores = 'f' THEN
                --Si no hubo errores lo registramos en la bitacora
                INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto)
                VALUES (TODAY, CURRENT, pUsuario, 'CARGA DE CAMPAÃAS', 1, "SE HA REALIZADO LA CARGA DE ARCHIVO", 3000);
				UPDATE "informix".sw_verificastatus_validarchivotxt 
				SET error_proceso = 'S', error = cCodRet, status = 'T', coderror = cErrores, emergente = pBandera, fecha_hora_fin = CURRENT
				WHERE usuario_insert = pUsuario AND producto = pProducto;
            ELSE
				UPDATE "informix".sw_verificastatus_validarchivotxt 
				SET error_proceso = 'N', error = cCodRet, status = 'T', coderror = cErrores, emergente = pBandera, fecha_hora_fin = CURRENT
				WHERE usuario_insert = pUsuario AND producto = pProducto;
                LET cMensaje = 'EJECUCIÃN FINALIZADA CON ERRORES REVISE LA MODAL DE ERRORES';
            END IF;
  
            RETURN cCodRet, cMensaje, cErrores;
    END
END PROCEDURE
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 28/09/2024',
'MODULO: DEBITO',
'FUNCIONALIDAD: CARGA DE CAMPAÃAS',
'DESCRIPCION: Procedimiento almacenado encargado de validar la informaciÃ³n del excel convertida en un archivo txt y realizar las validaciones',
'para las hojas de PROMOCIONES, SUCURSALES, CUENTAS, CLIENTES Y RENOVACIONES cada error encontrado durante el flujo se almacena en la bitacorra de errores',
'si no se encuentran errores el sp retornara en el campo errores = f de caso contrario sera t o sÃ­ el campo es errores = v significa que fue correcto pero la tasa es superior a la tasa de referencia CETES.',
'FECHA: 02/04/2025',
'AUTOR: Carlos Alberto Macias',
'MODIFICACION: Se realiza la sustituciÃ³n del LOAD por el DBLOAD, mediante la creaciÃ³n y ejecuciÃ³n un shell',
'AUTOR: Veronica Sanchez',
'FECHA: 09/03/2025',
'DESCRIPCION: Se agregan validaciones para el producto 1100 y para la hoja de TASAS',
'AUTOR: Veronica Sanchez',
'FECHA: 07/07/2025',
'DESCRIPCION: Se agregan el llamado a la tabla bdicnweb:"informix".sw_verificastatus_validarchivotxt para tratamiento de volumentria.',
'AUTOR: Veronica Sanchez',
'FECHA: 25/07/2025',
'DESCRIPCION: Se modifica procedimiento almacenado para colocar tablas de paso y ajustar consultas y logica de validacion: ',
'bdicnweb:"informix".sw_admintasascarga_promociones - HOJA PROMOCIONES', 
'bdicnweb:"informix".sw_admintasascarga_tasas - HOJA TASAS ', 
'bdicnweb:"informix".sw_admintasascarga_sucursales - HOJA SUCURSALES ', 
'bdicnweb:"informix".sw_admintasascarga_clientes - HOJA CLIENTES ',
'bdicnweb:"informix".sw_admintasascarga_cuentas - HOJAS CUENTAS ',
'bdicnweb:"informix".sw_admintasascarga_renovaciones - HOJA RENOVACIONES',
'AUTOR: Veronica Sanchez',
'FECHA: 25/07/2025',
'DESCRIPCION: Se modifica procedimiento almacenado para aplicar validacion del campo promocio cuando no es un numerico y no afectar el resto de consultas',
'AUTOR: Veronica Sanchez',
'FECHA: 01/12/2025',
'DESCRIPCION: Se modifica procedimiento almacenado para agregar nuevas validaciones para la opcion del procducto 3000',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_adminitasas_ope_guardainfo(pUsuario CHAR(9), pIdFuncion CHAR(8), pBandera CHAR(1), pErrores CHAR(1), pProducto CHAR(4),
pRegistros INTEGER, pRecuperacion INTEGER)
RETURNING CHAR(5)       AS codret,-- 0
          INTEGER       AS id_promocion,-- 1
          CHAR(100)     AS nombre_estrategia,--2
          CHAR(10)      AS canal,--3
          INTEGER       AS plazo_inicio,--4
          INTEGER       AS plazo_vencimiento, --5
          MONEY(14,2)   AS capital_min,    --6
          MONEY(14,2)   AS capital_max,-- 7
          DATE          AS fecha_inicio,--8
          DATE          AS fecha_vencimiento,--9
          DECIMAL(9,6)  AS tasa,--10
          DECIMAL(9,6)  AS gat_nominal,--11
          DECIMAL(9,6)  AS gat_real,--12
          CHAR(4)       AS num_sucursal,--13 (pertenece a la hoja de sucursal)
          CHAR(20)      AS num_cuenta,--14 (pertenece a la hoja de sucursal)
          CHAR(20)      AS num_cte,--14 (pertenece a la hoja de clientes)
          SMALLINT      AS secuencia,--16 (consecutivo de los registros)
          DECIMAL(9,6)  AS tasa_renovacion,--17
		  CHAR(2)		AS reqSdoNuevo,-- NUEVO--18
		  DECIMAL(18,2)	AS montoSdoNuevo, -- NUEVO--19
		  CHAR(2)		AS reqInstrApertura, -- NUEVO--20
		  CHAR(50)		AS instApertura, -- NUEVO-- 21
		  CHAR(2)		AS reqParCteNuevo, -- NUEVO--22
		  INTEGER		AS diasVigenciaCteNuevo; -- NUEVO--23



    
    DEFINE cCodRet              CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iRegistro            INTEGER;
    DEFINE iIdpromocion         INTEGER;
    DEFINE iPromocionfinal      INTEGER;
    DEFINE cNombreEstrategia    CHAR(100); 
    DEFINE cCanal               CHAR(10);
    DEFINE dCapitalmin          MONEY(14,2);
    DEFINE dCapitalmax          MONEY(14,2);
    DEFINE iplazoInicio         INTEGER;
    DEFINE iplazoVencimiento    INTEGER;
    DEFINE dFechaInicio         DATE;
    DEFINE dFechaVencimiento    DATE;
    DEFINE dTasa                DECIMAL(9,6);
    DEFINE dGatNominal          DECIMAL(9,6);
	DEFINE dGatReal             DECIMAL(9,6);
    DEFINE iCodEstatus          SMALLINT;
    DEFINE cSucursal            CHAR(4);
    DEFINE cNumCuenta           CHAR(20);
    DEFINE cNumcte              CHAR(20);
    DEFINE iSecuencia           SMALLINT;
    DEFINE dTasaRenovacion      DECIMAL(9,6);
    DEFINE iContador            INTEGER;
    DEFINE cCodRet2             CHAR(5);
    DEFINE iCodRetSp            INTEGER;
	--NUEVO
	DEFINE cRequiereSdoNuevo	CHAR(2);
	DEFINE dMontoSdoNuevo		DECIMAL(18,2);
	DEFINE cRequiereInstrApertura	CHAR(2);
	DEFINE cInstrumentoApertura	CHAR(50);
	DEFINE cParCteNuevo			CHAR(2);
	DEFINE iDiasVigenciaCteNuevo	INTEGER;
	DEFINE cInstrumentoVenCap		CHAR(2);
	DEFINE cInstrumentoVenInt		CHAR(2);

    LET cCodRet          = '00000';
    LET iSqlErr          = 0;
    LET iRegistro        = 0;
    LET iIdpromocion     = '';
    LET cNombreEstrategia = '';
    LET cCanal           = '';
    LET dCapitalmin      = '';
    LET dCapitalmax      = '';
    LET iplazoInicio     = 0;
    LET iplazoVencimiento = 0;
    LET dFechaInicio     = '';
    LET dFechaVencimiento = '';
    LET dTasa            = '';
    LET dGatNominal      = '';
	LET dGatReal         = '';
    LET iCodEstatus      = '';
    LET cSucursal        = '';
    LET cNumCuenta       = '';
    LET cNumcte          = '';
    LET iSecuencia       = NULL;
    LET dTasaRenovacion  = NULL;
    LET cCodRet2         = '00000';
    LET iContador        = 0;
    LET iCodRetSp        = NULL;
    LET iPromocionfinal  = 0;
	--NUEVO
	LET cRequiereSdoNuevo	= '';
	LET dMontoSdoNuevo	= 0;
	LET cRequiereInstrApertura	= '';
	LET cInstrumentoApertura	= '';
	LET cParCteNuevo	= '';
	LET iDiasVigenciaCteNuevo	= 0;
	LET cInstrumentoVenCap = '';
    LET cInstrumentoVenInt = '';
    BEGIN
     
        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, cSucursal, cNumCuenta, cNumcte, iSecuencia, dTasaRenovacion,
			cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo;
		END EXCEPTION;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/admintasas/sp_adminitasas_ope_guardainfo.out';
        --TRACE ON;

        IF pUsuario = '' OR pIdFuncion = '' OR pBandera = '' OR pErrores = '' OR pErrores NOT IN ('f', 't', 'v') AND pProducto = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, cSucursal, cNumCuenta, cNumcte, iSecuencia, dTasaRenovacion,
			cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, cSucursal, cNumCuenta, cNumcte, iSecuencia, dTasaRenovacion,
			cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, cSucursal, cNumCuenta, cNumcte, iSecuencia, dTasaRenovacion,
			cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo;
		END IF;

        IF pErrores = 'f' OR pErrores = 'v' THEN
            --CONSULTAMOS LA PAGINA DE PROMOCIONES
            IF pBandera = 1 THEN
                
                IF pProducto = '3000' THEN 
					FOREACH
						SELECT idcamp, nombre, canal, tasa, capital_min, capital_max, plazo_min, plazo_max, TO_DATE(TRIM(fecha_inicio),"%d-%m-%Y"), TO_DATE(TRIM(fecha_fin),"%d-%m-%Y"),
						requiere_sdo_nuevo, monto_saldo_nuevo, requiere_instruccion_apertura, instrumento_ven, para_cte_nuevo, dias_vigenciacte_nuevo
						INTO iIdpromocion, cNombreEstrategia, cCanal, dTasa, dCapitalmin, dCapitalmax, iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento,
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo
						FROM "informix".sw_admintasascarga_promociones
						WHERE usuario = pUsuario
					
						--Calculamos la gat nominal y real
						EXECUTE PROCEDURE bdinvers:sp_calculagat_promocion(dTasa, '3000', iplazoInicio,0,0)
						INTO cCodRet2, dGatNominal, dGatReal;
						
						LET iCodRetSp = cCodRet2::INTEGER;
						IF iCodRetSp < 0 THEN
							RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdinvers:sp_calculagat_promocion";
						ELIF iCodRetSp = 1 THEN
							LET cCodRet = '01284'; -- NO EXISTE MEDIANA DE INFLACIï¿½N
							RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, cSucursal, cNumCuenta, cNumcte, iSecuencia, dTasaRenovacion,
							cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo;
						END IF;
						
						LET iContador = iContador + 1;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, cSucursal, cNumCuenta, cNumcte, iSecuencia, dTasaRenovacion,
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo						WITH RESUME;
                   
					END FOREACH
				ELSE
					FOREACH
						SELECT idcamp, nombre, canal, tasa, capital_min, TO_DATE(TRIM(capital_max),"%d-%m-%Y"), TO_DATE(TRIM(plazo_min),"%d-%m-%Y")
						INTO iIdpromocion, cNombreEstrategia, cCanal, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento
						FROM "informix".sw_admintasascarga_promociones
						WHERE usuario = pUsuario
						
						LET iCodRetSp = cCodRet2::INTEGER;
						IF iCodRetSp < 0 THEN
							RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdinvers:sp_calculagat_promocion";
						ELIF iCodRetSp = 1 THEN
							LET cCodRet = '01284'; -- NO EXISTE MEDIANA DE INFLACIï¿½N
							RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, cSucursal, cNumCuenta, cNumcte, iSecuencia, dTasaRenovacion,
							cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo;
						END IF;
						
						LET iContador = iContador + 1;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, cSucursal, cNumCuenta, cNumcte, iSecuencia, dTasaRenovacion,
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                   
					END FOREACH
				END IF;
                   
            --CONSULTAMOS LA PAGINA DE SUCURSALES
            ELIF pBandera = 2 THEN
                FOREACH
                SELECT SKIP pRegistros FIRST pRecuperacion idcamp as id, sucursal
                    INTO  iIdpromocion, cSucursal
                    FROM "informix".sw_admintasascarga_sucursales
                    WHERE usuario = pUsuario

                    LET iContador = iContador + 1;

                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, cSucursal, cNumCuenta, cNumcte, iSecuencia, dTasaRenovacion,
					cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH

            --CONSULTAMOS LA PAGINA DE CUENTAS
            ELIF pBandera = 3 THEN

                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion idcamp as id, cuenta
                    INTO  iIdpromocion, cNumCuenta
                    FROM "informix".sw_admintasascarga_cuentas
                    WHERE usuario = pUsuario

                    LET iContador = iContador + 1;

                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, cSucursal, cNumCuenta, cNumcte, iSecuencia, dTasaRenovacion,
					cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                
                END FOREACH

            --CONSULTAMOS LA PAGINA DE CLIENTES
            ELIF pBandera = 4 THEN
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion idcamp as id, cliente
                    INTO  iIdpromocion, cNumcte
                    FROM "informix".sw_admintasascarga_clientes
                    WHERE usuario = pUsuario
					ORDER BY cliente
                    
                    LET iContador = iContador + 1;

                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, cSucursal, cNumCuenta, cNumcte, iSecuencia, dTasaRenovacion,
					cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH

            --CONSULTAMOS LA PAGINA DE RENOVACIONES
            ELIF pBandera = 5 THEN
                FOREACH
                    SELECT idcamp as id, renovacion, tasa
                    INTO  iIdpromocion,iSecuencia, dTasaRenovacion
                    FROM "informix".sw_admintasascarga_renovaciones
                    WHERE usuario = pUsuario

                    LET iContador = iContador + 1;
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, cSucursal, cNumCuenta, cNumcte, iSecuencia, dTasaRenovacion,
					cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH
            
            --CONSULTAMOS LA PAGINA DE TASAS
            ELIF pBandera = 6 THEN
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion idcamp as id, mes, tasa
                    INTO  iIdpromocion,iSecuencia, dTasa
                    FROM "informix".sw_admintasascarga_tasas
                    WHERE usuario = pUsuario
					
					--Calculamos la gat nominal y real
					EXECUTE PROCEDURE bdinvers:sp_calculagat_promocion(dTasa, pProducto, 0,iSecuencia,0)
					INTO cCodRet2, dGatNominal, dGatReal;

                    LET iContador = iContador + 1;
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, cSucursal, cNumCuenta, cNumcte, iSecuencia, dTasaRenovacion,
					cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH
            --BANDERA PARA GUARDAR LA INFORMACIï¿½N DE PASO EN LAS TABLAS FINALES
            ELIF pBandera = 7 THEN
                --Validamos que existan promociones
                IF EXISTS (SELECT 1 FROM "informix".sw_admintasascarga_promociones WHERE usuario = pUsuario) THEN
                    IF pProducto = '3000' THEN
						FOREACH
							SELECT idcamp, TRIM(nombre), TRIM(canal), TRIM(tasa), TRIM(capital_min), TRIM(capital_max), TRIM(plazo_min), TRIM(plazo_max), TO_DATE(TRIM(fecha_inicio),"%d-%m-%Y"), TO_DATE(TRIM(fecha_fin),"%d-%m-%Y"),
							requiere_sdo_nuevo, monto_saldo_nuevo, requiere_instruccion_apertura, instrumento_ven, para_cte_nuevo, dias_vigenciacte_nuevo
							INTO   iIdpromocion, cNombreEstrategia, cCanal, dTasa, dCapitalmin, dCapitalmax, iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento,
							cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo 
							FROM "informix".sw_admintasascarga_promociones
							WHERE usuario = pUsuario
							--Calculamos la gat nominal y real
							EXECUTE PROCEDURE bdinvers:sp_calculagat_promocion(dTasa, '3000', iplazoInicio,0,0)
							INTO cCodRet2, dGatNominal, dGatReal;
								
							LET iCodRetSp = cCodRet2::INTEGER;
							IF iCodRetSp < 0 THEN
								RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdinvers:sp_calculagat_promocion";
							ELIF iCodRetSp = 1 THEN
								LET cCodRet = '01284'; -- NO EXISTE MEDIANA DE INFLACIï¿½N
								RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, cSucursal, cNumCuenta, cNumcte, iSecuencia, dTasaRenovacion,
								cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo;
							END IF;
	
							LET iContador = iContador + 1;
	
							IF UPPER(cCanal) = 'SUCURSAL' THEN
								LET cCanal = 1;
							ELIF UPPER(cCanal) = 'APP' THEN
								LET cCanal = 2;
							ELIF UPPER(cCanal) = 'PORTAL' THEN
								LET cCanal = 3;
							ELIF UPPER(cCanal) = 'ATM' THEN
								LET cCanal = 4;
							END IF;
							
							LET cInstrumentoVenCap = NULL;
							LET cInstrumentoVenInt = NULL;
								
							IF TRIM(UPPER(NVL(cInstrumentoApertura, ''))) = 'REINVERSION DE CAPITAL E INTERESES'
								OR TRIM(UPPER(NVL(cInstrumentoApertura, ''))) = 'REINVERSIï¿½N DE CAPITAL E INTERESES' THEN 
								LET cInstrumentoVenCap = '01';
								LET cInstrumentoVenInt = '01';
							ELIF TRIM(UPPER(NVL(cInstrumentoApertura, ''))) = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA' THEN
								LET cInstrumentoVenCap = '02';
								LET cInstrumentoVenInt = '02';
							ELIF TRIM(UPPER(NVL(cInstrumentoApertura, ''))) = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA' 
								OR TRIM(UPPER(NVL(cInstrumentoApertura, ''))) = 'REINVERSIï¿½N CAPITAL / DEPï¿½SITO INTERESES A CTA'
								OR TRIM(UPPER(NVL(cInstrumentoApertura, ''))) = 'REINVERSIï¿½N CAPITAL/DEPï¿½SITO INTERESES A CTA'
								OR TRIM(UPPER(NVL(cInstrumentoApertura, ''))) = 'REINVERSION CAPITAL/DEPOSITO INTERESES A CTA'
								OR TRIM(UPPER(NVL(cInstrumentoApertura, ''))) = 'REINVERSIï¿½N CAPITAL/DEPOSITO INTERESES A CTA' THEN
								LET cInstrumentoVenCap = '01';
								LET cInstrumentoVenInt = '02';
							END IF;
							
							--REALIZAMOS LA INSERCIï¿½N DE LA INFORMACIï¿½N DE PROMOCIONES
							INSERT INTO bdinvers:sv_admintasas_pagare(nombre_estrategia,canal,capital_min,capital_max,plazo_inicio,plazo_vencimiento,fecha_inicio,fecha_vencimiento,
							instruccion_vencimiento_capital, instruccion_vencimiento_intereses, dias_vigencia, monto_saldonuevo, tasa,gat_nominal,gat_real)
							VALUES (cNombreEstrategia, cCanal, dCapitalmin, dCapitalmax, iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, 
							cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo, dTasa, dGatNominal, dGatReal);
							
							--OBTENEMOS EL ID SERIAL NUEVO
							LET iPromocionfinal = DBINFO('sqlca.sqlerrd1');
	
							--INSERTAMOS EL ESTATUS DE LA CAMPAï¿½A
							INSERT INTO bdinvers:sv_admintasas_estatus (id_promocion, id_usuario, cod_estatus, fecha_cambio)
							VALUES (iPromocionfinal, pUsuario, 0, CURRENT);
							
							-- INSERTAMOS LAS SUCURSALES
							IF EXISTS (SELECT 1 FROM "informix".sw_admintasascarga_sucursales WHERE usuario = pUsuario AND idcamp = iIdpromocion) THEN
								INSERT INTO bdinvers:sv_sucursales_promocion (id_promocion, num_sucursal) 
								SELECT iPromocionfinal, TRIM(sucursal)
								FROM "informix".sw_admintasascarga_sucursales
								WHERE usuario = pUsuario
								AND idcamp = iIdpromocion;
							END IF;
	
							-- INSERTAMOS LAS CUENTAS
							IF EXISTS (SELECT 1 FROM "informix".sw_admintasascarga_cuentas WHERE usuario = pUsuario AND idcamp = iIdpromocion) THEN
								INSERT INTO bdinvers:sv_cuentas_promocion(id_promocion, num_cuenta) 
								SELECT iPromocionfinal, cuenta
								FROM "informix".sw_admintasascarga_cuentas
								WHERE usuario = pUsuario
								AND idcamp = iIdpromocion;
							END IF;
	
							-- INSERTAMOS LOS CLIENTES
							IF EXISTS (SELECT 1 FROM "informix".sw_admintasascarga_clientes WHERE usuario = pUsuario AND idcamp = iIdpromocion) THEN
								INSERT INTO bdinvers:sv_clientes_promocion(id_promocion, num_cte)
								SELECT iPromocionfinal, cliente
								FROM "informix".sw_admintasascarga_clientes
								WHERE usuario = pUsuario
								AND idcamp = iIdpromocion;
							END IF;
	
							IF EXISTS (SELECT 1 FROM "informix".sw_admintasascarga_renovaciones WHERE usuario = pUsuario AND idcamp = iIdpromocion) THEN
								FOREACH
									SELECT renovacion, tasa
									INTO  iSecuencia, dTasaRenovacion
									FROM "informix".sw_admintasascarga_renovaciones
									WHERE usuario = pUsuario
									AND idcamp = iIdpromocion
	
									INSERT INTO bdinvers:sv_admintasas_renovacion(id_promocion, secuencia, tasa)
									VALUES (iPromocionfinal, iSecuencia, dTasaRenovacion);
								END FOREACH
							END IF;
							
							IF EXISTS (SELECT 1 FROM "informix".sw_admintasascarga_tasas WHERE usuario = pUsuario AND idcamp = iIdpromocion) THEN
								FOREACH
									SELECT mes, tasa
									INTO  iSecuencia, dTasa
									FROM "informix".sw_admintasascarga_tasas
									WHERE usuario = pUsuario
									AND idcamp = iIdpromocion
	
									--Calculamos la gat nominal y real
									EXECUTE PROCEDURE bdinvers:sp_calculagat_promocion(dTasa, pProducto, 0,iSecuencia,0)
									INTO cCodRet2, dGatNominal, dGatReal;
							
									INSERT INTO bdinvers:si_admintasas_inv_tasames(id_promocion, mes, valor_tasa, tipo_tasa, gat_nominal, gat_real)
									VALUES (iPromocionfinal, iSecuencia, dTasa, '', dGatNominal, dGatReal);
									
								END FOREACH
							END IF;
								--Si no hubo errores lo registramos en la bitacora
								INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto)
								VALUES (TODAY, CURRENT, pUsuario, 'CARGA DE CAMPAï¿½AS', 1, "SE HA ALMACENADO LA INFORMACIï¿½N DE LA CAMPAï¿½A " || UPPER(TRIM(cNombreEstrategia)), 3000);
	
								--LET iIdpromocion     = '';
								LET cNombreEstrategia = '';
								LET cCanal           = '';
								LET dCapitalmin      = '';
								LET dCapitalmax      = '';
								LET iplazoInicio     = 0;
								LET iplazoVencimiento = 0;
								LET dFechaInicio     = '';
								LET dFechaVencimiento = '';
								LET dTasa            = '';
								LET dGatNominal      = '';
								LET dGatReal         = '';
								LET iCodEstatus      = '';
								LET cSucursal        = '';
								LET cNumCuenta       = '';
								LET cNumcte          = '';
								LET iSecuencia       = NULL;
								LET dTasaRenovacion  = NULL;
	
	
						END FOREACH
	
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, cSucursal, cNumCuenta, cNumcte, iSecuencia, dTasaRenovacion,
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo;
					ELSE --PRODUCTO 1100
						FOREACH
							SELECT idcamp, TRIM(nombre), TRIM(canal), TRIM(tasa), TRIM(capital_min), TO_DATE(TRIM(capital_max),"%d-%m-%Y"), TO_DATE(TRIM(plazo_min),"%d-%m-%Y")
							INTO  iIdpromocion, cNombreEstrategia, cCanal, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento
							FROM "informix".sw_admintasascarga_promociones
							WHERE usuario = pUsuario
	
							LET iCodRetSp = cCodRet2::INTEGER;
							IF iCodRetSp < 0 THEN
								RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdinvers:sp_calculagat_promocion";
							ELIF iCodRetSp = 1 THEN
								LET cCodRet = '01284'; -- NO EXISTE MEDIANA DE INFLACIï¿½N
								RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, cSucursal, cNumCuenta, cNumcte, iSecuencia, dTasaRenovacion,
								cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo;
							END IF;
	
							LET iContador = iContador + 1;
	
							IF UPPER(cCanal) = 'SUCURSAL' THEN
								LET cCanal = 1;
							ELIF UPPER(cCanal) = 'APP' THEN
								LET cCanal = 2;
							ELIF UPPER(cCanal) = 'PORTAL' THEN
								LET cCanal = 3;
							ELIF UPPER(cCanal) = 'ATM' THEN
								LET cCanal = 4;
							END IF;
	
							--REALIZAMOS LA INSERCIï¿½N DE LA INFORMACIï¿½N DE PROMOCIONES
							INSERT INTO bdicheq:sc_admintasas_invcreciente(nombre_estrategia,canal,capital_min,capital_max,fecha_inicio,fecha_vencimiento)
							VALUES (cNombreEstrategia, cCanal, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento);
							
							--OBTENEMOS EL ID SERIAL NUEVO
							LET iPromocionfinal = DBINFO('sqlca.sqlerrd1');
	
							--INSERTAMOS EL ESTATUS DE LA CAMPAï¿½A
							INSERT INTO bdicheq:sc_admintasas_inv_estatus (id_promocion, id_usuario, cod_estatus, fecha_cambio)
							VALUES (iPromocionfinal, pUsuario, 0, CURRENT);
							
							
							-- INSERTAMOS LAS SUCURSALES
							IF EXISTS (SELECT 1 FROM "informix".sw_admintasascarga_sucursales WHERE usuario = pUsuario AND idcamp = iIdpromocion) THEN
								INSERT INTO bdicheq:sc_admintasas_inv_sucursales(id_promocion, num_sucursal) 
								SELECT iPromocionfinal, sucursal
								FROM "informix".sw_admintasascarga_sucursales
								WHERE usuario = pUsuario
								AND idcamp = iIdpromocion;
							END IF;
	
							-- INSERTAMOS LOS CLIENTES
							IF EXISTS (SELECT 1 FROM "informix".sw_admintasascarga_clientes WHERE usuario = pUsuario AND idcamp = iIdpromocion) THEN
								INSERT INTO bdicheq:sc_admintasas_inv_clientes(id_promocion, num_cte)
								SELECT iPromocionfinal, TRIM(cliente)
								FROM "informix".sw_admintasascarga_clientes
								WHERE usuario = pUsuario
								AND idcamp = iIdpromocion;
							END IF;
							
							IF EXISTS (SELECT 1 FROM "informix".sw_admintasascarga_tasas WHERE usuario = pUsuario AND idcamp = iIdpromocion) THEN
								FOREACH
									SELECT mes, tasa
									INTO  iSecuencia, dTasa
									FROM "informix".sw_admintasascarga_tasas
									WHERE usuario = pUsuario
									AND idcamp = iIdpromocion
	
									--Calculamos la gat nominal y real
									EXECUTE PROCEDURE bdinvers:sp_calculagat_promocion(dTasa, pProducto, 0,iSecuencia,0)
									INTO cCodRet2, dGatNominal, dGatReal;
							
									INSERT INTO bdinteg:si_admintasas_inv_tasames (id_promocion, mes, valor_tasa, tipo_tasa, gat_nominal, gat_real)
									VALUES (iPromocionfinal, iSecuencia, dTasa, '', dGatNominal, dGatReal);
									
								END FOREACH
							END IF;
								--Si no hubo errores lo registramos en la bitacora
								INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto)
								VALUES (TODAY, CURRENT, pUsuario, 'CARGA DE CAMPAï¿½AS', 1, "SE HA ALMACENADO LA INFORMACIï¿½N DE LA CAMPAï¿½A " || UPPER(TRIM(cNombreEstrategia)), 3000);

							--LET iIdpromocion     = '';
							LET cNombreEstrategia = '';
							LET cCanal           = '';
							LET dCapitalmin      = '';
							LET dCapitalmax      = '';
							LET iplazoInicio     = 0;
							LET iplazoVencimiento = 0;
							LET dFechaInicio     = '';
							LET dFechaVencimiento = '';
							LET dTasa            = '';
							LET dGatNominal      = '';
							LET dGatReal         = '';
							LET iCodEstatus      = '';
							LET cSucursal        = '';
							LET cNumCuenta       = '';
							LET cNumcte          = '';
							LET iSecuencia       = NULL;
							LET dTasaRenovacion  = NULL;


						END FOREACH

						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, cSucursal, cNumCuenta, cNumcte, iSecuencia, dTasaRenovacion,
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo;
					END IF;
                END IF;
            END IF

			IF pBandera <> 2 AND pBandera <> 3 AND pBandera <> 4 AND pBandera <> 6 THEN 
				IF iContador = 0 THEN
					LET cCodRet = '00017';
					RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, cSucursal, cNumCuenta, cNumcte, iSecuencia, dTasaRenovacion,
					cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo;
				END IF;
			ELSE
				IF iContador = 0 AND pRegistros = 0 THEN
					LET cCodRet = '00017';
					RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, cSucursal, cNumCuenta, cNumcte, iSecuencia, dTasaRenovacion,
					cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo;
				ELIF iContador = 0 AND pRegistros > 0 THEN
					LET cCodRet = '1001';
					RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, cSucursal, cNumCuenta, cNumcte, iSecuencia, dTasaRenovacion,
					cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo;
				END IF;
			END IF;
        ELSE 
            LET cCodRet = '00002';
            RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, cSucursal, cNumCuenta, cNumcte, iSecuencia, dTasaRenovacion,
			cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo;

        END IF;
    END
END PROCEDURE
DOCUMENT 'AUTOR: Josï¿½ Antonio Ramï¿½rez Franco',
'FECHA: 28/08/2024',
'MODULO: DEBITO',
'FUNCIONALIDAD: CARGA DE CAMPAï¿½AS',
'DESCRIPCION: Procedimiento Almacenado que se divide en 6 banderas las cuales se ejecutan siempre y cuando el parametro pErrores sea igual a f es decir',
'que del sp_adminitasas_cargarchivo no se haya encontrado una observaciï¿½n o un error en el contenido del archivo.',
'Bandera 1: Imprime la informaciï¿½n de la hoja de PROMOCIONES de la tabla de paso sw_admintasascarga_temp para que se visualice en el grid',
'Bandera 2: Imprime la informaciï¿½n de la hoja de SUCURSALES de la tabla de paso sw_admintasascarga_temp para que se visualice en el grid',
'Bandera 3: Imprime la informaciï¿½n de la hoja de CUENTAS de la tabla de paso sw_admintasascarga_temp para que se visualice en el grid',
'Bandera 4: Imprime la informaciï¿½n de la hoja de CLIENTES de la tabla de paso sw_admintasascarga_temp para que se visualice en el grid',
'Bandera 5: Imprime la informaciï¿½n de la hoja de RENOVACIONES de la tabla de paso sw_admintasascarga_temp para que se visualice en el grid',
'Bandera 6: Si la informaciï¿½n es correcta se procede guardar de la tabla de paso sw_admintasascarga_temp a las estructuras sv_admintasas_pagare, sv_sucursales_promocion, sv_cuentas_promocion, sv_clientes_promocion, sv_admintasas_renovacion y sv_admintasas_estatus de la bdinvers',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez',
'FECHA: 09/03/2025',
'DESCRIPCION: Se agregan validaciones para realizar el almacenamiento de los datos del producto 1100',
'AUTOR: Veronica Sanchez',
'FECHA: 25/07/2025',
'DESCRIPCION: Se modifica procedimiento almacenado para agregar las nuevas teblas en donde se realizara la recuperacion de datos',
'bdicnweb:"informix".sw_admintasascarga_promociones - HOJA PROMOCIONES', 
'bdicnweb:"informix".sw_admintasascarga_tasas - HOJA TASAS ', 
'bdicnweb:"informix".sw_admintasascarga_sucursales - HOJA SUCURSALES ', 
'bdicnweb:"informix".sw_admintasascarga_clientes - HOJA CLIENTES ',
'bdicnweb:"informix".sw_admintasascarga_cuentas - HOJAS CUENTAS ',
'bdicnweb:"informix".sw_admintasascarga_renovaciones - HOJA RENOVACIONES',
'AUTOR: Veronica Sanchez',
'FECHA: 01/12/2025',
'DESCRIPCION: Se modifica procedimiento almacenado para agregar nuevas validaciones para los campos nuevos del producto 3000 con bandera de planeada',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_admintasas_actualizastatuspagare(pUsuario CHAR(9), 
                                                                pIdFuncion CHAR(8),
                                                                pIdPromocion INTEGER,
                                                                pFechaVencimiento DATE,
                                                                pGatNominal DECIMAL(9,6),
                                                                pGatReal    DECIMAL(9,6),
                                                                pEstatus    SMALLINT,
																pProducto CHAR(4),
																pMontoSdoCte DECIMAL(14,2))
RETURNING CHAR(5)       AS codret;


    
    DEFINE cCodRet          CHAR(5);
    DEFINE iSqlErr          INTEGER;
    DEFINE iIdpromocion     INTEGER;
    DEFINE dFechaVencimiento date;
    DEFINE dGatNominal      DECIMAL(9,6);
	DEFINE dGatReal         DECIMAL(9,6);   
    DEFINE cNombreEstrategia CHAR(100);
    DEFINE iEstatus         INTEGER;
    DEFINE iBanMod          SMALLINT;
    DEFINE iCodEstatusOrg  SMALLINT;
	--Nuevo
	DEFINE iTotalPro1100	INTEGER;
	-- nuevo
	DEFINE dMontoSdoCte		DECIMAL(14,2);


    LET cCodRet          = '00000';
    LET iSqlErr          = 0;
    LET iIdpromocion     = '';
    LET dFechaVencimiento = '';
    LET dGatNominal       = 0;
    LET dGatReal          = 0;
    LET cNombreEstrategia = '';
    LET iEstatus          = NULL;
    LET iBanMod           = 0;
    LET iCodEstatusOrg    = NULL;
	--Nuevo
	LET iTotalPro1100	  = 0;
	LET dMontoSdoCte	  = 0;
   

    BEGIN

        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/admintasas/sp_admintasas_actualizastatuspagare.out';
		--TRACE ON;

        IF pUsuario = '' OR pIdFuncion = '' OR pIdPromocion = '' OR pIdPromocion IS NULL OR pFechaVencimiento = '' 
        OR pEstatus = '' OR pEstatus NOT IN (0,1,2) THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;

		IF pProducto = '3000' THEN -- VALIDACION POR PRODUCTO
			SELECT id_promocion, nombre_estrategia,  fecha_vencimiento, gat_nominal, gat_real, monto_saldonuevo
			INTO iIdpromocion, cNombreEstrategia, dFechaVencimiento, dGatNominal, dGatReal, dMontoSdoCte
			FROM bdinvers:sv_admintasas_pagare
			WHERE id_promocion = pIdPromocion;
	
			SELECT cod_estatus 
			INTO iCodEstatusOrg
			FROM bdinvers:sv_admintasas_estatus 
			WHERE id_promocion = iIdpromocion
			AND cod_estatus IN (0,1)
			AND fecha_cambio = (SELECT MAX(fecha_cambio) FROM bdinvers:sv_admintasas_estatus WHERE id_promocion = iIdpromocion AND cod_estatus IN (0,1));
	
			SELECT cod_estatus 
			INTO iEstatus
			FROM bdinvers:sv_admintasas_estatus 
			WHERE id_promocion = iIdpromocion 
			AND fecha_cambio = (SELECT MAX(fecha_cambio) FROM bdinvers:sv_admintasas_estatus WHERE id_promocion = iIdpromocion);
	
			IF iIdpromocion IS NOT NULL OR iIdpromocion <> '' THEN
			-- ActualizaciÃ³n de la campaÃ±a
				UPDATE bdinvers:sv_admintasas_pagare 
				SET fecha_vencimiento = pFechaVencimiento, gat_nominal = pGatNominal, gat_real = pGatReal, monto_saldonuevo = pMontoSdoCte
				WHERE id_promocion = pIdPromocion;
	
				IF pFechaVencimiento <> dFechaVencimiento THEN
					LET iBanMod = 1; -- fue ditado
					INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
					VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DE LA FECHA VENCIMIENTO DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, dFechaVencimiento, pFechaVencimiento);
				END IF;
				IF dGatNominal != pGatNominal THEN
					LET iBanMod = 1; -- fue ditado
					INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
					VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DE LA GAT NOMINAL DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, dGatNominal, pGatNominal);
				END IF;
				IF dGatReal != pGatReal THEN
					LET iBanMod = 1; -- fue ditado
					INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
					VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DE LA GAT REAL DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, dGatReal, pGatReal);
				END IF;
				
				IF NVL(dMontoSdoCte,0) <> NVL(pMontoSdoCte,0) THEN
					LET iBanMod = 1; -- fue ditado
					INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
					VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL MONTO SALDO NUEVO DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, dMontoSdoCte, pMontoSdoCte);
				END IF;
	
				IF pEstatus = iEstatus THEN --0,0 1,1, 2,2
	
					IF (iBanMod = 1 AND pEstatus = 0) THEN -- 
						INSERT INTO bdinvers:sv_admintasas_estatus VALUES(pIdPromocion, pUsuario, 0, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, iEstatus, 0);
					
					ELIF iBanMod = 1 AND pEstatus = 1 THEN 
						INSERT INTO bdinvers:sv_admintasas_estatus VALUES(pIdPromocion, pUsuario, 2, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, iEstatus, 2);
	
					ELIF iBanMod = 1 AND pEstatus = 2 AND iCodEstatusOrg = 1 THEN 
						INSERT INTO bdinvers:sv_admintasas_estatus VALUES(pIdPromocion, pUsuario, 2, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, iEstatus, 2);
					
					ELIF iBanMod = 1 AND pEstatus = 2 AND iCodEstatusOrg = 0 THEN 
						INSERT INTO bdinvers:sv_admintasas_estatus VALUES(pIdPromocion, pUsuario, 0, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, iEstatus, 0);
					END IF
	
					IF iBanMod = 0 THEN 
						INSERT INTO bdinvers:sv_admintasas_estatus VALUES(pIdPromocion, pUsuario, pEstatus, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, iEstatus, pEstatus);
	
					END IF
				ELIF pEstatus <> iEstatus THEN
	
					IF  iEstatus = 0 AND pEstatus = 1 AND iBanMod = 1 THEN
	
						INSERT INTO bdinvers:sv_admintasas_estatus VALUES(pIdPromocion, pUsuario, pEstatus, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, iEstatus, pEstatus);
					
					ELIF iEstatus = 1 AND pEstatus = 0 AND iBanMod = 1 THEN
						
						INSERT INTO bdinvers:sv_admintasas_estatus VALUES(pIdPromocion, pUsuario, 2, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, iEstatus, 2);
					
					ELIF iEstatus = 2 AND pEstatus = 1 AND iBanMod = 1 THEN
						
						INSERT INTO bdinvers:sv_admintasas_estatus VALUES(pIdPromocion, pUsuario, 2, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, iEstatus, 2);
					
					ELIF iEstatus = 2 AND pEstatus = 1 AND iBanMod = 0 THEN
						
						INSERT INTO bdinvers:sv_admintasas_estatus VALUES(pIdPromocion, pUsuario, pEstatus, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, iEstatus, pEstatus);
					
					ELIF iEstatus = 0 AND pEstatus = 1 AND iBanMod = 0 THEN
	
						INSERT INTO bdinvers:sv_admintasas_estatus VALUES(pIdPromocion, pUsuario, pEstatus, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, iEstatus, pEstatus);
					
					ELIF iEstatus = 1 AND pEstatus = 0 AND iBanMod = 0 THEN
						
						INSERT INTO bdinvers:sv_admintasas_estatus VALUES(pIdPromocion, pUsuario, 0, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, iEstatus, 0);
					
					ELIF iEstatus = 2 AND pEstatus = 0 AND iBanMod = 0 THEN
						
						INSERT INTO bdinvers:sv_admintasas_estatus VALUES(pIdPromocion, pUsuario, 0, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 3000, pUsuario, iEstatus, 0);
	
					END IF
								
				END IF;
			
			ELSE
				LET cCodRet = '00017';
			END IF;
		ELSE --1100
			SELECT COUNT(*)
			INTO iTotalPro1100
			FROM bdicheq:sc_admintasas_invcreciente
			WHERE id_promocion = pIdPromocion;
			
			IF NVL(iTotalPro1100,0) > 0 THEN 
				SELECT fecha_vencimiento
				INTO dFechaVencimiento
				FROM bdicheq:sc_admintasas_invcreciente
				WHERE id_promocion = pIdPromocion;
				
				SELECT cod_estatus 
				INTO iCodEstatusOrg
				FROM bdicheq:sc_admintasas_inv_estatus 
				WHERE id_promocion = pIdPromocion
				AND cod_estatus IN (0,1)
				AND fecha_cambio = (SELECT MAX(fecha_cambio) FROM bdicheq:sc_admintasas_inv_estatus WHERE id_promocion = pIdPromocion AND cod_estatus IN (0,1));
		
				SELECT cod_estatus 
				INTO iEstatus
				FROM bdicheq:sc_admintasas_inv_estatus 
				WHERE id_promocion = pIdPromocion 
				AND fecha_cambio = (SELECT MAX(fecha_cambio) FROM bdicheq:sc_admintasas_inv_estatus WHERE id_promocion = pIdPromocion);
	
				
				IF dFechaVencimiento <> pFechaVencimiento THEN
					LET iBanMod = 1; 
					UPDATE bdicheq:sc_admintasas_invcreciente
					SET fecha_vencimiento = pFechaVencimiento
					WHERE id_promocion = pIdPromocion;
					
					INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
					VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DE LA FECHA VENCIMIENTO DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), 1100, pUsuario, dFechaVencimiento, pFechaVencimiento);	
				END IF;
				
				IF pEstatus = iEstatus THEN --0,0 1,1, 2,2
	
					IF (iBanMod = 1 AND pEstatus = 0) THEN -- 
						INSERT INTO bdicheq:sc_admintasas_inv_estatus VALUES(pIdPromocion, pUsuario, 0, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), pProducto, pUsuario, iEstatus, 0);
					
					ELIF iBanMod = 1 AND pEstatus = 1 THEN 
						INSERT INTO bdicheq:sc_admintasas_inv_estatus VALUES(pIdPromocion, pUsuario, 2, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), pProducto, pUsuario, iEstatus, 2);
	
					ELIF iBanMod = 1 AND pEstatus = 2 AND iCodEstatusOrg = 1 THEN 
						INSERT INTO bdicheq:sc_admintasas_inv_estatus VALUES(pIdPromocion, pUsuario, 2, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), pProducto, pUsuario, iEstatus, 2);
					
					ELIF iBanMod = 1 AND pEstatus = 2 AND iCodEstatusOrg = 0 THEN 
						INSERT INTO bdicheq:sc_admintasas_inv_estatus VALUES(pIdPromocion, pUsuario, 0, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), pProducto, pUsuario, iEstatus, 0);
					END IF
	
					IF iBanMod = 0 THEN 
						INSERT INTO bdicheq:sc_admintasas_inv_estatus VALUES(pIdPromocion, pUsuario, pEstatus, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), pProducto, pUsuario, iEstatus, pEstatus);
	
					END IF
				ELIF pEstatus <> iEstatus THEN
	
					IF  iEstatus = 0 AND pEstatus = 1 AND iBanMod = 1 THEN
	
						INSERT INTO bdicheq:sc_admintasas_inv_estatus VALUES(pIdPromocion, pUsuario, pEstatus, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), pProducto, pUsuario, iEstatus, pEstatus);
					
					ELIF iEstatus = 1 AND pEstatus = 0 AND iBanMod = 1 THEN
						
						INSERT INTO bdicheq:sc_admintasas_inv_estatus VALUES(pIdPromocion, pUsuario, 2, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), pProducto, pUsuario, iEstatus, 2);
					
					ELIF iEstatus = 2 AND pEstatus = 1 AND iBanMod = 1 THEN
						
						INSERT INTO bdicheq:sc_admintasas_inv_estatus VALUES(pIdPromocion, pUsuario, 2, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), pProducto, pUsuario, iEstatus, 2);
					
					ELIF iEstatus = 2 AND pEstatus = 1 AND iBanMod = 0 THEN
						
						INSERT INTO bdicheq:sc_admintasas_inv_estatus VALUES(pIdPromocion, pUsuario, pEstatus, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), pProducto, pUsuario, iEstatus, pEstatus);
					
					ELIF iEstatus = 0 AND pEstatus = 1 AND iBanMod = 0 THEN
	
						INSERT INTO bdicheq:sc_admintasas_inv_estatus VALUES(pIdPromocion, pUsuario, pEstatus, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), pProducto, pUsuario, iEstatus, pEstatus);
					
					ELIF iEstatus = 1 AND pEstatus = 0 AND iBanMod = 0 THEN
						
						INSERT INTO bdicheq:sc_admintasas_inv_estatus VALUES(pIdPromocion, pUsuario, 0, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), pProducto, pUsuario, iEstatus, 0);
					
					ELIF iEstatus = 2 AND pEstatus = 0 AND iBanMod = 0 THEN
						
						INSERT INTO bdicheq:sc_admintasas_inv_estatus VALUES(pIdPromocion, pUsuario, 0, CURRENT);
	
						INSERT INTO bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto, usuario_mod, campoAnterior, campoNuevo)
						VALUES (TODAY, CURRENT, pUsuario, 'MODIFICACIÃN DE CAMPAÃAS', 2, "SE REALIZÃ LA MODIFICACIÃN DEL ESTATUS DE LA CAMPAÃA " || UPPER(TRIM(cNombreEstrategia)), pProducto, pUsuario, iEstatus, 0);
	
					END IF
								
				END IF;
				
			ELSE
				LET cCodRet = '00017';
			END IF;
			
		END IF;
		
        RETURN cCodRet;
    END
END PROCEDURE    
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 28/08/2024',
'MODULO: DEBITO',
'FUNCIONALIDAD: MODIFICACIÃN DE CAMPAÃAS',
'DESCRIPCION: Procedimiento almacenado que se encarga de actualizar la fecha de vencimiento, gat Nominal, gat Real y el estatus de la campaÃ±a de la tabla bdinvers:sv_admintasas_pagare',
'AsÃ­ como validar que la fecha de vencimiento no sea menor a la actual e insertar un nuevo registro a la bdinvers:sv_admintasas_pagare, cuando haya un cambio de estatus',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez',
'FECHA: 31/03/2025',
'DESCRIPCION: Se agregan validaciones para actualizar los datos del producto 1100',
'AUTOR: Veronica Sanchez',
'FECHA: 26/08/2025',
'DESCRIPCION: Se modifica proceso realizar la insercion del estatus de forma correcta',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez',
'FECHA: 01/12/2025',
'DESCRIPCION: Se modifica proceso realizar la insercion de los nuevos campos para de producto 3000',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_admintasas_consultapagare(pUsuario CHAR(9), 
                                                        pIdFuncion CHAR(8), 
                                                        pProducto CHAR(4), 
                                                        pEstatus SMALLINT, 
                                                        pIdPromocion INTEGER,
                                                        pNombrePromocion CHAR(100), 
                                                        pCanal SMALLINT, 
                                                        pCapitalMin DECIMAL(14,2), 
                                                        pCapitalMax DECIMAL(14,2), 
                                                        pFechaInicio DATE, 
                                                        pFechaVencimiento DATE,
                                                        pPlazo_inicio INTEGER, 
                                                        pPlazo_vencimiento INTEGER, 
                                                        pCampoOrden SMALLINT, 
                                                        pOrderBy SMALLINT,
                                                        pRegistros INTEGER, 
                                                        pRecuperacion INTEGER)
RETURNING CHAR(5)       AS codret,
          INTEGER       AS id_promocion,
          CHAR(100)     AS nombre_estrategia,
          SMALLINT      AS canal,
          INTEGER       AS plazo_inicio,
          INTEGER       AS plazo_vencimiento, 
          DECIMAL(14,2)   AS capital_min,    
          DECIMAL(14,2)   AS capital_max,
          CHAR(10)        AS fecha_inicio,
          CHAR(10)      AS fecha_vencimiento,
          DECIMAL(9,6)  AS tasa,
          DECIMAL(9,6)  AS gat_nominal,
          DECIMAL(9,6)  AS gat_real,
          SMALLINT      AS cod_estatus,
          SMALLINT      AS cod_estatus_orginal,
		  CHAR(2)		AS requiereSdoNuevo, -- NUEVO
		  DECIMAL(14,2) AS montoSdoNuevo, -- NUEVO
		  CHAR(2)		AS requiereInsApertura, -- NUEVO
		  CHAR(60)		AS instrumentoApertura, -- NUEVO
		  CHAR(2)		AS requiereParCteNuevo, -- NUEVO
		  INTEGER		AS diasVigenciaCteNuevo; -- NUEVO

    DEFINE vCampoOrden          INTEGER;
    DEFINE cCodRet              CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iRegistro            INTEGER;
    DEFINE iIdpromocion         INTEGER;
    DEFINE cNombreEstrategia    CHAR(100); 
    DEFINE cCanal               SMALLINT;
    DEFINE dCapitalmin          DECIMAL(14,2);
    DEFINE dCapitalmax          DECIMAL(14,2);
    DEFINE iplazoInicio         INTEGER;
    DEFINE iplazoVencimiento    INTEGER;
    DEFINE dFechaInicio         CHAR(10);
    DEFINE dFechaVencimiento    CHAR(10);
    DEFINE dTasa                DECIMAL(9,6);
    DEFINE dGatNominal          DECIMAL(9,6);
	DEFINE dGatReal             DECIMAL(9,6);
    DEFINE iCodEstatus          SMALLINT;
    DEFINE iCodEstatusOrg       SMALLINT;
    DEFINE cCmd1 CHAR(6500);
    DEFINE vOrdenamiento        VARCHAR(50);
    DEFINE cCmd2 CHAR(6500);
	-- Nuevos
	DEFINE cRequiereSdoNuevo	CHAR(2);
	DEFINE dMontoSdoNuevo		DECIMAL(14,2);
	DEFINE cRequiereInstrApertura	CHAR(2);
	DEFINE cInstrumentoApertura	CHAR(50);
	DEFINE cParCteNuevo			CHAR(2);
	DEFINE iDiasVigenciaCteNuevo	INTEGER;
	DEFINE cInstrumentoVenCap		CHAR(2);
	DEFINE cInstrumentoVenInt		CHAR(2);

    

    LET cCodRet          = '00000';
    LET iSqlErr          = 0;
    LET iRegistro        = 0;
    LET iIdpromocion     = '';
    LET cNombreEstrategia = '';
    LET cCanal           = '';
    LET dCapitalmin      = '';
    LET dCapitalmax      = '';
    LET iplazoInicio     = 0;
    LET iplazoVencimiento = 0;
    LET dFechaInicio     = '';
    LET dFechaVencimiento = '';
    LET dTasa            = '';
    LET dGatNominal      = '';
	LET dGatReal         = '';
    LET iCodEstatus      = '';
    LET iCodEstatusOrg   = '';
    let vCampoOrden      = '';
    let vOrdenamiento    = '';
	--NUEVO
	LET cRequiereSdoNuevo	= '';
	LET dMontoSdoNuevo	= 0;
	LET cRequiereInstrApertura	= '';
	LET cInstrumentoApertura	= '';
	LET cParCteNuevo	= '';
	LET iDiasVigenciaCteNuevo	= 0;
	LET cInstrumentoVenCap = '';
    LET cInstrumentoVenInt = '';


    BEGIN

        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg,
			cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/vero/tasas_f3/sp_admintasas_consultastatuspagare.out';
		--TRACE ON;

        IF pUsuario = '' OR pIdFuncion = '' OR pProducto = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg,
			cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo;
		END IF;

        --Validamos que el campo orden no exceda de los 13 registros
        IF pCampoOrden IS NOT NULL AND pCampoOrden NOT IN (1,2,3,4,5,6,7,8,9,10,11,12,13) THEN
            LET cCodRet = '00003';
			RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg,
			cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo;
        END IF;

		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg,
			cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo;
		END IF;
		
        IF pProducto <> '3000' AND pProducto <> '1100' THEN
            LET cCodRet = '00003';
			RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg,
			cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo;
        END IF;

        IF pRegistros = 0 THEN

            DELETE FROM "informix".sw_admintasas_pagare_estatus_temp  WHERE usuario_insert = pUsuario; 

            LET cCmd1 = "";
			IF pProducto = '3000' THEN -- VALIDACION POR PRODUCTO
				LET cCmd1 = ""||TRIM(cCmd1)|| "SELECT p.id_promocion, nombre_estrategia, canal, plazo_inicio, plazo_vencimiento, capital_min, capital_max, fecha_inicio, fecha_vencimiento, tasa, gat_nominal, gat_real,";
				LET cCmd1 = ""||TRIM(cCmd1)|| "instruccion_vencimiento_capital, instruccion_vencimiento_intereses, dias_vigencia, monto_saldonuevo, cod_estatus";
				LET cCmd1 = ""||TRIM(cCmd1)|| " FROM bdinvers:sv_admintasas_pagare p INNER JOIN bdinvers:sv_admintasas_estatus s ON p.id_promocion = s.id_promocion AND s.fecha_cambio = (SELECT MAX(fecha_cambio) FROM bdinvers:sv_admintasas_estatus WHERE id_promocion = p.id_promocion)";
				LET cCmd1 = ""||TRIM(cCmd1)|| " WHERE 1=1";
	
				IF pIdPromocion IS NOT NULL OR pIdPromocion <> '' THEN
					LET cCmd1 = ""||TRIM(cCmd1)|| " AND p.id_promocion = '" || pIdPromocion ||"'";
				END IF;
	
				IF pEstatus IS NOT NULL THEN
					LET cCmd1 = ""||TRIM(cCmd1)|| " AND cod_estatus = '" || pEstatus ||"'";
				END IF;
	
				IF pCanal IS NOT NULL THEN
					LET cCmd1 = ""||TRIM(cCmd1)|| " AND canal = '" || pCanal ||"'";
				END IF;
	
				IF pCapitalMin IS NOT NULL AND pCapitalMax IS NOT NULL THEN
					LET cCmd1 = ""||TRIM(cCmd1)|| " AND (capital_min >= " || pCapitalMin || "AND capital_min <= "|| pCapitalMax ||") AND (capital_max <= " || pCapitalMax || " AND capital_max >= " || pCapitalMin||")";
				END IF;
	
				IF pPlazo_inicio IS NOT NULL AND pPlazo_vencimiento IS NOT NULL THEN
					LET cCmd1 = ""||TRIM(cCmd1)|| " AND (plazo_inicio >= " || pPlazo_inicio || " AND plazo_vencimiento <= " || pPlazo_vencimiento || ")";
				END IF;
	
				IF pFechaInicio IS NOT NULL AND pFechaVencimiento IS NOT NULL THEN
					LET cCmd1 = ""||TRIM(cCmd1)|| " AND (fecha_inicio BETWEEN '" || pFechaInicio ||"' AND '" || pFechaVencimiento || "') AND fecha_vencimiento <= '"||pFechaVencimiento||"'";
				END IF;
				
			ELSE -- PRODUCTO 1100
				LET cCmd1 = ""||TRIM(cCmd1)|| "SELECT p.id_promocion, nombre_estrategia, canal, capital_min, capital_max, fecha_inicio, fecha_vencimiento, cod_estatus";
				LET cCmd1 = ""||TRIM(cCmd1)|| " FROM bdicheq:sc_admintasas_invcreciente p INNER JOIN bdicheq:sc_admintasas_inv_estatus s ON p.id_promocion = s.id_promocion AND s.fecha_cambio = (SELECT MAX(fecha_cambio) FROM bdicheq:sc_admintasas_inv_estatus WHERE id_promocion = p.id_promocion)";
				LET cCmd1 = ""||TRIM(cCmd1)|| " WHERE 1=1";
		
				IF pIdPromocion IS NOT NULL OR pIdPromocion <> '' THEN
					LET cCmd1 = ""||TRIM(cCmd1)|| " AND p.id_promocion = '" || pIdPromocion ||"'";
				END IF;
		
				IF pCapitalMin IS NOT NULL AND pCapitalMax IS NOT NULL THEN
					LET cCmd1 = ""||TRIM(cCmd1)|| " AND (capital_min >= " || pCapitalMin || "AND capital_min <= "|| pCapitalMax ||") AND (capital_max <= " || pCapitalMax || " AND capital_max >= " || pCapitalMin||")";
				END IF;
				
				IF pEstatus IS NOT NULL THEN
					LET cCmd1 = ""||TRIM(cCmd1)|| " AND s.cod_estatus = '" || pEstatus ||"'";
				END IF;
		
				IF pFechaInicio IS NOT NULL AND pFechaVencimiento IS NOT NULL THEN
					LET cCmd1 = ""||TRIM(cCmd1)|| " AND (p.fecha_inicio BETWEEN '" || pFechaInicio ||"' AND '" || pFechaVencimiento || "') AND p.fecha_vencimiento <= '"||pFechaVencimiento||"'";
				END IF;
				
				IF pCanal IS NOT NULL THEN
					LET cCmd1 = ""||TRIM(cCmd1)|| " AND canal = '" || pCanal ||"'";
				END IF;
				
			END IF;
			
			IF pCampoOrden IS NULL AND (pOrderBy = 1 OR pOrderBy = '') THEN
				LET cCmd1 = ""||TRIM(cCmd1)|| " ORDER BY id_promocion ASC";
			END IF;
			
            IF pCampoOrden IS NULL AND pOrderBy = 2 THEN
                LET cCmd1 = ""||TRIM(cCmd1)|| " ORDER BY id_promocion DESC";
            END IF;

            IF pCampoOrden IS NOT NULL AND pOrderBy IS NOT NULL THEN
                IF pOrderBy = '1' THEN
                    LET cCmd1 = ""||TRIM(cCmd1)|| " ORDER BY " || pCampoOrden ||"  ASC";
                ELIF pOrderBy = '2' THEN
                    LET cCmd1 = ""||TRIM(cCmd1)|| " ORDER BY " || pCampoOrden ||"  DESC";
                END IF
            END IF

            --Ajuste 
            IF NVL(pNombrePromocion,'') <> '' THEN
                LET pNombrePromocion  = "%" || UPPER(TRIM(pNombrePromocion)) || "%";
            END IF;

            PREPARE stmtId FROM TRIM(cCmd1);
            DECLARE selectQryCur CURSOR FOR stmtId;
            OPEN selectQryCur;
			
			IF pProducto = '3000' THEN -- VALIDACION POR PRODUCTO
				FETCH selectQryCur INTO iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo, iCodEstatus;
			ELSE
				FETCH selectQryCur INTO iIdpromocion, cNombreEstrategia, cCanal, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, iCodEstatus;
			END IF;
			
			IF pProducto = '3000' THEN 
				WHILE(SQLCODE == 0)	
            
                    SELECT cod_estatus 
                    INTO iCodEstatusOrg
                    FROM bdinvers:sv_admintasas_estatus 
                    WHERE id_promocion = iIdpromocion
                    AND cod_estatus IN (0,1)
                    AND fecha_cambio = (SELECT MAX(fecha_cambio) FROM bdinvers:sv_admintasas_estatus WHERE id_promocion = iIdpromocion AND cod_estatus IN (0,1));

                    IF iCodEstatusOrg IS NULL OR iCodEstatus = '' THEN
                        LET iCodEstatusOrg = iCodEstatus;
                    END IF;

                    IF pNombrePromocion <> '' THEN
                        LET cNombreEstrategia = UPPER(TRIM(cNombreEstrategia));

                        IF cNombreEstrategia LIKE pNombrePromocion THEN
                            LET iRegistro = iRegistro + 1;
                            --RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg WITH RESUME;
                            INSERT INTO "informix".sw_admintasas_pagare_estatus_temp 
                            VALUES (iIdpromocion, UPPER(cNombreEstrategia), cCanal, dCapitalmin, dCapitalmax, iplazoInicio, iplazoVencimiento,dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo, pUsuario, TODAY);
                        END IF;
                    ELSE
                            LET iRegistro = iRegistro + 1;
                            INSERT INTO "informix".sw_admintasas_pagare_estatus_temp 
                            VALUES (iIdpromocion, UPPER(cNombreEstrategia), cCanal, dCapitalmin, dCapitalmax, iplazoInicio, iplazoVencimiento,dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo, pUsuario, TODAY);
                    END IF;
					FETCH selectQryCur INTO  iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo, iCodEstatus;
				END WHILE;			
			ELSE 
				WHILE(SQLCODE == 0)	
                    SELECT cod_estatus 
					INTO iCodEstatusOrg
					FROM bdicheq:sc_admintasas_inv_estatus 
					WHERE id_promocion = iIdpromocion
					AND cod_estatus IN (0,1)
					AND fecha_cambio = (SELECT MAX(fecha_cambio) FROM bdinvers:sv_admintasas_estatus WHERE id_promocion = iIdpromocion AND cod_estatus IN (0,1));

                    IF iCodEstatusOrg IS NULL OR iCodEstatus = '' THEN
                        LET iCodEstatusOrg = iCodEstatus;
                    END IF;

                    IF pNombrePromocion <> '' THEN
                        LET cNombreEstrategia = UPPER(TRIM(cNombreEstrategia));

                        IF cNombreEstrategia LIKE pNombrePromocion THEN
                            LET iRegistro = iRegistro + 1;
                            --RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg WITH RESUME;
                            INSERT INTO "informix".sw_admintasas_pagare_estatus_temp 
                            VALUES (iIdpromocion, UPPER(cNombreEstrategia), cCanal, dCapitalmin, dCapitalmax, iplazoInicio, iplazoVencimiento,dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo, pUsuario, TODAY);
                        END IF;
                    ELSE
						LET iRegistro = iRegistro + 1;
						INSERT INTO "informix".sw_admintasas_pagare_estatus_temp 
						VALUES (iIdpromocion, UPPER(cNombreEstrategia), cCanal, dCapitalmin, dCapitalmax, iplazoInicio, iplazoVencimiento,dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo, pUsuario, TODAY);
                    END IF;
					FETCH selectQryCur INTO  iIdpromocion, cNombreEstrategia, cCanal, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, iCodEstatus;
				END WHILE;
			END IF;
			
            CLOSE selectQryCur;
            FREE selectQryCur;
            FREE stmtId;
            
            LET cCmd1 = '';	
            --SE REGISTRA EN BITACORA
            INSERT INTO {+INDEX (bdinvers:"informix".sv_camp_bitacora idx_sv_camp_bitacora)} bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto)
            VALUES (TODAY, CURRENT YEAR TO SECOND, pUsuario, 'CONSULTA DE CAMPAÃAS', 3, "CONSULTA DE CAMPAÃAS", pProducto);
        END IF;

            --AGREGAR PAGINADO
            --SUSTITUIR EN ORDER BY PoRDENAMIENTO
            --AGREGAR ASC O DESC
            --------TODO EN SENTENCIA PREPARADA
            
                

        IF pOrderBy = '2' THEN 

            IF pCampoOrden = 1 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion NVL(id_promocion,0),nombre_estrategia , canal , capital_min , capital_max , plazo_inicio , plazo_vencimiento, fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY id_promocion DESC
                    LET iRegistro = iRegistro + 1;
					
					IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
						ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
						ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
						END IF;
					ELSE
						LET cRequiereInstrApertura = 'NO';
						LET cInstrumentoApertura = '';
					END IF;
					
					IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
						LET cParCteNuevo = 'SI';
					ELSE
						LET cParCteNuevo = 'NO';
					END IF;
					
					IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
						LET cRequiereSdoNuevo = 'SI';
					ELSE
						LET cRequiereSdoNuevo = 'NO';
					END IF;
					
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
					cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH;

                ELIF pCampoOrden = 2 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),NVL(nombre_estrategia,0), CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY nombre_estrategia DESC
                    LET iRegistro = iRegistro + 1;
					
					IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
						ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
						ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
						END IF;
					ELSE
						LET cRequiereInstrApertura = 'NO';
						LET cInstrumentoApertura = '';
					END IF;
					
					IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
						LET cParCteNuevo = 'SI';
					ELSE
						LET cParCteNuevo = 'NO';
					END IF;
					
					IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
						LET cRequiereSdoNuevo = 'SI';
					ELSE
						LET cRequiereSdoNuevo = 'NO';
					END IF;
					
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
					cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
               END FOREACH;

            ELIF pCampoOrden = 3 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, NVL(CAST(canal AS INTEGER),0) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY (CASE canal
					WHEN 2 THEN 1
					WHEN 4 THEN 2
					WHEN 3 THEN 3
					WHEN 1 THEN 4
					ELSE 999
					END) * -1
                    LET iRegistro = iRegistro + 1;
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
					cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
               END FOREACH;

            ELIF pCampoOrden = 4 THEN 
				IF pProducto = '3000' THEN
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , NVL(CAST(plazo_inicio AS INTEGER),0) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY plazo_inicio DESC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
					
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
					
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				ELSE
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , NVL(CAST(plazo_inicio AS INTEGER),0) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY capital_min DESC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
					
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				END IF;
            ELIF pCampoOrden = 5 THEN
                IF pProducto = '3000' THEN
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , NVL(CAST(plazo_vencimiento AS INTEGER),0), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY plazo_vencimiento DESC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				ELSE 
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , NVL(CAST(plazo_vencimiento AS INTEGER),0), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY capital_max DESC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				END IF;

            ELIF pCampoOrden = 6 THEN 
                IF pProducto = '3000' THEN 
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , NVL(capital_min,0) , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY capital_min DESC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;

				ELSE 
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , NVL(capital_min,0) , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY fecha_inicio DESC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;

				END IF;
            ELIF pCampoOrden = 7 THEN 
                IF pProducto = '3000' THEN 
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , NVL(capital_max,0) , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY capital_max DESC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				ELSE
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , NVL(capital_max,0) , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY fecha_vencimiento DESC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				END IF;

            ELIF pCampoOrden = 8 THEN 
                IF pProducto = '3000' THEN 
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), NVL(fecha_inicio,0) , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY fecha_inicio DESC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				ELSE
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), NVL(fecha_inicio,0) , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY (CASE cod_estatus WHEN 1 THEN 1
						WHEN 2 THEN 2
						WHEN 0 THEN 3
						ELSE 999
						END) * -1
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				END IF;

            ELIF pCampoOrden = 9 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , NVL(fecha_vencimiento,0), tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY fecha_vencimiento DESC
                    LET iRegistro = iRegistro + 1;
					
					IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
						ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
						ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
						END IF;
					ELSE
						LET cRequiereInstrApertura = 'NO';
						LET cInstrumentoApertura = '';
					END IF;
					
					IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
						LET cParCteNuevo = 'SI';
					ELSE
						LET cParCteNuevo = 'NO';
					END IF;
					
					IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
						LET cRequiereSdoNuevo = 'SI';
					ELSE
						LET cRequiereSdoNuevo = 'NO';
					END IF;
						
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
					cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH;

            ELIF pCampoOrden = 10 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, NVL(tasa,0), gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY tasa DESC
                    LET iRegistro = iRegistro + 1;
					
					IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
						ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
						ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
						END IF;
					ELSE
						LET cRequiereInstrApertura = 'NO';
						LET cInstrumentoApertura = '';
					END IF;
					
					IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
						LET cParCteNuevo = 'SI';
					ELSE
						LET cParCteNuevo = 'NO';
					END IF;
					
					IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
						LET cRequiereSdoNuevo = 'SI';
					ELSE
						LET cRequiereSdoNuevo = 'NO';
					END IF;
						
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
					cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH;

            ELIF pCampoOrden = 11 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, NVL(gat_nominal,0), gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY gat_nominal DESC
                    LET iRegistro = iRegistro + 1;
					
					IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
						ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
						ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
						END IF;
					ELSE
						LET cRequiereInstrApertura = 'NO';
						LET cInstrumentoApertura = '';
					END IF;
					
					IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
						LET cParCteNuevo = 'SI';
					ELSE
						LET cParCteNuevo = 'NO';
					END IF;
					
					IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
						LET cRequiereSdoNuevo = 'SI';
					ELSE
						LET cRequiereSdoNuevo = 'NO';
					END IF;
						
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
					cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH;

            ELIF pCampoOrden = 12 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, NVL(gat_real,0), cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY gat_real DESC
                    LET iRegistro = iRegistro + 1;
					
					IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
						ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
						ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
						END IF;
					ELSE
						LET cRequiereInstrApertura = 'NO';
						LET cInstrumentoApertura = '';
					END IF;
					
					IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
						LET cParCteNuevo = 'SI';
					ELSE
						LET cParCteNuevo = 'NO';
					END IF;
					
					IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
						LET cRequiereSdoNuevo = 'SI';
					ELSE
						LET cRequiereSdoNuevo = 'NO';
					END IF;
						
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
					cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH;

            ELIF pCampoOrden = 13 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, NVL(cod_estatus,0), cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY (CASE cod_estatus WHEN 1 THEN 1
					WHEN 2 THEN 2
					WHEN 0 THEN 3
					ELSE 999
					END) * -1
                    LET iRegistro = iRegistro + 1;
					
					IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
						ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
						ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
						END IF;
					ELSE
						LET cRequiereInstrApertura = 'NO';
						LET cInstrumentoApertura = '';
					END IF;
					
					IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
						LET cParCteNuevo = 'SI';
					ELSE
						LET cParCteNuevo = 'NO';
					END IF;
					
					IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
						LET cRequiereSdoNuevo = 'SI';
					ELSE
						LET cRequiereSdoNuevo = 'NO';
					END IF;
						
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
					cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH;
            END IF;
        ELSE   
            IF pCampoOrden = 1 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion NVL(id_promocion,0),nombre_estrategia , canal , capital_min , capital_max , plazo_inicio , plazo_vencimiento, fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY id_promocion ASC
                    LET iRegistro = iRegistro + 1;
					
					IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
						ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
						ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
						END IF;
					ELSE
						LET cRequiereInstrApertura = 'NO';
						LET cInstrumentoApertura = '';
					END IF;
					
					IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
						LET cParCteNuevo = 'SI';
					ELSE
						LET cParCteNuevo = 'NO';
					END IF;
					
					IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
						LET cRequiereSdoNuevo = 'SI';
					ELSE
						LET cRequiereSdoNuevo = 'NO';
					END IF;
						
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH;

                ELIF pCampoOrden = 2 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),NVL(nombre_estrategia,0), CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY nombre_estrategia ASC
                    LET iRegistro = iRegistro + 1;
					
					IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
						ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
						ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
						END IF;
					ELSE
						LET cRequiereInstrApertura = 'NO';
						LET cInstrumentoApertura = '';
					END IF;
					
					IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
						LET cParCteNuevo = 'SI';
					ELSE
						LET cParCteNuevo = 'NO';
					END IF;
					
					IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
						LET cRequiereSdoNuevo = 'SI';
					ELSE
						LET cRequiereSdoNuevo = 'NO';
					END IF;
						
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH;

            ELIF pCampoOrden = 3 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, NVL(CAST(canal AS INTEGER),0) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY (CASE canal
					WHEN 2 THEN 1
					WHEN 4 THEN 2
					WHEN 3 THEN 3
					WHEN 1 THEN 4
					ELSE 999
					END) * 1
                    LET iRegistro = iRegistro + 1;
					
					IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
						ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
						ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
						END IF;
					ELSE
						LET cRequiereInstrApertura = 'NO';
						LET cInstrumentoApertura = '';
					END IF;
					
					IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
						LET cParCteNuevo = 'SI';
					ELSE
						LET cParCteNuevo = 'NO';
					END IF;
					
					IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
						LET cRequiereSdoNuevo = 'SI';
					ELSE
						LET cRequiereSdoNuevo = 'NO';
					END IF;
						
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH;

            ELIF pCampoOrden = 4 THEN 
                IF pProducto = '3000' THEN 
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , NVL(CAST(plazo_inicio AS INTEGER),0) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY plazo_inicio ASC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				ELSE
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , NVL(CAST(plazo_inicio AS INTEGER),0) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY capital_min ASC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				END IF;

            ELIF pCampoOrden = 5 THEN
                IF pProducto = '3000' THEN 
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , NVL(CAST(plazo_vencimiento AS INTEGER),0), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY plazo_vencimiento ASC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				ELSE 
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , NVL(CAST(plazo_vencimiento AS INTEGER),0), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY capital_max ASC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				END IF;

            ELIF pCampoOrden = 6 THEN 
                IF pProducto = '3000' THEN
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , NVL(capital_min,0) , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY capital_min ASC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				ELSE 
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , NVL(capital_min,0) , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY fecha_inicio ASC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				END IF;

            ELIF pCampoOrden = 7 THEN 
                IF pProducto = '3000' THEN 
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , NVL(capital_max,0) , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY capital_max ASC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				ELSE 
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , NVL(capital_max,0) , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY fecha_vencimiento ASC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				END IF;

            ELIF pCampoOrden = 8 THEN 
                IF pProducto = '3000' THEN 
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), NVL(fecha_inicio,0) , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY fecha_inicio ASC
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				ELSE 
					FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), NVL(fecha_inicio,0) , fecha_vencimiento, tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
						INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
						FROM "informix".sw_admintasas_pagare_estatus_temp
						WHERE usuario_insert = pUsuario
						ORDER BY (CASE cod_estatus WHEN 1 THEN 1
						WHEN 2 THEN 2
						WHEN 0 THEN 3
						ELSE 999
						END) * 1
						LET iRegistro = iRegistro + 1;
						
						IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
							IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
							ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
							ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
								LET cRequiereInstrApertura = 'SI';
								LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
							END IF;
						ELSE
							LET cRequiereInstrApertura = 'NO';
							LET cInstrumentoApertura = '';
						END IF;
						
						IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
							LET cParCteNuevo = 'SI';
						ELSE
							LET cParCteNuevo = 'NO';
						END IF;
						
						IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
							LET cRequiereSdoNuevo = 'SI';
						ELSE
							LET cRequiereSdoNuevo = 'NO';
						END IF;
						
						RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
					END FOREACH;
				END IF;

            ELIF pCampoOrden = 9 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , NVL(fecha_vencimiento,0), tasa, gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY fecha_vencimiento ASC
                    LET iRegistro = iRegistro + 1;
					
					IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
						ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
						ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
						END IF;
					ELSE
						LET cRequiereInstrApertura = 'NO';
						LET cInstrumentoApertura = '';
					END IF;
					
					IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
						LET cParCteNuevo = 'SI';
					ELSE
						LET cParCteNuevo = 'NO';
					END IF;
					
					IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
						LET cRequiereSdoNuevo = 'SI';
					ELSE
						LET cRequiereSdoNuevo = 'NO';
					END IF;
						
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH;

            ELIF pCampoOrden = 10 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, NVL(tasa,0), gat_nominal, gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY tasa ASC
                    LET iRegistro = iRegistro + 1;
					
					IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
						ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
						ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
						END IF;
					ELSE
						LET cRequiereInstrApertura = 'NO';
						LET cInstrumentoApertura = '';
					END IF;
					
					IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
						LET cParCteNuevo = 'SI';
					ELSE
						LET cParCteNuevo = 'NO';
					END IF;
					
					IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
						LET cRequiereSdoNuevo = 'SI';
					ELSE
						LET cRequiereSdoNuevo = 'NO';
					END IF;
						
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH;

            ELIF pCampoOrden = 11 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, NVL(gat_nominal,0), gat_real, cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY gat_nominal ASC
                    LET iRegistro = iRegistro + 1;
					
					IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
						ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
						ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
						END IF;
					ELSE
						LET cRequiereInstrApertura = 'NO';
						LET cInstrumentoApertura = '';
					END IF;
					
					IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
						LET cParCteNuevo = 'SI';
					ELSE
						LET cParCteNuevo = 'NO';
					END IF;
					
					IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
						LET cRequiereSdoNuevo = 'SI';
					ELSE
						LET cRequiereSdoNuevo = 'NO';
					END IF;
						
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH;

            ELIF pCampoOrden = 12 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, NVL(gat_real,0), cod_estatus, cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY gat_real ASC
                    LET iRegistro = iRegistro + 1;
					
					IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
						ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
						ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
						END IF;
					ELSE
						LET cRequiereInstrApertura = 'NO';
						LET cInstrumentoApertura = '';
					END IF;
					
					IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
						LET cParCteNuevo = 'SI';
					ELSE
						LET cParCteNuevo = 'NO';
					END IF;
					
					IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
						LET cRequiereSdoNuevo = 'SI';
					ELSE
						LET cRequiereSdoNuevo = 'NO';
					END IF;
						
                    RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH;

            ELIF pCampoOrden = 13 THEN 
                FOREACH
                    SELECT SKIP pRegistros FIRST pRecuperacion CAST(id_promocion AS INTEGER),nombre_estrategia, CAST(canal AS INTEGER) , capital_min , capital_max , CAST(plazo_inicio AS INTEGER) , CAST(plazo_vencimiento AS INTEGER), fecha_inicio , fecha_vencimiento, tasa, gat_nominal, gat_real, NVL(cod_estatus,0), cod_estatus_org, requiere_instruccion_apertura_cap, requiere_instruccion_apertura_int, dias_vigenciacte_nuevo, monto_saldo_nuevo 
                    INTO  iIdpromocion, cNombreEstrategia, cCanal,  dCapitalmin, dCapitalmax,   iplazoInicio, iplazoVencimiento, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, cInstrumentoVenCap, cInstrumentoVenInt, iDiasVigenciaCteNuevo, dMontoSdoNuevo
                    FROM "informix".sw_admintasas_pagare_estatus_temp
                    WHERE usuario_insert = pUsuario
                    ORDER BY (CASE cod_estatus WHEN 1 THEN 1
					WHEN 2 THEN 2
					WHEN 0 THEN 3
					ELSE 999
					END) * 1
                    LET iRegistro = iRegistro + 1;
					
					IF NVL(cInstrumentoVenCap,'') <> '' AND NVL(cInstrumentoVenInt,'') <> '' THEN 
						IF cInstrumentoVenCap = '01' AND cInstrumentoVenInt = '01' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION DE CAPITAL E INTERESES';
						ELIF NVL(cInstrumentoVenCap,'') = '02' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'TRASPASO DE CAPITAL E INTERESES A LA CUENTA';
						ELIF NVL(cInstrumentoVenCap,'') = '01' AND NVL(cInstrumentoVenInt,'') = '02' THEN
							LET cRequiereInstrApertura = 'SI';
							LET cInstrumentoApertura = 'REINVERSION CAPITAL / DEPOSITO INTERESES A CTA';							
						END IF;
					ELSE
						LET cRequiereInstrApertura = 'NO';
						LET cInstrumentoApertura = '';
					END IF;
					
					IF NVL(iDiasVigenciaCteNuevo,0) <> 0 THEN 
						LET cParCteNuevo = 'SI';
					ELSE
						LET cParCteNuevo = 'NO';
					END IF;
					
					IF NVL(dMontoSdoNuevo,0) <> 0 THEN 
						LET cRequiereSdoNuevo = 'SI';
					ELSE
						LET cRequiereSdoNuevo = 'NO';
					END IF;
						
                   RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
						cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
                END FOREACH;
            END IF;
        END IF;

        IF iRegistro = 0 AND pRegistros = 0 THEN
            LET cCodRet = '00017';
            LET iIdpromocion     = '';
            LET cNombreEstrategia = '';
            LET cCanal           = '';
            LET dCapitalmin      = '';
            LET dCapitalmax      = '';
            LET iplazoInicio     = 0;
            LET iplazoVencimiento = 0;
            LET dFechaInicio     = '';
            LET dFechaVencimiento = '';
            LET dTasa            = '';
            LET dGatNominal      = '';
            LET dGatReal         = '';
            LET iCodEstatus      = '';
            LET iCodEstatusOrg   = '';  

            RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
			cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
        END IF;

        IF iRegistro = 0 AND pRegistros > 0 THEN
            LET cCodRet = '1001';
			RETURN cCodRet, iIdpromocion, cNombreEstrategia, cCanal, iplazoInicio, iplazoVencimiento, dCapitalmin, dCapitalmax, dFechaInicio, dFechaVencimiento, dTasa, dGatNominal, dGatReal, iCodEstatus, iCodEstatusOrg, 
			cRequiereSdoNuevo, dMontoSdoNuevo, cRequiereInstrApertura, cInstrumentoApertura, cParCteNuevo, iDiasVigenciaCteNuevo WITH RESUME;
        END IF;
    END
END PROCEDURE    
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 02/09/2024',
'MODULO: DEBITO',
'FUNCIONALIDAD: CONSULTA DE CAMPAÃAS',
'DESCRIPCION: Procedimiento que se encarga de consultar las campaÃ±as promocionales del producto pagare de acuerdo los filtros propocionados por el cliente y se pinten de color donde:',
'Si el cod_estatus 0 = color rojo, cod_estatus 1 = color verde, cod_estatus 2 = color amarillo',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez',
'FECHA: 31/03/2025',
'DESCRIPCION: Se agregan validaciones para recuperar los datos para el producto 1100',
'AUTOR: Veronica Sanchez',
'FECHA: 01/12/2025',
'DESCRIPCION: Se agregan nuevos retornos para la recuperacion de 6 campos nuevos del producto 3000',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_admintasas_consultapagare_totales(pUsuario CHAR(9), 
                                                        pIdFuncion CHAR(8), 
                                                        pProducto CHAR(4), 
                                                        pEstatus SMALLINT, 
                                                        pIdPromocion INTEGER,
                                                        pNombrePromocion CHAR(100), 
                                                        pCanal SMALLINT, 
                                                        pCapitalMin DECIMAL(14,2), 
                                                        pCapitalMax DECIMAL(14,2), 
                                                        pFechaInicio DATE, 
                                                        pFechaVencimiento DATE,
                                                        pPlazo_inicio INTEGER, 
                                                        pPlazo_vencimiento INTEGER, 
                                                        pCampoOrden SMALLINT, 
                                                        pOrderBy SMALLINT)
RETURNING CHAR(5)       AS codret,
          INTEGER       AS total_reg; 

    
    DEFINE cCodRet              CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iRegistro            INTEGER;
    DEFINE cCmd1                CHAR(6500);
    DEFINE cNombreEstrategia    CHAR(100);
    

    LET cCodRet          = '00000';
    LET iSqlErr          = 0;
    LET iRegistro        = 0;
    LET cCmd1            = '';
    LET cNombreEstrategia = '';


    BEGIN

        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iRegistro;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
	
        IF pUsuario = '' OR pIdFuncion = '' OR pProducto = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iRegistro;
		END IF;

        --Validamos que el campo orden no exceda de los 13 registros
        IF pCampoOrden IS NOT NULL AND pCampoOrden NOT IN (1,2,3,4,5,6,7,8,9,10,11,12,13) THEN
            LET cCodRet = '00003';
			RETURN cCodRet, iRegistro;
        END IF;


		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iRegistro;
		END IF;


        /*IF pProducto <> '3000' OR pProducto <> '1100' THEN
            LET cCodRet = '00003';
			RETURN cCodRet, iRegistro;
        END IF;*/

        --SET DEBUG FILE TO '/admintasas/sp_admintasas_consultapagare_totales.out';
		--TRACE ON;
		
		IF pProducto = '3000' THEN -- VALIDACION PRODUCTO
			LET cCmd1 = "";
			LET cCmd1 = ""||TRIM(cCmd1)|| "SELECT p.nombre_estrategia";
			LET cCmd1 = ""||TRIM(cCmd1)|| " FROM bdinvers:sv_admintasas_pagare p INNER JOIN bdinvers:sv_admintasas_estatus s ON p.id_promocion = s.id_promocion AND s.fecha_cambio = (SELECT MAX(fecha_cambio) FROM bdinvers:sv_admintasas_estatus WHERE id_promocion = p.id_promocion)";
			LET cCmd1 = ""||TRIM(cCmd1)|| " WHERE 1=1";
	
			IF pIdPromocion IS NOT NULL OR pIdPromocion <> '' THEN
				LET cCmd1 = ""||TRIM(cCmd1)|| " AND p.id_promocion = '" || pIdPromocion ||"'";
			END IF;
	
			IF TRIM(pNombrePromocion) <> '' THEN
				LET cCmd1 = ""||TRIM(cCmd1)|| " AND p.nombre_estrategia = p.nombre_estrategia";
			END IF;
	
			IF pEstatus IS NOT NULL THEN
				LET cCmd1 = ""||TRIM(cCmd1)|| " AND cod_estatus = '" || pEstatus ||"'";
			END IF;
	
			IF pCanal IS NOT NULL THEN
				LET cCmd1 = ""||TRIM(cCmd1)|| " AND canal = '" || pCanal ||"'";
			END IF;
	
			IF pCapitalMin IS NOT NULL AND pCapitalMax IS NOT NULL THEN
				LET cCmd1 = ""||TRIM(cCmd1)|| " AND (capital_min >= " || pCapitalMin || "AND capital_min <= "|| pCapitalMax ||") AND (capital_max <= " || pCapitalMax || " AND capital_max >= " || pCapitalMin||")";
			END IF;
	
			IF pPlazo_inicio IS NOT NULL AND pPlazo_vencimiento IS NOT NULL THEN
				LET cCmd1 = ""||TRIM(cCmd1)|| " AND (plazo_inicio >= " || pPlazo_inicio || " AND plazo_vencimiento <= " || pPlazo_vencimiento || ")";
			END IF;
	
			IF pFechaInicio IS NOT NULL AND pFechaVencimiento IS NOT NULL THEN
				LET cCmd1 = ""||TRIM(cCmd1)|| " AND (fecha_inicio BETWEEN '" || pFechaInicio ||"' AND '" || pFechaVencimiento || "') AND fecha_vencimiento <= '"||pFechaVencimiento||"'";
			END IF;
		ELSE -- Producto 1100
			LET cCmd1 = ""||TRIM(cCmd1)|| "SELECT p.nombre_estrategia";
			LET cCmd1 = ""||TRIM(cCmd1)|| " FROM bdicheq:sc_admintasas_invcreciente p INNER JOIN bdicheq:sc_admintasas_inv_estatus s ON p.id_promocion = s.id_promocion AND s.fecha_cambio = (SELECT MAX(fecha_cambio) FROM bdicheq:sc_admintasas_inv_estatus WHERE id_promocion = p.id_promocion)";
			LET cCmd1 = ""||TRIM(cCmd1)|| " WHERE 1=1";
			
			IF pIdPromocion IS NOT NULL OR pIdPromocion <> '' THEN
				LET cCmd1 = ""||TRIM(cCmd1)|| " AND p.id_promocion = '" || pIdPromocion ||"'";
			END IF;
	
			IF TRIM(pNombrePromocion) <> '' THEN
				LET cCmd1 = ""||TRIM(cCmd1)|| " AND p.nombre_estrategia = p.nombre_estrategia";
			END IF;
	
			IF pEstatus IS NOT NULL THEN
				LET cCmd1 = ""||TRIM(cCmd1)|| " AND s.cod_estatus = '" || pEstatus ||"'";
			END IF;
	
			IF pFechaInicio IS NOT NULL AND pFechaVencimiento IS NOT NULL THEN
				LET cCmd1 = ""||TRIM(cCmd1)|| " AND (p.fecha_inicio BETWEEN '" || pFechaInicio ||"' AND '" || pFechaVencimiento || "') AND p.fecha_vencimiento <= '"||pFechaVencimiento||"'";
			END IF;
		
		END IF;
			
		
        IF pCampoOrden IS NULL AND (pOrderBy = 1 OR pOrderBy = '') THEN
            LET cCmd1 = ""||TRIM(cCmd1)|| " ORDER BY id_promocion ASC";
        END IF;

        IF pCampoOrden IS NULL AND pOrderBy = 2 THEN
            LET cCmd1 = ""||TRIM(cCmd1)|| " ORDER BY id_promocion DESC";
        END IF;

        LET cCmd1 = ""||TRIM(cCmd1)|| " ORDER BY " || 1 ||"  ASC";
		
		--- Ajuste
		IF pNombrePromocion <> '' THEN
			LET pNombrePromocion  = "%" || UPPER(TRIM(pNombrePromocion)) || "%";
		END IF;

		PREPARE stmtId FROM TRIM(cCmd1);
		DECLARE selectQryCur CURSOR FOR stmtId;
		OPEN selectQryCur;
		FETCH selectQryCur INTO cNombreEstrategia;



        WHILE(SQLCODE == 0)	
            IF pNombrePromocion <> '' THEN
                LET cNombreEstrategia = UPPER(TRIM(cNombreEstrategia));
                --LET pNombrePromocion  = "%" || UPPER(TRIM(pNombrePromocion)) || "%";

                IF cNombreEstrategia LIKE pNombrePromocion THEN
                    LET iRegistro = iRegistro + 1;
                END IF;
            ELSE
                LET iRegistro = iRegistro + 1;
            END IF;

            IF iRegistro < 0 THEN
                LET iRegistro = 0;
            END IF;

			FETCH selectQryCur INTO  cNombreEstrategia;
		END WHILE;
			
		CLOSE selectQryCur;
		FREE selectQryCur;
		FREE stmtId;
		
		LET cCmd1 = '';	

        IF NVL(iRegistro, 0) = 0 THEN
            LET cCodRet = '00017';
            
        END IF;

        RETURN cCodRet, iRegistro;
    END
END PROCEDURE    
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 02/09/2024',
'MODULO: DEBITO',
'FUNCIONALIDAD: CONSULTA DE CAMPAÃAS',
'DESCRIPCION: Procedimiento que se encarga de consultar el total de las campaÃ±as promocionales del producto pagare de acuerdo los filtros propocionados por el cliente ',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez',
'FECHA: 31/03/2025',
'DESCRIPCION: Se agregan validaciones para recuperar los datos para el producto 1100',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_capturaeactulizagat(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera CHAR(1), pFecha DATE, pProducto CHAR(4), pTasa DECIMAL(9,6), pGatNominal DECIMAL(9,6), pGatReal DECIMAL(9,6), pPlazaInicio INTEGER, pPlazaFin INTEGER, pPeriodo INTEGER, pRowId INTEGER)
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE dTasa DECIMAL(9,6);
	DEFINE dFechaMax DATE;
	DEFINE iRowID INTEGER;
	-- NUEVO
	DEFINE dGatReal DECIMAL(9,6);
	DEFINE dGatNominal DECIMAL(9,6);
	DEFINE iPeriodo	INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET dTasa = 0.00;
	LET dFechaMax = '';
	LET iRowID = 0;
	-- NUEVO 
	LET dGatReal = 0;
	LET dGatNominal = 0;
	LET iPeriodo = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/sp_cap_capturaeactulizagat.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pBandera = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;		
		
		-- actualiza e inserta inversion creciente
		IF pBandera = '1' THEN 		-- inv creciente
			/*SELECT  MAX(fecha_publicacion), MAX(rowid)
			INTO dFechaMax, iRowID
			FROM bdicheq:"informix".sc_gat 
			WHERE producto = pProducto;
		
			SELECT  tasa
			INTO dTasa
			FROM bdicheq:"informix".sc_gat 
			WHERE producto = pProducto
			AND fecha_publicacion = dFechaMax
			AND rowid = iRowID;
			
			IF dFechaMax <> pFecha THEN 
				LET cCodRet = '00133';
			END IF;*/
			
			SELECT COUNT(*)
			INTO iRowID
			FROM bdicheq:"informix".sc_gat 
			WHERE producto = pProducto 
			AND rowid = pRowId;
						
			IF NVL(iRowID,0) <> 0 THEN 	
				
				SELECT tasa, gat_nominal, gat_real, periodo
				INTO dTasa, dGatReal, dGatNominal, iPeriodo
				FROM bdicheq:"informix".sc_gat 
				WHERE producto = pProducto
				AND rowid = pRowId;
				
				IF dTasa <> pTasa THEN 
					INSERT INTO bdinteg:"informix".si_bitacoraprod1100 (valor_ant, valor_nuevo, usuario_modifica, fecha_modifica) 
					VALUES (dTasa, pTasa, pUsuario, CURRENT);
				END IF;
				
				IF dGatReal <> pGatReal THEN 
					INSERT INTO bdinteg:"informix".si_bitacoraprod1100 (valor_ant, valor_nuevo, usuario_modifica, fecha_modifica) 
					VALUES (dGatReal, pGatReal, pUsuario, CURRENT);
				END IF;
				
				IF dGatNominal <> pGatNominal THEN 
					INSERT INTO bdinteg:"informix".si_bitacoraprod1100 (valor_ant, valor_nuevo, usuario_modifica, fecha_modifica)
					VALUES (dGatNominal, pGatNominal, pUsuario, CURRENT);
				END IF;
				
				IF iPeriodo <> pPeriodo THEN 
					INSERT INTO bdinteg:"informix".si_bitacoraprod1100 (valor_ant, valor_nuevo, usuario_modifica, fecha_modifica)
					VALUES (iPeriodo, pPeriodo, pUsuario, CURRENT);
				END IF;
					
				UPDATE bdicheq:"informix".sc_gat
				SET tasa = pTasa, gat_nominal = pGatNominal, gat_real = pGatReal, periodo = pPeriodo
				WHERE producto = pProducto
				--AND fecha_publicacion = dFechaMax
				AND rowid = pRowId;
								
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00283';
					RETURN cCodRet;
				END IF;
			
			ELSE 
				INSERT INTO bdicheq:"informix".sc_gat (producto, tasa, gat_nominal, gat_real, fecha_publicacion, periodo)
				VALUES (pProducto, pTasa, pGatNominal, pGatReal, CURRENT, pPeriodo);
				RETURN cCodRet;
				
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00282';
					RETURN cCodRet;
				END IF;
				
			END IF;
			
		ELIF pBandera = '2' THEN  --
			
			UPDATE bdicheq:"informix".sc_gat
				SET gat_nominal = pGatNominal, gat_real = pGatReal, tasa = pTasa, periodo = pPeriodo
				WHERE producto = pProducto
				AND fecha_publicacion = pFecha
				AND rowid = pRowId;
							
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00283';
				RETURN cCodRet;
			END IF;
		
		ELIF pBandera = '3' THEN -- producto pagare
		
			UPDATE bdinvers:"informix".sv_gat
				SET gat_nomina = pGatNominal, gat_real = pGatReal, tasa = pTasa, periodo = pPeriodo
				WHERE plazo_inicio = pPlazaInicio
				AND plazo_fin = pPlazaFin
				AND rowid = pRowId;
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00283';
				RETURN cCodRet;
			END IF;
		END IF;
		
		RETURN cCodRet;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 09/08/2016',
'MODULO: DeBITO',
'FUNCIONALIDAD: MANTENIMIENTOS GAT',
'DESCRIPCION: SPL que realiza la actualizacion e insercion de los registros de inversion creciente, cuenta jovenes y producto pagare ',
'AUTOR: ING. JOSÃ ANTONIO RAMÃREZ FRANCO',
'FECHA: 30/06/2023',
'DESCRIPCION: Se realizo una actualizaciÃ³n a los updates ahora actualiza el nuevo campo de periodo',
'AUTOR: VERONICA SANCHEZ TLACOMULCO',
'FECHA: 19/11/2025',
'DESCRIPCION: Se agresa insert a tabla de bitacoreo para actualizacion de datos del producto 1100',
'AUTOR: VERONICA SANCHEZ TLACOMULCO',
'FECHA: 26/01/2026',
'DESCRIPCION: Se ajusta seccion de producto 1100, para actualizar el valor de la tasa',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_cuentascanceladas(id_usuarioc CHAR(8), id_funcionc CHAR(10), pBandera CHAR(2), pNumCte CHAR(20), pCuenta CHAR(20), pFechaCancelacion CHAR(20), pUsuarioCancela CHAR(8),
													pRegistro INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret, 
			  CHAR(20) AS no_cliente, 
			  CHAR(120) AS nombre_cliente, 
			  CHAR(20) AS no_cuenta, 
			  CHAR(20) AS fecha_ultimo_mov, 
			  DECIMAL(9,2) AS saldo, 
			  CHAR(1) AS cte_notificado, 
			  CHAR(20) AS fecha_cancelacion, 
			  CHAR(40) AS folio_cancelacion, 
			  CHAR(8) AS usuario_cancelacion,
			  CHAR(15) AS status_ant;
	
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE v_TotalRegistros INTEGER;
	
	DEFINE v_NoCliente CHAR(20);
	DEFINE v_NoCuenta CHAR(20);
	DEFINE v_RazonSocial CHAR(120);
	DEFINE v_FechaUltimoMov DATE;
	DEFINE v_Saldo DECIMAL(9,2);
	DEFINE v_ClienteNotificado BOOLEAN;
	DEFINE v_Contador INTEGER;
	DEFINE v_FechaCancelacion CHAR(20);
	DEFINE v_FolioCancelacion CHAR(40);
	DEFINE v_UsuarioCancelacion CHAR(8);
	DEFINE status_ant CHAR(15);
	DEFINE cIdStatusAnt	CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET v_TotalRegistros = 0;
	
	LET v_NoCliente = '';
	LET v_NoCuenta = '';
	LET v_RazonSocial = '';
	LET v_FechaUltimoMov = TODAY;
	LET v_Saldo = 0;
	LET v_ClienteNotificado = 'f';
	LET v_Contador = 0;
	LET v_FechaCancelacion = '';
	LET v_FolioCancelacion = '';
	LET v_UsuarioCancelacion = '';
	LET status_ant = '';
	LET cIdStatusAnt = '';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, v_NoCliente, v_RazonSocial, v_NoCuenta, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, v_FechaCancelacion, v_FolioCancelacion, v_UsuarioCancelacion, status_ant;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/home/mfinis/EAPT/sp_extrae_cuentascan.out';
		-- TRACE ON;
		
		IF pBandera='' OR id_usuarioc = '' OR id_funcionc = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, v_NoCliente, v_RazonSocial, v_NoCuenta, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, v_FechaCancelacion, v_FolioCancelacion, v_UsuarioCancelacion, status_ant;
		END IF;		
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(id_usuarioc, id_funcionc) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, v_NoCliente, v_RazonSocial, v_NoCuenta, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, v_FechaCancelacion, v_FolioCancelacion, v_UsuarioCancelacion, status_ant;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pBandera = '1' THEN
			FOREACH
				SELECT SKIP pRegistro FIRST pRecuperacion canc.no_cliente, canc.no_cuenta, cliente.razon_social, canc.fec_ultimo_mov, canc.saldo, canc.cliente_notificado, canc.status_ant
				INTO v_NoCliente, v_NoCuenta, v_RazonSocial, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, cIdStatusAnt
				FROM bdinteg:si_cliente cliente 
				INNER JOIN bdicheq:si_cliente_cancela_notifica canc ON cliente.numcte = canc.no_cliente 
				WHERE canc.status = '0' OR canc.status IS NULL or canc.status = ''
				
				IF cIdStatusAnt = '1' THEN
					LET status_ant = "ACTIVA";
				ELIF cIdStatusAnt = '2' THEN 
					LET status_ant = "CANCELADA";
				ELIF cIdStatusAnt = '3' THEN
					LET status_ant = "BLOQUEADA";
				ELIF cIdStatusAnt = '4' THEN 
					LET status_ant = "INACTIVA";
				ELIF cIdStatusAnt = '5' THEN 
					LET status_ant = "INFORMADA";
				ELIF cIdStatusAnt = '6' THEN 
					LET status_ant = "CONCENTRADA";
				ELIF cIdStatusAnt = '7' THEN 
					LET status_ant = "BENEFICIENCIA";
				ELIF cIdStatusAnt = '8' THEN 
					LET status_ant = "DESCONCENTRADA";
				END IF;
				
				LET v_Contador = v_Contador + 1;
				RETURN cCodRet, v_NoCliente, v_RazonSocial, v_NoCuenta, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, v_FechaCancelacion, v_FolioCancelacion, v_UsuarioCancelacion, status_ant WITH RESUME;
			END FOREACH;
			IF v_Contador = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, v_NoCliente, v_RazonSocial, v_NoCuenta, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, v_FechaCancelacion, v_FolioCancelacion, v_UsuarioCancelacion, status_ant;
			END IF;
			
		ELIF pBandera = '2' THEN
		
			IF pNumCte IS NOT NULL AND pNumCte <> '' THEN
				FOREACH
					SELECT SKIP pRegistro FIRST pRecuperacion canc.no_cliente, canc.no_cuenta, cliente.razon_social, canc.fec_ultimo_mov, canc.saldo, canc.cliente_notificado, canc.fecha_cancelacion, canc.folio_cancelacion, canc.usuario_cancela, canc.status_ant
					INTO v_NoCliente, v_NoCuenta, v_RazonSocial, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, v_FechaCancelacion, v_FolioCancelacion, v_UsuarioCancelacion, cIdStatusAnt
					FROM bdinteg:si_cliente cliente
					INNER JOIN bdicheq:si_cliente_cancela_notifica canc ON cliente.numcte = canc.no_cliente
					WHERE canc.status = '2' and no_cliente = pNumCte
					
					IF cIdStatusAnt = '1' THEN
						LET status_ant = "ACTIVA";
					ELIF cIdStatusAnt = '2' THEN 
						LET status_ant = "CANCELADA";
					ELIF cIdStatusAnt = '3' THEN 
						LET status_ant = "BLOQUEADA";
					ELIF cIdStatusAnt = '4' THEN 
						LET status_ant = "INACTIVA";
					ELIF cIdStatusAnt = '5' THEN 
						LET status_ant = "INFORMADA";
					ELIF cIdStatusAnt = '6' THEN 
						LET status_ant = "CONCENTRADA";
					ELIF cIdStatusAnt = '7' THEN 
						LET status_ant = "BENEFICIENCIA";
					ELIF cIdStatusAnt = '8' THEN 
						LET status_ant = "DESCONCENTRADA";
					END IF;
				
					LET v_Contador = v_Contador + 1;
					RETURN cCodRet, v_NoCliente, v_RazonSocial, v_NoCuenta, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, v_FechaCancelacion, v_FolioCancelacion, v_UsuarioCancelacion, status_ant WITH RESUME;
				END FOREACH;
			ELIF pCuenta IS NOT NULL AND pCuenta <> '' THEN
				FOREACH
					SELECT SKIP pRegistro FIRST pRecuperacion canc.no_cliente, canc.no_cuenta, cliente.razon_social, canc.fec_ultimo_mov, canc.saldo, canc.cliente_notificado, canc.fecha_cancelacion, canc.folio_cancelacion, canc.usuario_cancela, canc.status_ant
					INTO v_NoCliente, v_NoCuenta, v_RazonSocial, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, v_FechaCancelacion, v_FolioCancelacion, v_UsuarioCancelacion, cIdStatusAnt
					FROM bdinteg:si_cliente cliente
					INNER JOIN bdicheq:si_cliente_cancela_notifica canc ON cliente.numcte = canc.no_cliente
					WHERE canc.status = '2' and no_cuenta = pCuenta
					
					IF cIdStatusAnt = '1' THEN
						LET status_ant = "ACTIVA";
					ELIF cIdStatusAnt = '2' THEN 
						LET status_ant = "CANCELADA";
					ELIF cIdStatusAnt = '3' THEN 
						LET status_ant = "BLOQUEADA";
					ELIF cIdStatusAnt = '4' THEN 
						LET status_ant = "INACTIVA";
					ELIF cIdStatusAnt = '5' THEN 
						LET status_ant = "INFORMADA";
					ELIF cIdStatusAnt = '6' THEN 
						LET status_ant = "CONCENTRADA";
					ELIF cIdStatusAnt = '7' THEN 
						LET status_ant = "BENEFICIENCIA";
					ELIF cIdStatusAnt = '8' THEN 
						LET status_ant = "DESCONCENTRADA";
					END IF;
					
					LET v_Contador = v_Contador + 1;
					RETURN cCodRet, v_NoCliente, v_RazonSocial, v_NoCuenta, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, v_FechaCancelacion, v_FolioCancelacion, v_UsuarioCancelacion, status_ant WITH RESUME;
				END FOREACH;
			ELIF pFechaCancelacion IS NOT NULL AND pFechaCancelacion <> '' THEN
				FOREACH
					SELECT SKIP pRegistro FIRST pRecuperacion canc.no_cliente, canc.no_cuenta, cliente.razon_social, canc.fec_ultimo_mov, canc.saldo, canc.cliente_notificado, canc.fecha_cancelacion, canc.folio_cancelacion, canc.usuario_cancela, canc.status_ant
					INTO v_NoCliente, v_NoCuenta, v_RazonSocial, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, v_FechaCancelacion, v_FolioCancelacion, v_UsuarioCancelacion, cIdStatusAnt
					FROM bdinteg:si_cliente cliente
					INNER JOIN bdicheq:si_cliente_cancela_notifica canc ON cliente.numcte = canc.no_cliente
					WHERE canc.status = '2' and fecha_cancelacion = pFechaCancelacion
					
					IF cIdStatusAnt = '1' THEN
						LET status_ant = "ACTIVA";
					ELIF cIdStatusAnt = '2' THEN 
						LET status_ant = "CANCELADA";
					ELIF cIdStatusAnt = '3' THEN 
						LET status_ant = "BLOQUEADA";
					ELIF cIdStatusAnt = '4' THEN 
						LET status_ant = "INACTIVA";
					ELIF cIdStatusAnt = '5' THEN 
						LET status_ant = "INFORMADA";
					ELIF cIdStatusAnt = '6' THEN 
						LET status_ant = "CONCENTRADA";
					ELIF cIdStatusAnt = '7' THEN 
						LET status_ant = "BENEFICIENCIA";
					ELIF cIdStatusAnt = '8' THEN 
						LET status_ant = "DESCONCENTRADA";
					END IF;
					
					LET v_Contador = v_Contador + 1;
					RETURN cCodRet, v_NoCliente, v_RazonSocial, v_NoCuenta, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, v_FechaCancelacion, v_FolioCancelacion, v_UsuarioCancelacion, status_ant WITH RESUME;
				END FOREACH;
			ELIF pUsuarioCancela IS NOT NULL AND pUsuarioCancela <> '' THEN
				FOREACH
					SELECT SKIP pRegistro FIRST pRecuperacion canc.no_cliente, canc.no_cuenta, cliente.razon_social, canc.fec_ultimo_mov, canc.saldo, canc.cliente_notificado, canc.fecha_cancelacion, canc.folio_cancelacion, canc.usuario_cancela, canc.status_ant
					INTO v_NoCliente, v_NoCuenta, v_RazonSocial, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, v_FechaCancelacion, v_FolioCancelacion, v_UsuarioCancelacion, cIdStatusAnt
					FROM bdinteg:si_cliente cliente
					INNER JOIN bdicheq:si_cliente_cancela_notifica canc ON cliente.numcte = canc.no_cliente
					WHERE canc.status = '2' and usuario_cancela = pUsuarioCancela
					
					IF cIdStatusAnt = '1' THEN
						LET status_ant = "ACTIVA";
					ELIF cIdStatusAnt = '2' THEN 
						LET status_ant = "CANCELADA";
					ELIF cIdStatusAnt = '3' THEN 
						LET status_ant = "BLOQUEADA";
					ELIF cIdStatusAnt = '4' THEN 
						LET status_ant = "INACTIVA";
					ELIF cIdStatusAnt = '5' THEN 
						LET status_ant = "INFORMADA";
					ELIF cIdStatusAnt = '6' THEN 
						LET status_ant = "CONCENTRADA";
					ELIF cIdStatusAnt = '7' THEN 
						LET status_ant = "BENEFICIENCIA";
					ELIF cIdStatusAnt = '8' THEN 
						LET status_ant = "DESCONCENTRADA";
					END IF;
					
					LET v_Contador = v_Contador + 1;
					RETURN cCodRet, v_NoCliente, v_RazonSocial, v_NoCuenta, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, v_FechaCancelacion, v_FolioCancelacion, v_UsuarioCancelacion,status_ant WITH RESUME;
				END FOREACH;
			END IF
			
			IF pRegistro = 0 AND v_Contador = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, v_NoCliente, v_RazonSocial, v_NoCuenta, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, v_FechaCancelacion, v_FolioCancelacion, v_UsuarioCancelacion, status_ant;
			END IF;
			
			IF pRegistro > 0 AND v_Contador = 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, v_NoCliente, v_RazonSocial, v_NoCuenta, v_FechaUltimoMov, v_Saldo, v_ClienteNotificado, v_FechaCancelacion, v_FolioCancelacion, v_UsuarioCancelacion, status_ant;
			END IF;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Eduardo Ãvila PÃ©rez Tagle',
'FECHA: 24/09/2025',
'Requerimiento: RQM 20 129 DEF AutomatizaciÃ³n de cancelaciÃ³n de cuentas inactivas',
'DESCRIPCION: Procedimiento encargado de realizar la cancelacion de las cuentass',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_cuentascanceladas_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera CHAR(2), pNumCte CHAR(20), pCuenta CHAR(20), pFechaCancelacion DATE, pUsuarioCancela CHAR(8))
	RETURNING CHAR(5) AS codret, INTEGER as total_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE v_TotalRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET v_TotalRegistros = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, v_TotalRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/vero/cancelacion/sp_cap_cuentascanceladas_totales.out';
		--TRACE ON;
		
		IF pBandera='' OR pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, v_TotalRegistros;
		END IF;		
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, v_TotalRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pBandera = '1' THEN
			SELECT COUNT(*) 
			INTO v_TotalRegistros 
			FROM bdicheq:si_cliente_cancela_notifica 
			WHERE (status = 0 OR status IS NULL OR status = '') AND cliente_notificado = 't'; 
			IF NVL(v_TotalRegistros,0) = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, v_TotalRegistros;
			ELSE
				RETURN cCodRet, v_TotalRegistros;
			END IF;
		ELIF pBandera = '2' THEN
			IF pNumCte <> '' THEN
				SELECT COUNT(*) 
				INTO v_TotalRegistros 
				FROM bdicheq:si_cliente_cancela_notifica 
				WHERE status = 2 and no_cliente = pNumCte; 
				IF NVL(v_TotalRegistros,0) = 0 THEN
					LET cCodRet = '00017';
					RETURN cCodRet, v_TotalRegistros;
				ELSE
					RETURN cCodRet, v_TotalRegistros;
				END IF;
			END IF;
			IF pCuenta <> '' THEN
				SELECT COUNT(*) 
				INTO v_TotalRegistros 
				FROM bdicheq:si_cliente_cancela_notifica 
				WHERE status = 2 and no_cuenta = pCuenta; 
				IF NVL(v_TotalRegistros,0) = 0 THEN
					LET cCodRet = '00017';
					RETURN cCodRet, v_TotalRegistros;
				ELSE
					RETURN cCodRet, v_TotalRegistros;
				END IF;
			END IF;
			IF pFechaCancelacion IS NOT NULL THEN
				SELECT COUNT(*) 
				INTO v_TotalRegistros 
				FROM bdicheq:si_cliente_cancela_notifica 
				WHERE status = 2 and fecha_cancelacion = pFechaCancelacion; 
				IF NVL(v_TotalRegistros,0) = 0 THEN
					LET cCodRet = '00017';
					RETURN cCodRet, v_TotalRegistros;
				ELSE
					RETURN cCodRet, v_TotalRegistros;
				END IF;
			END IF;
			IF pUsuarioCancela <> '' THEN
				SELECT COUNT(*) 
				INTO v_TotalRegistros 
				FROM bdicheq:si_cliente_cancela_notifica 
				WHERE status = 2 and usuario_cancela = pUsuarioCancela; 
				IF NVL(v_TotalRegistros,0) = 0 THEN
					LET cCodRet = '00017';
					RETURN cCodRet, v_TotalRegistros;
				ELSE
					RETURN cCodRet, v_TotalRegistros;
				END IF;
			END IF;
		END IF;
		RETURN cCodRet, v_TotalRegistros;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Eduardo Ãvila PÃ©rez Tagle',
'FECHA: 24/09/2025',
'Requerimiento: RQM 20 129 DEF AutomatizaciÃ³n de cancelaciÃ³n de cuentas inactivas',
'DESCRIPCION: Procedimiento almacenado de recuperar el total de registros de las cuentas canceladad y no canceladas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_genrep_ctascanceladas(pUsuario CHAR(8), pIdFuncion CHAR(10), pRutaDescarga CHAR(150), pNumCte CHAR(20), pNumCta CHAR(20), pFechaCancelacion CHAR(20), 
																	pUsuarioCancelacion CHAR(20))
	RETURNING CHAR(5) AS codret,
			  CHAR(150) AS nomArchivo;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCmd1 CHAR(5000);
	DEFINE cSql CHAR(5000);
	DEFINE cRutaInformix CHAR(100);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreReporte CHAR(150);
	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCmd1 = '';
	LET cSql = '';
	--Ruta Desarollo
	--LET cRutaInformix = '/informix/bin/';
	--Ruta Produccion
	LET cRutaInformix = '/ifxsif01/bin/';
	LET cRutaGral = '';
	LET cNombreReporte = '';


	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombreReporte;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cap_genrep_ctascanceladas.out';
		--TRACE ON;

		IF pUsuario = '' OR pRutaDescarga = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreReporte;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombreReporte;
		END IF;

		-- SE ASIGNAN VALORES PARA LA GENERACION DEL REPORTE
		LET cNombreReporte = 'REPORTE_CUENTAS_CANCELADAS_'||TO_CHAR(CURRENT,'%Y%m%d')||'.xls'; --.csv .txt
		
		LET cCmd1 ="";
		LET cCmd1 =""||TRIM(cCmd1)||" SELECT 'NO. CLIENTE','NOMBRE CLIENTE','NO. CUENTA','ESTATUS ANTES CANCELACION','ESTATUS ACTUAL','FECHA ULTIMO MOVIMIENTO','SALDO','CLIENTE NOTIFICADO','FECHA CANCELACION','FOLIO CANCELACION','USUARIO CANCELACION' FROM systables WHERE tabid = 1 ";
		LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL";
		LET cCmd1 =""||TRIM(cCmd1)||" SELECT cliente.numcte, cliente.razon_social, ''''||cliente_notifica.no_cuenta, CASE WHEN cliente_notifica.status_ant = 1 THEN 'ACTIVA' WHEN cliente_notifica.status_ant = 4 THEN 'INACTIVA' ";
		LET cCmd1 =""||TRIM(cCmd1)||" WHEN cliente_notifica.status_ant = 6 THEN 'CONCENTRADA' WHEN cliente_notifica.status_ant = 7 THEN 'BENEFICIENCIA' WHEN cliente_notifica.status_ant = 8 THEN 'DESCONCENTRADA' ELSE '' END CASE, 'CANCELADO',TO_CHAR(cliente_notifica.fec_ultimo_mov,'%d/%m/%Y'), TO_CHAR(cliente_notifica.saldo), ";
		LET cCmd1 =""||TRIM(cCmd1)||" CASE WHEN cliente_notificado = 'f' THEN 'NO' ELSE 'SI' END, TO_CHAR(cliente_notifica.fecha_cancelacion,'%d/%m/%Y'), ''''||cliente_notifica.folio_cancelacion,  ";
		LET cCmd1 =""||TRIM(cCmd1)||" cliente_notifica.usuario_cancela FROM bdinteg:si_cliente cliente ";
		LET cCmd1 =""||TRIM(cCmd1)||" INNER JOIN bdicheq:si_cliente_cancela_notifica cliente_notifica ON cliente.numcte = cliente_notifica.no_cliente ";
		LET cCmd1 =""||TRIM(cCmd1)||" WHERE cliente_notifica.status = '2'";
		
		IF pNumCte <> '' THEN
			LET cCmd1 =""||TRIM(cCmd1)||" AND cliente.numcte = '"||TRIM(pNumCte)||"'";
		END IF;
		IF pNumCta <> '' THEN
			LET cCmd1 =""||TRIM(cCmd1)||" AND cliente_notifica.no_cuenta = '"||TRIM(pNumCta)||"'";
		END IF;
		IF pFechaCancelacion <> '' THEN
			LET cCmd1 =""||TRIM(cCmd1)||" AND cliente_notifica.fecha_cancelacion = '"||TRIM(pFechaCancelacion)||"'";
		END IF;
		IF pUsuarioCancelacion <> '' THEN
			LET cCmd1 =""||TRIM(cCmd1)||" AND cliente_notifica.usuario_cancela = '"||TRIM(pUsuarioCancelacion)||"'";
		END IF;
		
		--LET cCmd1 =""||TRIM(cCmd1)||" ";
		
		
		LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
		LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreReporte);

		LET cSql = '';
		LET cSql = '/usr/bin/echo "UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER '|| '''	'''|| ' ' ||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'queryRepCuentasCanceladas.sql';
		SYSTEM TRIM(cSql);

		--LET cSql = '';
		--LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'queryRepCuentasCanceladas.sql';
		--SYSTEM TRIM(cSql);

		LET cSql = '';		--Cambiar Base de datos segun el reporte
		LET cSql = TRIM(cRutaInformix)||'dbaccess bdicnweb '||TRIM(pRutaDescarga)||'queryRepCuentasCanceladas.sql';
		SYSTEM TRIM(cSql);

		--LET cSql = '';
		--LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'queryRepCuentasCanceladas.sql';
		--SYSTEM TRIM(cSql);

		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGral);
		SYSTEM TRIM(cSql);


		RETURN cCodRet, cNombreReporte;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Eduardo Ãvila PÃ©rez Tagle',
'FECHA: 24/09/2025',
'Requerimiento: RQM 20 129 DEF AutomatizaciÃ³n de cancelaciÃ³n de cuentas inactivas',
'DESCRIPCION: Procedimiento almacenado encargado de generar el reporte de las cuentas canceladas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cap_genrep_ctasnocanceladas(pUsuario CHAR(8), pIdFuncion CHAR(10), pRutaDescarga CHAR(150))
	RETURNING CHAR(5) AS codret,
			  CHAR(150) AS nomArchivo;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCmd1 CHAR(5000);
	DEFINE cSql CHAR(5000);
	DEFINE cRutaInformix CHAR(100);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreReporte CHAR(150);
	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCmd1 = '';
	LET cSql = '';
	--Ruta Desarollo
	--LET cRutaInformix = '/informix/bin/';
	--Ruta Produccion
	LET cRutaInformix = '/ifxsif01/bin/';
	LET cRutaGral = '';
	LET cNombreReporte = '';


	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombreReporte;
		END EXCEPTION;

		SET DEBUG FILE TO '/tmp/mfinis/sp_cap_genrep_ctasnocanceladas.out';
		TRACE ON;

		IF pUsuario = '' OR pRutaDescarga = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreReporte;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombreReporte;
		END IF;

		-- SE ASIGNAN VALORES PARA LA GENERACION DEL REPORTE
		LET cNombreReporte = 'REPORTE_CUENTAS_NOCANCELADAS_'||TO_CHAR(CURRENT,'%Y%m%d')||'.xls'; --.csv .txt
		
		LET cCmd1 ="";
		LET cCmd1 =""||TRIM(cCmd1)||" SELECT 'NO. CLIENTE','NOMBRE CLIENTE','NO. CUENTA','FECHA ULTIMO MOVIMIENTO','SALDO','CLIENTE NOTIFICADO','MOTIVO' FROM systables WHERE tabid = 1 ";
		LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL";
		LET cCmd1 =""||TRIM(cCmd1)||" SELECT no_cliente,nombre_cliente,TO_CHAR(no_cuenta),TO_CHAR(fec_ultimo_mov,'%d/%m/%Y'), TO_CHAR(saldo),CASE WHEN cliente_notificado = 'f' THEN 'NO' ELSE 'SI' END, motivo_no_cancelar ";
		LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:'informix'.sw_ctasnocanceladas ";
		LET cCmd1 =""||TRIM(cCmd1)||" WHERE id_usuario = '"||pUsuario||"'";
		
		LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
		LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreReporte);

		LET cSql = '';
		LET cSql = '/usr/bin/echo "UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER '|| '''	'''|| ' ' ||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'queryRepCuentasNoCanceladas.sql';
		SYSTEM TRIM(cSql);

		--LET cSql = '';
		--LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'queryRepCuentasCanceladas.sql';
		--SYSTEM TRIM(cSql);

		LET cSql = '';
		LET cSql = TRIM(cRutaInformix)||'dbaccess bdicnweb '||TRIM(pRutaDescarga)||'queryRepCuentasNoCanceladas.sql';
		SYSTEM TRIM(cSql);

		--LET cSql = '';
		--LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'queryRepCuentasCanceladas.sql';
		--SYSTEM TRIM(cSql);

		LET cSql = '';
		LET cSql = 'chmod 777 '||TRIM(cRutaGral);
		SYSTEM TRIM(cSql);

        --DEPURACION DE TABLA DE TRABAJO
		DELETE FROM bdicnweb:"informix".sw_ctasnocanceladas WHERE id_usuario = pUsuario;

		RETURN cCodRet, cNombreReporte;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Eduardo Ãvila PÃ©rez Tagle',
'FECHA: 24/09/2025',
'Requerimiento: RQM 20 129 DEF AutomatizaciÃ³n de cancelaciÃ³n de cuentas inactivas',
'DESCRIPCION: Procedimiento almacenado encargado de generar el reporte de las cuentas que no fueron canceladas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_valida_cuentacan(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20))
	RETURNING CHAR(5) AS codret, 
	          BOOLEAN AS resultado;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	
	DEFINE v_Cuenta CHAR(20);
	DEFINE v_Cliente CHAR(20);
	DEFINE v_RazonSocial CHAR(120);
	DEFINE v_SdoActual MONEY;
	DEFINE v_SdoCongelado MONEY;
	DEFINE v_LimSbgCCC MONEY;
	DEFINE v_ImpChqSbg MONEY;
	DEFINE v_ComPendiente MONEY;
	DEFINE v_FecUltMov DATE;
	DEFINE v_Producto CHAR(4);
	DEFINE v_ProdNoCancelacion INTEGER;
	DEFINE anio_actual INTEGER;
    DEFINE anio_pasado INTEGER;
    DEFINE mes_actual INTEGER;
	DEFINE v_Anio SMALLINT;
	
	DEFINE v_capvigprom1 MONEY; 
	DEFINE v_capvigprom2 MONEY;
	DEFINE v_capvigprom3 MONEY;
	DEFINE v_capvigprom4 MONEY; 
	DEFINE v_capvigprom5 MONEY;
	DEFINE v_capvigprom6 MONEY;
	DEFINE v_capvigprom7 MONEY;
	DEFINE v_capvigprom8 MONEY;
	DEFINE v_capvigprom9 MONEY;
	DEFINE v_capvigprom10 MONEY;
	DEFINE v_capvigprom11 MONEY;
	DEFINE v_capvigprom12 MONEY;
	
	DEFINE v_SaldoProm1 MONEY; 
	DEFINE v_SaldoProm2 MONEY;
	DEFINE v_SaldoProm3 MONEY;
	DEFINE v_SaldoProm4 MONEY; 
	DEFINE v_SaldoProm5 MONEY;
	DEFINE v_SaldoProm6 MONEY;
	DEFINE v_SaldoProm7 MONEY;
	DEFINE v_SaldoProm8 MONEY;
	DEFINE v_SaldoProm9 MONEY;
	DEFINE v_SaldoProm10 MONEY;
	DEFINE v_SaldoProm11 MONEY;
	DEFINE v_SaldoProm12 MONEY;
	
	DEFINE v_CreditosVigentes INTEGER;
	DEFINE v_CreditosVigentes1 INTEGER;
	DEFINE v_CreditosVigentes2 INTEGER;
	
	DEFINE v_AclaracionPendiente INTEGER;
	
	DEFINE v_Spei INTEGER;
	
	define v_EmpresaPrueba INTEGER;
	DEFINE v_CuentaFideicomiso INTEGER;
	DEFINE v_FechaActual DATE;
	
	DEFINE v_mes_actual INTEGER;
	
	DEFINE v_mes_anio_actual INTEGER;
	DEFINE v_mes_anio_anterior INTEGER;
	
	DEFINE v_SaldoPromedioTotal MONEY;
	
	DEFINE v_SaldoSobregirado MONEY;
	DEFINE v_SaldoActual MONEY;
	
	DEFINE v_SaldoActualSegVal MONEY;
	DEFINE v_SaldoCuenta MONEY;
	
	DEFINE v_Resultado BOOLEAN;

    LET v_FechaActual = TODAY;
    --LET p_cuenta = '10305923635';
    
    LET mes_actual = MONTH(v_FechaActual);
	
	LET v_capvigprom1 = 0; 
	LET v_capvigprom2 = 0;
	LET v_capvigprom3 = 0;
	LET v_capvigprom4 = 0; 
	LET v_capvigprom5 = 0;
	LET v_capvigprom6 = 0;
	LET v_capvigprom7 = 0;
	LET v_capvigprom8 = 0;
	LET v_capvigprom9 = 0;
	LET v_capvigprom10 = 0;
	LET v_capvigprom11 = 0;
	LET v_capvigprom12 = 0;
	
	LET v_SaldoProm1 = 0; 
	LET v_SaldoProm2 = 0;
	LET v_SaldoProm3 = 0;
	LET v_SaldoProm4 = 0; 
	LET v_SaldoProm5 = 0;
	LET v_SaldoProm6 = 0;
	LET v_SaldoProm7 = 0;
	LET v_SaldoProm8 = 0;
	LET v_SaldoProm9 = 0;
	LET v_SaldoProm10 = 0;
	LET v_SaldoProm11 = 0;
	LET v_SaldoProm12 = 0;
	
	LET v_SaldoPromedioTotal = 0;
	
	LET v_Anio = 0;
	
	LET v_mes_anio_actual = 0;
	LET v_mes_anio_anterior = 0;

	LET v_Cuenta = '';
	LET v_Cliente  = '';
	LET v_RazonSocial = '';
	LET v_SdoActual = 0;
	LET v_SdoCongelado = 0;
	LET v_LimSbgCCC = 0;
	LET v_ImpChqSbg = 0;
	LET v_ComPendiente = 0;
	LET v_FecUltMov = CURRENT;
	LET v_Producto = '0000';
	LET v_ProdNoCancelacion = 0;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;		
	
	LET v_SaldoSobregirado = 0;
	LET v_SaldoActual = 0;
	
	LET v_CreditosVigentes = 0;
	LET v_CreditosVigentes1 = 0;
	LET v_CreditosVigentes2 = 0;
	
	LET v_SaldoActualSegVal = 0;
	LET v_SaldoCuenta = 0;
	
	LET v_AclaracionPendiente = 0;
	LET v_EmpresaPrueba = 0;
	LET v_CuentaFideicomiso = 0;
	
	LET v_Spei = 0;
	
	LET v_Resultado = 'f';
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, v_Resultado;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/home/mfinis/sp_extrae_cuentascan.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCuenta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, v_Resultado;
		END IF;		
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, v_Resultado;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		SELECT FIRST 1 chq.cuenta, cli.numcte, cli.razon_social, chq.sdo_actual, chq.sdo_cong, chq.lim_sbg_ccc, chq.imp_chq_sbg, chq.com_pendiente, chq.fec_ult_mov, chq.producto
		INTO v_Cuenta, v_Cliente, v_RazonSocial, v_SdoActual, v_SdoCongelado, v_LimSbgCCC, v_ImpChqSbg, v_ComPendiente, v_FecUltMov, v_Producto
		FROM bdinteg:si_cliente cli
		INNER JOIN bdicheq:sc_maechq chq ON cli.numcte = chq.num_cte
		WHERE chq.cuenta = pCuenta AND chq.producto IN ('1200','1600','2200','2600') AND cli.tpo_persona='02' AND chq.status_cta NOT IN('3','2','5') 
		AND chq.fec_ult_mov <= (TODAY - DAY(TODAY) UNITS DAY) - 12 UNITS MONTH;
		
		SELECT COUNT(*) INTO v_ProdNoCancelacion 
		FROM bdicheq:sc_productonocancelacion 
		WHERE producto = v_Producto;
		
		IF NVL(v_ProdNoCancelacion,0) = 0 THEN
			LET v_mes_anio_actual = mes_actual - 1;
			LET v_mes_anio_anterior = 12 - v_mes_anio_actual;
			FOREACH
				SELECT
					capvigprom1, capvigprom2, capvigprom3, capvigprom4, capvigprom5, 
					capvigprom6, capvigprom7, capvigprom8, capvigprom9, capvigprom10, 
					capvigprom11, capvigprom12, anio
				INTO 
					v_capvigprom1, v_capvigprom2, v_capvigprom3, v_capvigprom4, v_capvigprom5,
					v_capvigprom6, v_capvigprom7, v_capvigprom8, v_capvigprom9, v_capvigprom10,
					v_capvigprom11, v_capvigprom12, v_Anio
				FROM 
					bdicheq:sc_sdomensualc
				WHERE
					cuenta = v_Cuenta
				AND				
					(anio = YEAR(v_FechaActual - 12 UNITS MONTH)
				OR
					anio = YEAR(v_FechaActual - 1 UNITS MONTH))
					
				IF v_Anio = YEAR(v_FechaActual - 1) THEN
					IF v_mes_anio_anterior = 1 THEN
						LET v_SaldoProm1 = v_capvigprom12;
					ELIF v_mes_anio_anterior = 2 THEN
						LET v_SaldoProm1 = v_capvigprom11;
						LET v_SaldoProm2 = v_capvigprom12;
					ELIF v_mes_anio_anterior = 3 THEN
						LET v_SaldoProm1 = v_capvigprom10;
						LET v_SaldoProm2 = v_capvigprom11;
						LET v_SaldoProm3 = v_capvigprom12;
					ELIF v_mes_anio_anterior = 4 THEN
						LET v_SaldoProm1 = v_capvigprom9;
						LET v_SaldoProm2 = v_capvigprom10;
						LET v_SaldoProm3 = v_capvigprom11;
						LET v_SaldoProm4 = v_capvigprom12;
					ELIF v_mes_anio_anterior = 5 THEN
						LET v_SaldoProm1 = v_capvigprom8;
						LET v_SaldoProm2 = v_capvigprom9;
						LET v_SaldoProm3 = v_capvigprom10;
						LET v_SaldoProm4 = v_capvigprom11;
						LET v_SaldoProm5 = v_capvigprom12;
					ELIF v_mes_anio_anterior = 6 THEN
						LET v_SaldoProm1 = v_capvigprom7;
						LET v_SaldoProm2 = v_capvigprom8;
						LET v_SaldoProm3 = v_capvigprom9;
						LET v_SaldoProm4 = v_capvigprom10;
						LET v_SaldoProm5 = v_capvigprom11;
						LET v_SaldoProm6 = v_capvigprom12;
					ELIF v_mes_anio_anterior = 7 THEN
						LET v_SaldoProm1 = v_capvigprom6;
						LET v_SaldoProm2 = v_capvigprom7;
						LET v_SaldoProm3 = v_capvigprom8;
						LET v_SaldoProm4 = v_capvigprom9;
						LET v_SaldoProm5 = v_capvigprom10;
						LET v_SaldoProm6 = v_capvigprom11;
						LET v_SaldoProm7 = v_capvigprom12;
					ELIF v_mes_anio_anterior = 8 THEN
						LET v_SaldoProm1 = v_capvigprom5;
						LET v_SaldoProm2 = v_capvigprom6;
						LET v_SaldoProm3 = v_capvigprom7;
						LET v_SaldoProm4 = v_capvigprom8;
						LET v_SaldoProm5 = v_capvigprom9;
						LET v_SaldoProm6 = v_capvigprom10;
						LET v_SaldoProm7 = v_capvigprom11;
						LET v_SaldoProm8 = v_capvigprom12;
					ELIF v_mes_anio_anterior = 9 THEN
						LET v_SaldoProm1 = v_capvigprom4;
						LET v_SaldoProm2 = v_capvigprom5;
						LET v_SaldoProm3 = v_capvigprom6;
						LET v_SaldoProm4 = v_capvigprom7;
						LET v_SaldoProm5 = v_capvigprom8;
						LET v_SaldoProm6 = v_capvigprom9;
						LET v_SaldoProm7 = v_capvigprom10;
						LET v_SaldoProm8 = v_capvigprom11;
						LET v_SaldoProm9 = v_capvigprom12;
					ELIF v_mes_anio_anterior = 10 THEN
						LET v_SaldoProm1 = v_capvigprom3;
						LET v_SaldoProm2 = v_capvigprom4;
						LET v_SaldoProm3 = v_capvigprom5;
						LET v_SaldoProm4 = v_capvigprom6;
						LET v_SaldoProm5 = v_capvigprom7;
						LET v_SaldoProm6 = v_capvigprom8;
						LET v_SaldoProm7 = v_capvigprom9;
						LET v_SaldoProm8 = v_capvigprom10;
						LET v_SaldoProm9 = v_capvigprom11;
						LET v_SaldoProm10 = v_capvigprom12;
					ELIF v_mes_anio_anterior = 11 THEN
						LET v_SaldoProm1 = v_capvigprom2;
						LET v_SaldoProm2 = v_capvigprom3;
						LET v_SaldoProm3 = v_capvigprom4;
						LET v_SaldoProm4 = v_capvigprom5;
						LET v_SaldoProm5 = v_capvigprom6;
						LET v_SaldoProm6 = v_capvigprom7;
						LET v_SaldoProm7 = v_capvigprom8;
						LET v_SaldoProm8 = v_capvigprom9;
						LET v_SaldoProm9 = v_capvigprom10;
						LET v_SaldoProm10 = v_capvigprom11;
						LET v_SaldoProm11 = v_capvigprom12;
					ELIF v_mes_anio_anterior = 12 THEN
						LET v_SaldoProm1 = v_capvigprom1;
						LET v_SaldoProm2 = v_capvigprom2;
						LET v_SaldoProm3 = v_capvigprom3;
						LET v_SaldoProm4 = v_capvigprom4;
						LET v_SaldoProm5 = v_capvigprom5;
						LET v_SaldoProm6 = v_capvigprom6;
						LET v_SaldoProm7 = v_capvigprom7;
						LET v_SaldoProm8 = v_capvigprom8;
						LET v_SaldoProm9 = v_capvigprom9;
						LET v_SaldoProm10 = v_capvigprom10;
						LET v_SaldoProm11 = v_capvigprom11;
						LET v_SaldoProm12 = v_capvigprom12;
					END IF;
				ELIF v_Anio = YEAR(v_FechaActual) THEN
					IF v_mes_anio_actual = 1 THEN
						LET v_SaldoProm12 = v_capvigprom1;
					ELIF v_mes_anio_actual = 2 THEN
						LET v_SaldoProm11 = v_capvigprom1;
						LET v_SaldoProm12 = v_capvigprom2;
					ELIF v_mes_anio_actual = 3 THEN
						LET v_SaldoProm10 = v_capvigprom1;
						LET v_SaldoProm11 = v_capvigprom2;
						LET v_SaldoProm12 = v_capvigprom3;
					ELIF v_mes_anio_actual = 4 THEN
						LET v_SaldoProm9 = v_capvigprom1;
						LET v_SaldoProm10 = v_capvigprom2;
						LET v_SaldoProm11 = v_capvigprom3;
						LET v_SaldoProm12 = v_capvigprom4;
					ELIF v_mes_anio_actual = 5 THEN
						LET v_SaldoProm8 = v_capvigprom1;
						LET v_SaldoProm9 = v_capvigprom2;
						LET v_SaldoProm10 = v_capvigprom3;
						LET v_SaldoProm11 = v_capvigprom4;
						LET v_SaldoProm12 = v_capvigprom5;
					ELIF v_mes_anio_actual = 6 THEN
						LET v_SaldoProm7 = v_capvigprom1;
						LET v_SaldoProm8 = v_capvigprom2;
						LET v_SaldoProm9 = v_capvigprom3;
						LET v_SaldoProm10 = v_capvigprom4;
						LET v_SaldoProm11 = v_capvigprom5;
						LET v_SaldoProm12 = v_capvigprom6;
					ELIF v_mes_anio_actual = 7 THEN
						LET v_SaldoProm6 = v_capvigprom1;
						LET v_SaldoProm7 = v_capvigprom2;
						LET v_SaldoProm8 = v_capvigprom3;
						LET v_SaldoProm9 = v_capvigprom4;
						LET v_SaldoProm10 = v_capvigprom5;
						LET v_SaldoProm11 = v_capvigprom6;
						LET v_SaldoProm12 = v_capvigprom7;
					ELIF v_mes_anio_actual = 8 THEN
						LET v_SaldoProm5 = v_capvigprom1;
						LET v_SaldoProm6 = v_capvigprom2;
						LET v_SaldoProm7 = v_capvigprom3;
						LET v_SaldoProm8 = v_capvigprom4;
						LET v_SaldoProm9 = v_capvigprom5;
						LET v_SaldoProm10 = v_capvigprom6;
						LET v_SaldoProm11 = v_capvigprom7;
						LET v_SaldoProm12 = v_capvigprom8;
					ELIF v_mes_anio_actual = 9 THEN
						LET v_SaldoProm4 = v_capvigprom1;
						LET v_SaldoProm5 = v_capvigprom2;
						LET v_SaldoProm6 = v_capvigprom3;
						LET v_SaldoProm7 = v_capvigprom4;
						LET v_SaldoProm8 = v_capvigprom5;
						LET v_SaldoProm9 = v_capvigprom6;
						LET v_SaldoProm10 = v_capvigprom7;
						LET v_SaldoProm11 = v_capvigprom8;
						LET v_SaldoProm12 = v_capvigprom9;
					ELIF v_mes_anio_actual = 10 THEN
						LET v_SaldoProm3 = v_capvigprom1;
						LET v_SaldoProm4 = v_capvigprom2;
						LET v_SaldoProm5 = v_capvigprom3;
						LET v_SaldoProm6 = v_capvigprom4;
						LET v_SaldoProm7 = v_capvigprom5;
						LET v_SaldoProm8 = v_capvigprom6;
						LET v_SaldoProm9 = v_capvigprom7;
						LET v_SaldoProm10 = v_capvigprom8;
						LET v_SaldoProm11 = v_capvigprom9;
						LET v_SaldoProm12 = v_capvigprom10;
					ELIF v_mes_anio_actual = 11 THEN
						LET v_SaldoProm2 = v_capvigprom1;
						LET v_SaldoProm3 = v_capvigprom2;
						LET v_SaldoProm4 = v_capvigprom3;
						LET v_SaldoProm5 = v_capvigprom4;
						LET v_SaldoProm6 = v_capvigprom5;
						LET v_SaldoProm7 = v_capvigprom6;
						LET v_SaldoProm8 = v_capvigprom7;
						LET v_SaldoProm9 = v_capvigprom8;
						LET v_SaldoProm10 = v_capvigprom9;
						LET v_SaldoProm11 = v_capvigprom10;
						LET v_SaldoProm12 = v_capvigprom11;
					ELIF v_mes_anio_actual = 12 THEN
						LET v_SaldoProm1 = v_capvigprom1;
						LET v_SaldoProm2 = v_capvigprom2;
						LET v_SaldoProm3 = v_capvigprom3;
						LET v_SaldoProm4 = v_capvigprom4;
						LET v_SaldoProm5 = v_capvigprom5;
						LET v_SaldoProm6 = v_capvigprom6;
						LET v_SaldoProm7 = v_capvigprom7;
						LET v_SaldoProm8 = v_capvigprom8;
						LET v_SaldoProm9 = v_capvigprom9;
						LET v_SaldoProm10 = v_capvigprom10;
						LET v_SaldoProm11 = v_capvigprom11;
						LET v_SaldoProm12 = v_capvigprom12;
					END IF;
				END IF;
				
			END FOREACH
			LET v_SaldoPromedioTotal = v_capvigprom1 + v_capvigprom2 + v_capvigprom3 + v_capvigprom4 + v_capvigprom5 + v_capvigprom6 + v_capvigprom7 + v_capvigprom8 + v_capvigprom9 + v_capvigprom10 + v_capvigprom11 + v_capvigprom2;
			IF NVL(v_SaldoPromedioTotal,0) = 0 THEN
				FOREACH
					SELECT imp_chq_sbg, sdo_actual 
					INTO v_SaldoSobregirado, v_SaldoActual 
					FROM bdicheq:sc_maechq 
					WHERE cuenta = v_Cuenta AND num_cte = v_Cliente --Aqui se agrego el filtro num_cte porque devolvÃ­a mas de un registro
				END FOREACH
				IF NVL(v_SaldoSobregirado,0) = 0 THEN
					IF NVL(v_SaldoActual,0) = 0 THEN
						--Aqui va el otro calculo del saldo actual
						SELECT (cheq.sdo_actual - (cheq.sdo_retenido + cheq.sdo_cong + cheq.imp_sbg_ccc)) AS saldo_actual, bal.sdo_cta
						INTO v_SaldoActualSegVal, v_SaldoCuenta
						FROM bdicheq:sc_maechq cheq
						INNER JOIN bditransfer:tf_maecte mae ON mae.numcte_tf = cheq.num_cte
						INNER JOIN bditransfer:tf_account_balance_customer bal ON bal.cuenta = mae.cuenta_tf
						WHERE cheq.num_cte = v_Cliente  AND (mae.numcte = v_Cliente OR mae.numcte_tf = v_Cliente) AND mae.status_cta != '2' AND bal.fecha_proceso = (SELECT MAX(bal2.fecha_proceso)
						FROM bditransfer:tf_account_balance_customer bal2
						WHERE bal2.cuenta = bal.cuenta);
						
						IF NVL(v_SaldoActualSegVal,0) = 0 AND NVL(v_SaldoCuenta,0) = 0 THEN
							SELECT COUNT(*) INTO v_CreditosVigentes FROM bdicred:sd_ctascarg WHERE num_cta = v_Cuenta AND naturaleza = naturaleza;
							IF v_CreditosVigentes > 0 THEN
								SELECT count(ctascar.num_cta)
								INTO v_CreditosVigentes1
								FROM bdicred:sd_ctascarg ctascar
								INNER JOIN bdicred:sd_maecred cred ON ctascar.empresa = cred.empresa AND ctascar.num_credito = cred.num_credito
								WHERE cred.numcte = v_Cliente AND ctascar.num_cta = v_Cuenta AND cred.status_cred != 'FF';
								
								SELECT count(ctascar.num_cta)
								INTO v_CreditosVigentes2
								FROM bdicred:sd_ctascarg ctascar
								INNER JOIN bdicred:sd_maecredcrd cred ON ctascar.empresa = cred.empresa AND ctascar.num_credito = cred.num_credito
								WHERE cred.numcte = v_Cliente AND ctascar.num_cta = v_Cuenta AND cred.status_cred != 'FF';
							END IF;
							
							IF NVL(v_CreditosVigentes,0) = 0 and (NVL(v_CreditosVigentes1,0) = 0 and NVL(v_CreditosVigentes2,0) = 0) THEN
								SELECT count(producto.numero_cuenta)
								INTO v_AclaracionPendiente
								FROM bdiaclaracion:acl_producto producto
								INNER JOIN bdiaclaracion:acl_aclaracion aclaracion ON producto.pky_producto = aclaracion.fky_producto
								WHERE producto.numero_cuenta = v_Cuenta AND aclaracion.fky_estatus_aclaracion = '2';
								IF NVL(v_AclaracionPendiente,0) = 0 THEN
									SELECT COUNT(*) 
									INTO v_EmpresaPrueba
									FROM bdicnweb:si_cliente_emp_pru
									WHERE no_cliente = v_Cliente;
										
									IF NVL(v_EmpresaPrueba,0) = 0 THEN
										SELECT COUNT(*) 
										INTO v_CuentaFideicomiso
										FROM bdinteg:si_ctepm 
										WHERE numcte = v_Cliente AND 
										(giro IS NULL OR giro = '' OR actividadsocial IS NULL OR actividadsocial = '' OR sufijo IS NULL OR sufijo = '' OR telefono_contacto IS NULL OR telefono_contacto = '' 
												OR tipo_poder IS NULL OR tipo_poder = '' OR tipo_admon IS NULL OR tipo_admon = '' OR tipo_org IS NULL OR tipo_org = '');
										IF v_CuentaFideicomiso <= 0 THEN
											SELECT COUNT(*) 
											INTO v_Spei
											FROM bdicheq:sc_movdia 
											WHERE cuenta = v_Cuenta AND transacc = '0274';
											IF NVL(v_Spei,0) = 0 THEN
												LET v_Resultado = 't';
											ELSE 
												INSERT INTO bdicnweb:"informix".sw_ctasnocanceladas (no_cliente,nombre_cliente,no_cuenta,fec_ultimo_mov,saldo,cliente_notificado,motivo_no_cancelar,id_usuario)
												VALUES(v_Cliente,v_RazonSocial,pCuenta,v_FecUltMov,v_SdoActual,'t','LA CUENTE TIENE UN SPEI EN PROCESO', pUsuario);
											
												LET v_Resultado = 'f';
											END IF;
										ELSE 
											INSERT INTO bdicnweb:"informix".sw_ctasnocanceladas (no_cliente,nombre_cliente,no_cuenta,fec_ultimo_mov,saldo,cliente_notificado,motivo_no_cancelar,id_usuario)
											VALUES(v_Cliente,v_RazonSocial,pCuenta,v_FecUltMov,v_SdoActual,'t','LA CUENTA ES DE TIPO FIDEICOMISO', pUsuario);
											LET v_Resultado = 'f';
										END IF;
									ELSE
										INSERT INTO bdicnweb:"informix".sw_ctasnocanceladas (no_cliente,nombre_cliente,no_cuenta,fec_ultimo_mov,saldo,cliente_notificado,motivo_no_cancelar,id_usuario)
										VALUES(v_Cliente,v_RazonSocial,pCuenta,v_FecUltMov,v_SdoActual,'t','LA CUENTA ES DE PRUEBA', pUsuario);
		
										LET v_Resultado = 'f';
									END IF;
								ELSE 
									INSERT INTO bdicnweb:"informix".sw_ctasnocanceladas (no_cliente,nombre_cliente,no_cuenta,fec_ultimo_mov,saldo,cliente_notificado,motivo_no_cancelar,id_usuario)
									VALUES(v_Cliente,v_RazonSocial,pCuenta,v_FecUltMov,v_SdoActual,'t','LA CUENTA TIENE ACLARACIONES PENDIENTES', pUsuario);
		
									LET v_Resultado = 'f';
								END IF;
							ELSE
								INSERT INTO bdicnweb:"informix".sw_ctasnocanceladas (no_cliente,nombre_cliente,no_cuenta,fec_ultimo_mov,saldo,cliente_notificado,motivo_no_cancelar,id_usuario)
								VALUES(v_Cliente,v_RazonSocial,pCuenta,v_FecUltMov,v_SdoActual,'t','LA CUENTA TIENE CREDITOS VIGENTES', pUsuario);
		
								LET v_Resultado = 'f';
							END IF;
						ELSE 
							INSERT INTO bdicnweb:"informix".sw_ctasnocanceladas (no_cliente,nombre_cliente,no_cuenta,fec_ultimo_mov,saldo,cliente_notificado,motivo_no_cancelar,id_usuario)
							VALUES(v_Cliente,v_RazonSocial,pCuenta,v_FecUltMov,v_SdoActual,'t','EL SALDO ACTUAL ES MAYOR A 0', pUsuario);
		
							LET v_Resultado = 'f';
						END IF;
					ELSE
						INSERT INTO bdicnweb:"informix".sw_ctasnocanceladas (no_cliente,nombre_cliente,no_cuenta,fec_ultimo_mov,saldo,cliente_notificado,motivo_no_cancelar,id_usuario)
						VALUES(v_Cliente,v_RazonSocial,pCuenta,v_FecUltMov,v_SdoActual,'t','EL SALDO ACTUAL ES MAYOR A 0', pUsuario);
		
						LET v_Resultado = 'f';
					END IF;
				ELSE 
					INSERT INTO bdicnweb:"informix".sw_ctasnocanceladas (no_cliente,nombre_cliente,no_cuenta,fec_ultimo_mov,saldo,cliente_notificado,motivo_no_cancelar,id_usuario)
					VALUES(v_Cliente,v_RazonSocial,pCuenta,v_FecUltMov,v_SdoActual,'t','LA CUENTA PRESENTA SALDO SOBREGIRADO', pUsuario);
		
					LET v_Resultado = 'f';
				END IF;
			ELSE
				INSERT INTO bdicnweb:"informix".sw_ctasnocanceladas (no_cliente,nombre_cliente,no_cuenta,fec_ultimo_mov,saldo,cliente_notificado,motivo_no_cancelar,id_usuario)
				VALUES(v_Cliente,v_RazonSocial,pCuenta,v_FecUltMov,v_SdoActual,'t','EL SALDO PROMEDIO DE LA CUENTA ES MAYOR A 0', pUsuario);
		
				LET v_Resultado = 'f';
			END IF;
		ELSE
			INSERT INTO bdicnweb:"informix".sw_ctasnocanceladas (no_cliente,nombre_cliente,no_cuenta,fec_ultimo_mov,saldo,cliente_notificado,motivo_no_cancelar,id_usuario)
			VALUES(v_Cliente,v_RazonSocial,pCuenta,v_FecUltMov,v_SdoActual,'t','EL PRODUCTO NO PERMITE CANCELAR', pUsuario);
		
			LET v_Resultado = 'f';
		END IF;
		
		RETURN cCodRet, v_Resultado;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Eduardo Ãvila PÃ©rez Tagle',
'FECHA: 24/09/2025',
'Requerimiento: RQM 20 129 DEF AutomatizaciÃ³n de cancelaciÃ³n de cuentas inactivas',
'DESCRIPCION: Procedimiento almacenado encargado de validar si la cuenta es candidata a cancelar',
'BD: bdicheq';


CREATE PROCEDURE "informix".sp_inserta_creditoexcluir( pCuenta CHAR(20))

-- Control de Cambios
-----------------------------------------------------------------------------------
----Faviola Martinez
--------------------------------------------------------------------------------
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE vStatusSol       CHAR(2);
DEFINE vHoy             DATE;
define dFechaEnt        DATE;
DEFINE vCausaSol        CHAR(3);
DEFINE P_COD_RET   VARCHAR(5);
DEFINE cNumcte   CHAR(20);
DEFINE cCodRet   CHAR(6);
DEFINE cMensajeRet   CHAR(100);
DEFINE iValido   INTEGER;
DEFINE cSucursal   CHAR(4);
DEFINE cNumProd   CHAR(4);
DEFINE vRegistro   DECIMAL(18,2);
DEFINE vMensajeStatus         CHAR(80);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET vStatusSol  = "??";
LET vHoy  = DATE(1);
LET dFechaEnt  =  DATE(1);
LET vCausaSol   = "";
LET P_COD_RET   = "";
LET cNumcte   = "";
LET cCodRet   = "";
LET cMensajeRet   = "";
LET iValido   = 0;
LET cSucursal   = "";
LET cNumProd   = "";
LET vRegistro   = 0;
LET vMensajeStatus="";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

--SET DEBUG FILE TO "sp_inserta_creditoexcluir.out";
--TRACE ON;
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
    	
 SELECT id_registro, status
	INTO vRegistro, vStatusSol
	FROM bdicnweb:"informix".sw_evc_excluidos
	WHERE  cuenta = pCuenta
	AND id_registro = (select max(id_registro) from bdicnweb:"informix".sw_evc_excluidos where cuenta = pCuenta);

	IF (SELECT COUNT(*) FROM bdicnweb:"informix".sw_evc_excluidos WHERE cuenta = pCuenta) > 1 THEN

         IF vStatusSol <> 'P' THEN
						
			delete from sw_evc_excluidos where cuenta = pCuenta
			and id_registro < vRegistro;
			
         END IF;
	END IF;
END PROCEDURE;
CREATE PROCEDURE "informix".sp_consmovretenidosccl(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo CHAR(1), pFechaInicio DATE, pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
		CHAR(15) AS cuenta_credito,
		DATETIME YEAR TO FRACTION(5) AS fecha_retencion,
		CHAR(20) AS folio_retencion ,
		MONEY(18,2) AS monto_retenido,
		INTEGER AS dias_restantes_lib;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE codret CHAR(5);
	DEFINE cCuentaCredito CHAR(15);
	DEFINE dFechaRetencion DATETIME YEAR TO FRACTION(5);
	DEFINE cFolioRetencion CHAR(20);
	DEFINE mMontoRetenido MONEY(18,2);
	DEFINE iDiasRestantesLib INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET codret = '' ;
	LET cCuentaCredito = '' ;
	LET dFechaRetencion = '' ;
	LET cFolioRetencion = '' ;
	LET mMontoRetenido = 0.00;
	LET iDiasRestantesLib =0;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCuentaCredito,dFechaRetencion,cFolioRetencion,mMontoRetenido,iDiasRestantesLib;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_consmovretenidosccl.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pTipo = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCuentaCredito,dFechaRetencion,cFolioRetencion,mMontoRetenido,iDiasRestantesLib;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cCuentaCredito,dFechaRetencion,cFolioRetencion,mMontoRetenido,iDiasRestantesLib;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCuentaCredito,dFechaRetencion,cFolioRetencion,mMontoRetenido,iDiasRestantesLib;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		FOREACH
			EXECUTE PROCEDURE bditarjeta: "informix".sp_concreing_movimientosretenidos2(pTipo, pFechaInicio, pFechaFin, pRegistros, pRecuperacion)
			INTO cCodRetSp, cCuentaCredito,dFechaRetencion,cFolioRetencion,mMontoRetenido,iDiasRestantesLib
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP intercard:sp_consultaconadmincorr';
			END IF;
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cCuentaCredito,dFechaRetencion,cFolioRetencion,mMontoRetenido,iDiasRestantesLib WITH RESUME;	
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN 
				LET cCodRet ='00017';
				RETURN cCodRet, cCuentaCredito,dFechaRetencion,cFolioRetencion,mMontoRetenido,iDiasRestantesLib;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
				LET cCodRet ='1001';
				RETURN cCodRet, cCuentaCredito,dFechaRetencion,cFolioRetencion,mMontoRetenido,iDiasRestantesLib;
			END IF;	
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez ',
'FECHA: 11/09/2015',
'MODULO: CONCILIACIONES  ',
'FUNCIONALIDAD: CONSULTA DE RETENIDOS POR LIBERARSE ',
'DESCRIPCION:SPL que consulta el detalle de movimientos retenidos pendientes por liberar de cheques y credito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consmovretenidosccl_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo CHAR(1), pFechaInicio DATE, pFechaFin DATE)
		RETURNING CHAR(5) AS codret,		
		INTEGER AS num_registros;

	DEFINE cCodRet 					CHAR(5);
	DEFINE cCodRetSp 				CHAR(6);
	DEFINE cDescCodRet 				CHAR(100);
	DEFINE iCodRetSp				INTEGER;
	DEFINE iSqlErr 					INTEGER;	
	DEFINE iNumRegistros 			INTEGER;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cDescCodRet = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;
	LET iNumRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumRegistros;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_consmovretenidosccl_totales.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pTipo = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_movimientosretenidos2_totales(pTipo, pFechaInicio, pFechaFin)
		INTO cCodRetSp,iNumRegistros;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bditarjeta:sp_concreing_movimientosretenidos2_totales';
		END IF;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00017';		
		END IF;
        
		RETURN cCodRet, iNumRegistros;
		
	END;

END PROCEDURE 
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez ',
'FECHA: 11/09/2015',
'MODULO: CONCILIACIONES  ',
'FUNCIONALIDAD: CONSULTA DE RETENIDOS POR LIBERARSE ',
'DESCRIPCION:SPL que consulta el total de movimientos retenidos pendientes por liberar de cheques y credito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consprogramacionhorariosccl(pUsuario CHAR(8), pIdFuncion CHAR(10))	
		RETURNING CHAR(5) AS codret,
			CHAR(3) AS arch_origen,
			INTEGER AS orden_proceso,
			CHAR(1) AS hr_ejecucionHoy,
			CHAR(1) AS hr_ejecucionExt;
			
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRet CHAR(100);
	DEFINE iCodRetSp INTEGER;
	DEFINE iSqlErr INTEGER;	
	DEFINE cArchOrigen CHAR(3);
	DEFINE iOrdenProceso INTEGER;
	DEFINE cHrEjecucionHoy CHAR(1);
	DEFINE cHrEjecucionExt CHAR(1);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cDescCodRet = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;
	LET cArchOrigen = '';
	LET iOrdenProceso = 0;
	LET cHrEjecucionHoy = '';
	LET cHrEjecucionExt = '';
	LET iNoRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cArchOrigen,iOrdenProceso,cHrEjecucionHoy,cHrEjecucionExt;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consprogramacionhorariosccl.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cArchOrigen,iOrdenProceso,cHrEjecucionHoy,cHrEjecucionExt;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cArchOrigen,iOrdenProceso,cHrEjecucionHoy,cHrEjecucionExt;
		END IF;
	
		FOREACH
			EXECUTE PROCEDURE bditarjeta:'informix'.sp_concreing_consultaproghorarios(pUsuario)
			INTO cCodRetSp,cArchOrigen,iOrdenProceso,cHrEjecucionHoy,cHrEjecucionExt
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditarjeta:sp_concreing_consultaproghorarios';
			END IF;
				
			LET iCodRetSp = cCodRetSp::INTEGER;
			LET cCodRet = LPAD(iCodRetSp, 5, '0');
			
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet,UPPER(cArchOrigen),iOrdenProceso,cHrEjecucionHoy,cHrEjecucionExt WITH RESUME;
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cArchOrigen,iOrdenProceso,cHrEjecucionHoy,cHrEjecucionExt;
		END IF;
		
	END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 19/08/2015',
'DESCRIPCION: SPL que consulta la programaciÃ³n de horarios.',
'FUNCIONALIDAD: ProgramaciÃ³n de Horarios', 
'MODULO: CONCILIACIONES',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_constparametrosccl(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
		CHAR(90) AS historico_ccl,
		CHAR(90) AS bitacora_ccl,
		CHAR(90) AS movimientos_ccl,
		CHAR(90) AS archivos_aix;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cHistoricoCcl CHAR(90);
	DEFINE cBitacoraCcl	CHAR(90);
	DEFINE cMovimientosCcl CHAR(90);
	DEFINE cArchivosAix	CHAR(90);
	DEFINE iNoRegistros INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET cHistoricoCcl = '';
	LET cBitacoraCcl = '';
	LET cMovimientosCcl	= '';
	LET cArchivosAix = '';
	LET iNoRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cHistoricoCcl, cBitacoraCcl, cMovimientosCcl,cArchivosAix;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_constparametrosccl.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cHistoricoCcl, cBitacoraCcl, cMovimientosCcl,cArchivosAix;
		END IF;	
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cHistoricoCcl, cBitacoraCcl, cMovimientosCcl,cArchivosAix;
		END IF;		
		
		SET ISOLATION TO DIRTY READ;		
		EXECUTE PROCEDURE bditarjeta:'informix'.sp_concreing_consultamttoparam(pUsuario)
		INTO cCodRetSp, cHistoricoCcl, cBitacoraCcl, cMovimientosCcl,cArchivosAix;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
		RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bditarjeta:sp_concreing_consultamttoparam";
		ELIF cCodRetSp::INTEGER = 100  THEN
			LET cCodRet = '00100';
		END IF;
		LET iNoRegistros = iNoRegistros + 1;
		RETURN cCodRet, cHistoricoCcl, cBitacoraCcl, cMovimientosCcl,cArchivosAix;	
		END;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cHistoricoCcl, cBitacoraCcl, cMovimientosCcl,cArchivosAix;	
		END IF;
	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe A. Hernandez Perez',
'FECHA: 02/10/2015',
'MODULO: CONCILIACIONES',
'FUNCIONALIDAD: PARAMETROS DE ARCHIVOS',
'DESCRIPCION: SPL que consulta los parametros de repositorio y depuracion',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultaarchivosconau(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				CHAR(30) AS nombre_archivo,
				CHAR(5) AS archivo_origen,
				CHAR(1) AS proceso,
				DATE AS fecha_archivo;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cNombreArchivo CHAR(30);
	
	DEFINE cArchivoOrigen CHAR(5);
	DEFINE cProceso CHAR(1);
	DEFINE dFechaArchivo DATE;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cNombreArchivo = '';
	LET cArchivoOrigen = '';
	LET cProceso = '';
	LET dFechaArchivo = NULL;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombreArchivo, cArchivoOrigen, cProceso, dFechaArchivo;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultaarchivosconau.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreArchivo, cArchivoOrigen, cProceso, dFechaArchivo;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNombreArchivo, cArchivoOrigen, cProceso, dFechaArchivo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombreArchivo, cArchivoOrigen, cProceso, dFechaArchivo;
		END IF;
		
		FOREACH EXECUTE PROCEDURE bditarjeta:'informix'.sp_concreing_consultaarchivosconciliacion2(pFecha, pRegistros,  pRecuperacion)
			INTO cCodRetSp, cNombreArchivo, cArchivoOrigen, cProceso, dFechaArchivo
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditarjeta:sp_concreing_consultaarchivosconciliacion2';
			END IF;
			
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, cNombreArchivo, cArchivoOrigen, cProceso, dFechaArchivo WITH RESUME;
			
		END FOREACH;
		
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNombreArchivo, cArchivoOrigen, cProceso, dFechaArchivo;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNombreArchivo, cArchivoOrigen, cProceso, dFechaArchivo;
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 18/08/2015',
'MODULO: CONCILIACIONES',
'FUNCIONALIDAD: Mantenimiento de CRON',
'DESCRIPCION: Consulta de regitros para procesar en el proceso de CRON',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultaarchivosconau_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE)
		RETURNING CHAR(5) AS codret,
				INTEGER AS total_registros;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultaarchivosconau_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		EXECUTE PROCEDURE bditarjeta:'informix'.sp_concreing_consultaarchivosconciliacion2_totales(pFecha)
		INTO cCodRetSp, iNoRegistros;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditarjeta:sp_concreing_consultaarchivosconciliacion2_totales';
		END IF;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iNoRegistros;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 19/08/2015',
'MODULO: CONCILIACIONES',
'FUNCIONALIDAD: Mantenimiento de CRON',
'DESCRIPCION: Consulta el totoal de registros que devolvera la consulta de archivos de conciliaciÃ³n automÃ¡tica',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultabajausuariosccl(pUsuario CHAR(8), pIdFuncion CHAR(10), pClave CHAR(10))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultabajausuariosccl.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  OR pClave = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
						
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		EXECUTE PROCEDURE bditarjeta:'informix'.sp_concreing_bajausuarios( pClave,  pUsuario)
		INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditarjeta:sp_concreing_bajausuarios';
		END IF;		
			RETURN cCodRet;	
		END ;
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 21/09/2015',
'MODULO: CONCILIACIONES',
'FUNCIONALIDAD: ADMINISTRACIÓN DE USUARIOS',
'DESCRIPCION: SPL para la baja de usuario y sus perfiles',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultabitacoraccl(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo CHAR(1), pElemento INTEGER, 
pFechaInicio DATE, pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)	
		RETURNING CHAR(5) AS codret,
		INTEGER AS elemento,
		DATETIME YEAR TO FRACTION(5) AS fecha_hora,      
		CHAR(250) AS actividad,
		CHAR(10) AS cve_usuario;
			
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRet CHAR(80);
	DEFINE iCodRetSp INTEGER;
	DEFINE iSqlErr INTEGER;	
	DEFINE iElemento INTEGER;
	DEFINE dFechaHora DATETIME YEAR TO FRACTION(5);
	DEFINE cActividad CHAR(250);
	DEFINE cClaveUsuario CHAR(10);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cDescCodRet = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;
	LET iElemento = 0;
	LET dFechaHora = '';
	LET cActividad = '';
	LET cClaveUsuario = '';
	LET iRecuperacion = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iElemento,dFechaHora,cActividad,cClaveUsuario;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_consultabitacoraccl.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipo = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iElemento,dFechaHora,cActividad,cClaveUsuario;
		END IF;
		
		-- VALIDACIÃN DE LOS DATOS DE PAGINACIÃN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,iElemento,dFechaHora,cActividad,cClaveUsuario;
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iElemento,dFechaHora,cActividad,cClaveUsuario;
		END IF;
	
		IF pTipo = '2' THEN
			IF NVL(pElemento,'') = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet,iElemento,dFechaHora,cActividad,cClaveUsuario;
			END IF;
		END IF;
	
		FOREACH
			EXECUTE PROCEDURE bditarjeta:"informix".sp_conbitacora_con2 (pTipo,pElemento,pFechaInicio,pFechaFin,pRegistros,pRecuperacion)
			INTO cCodRetSp,cDescCodRet,iElemento,dFechaHora,cActividad,cClaveUsuario
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditarjeta:sp_conbitacora_con2';
			END IF;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,iElemento,dFechaHora,UPPER(cActividad),cClaveUsuario WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet,iElemento,dFechaHora,cActividad,cClaveUsuario;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,iElemento,dFechaHora,cActividad,cClaveUsuario;
		END IF;
		
	END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 20/08/2015',
'DESCRIPCION: SPL que realiza la consulta de bitÃ¡cora de ConciliaciÃ³n.',
'FUNCIONALIDAD: BitÃ¡cora de ConciliaciÃ³n', 
'MODULO: CONCILIACIONES',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultabitacoraccl_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo CHAR(1), pElemento INTEGER, 
pFechaInicio DATE, pFechaFin DATE)	
		RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
			
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRet CHAR(80);
	DEFINE iCodRetSp INTEGER;
	DEFINE iSqlErr INTEGER;	
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cDescCodRet = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;
	LET iNumRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumRegistros;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_consultabitacoraccl_totales.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipo = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNumRegistros;
		END IF;
	
		IF pTipo = '2' THEN
			IF NVL(pElemento,'') = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iNumRegistros;
			END IF;
		END IF;

		EXECUTE PROCEDURE bditarjeta:"informix".sp_conbitacora_con2_totales (pTipo,pElemento,pFechaInicio,pFechaFin)
		INTO cCodRetSp,iNumRegistros;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditarjeta:sp_conbitacora_con2_totales';
		END IF;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00017';		
		END IF;

		RETURN cCodRet, iNumRegistros;
		
	END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 20/08/2015',
'DESCRIPCION: SPL que consulta el nÃºmero total de registros en bitÃ¡cora de ConciliaciÃ³n.',
'FUNCIONALIDAD: BitÃ¡cora de ConciliaciÃ³n', 
'MODULO: CONCILIACIONES',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultacompaplicacionccl(pUsuario
 CHAR(8), pIdFuncion CHAR(10), pArchOrigen CHAR (3),
 pIntegridad  CHAR(1), pConcecutivo INTEGER, pAplica CHAR (1), pSecuencia325 CHAR(6))
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cAplicacion CHAR (1);
	DEFINE cErrorActividad CHAR(250);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET cAplicacion ='';
	LET cErrorActividad ='';
	
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultacompaplicacionccl.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pArchOrigen ='' OR pIntegridad ='' OR pConcecutivo IS NULL OR pSecuencia325= ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		--ejecucion del productivo
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_compaplicacion (pUsuario,  pArchOrigen, pIntegridad, pConcecutivo, pAplica, pSecuencia325) 
		INTO cCodRetSp, cAplicacion, cErrorActividad;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditarjeta:sp_concreing_compaplicacion';
		ELIF iCodRetSp = 460 THEN
			LET cCodRet = '00613';
		END IF;
		
		RETURN cCodRet;		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez ',
'FECHA: 13/08/2015',
'MODULO: CONCILIACIONES  ',
'FUNCIONALIDAD: Consulta de Movimientos con Error de Aplicación',
'DESCRIPCION: Actualiza registro con Error de Aplicación por medio de una ejecucion intermedia',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultacomplementoccl(pUsuario CHAR(8), pIdFuncion CHAR(10), pArchOrigen CHAR(3), 
	pConciliacion CHAR(1), pConsecutivo INTEGER, pNumTarjeta CHAR(16), pSecuencia325 CHAR(6), pMonto325 CHAR(13), 
	pTipoTransaccion325 CHAR(15), pIntegridad CHAR(1))

		RETURNING CHAR(5) AS codret,
			CHAR(1) AS conciliacion,
			CHAR(7) AS secuencia,
			CHAR(15) AS secuencia_extendida,
			MONEY(16,2) AS monto_intercard,
			DATE AS fecha_transaccion,
			CHAR(40) AS inf_receptor,
			CHAR(16) AS id_terminal,
			CHAR(2) AS metodo_captura,
			CHAR(1) AS mov_conciliado,
			CHAR(1) AS mov_reversado,
			CHAR(1) AS tipo_mov,
			CHAR(16) AS folio_mov,
			DATE AS fecha_concilia,
			INTEGER AS tipo_conciliacion,
			CHAR(60) AS desc_conciliacion,
			CHAR(250) AS error_actividad,
			INTEGER AS elemento;
			
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE cDescCodRet CHAR(100);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;	
		DEFINE cConciliacion CHAR(1);
		DEFINE cSecuencia CHAR(7); 
		DEFINE cSecExtendida CHAR(15);
		DEFINE mMontoIntercard MONEY(16,2);
		DEFINE dFechaTransaccion DATE;
		DEFINE cInfReceptor CHAR(40);
		DEFINE cIdTerminal CHAR(16);
		DEFINE cMetodoCaptura CHAR(2); 
		DEFINE cMovConciliado CHAR(1); 
		DEFINE cMovReversado CHAR(1); 
		DEFINE cTipoMov CHAR(1); 
		DEFINE cFolioMov CHAR(16);
		DEFINE dFechaConcilia DATE;
		DEFINE iTipoConciliacion INTEGER; 
		DEFINE cDescConciliacion CHAR(60);
		DEFINE cErrorActividad CHAR(250);
		DEFINE iElemento INTEGER; 		
		DEFINE iNoRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET cDescCodRet = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET cConciliacion = '';
		LET cSecuencia = '';
		LET cSecExtendida = '';
		LET mMontoIntercard = 0.00;
		LET dFechaTransaccion = '';
		LET cInfReceptor = '';
		LET cIdTerminal = '';
		LET cMetodoCaptura = '';
		LET cMovConciliado = '';
		LET cMovReversado = ''; 
		LET cTipoMov = ''; 
		LET cFolioMov = '';
		LET dFechaConcilia = '';
		LET iTipoConciliacion = 0;
		LET cDescConciliacion = '';
		LET cErrorActividad = '';
		LET iElemento = 0;
		LET iNoRegistros = 0;
		
	
		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet,cConciliacion,cSecuencia,cSecExtendida,mMontoIntercard,dFechaTransaccion,cInfReceptor,cIdTerminal,cMetodoCaptura,
				cMovConciliado,cMovReversado,cTipoMov,cFolioMov,dFechaConcilia,iTipoConciliacion,cDescConciliacion,cErrorActividad,iElemento;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_consultacomplementoccl.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet,cConciliacion,cSecuencia,cSecExtendida,mMontoIntercard,dFechaTransaccion,cInfReceptor,cIdTerminal,cMetodoCaptura,
				cMovConciliado,cMovReversado,cTipoMov,cFolioMov,dFechaConcilia,iTipoConciliacion,cDescConciliacion,cErrorActividad,iElemento;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet,cConciliacion,cSecuencia,cSecExtendida,mMontoIntercard,dFechaTransaccion,cInfReceptor,cIdTerminal,cMetodoCaptura,
				cMovConciliado,cMovReversado,cTipoMov,cFolioMov,dFechaConcilia,iTipoConciliacion,cDescConciliacion,cErrorActividad,iElemento;
			END IF;
			
			SET ISOLATION TO DIRTY READ;

			EXECUTE PROCEDURE bditarjeta:'informix'.sp_concreing_consultacompconciliacion (pUsuario,pArchOrigen,pConciliacion, 
				pConsecutivo,pNumTarjeta,pSecuencia325,pMonto325,pTipoTransaccion325,pIntegridad)
			INTO cCodRetSp,cConciliacion,cSecuencia,cSecExtendida,mMontoIntercard,dFechaTransaccion,cInfReceptor,cIdTerminal,cMetodoCaptura,
				cMovConciliado,cMovReversado,cTipoMov,cFolioMov,dFechaConcilia,iTipoConciliacion,cDescConciliacion,cErrorActividad,iElemento;
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditarjeta:sp_concreing_consultacompconciliacion';
			ELSE
				LET iNoRegistros = iNoRegistros + 1;
				LET cCodRet = cCodRetSp;
				RETURN cCodRet,cConciliacion,cSecuencia,cSecExtendida,mMontoIntercard,dFechaTransaccion,cInfReceptor,cIdTerminal,cMetodoCaptura,
				cMovConciliado,cMovReversado,cTipoMov,cFolioMov,dFechaConcilia,iTipoConciliacion,cDescConciliacion,cErrorActividad,iElemento;
			END IF;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00283';
				RETURN cCodRet,cConciliacion,cSecuencia,cSecExtendida,mMontoIntercard,dFechaTransaccion,cInfReceptor,cIdTerminal,cMetodoCaptura,
				cMovConciliado,cMovReversado,cTipoMov,cFolioMov,dFechaConcilia,iTipoConciliacion,cDescConciliacion,cErrorActividad,iElemento;
			END IF;
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 12/08/2015',
'DESCRIPCION: SPL que se encarga de actualizar el registro con error de conciliacion.',
'Complementa la integridad de los campos necesarios para la conciliacion',
'FUNCIONALIDAD: Consulta de Movimientos Pendientes de Aplicar', 
'MODULO: CONCILIACIONES',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultaltausuariosccl(pUsuario CHAR(8), pIdFuncion CHAR(10),pActivo CHAR(1), pClave CHAR(10), pNombre CHAR(30), pOperacion CHAR(1), pMonitoreo CHAR(1), pAdmon CHAR(1), pFecha DATE)
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET pActivo = UPPER(TRIM(pActivo));
	LET pClave = UPPER(TRIM(pClave));
	LET pOperacion = UPPER(TRIM(pOperacion));
	LET pMonitoreo = UPPER(TRIM(pMonitoreo));
	LET pAdmon = UPPER(TRIM(pAdmon));
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultaltausuariosccl.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR   pClave = '' OR pNombre = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
						
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		IF(pActivo = '') OR (pActivo IS NULL)THEN
			LET pActivo = 'F';
			RETURN cCodRet;
		END IF;
		
		IF(pOperacion = '') OR (pOperacion IS NULL)THEN
			LET pOperacion = 'F';
			RETURN cCodRet;
		END IF;
		
		IF(pMonitoreo = '') OR (pMonitoreo IS NULL)THEN
			LET pMonitoreo = 'F';
			RETURN cCodRet;
		END IF;
		
		IF(pAdmon = '') OR (pAdmon IS NULL)THEN
			LET pAdmon = 'F';
			RETURN cCodRet;
		END IF;
		
		IF pActivo NOT IN ('V', 'F') THEN
			LET cCodRet = '00102';
			RETURN cCodRet;
		END IF;
		
		IF pOperacion NOT IN ('V', 'F') THEN
			LET cCodRet = '00102';
			RETURN cCodRet;
		END IF;
		
		IF pMonitoreo NOT IN ('V', 'F') THEN
			LET cCodRet = '00102';
			RETURN cCodRet;
		END IF;
		
		IF pAdmon NOT IN ('V', 'F') THEN
			LET cCodRet = '00102';
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		EXECUTE PROCEDURE bditarjeta:'informix'.sp_concreing_altausuarios(pActivo, pClave, pNombre, pOperacion, pMonitoreo, pAdmon, pFecha, pUsuario)
		INTO cCodRetSp;		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditarjeta:sp_concreing_altausuarios';
		ELIF iCodRetSp = 002 THEN
			LET cCodRet = '00004';	
		END IF;		
			RETURN cCodRet;	
		END ;
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 21/09/2015',
'MODULO: CONCILIACIONES  ',
'FUNCIONALIDAD: ADMINISTRACIÓN DE USUARIOS   ',
'DESCRIPCION: SPL para dar de alta a los usuarios de la conciliación',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultamodificausuariosccl(pUsuario CHAR(8), pIdFuncion CHAR(10), pClave CHAR(10), pNombre CHAR(30), pOperacion CHAR(1), pMonitoreo CHAR(1), pAdmon CHAR(1), pFecha DATE,pActivo CHAR(1))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET pClave = UPPER(TRIM(pClave));
	LET pOperacion = UPPER(TRIM(pOperacion));
	LET pMonitoreo = UPPER(TRIM(pMonitoreo));
	LET pAdmon = UPPER(TRIM(pAdmon));
	LET	pActivo =  UPPER(TRIM(pActivo));
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultamodificausuariosccl.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  OR pClave = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
						
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		IF(pOperacion = '') OR (pOperacion IS NULL)THEN
			LET pOperacion = 'F';
			RETURN cCodRet;
		END IF;
		
		IF(pMonitoreo = '') OR (pMonitoreo IS NULL)THEN
			LET pMonitoreo = 'F';
			RETURN cCodRet;
		END IF;
		
		IF(pAdmon = '') OR (pAdmon IS NULL)THEN
			LET pAdmon = 'F';
			RETURN cCodRet;
		END IF;
		
		IF pOperacion NOT IN ('V', 'F') THEN
			LET cCodRet = '00102';
			RETURN cCodRet;
		END IF;
		
		IF pMonitoreo NOT IN ('V', 'F') THEN
			LET cCodRet = '00102';
			RETURN cCodRet;
		END IF;
		
		IF pAdmon NOT IN ('V', 'F') THEN
			LET cCodRet = '00102';
			RETURN cCodRet;
		END IF;
		
		IF pActivo NOT IN ('V', 'F') THEN
			LET cCodRet = '00102';
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		EXECUTE PROCEDURE bditarjeta:'informix'.sp_concreing_modificausuarios( pClave, pNombre, pOperacion, pMonitoreo, pAdmon, pFecha, pUsuario,pActivo)		
		INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditarjeta:sp_concreing_modificausuarios';
		END IF;		
			RETURN cCodRet;	
		END ;
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 21/09/2015',
'MODULO: CONCILIACIONES  ',
'FUNCIONALIDAD: ADMINISTRACIÓN DE USUARIOS   ',
'DESCRIPCION: SPL para almacenado que modifica los datos del usuario y sus perfiles',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultamovpendientesccl(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE, pRegistros INTEGER, pRecuperacion INTEGER)	
		RETURNING CHAR(5) AS codret,                         
	        INTEGER AS consecutivo,                        
	        CHAR(23) AS nom_archivo,                       
	        CHAR(3) AS archivo_origen,                     
	        CHAR(1) AS integridad,                         
	        CHAR(20) AS integridad_error,                  
	        CHAR(16) AS num_tarjeta,                       
	        CHAR(6) AS secuencia,                          
	        CHAR(9) AS id_comercio325,                     
	        CHAR(30) AS nom_comercio325,                   
	        CHAR(23) AS referencia23_325,                  
	        CHAR(13) AS monto,                             
	        CHAR(15) as rfc325,                            
	        CHAR(3) AS divisa325,                          
	        CHAR(13) AS monto_cash_back,                   
	        CHAR(1) AS conciliacion,                       
	        INTEGER AS tipo_conciliacion,                  
	        CHAR(15) AS secuencia_extendida,               
	        MONEY(16,2) AS monto_intercard,                
	        CHAR(1) AS mov_conciliado,                     
	        CHAR(1) AS mov_reversado,                      
	        CHAR(1) AS aplicacion,                         
	        CHAR(16) AS folio_aplicacion,                  
	        CHAR(5) AS cod_retorno,                        
	        CHAR(15) AS tipo_transaccion325,               
	        CHAR(13) AS monto325,                          
	        CHAR(1) AS bandera_proceso;                    
			

		DEFINE cCodRet                 CHAR(5);
        DEFINE cCodRetSp               CHAR(6);
		DEFINE cDescCodRet             CHAR(100);
		DEFINE iCodRetSp               INTEGER;
        DEFINE iSqlErr                 INTEGER;	
		DEFINE iConsecutivo             INTEGER;         
		DEFINE cNomArchivo             CHAR(23);        
		DEFINE cArchivoOrigen          CHAR(3);         
		DEFINE cIntegridad              CHAR(1);         
		DEFINE cIntegridadError        CHAR(20);        
		DEFINE cNumTarjeta             CHAR(16);        
		DEFINE cSecuencia               CHAR(6);         
		DEFINE cIdComercio325          CHAR(9);         
		DEFINE cNomComercio325         CHAR(30);        
		DEFINE cReferencia23_325        CHAR(23);        
		DEFINE cMonto                   CHAR(13);        
		DEFINE cRFC325                  CHAR(15);        
		DEFINE cDivisa325               CHAR(3);         
		DEFINE cMontoCashBack         CHAR(13);        
		DEFINE cConciliacion            CHAR(1);         
		DEFINE cTipoConciliacion       INTEGER;         
		DEFINE cSecuenciaExtendida     CHAR(15);        
		DEFINE mMontoIntercard         MONEY(16,2);      
		DEFINE cMovConciliado          CHAR(1);         
		DEFINE cMovReversado           CHAR(1);         
		DEFINE cAplicacion              CHAR(1);         
		DEFINE cFolioAplicacion        CHAR(16);        
		DEFINE cCodRetorno             CHAR(5);         
		DEFINE cTipoTransaccion325     CHAR(15);       
		DEFINE cMonto325                CHAR(13);       
		DEFINE cBanderaProceso         CHAR(1);   
		DEFINE iRecuperacion            INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET cDescCodRet = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET iConsecutivo = 0;       
		LET cNomArchivo = '';                  
		LET cArchivoOrigen = '';               
		LET cIntegridad = '';                   
		LET cIntegridadError = '';             
		LET cNumTarjeta = '';                  
		LET cSecuencia = '';                    
		LET cIdComercio325 = '';               
		LET cNomComercio325 = '';              
		LET cReferencia23_325 = '';             
		LET cMonto = '';                        
		LET cRFC325 = '';                       
		LET cDivisa325 = '';                    
		LET cMontoCashBack = '';              
		LET cConciliacion = '';                 
		LET cTipoConciliacion = '';            
		LET cSecuenciaExtendida = '';          
		LET mMontoIntercard = 0.00;   
		LET cMovConciliado = '';               
		LET cMovReversado = '';                
		LET cAplicacion = '';                   
		LET cFolioAplicacion = '';             
		LET cCodRetorno = '';                  
		LET cTipoTransaccion325 = '';         
		LET cMonto325 = '';                    
		LET cBanderaProceso = '';        
		LET iRecuperacion = 0;
		

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet,iConsecutivo,cNomArchivo,cArchivoOrigen,cIntegridad,cIntegridadError,cNumTarjeta,cSecuencia,cIdComercio325,cNomComercio325,              
					   cReferencia23_325,cMonto,cRFC325,cDivisa325,cMontoCashBack,cConciliacion,cTipoConciliacion,cSecuenciaExtendida,mMontoIntercard,   
					   cMovConciliado,cMovReversado,cAplicacion,cFolioAplicacion,cCodRetorno,cTipoTransaccion325,cMonto325,cBanderaProceso;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_consultamovpendientesccl.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pFecha IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet,iConsecutivo,cNomArchivo,cArchivoOrigen,cIntegridad,cIntegridadError,cNumTarjeta,cSecuencia,cIdComercio325,cNomComercio325,              
					   cReferencia23_325,cMonto,cRFC325,cDivisa325,cMontoCashBack,cConciliacion,cTipoConciliacion,cSecuenciaExtendida,mMontoIntercard,   
					   cMovConciliado,cMovReversado,cAplicacion,cFolioAplicacion,cCodRetorno,cTipoTransaccion325,cMonto325,cBanderaProceso;
            END IF;
            
			-- VALIDACIÃN DE LOS DATOS DE PAGINACIÃN
            IF pRegistros < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet,iConsecutivo,cNomArchivo,cArchivoOrigen,cIntegridad,cIntegridadError,cNumTarjeta,cSecuencia,cIdComercio325,cNomComercio325,              
					   cReferencia23_325,cMonto,cRFC325,cDivisa325,cMontoCashBack,cConciliacion,cTipoConciliacion,cSecuenciaExtendida,mMontoIntercard,   
					   cMovConciliado,cMovReversado,cAplicacion,cFolioAplicacion,cCodRetorno,cTipoTransaccion325,cMonto325,cBanderaProceso;
            END IF;
			
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet,iConsecutivo,cNomArchivo,cArchivoOrigen,cIntegridad,cIntegridadError,cNumTarjeta,cSecuencia,cIdComercio325,cNomComercio325,              
					   cReferencia23_325,cMonto,cRFC325,cDivisa325,cMontoCashBack,cConciliacion,cTipoConciliacion,cSecuenciaExtendida,mMontoIntercard,   
					   cMovConciliado,cMovReversado,cAplicacion,cFolioAplicacion,cCodRetorno,cTipoTransaccion325,cMonto325,cBanderaProceso;
			END IF;
			
			SET ISOLATION TO DIRTY READ;
			
			FOREACH
				EXECUTE PROCEDURE bditarjeta:'informix'.sp_concreing_consultamovpendientes2 (pUsuario, pFecha, pRegistros, pRecuperacion)
				INTO cCodRetSp,iConsecutivo,cNomArchivo,cArchivoOrigen,cIntegridad,cIntegridadError,cNumTarjeta,cSecuencia,cIdComercio325,cNomComercio325,              
					 cReferencia23_325,cMonto,cRFC325,cDivisa325,cMontoCashBack,cConciliacion,cTipoConciliacion,cSecuenciaExtendida,mMontoIntercard,   
					 cMovConciliado,cMovReversado,cAplicacion,cFolioAplicacion,cCodRetorno,cTipoTransaccion325,cMonto325,cBanderaProceso
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditarjeta:sp_concreing_consultamovpendientes2';
				ELSE
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet,iConsecutivo,cNomArchivo,cArchivoOrigen,cIntegridad,cIntegridadError,cNumTarjeta,cSecuencia,cIdComercio325,cNomComercio325,              
					 cReferencia23_325,cMonto,cRFC325,cDivisa325,cMontoCashBack,cConciliacion,cTipoConciliacion,cSecuenciaExtendida,mMontoIntercard,   
					 cMovConciliado,cMovReversado,cAplicacion,cFolioAplicacion,cCodRetorno,cTipoTransaccion325,cMonto325,cBanderaProceso WITH RESUME;
				END IF;
			END FOREACH;
			
			IF iRecuperacion = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017'; 
				RETURN cCodRet,iConsecutivo,cNomArchivo,cArchivoOrigen,cIntegridad,cIntegridadError,cNumTarjeta,cSecuencia,cIdComercio325,cNomComercio325,              
					   cReferencia23_325,cMonto,cRFC325,cDivisa325,cMontoCashBack,cConciliacion,cTipoConciliacion,cSecuenciaExtendida,mMontoIntercard,   
					   cMovConciliado,cMovReversado,cAplicacion,cFolioAplicacion,cCodRetorno,cTipoTransaccion325,cMonto325,cBanderaProceso;
			ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet,iConsecutivo,cNomArchivo,cArchivoOrigen,cIntegridad,cIntegridadError,cNumTarjeta,cSecuencia,cIdComercio325,cNomComercio325,              
					   cReferencia23_325,cMonto,cRFC325,cDivisa325,cMontoCashBack,cConciliacion,cTipoConciliacion,cSecuenciaExtendida,mMontoIntercard,   
					   cMovConciliado,cMovReversado,cAplicacion,cFolioAplicacion,cCodRetorno,cTipoTransaccion325,cMonto325,cBanderaProceso;
			END IF;
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 10/08/2015',
'DESCRIPCION: SPL que obtiene el detalle de los movimientos pendientes de aplicar.',
'FUNCIONALIDAD: Consulta de Movimientos Pendientes de Aplicar', 
'MODULO: CONCILIACIONES',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultaparamccl(pUsuario CHAR(8), pIdFuncion CHAR(10), pCodigo CHAR(3))	
		RETURNING CHAR(5) AS codret,
			CHAR(3) AS codigo,
			CHAR(50) AS desc_codigo,
			CHAR(90) AS valor,
			DATE AS fecha_mod;
			
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE cDescCodRet CHAR(100);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;	
		DEFINE cCodigo CHAR(3);
		DEFINE cDescripcion CHAR(50);
		DEFINE cValor CHAR(90);
		DEFINE dFechaMod DATE;
		DEFINE iNoRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET cDescCodRet = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET cCodigo = '';
		LET cDescripcion = '';
		LET cValor = ''; 	
		LET dFechaMod = '';
		LET iNoRegistros = 0;
		

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, cCodigo, cDescripcion, cValor, dFechaMod;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_consultaparamccl.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pCodigo = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cCodigo, cDescripcion, cValor, dFechaMod;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, cCodigo, cDescripcion, cValor, dFechaMod;
			END IF;
			
			SET ISOLATION TO DIRTY READ;

			EXECUTE PROCEDURE bditarjeta:'informix'.sp_concreing_consultaparam (pCodigo)
			INTO cCodigo, cDescripcion, cValor, dFechaMod;
			
			
			IF NVL(cCodigo,'') <> '' THEN 
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, cCodigo, UPPER(cDescripcion), UPPER(cValor), dFechaMod;
			END IF;
	
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00190';
				RETURN cCodRet, cCodigo, cDescripcion, cValor, dFechaMod;
			END IF;
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 10/08/2015',
'DESCRIPCION: SPL que obtiene la informacion correspondiente del codigo del parametro indicado.',
'FUNCIONALIDAD: Consulta de Movimientos Pendientes de Aplicar', 
'MODULO: CONCILIACIONES',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultarchivosccl(pUsuario CHAR(8), pIdFuncion CHAR(10), 
	pParam CHAR(1), pTipoArchOrigen CHAR(3), pFechaInicio DATE, pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)	
		RETURNING CHAR(5) AS codret,                         
	        CHAR(23) AS nom_archivo,                        
	        CHAR(3) AS archivo_origen,                      
	        DATE AS fecha_archivo,                                              
	        INTEGER AS num_registros325,                   
	        MONEY(16,2) AS monto325, 
			DATE AS fecha_proceso, 		
			DATETIME YEAR TO FRACTION(5) AS fecha_hora_transferencia,   		
			DATETIME YEAR TO FRACTION(5) AS fecha_hora_ini_proceso,     		
			DATETIME YEAR TO FRACTION(5) AS fecha_hora_carga_archivo,   		
			DATETIME YEAR TO FRACTION(5) AS fecha_hora_carga_tabla,		
			DATETIME YEAR TO FRACTION(5) AS fecha_hora_ini_concilia_reg,		
			DATETIME YEAR TO FRACTION(5) AS fecha_hora_fin_concilia_reg,		
			DATETIME YEAR TO FRACTION(5) AS fecha_hora_fin_proceso,		
			DATETIME YEAR TO FRACTION(5) AS fecha_hora_gen_conadmin,		
			CHAR(1) AS transferencia,		
			CHAR(1) AS carga,		
			CHAR(1) AS conadmin,		
			INTEGER AS num_cargo,		
			MONEY(16,2) AS monto_cargo,		
			INTEGER AS num_abono,		
			MONEY(16,2) AS monto_abono,		
			CHAR(1) AS proceso;					
			
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE cDescCodRet CHAR(80);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;	
		DEFINE cNombreArchivo CHAR(23);
		DEFINE cArchivoOrigen CHAR(3);
		DEFINE dFechaArchivo DATE;
		DEFINE iNumRegistros325 INTEGER;
		DEFINE mMonto325 MONEY(16,2);
		DEFINE dFechaProceso DATE;
		DEFINE dFechaHoraTransferencia DATETIME YEAR TO FRACTION(5);
		DEFINE dFechaHoraIniProceso DATETIME YEAR TO FRACTION(5);
		DEFINE dFechaHoraCargaArchivo DATETIME YEAR TO FRACTION(5);
		DEFINE dFechaHoraCargaTabla DATETIME YEAR TO FRACTION(5);
		DEFINE dFechaHoraIniConciliaReg DATETIME YEAR TO FRACTION(5);
		DEFINE dFechaHoraFinConciliaReg DATETIME YEAR TO FRACTION(5);
		DEFINE dFechaHoraFinProceso DATETIME YEAR TO FRACTION(5);
		DEFINE dFechaHoraGenConadmin DATETIME YEAR TO FRACTION(5);
		DEFINE cTransferencia CHAR(1);
		DEFINE cCarga CHAR(1);
		DEFINE cConadmin CHAR(1);
		DEFINE iNumCargo INTEGER;
		DEFINE mMontoCargo MONEY(16,2);
		DEFINE iNumAbono INTEGER;
		DEFINE mMontoAbono MONEY(16,2);
		DEFINE cProceso CHAR(1);  
		DEFINE iRecuperacion INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET cDescCodRet = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET cNombreArchivo = '';
		LET cArchivoOrigen = '';
		LET dFechaArchivo = '';
		LET iNumRegistros325 = 0;
		LET mMonto325 = 0.00;
		LET dFechaProceso = '';
		LET dFechaHoraTransferencia = '';
		LET dFechaHoraIniProceso = '';
		LET dFechaHoraCargaArchivo = '';
		LET dFechaHoraCargaTabla = '';
		LET dFechaHoraIniConciliaReg = '';
		LET dFechaHoraFinConciliaReg = '';
		LET dFechaHoraFinProceso = '';
		LET dFechaHoraGenConadmin = '';
		LET cTransferencia = '';
		LET cCarga = '';
		LET cConadmin = '';
		LET iNumCargo = 0;
		LET mMontoCargo = 0.00;
		LET iNumAbono = 0;
		LET mMontoAbono = 0.00;
		LET cProceso = '';    
		LET iRecuperacion = 0;
		

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet,cNombreArchivo,cArchivoOrigen,dFechaArchivo,iNumRegistros325,mMonto325,dFechaProceso,dFechaHoraTransferencia,
				dFechaHoraIniProceso,dFechaHoraCargaArchivo,dFechaHoraCargaTabla,dFechaHoraIniConciliaReg,dFechaHoraFinConciliaReg,
				dFechaHoraFinProceso,dFechaHoraGenConadmin,cTransferencia,cCarga,cConadmin,iNumCargo,mMontoCargo,iNumAbono,mMontoAbono,cProceso;
			END EXCEPTION;
            
            -- SET DEBUG FILE TO '/tmp/mfinis/sp_consultarchivosccl.out';
            -- TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pParam = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet,cNombreArchivo,cArchivoOrigen,dFechaArchivo,iNumRegistros325,mMonto325,dFechaProceso,dFechaHoraTransferencia,
				dFechaHoraIniProceso,dFechaHoraCargaArchivo,dFechaHoraCargaTabla,dFechaHoraIniConciliaReg,dFechaHoraFinConciliaReg,
				dFechaHoraFinProceso,dFechaHoraGenConadmin,cTransferencia,cCarga,cConadmin,iNumCargo,mMontoCargo,iNumAbono,mMontoAbono,cProceso;
            END IF;
            
			-- VALIDACIÃN DE LOS DATOS DE PAGINACIÃN
            IF pRegistros < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet,cNombreArchivo,cArchivoOrigen,dFechaArchivo,iNumRegistros325,mMonto325,dFechaProceso,dFechaHoraTransferencia,
				dFechaHoraIniProceso,dFechaHoraCargaArchivo,dFechaHoraCargaTabla,dFechaHoraIniConciliaReg,dFechaHoraFinConciliaReg,
				dFechaHoraFinProceso,dFechaHoraGenConadmin,cTransferencia,cCarga,cConadmin,iNumCargo,mMontoCargo,iNumAbono,mMontoAbono,cProceso;
            END IF;
			
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet,cNombreArchivo,cArchivoOrigen,dFechaArchivo,iNumRegistros325,mMonto325,dFechaProceso,dFechaHoraTransferencia,
				dFechaHoraIniProceso,dFechaHoraCargaArchivo,dFechaHoraCargaTabla,dFechaHoraIniConciliaReg,dFechaHoraFinConciliaReg,
				dFechaHoraFinProceso,dFechaHoraGenConadmin,cTransferencia,cCarga,cConadmin,iNumCargo,mMontoCargo,iNumAbono,mMontoAbono,cProceso;
			END IF;
			
			IF pParam = '2' THEN
				IF pTipoArchOrigen = '' THEN 
					LET cCodRet = '00003';
					RETURN cCodRet,cNombreArchivo,cArchivoOrigen,dFechaArchivo,iNumRegistros325,mMonto325,dFechaProceso,dFechaHoraTransferencia,
					dFechaHoraIniProceso,dFechaHoraCargaArchivo,dFechaHoraCargaTabla,dFechaHoraIniConciliaReg,dFechaHoraFinConciliaReg,
					dFechaHoraFinProceso,dFechaHoraGenConadmin,cTransferencia,cCarga,cConadmin,iNumCargo,mMontoCargo,iNumAbono,mMontoAbono,cProceso;
				END IF;
			END IF;
			
			SET ISOLATION TO DIRTY READ;
			
			FOREACH
				EXECUTE PROCEDURE bditarjeta:'informix'.sp_conarchivos_con2(pParam,pTipoArchOrigen,pFechaInicio,pFechaFin,pUsuario,pUsuario,pRegistros,pRecuperacion)
				INTO cCodRetSp,cDescCodRet,cNombreArchivo,cArchivoOrigen,dFechaArchivo,iNumRegistros325,mMonto325,dFechaProceso,dFechaHoraTransferencia,
				dFechaHoraIniProceso,dFechaHoraCargaArchivo,dFechaHoraCargaTabla,dFechaHoraIniConciliaReg,dFechaHoraFinConciliaReg,
				dFechaHoraFinProceso,dFechaHoraGenConadmin,cTransferencia,cCarga,cConadmin,iNumCargo,mMontoCargo,iNumAbono,mMontoAbono,cProceso
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditarjeta:sp_conarchivos_con2';
				ELSE
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet,UPPER(cNombreArchivo),UPPER(cArchivoOrigen),dFechaArchivo,iNumRegistros325,mMonto325,dFechaProceso,dFechaHoraTransferencia,
					dFechaHoraIniProceso,dFechaHoraCargaArchivo,dFechaHoraCargaTabla,dFechaHoraIniConciliaReg,dFechaHoraFinConciliaReg,
					dFechaHoraFinProceso,dFechaHoraGenConadmin,UPPER(cTransferencia),UPPER(cCarga),UPPER(cConadmin),iNumCargo,mMontoCargo,iNumAbono,mMontoAbono,UPPER(cProceso) WITH RESUME;
				END IF;
			END FOREACH;
			
			IF iRecuperacion = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017'; 
				RETURN cCodRet,cNombreArchivo,cArchivoOrigen,dFechaArchivo,iNumRegistros325,mMonto325,dFechaProceso,dFechaHoraTransferencia,
				dFechaHoraIniProceso,dFechaHoraCargaArchivo,dFechaHoraCargaTabla,dFechaHoraIniConciliaReg,dFechaHoraFinConciliaReg,
				dFechaHoraFinProceso,dFechaHoraGenConadmin,cTransferencia,cCarga,cConadmin,iNumCargo,mMontoCargo,iNumAbono,mMontoAbono,cProceso;
			ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet,cNombreArchivo,cArchivoOrigen,dFechaArchivo,iNumRegistros325,mMonto325,dFechaProceso,dFechaHoraTransferencia,
				dFechaHoraIniProceso,dFechaHoraCargaArchivo,dFechaHoraCargaTabla,dFechaHoraIniConciliaReg,dFechaHoraFinConciliaReg,
				dFechaHoraFinProceso,dFechaHoraGenConadmin,cTransferencia,cCarga,cConadmin,iNumCargo,mMontoCargo,iNumAbono,mMontoAbono,cProceso;
			END IF;
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 08/09/2015',
'DESCRIPCION: SPL que obtiene el detalle de los archivos de conciliaciÃ³n.',
'FUNCIONALIDAD: Consulta de Archivos de ConciliaciÃ³n', 
'MODULO: CONCILIACIONES',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultarchivosccl_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), 
	pParam CHAR(1), pTipoArchOrigen CHAR(3), pFechaInicio DATE, pFechaFin DATE)	
		RETURNING CHAR(5) AS codret,                           
			INTEGER AS num_registros;

	DEFINE cCodRet 					CHAR(5);
	DEFINE cCodRetSp 				CHAR(6);
	DEFINE cDescCodRet 				CHAR(100);
	DEFINE iCodRetSp				INTEGER;
	DEFINE iSqlErr 					INTEGER;	
	DEFINE iNumRegistros 			INTEGER;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cDescCodRet = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;
	LET iNumRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumRegistros;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_consultarchivosccl_totales.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pParam = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNumRegistros;
		END IF;

		IF pParam = '2' THEN
			IF pTipoArchOrigen = '' THEN 
				LET cCodRet = '00003';
				RETURN cCodRet, iNumRegistros;
			END IF;
		END IF;
			
		EXECUTE PROCEDURE bditarjeta:'informix'.sp_conarchivos_con2_totales(pParam,pTipoArchOrigen,pFechaInicio,pFechaFin,pUsuario,pUsuario)
		INTO cCodRetSp,iNumRegistros;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditarjeta:sp_conarchivos_con2_totales';
		END IF;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00017';		
		END IF;
        
		RETURN cCodRet, iNumRegistros;
		
	END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 08/09/2015',
'DESCRIPCION: SPL que obtiene el nÃºmero total de archivos de conciliaciÃ³n.',
'FUNCIONALIDAD: Consulta de Archivos de ConciliaciÃ³n', 
'MODULO: CONCILIACIONES',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultausuariosccl(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
		CHAR(1) AS activo,
		CHAR(10) AS clave,
		CHAR(30) AS nombre,
		CHAR(1) AS operacion,
		CHAR(1) AS monitoreo ,
		CHAR(1) AS admon,
		DATETIME YEAR TO FRACTION(5) AS fecha;	
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cActivo CHAR(1);				
	DEFINE cClave CHAR(10);
	DEFINE cNombre CHAR(30);						
	DEFINE cOperacion CHAR(1);
	DEFINE cMonitoreo CHAR(1);						 
	DEFINE cAdmon CHAR(1);			
	DEFINE dFecha DATETIME YEAR TO FRACTION(5);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET cActivo ='';
	LET cClave ='';
	LET cNombre ='';						
	LET cOperacion ='';
	LET cMonitoreo ='';					 
	LET cAdmon ='';				
	LET dFecha='';
	LET iNoRegistros = 0;
			
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cActivo,cClave,cNombre,cOperacion,cMonitoreo,cAdmon,dFecha;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultausuariosccl.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cActivo,cClave,cNombre,cOperacion,cMonitoreo,cAdmon,dFecha;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cActivo,cClave,cNombre,cOperacion,cMonitoreo,cAdmon,dFecha;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		FOREACH
			EXECUTE PROCEDURE bditarjeta:'informix'.sp_concreing_consultausuariosconciliacion()
			INTO cCodRetSp, cActivo,cClave,cNombre,cOperacion,cMonitoreo,cAdmon,dFecha			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditarjeta:sp_concreing_consultausuariosconciliacion';
			END IF;
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, UPPER (TRIM(cActivo)),cClave,UPPER (TRIM(cNombre)),UPPER (TRIM(cOperacion)),UPPER (TRIM(cMonitoreo)), UPPER (TRIM(cAdmon)), dFecha WITH RESUME;	
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cActivo,cClave,cNombre,cOperacion,cMonitoreo,cAdmon,dFecha;
		END IF;
		
		END;
		
	END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 21/09/2015',
'MODULO: CONCILIACIONES  ',
'FUNCIONALIDAD: ADMINISTRACIÓN DE USUARIOS   ',
'DESCRIPCION: SPL que consulta el almacenamiento de los usuarios',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_guardabitacoraccl(pUsuario CHAR(8), pIdFuncion CHAR(10), pElemento INTEGER, pActividad CHAR(150))	
		RETURNING CHAR(5) AS codret;
			
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRet CHAR(100);
	DEFINE iCodRetSp INTEGER;
	DEFINE iSqlErr INTEGER;	
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cDescCodRet = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_guardabitacoraccl.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pElemento = '' OR pActividad = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
	
		EXECUTE PROCEDURE bditarjeta:'informix'.sp_concreing_guardabitacora(pElemento,pActividad,pUsuario)
		INTO cCodRetSp;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditarjeta:sp_concreing_guardabitacora';
		END IF;
			
		LET iCodRetSp = cCodRetSp::INTEGER;
		LET cCodRet = LPAD(iCodRetSp, 5, '0');
		RETURN cCodRet;
		
	END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 19/08/2015',
'DESCRIPCION: SPL que realiza el guardado en bitÃ¡cora.',
'FUNCIONALIDAD: Mantenimiento de Cron', 
'MODULO: CONCILIACIONES',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mantenimientoparametroopeccl(pUsuario CHAR(8), pIdFuncion CHAR(10),pFlag CHAR(1),pComDebito CHAR(4),pComCredito CHAR(4),pComPago CHAR(4),pComDeposito CHAR(4),pConcEjec CHAR(1),pComSaldoDebito CHAR(4),pComSaldoCredito CHAR(4),pComDisposicionDebito CHAR(4),pComDisposicionCredito CHAR(4),pComTranferenciaEfectiva CHAR(4),pComPagTDCBCPLCargEfectiva CHAR(4),pComPagTDCOtroCargEfectiva CHAR(4),pComPagTDCOtroEfectivo	CHAR(4),pComTransferencia CHAR(4))
		RETURNING CHAR(5) AS codret,
		CHAR(4) AS comdebito,
		CHAR(4) AS comcredito,
		CHAR(4) AS compago,
		CHAR(4) AS comdeposito,
		CHAR(1) AS concejec,
		CHAR(4) AS comsaldodebito,
		CHAR(4) AS comsaldocredito,
		CHAR(4) AS comdisposiciondebito,	
		CHAR(4) AS comdisposicioncredito,
		CHAR(4) AS comtranferenciaefectiva,
		CHAR(4) AS compagTDCBCPLcargefectiva,
		CHAR(4) AS compagTDCOtrocargefectiva,
		CHAR(4) AS compagTDCOtroefectivo,
		CHAR(4) AS comtransferencia;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cComDebito CHAR(4);
	DEFINE cComCredito CHAR(4);
	DEFINE cComPago CHAR(4);
	DEFINE cComDeposito CHAR(4);
	DEFINE cConcEjec CHAR(1);
	DEFINE cComSaldoDebito CHAR(4);
	DEFINE cComSaldoCredito CHAR(4);
	DEFINE cComDisposicionDebito CHAR(4);
	DEFINE cComDisposicionCredito CHAR(4);
	DEFINE cComTranferenciaEfectiva CHAR(4);
	DEFINE cComPagTDCBCPLCargEfectiva CHAR(4);
	DEFINE cComPagTDCOtroCargEfectiva CHAR(4);
	DEFINE cComPagTDCOtroEfectivo CHAR(4);
	DEFINE cComTransferencia CHAR(4);
	DEFINE iNoRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET cComDebito = '';
	LET cComCredito = '';
	LET cComPago = '';
	LET cComDeposito = '';
	LET cConcEjec = '';
	LET cComSaldoDebito = '';
	LET cComSaldoCredito = '';
	LET cComDisposicionDebito = '';
	LET cComDisposicionCredito = '';
	LET cComTranferenciaEfectiva = '';
	LET cComPagTDCBCPLCargEfectiva = '';
	LET cComPagTDCOtroCargEfectiva = '';
	LET cComPagTDCOtroEfectivo = '';
	LET cComTransferencia = '';
	LET iNoRegistros = 0;
	LET iRecuperacion = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cComDebito,cComCredito,cComPago,cComDeposito,
			cConcEjec,cComSaldoDebito,cComSaldoCredito,cComDisposicionDebito
			,cComDisposicionCredito,cComTranferenciaEfectiva,
			cComPagTDCBCPLCargEfectiva,cComPagTDCOtroCargEfectiva,
			cComPagTDCOtroEfectivo,cComTransferencia;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mantenimientoparametroopeccl.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pFlag = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cComDebito,cComCredito,cComPago,cComDeposito,
			cConcEjec,cComSaldoDebito,cComSaldoCredito,cComDisposicionDebito
			,cComDisposicionCredito,cComTranferenciaEfectiva,
			cComPagTDCBCPLCargEfectiva,cComPagTDCOtroCargEfectiva,
			cComPagTDCOtroEfectivo,cComTransferencia;
		END IF;
			
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cComDebito,cComCredito,cComPago,cComDeposito,
			cConcEjec,cComSaldoDebito,cComSaldoCredito,cComDisposicionDebito
			,cComDisposicionCredito,cComTranferenciaEfectiva,
			cComPagTDCBCPLCargEfectiva,cComPagTDCOtroCargEfectiva,
			cComPagTDCOtroEfectivo,cComTransferencia;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
	
		EXECUTE PROCEDURE bditarjeta:'informix'.sp_concreing_maparopecr(pFlag,pComDebito ,pComCredito,pComPago,pComDeposito,pConcEjec ,pComSaldoDebito,pComSaldoCredito,pComDisposicionDebito,pComDisposicionCredito,pComTranferenciaEfectiva,pComPagTDCBCPLCargEfectiva,pComPagTDCOtroCargEfectiva,pComPagTDCOtroEfectivo,pComTransferencia,pUsuario)
		INTO cCodRetSp,cComDebito,cComCredito,cComPago,cComDeposito,
			cConcEjec,cComSaldoDebito,cComSaldoCredito,cComDisposicionDebito
			,cComDisposicionCredito,cComTranferenciaEfectiva,
			cComPagTDCBCPLCargEfectiva,cComPagTDCOtroCargEfectiva,
			cComPagTDCOtroEfectivo,cComTransferencia;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditarjeta:sp_concreing_maparopecr';
		END IF;
		
		RETURN cCodRet, cComDebito,cComCredito,cComPago,cComDeposito,
			cConcEjec,cComSaldoDebito,cComSaldoCredito,cComDisposicionDebito
			,cComDisposicionCredito,cComTranferenciaEfectiva,
			cComPagTDCBCPLCargEfectiva,cComPagTDCOtroCargEfectiva,
			cComPagTDCOtroEfectivo,cComTransferencia;
		END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 22/09/2015',
'MODULO: CONCILIACIONES  ',
'FUNCIONALIDAD: MANTENIMIENTO DE PARÁMETROS OPERATIVOS',
'DESCRIPCION:SPL para cambios en parametros de conciliacion reingenieria hechos por usuario',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validaintegridadccl(pUsuario CHAR(8), pIdFuncion CHAR(10), pArchOrigen CHAR(3), pIntegridad CHAR(1), 
	pConsecutivo INTEGER, pNumTarjeta CHAR(16), pTipoTransaccion325 CHAR(15), pMonto325 CHAR(13), pIdComercio325 CHAR(9), 
	pNomComercio325 CHAR(30), pReferencia23_325 CHAR(23), pSecuencia325 CHAR(6), pDivisa325 CHAR(3), pRfc325 CHAR(16))
		RETURNING CHAR(5) AS codret;
			
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE cDescCodRet CHAR(100);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;	
		DEFINE cIntegridad CHAR(1);
		DEFINE cErrorActividad CHAR(250);
		DEFINE cIntegridadError CHAR(20);
		DEFINE cSistema CHAR(1);
		DEFINE cMontoCB325 CHAR(13);
		DEFINE cEsNoNumTarjeta CHAR(1);
		DEFINE cEsNoIdComercio325 CHAR(1);
		DEFINE cEsNoSecuencia325 CHAR(1);
		DEFINE cEsNoDivisa325 CHAR(1);
		DEFINE cEsNoMonto325 CHAR(1);
		DEFINE cEsNoRef23_325 CHAR(1);
		DEFINE cEsNoMontoCB325 CHAR(1);
		DEFINE cMonto325 MONEY (18,2);
		DEFINE cMontoCashBack325 MONEY (18,2);
		DEFINE cBine CHAR(6);
		DEFINE iNoRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET cDescCodRet = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET cIntegridad = '';
		LET cErrorActividad = ''; 	
		LET cIntegridadError = '';
		LET cSistema = '';
		LET cMontoCB325 = '';
		LET cEsNoNumTarjeta = '';
		LET cEsNoIdComercio325 = '';
		LET cEsNoSecuencia325 = '';
		LET cEsNoDivisa325 = '';
		LET cEsNoMonto325 = '';
		LET cEsNoRef23_325 = '';
		LET cEsNoMontoCB325 = '';
		LET cMonto325 = 0.00;
		LET cMontoCashBack325 = 0.00;
		LET cBine = '';
		LET iNoRegistros = 0;
	
		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_validaintegridadccl.out';
            --TRACE ON;
            
			-- VALIDACION DE PARAMETROS REQUERIDOS
			IF pUsuario = '' OR pIdFuncion = '' OR pArchOrigen = '' OR pNumTarjeta = '' OR pMonto325 = '' OR pNomComercio325 = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
			END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet;
			END IF;
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;

			-- LECTURA DEL CAMPO SISTEMA
			SELECT FIRST 1 sistema INTO cSistema
			FROM bditarjeta:"informix".td_archivo_origen
			WHERE archivo_origen = pArchOrigen;

			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;

			-- RECUPERA EL VALOR DEL MONTO CASHBACK DEL REGISTRO EN CUESTION
			SELECT montocashback325 INTO cMontoCB325 
			FROM bditarjeta:"informix".td_movimientos_conciliacion
			WHERE archivo_origen = pArchOrigen AND consecutivo = pConsecutivo;
			
			IF ((pArchOrigen = 'MCD') OR (pArchOrigen = 'MCC')) THEN	
	   
				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pNumTarjeta) INTO cEsNoNumTarjeta;
				IF cEsNoNumTarjeta = 'F' THEN
					LET cCodRet = '00595'; --NÃMERO DE TARJETA INVALIDO, DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet;
				ELSE				
					IF LENGTH(pNumTarjeta)!= 16 THEN
						LET cCodRet = '00596'; --EL NÃMERO DE TARJETA DEBE SER DE 16 POSICIONES, VERIFIQUE
						RETURN cCodRet;
					ELSE
						IF pNumTarjeta = '0000000000000000' THEN
							LET cCodRet = '00597'; --EL NÃMERO DE TARJETA NO PUEDE TENER SÃLO CEROS
							RETURN cCodRet;
						END IF;
					END IF;					
				END IF;

				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pIdComercio325) INTO cEsNoIdComercio325;
				IF cEsNoIdComercio325 = 'F' THEN
					LET cCodRet = '00598'; --LA CLAVE DE COMERCIO DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet;
				END IF;

				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pSecuencia325) INTO cEsNoSecuencia325 ;
				IF cEsNoSecuencia325 = 'F' THEN
					LET cCodRet = '00599'; --NÃMERO DE SECUENCIA INVALIDO, DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet;
				ELSE
					IF LENGTH(pSecuencia325) != 6 THEN
						LET cCodRet = '00600'; --EL NÃMERO DE SECUENCIA DEBE SER DE 6 POSICIONES, VERIFIQUE
						RETURN cCodRet;
				ELSE
					IF pSecuencia325 = '000000' THEN
						LET cCodRet = '00728'; --NÃMERO DE SECUENCIA DEBE SER DIFERENTE DE 000000, VERIFIQUE
						RETURN cCodRet;
					END IF;
					END IF;
				END IF;

				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pDivisa325) INTO cEsNoDivisa325 ;
				IF cEsNoDivisa325 = 'F' THEN
					LET cCodRet = '00601'; --NÃMERO DE DIVISA INVALIDO, DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet;
				ELSE

					IF LENGTH(TRIM(pDivisa325)) != 3 THEN
						LET cCodRet = '00602'; --EL NÃMERO DE DIVISA DEBE SER DE 3 POSICIONES, VERIFIQUE
						RETURN cCodRet;
					ELSE
						IF pDivisa325 = '000' THEN
							LET cCodRet = '00603'; --EL NÃMERO DE DIVISA NO PUEDE TENER SÃLO CEROS
							RETURN cCodRet;
						END IF;
					END IF;

				END IF;

				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pMonto325) INTO cEsNoMonto325;
				IF cEsNoMonto325 = 'F' THEN
					LET cCodRet = '00604'; --EL MONTO DE LA TRANSACCIÃN DEBE SER NÃMERICO, VERIFIQUE
					RETURN cCodRet;
				ELSE 
					LET cMonto325 = ((REPLACE(pMonto325,'.',''))::MONEY/100);
					IF (cMonto325 = 0) THEN
						LET cCodRet = '00605'; --EL MONTO DE LA TRANSACCIÃN DEBE SER DIFERENTE DE CERO
						RETURN cCodRet; 
					END IF; 
				END IF;

				-- OBTENIENDO LA CIFRA DEL BIN DE LA TARJETA
				LET cBine = NVL(SUBSTRING(pNumTarjeta FROM 1 FOR 6),'');
				IF ((pArchOrigen = 'MCD') AND ((cBine NOT IN (SELECT Bin FROM Intercard:"informix".Bines WHERE CreditoDebito = 'D')) OR (cSistema != 'D'))) THEN -- BIN 400819 EN VID
					LET cCodRet = '00606'; --ERROR DE INTEGRIDAD CON EL NÃMERO DE TARJETA, EL BIN DEL REGISTRO NO COINCIDE
					RETURN cCodRet;
				END IF;
				IF ((pArchOrigen = 'MCC') AND ((cBine NOT IN (SELECT Bin FROM Intercard:"informix".Bines WHERE CreditoDebito = 'C')) OR (cSistema != 'C'))) THEN -- BIN 426807 EN VIC
					LET cCodRet = '00606'; --ERROR DE INTEGRIDAD CON EL NÃMERO DE TARJETA, EL BIN DEL REGISTRO NO COINCIDE
					RETURN cCodRet;
				END IF;

				IF ((pTipoTransaccion325 NOT IN ('01','02','05','06','07','21')) AND (NOT((pArchOrigen = 'VID') AND (pTipoTransaccion325 = '20')))) THEN -- VIC CON PSTIPOTRANSACCION325 = 20 ES PARA MONEYGRAM
					LET cCodRet = '00607'; --EL TIPO DE TRANSACCION ES INCORRECTO, VERIFIQUE
					RETURN cCodRet;
				END IF;
				
			ELIF ((pArchOrigen = 'VID') OR (pArchOrigen = 'VIC')) THEN  

				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pNumTarjeta) INTO cEsNoNumTarjeta;
				IF cEsNoNumTarjeta = 'F' THEN
					LET cCodRet = '00595'; --NÃMERO DE TARJETA INVALIDO, DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet;
				ELSE
				
					IF LENGTH(pNumTarjeta)!= 16 THEN
						LET cCodRet = '00596'; --EL NÃMERO DE TARJETA DEBE SER DE 16 POSICIONES, VERIFIQUE
						RETURN cCodRet;
					ELSE
						IF pNumTarjeta = '0000000000000000' THEN
							LET cCodRet = '00597'; --EL NÃMERO DE TARJETA NO PUEDE TENER SÃLO CEROS
							RETURN cCodRet;
						END IF;
					END IF;	
				
				END IF;

				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pIdComercio325) INTO cEsNoIdComercio325;
				IF cEsNoIdComercio325 = 'F' THEN
					LET cCodRet = '00598'; --LA CLAVE DE COMERCIO DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet;
				END IF;

				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pSecuencia325) INTO cEsNoSecuencia325 ;
				IF cEsNoSecuencia325 = 'F' THEN
					LET cCodRet = '00599'; --NÃMERO DE SECUENCIA INVALIDO, DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet;
				ELSE
					IF LENGTH(pSecuencia325) != 6 THEN
						LET cCodRet = '00600'; --EL NÃMERO DE SECUENCIA DEBE SER DE 6 POSICIONES, VERIFIQUE
						RETURN cCodRet;
				ELSE 
					IF pSecuencia325 = '000000' THEN
						LET cCodRet = '00728'; --NÃMERO DE SECUENCIA DEBE SER DIFERENTE DE 000000, VERIFIQUE
						RETURN cCodRet;
					END IF;
					END IF;
				END IF;

				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pDivisa325) INTO cEsNoDivisa325 ;
				IF cEsNoDivisa325 = 'F' THEN
					LET cCodRet = '00601'; --NÃMERO DE DIVISA INVALIDO, DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet;
				ELSE

					IF LENGTH(TRIM(pDivisa325)) != 3 THEN
						LET cCodRet = '00602'; --EL NÃMERO DE DIVISA DEBE SER DE 3 POSICIONES, VERIFIQUE
						RETURN cCodRet;
					ELSE
						IF pDivisa325 = '000' THEN
							LET cCodRet = '00603'; --EL NÃMERO DE DIVISA NO PUEDE TENER SÃLO CEROS
							RETURN cCodRet;
						END IF;
					END IF;

				END IF;

				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pMonto325) INTO cEsNoMonto325;
				IF cEsNoMonto325 = 'F' THEN
					LET cCodRet = '00604'; --EL MONTO DE LA TRANSACCIÃN DEBE SER NÃMERICO, VERIFIQUE
					RETURN cCodRet;
				ELSE 
					LET cMonto325 = ((REPLACE(pMonto325,'.',''))::MONEY/100);
					IF (cMonto325 = 0) THEN
						LET cCodRet = '00605'; --EL MONTO DE LA TRANSACCIÃN DEBE SER DIFERENTE DE CERO
						RETURN cCodRet; 
					END IF; 
				END IF;
				
				-- OBTENIENDO LA CIFRA DEL BIN DE LA TARJETA
				LET cBine = NVL(SUBSTRING(pNumTarjeta FROM 1 FOR 6),'');
				IF ((pArchOrigen = 'VID') AND ((cBine NOT IN (SELECT Bin FROM Intercard:"informix".Bines WHERE CreditoDebito = 'D')) OR (cSistema != 'D'))) THEN -- BIN 400819 EN VID
					LET cCodRet = '00606'; --ERROR DE INTEGRIDAD CON EL NÃMERO DE TARJETA, EL BIN DEL REGISTRO NO COINCIDE
					RETURN cCodRet;
				END IF;
				IF ((pArchOrigen = 'VIC') AND ((cBine NOT IN (SELECT Bin FROM Intercard:"informix".Bines WHERE CreditoDebito = 'C')) OR (cSistema != 'C' ))) THEN -- BIN 426807 EN VIC
					LET cCodRet = '00606'; --ERROR DE INTEGRIDAD CON EL NÃMERO DE TARJETA, EL BIN DEL REGISTRO NO COINCIDE
					RETURN cCodRet;
				END IF;	
				
				IF ((pTipoTransaccion325 NOT IN ('01','02','05','06','07','21')) AND (NOT((pArchOrigen = 'VID') AND (pTipoTransaccion325 = '20')))) THEN -- VIC CON PSTIPOTRANSACCION325 = 20 ES PARA MONEYGRAM
					LET cCodRet = '00607'; --EL TIPO DE TRANSACCION ES INCORRECTO, VERIFIQUE
					RETURN cCodRet;
				END IF;

				IF LENGTH(TRIM(pIdComercio325)) < 9 THEN
					LET cCodRet = '00608'; --LA CLAVE DE COMERCIO DEBE SER DE 9 POSICIONES, VERIFIQUE
					RETURN cCodRet;
				END IF; 
				
				
			-- VALIDACION DE INTEGRIDAD DE REGISTROS, ARCHIVOS E-GLOBAL VENTAS NACIONALES Y ARCHIVOS COPPEL INTERREDES (BCPLVND, BCPLVNC, BCPLTCD Y BCPLTCC)
			ELIF ((pArchOrigen = 'VND') OR (pArchOrigen = 'VNC') OR (pArchOrigen = 'TCD') OR (pArchOrigen = 'TCC')) THEN
				
				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pNumTarjeta) INTO cEsNoNumTarjeta;
				IF cEsNoNumTarjeta = 'F' THEN
					LET cCodRet = '00595'; --NÃMERO DE TARJETA INVALIDO, DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet;
				ELSE
				
					IF LENGTH(pNumTarjeta)!= 16 THEN
						LET cCodRet = '00596'; --EL NÃMERO DE TARJETA DEBE SER DE 16 POSICIONES, VERIFIQUE
						RETURN cCodRet;
					ELSE
						IF pNumTarjeta = '0000000000000000' THEN
							LET cCodRet = '00597'; --EL NÃMERO DE TARJETA NO PUEDE TENER SÃLO CEROS
							RETURN cCodRet;
						END IF;
					END IF;	
				
				END IF;

				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pIdComercio325) INTO cEsNoIdComercio325;
				IF cEsNoIdComercio325 = 'F' THEN
					LET cCodRet = '00598'; --LA CLAVE DE COMERCIO DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet;
				END IF;

				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pSecuencia325) INTO cEsNoSecuencia325 ;
				IF cEsNoSecuencia325 = 'F' THEN
					LET cCodRet = '00599'; --NÃMERO DE SECUENCIA INVALIDO, DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet;
				ELSE
					IF LENGTH(pSecuencia325) != 6 THEN
						LET cCodRet = '00600'; --EL NÃMERO DE SECUENCIA DEBE SER DE 6 POSICIONES, VERIFIQUE
						RETURN cCodRet;
					END IF;
				END IF;

				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pMonto325) INTO cEsNoMonto325;
				IF cEsNoMonto325 = 'F' THEN
					LET cCodRet = '00604'; --EL MONTO DE LA TRANSACCIÃN DEBE SER NÃMERICO, VERIFIQUE
					RETURN cCodRet;
				ELSE 
					LET cMonto325 = ((REPLACE(pMonto325,'.',''))::MONEY/100);
					IF (cMonto325 = 0) THEN
						LET cCodRet = '00605'; --EL MONTO DE LA TRANSACCIÃN DEBE SER DIFERENTE DE CERO
						RETURN cCodRet; 
					END IF; 
				END IF;
				
				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pReferencia23_325) INTO cEsNoRef23_325;
				IF cEsNoRef23_325 = 'F' THEN
					LET cCodRet = '00609'; --NÃMERO DE REFERENCIA INVALIDO, DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet; 
				END IF;

				IF (TRIM(NVL(cMontoCB325,'')) = '') THEN
					LET cCodRet = '00610'; --NO SE ENCONTRO EL VALOR DEL MONTO CASHBACK DEL REGISTRO EN CUESTION
					RETURN cCodRet;
				ELSE
				
					EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(cMontoCB325) INTO cEsNoMontoCB325;
					IF cEsNoMontoCB325 = 'F' THEN
						LET cCodRet = '00611'; --EL MONTO CASHBACK DEBE SER NÃMERICO
						RETURN cCodRet;
					ELSE
						LET cMontoCashBack325 = ((REPLACE(cMontoCB325,'.',''))::MONEY/100); 
						IF (cMonto325 + cMontoCashBack325 = 0) THEN
							LET cCodRet = '00612'; --EL MONTO CASHBACK DEBE SER DIFERENTE DE CERO
							RETURN cCodRet; 
						END IF; 		
					END IF;		
				
				END IF;

				-- OBTENIENDO LA CIFRA DEL BIN DE LA TARJETA
				LET cBine = NVL(SUBSTRING(pNumTarjeta FROM 1 FOR 6),'');
				IF (((pArchOrigen = 'VND') OR (pArchOrigen = 'TCD')) AND ((cBine NOT IN (SELECT Bin FROM Intercard:"informix".Bines WHERE CreditoDebito = 'D')) OR (cSistema != 'D'))) THEN -- BIN 400819 EN VID
					LET cCodRet = '00606'; --ERROR DE INTEGRIDAD CON EL NÃMERO DE TARJETA, EL BIN DEL REGISTRO NO COINCIDE
					RETURN cCodRet;
				END IF;
				IF (((pArchOrigen = 'VNC') OR (pArchOrigen = 'TCC')) AND ((cBine NOT IN (SELECT Bin FROM Intercard:"informix".Bines WHERE CreditoDebito = 'C')) OR (cSistema != 'C'))) THEN -- BIN 426807 EN VIC
					LET cCodRet = '00606'; --ERROR DE INTEGRIDAD CON EL NÃMERO DE TARJETA, EL BIN DEL REGISTRO NO COINCIDE
					RETURN cCodRet;
				END IF;

				IF (pTipoTransaccion325 NOT IN ('01','02','20','21')) THEN
					LET cCodRet = '00607'; --EL TIPO DE TRANSACCION ES INCORRECTO, VERIFIQUE
					RETURN cCodRet;
				END IF;
				
				IF LENGTH(TRIM(pIdComercio325)) < 9 THEN
					LET cCodRet = '00608'; --LA CLAVE DE COMERCIO DEBE SER DE 9 POSICIONES, VERIFIQUE
					RETURN cCodRet;
				END IF;
				
				IF ((LENGTH(TRIM(pRfc325)) < 12) OR (LENGTH(TRIM(pRfc325)) > 13)) THEN
					LET cCodRet = '00722'; --LA CLAVE RFC DEBE SER DE 12 Ã 13 POSICIONES
					RETURN cCodRet;
				END IF;
				
			--VALIDACION DE INTEGRIDAD DE REGISTROS, ARCHIVOS E-GLOBAL CAJEROS AUTOMATICOS (BCPL_ATMD Y BCPL_ATMC)	
			ELIF ((pArchOrigen = 'TMD') OR (pArchOrigen = 'TMC')) THEN
				
				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pNumTarjeta) INTO cEsNoNumTarjeta;
				IF cEsNoNumTarjeta = 'F' THEN
					LET cCodRet = '00595'; --NÃMERO DE TARJETA INVALIDO, DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet;
				ELSE
				
					IF LENGTH(pNumTarjeta)!= 16 THEN
						LET cCodRet = '00596'; --EL NÃMERO DE TARJETA DEBE SER DE 16 POSICIONES, VERIFIQUE
						RETURN cCodRet;
					ELSE
						IF pNumTarjeta = '0000000000000000' THEN
							LET cCodRet = '00597'; --EL NÃMERO DE TARJETA NO PUEDE TENER SÃLO CEROS
							RETURN cCodRet;
						END IF;
					END IF;	
				
				END IF;

				-- OBTENIENDO LA CIFRA DEL BIN DE LA TARJETA
				LET cBine = NVL(SUBSTRING(pNumTarjeta FROM 1 FOR 6),'');
				IF ((pArchOrigen = 'TMD') AND ((cBine NOT IN (SELECT Bin FROM Intercard:"informix".Bines WHERE CreditoDebito = 'D')) OR (cSistema != 'D'))) THEN -- BIN 400819 EN VID
					LET cCodRet = '00606'; --ERROR DE INTEGRIDAD CON EL NÃMERO DE TARJETA, EL BIN DEL REGISTRO NO COINCIDE
					RETURN cCodRet;
				END IF;
				IF ((pArchOrigen = 'TMC') AND ((cBine NOT IN (SELECT Bin FROM Intercard:"informix".Bines WHERE CreditoDebito = 'C')) OR (cSistema != 'C'))) THEN -- BIN 426807 EN VIC
					LET cCodRet = '00606'; --ERROR DE INTEGRIDAD CON EL NÃMERO DE TARJETA, EL BIN DEL REGISTRO NO COINCIDE
					RETURN cCodRet;
				END IF;
	
			--VALIDACION DE INTEGRIDAD DE REGISTROS, ARCHIVOS E-GLOBAL PAGOS INTERBANCARIOS (BCPLPNC)
			ELIF ((pArchOrigen = 'PNC')) THEN	

				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pNumTarjeta) INTO cEsNoNumTarjeta;
				IF cEsNoNumTarjeta = 'F' THEN
					LET cCodRet = '00595'; --NÃMERO DE TARJETA INVALIDO, DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet;
				ELSE
				
					IF LENGTH(pNumTarjeta)!= 16 THEN
						LET cCodRet = '00596'; --EL NÃMERO DE TARJETA DEBE SER DE 16 POSICIONES, VERIFIQUE
						RETURN cCodRet;
					ELSE
						IF pNumTarjeta = '0000000000000000' THEN
							LET cCodRet = '00597'; --EL NÃMERO DE TARJETA NO PUEDE TENER SÃLO CEROS
							RETURN cCodRet;
						END IF;
					END IF;	
				
				END IF;
				
				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pMonto325) INTO cEsNoMonto325;
				IF cEsNoMonto325 = 'F' THEN
					LET cCodRet = '00604'; --EL MONTO DE LA TRANSACCIÃN DEBE SER NÃMERICO, VERIFIQUE
					RETURN cCodRet;
				ELSE 
					LET cMonto325 = ((REPLACE(pMonto325,'.',''))::MONEY/100);
					IF (cMonto325 = 0) THEN
						LET cCodRet = '00605'; --EL MONTO DE LA TRANSACCIÃN DEBE SER DIFERENTE DE CERO
						RETURN cCodRet; 
					END IF; 
				END IF;
				
				-- OBTENIENDO LA CIFRA DEL BIN DE LA TARJETA
				LET cBine = NVL(SUBSTRING(pNumTarjeta FROM 1 FOR 6),'');
				IF ((pArchOrigen = 'PNC') AND ((cBine NOT IN (SELECT Bin FROM Intercard:"informix".Bines WHERE CreditoDebito = 'C')) OR (cSistema != 'C'))) THEN -- BIN 426807 EN VIC
					LET cCodRet = '00606'; --ERROR DE INTEGRIDAD CON EL NÃMERO DE TARJETA, EL BIN DEL REGISTRO NO COINCIDE
					RETURN cCodRet;
				END IF;
				
				IF (pTipoTransaccion325 != '20') THEN
					LET cCodRet = '00607'; --EL TIPO DE TRANSACCION ES INCORRECTO, VERIFIQUE
					RETURN cCodRet;
				END IF;
	
			--VALIDACION DE INTEGRIDAD DE REGISTROS, ARCHIVOS COPPEL CORRESPONSALES (BCPLCCD Y BCPLCCP)
			ELIF ((pArchOrigen = 'CCD') OR (pArchOrigen = 'CCP') OR (pArchOrigen = 'TPD')) THEN

				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pNumTarjeta) INTO cEsNoNumTarjeta;
				IF cEsNoNumTarjeta = 'F' THEN
					LET cCodRet = '00595'; --NÃMERO DE TARJETA INVALIDO, DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet;
				ELSE
				
					IF LENGTH(pNumTarjeta)!= 16 THEN
						LET cCodRet = '00596'; --EL NÃMERO DE TARJETA DEBE SER DE 16 POSICIONES, VERIFIQUE
						RETURN cCodRet;
					ELSE
						IF pNumTarjeta = '0000000000000000' THEN
							LET cCodRet = '00597'; --EL NÃMERO DE TARJETA NO PUEDE TENER SÃLO CEROS
							RETURN cCodRet;
						END IF;
					END IF;	
				
				END IF;
				
				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pMonto325) INTO cEsNoMonto325;
				IF cEsNoMonto325 = 'F' THEN
					LET cCodRet = '00604'; --EL MONTO DE LA TRANSACCIÃN DEBE SER NÃMERICO, VERIFIQUE
					RETURN cCodRet;
				ELSE 
					LET cMonto325 = ((REPLACE(pMonto325,'.',''))::MONEY/100);
					IF (cMonto325 = 0) THEN
						LET cCodRet = '00605'; --EL MONTO DE LA TRANSACCIÃN DEBE SER DIFERENTE DE CERO
						RETURN cCodRet; 
					END IF; 
				END IF;
				
			--VALIDACION DE INTEGRIDAD DE REGISTROS; ARCHIVOS PROSA (BCPL_ATMOL Y BCPL_ATMPL)
			ELIF ((pArchOrigen = 'TMO') OR (pArchOrigen = 'TMP')) THEN
	
				EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_esnumerico(pNumTarjeta) INTO cEsNoNumTarjeta;
				IF cEsNoNumTarjeta = 'F' THEN
					LET cCodRet = '00595'; --NÃMERO DE TARJETA INVALIDO, DEBE CONTENER SÃLO NÃMEROS
					RETURN cCodRet;
				ELSE
				
					IF LENGTH(pNumTarjeta)!= 16 THEN
						LET cCodRet = '00596'; --EL NÃMERO DE TARJETA DEBE SER DE 16 POSICIONES, VERIFIQUE
						RETURN cCodRet;
					ELSE
						IF pNumTarjeta = '0000000000000000' THEN
							LET cCodRet = '00597'; --EL NÃMERO DE TARJETA NO PUEDE TENER SÃLO CEROS
							RETURN cCodRet;
						END IF;
					END IF;	
				
				END IF;				
				
			ELSE
				LET cCodRet = '00594'; --EL NOMBRE DEL ARCHIVO ORIGEN NO CORRESPONDE A LA NOMENCLATURA ESTABLECIDA, VERIFIQUE
				RETURN cCodRet;
			END IF;
			
			
			EXECUTE PROCEDURE bditarjeta:'informix'.sp_concreing_compvalidaintegridad (pUsuario, pArchOrigen, pIntegridad, 
			pConsecutivo, pNumTarjeta, pTipoTransaccion325, pMonto325, pIdComercio325, pNomComercio325, pReferencia23_325, 
			pSecuencia325, pDivisa325, pRfc325)				
			INTO cCodRetSp, cIntegridad, cErrorActividad, cIntegridadError;
		
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditarjeta:sp_concreing_compvalidaintegridad';
			END IF;
		
			IF cCodRetSp::INTEGER = 0 AND cIntegridad = 'V' THEN
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet;
			END IF;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00283';
				RETURN cCodRet;
			END IF;
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 10/08/2015',
'MODULO: CONCILIACIONES',
'FUNCIONALIDAD: Consulta de Movimientos Pendientes de Aplicar', 
'DESCRIPCION: SPL que se encarga de actualizar el registro con error de integridad.',
'Complementa la integridad de los campos necesarios para la conciliacion',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 23/11/2015',
'DESCRIPCION: Se aplicÃ³ el cambio a la validaciÃ³n del cMontoCB325 y a las posiciones del rfc, ya que anteriormente solo validaba que el RFC fuera a 13 posiciones.',
'BD: bdicnweb',
'AUTOR: Ing. Guadalupe A. Hernandez Perez',
'FECHA: 02/02/2016',
'DESCRIPCION: Se agrega la validaciÃ³n para ver si el numero de secuencia sea diferente a 000000.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogoarchivotef(pUsuario CHAR(8), pIdFuncion CHAR(10), pRuta CHAR(100), pRegistros INTEGER, pRecuperacion INTEGER)
                RETURNING CHAR(5) AS codret,
                        CHAR(50) AS nom_archivo;
                        
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE cNomArchivo CHAR(50);
	DEFINE iNoRegistros INTEGER;
	DEFINE bInTrans BOOLEAN;
	DEFINE cFechaArchivoOUT CHAR(10);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cNomArchivo = '';
	LET iNoRegistros = 0;
	LET bInTrans = 'f';
	LET cFechaArchivoOUT = YEAR(CURRENT::DATE)||LPAD(MONTH(CURRENT::DATE),2,'0')||LPAD(DAY(CURRENT::DATE),2,'0')||'_';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNomArchivo;
		END EXCEPTION;

		ON EXCEPTION IN (-535)
			COMMIT WORK;
			LET bInTrans = 't';
		END EXCEPTION WITH RESUME;

		-- SET DEBUG FILE TO '/tmp/mfinis/sp_catalogoarchivotef.out';
		-- TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pRuta = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNomArchivo;
		END IF;

		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNomArchivo;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNomArchivo;
		END IF;

		BEGIN WORK;
		IF NOT bInTrans THEN
			COMMIT WORK;
		END IF;

		-- Se elimina el archivo out
		-- SYSTEM "[ -f "||TRIM(pRuta)||TRIM(cFechaArchivoOUT)||"buscar.bus"||" ] && rm -rf "||TRIM(pRuta)||TRIM(cFechaArchivoOUT)||"buscar.bus";

		SET ISOLATION TO DIRTY READ;
		IF pRegistros = 0 THEN

			FOREACH EXECUTE PROCEDURE bditef:'informix'.sp_buscararchivos_tef(pRuta)
					INTO cCodRetSp, cNomArchivo

				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃ?N DEL SP bditef:sp_buscararchivos_tef';
				ELIF cCodRetSp::INTEGER = 1     THEN
					IF bInTrans THEN
						BEGIN WORK;
					END IF;

					LET cCodRet = '00003';
					RETURN cCodRet, cNomArchivo;
				END IF;

				LET iNoRegistros = iNoRegistros + 1;
				IF iNoRegistros <= pRecuperacion THEN
					RETURN cCodRet, UPPER(cNomArchivo) WITH RESUME;
				END IF;

			END FOREACH;

		ELSE 

			SET ISOLATION TO DIRTY READ;
			FOREACH SELECT SKIP pRegistros FIRST pRecuperacion linea
					INTO cNomArchivo
					FROM bditef:"informix".tef_busca_archivos

				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, UPPER(cNomArchivo) WITH RESUME;

			END FOREACH;

		END IF;

		IF bInTrans THEN
			BEGIN WORK;
		END IF;

		IF iNoRegistros = 0 THEN
			IF pRegistros = 0 THEN
				LET cCodRet = '00560';
			ELSE
				LET cCodRet = '1001';
			END IF;

			RETURN cCodRet, cNomArchivo;
		END IF;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 07/07/2015',
'DESCRIPCION: SPL que realiza la consulta de archivos a tratar de acuerdo a la ruta proporcionada.',
'FUNCIONALIDAD: EnvÃ­o/RecepciÃ³n Archivos Bancoppel - Cecoban', 
'MODULO: TEF',
'BD: bditef';

CREATE PROCEDURE "informix".sp_con_consultactesfusionados_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechIni DATE, pFechFin DATE)
			RETURNING CHAR(5) AS codret,
					INTEGER AS num_registros;
					
		DEFINE cCodRet CHAR(5);
		DEFINE iSqlErr INTEGER;
		DEFINE cCodRetSp CHAR(5);
		DEFINE iCodRetSp INTEGER;
		DEFINE iNoRegistros INTEGER;
	
		LET cCodRet = '00000';
		LET iSqlErr = 0;
		LET cCodRetSp = '';
		LET iCodRetSp = 0;
		LET iNoRegistros = 0;	
	
		BEGIN	
				ON EXCEPTION SET iSqlErr
						LET cCodRet = iSqlErr;
						RETURN cCodRet, iNoRegistros;
				END EXCEPTION;
			
				--SET DEBUG FILE TO '/tmp/mfinis/sp_con_consultactesfusionados_totales.out';
				--TRACE ON;
		
				IF pUsuario = '' OR pIdFuncion = '' OR  pFechIni IS NULL OR pFechFin IS NULL THEN
						LET cCodRet = '00003';
						RETURN cCodRet, iNoRegistros;
				END IF;
		
				-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
				EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
				IF cCodRet <> '00000' THEN
						RETURN cCodRet, iNoRegistros;
				END IF;
				
				SET ISOLATION TO DIRTY READ;
				
						EXECUTE PROCEDURE bdinteg:"informix".sp_ctes_fusionados2_totales(pFechIni, pFechFin)
						INTO cCodRetSp, iNoRegistros;
		
						LET iCodRetSp = cCodRetSp::INTEGER;
						IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_ctes_fusionados2_totales';		
						END IF;
			
				IF iNoRegistros = 0 THEN
						LET cCodRet = '00017';				
				END IF;			
					RETURN cCodRet, iNoRegistros;		
		END;	
END PROCEDURE
DOCUMENT 'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 12/11/2015',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: Reporte Procesos Sucursal',
'DESCRIPCION: SPL que consulta total de clientes fusionados',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_con_consultaverificasms(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechIni DATE, pFechFin DATE , pRegistros INTEGER, pRecuperacion INTEGER)
			RETURNING CHAR(5) AS codret,
			CHAR(10) AS Fecha,
			INTEGER AS Validos,
			INTEGER AS No_Validos,
			INTEGER AS Total,
			INTEGER AS total_validos,
			INTEGER AS total_novalidos,
			INTEGER AS resultado_total;	
		
		DEFINE cCodRet CHAR(5);
		DEFINE iSqlErr INTEGER;
		DEFINE cCodRetSp CHAR(5);
		DEFINE iCodRetSp INTEGER;
		DEFINE cFecha CHAR(10);
		DEFINE iValidos INTEGER;
		DEFINE iNoValidos INTEGER;
		DEFINE iTotal INTEGER;
		DEFINE iTotalValidos INTEGER;
		DEFINE iTotalNoValidos INTEGER;
		DEFINE iResultadoTotal INTEGER;
		DEFINE iNoRegistros INTEGER;
	
		LET cCodRet = '00000';
		LET iSqlErr = 0;
		LET cCodRetSp = '';
		LET iCodRetSp = 0;
		LET cFecha = '';
		LET iValidos = 0;
		LET iNoValidos = 0;
		LET iTotal = 0;
		LET iTotalValidos = 0;
		LET iTotalNoValidos = 0;
		LET iResultadoTotal = 0;
		LET iNoRegistros = 0;	
	
		BEGIN	
				ON EXCEPTION SET iSqlErr
						LET cCodRet = iSqlErr;
						RETURN cCodRet, cFecha, iValidos, iNoValidos, iTotal, iTotalValidos, iTotalNoValidos, iResultadoTotal;
				END EXCEPTION;
			
				--SET DEBUG FILE TO '/tmp/mfinis/sp_con_consultaverificasms.out';
				--TRACE ON;
		
				IF pUsuario = '' OR pIdFuncion = '' OR  pFechIni IS NULL OR pFechFin IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
						LET cCodRet = '00003';
						RETURN cCodRet, cFecha, iValidos, iNoValidos, iTotal, iTotalValidos, iTotalNoValidos, iResultadoTotal;
				END IF;
				
				-- VALIDACION DE LA PAGINACION
				IF pRegistros < 0 OR pRecuperacion < 0 THEN
						LET cCodRet = '00098';
						RETURN cCodRet, cFecha, iValidos, iNoValidos, iTotal, iTotalValidos, iTotalNoValidos, iResultadoTotal;
				END IF;
		
				-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
				EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
				IF cCodRet <> '00000' THEN
						RETURN cCodRet, cFecha, iValidos, iNoValidos, iTotal, iTotalValidos, iTotalNoValidos, iResultadoTotal;
				END IF;
				-- OBTIENE SUMA TOTALES
				FOREACH
						EXECUTE PROCEDURE bdinteg:"informix".sp_verifica_sms(pFechIni, pFechFin)
						INTO cCodRetSp, cFecha, iValidos, iNoValidos, iTotal
						
						LET iCodRetSp = cCodRetSp::INTEGER;
						IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_verifica_sms';		
						END IF;
			
						LET iTotalValidos = iTotalValidos + iValidos;
						LET iTotalNoValidos = iTotalNoValidos + iNoValidos;
						LET iResultadoTotal = iResultadoTotal + iTotal;	
				END FOREACH
				--OBTIENE DETALLES DE LA CONSULTA
				FOREACH
						EXECUTE PROCEDURE bdinteg:"informix".sp_verifica_sms2(pFechIni, pFechFin, pRegistros, pRecuperacion)
						INTO cCodRetSp, cFecha, iValidos, iNoValidos, iTotal
						
						LET iCodRetSp = cCodRetSp::INTEGER;
						IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_verifica_sms2';		
						END IF;									
		
						LET iNoRegistros = iNoRegistros + 1;
		
						RETURN cCodRet, cFecha, iValidos, iNoValidos, iTotal, iTotalValidos, iTotalNoValidos, iResultadoTotal WITH RESUME;
		
				END FOREACH
		
				IF iNoRegistros = 0 AND pRegistros = 0 THEN			
						LET cCodRet = '00017';
						RETURN cCodRet, cFecha, iValidos, iNoValidos, iTotal, iTotalValidos, iTotalNoValidos, iResultadoTotal;
				ELIF iNoRegistros = 0 AND pRegistros > 0 THEN 
						LET cCodRet = '1001';		
						RETURN cCodRet, cFecha, iValidos, iNoValidos, iTotal, iTotalValidos, iTotalNoValidos, iResultadoTotal;
				END IF;	
		END;	
END PROCEDURE
DOCUMENT 'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 12/11/2015',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: Reporte Procesos Sucursal',
'DESCRIPCION: SPL que consulta la verificaciÃ³n de sms del Reporte Procesos Sucursal',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_actualizacedulas( pFechaConcil DATE, pCtaContable CHAR(14), pObservaciones CHAR(255) )
RETURNING CHAR(5);
    
    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE iExiste      SMALLINT;
    
    LET cCodRet1     = '000';
    LET cCodRet2     = '';
    LET cCodRet3     = '';
    LET iSqlErr	     = 0;
    LET iSamErr      = 0;
    LET cDesErr      = '';
    LET iExiste      = 0;
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_actualizacedulas.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_actualizacedulas.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( ( pFechaConcil is null OR pFechaConcil = '' ) OR
         ( pCtaContable is null OR pCtaContable = '' ) ) THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1;
    END IF;
    
    SELECT COUNT(*) 
      INTO iExiste
      FROM bdicheq:sc_cedulacontable
     WHERE fecha_concil = pFechaConcil
       AND cta_contable = pCtaContable
       AND editable = '0';
       
    IF iExiste > 0 THEN
        UPDATE bdicheq:sc_cedulacontable
           SET observaciones = pObservaciones
         WHERE fecha_concil = pFechaConcil
           AND cta_contable = pCtaContable;
    ELSE
        LET cCodRet1 = '100';
        RETURN cCodRet1;
    END IF;
    
    RETURN cCodRet1;
     
    END;
    
END PROCEDURE;
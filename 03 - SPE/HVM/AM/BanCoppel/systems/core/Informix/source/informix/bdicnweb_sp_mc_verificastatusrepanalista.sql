CREATE PROCEDURE "informix".sp_mc_verificastatusrepanalista(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		INTEGER AS num_registros,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iNumRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_verificastatusrepanalista.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;
		END IF;
		
		
	
		SELECT status,num_registros,error_proceso,error
		INTO cStatus,iNumRegistros,cErrorProceso,cError
		FROM "informix".status_rep_analista WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 27/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUD',
'DESCRIPCION: SPL encargado verificar el status del reporte analista.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_verificastatusrepcompingreso(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		INTEGER AS num_registros,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iNumRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_verificastatusrepcompingreso.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;
		END IF;
		
		
	
		SELECT status,num_registros,error_proceso,error
		INTO cStatus,iNumRegistros,cErrorProceso,cError
		FROM "informix".status_rep_compingreso WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 27/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUD',
'DESCRIPCION: SPL encargado verificar el status del reporte comprobante de ingresos.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_verificastatusrepdetallado(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		INTEGER AS num_registros,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iNumRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_verificastatusrepdetallado.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;
		END IF;
		
		
	
		SELECT status,num_registros,error_proceso,error
		INTO cStatus,iNumRegistros,cErrorProceso,cError
		FROM "informix".status_rep_detallado WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 27/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUD',
'DESCRIPCION: SPL encargado verificar el status del reporte detallado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_verificastatusrepgeneral(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		INTEGER AS num_registros,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iNumRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_verificastatusrepgeneral.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;
		END IF;
		
		
	
		SELECT status,num_registros,error_proceso,error
		INTO cStatus,iNumRegistros,cErrorProceso,cError
		FROM "informix".status_rep_general WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 27/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUD',
'DESCRIPCION: SPL encargado verificar el status del reporte general.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_verificastatusreplincred(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		INTEGER AS num_registros,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iNumRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END EXCEPTION;
	 
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_verificastatusreplincred.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;
		END IF;
		
		
	
		SELECT status,num_registros,error_proceso,error
		INTO cStatus,iNumRegistros,cErrorProceso,cError
		FROM "informix".status_rep_lincred WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 27/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUD',
'DESCRIPCION: SPL encargado verificar el status del reporte linea de credito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_sw_combostatusmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
		CHAR(2) AS id,
		CHAR(50) AS descripcion;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(5);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;
	DEFINE cDescripcion CHAR(50);
	DEFINE cId CHAR(2);
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;
	LET cDescripcion = '';
    LET cId = '';

	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cId, cDescripcion;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_sw_combostatusmc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cId, cDescripcion;
		END IF;
		
		-- VALIDACIÓN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cId, cDescripcion;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cId, cDescripcion;
		END IF;
		
		
		
		FOREACH cusor1 WITH HOLD FOR
 
       			SELECT SKIP pRegistros FIRST pRecuperacion id, descripcion 
				INTO   cId, cDescripcion 
			    FROM   bdicnweb:"informix".sw_mc_combostatus
				WHERE id in ('AT','EE','CM','RT')
				
				LET iRecuperacion = iRecuperacion + 1;
                   
	            RETURN 
	 		 		TRIM(NVL(cCodRet, '')), 
					TRIM(UPPER(NVL(cId, ''))), 
			        TRIM(UPPER(NVL(cDescripcion, '')))
	            WITH RESUME;
              
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '01086';
			RETURN cCodRet, cId, cDescripcion;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cId, cDescripcion;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sánchez',
'FECHA: 28/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTES MESA CONTROL',
'Descripcion: SPL encargado de consultar los registros para el llenado del combo de status Solicitud.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_sw_gralsino(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
		SMALLINT AS id,
		CHAR(50) AS descripcion;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(5);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;
	DEFINE cDescripcion CHAR(50);
	DEFINE sId SMALLINT;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;
	LET cDescripcion = '';
    LET sId = 0;

	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, sId, cDescripcion;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_sw_gralsino.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, sId, cDescripcion;
		END IF;
		
		-- VALIDACIÓN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, sId, cDescripcion;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, sId, cDescripcion;
		END IF;
		
		
		
		FOREACH cusor1 WITH HOLD FOR
 
       			SELECT SKIP pRegistros FIRST pRecuperacion id, descripcion 
				INTO   sId, cDescripcion 
			    FROM   bdicnweb:"informix".sw_gral_sino
				WHERE id in(1,2)
				
				LET iRecuperacion = iRecuperacion + 1;
                   
	            RETURN 
	 		 		TRIM(NVL(cCodRet, '')), 
					NVL(sId, 0),
			        TRIM(UPPER(NVL(cDescripcion, '')))
	            WITH RESUME;
              
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '01086';
			RETURN cCodRet, sId, cDescripcion;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, sId, cDescripcion;
		END IF;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sánchez',
'FECHA: 28/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: DATOS DE LA SOLICITUD',
'Descripcion: SPL encargado de consultar los registros para el llenado del combo de comprobante de ingresos.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificastatusrepdetsolicitudmc(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		INTEGER AS num_registros,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iNumRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_verificastatusrepdetsolicitudmc.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;
		END IF;
		
	
		SELECT status,num_registros,error_proceso,error
		INTO cStatus,iNumRegistros,cErrorProceso,cError
		FROM "informix".status_repsolicitudmc WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 07/09/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUD',
'DESCRIPCION: SPL encargado verificar el status del reporte solicitud mc.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_generarreportes_tef_mx(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(20), pTipoArchivo CHAR(4), pFechaInicial DATE, pFechaFinal DATE, pTipoReporte SMALLINT, pRegistros INTEGER, pRecuperacion INTEGER)
                RETURNING CHAR(5) AS codret,
                                CHAR(10) AS fecha_presentacion,
                                CHAR(20) AS nombre_arch,
                                CHAR(2) AS cod_operacion,
                                CHAR(4) AS no_sucursal,
                                CHAR(40) AS nombre_ord,
                                CHAR(20)AS num_cta_ord,
                                CHAR(50) AS tipo_operacion,
                                CHAR(7) AS ref_numerica,
                                DECIMAL(11,2) AS importe,
                                CHAR(40) AS nombre_rec,
                                CHAR(20) AS num_cta_rec,
                                CHAR(7) AS num_secuencia,
                                CHAR(40) AS tipo_cta_destino,
                                CHAR(40) AS bancodestino,
                                CHAR(20) AS status,
                                DECIMAL(18,2) AS imp_operaciones,
                                CHAR(8) AS fecha_presentacion2,
                                CHAR(2) AS motivo_dev,
                                CHAR(50) AS descripcion,
                                INTEGER AS registrosCod61,
                                DECIMAL(18,2) AS totalImporteCod61,
                                INTEGER AS registrosCod62,
                                DECIMAL(18,2) AS totalImporteCod62;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(5);
        DEFINE iCodRetSp INTEGER;
        DEFINE cFechaInicio CHAR(8);
        DEFINE cFechaFin CHAR(8);
        DEFINE iNoRegistros INTEGER;
        DEFINE cFechaPresentacion CHAR(10);
        DEFINE cNombreArch CHAR(20);
        DEFINE cCodOperacion CHAR(2);
        DEFINE cNoSucursal CHAR(4);
        DEFINE cNombreOrd CHAR(40);
        DEFINE cNumCtaOrd CHAR(20);
        DEFINE cTipoOperacion CHAR(50);
        DEFINE cRefNumerica CHAR(7);
        DEFINE dImporte DECIMAL(11,2);
        DEFINE cNombreRec CHAR(40);
        DEFINE cNumCtaRec CHAR(20);
        DEFINE cNumSecuencia CHAR(7);
        DEFINE cTipoCtaDestino CHAR(40);
        DEFINE cBancoDestino CHAR(40);
        DEFINE cStatus CHAR(20);
        DEFINE dImpOperaciones DECIMAL(18,2);
        DEFINE cFechaPresentacion2 CHAR(8);
        DEFINE cMotivoDev CHAR(2);
        DEFINE cDescripcion CHAR(50);
        DEFINE iRegistrosCod61 INTEGER;
        DEFINE dTotalImporteCod61 DECIMAL(18,2);
        DEFINE iRegistrosCod62 INTEGER;
        DEFINE dTotalImporteCod62 DECIMAL(18,2);

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET cFechaInicio = '';
        LET cFechaFin = '';
        LET iNoRegistros = 0;
        LET cFechaPresentacion = '';
        LET cNombreArch = '';
        LET cCodOperacion = '';
        LET cNoSucursal = '';
        LET cNombreOrd = '';
        LET cNumCtaOrd = '';
        LET cTipoOperacion = '';
        LET cRefNumerica = '';
        LET dImporte = NULL;
        LET cNombreRec = '';
        LET cNumCtaRec = '';
        LET cNumSecuencia = '';
        LET cTipoCtaDestino = '';
        LET cBancoDestino = '';
        LET cStatus = '';
        LET dImpOperaciones = NULL;
        LET cFechaPresentacion2 = '';
        LET cMotivoDev = '';
        LET cDescripcion = '';
        LET iRegistrosCod61 = 0;
        LET dTotalImporteCod61 = NULL;
        LET iRegistrosCod62 = 0;
        LET dTotalImporteCod62 = NULL;

        BEGIN

                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62;
                END EXCEPTION;

                 --SET DEBUG FILE TO '/tmp/ALAN/sp_generarreportes_tef.out';
                 --TRACE ON;

                IF pUsuario = '' OR pIdFuncion = '' OR pTipoArchivo = '' OR pTipoReporte IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62;
                END IF;

                IF LENGTH(pNombreArchivo) > 15 THEN
                        LET pFechaInicial = NULL;
                        LET pFechaFinal = NULL;
                ElIF LENGTH(pTipoArchivo) = 2 THEN
                        IF pFechaInicial IS NULL OR pFechaFinal IS NULL THEN
                                LET cCodRet = '00003';
                                RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                        cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                        cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                        dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62;
                        END IF;

                        LET pNombreArchivo = '';
                        LET cFechaInicio = YEAR(DATE(pFechaInicial))||LPAD(MONTH(DATE(pFechaInicial)), 2, '0')||LPAD(DAY(DATE(pFechaInicial)), 2, '0');
                        LET cFechaFin = YEAR(DATE(pFechaFinal))||LPAD(MONTH(DATE(pFechaFinal)), 2, '0')||LPAD(DAY(DATE(pFechaFinal)), 2, '0');
                END IF;

                -- VALIDACION DE LA PAGINACION
                IF pRegistros < 0 OR pRecuperacion < 0 THEN
                        LET cCodRet = '00098';
                        RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62;
                END IF;

                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62;
                END IF;

                FOREACH EXECUTE PROCEDURE bditef:"informix".sp_reportearchivos_tef2(pNombreArchivo, pTipoArchivo, cFechaInicio, cFechaFin, pTipoReporte, pRegistros, pRecuperacion)
                        INTO cCodRetSp, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62

                        LET iCodRetSp = cCodRetSp::INTEGER;
                        IF iCodRetSp < 0 THEN
                                RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:"informix".sp_reportearchivos_tef2';
                        ELIF iCodRetSp = 1 THEN
                                LET cCodRet = '00003';
                        END IF;

                        LET iNoRegistros = iNoRegistros + 1;
                        RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62 WITH RESUME;

                END FOREACH;

                IF iNoRegistros = 0 AND pRegistros = 0 THEN
                        LET cCodRet = '00017';
                        RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62;
                ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
                        LET cCodRet = '1001';
                        RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62;
                END IF;

        END;

END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 05/08/2015',
'MODULO: TEF',
'FUNCIONALIDAD: Reportes de archivos tef',
'DESCRIPCION: Consulta de la informaciÃÂ³n para el llenado de los reportes de TEF',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_generarreportes_tef(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(20), pTipoArchivo CHAR(4), pFechaInicial DATE, pFechaFinal DATE, pTipoReporte SMALLINT, pRegistros INTEGER, pRecuperacion INTEGER)
                RETURNING CHAR(5) AS codret,
                                CHAR(10) AS fecha_presentacion,
                                CHAR(20) AS nombre_arch,
                                CHAR(2) AS cod_operacion,
                                CHAR(4) AS no_sucursal,
                                CHAR(40) AS nombre_ord,
                                CHAR(20)AS num_cta_ord,
                                CHAR(50) AS tipo_operacion,
                                CHAR(7) AS ref_numerica,
                                DECIMAL(11,2) AS importe,
                                CHAR(40) AS nombre_rec,
                                CHAR(20) AS num_cta_rec,
                                CHAR(7) AS num_secuencia,
                                CHAR(40) AS tipo_cta_destino,
                                CHAR(40) AS bancodestino,
                                CHAR(20) AS status,
                                DECIMAL(18,2) AS imp_operaciones,
                                CHAR(8) AS fecha_presentacion2,
                                CHAR(2) AS motivo_dev,
                                CHAR(50) AS descripcion,
                                INTEGER AS registrosCod61,
                                DECIMAL(18,2) AS totalImporteCod61,
                                INTEGER AS registrosCod62,
                                DECIMAL(18,2) AS totalImporteCod62;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(5);
        DEFINE iCodRetSp INTEGER;
        DEFINE cFechaInicio CHAR(8);
        DEFINE cFechaFin CHAR(8);
        DEFINE iNoRegistros INTEGER;
        DEFINE cFechaPresentacion CHAR(10);
        DEFINE cNombreArch CHAR(20);
        DEFINE cCodOperacion CHAR(2);
        DEFINE cNoSucursal CHAR(4);
        DEFINE cNombreOrd CHAR(40);
        DEFINE cNumCtaOrd CHAR(20);
        DEFINE cTipoOperacion CHAR(50);
        DEFINE cRefNumerica CHAR(7);
        DEFINE dImporte DECIMAL(11,2);
        DEFINE cNombreRec CHAR(40);
        DEFINE cNumCtaRec CHAR(20);
        DEFINE cNumSecuencia CHAR(7);
        DEFINE cTipoCtaDestino CHAR(40);
        DEFINE cBancoDestino CHAR(40);
        DEFINE cStatus CHAR(20);
        DEFINE dImpOperaciones DECIMAL(18,2);
        DEFINE cFechaPresentacion2 CHAR(8);
        DEFINE cMotivoDev CHAR(2);
        DEFINE cDescripcion CHAR(50);
        DEFINE iRegistrosCod61 INTEGER;
        DEFINE dTotalImporteCod61 DECIMAL(18,2);
        DEFINE iRegistrosCod62 INTEGER;
        DEFINE dTotalImporteCod62 DECIMAL(18,2);

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET cFechaInicio = '';
        LET cFechaFin = '';
        LET iNoRegistros = 0;
        LET cFechaPresentacion = '';
        LET cNombreArch = '';
        LET cCodOperacion = '';
        LET cNoSucursal = '';
        LET cNombreOrd = '';
        LET cNumCtaOrd = '';
        LET cTipoOperacion = '';
        LET cRefNumerica = '';
        LET dImporte = NULL;
        LET cNombreRec = '';
        LET cNumCtaRec = '';
        LET cNumSecuencia = '';
        LET cTipoCtaDestino = '';
        LET cBancoDestino = '';
        LET cStatus = '';
        LET dImpOperaciones = NULL;
        LET cFechaPresentacion2 = '';
        LET cMotivoDev = '';
        LET cDescripcion = '';
        LET iRegistrosCod61 = 0;
        LET dTotalImporteCod61 = NULL;
        LET iRegistrosCod62 = 0;
        LET dTotalImporteCod62 = NULL;

        BEGIN

                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62;
                END EXCEPTION;
				
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;

                 --SET DEBUG FILE TO '/tmp/ALAN/sp_generarreportes_tef.out';
                 --TRACE ON;

                IF pUsuario = '' OR pIdFuncion = '' OR pTipoArchivo = '' OR pTipoReporte IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62;
                END IF;

                IF LENGTH(pNombreArchivo) > 15 THEN
                        LET pFechaInicial = NULL;
                        LET pFechaFinal = NULL;
                ElIF LENGTH(pTipoArchivo) = 2 THEN
                        IF pFechaInicial IS NULL OR pFechaFinal IS NULL THEN
                                LET cCodRet = '00003';
                                RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                        cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                        cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                        dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62;
                        END IF;

                        LET pNombreArchivo = '';
                        LET cFechaInicio = YEAR(DATE(pFechaInicial))||LPAD(MONTH(DATE(pFechaInicial)), 2, '0')||LPAD(DAY(DATE(pFechaInicial)), 2, '0');
                        LET cFechaFin = YEAR(DATE(pFechaFinal))||LPAD(MONTH(DATE(pFechaFinal)), 2, '0')||LPAD(DAY(DATE(pFechaFinal)), 2, '0');
                END IF;

                -- VALIDACION DE LA PAGINACION
                IF pRegistros < 0 OR pRecuperacion < 0 THEN
                        LET cCodRet = '00098';
                        RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62;
                END IF;

                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62;
                END IF;

                FOREACH EXECUTE PROCEDURE bditef:"informix".sp_reportearchivos_tef2(pNombreArchivo, pTipoArchivo, cFechaInicio, cFechaFin, pTipoReporte, pRegistros, pRecuperacion)
                        INTO cCodRetSp, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62

                        LET iCodRetSp = cCodRetSp::INTEGER;
                        IF iCodRetSp < 0 THEN
                                RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:"informix".sp_reportearchivos_tef2';
                        ELIF iCodRetSp = 1 THEN
                                LET cCodRet = '00003';
                        END IF;

                        LET iNoRegistros = iNoRegistros + 1;
                        RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62 WITH RESUME;

                END FOREACH;

                IF iNoRegistros = 0 AND pRegistros = 0 THEN
                        LET cCodRet = '00017';
                        RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62;
                ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
                        LET cCodRet = '1001';
                        RETURN cCodRet, cFechaPresentacion, cNombreArch, cCodOperacion, cNoSucursal, cNombreOrd, cNumCtaOrd,
                                cTipoOperacion, cRefNumerica, dImporte, cNombreRec, cNumCtaRec, cNumSecuencia, cTipoCtaDestino,
                                cBancoDestino, cStatus, dImpOperaciones, cFechaPresentacion2, cMotivoDev, cDescripcion, iRegistrosCod61,
                                dTotalImporteCod61, iRegistrosCod62, dTotalImporteCod62;
                END IF;

        END;

END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 05/08/2015',
'MODULO: TEF',
'FUNCIONALIDAD: Reportes de archivos tef',
'DESCRIPCION: Consulta de la informaciÃÂ³n para el llenado de los reportes de TEF',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultacatalogocausastatusmc(pStatus CHAR(2), pRegistros INTEGER, pRecuperacion INTEGER)
        RETURNING CHAR(5) AS codret,
                        CHAR(2) AS status,
                        CHAR(40) AS descripcion_status,
                        CHAR(3) AS causa,
                        CHAR(100) AS descripcion_causa,
						CHAR(100) AS justificacion;
        
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(5);
        DEFINE cStatus CHAR(2);
        DEFINE cDescripcionStatus CHAR(40);
        DEFINE cCausa CHAR(3);
        DEFINE cDescripcionCausa CHAR(100);
		DEFINE cJustificacion CHAR(100);
		DEFINE iNoRegitros INTEGER;
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET cStatus = '';
        LET cDescripcionStatus = '';
        LET cCausa = '';
        LET cDescripcionCausa = '';
		LET cJustificacion = '';
		LET iNoRegitros = 0;
        
        BEGIN
                
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cStatus, cDescripcionStatus, cCausa, cDescripcionCausa, cJustificacion;
                END EXCEPTION;
                
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
                -- SET DEBUG FILE TO '/tmp/mfinis/sp_consultacatalogocausastatusmc.out';
                -- TRACE ON;
				
				--SET LOCK MODE TO WAIT 3;
				
				IF pRegistros IS NULL OR pRecuperacion IS NULL THEN
					LET cCodRet = '00003';
					RETURN cCodRet, cStatus, cDescripcionStatus, cCausa, cDescripcionCausa, cJustificacion;
				END IF;
		
				-- VALIDACION DE LA PAGINACION
				IF pRegistros < 0 OR pRecuperacion < 0 THEN
					LET cCodRet = '00098';
					RETURN cCodRet, cStatus, cDescripcionStatus, cCausa, cDescripcionCausa, cJustificacion;
				END IF;
				
				SET ISOLATION TO DIRTY READ;
				FOREACH SELECT SKIP pRegistros FIRST pRecuperacion codret, status, descripcion_status, causa, descripcion_causa, justificacion
						INTO cCodRetSp, cStatus, cDescripcionStatus, cCausa, cDescripcionCausa, cJustificacion
						FROM TABLE(PROCEDURE bdicred:'informix'.sp_consultarcausastatussoc(pStatus))
							AS consultarcausastatus_tmp(codret, status, descripcion_status, causa, descripcion_causa, justificacion)
					IF cCodRetSp::SMALLINT = 1 THEN
						LET cCodRet = '00017';
						RETURN cCodRet, cStatus, cDescripcionStatus, cCausa, cDescripcionCausa, cJustificacion;
					ELSE
						RETURN cCodRet, cStatus, cDescripcionStatus, cCausa, cDescripcionCausa, cJustificacion WITH RESUME;
						LET iNoRegitros = iNoRegitros + 1;
					END IF;
				END FOREACH;
				
				IF iNoRegitros = 0 THEN
					IF pRegistros = 0 THEN
						LET cCodRet = '00017';
					ELIF pRegistros > 0 THEN
						LET cCodRet = '1001';
					END IF;
					
					RETURN cCodRet, cStatus, cDescripcionStatus, cCausa, cDescripcionCausa, cJustificacion;
				END IF;
				
        END;
        
END PROCEDURE
DOCUMENT 
"AUTOR: Johnattan Esquivel Sánchez",
"FECHA: 01/08/2018",
"DESCRIPCION: Se aplica mantto MC",
"BD: bdicnweb";

CREATE PROCEDURE "informix".sp_ope_catsucaralreporte(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING 	CHAR(5) AS codret,
				CHAR(4) AS sucursal,
				CHAR(40) AS nombre,
				CHAR(3) AS plaza,
				CHAR(3) AS pais,
				CHAR(2) AS estado;

	DEFINE cCodRet 			CHAR(5);
	DEFINE iSqlErr 			INTEGER;
	DEFINE cSucursal 		CHAR(40);
	DEFINE cNombre 			CHAR(40);
	DEFINE cPlaza 			CHAR(3);
	DEFINE cPais 			CHAR(3);
	DEFINE cEstado 			CHAR(2);
	DEFINE iNoRegistros 	INTEGER;
	DEFINE iRegistros 		INTEGER;
	DEFINE iRecuperacion 	INTEGER;

	LET cCodRet 			= '00000';
	LET iSqlErr 			= 0;
	LET cSucursal 			= '';
	LET cNombre 			= '';
	LET cPlaza 				= '';
	LET cPais 				= '';
	LET cEstado 			= '';
	LET iNoRegistros 		= 0;
	LET iRegistros 			= 0;
	LET iRecuperacion 		= 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cSucursal, cNombre, cPlaza, cPais, cEstado;
		END EXCEPTION;

		--SET DEBUG FILE TO '/informix/yoselin/bdicnweb/sp_ope_catsucaralreporte.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cSucursal, cNombre, cPlaza, cPais, cEstado;
		END IF;

		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet,  cSucursal, cNombre, cPlaza, cPais, cEstado;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
				RETURN cCodRet, cSucursal, cNombre, cPlaza, cPais, cEstado;
		END IF;				
					
		FOREACH SELECT {+AVOID_FULL(bdinteg:"informix".si_sucursales)} SKIP pRegistros FIRST pRecuperacion sucursal, nombre, plaza_cajagen, pais, estado
				INTO cSucursal, cNombre, cPlaza, cPais, cEstado
				FROM bdinteg:"informix".si_sucursales   
				ORDER BY sucursal::INTEGER

				LET iNoRegistros = iNoRegistros +1;
				RETURN cCodRet, cSucursal, UPPER(TRIM(cNombre)), cPlaza, cPais, cEstado WITH RESUME;
		END FOREACH

		IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cSucursal, cNombre, cPlaza, cPais, cEstado;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cSucursal, cNombre, cPlaza, cPais, cEstado;
		END IF;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: Lic. Uriel CaamaÃ±o Mejia',
'FECHA: 17/02/2016',
'MODULO: OPERACION',
'FUNCIONALIDAD: Reportes Convenios SAC',
'DESCRIPCION: SPL que realiza la consulta de las sucursales.',
'AUTOR: Martha Salgado Mendoza',
'FECHA: 21/04/2016',
'DESCRIPCION:  Se realizo una modificacion a el campo plaza por plaza_cajagen.',
'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 22/03/2017',
'DESCRIPCION:  Se realizo una modificacion al SPL para optimizar la respuesta haciendo un cruce directo con la tabla bdinteg:si_ptf.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_consanalistadictamen(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(8) AS numero,
			CHAR(45) AS nombre;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE numAnalista CHAR(8);
	DEFINE nomAnalista CHAR(45);	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET numAnalista = '';
	LET nomAnalista = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, numAnalista, nomAnalista;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consanalistadictamen.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, numAnalista, nomAnalista;
		END IF;				
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, numAnalista, nomAnalista;
		END IF;
		
		FOREACH
			EXECUTE PROCEDURE bdinteg:"informix".sp_dicta_consanalistadictamen()
			INTO cCodRetSp, numAnalista, nomAnalista
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP ';
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, numAnalista, nomAnalista;
			END IF;
			
			RETURN cCodRet, numAnalista, UPPER(nomAnalista) WITH RESUME;
		END FOREACH;
		
		 -- SE VALIDA SI LA CONSULTA NO CONTIENE REGRESA DATOS
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRet = '00017';
			RETURN cCodRet, TRIM(NVL(numAnalista,'')), TRIM(NVL(nomAnalista,''));
		END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 12/05/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que consulta los datos del analista de comparación de huellas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_consexpedientehuella(pUsuario CHAR(8), pIdFuncion CHAR(10), pEmpresa CHAR(4), pCliente CHAR(9), pNumRegs SMALLINT)
		RETURNING CHAR(5) AS codret,
			  CHAR(20) AS cuenta,
			  CHAR(40) AS prod_nombre,
			  CHAR(4) AS cod_docto,
			  DATE AS fecha_alta,
			  CHAR(3) AS cod_grupo,
			  CHAR(30) AS descrip_gpo,
			  CHAR(35) AS descrip_docto,
			  CHAR(30) AS descrip2,
			  CHAR(1) AS multi_img,
			  SMALLINT AS secuencia,
			  CHAR(1) AS ima_esnula;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;	
	DEFINE cCuenta CHAR(20);
    DEFINE cProdNombre CHAR(40);
    DEFINE cCodDocto CHAR(4);
    DEFINE dFechAlta DATE;
    DEFINE cCodGrupo CHAR(3);
    DEFINE cDescripGpo CHAR(30);
    DEFINE cDescripDocto CHAR(35);
    DEFINE cDescrip2 CHAR(30);
    DEFINE cMultImg CHAR(1); 
    DEFINE cSecuencia SMALLINT;   
    DEFINE cImaEsnula CHAR(1);
	DEFINE iCont SMALLINT;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cCuenta= '';
    LET cProdNombre = '';
    LET cCodDocto = '';
    LET dFechAlta = '';
    LET cCodGrupo = '';
    LET cDescripGpo = '';
    LET cDescripDocto = '';
    LET cDescrip2 = '';
    LET cMultImg = '';   
    LET cSecuencia = 0;   
    LET cImaEsnula = '';   
	LET iCont = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCuenta, cProdNombre, cCodDocto, dFechAlta, cCodGrupo, cDescripGpo, cDescripDocto, cDescrip2, cMultImg, cSecuencia, cImaEsnula;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consexpedientehuella.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEmpresa = '' OR pCliente = '' OR pNumRegs IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCuenta, cProdNombre, cCodDocto, dFechAlta, cCodGrupo, cDescripGpo, cDescripDocto, cDescrip2, cMultImg, cSecuencia, cImaEsnula;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCuenta, cProdNombre, cCodDocto, dFechAlta, cCodGrupo, cDescripGpo, cDescripDocto, cDescrip2, cMultImg, cSecuencia, cImaEsnula;
		END IF;
		
		FOREACH
			EXECUTE PROCEDURE bdidigital:"informix".cons_expediente_huella(pEmpresa,pCliente,pNumRegs) 
			INTO cCodRetSp, cCuenta, cProdNombre, cCodDocto, dFechAlta, cCodGrupo, cDescripGpo, cDescripDocto, cDescrip2, cMultImg, cSecuencia, cImaEsnula
			
			LET iCont = iCont + 1;
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdidigital@coppelimg_tcp:"informix".cons_expediente_huella';
			ELIF iCodRetSp = 110 THEN
				LET cCodRet = '00003';
			END IF;
			
			RETURN cCodRet, cCuenta, cProdNombre, cCodDocto, dFechAlta, cCodGrupo, cDescripGpo, cDescripDocto, cDescrip2, cMultImg, cSecuencia, cImaEsnula WITH RESUME;
		END FOREACH;
		
		IF iCont = 0 THEN
			LET cCodRet = '1001'; 
			RETURN cCodRet, cCuenta, cProdNombre, cCodDocto, dFechAlta, cCodGrupo, cDescripGpo, cDescripDocto, cDescrip2, cMultImg, cSecuencia, cImaEsnula;
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 19/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que consulta el expediente de documentos de identificacion del cliente',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_consultacalles(pUsuario CHAR(8), pIdFuncion CHAR(10), pCalle INTEGER ,pNombre CHAR(30))
		RETURNING CHAR(5) AS codret,
		  CHAR(80) AS mensaje_Retorno,
		  INTEGER  AS calle,
		  CHAR(30) AS nombre;    
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cMensajeRet CHAR(80);
	DEFINE iCalle INTEGER;
	DEFINE cNombre CHAR(30);	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cMensajeRet = '';
	LET iCalle = '';
	LET cNombre = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cMensajeRet, iCalle, cNombre;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consultacalles.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCalle IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cMensajeRet, iCalle, cNombre;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cMensajeRet, iCalle, cNombre;
		END IF;
		
		FOREACH 
			EXECUTE PROCEDURE bdinteg:"informix".sp_consultacalles(pCalle, pNombre, 0)
			INTO cCodRetSp, cMensajeRet, iCalle, cNombre
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:"informix".sp_consultacalles';
			ELIF iCodRetSp = 3 THEN
				LET cCodRet = '1001';
			END IF;
			
			RETURN cCodRet, cMensajeRet, iCalle, cNombre WITH RESUME;
		END FOREACH;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 29/05/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que consulta la calle del Cliente Coppel',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_consultacatdictamen(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(1) AS tipo_dictamen,
			CHAR(100) AS descripcion_dictamen;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cTipoDictamen CHAR(1);
	DEFINE cDescDictamen CHAR(100);
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cTipoDictamen = '';
	LET cDescDictamen = '';	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cTipoDictamen, cDescDictamen;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consultacatdictamen.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cTipoDictamen, cDescDictamen;
		END IF;
		
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cTipoDictamen, cDescDictamen;
		END IF;
		
		FOREACH
			EXECUTE PROCEDURE bdinteg:"informix".sp_dicta_consultacatdictamen()
			INTO cCodRetSp, cTipoDictamen, cDescDictamen 
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:"informix".sp_dicta_consultacatdictamen()';		
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00017';			
			END IF;
			
			RETURN cCodRet, cTipoDictamen, TRIM(UPPER(cDescDictamen)) WITH RESUME;
		END FOREACH;	
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cTipoDictamen, cDescDictamen;
		END IF;		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 07/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTA - INFORME DE DICTAMENES',
'DESCRIPCION: SPL que consulta los tipos de dictamenes',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_consultactecoincidencia(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(9), pEmpresa CHAR(3), pTpDireccion INTEGER)
		RETURNING CHAR(5) AS codret,
			CHAR(40) AS nombre1,
			CHAR(40) AS nombre2,
			CHAR(40) AS ap_paterno,
			CHAR(40) AS ap_materno,
			CHAR(13) AS rfc,
			CHAR(10) AS fecha_naci,
			CHAR(1)  AS sexo,
			CHAR(20) AS tipo_persona,
			CHAR(10) AS fecha_alta,
			CHAR(4)  AS sucursal,
			CHAR(30) AS nom_calle,
			CHAR(10) AS num_ext,
			CHAR(10) AS num_int,
			CHAR(6)  AS depto,
			CHAR(30) AS nom_colonia,
			CHAR(30) AS nom_municipio,
			CHAR(30) AS nom_ciudad,
			CHAR(30) AS nom_estado,
			CHAR(10) AS tel_particular,
			CHAR(10) AS tel_celular,
			CHAR(10) AS tel_trabajo,
			CHAR(5)  AS extencion;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cNombre1 CHAR(40);
	DEFINE cNombre2 CHAR(40);
	DEFINE cApPaterno CHAR(40);
	DEFINE cApMaterno CHAR(40);
	DEFINE cRFC CHAR(13);
	DEFINE cFechNacimiento CHAR(10);
	DEFINE cSexo CHAR(1);
	DEFINE cDescTpPersona CHAR(20);
	DEFINE cFechaAlta CHAR(10);
	DEFINE cSucursal CHAR(4);
	DEFINE cNomCalle CHAR(30);
	DEFINE cNumeroExt CHAR(10);
	DEFINE cNumeroInt CHAR(10);
	DEFINE cDepto CHAR(6);
	DEFINE cNomColonia CHAR(30);
	DEFINE cNomMunicipio CHAR(30);	
	DEFINE cNomCiudad CHAR(30);
	DEFINE cNomEstado CHAR(30);		
	DEFINE cTelParticular CHAR(10);
	DEFINE cTelCelular CHAR(10);
	DEFINE cTelTrabajo CHAR(10);
	DEFINE cExtencion CHAR(5);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cNombre1 = '';
	LET cNombre2 = '';
	LET cApPaterno = '';
	LET cApMaterno = '';
	LET cRFC = '';
	LET cFechNacimiento = '';
	LET cSexo = '';	
	LET cDescTpPersona = '';
	LET cFechaAlta = '';
	LET cSucursal = '';
	LET cNomCalle = '';
	LET cNumeroExt = '';
	LET cNumeroInt = '';
	LET cDepto = '';	
	LET cNomColonia = '';	
	LET cNomMunicipio = '';	
	LET cNomEstado = '';	
	LET cNomCiudad = '';
	LET cTelParticular = '';
	LET cTelCelular = '';
	LET cTelTrabajo = '';
	LET cExtencion = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNombre1,cNombre2,cApPaterno,cApMaterno,cRFC,cFechNacimiento,cSexo,cDescTpPersona,cFechaAlta,cSucursal,cNomCalle,cNumeroExt,cNumeroInt,cDepto,cNomColonia,cNomMunicipio,cNomEstado,cNomCiudad,cTelParticular,cTelCelular,cTelTrabajo,cExtencion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consultactecoincidencia.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCte = '' OR pEmpresa = '' OR pTpDireccion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombre1,cNombre2,cApPaterno,cApMaterno,cRFC,cFechNacimiento,cSexo,cDescTpPersona,cFechaAlta,cSucursal,cNomCalle,cNumeroExt,cNumeroInt,cDepto,cNomColonia,cNomMunicipio,cNomEstado,cNomCiudad,cTelParticular,cTelCelular,cTelTrabajo,cExtencion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombre1,cNombre2,cApPaterno,cApMaterno,cRFC,cFechNacimiento,cSexo,cDescTpPersona,cFechaAlta,cSucursal,cNomCalle,cNumeroExt,cNumeroInt,cDepto,cNomColonia,cNomMunicipio,cNomEstado,cNomCiudad,cTelParticular,cTelCelular,cTelTrabajo,cExtencion;
		END IF;
				
		EXECUTE PROCEDURE bdinteg:"informix".sp_consultactecoincidencia(pNumCte, pEmpresa, pTpDireccion)
		INTO cCodRetSp,cNombre1,cNombre2,cApPaterno,cApMaterno,cRFC,cFechNacimiento,cSexo,cDescTpPersona,cFechaAlta,cSucursal,cNomCalle,cNumeroExt,cNumeroInt,cDepto,cNomColonia,cNomMunicipio,cNomEstado,cNomCiudad,cTelParticular,cTelCelular,cTelTrabajo,cExtencion;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:"informix".sp_consultactecoincidencia';
		ELIF iCodRetSp =  1 THEN
			LET cCodRet = '00003';			
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '00020';
		END IF;
		
		RETURN cCodRet,cNombre1,cNombre2,cApPaterno,cApMaterno,cRFC,cFechNacimiento,cSexo,cDescTpPersona,cFechaAlta,cSucursal,cNomCalle,cNumeroExt,cNumeroInt,cDepto,cNomColonia,cNomMunicipio,cNomEstado,cNomCiudad,cTelParticular,cTelCelular,cTelTrabajo,cExtencion;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 19/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que consulta los datos y dirección del cliente coincidencia',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_consultaempleadoiccat(pUsuario CHAR(8), pIdFuncion CHAR(10), pEmpresa CHAR (3), pNumEmp CHAR(8))
		RETURNING CHAR(5) AS codret,
		CHAR(45) AS nomEmpleado;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cNomEmpleado CHAR(45);
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cNomEmpleado = '';	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNomEmpleado;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consultaempleadoiccat.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNomEmpleado;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNomEmpleado;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_empleado_iccat(pEmpresa, pNumEmp)
		INTO cCodRetSp, cNomEmpleado;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:"informix".sp_consulta_empleado_iccat';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00072';
		END IF;
		
		RETURN cCodRet, cNomEmpleado;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 28/05/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que retorna el nombre del empleado iccat',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_consultaestados(pUsuario CHAR(8), pIdFuncion CHAR(10), pEstado CHAR(2),pNombre CHAR(30))
		RETURNING CHAR(5) AS codret,
		CHAR(80) AS mensaje_Retorno,
		CHAR(2)  AS estado,
		CHAR(30) AS nombre;    
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cMensajeRet CHAR(80);
	DEFINE cEstado CHAR(2);
	DEFINE cNombre CHAR(30);	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cMensajeRet = '';
	LET cEstado = '';
	LET cNombre = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cMensajeRet, cEstado, cNombre;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consultaestados.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEstado IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cMensajeRet, cEstado, cNombre;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cMensajeRet, cEstado, cNombre;
		END IF;
		
		FOREACH 
			EXECUTE PROCEDURE bdinteg:"informix".sp_consultaestados(pEstado, pNombre, 0)
			INTO cCodRetSp, cMensajeRet, cEstado, cNombre
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:"informix".sp_consultaestados';
			ELIF iCodRetSp = 2 THEN
				LET cCodRet = '1001';
			END IF;
			RETURN cCodRet, cMensajeRet, cEstado, cNombre WITH RESUME;
		END FOREACH;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 29/05/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que consulta el estado del Cliente Coppel',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_consultalertacomph(pUsuario CHAR(8), pIdFuncion CHAR(10), pModo SMALLINT, pSkyp INTEGER,
			pStatus CHAR (1),pNumctenvo CHAR (20),pFechaIni DATE,pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			CHAR(1) AS statusAlerta,
			CHAR(4) AS sucursal,
			CHAR(20) AS cliente,
			SMALLINT AS matches,
			DATE AS fechaInsert,
			CHAR (1) AS origen,
			INTEGER	AS totalComparaciones,
			CHAR(5)	AS hora,
			CHAR(8)	AS analistaFraudes,
			CHAR(30) AS descripcionOrigen;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cStatusAlerta CHAR(1);
	DEFINE cSucursal CHAR (4);
	DEFINE cCliente CHAR (20);
	DEFINE cMatches SMALLINT;
	DEFINE dFechaInsert DATE;
	DEFINE cOrigen CHAR (1);
	DEFINE iTotalComparaciones INTEGER;
	DEFINE cHora CHAR(5);
	DEFINE cAnalistaFraudes CHAR(8);
	DEFINE cDescripcionOrigen CHAR(30);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cStatusAlerta = '';
	LET cSucursal = '';
	LET cCliente = '';
	LET cMatches = 0;
	LET dFechaInsert = '';
	LET cOrigen = '';
	LET iTotalComparaciones = 0;
	LET cHora = '';
	LET cAnalistaFraudes = '';
	LET iNoRegistros = 0;
	LET cDescripcionOrigen = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cStatusAlerta, cSucursal, cCliente, cMatches, dFechaInsert, cOrigen, iTotalComparaciones, cHora, cAnalistaFraudes, cDescripcionOrigen;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consultalertacomph.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pModo IS NULL OR pModo NOT IN (1,2) THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cStatusAlerta, cSucursal, cCliente, cMatches, dFechaInsert, cOrigen, iTotalComparaciones, cHora, cAnalistaFraudes, cDescripcionOrigen;
		END IF;
		
		IF pModo = '2' AND pNumctenvo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cStatusAlerta, cSucursal, cCliente, cMatches, dFechaInsert, cOrigen, iTotalComparaciones, cHora, cAnalistaFraudes, cDescripcionOrigen;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cStatusAlerta, cSucursal, cCliente, cMatches, dFechaInsert, cOrigen, iTotalComparaciones, cHora, cAnalistaFraudes, cDescripcionOrigen;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cStatusAlerta, cSucursal, cCliente, cMatches, dFechaInsert, cOrigen, iTotalComparaciones, cHora, cAnalistaFraudes, cDescripcionOrigen;
		END IF;	

		FOREACH
			EXECUTE PROCEDURE bdinteg:"informix".sp_dicta_consultalertacomph2(pModo, pSkyp, pStatus, pNumctenvo, pUsuario, pFechaIni, pFechaFin, pRegistros, pRecuperacion)
			INTO cCodRetSp, cStatusAlerta, cSucursal, cCliente, cMatches, dFechaInsert, cOrigen, iTotalComparaciones, cHora, cAnalistaFraudes, cDescripcionOrigen
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_dicta_consultalertacomph2';
			ELIF iCodRetSp = 3 THEN
				LET cCodRet = '1001';
			END IF;
			
			LET iNoRegistros = iNoRegistros + 1;

			IF iNoRegistros > 0 THEN
				LET iCodRetSp = '00000';
			END IF;

			RETURN cCodRet, cStatusAlerta, cSucursal, cCliente, cMatches, dFechaInsert, cOrigen, iTotalComparaciones, cHora, cAnalistaFraudes, cDescripcionOrigen WITH RESUME;
		END FOREACH;
				
		IF iNoRegistros = 0 AND pRegistros = 0 THEN	
			LET cCodRet = '00017';
			RETURN cCodRet, cStatusAlerta, cSucursal, cCliente, cMatches, dFechaInsert, cOrigen, iTotalComparaciones, cHora, cAnalistaFraudes, cDescripcionOrigen;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN 
			LET cCodRet = '1001';	
			RETURN cCodRet, cStatusAlerta, cSucursal, cCliente, cMatches, dFechaInsert, cOrigen, iTotalComparaciones, cHora, cAnalistaFraudes, cDescripcionOrigen;
		END IF;	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 25/05/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que realiza la consulta para el llenado del buzon de alertas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_consultamatchhuellacte(pUsuario CHAR(8), pIdFuncion CHAR(10), pNvoCteBco CHAR(20))
		RETURNING CHAR(5) AS codret,
			CHAR(20) AS numcte_match,
			CHAR(4) AS empresa,
			CHAR(25) AS descripcion,
			CHAR(4) AS sucursal,
			SMALLINT AS bandera;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cClienteMatch CHAR(20);
	DEFINE cEmpresa CHAR(4);
	DEFINE cDescripcion CHAR(25);
	DEFINE sCteExiste SMALLINT;
	DEFINE cSucursal CHAR(4);	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cClienteMatch = '';
	LET cEmpresa = '';
	LET cDescripcion = '';
	LET sCteExiste = 0;
	LET cSucursal = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cClienteMatch, cEmpresa, cDescripcion, sCteExiste, cSucursal;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consultamatchhuellacte.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pNvoCteBco = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cClienteMatch, cEmpresa, cDescripcion, sCteExiste, cSucursal;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cClienteMatch, cEmpresa, cDescripcion, sCteExiste, cSucursal;
		END IF;
		
		FOREACH
			EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_matcheshuellacte(pNvoCteBco)
			INTO cCodRetSp, cClienteMatch, cEmpresa, cDescripcion, sCteExiste, cSucursal
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:"informix".sp_consulta_matcheshuellacte';
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '1001'; --NO HAY RESPUESTA DE LA COMPARACION DE HUELLAS
			--ELIF iCodRetSp = 2 THEN
			--	LET cCodRet = '00017'; --OCURRIO UN PROBLEMA DE AMBIENTACION
			END IF;
			
			RETURN cCodRet, cClienteMatch, cEmpresa, cDescripcion, sCteExiste, cSucursal WITH RESUME;
		END FOREACH;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 19/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: Verifica si ha habido respuesta de la comparacion de huellas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_consultaparamdigitalizacion(pUsuario CHAR(8), pIdFuncion CHAR(10), pEmpresa CHAR(3), pCodParam SMALLINT)
		RETURNING CHAR(5) AS codret,
			CHAR(100) AS valor_param,
			CHAR(50) AS des_param;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cValorParam CHAR(100);
	DEFINE cDesParam CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cValorParam = '';
	LET cDesParam = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cValorParam, cDesParam;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consultaparamdigitalizacion.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEmpresa = '' OR pCodParam = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cValorParam, cDesParam;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cValorParam, cDesParam;
		END IF;
		
		EXECUTE PROCEDURE bdidigital:"informix".sp_dgconsultaparametrosdigitalizacion(pEmpresa, pCodParam)
		INTO cCodRetSp, cValorParam, cDesParam;
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdidigital:"informix".sp_dgconsultaparametrosdigitalizacion';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00003';			
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '00367';
		ELIF iCodRetSp = 3 THEN
			LET cCodRet = '01071';
		ELIF iCodRetSp = 4 THEN
			LET cCodRet = '00017';
		END IF;
		RETURN cCodRet, cValorParam, cDesParam;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 19/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que consulta los parametros IP y Puerto del servidor de imagenes',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_consultarcatsucursales(pUsuario CHAR(8), pIdFuncion CHAR(10), pEmpresa CHAR(3), pSucursal CHAR(4))
		RETURNING CHAR(5) AS codret,
			CHAR(3) AS empresa, 
			CHAR(4) AS sucursal, 
			CHAR(40) AS nombre, 
			CHAR(40) AS direccion1, 
			CHAR(40) AS direccion2, 
			CHAR(14) AS telefono,
			CHAR(40) AS gerente, 
			CHAR(40) AS subgerente, 
			CHAR(2) AS tpo_sucursal;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cSucursal CHAR(4);
	DEFINE cEmpresa CHAR(3);
	DEFINE cNombre CHAR(40);
	DEFINE cDireccion1 CHAR(40);
	DEFINE cDireccion2 CHAR(40);
	DEFINE cTelefono1 CHAR(14);
	DEFINE cGerente CHAR(40);
	DEFINE cSubgerente CHAR(40);
	DEFINE cTipoSucursal CHAR(2);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '';
	LET cSucursal = '';
	LET cNombre = '';
	LET cDireccion1 = '';
	LET cDireccion2 = '';
	LET cTelefono1 = '';
	LET cGerente = '';
	LET cSubgerente = '';
	LET cTipoSucursal = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cEmpresa, cSucursal, cNombre, cDireccion1, cDireccion2, cTelefono1, cGerente, cSubgerente, cTipoSucursal;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consultarcatsucursales.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEmpresa= '' OR pSucursal= '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cEmpresa, cSucursal, cNombre, cDireccion1, cDireccion2, cTelefono1, cGerente, cSubgerente, cTipoSucursal;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cEmpresa, cSucursal, cNombre, cDireccion1, cDireccion2, cTelefono1, cGerente, cSubgerente, cTipoSucursal;
		END IF;
		
		FOREACH
			EXECUTE PROCEDURE bdinteg:"informix".sp_consultarcatsucursales(pEmpresa, pSucursal)
			INTO cCodRetSp, cEmpresa, cSucursal, cNombre, cDireccion1, cDireccion2, cTelefono1, cGerente, cSubgerente, cTipoSucursal
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:"informix".sp_consultarcatsucursales';
			END IF;
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00017'; 
				RETURN cCodRet, cEmpresa, cSucursal, cNombre, cDireccion1, cDireccion2, cTelefono1, cGerente, cSubgerente, cTipoSucursal;
			END IF;
	
			RETURN cCodRet, cEmpresa, cSucursal, cNombre, cDireccion1, cDireccion2, cTelefono1, cGerente, cSubgerente, cTipoSucursal WITH RESUME;
		END FOREACH;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 19/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que consulta los datos de la sucursal',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_consultasucursales(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4))
    RETURNING CHAR(5) AS codRet,
		CHAR(40) AS nombre_suc;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cNombreSuc CHAR(40);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET cNombreSuc = '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cNombreSuc;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_consultasucursales.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSucursal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombreSuc;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombreSuc;
		END IF;
		
		SELECT nombre 
		INTO cNombreSuc 
		FROM bdinteg:"informix".si_sucursales 
		WHERE empresa = cEmpresa AND sucursal = pSucursal;
		
		IF NVL(cNombreSuc,'') = '' THEN
			LET cCodRet = '00833'; --EL NÚMERO DE SUCURSAL NO EXISTE
		END IF;
		
		RETURN cCodRet,TRIM(UPPER(cNombreSuc));
		
	END;
	
END PROCEDURE

DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA 12/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: Spl que consulta el nombre de la sucursales.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_correciondatoscte(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(20), pTipoSol CHAR(20), pNombreInc CHAR (104), pFechaNacInc DATE, 
									pNumCteCorr CHAR(20), pNombreCorr CHAR(104), pFechaNacCorr DATE, pSucursal CHAR(4), pOrigen CHAR(1))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_correciondatoscte.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCte = '' OR pTipoSol = '' OR pNombreInc = '' OR pFechaNacInc IS NULL 
		  OR pNumCteCorr = '' OR pNombreCorr = '' OR pFechaNacCorr IS NULL OR pSucursal = '' OR pOrigen = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_bit_solicitudessos_sif(pNumCte, pTipoSol, pNombreInc, pFechaNacInc, pNumCteCorr, pNombreCorr, pFechaNacCorr, pSucursal, pUsuario, pOrigen)
		INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:"informix".sp_bit_solicitudessos_sif';
		--ELIF iCodRetSp =  THEN
		--	LET cCodRet = '';
		END IF;
		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 19/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que realiza la correción de los datos de clientes',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_enviarmonitoralertas(pUsuario CHAR(8), pIdFuncion CHAR(10),pTramaEnvios CHAR(250))
		RETURNING CHAR(5) AS codRet;
   
   DEFINE cCodRet CHAR(5);
   DEFINE iSqlErr INTEGER;
   DEFINE cNumCte CHAR(9); 
   DEFINE iNoRegistros INTEGER;   
   
   LET cCodRet = '00000';
   LET iSqlErr = 0;
   LET cNumCte = '';
   LET iNoRegistros = 0;   
   
   BEGIN

	  ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
	  		RETURN cCodRet;
	  	END IF;
	  END EXCEPTION;
		
	  --SET DEBUG FILE TO '/tmp/mfinis/sp_dic_enviarmonitoralertas.out';
	  --TRACE ON;
	  
	  SET ISOLATION TO DIRTY READ;
	  SET LOCK MODE TO WAIT 3;
		
	  IF pUsuario = '' OR pIdFuncion = '' OR pTramaEnvios = '' THEN
		LET cCodRet = '00003';	
		UPDATE bdicnweb:"informix".sw_dic_statusbuzonenvmonitor
        SET status = 'E', total_registros = iNoRegistros, error_proceso = 'S', error_code = cCodRet WHERE usuario = pUsuario;
		RETURN cCodRet;
	  END IF;
		
	  EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
	  IF cCodRet <> '00000' THEN
		UPDATE bdicnweb:"informix".sw_dic_statusbuzonenvmonitor
        SET status = 'E', total_registros = iNoRegistros, error_proceso = 'S', error_code = cCodRet WHERE usuario = pUsuario;
	  	RETURN cCodRet;
	  END IF;

	  DELETE FROM bdicnweb:"informix".sw_dic_statusbuzonenvmonitor WHERE usuario = pUsuario;
		
	  INSERT INTO bdicnweb:"informix".sw_dic_statusbuzonenvmonitor(usuario,total_registros,status,error_proceso,error_code)
      VALUES(pUsuario, iNoRegistros,'I','', ''); 
	  
	  FOREACH
	  
		EXECUTE PROCEDURE bdicnweb:"informix".sp_split_cadena(pTramaEnvios, '|')
		INTO cNumCte
		--ACTUALIZA ES ESTATUS DE 5 A 1
		update bdinteg:'informix'.si_bitacora_comparaciones 
	    set status_alerta = '1' 
	    where numcte = cNumCte 
	    and status_alerta = '5';
		
		 LET iNoRegistros = iNoRegistros + 1;
		 
	  END FOREACH;
	  
	  UPDATE bdicnweb:"informix".sw_dic_statusbuzonenvmonitor
      SET status = 'T', total_registros = iNoRegistros, error_proceso = 'N', error_code = cCodRet WHERE usuario = pUsuario;
	  
	  RETURN cCodRet;
   END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 13/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SP que se encarga de regersar las alertas del buzon de pendientes al monitor de alertas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_reevdparam(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5)  AS codret,
			      CHAR(8)  AS  cTotalRegEncon,
			      CHAR(8)  AS cTotalRegenDep,
			      CHAR(8)  AS  cTotalRegPen;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cTotalRegEncon CHAR(8);
	DEFINE cTotalRegenDep CHAR(8);
	DEFINE cTotalRegPen CHAR(8);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cTotalRegEncon = '';
	LET cTotalRegenDep = '';
	LET cTotalRegPen = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cTotalRegEncon, cTotalRegenDep, cTotalRegPen;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_reevdparam.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cTotalRegEncon, cTotalRegenDep, cTotalRegPen;
		END IF;				
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cTotalRegEncon, cTotalRegenDep, cTotalRegPen;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_dicta_reevdparam()
		INTO cCodRetSp, cTotalRegEncon, cTotalRegenDep, cTotalRegPen;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:"informix".sp_dicta_reevdparam';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00003';
		END IF;
		
		RETURN cCodRet, cTotalRegEncon, cTotalRegenDep, cTotalRegPen;
	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 19/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que realiza el proceso de revaluación de los registros ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_verificastatusbuzonenvmonitor(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
			  CHAR(1) AS status,
			  INTEGER AS total_registros,
			  CHAR(1) AS error_proceso,
			  CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE iTotalReg INTEGER;
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE cPathFile CHAR(100);
	DEFINE cNomFile CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET iTotalReg = 0;
	LET cErrorProceso = '';
	LET cError = '';
	LET cPathFile = '';
	LET cNomFile = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_verificastatusbuzonenvmonitor.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END IF;
		
		LET pUsuario = TRIM(pUsuario);
		
		SELECT status,total_registros,error_proceso,error_code
		INTO cStatus, iTotalReg, cErrorProceso,cError
		FROM bdicnweb:"informix".sw_dic_statusbuzonenvmonitor WHERE usuario = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
			RETURN cCodRet,'I',iTotalReg,cErrorProceso,cError;			
		ELSE 			
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END IF;	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA 13/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que verifica el status de la ejecucion del spl encargado de regresar registros del buzon de pendientes al monitor de alertas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_verificastatusconsctesdichawk(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
			  CHAR(1) AS status,
			  INTEGER AS total_registros,
			  CHAR(1) AS error_proceso,
			  CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE iTotalReg INTEGER;
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE cPathFile CHAR(100);
	DEFINE cNomFile CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET iTotalReg = 0;
	LET cErrorProceso = '';
	LET cError = '';
	LET cPathFile = '';
	LET cNomFile = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_verificastatusconsctesdichawk.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END IF;
		
		LET pUsuario = TRIM(pUsuario);
		
		SELECT status,total_registros,error_proceso,error_code
		INTO cStatus, iTotalReg, cErrorProceso,cError
		FROM bdicnweb:"informix".sw_dic_statusconsctesdichawk WHERE usuario = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
			RETURN cCodRet,'I',iTotalReg,cErrorProceso,cError;			
		ELSE 			
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 
'AUTOR: Miguel Huitzil Cuachayo',
'FECHA 11/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que verifica el status de la ejecucion del spl encargado de consultar la Evaluacion de Resultados Hawk de Comparación de Huellas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_verificastatusconsultahuellas(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
			  INTEGER AS total_registros,
			  CHAR(1) AS status,
			  CHAR(1) AS error_proceso,
			  CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE iTotalReg INTEGER;
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE cPathFile CHAR(100);
	DEFINE cNomFile CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET iTotalReg = 0;
	LET cErrorProceso = '';
	LET cError = '';
	LET cPathFile = '';
	LET cNomFile = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cError = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,iTotalReg,cStatus,cErrorProceso,cError;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_verificastatusconsultahuellas.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cError = '00003';
			RETURN cCodRet,iTotalReg,cStatus,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cError;
		IF cError <> '00000' THEN
			RETURN cCodRet,iTotalReg,cStatus,cErrorProceso,cError;
		END IF;
		
		LET pUsuario = TRIM(pUsuario);
		
		SELECT status,total_registros,error_proceso,error_code
		INTO cStatus, iTotalReg, cErrorProceso,cError
		FROM bdicnweb:"informix".sw_dic_statusconsultahuellas WHERE usuario = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN				
			RETURN cCodRet,iTotalReg,'I',cErrorProceso,cError;		
		ELSE 			
			RETURN cCodRet,iTotalReg,cStatus,cErrorProceso,cError;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 
'AUTOR: Miguel Huitzil Cuachayo',
'FECHA 07/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTA HUELLAS',
'DESCRIPCION: SPL que verifica el status de la ejecucion del spl encargado de consultar la Evaluacion de Resultados de Comparación de Huellas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_dic_verificastatusenviobuzon(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
			  CHAR(1) AS status,
			  INTEGER AS total_registros,
			  CHAR(1) AS error_proceso,
			  CHAR(5) AS error;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE iTotalReg INTEGER;
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE cPathFile CHAR(100);
	DEFINE cNomFile CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET iTotalReg = 0;
	LET cErrorProceso = '';
	LET cError = '';
	LET cPathFile = '';
	LET cNomFile = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = '00770'; --PROCESO CON ERRORES, POR FAVOR REINTENTE NUEVAMENTE
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_dic_verificastatusenviobuzon.out';
		--TRACE ON;
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END IF;
		
		LET pUsuario = TRIM(pUsuario);
		SELECT status,total_registros,error_proceso,error_code
		INTO cStatus, iTotalReg, cErrorProceso,cError
		FROM bdicnweb:"informix".sw_dic_statusenviobuzon WHERE usuario = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN			
			RETURN cCodRet,'I',iTotalReg,cErrorProceso,cError;			
		ELSE 			
			RETURN cCodRet,cStatus,iTotalReg,cErrorProceso,cError;	
		END IF;	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA 13/06/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: MONITOR ALERTAS COMPARACION DE HUELLAS',
'DESCRIPCION: SPL que verifica el status de la ejecucion del spl encargado de regresar registros del Monitor de Alertas al Buzon de pendientes.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_sw_ro_buscapersona_pba(pId_UsuarioC CHAR(8), 
									pId_FuncionC CHAR(10), 
									pTipoBusqueda SMALLINT, 
									pIdOficio INT, 
									pNombre1 CHAR(60), 
									pNombre2 CHAR(26), 
									pApPaterno CHAR(26), 
									pApMaterno CHAR(26), 
									pPagina SMALLINT, 
									pRegistros SMALLINT, 
									pIp CHAR(15), 
									pMacAddress CHAR(12))

RETURNING CHAR(5) AS codRet, 
	CHAR(20) AS numeroCliente, 
	CHAR(15) AS rfc,
	CHAR(26) AS nombre1, 
	CHAR(26) AS nombre2, 
	CHAR(26) AS apPaterno, 
	CHAR(26) AS apMaterno, 
	CHAR(60) AS razonSocial,
	CHAR(20) AS noCuenta,
	CHAR(20) AS noTarjeta,
	CHAR(2) AS tipoPersona, 
	CHAR(1) AS tipoCliente, 
	INT AS status, 
	CHAR(20) AS descStatusBusqueda,
	CHAR(1) AS ind_omitido,
	CHAR(1) AS ind_bloqueocta,
	CHAR(1) AS ind_terminado,
	INT AS id_busqueda,
	INT AS id_resulcte,
	CHAR(2) AS tipoCuenta,
	CHAR(1) AS ind_rfc,
	CHAR(1) AS ind_dir_empleo,
	CHAR(1) AS ind_domicilio,
	CHAR(1) AS ind_nacionalidad
-- Definición de variables
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE cNumeroCliente CHAR(20);
	DEFINE cNumeroCuenta CHAR(20);
	DEFINE cNumeroTarjeta CHAR(20);
	DEFINE cRfc CHAR(13);
	DEFINE iIdNumConsulta INT;
	DEFINE cNombre1 CHAR(26);
	DEFINE cNombre2 CHAR(26);
	DEFINE cApPaterno CHAR(26);
	DEFINE cApMaterno CHAR(26);
	DEFINE cRazonSocial CHAR(60);
	DEFINE iSqlErr INT;
	DEFINE iNoRows INT;
	DEFINE iExiste INT;
	DEFINE cCriterio CHAR(60);
	DEFINE iIdBusqueda INT;
	DEFINE cTipoBusquedaPersona CHAR(1);
	DEFINE cTipoPersona CHAR(2);
	DEFINE cTipoCliente CHAR(1);
	DEFINE cIdEncontrado INT;
	DEFINE iStatusBusqueda INT;
	DEFINE cDescStatusBusqueda CHAR(20);
	DEFINE iRegsProc INT;
	DEFINE cOmitido CHAR(1);
	DEFINE cBloqueado CHAR(1);
	DEFINE cTerminado CHAR(1);
	DEFINE cTipoCuenta CHAR(2);
	DEFINE cIndRfc CHAR(1);
	DEFINE cIndEmpleo CHAR(1);
	DEFINE cIndDomicilio CHAR(1);
	DEFINE cIndNacionalidad CHAR(1);
	-- ETIQUETAS
	DEFINE cHomonimo CHAR(15);
	DEFINE cEncontrado CHAR(15);
	DEFINE cNoEncontrado CHAR(15);
	--Inicialización de variables
	LET cCodRet	= '00000';
	LET cCodRetSp = '00000';
	LET cNumeroCliente = '';
	LET cRfc = '';
	LET iIdNumConsulta = 0;
	LET cNombre1 = '';
	LET cNombre2 = '';
	LET cApPaterno = '';
	LET cApMaterno = '';
	LET cRazonSocial = '';
	LET iSqlErr = 0;
	LET cHomonimo = 'HOMONIMO';
	LET cEncontrado = 'LOCALIZADO';
	LET cNoEncontrado = 'NO LOCALIZADO';
	LET iExiste = 0;
	LET cCriterio = '';
	LET iIdBusqueda = 0;
	LET cTipoPersona = '';
	LET cTipoCliente = '';
	LET iStatusBusqueda = 0;
	LET cDescStatusBusqueda = '';
	LET cIdEncontrado = 0;
	LET iRegsProc = 0;
	LET cNumeroCuenta = '';
	LET cNumeroTarjeta = '';
	LET cOmitido = '0';
	LET cBloqueado = '0';
	LET cTerminado = '0';
	LET cTipoCuenta = '';
	LET cIndRfc = '0';
	LET cIndEmpleo = '0';
	LET cIndDomicilio = '0';
	LET cIndNacionalidad = '0';
	
	BEGIN
		-- Validaciones
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cNumeroCliente, cRfc, 
						cNombre1, cNombre2, cApPaterno, 
						cApMaterno, cRazonSocial, cNumeroCuenta, 
						cNumeroTarjeta, cTipoPersona, cTipoCliente, 
						iStatusBusqueda, cDescStatusBusqueda, cOmitido, 
						cBloqueado, cTerminado, cIdEncontrado, 
						0, cTipoCuenta, cIndRfc, 
						cIndEmpleo, cIndDomicilio, cIndNacionalidad;
			END IF;
		END EXCEPTION;

	  --SET DEBUG FILE TO "/RESPALDOS/sp_sw_ro_buscapersona.out";
	  --TRACE ON;

		-- Validación del numero de oficio
		IF pIdOficio = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumeroCliente, cRfc, 
					cNombre1, cNombre2, cApPaterno, 
					cApMaterno, cRazonSocial, cNumeroCuenta, 
					cNumeroTarjeta, cTipoPersona, cTipoCliente, 
					iStatusBusqueda, cDescStatusBusqueda, cOmitido, 
					cBloqueado, cTerminado, cIdEncontrado,
					0, cTipoCuenta, cIndRfc, 
					cIndEmpleo, cIndDomicilio, cIndNacionalidad;
		END IF;
		-- Busqueda del numero de oficio
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(id_oficio) 
		INTO iExiste 
		FROM sw_ro_maeoficios 
		WHERE id_oficio = pIdOficio;
		IF iExiste = 0 THEN
			LET cCodRet = '00001';
			RETURN cCodRet, cNumeroCliente, cRfc, 
				cNombre1, cNombre2, cApPaterno, 
				cApMaterno, cRazonSocial, cNumeroCuenta, 
				cNumeroTarjeta, cTipoPersona, cTipoCliente, 
				iStatusBusqueda, cDescStatusBusqueda, cOmitido,
				cBloqueado, cTerminado, cIdEncontrado,
				0, cTipoCuenta, cIndRfc, 
				cIndEmpleo, cIndDomicilio, cIndNacionalidad;
		END IF;
		IF pTipoBusqueda NOT IN (1,2,3,4,5,6) THEN
			LET cCodRet = '00087';
			RETURN cCodRet, cNumeroCliente, cRfc, 
				cNombre1, cNombre2, cApPaterno, 
				cApMaterno, cRazonSocial, cNumeroCuenta, 
				cNumeroTarjeta, cTipoPersona, cTipoCliente, 
				iStatusBusqueda, cDescStatusBusqueda, cOmitido, 
				cBloqueado, cTerminado, cIdEncontrado,
				0, cTipoCuenta, cIndRfc,
				cIndEmpleo, cIndDomicilio, cIndNacionalidad;
		ELSE
			-- Se INSERTa el criterio de busqueda en la tabla sw_ro_buscaper
			-- Criterio de busqueda por Nombre
			IF pTipoBusqueda = 1 THEN
				IF pPagina = 0 THEN
					EXECUTE PROCEDURE sp_sw_ro_bitacorabusqueda(pTipoBusqueda, pIdOficio, pApPaterno, 
																pApMaterno, pNombre1, pNombre2, 
																'', '', '', 
																'', '', pId_UsuarioC, 
																pIp, pMacAddress)
					INTO cCodRetSp, iIdBusqueda;
				ELSE
					EXECUTE PROCEDURE sp_sw_ro_consultimoidbusqueda(pTipoBusqueda, pIdOficio, pApPaterno,
																pApMaterno, pNombre1, pNombre2,
																'', '', '', 
																'', '', pId_UsuarioC, 
																pIp, pMacAddress)
					INTO iIdBusqueda;
				END IF;
				-- Se realiza la consulta de la persona
				LET cTipoBusquedaPersona = '1';
				SET ISOLATION TO DIRTY READ;
				FOREACH 
					EXECUTE PROCEDURE sp_sw_ro_buscaxnombre(pId_UsuarioC, pId_FuncionC, iIdBusqueda, 
															pIdOficio, cTipoBusquedaPersona, pNombre1, 
															pNombre2, pApPaterno, pApMaterno, 
															'', cTipoCuenta, pIp, 
															pMacAddress, pPagina, pRegistros)
					INTO cCodRet, cNumeroCliente, cRfc, 
						iIdNumConsulta, cNombre1, cNombre2, 
						cApPaterno, cApMaterno, cRazonSocial, 
						cTipoPersona, cTipoCliente, iStatusBusqueda, 
						cDescStatusBusqueda, cIdEncontrado
					RETURN cCodRet, cNumeroCliente, cRfc, 
						cNombre1, cNombre2, cApPaterno, 
						cApMaterno, cRazonSocial, cNumeroCuenta, 
						cNumeroTarjeta, cTipoPersona, cTipoCliente, 
						iStatusBusqueda, cDescStatusBusqueda, cOmitido, 
						cBloqueado, cTerminado, iIdBusqueda, 
						cIdEncontrado, cTipoCuenta, cIndRfc, 
						cIndEmpleo, cIndDomicilio, cIndNacionalidad
						WITH resume;
				END FOREACH;
			END IF;
			-- Criterio de busqueda por Razón Social
			IF pTipoBusqueda = 2 THEN
				LET cCriterio = pNombre1;
				LET pNombre1 = '';
				IF pPagina = 0 THEN
					EXECUTE PROCEDURE sp_sw_ro_bitacorabusqueda(pTipoBusqueda, pIdOficio, pApPaterno, 
																pApMaterno, pNombre1, pNombre2, 
																cCriterio, '', '', 
																'', '', pId_UsuarioC, 
																pIp, pMacAddress)
					INTO cCodRetSp, iIdBusqueda;
				ELSE
					EXECUTE PROCEDURE sp_sw_ro_consultimoidbusqueda(pTipoBusqueda, pIdOficio, pApPaterno, 
																	pApMaterno, pNombre1, pNombre2, 
																	cCriterio, '', '', 
																	'', '', pId_UsuarioC, 
																	pIp, pMacAddress)
					INTO iIdBusqueda;
				END IF;
				-- Se realiza la consulta de la persona
				LET cTipoBusquedaPersona = '2';
				FOREACH 
					EXECUTE PROCEDURE sp_sw_ro_buscaxnombre(pId_UsuarioC, pId_FuncionC, iIdBusqueda,
															pIdOficio, cTipoBusquedaPersona, pNombre1, 
															pNombre2, pApPaterno, pApMaterno, 
															cCriterio, cTipoCuenta, pIp, 
															pMacAddress, pPagina, pRegistros)
					INTO cCodRet, cNumeroCliente, cRfc, 
						iIdNumConsulta, cNombre1, cNombre2, 
						cApPaterno, cApMaterno, cRazonSocial, 
						cTipoPersona, cTipoCliente, iStatusBusqueda, 
						cDescStatusBusqueda, cIdEncontrado
					RETURN cCodRet, cNumeroCliente, cRfc, cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cNumeroCuenta, cNumeroTarjeta, cTipoPersona, cTipoCliente, iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado, cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta, cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad WITH resume;
				END FOREACH;
			END IF;
			-- Busqueda por RFC
			IF pTipoBusqueda = 3 THEN
				LET cCriterio = TRIM(pNombre1);
				LET pNombre1 = '';
				IF pPagina = 0 THEN
					EXECUTE PROCEDURE sp_sw_ro_bitacorabusqueda(pTipoBusqueda, pIdOficio, pApPaterno, 
																pApMaterno, pNombre1, pNombre2, 
																'', cCriterio, '', 
																'', '', pId_UsuarioC, 
																pIp, pMacAddress)
					INTO cCodRetSp, iIdBusqueda;
				ELSE
					EXECUTE PROCEDURE sp_sw_ro_consultimoidbusqueda(pTipoBusqueda, pIdOficio, pApPaterno, 
																pApMaterno, pNombre1, pNombre2, 
																'', cCriterio, '',
																'', '', pId_UsuarioC,
																pIp, pMacAddress)
					INTO iIdBusqueda;
				END IF;
				SET ISOLATION TO DIRTY READ;
				SELECT {+INDEX (bdinteg:si_cliente idx_cliente_rfc)} COUNT(*)
				INTO iRegsProc
				FROM bdinteg:si_cliente WHERE rfc like trim(cCriterio)||"%";
				--FROM bdinteg:si_cliente WHERE rfc_alterno = cCriterio;
				IF iRegsProc = 0 THEN
					SET ISOLATION TO DIRTY READ;
					SELECT {+INDEX (bdinteg:si_cliente idx_cliente_rfc_alterno)}  COUNT(*)
					INTO iRegsProc
					FROM bdinteg:si_cliente WHERE rfc_alterno like trim(cCriterio)||"%";
					--FROM bdinteg:si_cliente WHERE rfc = cCriterio;
				END IF;
				IF iRegsProc = 0 THEN
					LET cRfc = cCriterio;
					LET cDescStatusBusqueda = 'NO LOCALIZADO';
					LET cRazonSocial = '';
					-- Registro del resultado obtenido
					EXECUTE PROCEDURE sp_sw_ro_bitacoraresultados(pId_UsuarioC, iIdBusqueda, pIdOficio, 
																	'', '', '', '', 
																	'', cRfc, 
																	cNumeroCliente, '', '', '',
																	cTipoCliente, iStatusBusqueda, pIp, pMacAddress)
																	INTO cCodRetSp, iRegsProc;					
					RETURN cCodRet, cNumeroCliente, cRfc, 
							cNombre1, cNombre2, cApPaterno, 
							cApMaterno, cRazonSocial, cNumeroCuenta, 
							cNumeroTarjeta, cTipoPersona, cTipoCliente, 
							iStatusBusqueda, cDescStatusBusqueda, cOmitido, 
							cBloqueado, cTerminado, iIdBusqueda, 
							cIdEncontrado, cTipoCuenta, cIndRfc, 
							cIndEmpleo, cIndDomicilio, cIndNacionalidad;
				ELSE
					LET iRegsProc = 0;
					FOREACH 
						EXECUTE PROCEDURE sp_sw_ro_buscaxrfc2(pId_UsuarioC, pId_FuncionC, pIdOficio, iIdBusqueda, 
																cCriterio, pPagina, pRegistros, pIp, 
																pMacAddress)
						INTO cCodRet, cNumeroCliente, cRfc, iIdNumConsulta, 
								cNombre1, cNombre2, cApPaterno, cApMaterno, 
								cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda,
								cDescStatusBusqueda, cIdEncontrado
						RETURN cCodRet, cNumeroCliente, cRfc, cNombre1, cNombre2, cApPaterno, cApMaterno, cRazonSocial, cNumeroCuenta, cNumeroTarjeta, cTipoPersona, cTipoCliente, iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado, cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta, cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad WITH resume;
					END FOREACH;
				END IF;
			END IF;
			-- Busqueda por numero de cliente
			IF pTipoBusqueda = 4 THEN
				LET cCriterio = pNombre1;
				LET pNombre1 = '';
				IF pPagina = 0 THEN
					EXECUTE PROCEDURE sp_sw_ro_bitacorabusqueda(pTipoBusqueda, pIdOficio, pApPaterno, pApMaterno, 
																pNombre1, pNombre2, '', '', 
																cCriterio, '', '', pId_UsuarioC, 
																pIp, pMacAddress)
					INTO cCodRetSp, iIdBusqueda;
				ELSE
					EXECUTE PROCEDURE sp_sw_ro_consultimoidbusqueda(pTipoBusqueda, pIdOficio, pApPaterno, pApMaterno, 
																pNombre1, pNombre2, '', '', 
																cCriterio, '', '', pId_UsuarioC, 
																pIp, pMacAddress)
					INTO iIdBusqueda;
				END IF;
				SET ISOLATION TO DIRTY READ;
				SELECT SUBSTRING(tpo_persona FROM 2) AS tpo_persona, apell_paterno, apell_materno, nombre1, 
														nombre2, razon_social
				INTO cTipoBusquedaPersona, pApPaterno, pApMaterno, pNombre1, 
						pNombre2, cRazonSocial
				FROM bdinteg:si_cliente 
				WHERE numcte = cCriterio;
				IF cTipoBusquedaPersona is null THEN
					LET cDescStatusBusqueda = 'NO LOCALIZADO';
					LET cNumeroCliente = cCriterio;
					LET cRazonSocial = '';
				-- Registro del resultado obtenido
					EXECUTE PROCEDURE sp_sw_ro_bitacoraresultados(pId_UsuarioC, iIdBusqueda, pIdOficio, '', 
																	'', '', '', '', 
																	'', cNumeroCliente, '', '', 
																	'', cTipoCliente, iStatusBusqueda, pIp,
																	pMacAddress)
					INTO cCodRetSp, iRegsProc;
					RETURN cCodRet, cNumeroCliente, cRfc, cNombre1, 
							cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
							cNumeroCuenta, cNumeroTarjeta, cTipoPersona, cTipoCliente, 
							iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado, 
							cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta, 
							cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad;
				ELSE
					SET ISOLATION TO DIRTY READ;
					FOREACH 
						EXECUTE PROCEDURE sp_sw_ro_buscaxctectatar(pId_UsuarioC, pId_FuncionC, pIdOficio, iIdBusqueda,
																	1, cCriterio, pRegistros, pIp, 
																	pMacAddress)
						INTO cCodRet, cNumeroCliente, cRfc, iIdNumConsulta, 
								cNombre1, cNombre2, cApPaterno, cApMaterno, 
								cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
								cDescStatusBusqueda, cIdEncontrado
						RETURN cCodRet, cNumeroCliente, cRfc, cNombre1, 
								cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
								cNumeroCuenta, cNumeroTarjeta, cTipoPersona, cTipoCliente, 
								iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado,
								cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta, 
								cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad 
								WITH resume;
					END FOREACH;
				END IF;
			END IF;
			-- Busqueda por numero de cuenta
			IF pTipoBusqueda = 5 THEN
				LET cCriterio = pNombre1;
				LET pNombre1 = '';
				IF pPagina = 0 THEN
					EXECUTE PROCEDURE sp_sw_ro_bitacorabusqueda(pTipoBusqueda, pIdOficio, pApPaterno, pApMaterno,
																pNombre1, pNombre2, '', '', 
																'', cCriterio, '', pId_UsuarioC,
																pIp, pMacAddress)
					INTO cCodRetSp, iIdBusqueda;
				ELSE
					EXECUTE PROCEDURE sp_sw_ro_consultimoidbusqueda(pTipoBusqueda, pIdOficio, pApPaterno, pApMaterno,
																pNombre1, pNombre2, '', '', 
																'', cCriterio, '', pId_UsuarioC, 
																pIp, pMacAddress)
					INTO iIdBusqueda;
				END IF;
				SET ISOLATION TO DIRTY READ;
				FOREACH 
					EXECUTE PROCEDURE sp_sw_ro_buscacte_ctatar(1, cCriterio)
					INTO cCodRetSp, cTipoBusquedaPersona, pApPaterno, pApMaterno, 
							pNombre1, pNombre2, cRazonSocial, cTipoCuenta
					IF cTipoBusquedaPersona is null THEN
						LET cDescStatusBusqueda = 'NO LOCALIZADO';
						LET cRazonSocial = '';
						-- Registro del resultado obtenido
						EXECUTE PROCEDURE sp_sw_ro_bitacoraresultados(pId_UsuarioC, iIdBusqueda, pIdOficio, 
																		'', '', '', '', 
																		'', '', '', cCriterio, 
																		'', '', cTipoCliente, iStatusBusqueda, 
																		pIp, pMacAddress)
						INTO cCodRetSp, iRegsProc;
						RETURN cCodRetSp, cNumeroCliente, cRfc, cNombre1, 
								cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
								cCriterio, cNumeroTarjeta, cTipoPersona, cTipoCliente, 
								iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado, 
								cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta, 
								cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad 
								WITH resume;
					ELSE
						SET ISOLATION TO DIRTY READ;
						FOREACH 
							EXECUTE PROCEDURE sp_sw_ro_buscaxctectatar(pId_UsuarioC, pId_FuncionC, pIdOficio, iIdBusqueda, 
																		2, cCriterio, pRegistros, pIp, 
																		pMacAddress)
							INTO cCodRet, cNumeroCliente, cRfc, iIdNumConsulta, 
									cNombre1, cNombre2, cApPaterno, cApMaterno, 
									cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
									cDescStatusBusqueda, cIdEncontrado
							-- Se actualiza el numero de cuenta
							UPDATE sw_ro_resulper
							SET cuenta = cCriterio
							WHERE id_busqueda = iIdBusqueda 
									AND id_oficio = pIdOficio;
							RETURN cCodRet, cNumeroCliente, cRfc, cNombre1, 
									cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
									cCriterio, cNumeroTarjeta, cTipoPersona, cTipoCliente, 
									iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado, 
									cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta, 
									cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad 
									WITH resume;
						END FOREACH;
					END IF;
				END FOREACH;
			END IF;
			-- Busqueda por numero de cuenta
			IF pTipoBusqueda = 6 THEN
				LET cCriterio = pNombre1;
				LET pNombre1 = '';
				IF pPagina = 0 THEN
					EXECUTE PROCEDURE sp_sw_ro_bitacorabusqueda(pTipoBusqueda, pIdOficio, pApPaterno, pApMaterno,
																pNombre1, pNombre2, '', '', 
																'', '', cCriterio, pId_UsuarioC,
																pIp, pMacAddress)
					INTO cCodRetSp, iIdBusqueda;
				ELSE
					EXECUTE PROCEDURE sp_sw_ro_consultimoidbusqueda(pTipoBusqueda, pIdOficio, pApPaterno, pApMaterno, 
																	pNombre1, pNombre2, '', '', 
																	'', '', cCriterio, pId_UsuarioC, 
																	pIp, pMacAddress)
					INTO iIdBusqueda;
				END IF;
				SET ISOLATION TO DIRTY READ;
				FOREACH 
					EXECUTE PROCEDURE sp_sw_ro_buscacte_ctatar(2, cCriterio)
					INTO cCodRetSp, cTipoBusquedaPersona, pApPaterno, pApMaterno,
							pNombre1, pNombre2, cRazonSocial, cTipoCuenta
					IF cTipoBusquedaPersona is null THEN
						LET cDescStatusBusqueda = 'NO LOCALIZADO';
						LET cRazonSocial = '';
						-- Registro del resultado obtenido
						EXECUTE PROCEDURE sp_sw_ro_bitacoraresultados(pId_UsuarioC, iIdBusqueda, pIdOficio,'',
																		'', '', '', '',
																		'', '', '', cCriterio,
																		'',	cTipoCliente, iStatusBusqueda, pIp, 
																		pMacAddress)
						INTO cCodRetSp, iRegsProc;
						RETURN cCodRetSp, cNumeroCliente, cRfc, cNombre1, 
								cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
								cNumeroCuenta, cCriterio, cTipoPersona, cTipoCliente, 
								iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado, 
								cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta,
								cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad  
								WITH resume;
					ELSE
						SET ISOLATION TO DIRTY READ;
						FOREACH 
							EXECUTE PROCEDURE sp_sw_ro_buscaxctectatar(pId_UsuarioC, pId_FuncionC, pIdOficio, iIdBusqueda,
																		3, cCriterio, pRegistros, pIp, 
																		pMacAddress)
							INTO cCodRet, cNumeroCliente, cRfc, iIdNumConsulta, 
									cNombre1, cNombre2, cApPaterno, cApMaterno, 
									cRazonSocial, cTipoPersona, cTipoCliente, 
									iStatusBusqueda, cDescStatusBusqueda, cIdEncontrado
							-- Se actualiza el numero de cuenta
							UPDATE sw_ro_resulper
							SET num_tarjeta = cCriterio
							WHERE id_busqueda = iIdBusqueda AND id_oficio = pIdOficio;
							RETURN cCodRet, cNumeroCliente, cRfc, cNombre1, 
							cNombre2, cApPaterno, cApMaterno, cRazonSocial, 
							cNumeroCuenta, cCriterio, cTipoPersona, cTipoCliente, 
							iStatusBusqueda, cDescStatusBusqueda, cOmitido, cBloqueado, 
							cTerminado, iIdBusqueda, cIdEncontrado, cTipoCuenta, 
							cIndRfc, cIndEmpleo, cIndDomicilio, cIndNacionalidad 
							WITH resume;
						END FOREACH;
					END IF;
				END FOREACH;
			END IF;
		END IF;
	END
END PROCEDURE;
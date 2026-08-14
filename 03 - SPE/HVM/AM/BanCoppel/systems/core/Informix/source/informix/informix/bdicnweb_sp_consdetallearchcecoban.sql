CREATE PROCEDURE "informix".sp_consdetallearchcecoban(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(22), pDireccionMac CHAR(12), pFechaHoy DATE,
pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING 	CHAR(5) AS codret,
				 	CHAR(22) AS datos_nombre_archivo,
					CHAR(2) AS datos_cod_operacion,
					CHAR(22) AS datos_num_cuenta,
					INTEGER AS datos_num_cheque,
					CHAR(50) AS datos_motivo_devol,
					MONEY(14,2) AS importe;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNombreArchivo CHAR(22);
	DEFINE cCodOperacion CHAR(2);
	DEFINE cNumCuenta CHAR(22);
	DEFINE iNumCheque INTEGER;
	DEFINE cMotivoDev CHAR(50);
	DEFINE cImporte CHAR(15);
	DEFINE mImporte MONEY(14,2);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cNombreArchivo = '';
	LET cCodOperacion ='';
	LET cNumCuenta = '';
	LET iNumCheque = 0;
	LET cMotivoDev = '';
	LET cImporte = '';
	LET mImporte = 0.00;
	LET iRecuperacion = 0;
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNombreArchivo,cCodOperacion,cNumCuenta,iNumCheque,cMotivoDev,mImporte;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consdetallearchcecoban.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' OR pDireccionMac = '' OR	pFechaHoy IS NULL OR
		pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombreArchivo,cCodOperacion,cNumCuenta,iNumCheque,cMotivoDev,mImporte; 
		END IF;
		
		-- VALIDACIï¿½N DE LOS DATOS DE PAGINACIï¿½N
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNombreArchivo,cCodOperacion,cNumCuenta,iNumCheque,cMotivoDev,mImporte;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombreArchivo,cCodOperacion,cNumCuenta,iNumCheque,cMotivoDev,mImporte; 
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		
	
		FOREACH
			SELECT {+INDEX (bdicnweb:"informix".sw_cr_procesadetalle_tmp idx_sw_cr_procesadetalle_tmp )}
			SKIP pRegistros FIRST pRecuperacion datos_nombre_archivo,datos_cod_operacion,datos_num_cuenta,datos_num_cheque,
			datos_motivo_devol,importe
			INTO cNombreArchivo,cCodOperacion,cNumCuenta,iNumCheque,cMotivoDev,cImporte
			FROM bdicnweb:"informix".sw_cr_procesadetalle_tmp 
			WHERE usuario = pUsuario AND direccion_mac = pDireccionMac 
			AND datos_nombre_archivo = TRIM(pNombreArchivo) 
			AND fecha_insert = pFechaHoy

			LET mImporte = SUBSTR(cImporte,1,(LENGTH(cImporte)-2))||"."||SUBSTR(cImporte,(LENGTH(cImporte)-1),2);
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,UPPER(TRIM(cNombreArchivo)),TRIM(cCodOperacion),TRIM(cNumCuenta),iNumCheque,UPPER(TRIM(cMotivoDev)),NVL(mImporte,0) WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet,cNombreArchivo,cCodOperacion,cNumCuenta,iNumCheque,cMotivoDev,mImporte;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '10001';
			RETURN cCodRet,cNombreArchivo,cCodOperacion,cNumCuenta,iNumCheque,cMotivoDev,mImporte;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 14/07/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Carga manual de archivos recibidos', 
'DESCRIPCION: SPL encargado de consultar el detalle de los archivos de cecoban.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catarchivoimportar(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(5) AS cod_operacion,
			CHAR(100) AS desc_archivo;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDesCodRetSp CHAR(80);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cCodOperacion CHAR(5);
	DEFINE cDescArchivo CHAR(100);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cDesCodRetSp = '';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cCodOperacion = '';
	LET cDescArchivo = '';
	LET iRecuperacion = 0;
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodOperacion, cDescArchivo;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catarchivoimportar.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodOperacion, cDescArchivo;	
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCodOperacion, cDescArchivo;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		
		
		FOREACH
			SELECT {+INDEX (bdicnweb:"informix".sw_cr_tipoarchivo idx_codigo_desc_archivo )}
			codigo_operacion, decripcion_archivo
			INTO cCodOperacion, cDescArchivo
			FROM bdicnweb:"informix".sw_cr_tipoarchivo
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, TRIM(cCodOperacion), UPPER(TRIM(cDescArchivo)) WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCodOperacion, cDescArchivo;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 28/04/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Carga manual de archivos recibidos', 
'DESCRIPCION: SPL encargado de consultar el tipo de archivo a importar.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validarchivoimportar(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(22), pCodOperacion CHAR(5), pFecha DATE)
		RETURNING CHAR(5) AS codret;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDesCodRetSp CHAR(80);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cBanco CHAR(3);
	DEFINE cArchivo CHAR(22);
	DEFINE cPrefijoArch CHAR(20);
	DEFINE cArchInvalido CHAR(1);
	DEFINE cFechaConsulta CHAR(10);
	DEFINE cDiaArch CHAR(2);
	DEFINE iCountArch INTEGER;
	
	DEFINE cProcesoDatos CHAR(1);
	DEFINE cProcesoImg CHAR(1);
	DEFINE iRecuperacion INTEGER;
    --Nuevo
    DEFINE cCmd1 CHAR(1000);
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cDesCodRetSp = '';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cBanco = '';
	LET cArchivo = '';
	LET cPrefijoArch = '';
	LET cArchInvalido = '';
	LET cFechaConsulta = '';
	LET cDiaArch = '';
	LET iCountArch = 0;
	
	LET cProcesoDatos = '';
	LET cProcesoImg = '';
	LET iRecuperacion = 0;
    --Nuevo
    LET cCmd1 = '';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_validarchivoimportar.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' OR pCodOperacion = '' OR pFecha IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;	
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		-- N?mero de banco propio
		SELECT valor INTO cBanco 
		FROM bdinteg:"informix".si_param WHERE empresa = '001' AND cod_param = '5';
		
		LET cFechaConsulta = pFecha;
		LET cDiaArch = SUBSTRING(cFechaConsulta FROM 4 FOR 2);
			
		IF TRIM(pCodOperacion) IN ('40-1','40-2','46','47') THEN
			
			LET cArchivo = SUBSTRING(TRIM(pNombreArchivo) FROM 1 FOR 14);
			
			IF TRIM(pCodOperacion) = '40-1' THEN
				LET cPrefijoArch = 'S01'||TRIM(cBanco)||'A1.APR'||cDiaArch;			
			ELIF TRIM(pCodOperacion) = '40-2' THEN
				LET cPrefijoArch = 'S01'||TRIM(cBanco)||'A1.APD'||cDiaArch;
			ELIF TRIM(pCodOperacion) = '46' THEN
				LET cPrefijoArch = 'S01'||TRIM(cBanco)||'A1.ARP'||cDiaArch;			
			ELIF TRIM(pCodOperacion) = '47' THEN
				LET cPrefijoArch = 'S01'||TRIM(cBanco)||'A1.AEP'||cDiaArch;
			END IF;		
			
			IF UPPER(cArchivo) <> UPPER(TRIM(cPrefijoArch)) THEN 
				LET cArchInvalido = 'T';
			END IF;	
		
		ELIF TRIM(pCodOperacion) = 'IMG' THEN
		
			LET cArchivo = SUBSTRING(TRIM(pNombreArchivo) FROM 1 FOR 13);
			LET cPrefijoArch = 'SAI'||TRIM(cBanco)||'A1.AI'||cDiaArch;
		
			IF UPPER(cArchivo) <> UPPER(TRIM(cPrefijoArch)) THEN 
				LET cArchInvalido = 'T';
			END IF;
			
		END IF;
		
		IF cArchInvalido = 'T' THEN 
			LET cCodRet = '00481'; 
			RETURN cCodRet;
		END IF;
		 
		-- Valida que exista el 1er archivo de presentaciÃ³n cÃ³digo 40
		IF TRIM(pCodOperacion) = '47' THEN
			--LET cDiaArch = TO_CHAR(cDiaArch::INTEGER - 1);
            LET cPrefijoArch = '''%'||'S01'||TRIM(cBanco)||'A1.APR'||cDiaArch||'%''';
            LET cCmd1 = "";
            LET cCmd1 = ""||TRIM(cCmd1)|| "SELECT COUNT(*) ";
            LET cCmd1 = ""||TRIM(cCmd1)|| " FROM bditef:informix.cce_archivos_ctl ";
            LET cCmd1 = ""||TRIM(cCmd1)|| " WHERE nombrearchivo LIKE "||cPrefijoArch||" AND fecha_entrada <= '"||pFecha||"' AND procesado IN ('0','1')";
            
            PREPARE stmtId FROM TRIM(cCmd1);
            DECLARE selectQryCur CURSOR FOR stmtId;
            OPEN selectQryCur;
            FETCH selectQryCur INTO iCountArch;

			IF iCountArch = 0 THEN
				LET cCodRet = '00792'; --NO HA SIDO CARGADO UN ARCHIVO CÃDIGO 40 PARA HOY, VERIFIQUE
				RETURN cCodRet;
			END IF;
		END IF;
		
		-- Valida el archivo
		SELECT COUNT(*) INTO iCountArch
		FROM bditef:"informix".cce_archivos_ctl
        WHERE nombrearchivo = UPPER(TRIM(pNombreArchivo))
        AND fecha_entrada = pFecha
        AND procesado IN ('0','1');
		
		IF iCountArch <> 0 THEN
			LET cCodRet = '00793'; --ESTE ARCHIVO YA FUE PROCESADO PARA HOY, VERIFIQUE
			RETURN cCodRet;
		END IF;
		
		RETURN cCodRet;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Le?n Amador',
'FECHA: 29/04/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Carga manual de archivos recibidos', 
'DESCRIPCION: SPL encargado de hacer la validaciÃ³n del archivo a importar.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_recibedatosarchivoimagenes(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdEntrada CHAR(1), pNombreArchivo CHAR(22), 
pIdRegistro CHAR(2), pBloqueArchivo CHAR(117), pNroSecuencia INTEGER, pDireccionMac CHAR(12), pFechaHoy DATE)
		RETURNING CHAR(5) AS codret,
				  CHAR(1) AS bandera_det_error; 
	
	DEFINE cCodRet CHAR(5);
	DEFINE cIdCodRet CHAR(5);
	DEFINE cDescIdCodRet CHAR(100);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdCodRetSp CHAR(6);
	DEFINE cDescMensajeError CHAR(100);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cRenglon CHAR(400);
	DEFINE iLinea INTEGER;
	DEFINE cSeccion CHAR(12);
	DEFINE cCampo CHAR(2);
	DEFINE cTexto CHAR(100);
	DEFINE cBloqueArchivo CHAR(117);
	DEFINE cEncTipoRegistro CHAR(2);
	DEFINE cEncNumSecuencia CHAR(7); 
	DEFINE cEncVersion CHAR(3);
	DEFINE cEncCodOperacion CHAR(2);
	DEFINE cEncBancoPresenta CHAR(3);
	DEFINE cEncSentido CHAR(1);
	DEFINE cEncMoneda CHAR(1);
	DEFINE cEncNumBloque CHAR(7);
	DEFINE cEncFechaProceso CHAR(8);
	DEFINE cEncUsoFuturo CHAR(83);
	DEFINE iContEncabezado INTEGER;
	DEFINE cDetTipoRegistro CHAR(2);
	DEFINE cDetNumSecuencia CHAR(7);
	DEFINE cDetCodOperacion CHAR(2);
	DEFINE cDetFechaProceso CHAR(8);
	DEFINE cDetBancoPresenta CHAR(3);
	DEFINE cDetMoneda CHAR(1);
	DEFINE cDetCodSeguridad CHAR(3);
	DEFINE cDetDigPremar CHAR(1);
	DEFINE cDetClaveTrans CHAR(2);
	DEFINE cDetPlazaCompensa CHAR(3);
	DEFINE cDetBancoLibrado CHAR(3);
	DEFINE cDetDigInter CHAR(1);
	DEFINE cDetNumCuenta CHAR(13);
	DEFINE cDetNumCheque CHAR(10);
	DEFINE cDetImporte CHAR(15);
	DEFINE cDetUsoFuturo CHAR(13);
	DEFINE cDetTamImgAnverso CHAR(15);
	DEFINE cDetTamImgReverso CHAR(15);
	DEFINE iContDetalle INTEGER;
	DEFINE cSumTipoRegistro CHAR(2);
	DEFINE cSumNumSecuencia CHAR(7);						
	DEFINE cSumTotalRegistros CHAR(9);						
	DEFINE cSumTotalImporte CHAR(16);
	DEFINE cSumUsoFuturo CHAR(83);
	DEFINE iContSumario INTEGER;
	DEFINE iTamImgF BIGINT;
	DEFINE cTamImgF CHAR(11);
	DEFINE iTamImgT BIGINT;
	DEFINE cTamImgT CHAR(11);
	DEFINE cCuenta CHAR(11);
	DEFINE cCheque CHAR(7);
	DEFINE cArchivo CHAR(21);
	DEFINE cCarpetaImgCecoban CHAR(17);
	DEFINE cArchivoImgF CHAR(44);
	DEFINE cArchivoImgT CHAR(44);
	DEFINE iTotImagenesCecoban INTEGER;
	DEFINE mValorImporte MONEY(14,2);
	DEFINE mTotImporteCecoban MONEY(14,2);
	DEFINE mTotalImporte MONEY(14,2);
	DEFINE bBanderaError CHAR(1);
	DEFINE cMiBanco CHAR(3);
	DEFINE cRazonSocial CHAR(30);
	DEFINE dHora DATETIME HOUR TO SECOND;
	DEFINE cFormatFechaHoy CHAR(8);
	DEFINE mMontoImg MONEY(14,2);
	DEFINE iPosInicial INTEGER;
    DEFINE iNroSecuencia INTEGER;
    DEFINE cTieneEncabezado CHAR(1);
    DEFINE cTieneDetalle CHAR(1);
    DEFINE cTieneSumario CHAR(1);
    DEFINE cTieneGranSumario CHAR(1);
	DEFINE cExtractorImagenes CHAR(1);
	DEFINE cBanDetError CHAR(1);
	
	LET cCodRet = '00000';
	LET cIdCodRet = '00000';
	LET cDescIdCodRet = '';
	LET iSqlErr = 0;
	LET cIdCodRetSp = '';
	LET cDescMensajeError = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cRenglon = '';
	LET iLinea = 0;
	LET cSeccion = '';
	LET cCampo = '';
	LET cTexto = '';
	LET cBloqueArchivo = '';
	LET cEncTipoRegistro = '';
	LET cEncNumSecuencia = '';
	LET cEncVersion = '';
	LET cEncCodOperacion = '';
	LET cEncBancoPresenta = '';
	LET cEncSentido = '';
	LET cEncMoneda = '';
	LET cEncNumBloque = '';
	LET cEncFechaProceso = '';
	LET cEncUsoFuturo = '';
	LET iContEncabezado = 0;
	LET cDetTipoRegistro = '';
	LET cDetNumSecuencia = '';						
	LET cDetCodOperacion = '';						
	LET cDetFechaProceso = ''; 						
	LET cDetBancoPresenta = '';
	LET cDetMoneda = '';
	LET cDetCodSeguridad = '';
	LET cDetDigPremar = '';
	LET cDetClaveTrans = '';
	LET cDetPlazaCompensa = '';
	LET cDetBancoLibrado = '';
	LET cDetDigInter = '';
	LET cDetNumCuenta = '';
	LET cDetNumCheque = '';
	LET cDetImporte = '';
	LET cDetUsoFuturo = '';
	LET cDetTamImgAnverso = '';
	LET cDetTamImgReverso = '';
	LET iContDetalle = 0;
	LET cSumTipoRegistro = '';
	LET cSumNumSecuencia = '';						
	LET cSumTotalRegistros = '';						
	LET cSumTotalImporte = '';
	LET cSumUsoFuturo = '';
	LET iContSumario = 0;
	LET iTamImgF = 0;
	LET cTamImgF = '';
	LET iTamImgT = 0;
	LET cTamImgT = '';
	LET cCuenta = '';
	LET cCheque = '';
	LET cArchivo = '';
	LET cCarpetaImgCecoban = '\tempo_imgcecoban';
	LET cArchivoImgF = '';
	LET cArchivoImgT = '';
	LET iTotImagenesCecoban = 0;
	LET mValorImporte = 0.00;
	LET mTotImporteCecoban = 0.00;
	LET mTotalImporte = 0.00;
	LET bBanderaError = 'f';
	LET cMiBanco = '';
	LET cRazonSocial = '';
	LET dHora = '';
	LET cFormatFechaHoy = '';
	LET mMontoImg = 0.00;
	LET iPosInicial = 0;
    LET iNroSecuencia = 0;
	LET cTieneEncabezado = 'f';
    LET cTieneDetalle = 'f';
    LET cTieneSumario = 'f';
    LET cTieneGranSumario = 'f';
	LET cExtractorImagenes = 'f';	
	LET cBanDetError = 'f';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cBanDetError;
		END EXCEPTION;			
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_recibedatosarchivoimagenes.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdEntrada = '' OR pNombreArchivo = '' OR pIdRegistro = '' OR pBloqueArchivo = '' OR pNroSecuencia IS NULL
		OR pDireccionMac = '' OR pFechaHoy IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cBanDetError;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cBanDetError;
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
	
		--Limpia cuando se ejecuta por 1ra vez
		IF pIdEntrada = '1' THEN
		
			DROP TABLE IF EXISTS cr_cargaimagenes_tmp;
			
			CREATE TEMP TABLE cr_cargaimagenes_tmp (
			id_serial SERIAL NOT NULL PRIMARY KEY,
			linea CHAR(400)
			)
			WITH NO LOG;

			-- LIMPIA TABLAS
			DELETE FROM bdicnweb:"informix".sw_cr_bitacoraerrorimg WHERE user_insert = pUsuario AND direccion_mac = pDireccionMac AND fecha_insert = pFechaHoy;
			DELETE FROM bdicnweb:"informix".sw_cr_procesaencabezadoimg_tmp WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND fecha_insert = pFechaHoy;
			DELETE FROM bdicnweb:"informix".sw_cr_procesadetalleimg_tmp WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND fecha_insert = pFechaHoy;
			DELETE FROM bdicnweb:"informix".sw_cr_procesasumarioimg_tmp WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND fecha_insert = pFechaHoy;
		END IF;
		
		-- BANCO PROPIETARIO
		SELECT valor INTO cMiBanco FROM bdinteg:"informix".si_param WHERE empresa = cEmpresa AND cod_param = '5';
		-- RAZï¿½N SOCIAL
		SELECT razon_social INTO cRazonSocial FROM bdinteg:"informix".si_empresas WHERE empresa = cEmpresa;
		-- VALOR IMPORTE PARA ENVIO DE IMAGEN A CECOBAN
		SELECT valor INTO mMontoImg FROM bditef:"informix".cce_param WHERE empresa = cEmpresa AND cod_param = '2';
		
		LET cFormatFechaHoy = SUBSTR(pFechaHoy,7,4) || SUBSTR(pFechaHoy,1,2) || SUBSTR(pFechaHoy,4,2);
		LET dHora = CURRENT;
		
		--LET iLinea = iLinea + 1;
		LET iLinea = NVL(pNroSecuencia,0) + 1; --(entra con 0 en la primera ejecuciï¿½n, el conteo incrementa en 1 para las siguientes ejecuciones)
		
		IF pIdRegistro = '01' THEN
		
			IF SUBSTR(pBloqueArchivo,1,2) <> '01' THEN
				LET cDescIdCodRet = 'EL ARCHIVO DE IMAGENES NO TIENE ENCABEZADO, VERIFIQUE';
				LET cSeccion = '';
				LET cCampo = '01';
				INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerrorimg(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
				VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);
				
				LET cTexto = 'el archivo de imagenes no tiene encabezado, verifique';
				INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
				VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
				dhora,'IMG','M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
			END IF;
			
			--** ENCABEZADO **--
			
				LET cSeccion = 'ENCABEZADO';
				LET cTieneEncabezado = 't';
				LET iContEncabezado = iContEncabezado + 1;

				LET cEncTipoRegistro = SUBSTR(pBloqueArchivo,1,2);
				LET cEncNumSecuencia = SUBSTR(pBloqueArchivo,3,7);
				LET cEncVersion = SUBSTR(pBloqueArchivo,10,3);
				LET cEncCodOperacion = SUBSTR(pBloqueArchivo,13,2);
				LET cEncBancoPresenta = SUBSTR(pBloqueArchivo,15,3);
				LET cEncSentido = SUBSTR(pBloqueArchivo,18,1);
				LET cEncMoneda = SUBSTR(pBloqueArchivo,19,1);
				LET cEncNumBloque = SUBSTR(pBloqueArchivo,20,7);
				LET cEncFechaProceso = SUBSTR(pBloqueArchivo,27,8);
				LET cEncUsoFuturo = SUBSTR(pBloqueArchivo,35,83); --= 118
				
				IF cEncBancoPresenta <> cMiBanco THEN
					LET cDescIdCodRet = 'EL ARCHIVO A PROCESAR NO CORRESPONDE A '||TRIM(cRazonSocial);
					LET cCampo = '05';
					INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerrorimg(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
					VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);
					
					LET cTexto = 'el archivo a procesar no corresponde a '||TRIM(cRazonSocial);
					INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
					VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
					dhora,'IMG','M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
				END IF;
	
				IF cEncSentido <> "S" THEN
					LET cDescIdCodRet = 'EL ARCHIVO A PROCESAR NO ES DE SALIDA';
					LET cCampo = '06';
					INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerrorimg(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
					VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);
					
					LET cTexto = 'el archivo a procesar no es de salida';
					INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
					VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
					dhora,'IMG','M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
				END IF;
				
				IF cEncMoneda <> "1" THEN
					LET cDescIdCodRet = 'REGISTRO ENCABEZADO NO ES MONEDA NACIONAL';
					LET cCampo = '07';
					INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerrorimg(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
					VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);
					
					LET cTexto = 'registro encabezado no es moneda nacional';
					INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
					VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
					dhora,'IMG','M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
				END IF;
				
				IF cEncFechaProceso <> cFormatFechaHoy THEN
					LET cDescIdCodRet = 'LA FECHA DE PRESENTACION DEL ARCHIVO NO CORRESPONDE A LA FECHA DE PROCESO';
					LET cCampo = '09';
					INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerrorimg(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
					VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);
					
					LET cTexto = 'la fecha de presentacion del archivo no corresponde a la fecha de proceso';
					INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
					VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
					dhora,'IMG','M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
				END IF;
				
				INSERT INTO bdicnweb:"informix".sw_cr_procesaencabezadoimg_tmp(id_encabezado,usuario,direccion_mac,tipo_registro,num_secuencia,
				version,cod_operacion,banco_presenta,sentido,moneda,num_bloque,fecha_proceso,uso_futuro,fecha_insert)
				VALUES(iContEncabezado,pUsuario,pDireccionMac,cEncTipoRegistro,cEncNumSecuencia,
				cEncVersion,cEncCodOperacion,cEncBancoPresenta,cEncSentido,cEncMoneda,cEncNumBloque,cEncFechaProceso,cEncUsoFuturo,pFechaHoy);
			
		ELIF pIdRegistro = '02' THEN
			
			--** DETALLE **--
				
				LET cSeccion = 'DETALLE';
				LET cTieneDetalle = 't';
				LET iNroSecuencia = NVL(pNroSecuencia,0) + 1; --(entra con 1 en la primera ejecuciï¿½n)
				
				SELECT NVL(MAX(id_detalle),0)+1 INTO iContDetalle FROM bdicnweb:"informix".sw_cr_procesadetalleimg_tmp
				WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND datos_nombre_archivo = TRIM(pNombreArchivo) AND fecha_insert = pFechaHoy;

				LET cDetTipoRegistro = SUBSTR(pBloqueArchivo,1,2);
				LET cDetNumSecuencia = SUBSTR(pBloqueArchivo,3,7);						
				LET cDetCodOperacion = SUBSTR(pBloqueArchivo,10,2);						
				LET cDetFechaProceso = SUBSTR(pBloqueArchivo,12,8); 						
				LET cDetBancoPresenta = SUBSTR(pBloqueArchivo,20,3);
				LET cDetMoneda = SUBSTR(pBloqueArchivo,23,1);
				LET cDetCodSeguridad = SUBSTR(pBloqueArchivo,24,3);
				LET cDetDigPremar = SUBSTR(pBloqueArchivo,27,1);
				LET cDetClaveTrans = SUBSTR(pBloqueArchivo,28,2);
				LET cDetPlazaCompensa = SUBSTR(pBloqueArchivo,30,3);
				LET cDetBancoLibrado = SUBSTR(pBloqueArchivo,33,3);
				LET cDetDigInter = SUBSTR(pBloqueArchivo,36,1);
				LET cDetNumCuenta = SUBSTR(pBloqueArchivo,37,13);
				LET cDetNumCheque = SUBSTR(pBloqueArchivo,50,10);
				LET cDetImporte = SUBSTR(pBloqueArchivo,60,15);
				LET cDetUsoFuturo = SUBSTR(pBloqueArchivo,75,13);
				LET cDetTamImgAnverso = SUBSTR(pBloqueArchivo,88,15);
				LET cDetTamImgReverso = SUBSTR(pBloqueArchivo,103,15); --= 118
				
				IF ROUND(cDetNumSecuencia::INTEGER) <> iNroSecuencia THEN
					LET cDescIdCodRet = 'EL NUMERO DE SECUENCIA EN EL REGISTRO '||iNroSecuencia||' NO CORRESPONDE, VERIFIQUE';
					LET cCampo = '02';
					INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerrorimg(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
					VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);
					
					LET cTexto = 'el nro de secuencia en el registro '||iNroSecuencia||' no corresponde, verifique';
					INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
					VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
					dhora,'IMG','M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
				END IF;
				
				IF cDetFechaProceso <> cFormatFechaHoy THEN
					LET cDescIdCodRet = 'LA FECHA DE PRESENTACION DEL ARCHIVO NO CORRESPONDE A LA FECHA DE PROCESO';
					LET cCampo = '04';
					INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerrorimg(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
					VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);
					
					LET cTexto = 'la fecha de presentacion del archivo no corresponde a la fecha de proceso';
					INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
					VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
					dhora,'IMG','M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
				END IF;
				
				IF cDetBancoLibrado <> cMiBanco THEN
					LET cDescIdCodRet = 'EL REGISTRO A PROCESAR NO CORRESPONDE A '||TRIM(cRazonSocial);
					LET cCampo = '11';
					INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerrorimg(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
					VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);
					
					LET cTexto = 'el registro a procesar no corresponde a '||TRIM(cRazonSocial);
					INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
					VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
					dhora,'IMG','M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
				END IF;
		
				LET mValorImporte = 0.00;
				LET mValorImporte = SUBSTR(cDetImporte,1,(LENGTH(cDetImporte)-2))||"."||SUBSTR(cDetImporte,(LENGTH(cDetImporte)-1),2);
			    
				LET cCuenta = cDetNumCuenta::BIGINT;
				LET cCheque = cDetNumCheque::INTEGER;
				LET cArchivo = LPAD(TRIM(cDetBancoLibrado),3,'0')||LPAD(TRIM(cCuenta),11,'0')||LPAD(TRIM(cCheque),7,'0');
				LET cArchivoImgF = TRIM(cArchivo)||'F.tif';
				LET cArchivoImgT = TRIM(cArchivo)||'T.tif';
				LET cTamImgF = cDetTamImgAnverso::BIGINT;
				LET cTamImgT = cDetTamImgReverso::BIGINT;
			
				INSERT INTO bdicnweb:"informix".sw_cr_procesadetalleimg_tmp(id_detalle,usuario,direccion_mac,
				datos_nombre_archivo,datos_num_cuenta,datos_num_cheque,datos_importe,
				datos_archivo_imgf,datos_archivo_imgt,datos_tamanio_imgf,datos_tamanio_imgt,datos_carga_imgf,datos_carga_imgt,
				tipo_registro,num_secuencia,cod_operacion,fecha_proceso,banco_presenta,moneda,cod_seguridad,
				dig_pre,clave_transfer,plaza_compensa,banco_librado,dig_inter,num_cuenta,num_cheque,importe,
				uso_futuro,tam_img_anv,tam_img_rev,bandera_color,fecha_insert)
				VALUES(iContDetalle,pUsuario,pDireccionMac,
				pNombreArchivo,cDetNumCuenta::BIGINT,cDetNumCheque::INTEGER,mValorImporte,
				cArchivoImgF,cArchivoImgT,cTamImgF,cTamImgT,'0','0',
				cDetTipoRegistro,cDetNumSecuencia,cDetCodOperacion,cDetFechaProceso,cDetBancoPresenta,cDetMoneda,cDetCodSeguridad,
				cDetDigPremar,cDetClaveTrans,cDetPlazaCompensa,cDetBancoLibrado,cDetDigInter,cDetNumCuenta,cDetNumCheque,cDetImporte,
				cDetUsoFuturo,cDetTamImgAnverso,cDetTamImgReverso,'',pFechaHoy);
		
		ELIF pIdRegistro = '09' THEN
		
			--** SUMARIO **--
				
				LET cSeccion = 'SUMARIO';
				LET cTieneSumario = 't';
				LET iContSumario = iContSumario + 1;
				
				LET cSumTipoRegistro = SUBSTR(pBloqueArchivo,1,2);
				LET cSumNumSecuencia = SUBSTR(pBloqueArchivo,3,7);											
				LET cSumTotalRegistros = SUBSTR(pBloqueArchivo,10,9); 						
				LET cSumTotalImporte = SUBSTR(pBloqueArchivo,19,16);
				LET cSumUsoFuturo = SUBSTR(pBloqueArchivo,35,83); --= 118
				
				LET mTotalImporte = 0.00;
				LET mTotalImporte = SUBSTR(cSumTotalImporte,1,(LENGTH(cSumTotalImporte)-2))||"."||SUBSTR(cSumTotalImporte,(LENGTH(cSumTotalImporte)-1),2);
				
				SELECT SUM(datos_importe) INTO mTotImporteCecoban FROM bdicnweb:"informix".sw_cr_procesadetalleimg_tmp
				WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND datos_nombre_archivo = TRIM(pNombreArchivo) AND fecha_insert = pFechaHoy;
				
				IF mTotalImporte <> mTotImporteCecoban THEN
					LET cDescIdCodRet = 'IMPORTE TOTAL DEL ARCHIVO DE IMAGENES Y EL CARGADO DIFIERE';
					LET cCampo = '04';
					INSERT INTO bdicnweb:"informix".sw_cr_bitacoraerrorimg(archivo,seccion,campo,mensaje_error,linea,user_insert,direccion_mac,fecha_insert,hora_insert)
					VALUES(pNombreArchivo,cSeccion,cCampo,cDescIdCodRet,iLinea,pUsuario,pDireccionMac,pFechaHoy,dhora);
					
					LET cTexto = 'importe total del archivo de imagenes y el cargado difiere';
					INSERT INTO bditef:"informix".cce_archivos_ctl (nombrearchivo,fecha_entrada,secuencia,hora_entrada,cod_oper,tipo_ingreso,ult_error,usuario_alta,fecha_alta,cve_status)
					VALUES (pNombreArchivo,pFechaHoy,(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFechaHoy),
					dhora,'IMG','M',TRIM(cTexto),pUsuario,pFechaHoy,'02');
				END IF;
				
				INSERT INTO bdicnweb:"informix".sw_cr_procesasumarioimg_tmp(id_sumario,usuario,direccion_mac,
				tipo_registro,num_secuencia,total_registros,importe,uso_futuro,fecha_insert)
				VALUES(iContSumario,pUsuario,pDireccionMac,cSumTipoRegistro,cSumNumSecuencia,cSumTotalRegistros,
				cSumTotalImporte,cSumUsoFuturo,pFechaHoy);
		
		END IF;
	
		IF EXISTS (SELECT mensaje_error FROM bdicnweb:"informix".sw_cr_bitacoraerrorimg 
		WHERE user_insert = pUsuario AND direccion_mac = pDireccionMac AND fecha_insert = pFechaHoy) THEN
			LET cBanDetError  = 't';
		END IF;
		
		LET cExtractorImagenes = 't';
		RETURN cCodRet,cBanDetError; 
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 07/07/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Carga manual de archivos recibidos', 
'DESCRIPCION: SPL encargado de hacer la validaciï¿½n de informaciï¿½n correspondiente a las imï¿½genes y la carga de datos a tablas temporales.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validacaracter(pUsuario CHAR(8), pIdFuncion CHAR(10), pCadena CHAR(500), pTipoCompara CHAR(1))
		RETURNING CHAR(5) AS codret,                       
			CHAR(1) AS caracter_invalido,
			INTEGER AS posicion_trama;                
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;	
	DEFINE cTamCadena CHAR(500);
	DEFINE iPos INTEGER;
	DEFINE cComparaCadena CHAR(65);
	DEFINE cCaracter CHAR(1);
	DEFINE cCaracterInvalido CHAR(1);
	DEFINE bPositionFind boolean;
	DEFINE iPosTrama INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cTamCadena = '';
	LET iPos = 0;
	LET cComparaCadena = '';
	LET cCaracter = '';
	LET cCaracterInvalido = 'f';
	LET bPositionFind = 'f';
	LET iPosTrama = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCaracterInvalido, iPosTrama;   
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_validacaracter.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCadena = '' OR pTipoCompara = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCaracterInvalido, iPosTrama;  
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCaracterInvalido, iPosTrama;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- CARACTERES INVALIDOS		
		LET cTamCadena = LENGTH(pCadena) - 1;
		LET iPos = 1;
		
		IF UPPER(pTipoCompara) = 'N' THEN
			LET cComparaCadena = '0123456789';
		ELIF UPPER(pTipoCompara) = 'L' THEN
			LET cComparaCadena = ' !#$%&()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ\_ÃÃÃÃÃÃÂ¿Â¡';
		END IF;
		
		WHILE (iPos <= cTamCadena::INTEGER) LOOP
			
			LET cCaracter = UPPER(SUBSTR(TRIM(pCadena),iPos,1));
			
			IF INSTR(TRIM(cComparaCadena),REPLACE(cCaracter," ","*")) = 0 THEN
				LET cCaracterInvalido = 't';
				EXIT;
			END IF;
			
			LET iPos = iPos + 1;
			
		END LOOP;
		
		IF cCaracterInvalido = 't' THEN
			IF iPos >= 224 THEN
				LET iPosTrama = 31;
			ELIF 	iPos >= 212 THEN
				LET iPosTrama = 30;
			ELIF 	iPos >= 210 THEN
				LET iPosTrama = 29;
			ELIF 	iPos >= 170 THEN
				LET iPosTrama = 28;
			ELIF 	iPos >= 150 THEN
				LET iPosTrama = 27;
			ELIF 	iPos >= 148 THEN
				LET iPosTrama = 26;
			ELIF 	iPos >= 130 THEN
				LET iPosTrama = 25;
			ELIF 	iPos >= 117 THEN
				LET iPosTrama = 24;
			ELIF 	iPos >= 115 THEN
				LET iPosTrama = 23;
			ELIF 	iPos >= 107 THEN
				LET iPosTrama = 22;
			ELIF 	iPos >= 105 THEN
				LET iPosTrama = 21;
			ELIF 	iPos >= 104 THEN
				LET iPosTrama = 20;
			ELIF 	iPos >= 96 THEN
				LET iPosTrama = 19;
			ELIF 	iPos >= 93 THEN
				LET iPosTrama = 18;
			ELIF 	iPos >= 92 THEN
				LET iPosTrama = 17;
			ELIF 	iPos >= 91 THEN
				LET iPosTrama = 16;
			ELIF 	iPos >= 81 THEN
				LET iPosTrama = 15;
			ELIF 	iPos >= 68 THEN
				LET iPosTrama = 14;
			ELIF 	iPos >= 65 THEN
				LET iPosTrama = 13;
			ELIF 	iPos >= 63 THEN
				LET iPosTrama = 12;
			ELIF 	iPos >= 59 THEN
				LET iPosTrama = 11;
			ELIF 	iPos >= 52 THEN
				LET iPosTrama = 10;
			ELIF 	iPos >= 48 THEN
				LET iPosTrama = 9;
			ELIF 	iPos >= 41 THEN
				LET iPosTrama = 8;
			ELIF 	iPos >= 26 THEN
				LET iPosTrama = 7;
			ELIF 	iPos >= 23 THEN
				LET iPosTrama = 6;
			ELIF 	iPos >= 20 THEN
				LET iPosTrama = 5;
			ELIF 	iPos >= 12 THEN
				LET iPosTrama = 4;
			ELIF 	iPos >= 10 THEN
				LET iPosTrama = 3;
			ELIF 	iPos >= 3 THEN
				LET iPosTrama = 2;
			ELSE 
				LET iPosTrama = 1;
			END IF;
		END IF;
		
		RETURN cCodRet, cCaracterInvalido, iPosTrama;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 25/05/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Carga manual de archivos recibidos', 
'DESCRIPCION: SPL encargado de hacer la validaciÃ³n de caracteres para la carga de archivos.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_conserroresarchcecoban_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1), pNombreArchivo CHAR(22), pDireccionMac CHAR(12), pFechaHoy DATE)
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
			RETURN cCodRet,iNumRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_conserroresarchcecoban_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' OR pNombreArchivo = '' OR pDireccionMac = '' OR pFechaHoy IS NULL THEN
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
	
		--Bitï¿½cora errores datos
		IF UPPER(pIdConsulta) = 'D' THEN
		
			SELECT COUNT(*) INTO iNumRegistros
			FROM bdicnweb:"informix".sw_cr_bitacoraerror 
			WHERE user_insert = pUsuario AND direccion_mac = pDireccionMac AND archivo = TRIM(pNombreArchivo) AND fecha_insert = pFechaHoy;
		
		--Bitï¿½cora errores imï¿½genes
		ELIF UPPER(pIdConsulta) = 'I' THEN
		
			SELECT COUNT(*) INTO iNumRegistros
			FROM bdicnweb:"informix".sw_cr_bitacoraerrorimg 
			WHERE user_insert = pUsuario AND direccion_mac = pDireccionMac AND archivo = TRIM(pNombreArchivo) AND fecha_insert = pFechaHoy;
		
		END IF;
		
		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet,iNumRegistros;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 15/07/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Carga manual de archivos recibidos', 
'DESCRIPCION: SPL encargado de consultar el nï¿½mero total de los errores encontrados en los archivos de cecoban.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultaimgnula(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(22), 
pDireccionMac CHAR(12), pFecha DATE, pStatusImgF CHAR(1), pStatusImgT CHAR(1), pIdDetalle INTEGER)
		RETURNING CHAR(5) AS codret;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cCodRetSp CHAR(5); 
	DEFINE cDescCodRetSp CHAR(35);
	DEFINE cFormatFecha CHAR(10);
	DEFINE cDia CHAR(2);
	DEFINE cMiBanco CHAR(3);
	DEFINE iHayDatos INTEGER;
	DEFINE cDetDatosNombreArch CHAR(22);
	DEFINE cDetDatosNumCuenta CHAR(22);
	DEFINE iDetDatosNumCheque INTEGER;
	DEFINE cDetDatosImporte MONEY (14,2);
	DEFINE cDatosArchImgF CHAR(100);
	DEFINE cDatosArchImgT CHAR(100);
	DEFINE cDatosTamImgF CHAR(15); 
	DEFINE cDatosTamImgT CHAR(15);
	DEFINE cDatosCargaImgF CHAR(1);
	DEFINE cDatosCargaImgT CHAR(1);
	DEFINE iIdDetalle INTEGER;
	DEFINE cHuboError CHAR(1);
	DEFINE iContDetalle INTEGER;
	DEFINE iRecuperacion INTEGER;	

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cCodRetSp = ''; 
	LET cDescCodRetSp = '';
	LET cFormatFecha = '';
	LET cDia = '';
	LET cMiBanco = '';
	LET iHayDatos = 0;
	LET cDetDatosNombreArch = '';
	LET cDetDatosNumCuenta = '';
	LET iDetDatosNumCheque = 0;
	LET cDetDatosImporte = 0.00;
	LET cDatosArchImgF = '';
	LET cDatosArchImgT = '';
	LET cDatosTamImgF = ''; 
	LET cDatosTamImgT = '';
	LET cDatosCargaImgF = '';
	LET cDatosCargaImgT = '';
	LET iIdDetalle = 0;
	LET cHuboError = 'f';
	LET iContDetalle = 0;
	LET iRecuperacion = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultaimgnula.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' OR pDireccionMac = '' OR pFecha IS NULL OR 
		pStatusImgF = '' OR pStatusImgT = '' OR pIdDetalle IS NULL THEN
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
		
		-- FECHA HABIL ACTUAL
		LET cFormatFecha = SUBSTR(pFecha,7,4)||'/'||SUBSTR(pFecha,1,2)||'/'||SUBSTR(pFecha,4,2);
		LET cDia = SUBSTR(pFecha,4,2);
		
		-- BANCO PROPIETARIO
		SELECT valor INTO cMiBanco FROM bdinteg:"informix".si_param WHERE empresa = cEmpresa AND cod_param = '5';
		
		LET iHayDatos = 0;
		SELECT COUNT(id_detalle) INTO iHayDatos FROM bdicnweb:"informix".sw_cr_procesadetalleimg_tmp 
		WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND fecha_insert = pFecha AND datos_nombre_archivo = TRIM(pNombreArchivo);
		
		IF NVL(iHayDatos,0) = 0 THEN
			LET cCodRet = '00843'; --NO HAY IMï¿½GENES QUE PROCESAR, VERIFIQUE
			RETURN cCodRet;
		END IF;
	
		FOREACH
		
			SELECT datos_nombre_archivo,datos_num_cuenta,datos_num_cheque,datos_importe,
			datos_archivo_imgf,datos_archivo_imgt,datos_tamanio_imgf,datos_tamanio_imgt
			INTO cDetDatosNombreArch,cDetDatosNumCuenta,iDetDatosNumCheque,cDetDatosImporte,
			cDatosArchImgF,cDatosArchImgT,cDatosTamImgF,cDatosTamImgT
			FROM bdicnweb:"informix".sw_cr_procesadetalleimg_tmp
			WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND fecha_insert = pFecha 
			AND datos_nombre_archivo = TRIM(pNombreArchivo) AND id_detalle = pIdDetalle
			
			IF NVL(pStatusImgF,'') <> '3' OR NVL(pStatusImgT,'') <> '3' THEN
				
				IF NVL(pStatusImgF,'') = '2' THEN
					
					-- VALIDA QUE LA IMAGEN F NO SEA NULA
					EXECUTE PROCEDURE bditef:"informix".cons_img_nula(cEmpresa,cMiBanco,TRIM(cDetDatosNumCuenta),iDetDatosNumCheque,'F',pFecha)
					INTO cCodRetSp;
					
					IF cCodRetSp::INTEGER < 0 THEN 
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIï¿½N DEL SP bditef:cons_img_nula';
					ELIF cCodRetSp::INTEGER = 110 THEN 
						LET cCodRet = '00003';
						RETURN cCodRet;
					ELIF cCodRetSp::INTEGER = 130 THEN 
						LET cCodRet = '00720';
						RETURN cCodRet;
					END IF;					
					
					IF cCodRetSp = '000' THEN
					
						UPDATE bditef:"informix".cce_propios_det SET img1_stat = '3'
						WHERE fecha_entrada = pFecha AND c_cuenta = TRIM(cDetDatosNumCuenta) AND c_cheque = iDetDatosNumCheque;
						
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cCodRet = '00283';
							RETURN cCodRet;
						END IF;
						
						--Actualiza status imagen
						UPDATE bdicnweb:"informix".sw_cr_procesadetalleimg_tmp SET datos_carga_imgf = '3'
						WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND fecha_insert = pFecha 
						AND datos_nombre_archivo = TRIM(pNombreArchivo) AND id_detalle = pIdDetalle;
						
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cCodRet = '00283';
							RETURN cCodRet;
						END IF;
					
					END IF;
				END IF;
			
				IF NVL(pStatusImgT,'') = '2' THEN
					
					-- VALIDA QUE LA IMAGEN T NO SEA NULA
					EXECUTE PROCEDURE bditef:"informix".cons_img_nula(cEmpresa,cMiBanco,TRIM(cDetDatosNumCuenta),iDetDatosNumCheque,'T',pFecha)
					INTO cCodRetSp;
				
					IF cCodRetSp::INTEGER < 0 THEN 
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIï¿½N DEL SP bditef:cons_img_nula';
					ELIF cCodRetSp::INTEGER = 110 THEN 
						LET cCodRet = '00003';
						RETURN cCodRet;
					ELIF cCodRetSp::INTEGER = 130 THEN 
						LET cCodRet = '00720';
						RETURN cCodRet;
					END IF;
					
					IF cCodRetSp = '000' THEN
						
						UPDATE bditef:"informix".cce_propios_det SET img2_stat = '3'
						WHERE fecha_entrada = pFecha AND c_cuenta = TRIM(cDetDatosNumCuenta) AND c_cheque = iDetDatosNumCheque;
						
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cCodRet = '00283';
							RETURN cCodRet;
						END IF;
						
						--Actualiza status imagen
						UPDATE bdicnweb:"informix".sw_cr_procesadetalleimg_tmp SET datos_carga_imgt = '3'
						WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND fecha_insert = pFecha 
						AND datos_nombre_archivo = TRIM(pNombreArchivo) AND id_detalle = pIdDetalle;
						
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cCodRet = '00283';
							RETURN cCodRet;
						END IF;
						
					END IF;
				END IF;
			END IF;
			
			SELECT datos_carga_imgf,datos_carga_imgt
			INTO cDatosCargaImgF,cDatosCargaImgT
			FROM bdicnweb:"informix".sw_cr_procesadetalleimg_tmp
			WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND fecha_insert = pFecha 
			AND datos_nombre_archivo = TRIM(pNombreArchivo) AND id_detalle = pIdDetalle;
		
			IF NVL(cDatosCargaImgF,'') = '3' AND NVL(cDatosCargaImgT,'') = '3' THEN
			
				--Actualiza registros que se guardaron exitosamente
				UPDATE bdicnweb:"informix".sw_cr_procesadetalleimg_tmp SET bandera_color = 'V'
				WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND fecha_insert = pFecha 
				AND datos_nombre_archivo = TRIM(pNombreArchivo) AND id_detalle = pIdDetalle;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '00283';
					RETURN cCodRet;
				END IF;
				
			END IF;
			
		END FOREACH;
		
		IF cHuboError = 't' THEN
			LET cCodRet = '00844'; --OCURRIERON ERRORES AL IMPORTAR LAS IMAGENES, REPITA EL PROCESO MAS TARDE
			RETURN cCodRet;
		END IF;
		
		--MARCA ARCHIVO COMO PROCESADO
		SELECT NVL(MAX(id_detalle),0) INTO iContDetalle FROM bdicnweb:"informix".sw_cr_procesadetalleimg_tmp
		WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND datos_nombre_archivo = TRIM(pNombreArchivo) AND fecha_insert = pFecha;
	
		IF NVL(pIdDetalle,0) = NVL(iContDetalle,0) THEN
	
			INSERT INTO bditef:"informix".cce_archivos_ctl
			VALUES (
					UPPER(TRIM(pNombreArchivo)),
					pFecha,
					(SELECT NVL(MAX(secuencia),0)+1 FROM bditef:"informix".cce_archivos_ctl WHERE fecha_entrada = pFecha),
					CURRENT,
					'IMG',
					iContDetalle,
					'','','0','03','M',
					'archivo de IMAGENES importado exitosamente',
					pUsuario,
					pFecha
					);
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00282';
				RETURN cCodRet;
			END IF;
		
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 20/07/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Carga manual de archivos recibidos',
'DESCRIPCION: SPL encargado de consultar que la imï¿½gen del archivo no se encuentre nula.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_conserroresarchcecoban(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1), pNombreArchivo CHAR(22), pDireccionMac CHAR(12), pFechaHoy DATE,
pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			CHAR(12) AS seccion,
			CHAR(2) AS campo,
			CHAR(100) AS mensaje_error,
			INTEGER AS linea;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cSeccion CHAR(12);
	DEFINE cCampo CHAR(2);
	DEFINE cDescMensaje CHAR(100);
	DEFINE iLinea INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cSeccion = '';
	LET cCampo = '';
	LET cDescMensaje = '';
	LET iLinea = 0;
	LET iRecuperacion = 0;
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cSeccion,cCampo,cDescMensaje,iLinea;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_conserroresarchcecoban.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' OR pNombreArchivo = '' OR pDireccionMac = '' OR pFechaHoy IS NULL OR 
		pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cSeccion,cCampo,cDescMensaje,iLinea;
		END IF;
		
		-- VALIDACIï¿½N DE LOS DATOS DE PAGINACIï¿½N
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cSeccion,cCampo,cDescMensaje,iLinea;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cSeccion,cCampo,cDescMensaje,iLinea;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;			
	
		--Bitï¿½cora errores datos
		IF UPPER(pIdConsulta) = 'D' THEN
		
			FOREACH
				SELECT {+INDEX (bdicnweb:"informix".sw_cr_bitacoraerror idx_sw_cr_bitacoraerror )} 
				SKIP pRegistros FIRST pRecuperacion seccion,campo,mensaje_error,linea
				INTO cSeccion,cCampo,cDescMensaje,iLinea
				FROM bdicnweb:"informix".sw_cr_bitacoraerror 
				WHERE user_insert = pUsuario AND direccion_mac = pDireccionMac AND archivo = TRIM(pNombreArchivo) AND fecha_insert = pFechaHoy
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet,UPPER(TRIM(cSeccion)),TRIM(cCampo),UPPER(TRIM(cDescMensaje)),NVL(iLinea,'') WITH RESUME;
			END FOREACH; 
			
		--Bitï¿½cora errores imï¿½genes
		ELIF UPPER(pIdConsulta) = 'I' THEN
		
			FOREACH
				SELECT {+INDEX (bdicnweb:"informix".sw_cr_bitacoraerrorimg idx_sw_cr_bitacoraerrorimg )} 
				SKIP pRegistros FIRST pRecuperacion seccion,campo,mensaje_error,linea
				INTO cSeccion,cCampo,cDescMensaje,iLinea
				FROM bdicnweb:"informix".sw_cr_bitacoraerrorimg 
				WHERE user_insert = pUsuario AND direccion_mac = pDireccionMac AND archivo = TRIM(pNombreArchivo) AND fecha_insert = pFechaHoy
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet,UPPER(TRIM(cSeccion)),TRIM(cCampo),UPPER(TRIM(cDescMensaje)),NVL(iLinea,'') WITH RESUME;
			END FOREACH;
			
		END IF;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet,cSeccion,cCampo,cDescMensaje,iLinea;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cSeccion,cCampo,cDescMensaje,iLinea;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 15/07/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Carga manual de archivos recibidos', 
'DESCRIPCION: SPL encargado de consultar el detalle de los errores encontrados en los archivos de cecoban.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consdetallearchimgcecoban_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(22), pDireccionMac CHAR(12), pFechaHoy DATE)
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
			RETURN cCodRet,iNumRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consdetallearchimgcecoban_totales.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' OR pDireccionMac = '' OR	pFechaHoy IS NULL THEN
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
	
		SELECT {+INDEX (bdicnweb:"informix".sw_cr_procesadetalleimg_tmp idx_sw_cr_procesadetalleimg_tmp )}  
		COUNT(*) INTO iNumRegistros
		FROM bdicnweb:"informix".sw_cr_procesadetalleimg_tmp 
		WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND datos_nombre_archivo = TRIM(pNombreArchivo) AND fecha_insert = pFechaHoy;
		
		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '00017'; 
		END IF;
		
		RETURN cCodRet,iNumRegistros;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 14/07/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Carga manual de archivos recibidos', 
'DESCRIPCION: SPL encargado de consultar el nï¿½mero total de registros correspondientes a los archivos de imï¿½genes de cecoban.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consdetallearchimgcecoban(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(22), pDireccionMac CHAR(12), pFechaHoy DATE,
pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			CHAR(22) AS datos_nombre_archivo,
			CHAR(22) AS datos_num_cuenta,
			INTEGER AS datos_num_cheque,
			MONEY(14,2) AS importe,
			CHAR(1) AS datos_carga_imgf,
			CHAR(1) AS datos_carga_imgt,
			INTEGER AS id_detalle;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNombreArchivo CHAR(22);
	DEFINE cNumCuenta CHAR(22);
	DEFINE iNumCheque INTEGER;
	DEFINE cImporte CHAR(15);
	DEFINE mImporte MONEY(14,2);
	DEFINE cStatusCargaImgF CHAR(1);
	DEFINE cStatusCargaImgT CHAR(1);
	DEFINE iIdDetalle INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cNombreArchivo = '';
	LET cNumCuenta = '';
	LET iNumCheque = 0;
	LET cImporte = '';
	LET mImporte = 0.00;
	LET cStatusCargaImgF = '';
	LET cStatusCargaImgT = '';
	LET iIdDetalle = 0;
	LET iRecuperacion = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNombreArchivo,cNumCuenta,iNumCheque,mImporte,cStatusCargaImgF,cStatusCargaImgT,iIdDetalle;  
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consdetallearchimgcecoban.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' OR pDireccionMac = '' OR	pFechaHoy IS NULL OR
		pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombreArchivo,cNumCuenta,iNumCheque,mImporte,cStatusCargaImgF,cStatusCargaImgT,iIdDetalle;  
		END IF;
		
		-- VALIDACIï¿½N DE LOS DATOS DE PAGINACIï¿½N
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNombreArchivo,cNumCuenta,iNumCheque,mImporte,cStatusCargaImgF,cStatusCargaImgT,iIdDetalle; 
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombreArchivo,cNumCuenta,iNumCheque,mImporte,cStatusCargaImgF,cStatusCargaImgT,iIdDetalle;  
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		
	
		FOREACH
			SELECT {+INDEX (bdicnweb:"informix".sw_cr_procesadetalleimg_tmp idx_sw_cr_procesadetalleimg_tmp )} 
			SKIP pRegistros FIRST pRecuperacion datos_nombre_archivo,datos_num_cuenta,datos_num_cheque,importe,
			datos_carga_imgf,datos_carga_imgt,id_detalle
			INTO cNombreArchivo,cNumCuenta,iNumCheque,cImporte,cStatusCargaImgF,cStatusCargaImgT,iIdDetalle
			FROM bdicnweb:"informix".sw_cr_procesadetalleimg_tmp 
			WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND datos_nombre_archivo = TRIM(pNombreArchivo) 
			AND fecha_insert = pFechaHoy ORDER BY id_detalle ASC

			LET mImporte = SUBSTR(cImporte,1,(LENGTH(cImporte)-2))||"."||SUBSTR(cImporte,(LENGTH(cImporte)-1),2);
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,UPPER(TRIM(cNombreArchivo)),TRIM(cNumCuenta),iNumCheque,NVL(mImporte,0),
			cStatusCargaImgF,cStatusCargaImgT,iIdDetalle WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet,cNombreArchivo,cNumCuenta,iNumCheque,mImporte,cStatusCargaImgF,cStatusCargaImgT,iIdDetalle; 
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '10001';
			RETURN cCodRet,cNombreArchivo,cNumCuenta,iNumCheque,mImporte,cStatusCargaImgF,cStatusCargaImgT,iIdDetalle;  
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 14/07/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Carga manual de archivos recibidos', 
'DESCRIPCION: SPL encargado de consultar el detalle de los archivos de imï¿½genes de cecoban.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_calculadigitointercambio(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20), pModulo CHAR(2))
		RETURNING CHAR(5) AS codret,                       
			INTEGER AS digito_intercambio;                
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;	
	DEFINE iDigitoIntercambio INTEGER;
	DEFINE iNumModulo INTEGER;
	DEFINE xCuenta CHAR(20);
	DEFINE iMaximo INTEGER;
	DEFINE iPos INTEGER;
	DEFINE iNumero INTEGER;
	DEFINE iAux INTEGER;
	DEFINE iSuma INTEGER;
	DEFINE iRes INTEGER;
	DEFINE iDigito INTEGER;
	DEFINE cAux CHAR(11);
	DEFINE cSuma CHAR(11);
	DEFINE cNumModulo CHAR(11);
	DEFINE iTamAux INTEGER;
	DEFINE iCorteAux INTEGER;
	DEFINE iTamSum INTEGER;
	DEFINE iCorteSum INTEGER;
	DEFINE iTamNumMod INTEGER;
	DEFINE iCorteNumMod INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;	
	LET iDigitoIntercambio = 0;
	LET iNumModulo = 0;
	LET xCuenta = '';
	LET iMaximo = 0;
	LET iPos = 0;
	LET iNumero = 0;
	LET iAux = 0;
	LET iSuma = 0;
	LET iRes = 0;
	LET iDigito = 0;
	LET cAux = '';
	LET cSuma = '';
	LET cNumModulo = '';
	LET iTamAux = 0;
	LET iCorteAux = 0;
	LET iTamSum = 0;
	LET iCorteSum = 0;
	LET iTamNumMod = 0;
	LET iCorteNumMod = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iDigitoIntercambio;   
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_calculadigitointercambio.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCuenta = '' OR pModulo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iDigitoIntercambio;   
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iDigitoIntercambio; 
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- DIGITO DE INTERCAMBIO
		IF pModulo = '9' THEN 
			LET iNumModulo = 9;
		ELIF pModulo = '10' THEN 
			LET iNumModulo = 10;
		--ELIF pModulo = '10b' THEN 
		ELIF pModulo = '11' THEN 
			LET iNumModulo = 11;
		ELSE
			LET iNumModulo = 0;
		END IF;
		
		IF iNumModulo = 0 THEN 
			LET iDigitoIntercambio = -1;
			RETURN cCodRet, iDigitoIntercambio;  
		END IF;

		IF pCuenta::BIGINT <= 0 THEN
			LET iDigitoIntercambio = -1;
			RETURN cCodRet, iDigitoIntercambio;  
		END IF;

		LET xCuenta = TRIM(pCuenta);
		LET iMaximo = LENGTH(TRIM(xCuenta));
		
		IF iNumModulo = 10 THEN

			LET iPos = 1;
			
			WHILE (iPos <= iMaximo) LOOP
				
				LET iNumero = SUBSTR(xCuenta,iPos,1);
				
				IF iPos IN (1, 4, 7, 10, 13, 16, 19) THEN
					LET iAux = NVL(iNumero,0) * 3;
					IF iAux >= 10 THEN
						LET cAux = iAux;
						LET iTamAux = LENGTH(cAux);
						LET iAux = SUBSTR(cAux,iTamAux,1);
					END IF;
				ELIF iPos IN (2, 5, 8, 11, 14, 17) THEN
					LET iAux = NVL(iNumero,0) * 7;
					IF iAux >= 10 THEN
						LET cAux = iAux;
						LET iTamAux = LENGTH(cAux);
						LET iAux = SUBSTR(cAux,iTamAux,1);
					END IF;
				ELIF iPos IN (3, 6, 9, 12, 15, 18) THEN
					LET iAux = NVL(iNumero,0) * 1;
					IF iAux >= 10 THEN
						LET cAux = iAux;
						LET iTamAux = LENGTH(cAux);
						LET iAux = SUBSTR(cAux,iTamAux,1);
					END IF;
				END IF;
				
				LET iSuma = NVL(iSuma,0) + NVL(iAux,0);			
				LET iPos = NVL(iPos,0) + 1;
				
			END LOOP;

			LET cSuma = iSuma;
			LET iTamSum = LENGTH(cSuma);
			LET iRes = SUBSTR(cSuma,iTamSum,1);
			
			LET cNumModulo = iNumModulo - iRes;
			LET iTamNumMod = LENGTH(cNumModulo);
			LET iDigito = SUBSTR(cNumModulo,iTamNumMod,1);
			
		ELSE
		
			LET iPos = 0;
			
			WHILE (iPos <= (iMaximo - 1)) LOOP
				
				LET iNumero = SUBSTR(xCuenta,(iMaximo - iPos),1);
				
				IF iPos IN (0, 6, 12, 18) THEN
					LET iAux = NVL(iNumero,0) * 2;
				ELIF iPos IN (1, 7, 13) THEN
					LET iAux = NVL(iNumero,0) * 3;
				ELIF iPos IN (2, 8, 14) THEN
					LET iAux = NVL(iNumero,0) * 4;
				ELIF iPos IN (3, 9, 15) THEN
					LET iAux = NVL(iNumero,0) * 5;
				ELIF iPos IN (4, 10, 16) THEN
					LET iAux = NVL(iNumero,0) * 6;
				ELIF iPos IN (5, 11, 17) THEN
					LET iAux = NVL(iNumero,0) * 7;
				END IF;
				
				LET iSuma = NVL(iSuma,0) + NVL(iAux,0);								
				LET iPos = NVL(iPos,0) + 1;
				
			END LOOP;

			LET iRes = MOD(iSuma,iNumModulo);
			
			IF NVL(iNumModulo,0) > 9 THEN
				IF NVL(iNumModulo,0) = 11 THEN
					IF NVL(iRes,0) = 0 THEN 
						LET iDigito = 0;
					ELSE
						LET iDigito = 11 - NVL(iRes,0);
					END IF;
					
					IF NVL(iDigito,0) = 10 THEN 
						LET iDigito = 0;
					END IF;
					LET iDigitoIntercambio = NVL(iDigito,0);
					RETURN cCodRet, iDigitoIntercambio; 
				ELSE
					IF NVL(iRes,0) = 1 THEN 
						LET iDigitoIntercambio = -1;
						RETURN cCodRet, iDigitoIntercambio; 
					ELSE
						IF NVL(iRes,0) = 0 THEN
							LET iDigitoIntercambio = -1;
							RETURN cCodRet, iDigitoIntercambio; 
						END IF;
					END IF;
				END IF;
			END IF;
			
			LET iDigito = NVL(iNumModulo,0) - NVL(iRes,0);
		
		END IF;
		
		LET iDigitoIntercambio = NVL(iDigito,0);
		RETURN cCodRet, iDigitoIntercambio; 
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 26/05/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Carga manual de archivos recibidos', 
'DESCRIPCION: SPL encargado de calcular el dÃ­gito de intercambio para la carga de archivos.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_aplicacargaarchimgcecoban(pUsuario CHAR(8), pIdFuncion CHAR(10), pNombreArchivo CHAR(22), 
pDireccionMac CHAR(12), pFecha DATE, pStatusImgF CHAR(1), pStatusImgT CHAR(1), pIdDetalle INTEGER)
		RETURNING CHAR(5) AS codret;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cCodRetSp CHAR(5); 
	DEFINE cDescCodRetSp CHAR(35);
	
	DEFINE cFormatFecha CHAR(10);
	DEFINE cDia CHAR(2);
	DEFINE cMiBanco CHAR(3);
	DEFINE iHayDatos INTEGER;
	DEFINE cDetDatosNombreArch CHAR(22);
	DEFINE cDetDatosNumCuenta CHAR(22);
	DEFINE iDetDatosNumCheque INTEGER;
	DEFINE cDetDatosImporte MONEY (14,2);
	DEFINE cDatosArchImgF CHAR(100);
	DEFINE cDatosArchImgT CHAR(100);
	DEFINE cDatosTamImgF CHAR(15); 
	DEFINE cDatosTamImgT CHAR(15);
	DEFINE cDatosCargaImgF CHAR(1);
	DEFINE cDatosCargaImgT CHAR(1);
	DEFINE iIdDetalle INTEGER;
	DEFINE cHuboError CHAR(1);
	DEFINE iContDetalle INTEGER;
	DEFINE iRecuperacion INTEGER;	

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cCodRetSp = ''; 
	LET cDescCodRetSp = '';
	
	LET cFormatFecha = '';
	LET cDia = '';
	LET cMiBanco = '';
	LET iHayDatos = 0;
	LET cDetDatosNombreArch = '';
	LET cDetDatosNumCuenta = '';
	LET iDetDatosNumCheque = 0;
	LET cDetDatosImporte = 0.00;
	LET cDatosArchImgF = '';
	LET cDatosArchImgT = '';
	LET cDatosTamImgF = ''; 
	LET cDatosTamImgT = '';
	LET cDatosCargaImgF = '';
	LET cDatosCargaImgT = '';
	LET iIdDetalle = 0;
	LET cHuboError = 'f';
	LET iContDetalle = 0;
	LET iRecuperacion = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_aplicacargaarchimgcecoban.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pNombreArchivo = '' OR pDireccionMac = '' OR pFecha IS NULL OR 
		pStatusImgF = '' OR pStatusImgT = '' OR pIdDetalle IS NULL THEN
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
		
		-- FECHA HABIL ACTUAL
		LET cFormatFecha = SUBSTR(pFecha,7,4)||'/'||SUBSTR(pFecha,1,2)||'/'||SUBSTR(pFecha,4,2);
		LET cDia = SUBSTR(pFecha,4,2);
		
		-- BANCO PROPIETARIO
		SELECT valor INTO cMiBanco FROM bdinteg:"informix".si_param WHERE empresa = cEmpresa AND cod_param = '5';
		
		LET iHayDatos = 0;
		SELECT COUNT(id_detalle) INTO iHayDatos FROM bdicnweb:"informix".sw_cr_procesadetalleimg_tmp 
		WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND fecha_insert = pFecha AND datos_nombre_archivo = TRIM(pNombreArchivo);
		
		IF NVL(iHayDatos,0) = 0 THEN
			LET cCodRet = '00843'; --NO HAY IMï¿½GENES QUE PROCESAR, VERIFIQUE
			RETURN cCodRet;
		END IF;
	
		FOREACH
		
			SELECT datos_nombre_archivo,datos_num_cuenta,datos_num_cheque,datos_importe,
			datos_archivo_imgf,datos_archivo_imgt,datos_tamanio_imgf,datos_tamanio_imgt
			INTO cDetDatosNombreArch,cDetDatosNumCuenta,iDetDatosNumCheque,cDetDatosImporte,
			cDatosArchImgF,cDatosArchImgT,cDatosTamImgF,cDatosTamImgT
			FROM bdicnweb:"informix".sw_cr_procesadetalleimg_tmp
			WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND fecha_insert = pFecha 
			AND datos_nombre_archivo = TRIM(pNombreArchivo) AND id_detalle = pIdDetalle
			
			IF NVL(pStatusImgF,'') = '0' OR NVL(pStatusImgT,'') = '0' THEN
			
				IF NVL(pStatusImgF,'') <> '3' OR NVL(pStatusImgT,'') <> '3' THEN
				
					--ProcesaArchCtlZip
					IF NVL(pStatusImgF,'') <> '2' OR NVL(pStatusImgT,'') <> '2' THEN
					
						--'generar zip de la img1 (FRONTAL)
						IF NVL(pStatusImgF,'') = '0' THEN 
			
							-- INSERTA REGISTRO DE LA IMAGEN F
							EXECUTE PROCEDURE bditef:"informix".ins_img_det(cEmpresa,cMiBanco,TRIM(cDetDatosNumCuenta),iDetDatosNumCheque,
							'F',pFecha,'tif',cDatosTamImgF,pUsuario,pFecha)
							INTO cCodRetSp;
							
							IF cCodRetSp::INTEGER < 0 THEN 
								RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIï¿½N DEL SP bditef:ins_img_det';
							ELIF cCodRetSp::INTEGER = 110 THEN 
								LET cCodRet = '00003';
								RETURN cCodRet;
							END IF;
							
							IF cCodRetSp = '000' THEN
							
								UPDATE bditef:"informix".cce_propios_det SET img1_stat = '2'
								WHERE fecha_entrada = pFecha AND c_cuenta = TRIM(cDetDatosNumCuenta) AND c_cheque = iDetDatosNumCheque;
								
								IF DBINFO('sqlca.sqlerrd2') = 0 THEN
									LET cCodRet = '00283';
									RETURN cCodRet;
								END IF;
								
								--Actualiza status imagen
								UPDATE bdicnweb:"informix".sw_cr_procesadetalleimg_tmp SET datos_carga_imgf = '2'
								WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND fecha_insert = pFecha 
								AND datos_nombre_archivo = TRIM(pNombreArchivo) AND id_detalle = pIdDetalle;		

								IF DBINFO('sqlca.sqlerrd2') = 0 THEN
									LET cCodRet = '00283';
									RETURN cCodRet;
								END IF;
								
							END IF;
						END IF;
						
						--'generar zip de la img2 (TRASERA)
						IF NVL(pStatusImgT,'') = '0' THEN 
			
							-- INSERTA REGISTRO DE LA IMAGEN T
							EXECUTE PROCEDURE bditef:"informix".ins_img_det(cEmpresa,cMiBanco,TRIM(cDetDatosNumCuenta),iDetDatosNumCheque,
							'T',pFecha,'tif',cDatosTamImgT,pUsuario,pFecha)
							INTO cCodRetSp;
							
							IF cCodRetSp::INTEGER < 0 THEN 
								RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIï¿½N DEL SP bditef:ins_img_det';
							ELIF cCodRetSp::INTEGER = 110 THEN 
								LET cCodRet = '00003';
								RETURN cCodRet;
							END IF;
							
							IF cCodRetSp = '000' THEN
							
								UPDATE bditef:"informix".cce_propios_det SET img2_stat = '2'
								WHERE fecha_entrada = pFecha AND c_cuenta = TRIM(cDetDatosNumCuenta) AND c_cheque = iDetDatosNumCheque;
								
								IF DBINFO('sqlca.sqlerrd2') = 0 THEN
									LET cCodRet = '00283';
									RETURN cCodRet;
								END IF;
								
								--Actualiza status imagen
								UPDATE bdicnweb:"informix".sw_cr_procesadetalleimg_tmp SET datos_carga_imgt = '2'
								WHERE usuario = pUsuario AND direccion_mac = pDireccionMac AND fecha_insert = pFecha 
								AND datos_nombre_archivo = TRIM(pNombreArchivo) AND id_detalle = pIdDetalle;		

								IF DBINFO('sqlca.sqlerrd2') = 0 THEN
									LET cCodRet = '00283';
									RETURN cCodRet;
								END IF;
							
							END IF;
						END IF;	
					END IF;
				END IF;
			END IF;
			
		END FOREACH;
		
		IF cHuboError = 't' THEN
			LET cCodRet = '00844'; --OCURRIERON ERRORES AL IMPORTAR LAS IMAGENES, REPITA EL PROCESO MAS TARDE
			RETURN cCodRet;
		END IF;
	
		RETURN cCodRet;
		
	END;
END PROCEDURE;
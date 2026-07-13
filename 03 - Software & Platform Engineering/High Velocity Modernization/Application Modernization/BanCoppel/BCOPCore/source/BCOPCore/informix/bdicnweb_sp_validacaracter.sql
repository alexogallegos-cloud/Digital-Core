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
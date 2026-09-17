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
CREATE PROCEDURE "informix".sp_valida_descargaimg_ccep(pUsuario CHAR(8), pIdFuncion CHAR(10), pDireccionMac CHAR(15))
		RETURNING CHAR(5) AS codret,
				 INTEGER AS contDesImg, 
				 CHAR(1) AS existTamDifImg;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE iIdConsultaDetalleCheque40 INTEGER;
	DEFINE cBanco CHAR(3);
	DEFINE cCuentaReferencia CHAR(20);
	DEFINE cNumCheque INTEGER;
	DEFINE mImporte DECIMAL(14,2);
	DEFINE cIndImgCheque CHAR(1);
	DEFINE iTamAnvImgCheque INTEGER;
	DEFINE iTamRevImgCheque INTEGER;
	DEFINE cEjecutivo CHAR(8);
	DEFINE cDireccionMac CHAR(15);
	DEFINE iContadorDescargaImg INTEGER;
	DEFINE mMontoImagen DECIMAL(16,2);
	DEFINE tamImgOrigF INTEGER;
	DEFINE tamImgOrigT INTEGER;
	DEFINE bTamDiferente BOOLEAN;
	DEFINE bExistTamDifImg CHAR(1);
	DEFINE iExistenImgsDigitalizadas INTEGER;
	DEFINE cEmpresa CHAR(3);	
	DEFINE iTamImgChqAnverso INTEGER;
	DEFINE iTamImgChqReverso INTEGER;
	DEFINE cIsImagenCheque CHAR(1);
	DEFINE bImagenF BLOB;
	DEFINE bImagenT BLOB;
	DEFINE cImagenFormatoT CHAR(3);
	DEFINE cImagenFormatoF CHAR(3);
	DEFINE dFechaHoy DATE;
	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdConsultaDetalleCheque40 = 0;
	LET cBanco = '';
	LET cCuentaReferencia = '';
	LET cNumCheque = 0;
	LET mImporte = 0.0;
	LET cIndImgCheque = '';
	LET iTamAnvImgCheque = 0;
	LET iTamRevImgCheque = 0;
	LET cEjecutivo = '';
	LET cDireccionMac = '';
	LET iContadorDescargaImg = 0;
	LET mMontoImagen = 0.0;
	LET tamImgOrigF = 0;
	LET tamImgOrigT = 0;
	LET bTamDiferente = 'f';
	LET bExistTamDifImg = 'f';
	LET iExistenImgsDigitalizadas = 0;
	LET cEmpresa = '001';
	LET iTamImgChqAnverso = 0;
	LET iTamImgChqReverso = 0;
	LET cIsImagenCheque ='';
	LET bImagenF = NULL;
	LET bImagenT = NULL;
	LET cImagenFormatoT = '';
	LET cImagenFormatoF = '';
	LET dFechaHoy = NULL;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iContadorDescargaImg, bExistTamDifImg;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_valida_descargaimg_ccep.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
  		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pDireccionMac= ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iContadorDescargaImg, bExistTamDifImg;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iContadorDescargaImg, bExistTamDifImg;
		END IF;
		
		--SE VERIFICA SI EXISTEN IMAGENES O MONTOS MAYORES 
		SELECT COUNT(ind_img_cheque)
		INTO iExistenImgsDigitalizadas
		FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
		WHERE ejecutivo = pUsuario
			AND direccion_mac = pDireccionMac
			AND (ind_img_cheque = '1' OR  ind_img_cheque = '0');
		
		IF iExistenImgsDigitalizadas > 0 THEN
		
			--SE OBTIENE PARAMETRO DE MONTO
			SELECT valor INTO mMontoImagen  FROM bditef:cce_param WHERE empresa = cEmpresa AND cod_param = '2';	
			LET iContadorDescargaImg = 0;
			
			--VALIDA SI LOS TAMANIOS DE LA IMAGEN SON IGUALES Y ACTUALIZA TABLA sw_cc_consultadetallecheque40
			FOREACH SELECT id_consultadetallecheque40,banco,cuenta_referencia,num_cheque,importe,
					ind_img_cheque,tam_anv_img_cheque,tam_rev_img_cheque,ejecutivo,direccion_mac
					INTO iIdConsultaDetalleCheque40,cBanco,cCuentaReferencia,cNumCheque,mImporte,
					cIndImgCheque,iTamAnvImgCheque,iTamRevImgCheque,cEjecutivo,cDireccionMac
					FROM bdicnweb:'informix'.sw_cc_consultadetallecheque40
					WHERE ejecutivo = pUsuario
					AND direccion_mac = pDireccionMac
					
					LET tamImgOrigF =0;
					LET tamImgOrigT = 0;
					LET bTamDiferente = 'f';
					
					IF mImporte >  mMontoImagen THEN
							IF cIndImgCheque = 1 THEN
								SELECT FIRST 1 imagen_tam INTO tamImgOrigF FROM bditef:cce_cheques_img 
								WHERE cvebanco= cBanco
								AND numcuenta= cCuentaReferencia
								AND numcheque= cNumCheque
								AND (lado_ft='F' OR lado_ft='A');
								
								IF tamImgOrigF > 0 and iTamAnvImgCheque > 0 THEN
									LET iContadorDescargaImg = iContadorDescargaImg + 1;
								END IF;
								
								SELECT FIRST 1 imagen_tam INTO tamImgOrigT FROM bditef:cce_cheques_img 
								WHERE cvebanco= cBanco
								AND numcuenta= cCuentaReferencia
								AND numcheque= cNumCheque
								AND (lado_ft='T' OR lado_ft='B' );	
								
								IF tamImgOrigT > 0 AND iTamRevImgCheque > 0 THEN
									LET iContadorDescargaImg = iContadorDescargaImg + 1;
								END IF;							
								
								IF tamImgOrigF <> iTamAnvImgCheque THEN
									LET bTamDiferente = 't';
								END IF;
								
								IF tamImgOrigT <> iTamRevImgCheque THEN
									LET bTamDiferente = 't';
								END IF;
								
								
								IF bTamDiferente = 't' THEN
									LET bExistTamDifImg = 't';
									UPDATE bdicnweb:'informix'.sw_cc_consultadetallecheque40
									SET id_status_proceso = 'D'
									WHERE ejecutivo = cEjecutivo
									AND direccion_mac = cDireccionMac
									AND id_consultadetallecheque40 = iIdConsultaDetalleCheque40;
								END IF;
								
							ELIF cIndImgCheque = 0 THEN
								SELECT fecha_hoy 
								INTO dFechaHoy
								FROM bdicheq:'informix'.sc_fechas
								WHERE empresa = cEmpresa;
							
								
								SELECT FIRST 1 imagen_tam, imagen, imagen_formato
									INTO iTamImgChqAnverso,bImagenF , cImagenFormatoF
									FROM bditef:'informix'.cce_cheques_img
									WHERE empresa = cEmpresa
									AND cvebanco = cBanco
									AND numcuenta = cCuentaReferencia
									AND numcheque = cNumCheque
									AND fechapresenta = dFechaHoy
									AND lado_ft in ('F','A');
									
								IF iTamImgChqAnverso IS NOT NULL THEN
									-- SE CONSULTA EL TAMANIO DEL REVERSO DEL CHEQUE
									SELECT FIRST 1 imagen_tam, imagen, imagen_formato
										INTO iTamImgChqReverso, bImagenT , cImagenFormatoT
										FROM bditef:'informix'.cce_cheques_img
										WHERE empresa = cEmpresa
											AND cvebanco = cBanco
											AND numcuenta = cCuentaReferencia
											AND numcheque = cNumCheque
											AND fechapresenta = dFechaHoy
											AND lado_ft in ('T','B' );
									LET cIsImagenCheque = '1';
																		
									UPDATE bdicnweb:'informix'.sw_cc_consultadetallecheque40
									SET (ind_img_cheque, tam_anv_img_cheque, tam_rev_img_cheque, imagenf,imagent,imagen_formatof,imagen_formatot,id_status_proceso) = 
									(cIsImagenCheque, iTamImgChqAnverso, iTamImgChqReverso, bImagenF,bImagenT,cImagenFormatoF,cImagenFormatoT,'P')
									WHERE ejecutivo = cEjecutivo
									AND direccion_mac = cDireccionMac
									AND id_consultadetallecheque40 = iIdConsultaDetalleCheque40;
								ELSE
									LET cIsImagenCheque = '0';
									
									UPDATE bdicnweb:'informix'.sw_cc_consultadetallecheque40
									SET (id_status_proceso,ind_img_cheque) = ('F',cIsImagenCheque)
									WHERE ejecutivo = cEjecutivo
									AND direccion_mac = cDireccionMac
									AND id_consultadetallecheque40 = iIdConsultaDetalleCheque40;
								END IF;
							END IF;		
					END IF;	
			END FOREACH;
		ELSE
			LET cCodRet = '00017';
		END IF;		
		RETURN cCodRet, iContadorDescargaImg, bExistTamDifImg;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 23/02/2016',
'MODULO: CCEP',
'FUNCIONALIDAD: Generador de Archivo',
'DESCRIPCION: actualiza tabla sw_cc_consultadetallecheque40 respecto a imagenes correctas',
'BD: BDICNWEB';

CREATE PROCEDURE "informix".sp_generador_archivos(pBandera CHAR(2), 
													pUsuario CHAR(8), 
													pIdFuncion CHAR(10), 
													pDireccionMac CHAR(15), 
													pIdRegistro INTEGER, 
													pOpcion INTEGER,
													pImporteTotal DECIMAL(14,2),
													pnombrearchivo CHAR(30), 
													pRutaArchivo CHAR(60),
													pIdsEliminar CHAR(500),
													pFechaHoy DATE, 
													pFechadevol DATE,
													pRegistros INTEGER,
													pRecuperacion INTEGER, 
													pNoBloque INTEGER,
													pNoBanco CHAR(3),
													pRutaDescarga CHAR(50), 
													pIdsPresentados CHAR(500),
													pIdCheque INTEGER, 
													pFecha DATE, 
													pCodigo CHAR(2),
													pIdConsulta CHAR(1))
													
				

RETURNING
		CHAR(5) 		AS r_codret,
		CHAR(1) 		AS r_bBanDetalle,
		DECIMAL(20,2) 	AS r_importeTotal,
		INTEGER 		AS r_iNoRegistros,
		INTEGER 		AS r_iTotalValidos,
		DECIMAL(18,2) 	AS r_dMontoTotalValido,
		INTEGER 		AS r_iNoBloque,
		INTEGER 		AS r_idRowDetalle,	
		CHAR(3) 		AS r_cBancoLibrado,
		CHAR(50) 		AS r_cDescbancoLibrado,
		DECIMAL(14,2) 	AS r_mImporte,
		CHAR(13) 		AS r_cCuentaReferencia,
		CHAR(10) 		AS r_cNumCheque,
		CHAR(20)  		AS r_cCuentaDeposito,
		CHAR(70) 		AS r_cObservaciones,
		CHAR(100) 		AS r_cMotivoDevolucion,
		CHAR(2) 		AS r_cprocesar,
		DATE 			AS r_dFechaHoy,
		CHAR(3) 		AS r_cNoBanco,
		CHAR(1) 		AS r_cProcesado,
		DATE 			AS r_dFechaHabilAnt,
		INTEGER 		AS r_TotalRegTruncados,
		CHAR(30) 		AS r_NombreArchivo,
		BOOLEAN 		AS r_esta_duplicado,		
		CHAR(3) 		AS r_cvebanco,
		CHAR(40) 		AS r_descripcionbanco,
		CHAR(20) 		AS r_cuentareferencia,
		INTEGER 		AS r_nocheque,
		DECIMAL(14,2) 	AS r_nImporte,
		CHAR(20)		AS r_cuentaDeposito,
		CHAR(44) 		AS r_sucursaloperadora,
		CHAR(20) 		AS r_cChqProcesado,
		CHAR(3) 		AS r_chqcompensacion,
		CHAR(2) 		AS r_chqtransaccion,
		CHAR(3) 		AS r_chqcodseguridad,
		CHAR(1) 		AS r_chqdigverpre,
		CHAR(1) 		AS r_chqdigverinter,
		CHAR(1) 		AS r_indimgcheque,
		INTEGER 		AS r_tamanversoimagen,
		INTEGER 		AS r_tamreversoimagen,
		CHAR(4) 		AS r_transaccion,
		CHAR(60) 		AS r_nombrecliente,
		CHAR(13) 		AS r_rfccliente,
		CHAR(20) 		AS r_curpcliente,
		CHAR(2) 		AS r_tipoctadeposito,
		INTEGER 		AS r_idregistro,
		CHAR(1) 		AS r_cIdStatusProceso,
		INTEGER 		AS r_num_registros,
		INTEGER 		AS r_doc_incompletos,
		MONEY(16,2) 	AS r_monto_total_invalido,
		INTEGER 		AS r_total_validos,
		MONEY(16,2) 	AS r_monto_total_valido,
		INTEGER 		AS r_noImagenesDesc,
		DATE 			AS r_dFechaHabilProx,
		DATE 			AS r_dFechaHabilAnt1,
		DATE 			AS r_dFechaHabilAnt2;

--DECLARACIï¿½N DE VARIABLES
DEFINE cCodRet CHAR(5);
DEFINE iSqlErr INTEGER;
DEFINE importeTotal DECIMAL(20,2);	
DEFINE bBanDet CHAR(1);
DEFINE iNoRegistros INTEGER;
DEFINE iTotalValidos INTEGER;
DEFINE iNoBloque INTEGER;
DEFINE idRowDetalle INTEGER;
DEFINE cBancoLibrado  CHAR(3);
DEFINE cDescbancoLibrado CHAR(50);
DEFINE mImporte DECIMAL(14,2);
DEFINE cCuentaReferencia CHAR(13);
DEFINE cNumCheque CHAR(10);
DEFINE cCuentaDeposito CHAR(20);
DEFINE cObservaciones CHAR(70);
DEFINE cMotivoDevolucion CHAR(100);
DEFINE cprocesar CHAR(2);
DEFINE cEmpresa CHAR(3);
DEFINE dFecha DATE;
DEFINE cNoBanco CHAR(3);
DEFINE cProcesado CHAR(1);
DEFINE cNombreArchivo CHAR(30);
DEFINE dFechaHabilAnt DATE;	
DEFINE bIsChequeDuplicado BOOLEAN;
DEFINE dMontoTotalValido DECIMAL(16,2);
DEFINE cCveBanco CHAR(3);
DEFINE cDescripcionBanco CHAR(40);
DEFINE iNoCheque INTEGER;
DEFINE cSuscursalOperadora CHAR(44);
DEFINE cChqProcesado CHAR(1);
DEFINE cChqCompensacion CHAR(3);
DEFINE cChqTransaccion CHAR(2);
DEFINE cChqCodSeguridad CHAR(3);
DEFINE cChqDigVerPre CHAR(1);
DEFINE cChqDigVerInter CHAR(1);
DEFINE cIndImgCheque CHAR(1);
DEFINE iTamAnversoImagen INTEGER;
DEFINE iTamReversoImagen INTEGER;
DEFINE iTotalRegTruncados INTEGER;
DEFINE cTransaccion CHAR(4);
DEFINE cNombreCliente CHAR(60);
DEFINE cRfcCliente CHAR(13);
DEFINE cCurpCliente CHAR(20);
DEFINE cTipoCtaDeposito CHAR(2);
DEFINE iIdRegistro INTEGER;
DEFINE cIdStatusProceso CHAR(1);
DEFINE iNoImagenes INTEGER;
DEFINE iNoChequesValidos INTEGER;
DEFINE iNoDocsIncompletos INTEGER;
DEFINE mMontoTotalValido MONEY(16,2);
DEFINE mMontoTotalInvalido MONEY(16,2);
DEFINE cStatusProceso CHAR(1);
DEFINE dFechaHabilAnt1 DATE;
DEFINE dFechaHabilAnt2 DATE;
DEFINE dFechaHabilProx DATE;

--DEFINICIï¿½N
LET cCodRet = '00000';
LET iSqlErr = 0;
LET importeTotal = 0;
LET bBanDet = '';
LET iNoRegistros = 0;
LET iTotalValidos = 0;
LET dMontoTotalValido = 0.0;
LET iNoBloque = 0;
LET idRowDetalle = 0;	
LET cBancoLibrado = '';
LET cDescbancoLibrado = '';
LET mImporte = 0.0;
LET cCuentaReferencia = '';
LET cNumCheque = '';
LET cCuentaDeposito = '';
LET cObservaciones = '';
LET cMotivoDevolucion = '';
LET cprocesar = '';

LET cEmpresa = '001';
LET dFecha = null;
LET cNoBanco = '';
LET dFechaHabilAnt = null;		
LET cProcesado = 'f';
LET bIsChequeDuplicado = 'f';

LET cCveBanco = '';
LET cDescripcionBanco = '';
LET cCuentaReferencia = '';
LET iNoCheque = 0;
LET mImporte = 0.0;
LET cCuentaDeposito = '';
LET cSuscursalOperadora = '';
LET cChqProcesado = '';
LET cChqCompensacion = '';
LET cChqTransaccion = '';
LET cChqCodSeguridad = '';
LET cChqDigVerPre = '';
LET cChqDigVerInter = '';
LET cIndImgCheque = '';
LET iTamAnversoImagen = 0;
LET iTamReversoImagen = 0;
LET cTransaccion = '';
LET cNombreCliente = '';
LET cRfcCliente = '';
LET cCurpCliente = '';
LET cTipoCtaDeposito = '';
LET iIdRegistro = 0;
LET cIdStatusProceso = '';	
LET cNombreArchivo = '';
LET iNoRegistros = 0;
LET iNoImagenes = 0;
LET iNoChequesValidos = 0;
LET iNoDocsIncompletos = 0;
LET mMontoTotalValido = 0.0;
LET mMontoTotalInvalido = 0.0;
LET cStatusProceso = '';
LET iTotalRegTruncados = 0;
LET dFechaHabilAnt1 = null;
LET dFechaHabilAnt2 = null;
LET dFechaHabilProx = null;

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, bBanDet, importeTotal, iNoRegistros, iTotalValidos, dMontoTotalValido, iNoBloque,  idRowDetalle, cBancoLibrado,
				cDescbancoLibrado,mImporte,cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,
				dFecha,cNoBanco,cProcesado,dFechaHabilAnt,iTotalRegTruncados,cNombreArchivo,bIsChequeDuplicado,cCveBanco,cDescripcionBanco,
				cCuentaReferencia,iNoCheque,mImporte,cCuentaDeposito,cSuscursalOperadora,cChqProcesado,cChqCompensacion,cChqTransaccion,
				cChqCodSeguridad,cChqDigVerPre,cChqDigVerInter,cIndImgCheque,iTamAnversoImagen,iTamReversoImagen,cTransaccion,
				cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso,
				iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), iNoChequesValidos,NVL(mMontoTotalValido, 0.0),
				iNoImagenes, dFechaHabilProx, dFechaHabilAnt1, dFechaHabilAnt2;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_generador_archivo.out';
	    --TRACE ON;

		SET ISOLATION TO DIRTY READ;
	    SET LOCK MODE TO WAIT 3;

		
		IF pBandera = '1' THEN
			EXECUTE PROCEDURE "informix".sp_actualiza_chqrevisados_ccep(pUsuario, pIdFuncion, pDireccionMac, pIdRegistro, pOpcion)
			INTO cCodRet;
			RETURN cCodRet, bBanDet, importeTotal, iNoRegistros, iTotalValidos, dMontoTotalValido, iNoBloque,  idRowDetalle, cBancoLibrado,
				cDescbancoLibrado,mImporte,cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,
				dFecha,cNoBanco,cProcesado,dFechaHabilAnt,iTotalRegTruncados,cNombreArchivo,bIsChequeDuplicado,cCveBanco,cDescripcionBanco,
				cCuentaReferencia,iNoCheque,mImporte,cCuentaDeposito,cSuscursalOperadora,cChqProcesado,cChqCompensacion,cChqTransaccion,
				cChqCodSeguridad,cChqDigVerPre,cChqDigVerInter,cIndImgCheque,iTamAnversoImagen,iTamReversoImagen,cTransaccion,
				cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso,
				iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), iNoChequesValidos,NVL(mMontoTotalValido, 0.0),
				iNoImagenes, dFechaHabilProx, dFechaHabilAnt1, dFechaHabilAnt2;

		ELIF pBandera = '2' THEN
			EXECUTE PROCEDURE "informix".sp_aplicadevol_cod41_ccep(pUsuario, pIdFuncion, pImporteTotal, pDireccionMac)
			INTO cCodRet;
			RETURN cCodRet, bBanDet, importeTotal, iNoRegistros, iTotalValidos, dMontoTotalValido, iNoBloque,  idRowDetalle, cBancoLibrado,
				cDescbancoLibrado,mImporte,cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,
				dFecha,cNoBanco,cProcesado,dFechaHabilAnt,iTotalRegTruncados,cNombreArchivo,bIsChequeDuplicado,cCveBanco,cDescripcionBanco,
				cCuentaReferencia,iNoCheque,mImporte,cCuentaDeposito,cSuscursalOperadora,cChqProcesado,cChqCompensacion,cChqTransaccion,
				cChqCodSeguridad,cChqDigVerPre,cChqDigVerInter,cIndImgCheque,iTamAnversoImagen,iTamReversoImagen,cTransaccion,
				cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso,
				iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), iNoChequesValidos,NVL(mMontoTotalValido, 0.0),
				iNoImagenes, dFechaHabilProx, dFechaHabilAnt1, dFechaHabilAnt2;
		--PENDIENTE
		ELIF pBandera = '3' THEN
			EXECUTE PROCEDURE "informix".sp_cargacod41_ccep(pUsuario, pIdFuncion,pnombrearchivo, pRutaArchivo, pDireccionMac)
			INTO cCodRet,bBanDet,importeTotal;
			RETURN cCodRet, bBanDet, importeTotal, iNoRegistros, iTotalValidos, dMontoTotalValido, iNoBloque,  idRowDetalle, cBancoLibrado,
				cDescbancoLibrado,mImporte,cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,
				dFecha,cNoBanco,cProcesado,dFechaHabilAnt,iTotalRegTruncados,cNombreArchivo,bIsChequeDuplicado,cCveBanco,cDescripcionBanco,
				cCuentaReferencia,iNoCheque,mImporte,cCuentaDeposito,cSuscursalOperadora,cChqProcesado,cChqCompensacion,cChqTransaccion,
				cChqCodSeguridad,cChqDigVerPre,cChqDigVerInter,cIndImgCheque,iTamAnversoImagen,iTamReversoImagen,cTransaccion,
				cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso,
				iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), iNoChequesValidos,NVL(mMontoTotalValido, 0.0),
				iNoImagenes, dFechaHabilProx, dFechaHabilAnt1, dFechaHabilAnt2;

		ELIF pBandera = '4' THEN
			EXECUTE PROCEDURE "informix".sp_ccep_eliminacheques_cod46(pUsuario, pIdFuncion, pDireccionMac, pIdsEliminar)
			INTO cCodRet;
			RETURN cCodRet, bBanDet, importeTotal, iNoRegistros, iTotalValidos, dMontoTotalValido, iNoBloque,  idRowDetalle, cBancoLibrado,
				cDescbancoLibrado,mImporte,cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,
				dFecha,cNoBanco,cProcesado,dFechaHabilAnt,iTotalRegTruncados,cNombreArchivo,bIsChequeDuplicado,cCveBanco,cDescripcionBanco,
				cCuentaReferencia,iNoCheque,mImporte,cCuentaDeposito,cSuscursalOperadora,cChqProcesado,cChqCompensacion,cChqTransaccion,
				cChqCodSeguridad,cChqDigVerPre,cChqDigVerInter,cIndImgCheque,iTamAnversoImagen,iTamReversoImagen,cTransaccion,
				cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso,
				iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), iNoChequesValidos,NVL(mMontoTotalValido, 0.0),
				iNoImagenes, dFechaHabilProx, dFechaHabilAnt1, dFechaHabilAnt2;

		ELIF pBandera = '5' THEN
			EXECUTE PROCEDURE "informix".sp_consultachequescod47totales_ccep(pUsuario, pIdFuncion, pFechaHoy, pFechadevol, pDireccionMac)
			INTO cCodRet,iNoRegistros,iTotalValidos,dMontoTotalValido;
			RETURN cCodRet, bBanDet, importeTotal, iNoRegistros, iTotalValidos, dMontoTotalValido, iNoBloque,  idRowDetalle, cBancoLibrado,
				cDescbancoLibrado,mImporte,cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,
				dFecha,cNoBanco,cProcesado,dFechaHabilAnt,iTotalRegTruncados,cNombreArchivo,bIsChequeDuplicado,cCveBanco,cDescripcionBanco,
				cCuentaReferencia,iNoCheque,mImporte,cCuentaDeposito,cSuscursalOperadora,cChqProcesado,cChqCompensacion,cChqTransaccion,
				cChqCodSeguridad,cChqDigVerPre,cChqDigVerInter,cIndImgCheque,iTamAnversoImagen,iTamReversoImagen,cTransaccion,
				cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso,
				iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), iNoChequesValidos,NVL(mMontoTotalValido, 0.0),
				iNoImagenes, dFechaHabilProx, dFechaHabilAnt1, dFechaHabilAnt2;
		ELIF pBandera = '6' THEN
			EXECUTE PROCEDURE "informix".sp_consultadelvorevcod46total_ccep(pUsuario, pIdFuncion, pFechadevol, pFechaHoy, pDireccionMac)
			INTO cCodRet, iTotalValidos,dMontoTotalValido,iNoBloque;
			RETURN cCodRet, bBanDet, importeTotal, iNoRegistros, iTotalValidos, dMontoTotalValido, iNoBloque,  idRowDetalle, cBancoLibrado,
				cDescbancoLibrado,mImporte,cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,
				dFecha,cNoBanco,cProcesado,dFechaHabilAnt,iTotalRegTruncados,cNombreArchivo,bIsChequeDuplicado,cCveBanco,cDescripcionBanco,
				cCuentaReferencia,iNoCheque,mImporte,cCuentaDeposito,cSuscursalOperadora,cChqProcesado,cChqCompensacion,cChqTransaccion,
				cChqCodSeguridad,cChqDigVerPre,cChqDigVerInter,cIndImgCheque,iTamAnversoImagen,iTamReversoImagen,cTransaccion,
				cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso,
				iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), iNoChequesValidos,NVL(mMontoTotalValido, 0.0),
				iNoImagenes, dFechaHabilProx, dFechaHabilAnt1, dFechaHabilAnt2;
		ELIF pBandera = '7' THEN
            FOREACH
			EXECUTE PROCEDURE "informix".sp_consultaprocescod41_ccep(pUsuario, pIdFuncion, pDireccionMac, pRegistros, pRecuperacion)
			INTO cCodRet,idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,cCuentaReferencia,cNumCheque,
				 cCuentaDeposito,cObservaciones, cMotivoDevolucion,cprocesar

			RETURN cCodRet, bBanDet, importeTotal, iNoRegistros, iTotalValidos, dMontoTotalValido, iNoBloque,  idRowDetalle, cBancoLibrado,
				cDescbancoLibrado,mImporte,cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,
				dFecha,cNoBanco,cProcesado,dFechaHabilAnt,iTotalRegTruncados,cNombreArchivo,bIsChequeDuplicado,cCveBanco,cDescripcionBanco,
				cCuentaReferencia,iNoCheque,mImporte,cCuentaDeposito,cSuscursalOperadora,cChqProcesado,cChqCompensacion,cChqTransaccion,
				cChqCodSeguridad,cChqDigVerPre,cChqDigVerInter,cIndImgCheque,iTamAnversoImagen,iTamReversoImagen,cTransaccion,
				cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso,
				iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), iNoChequesValidos,NVL(mMontoTotalValido, 0.0),
				iNoImagenes, dFechaHabilProx, dFechaHabilAnt1, dFechaHabilAnt2 WITH RESUME;
             END FOREACH;

		ELIF pBandera = '8' THEN
			EXECUTE PROCEDURE "informix".sp_datosdiahoy_cod47(pUsuario , pIdFuncion)
			INTO cCodRet,dFecha,cNoBanco,cProcesado,dFechaHabilAnt;
			RETURN cCodRet, bBanDet, importeTotal, iNoRegistros, iTotalValidos, dMontoTotalValido, iNoBloque,  idRowDetalle, cBancoLibrado,
				cDescbancoLibrado,mImporte,cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,
				dFecha,cNoBanco,cProcesado,dFechaHabilAnt,iTotalRegTruncados,cNombreArchivo,bIsChequeDuplicado,cCveBanco,cDescripcionBanco,
				cCuentaReferencia,iNoCheque,mImporte,cCuentaDeposito,cSuscursalOperadora,cChqProcesado,cChqCompensacion,cChqTransaccion,
				cChqCodSeguridad,cChqDigVerPre,cChqDigVerInter,cIndImgCheque,iTamAnversoImagen,iTamReversoImagen,cTransaccion,
				cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso,
				iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), iNoChequesValidos,NVL(mMontoTotalValido, 0.0),
				iNoImagenes, dFechaHabilProx, dFechaHabilAnt1, dFechaHabilAnt2;

		ELIF pBandera = '9' THEN
			EXECUTE PROCEDURE "informix".sp_genera_archivo_presencod46(pUsuario, pIdFuncion, pFechadevol, pFechaHoy, pNoBloque,
														  pNoBanco,pRutaDescarga, pDireccionMac, pIdsPresentados)
			INTO cCodRet,iTotalRegTruncados,cNombreArchivo;	
			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
		ELIF pBandera = '10' THEN
			EXECUTE PROCEDURE "informix".sp_genera_archivo_presencod47(pUsuario, pIdFuncion, pFechaHoy, pNoBloque,
														  pNoBanco,pRutaDescarga, pDireccionMac, pIdsEliminar)
			INTO cCodRet,iTotalRegTruncados,cNombreArchivo;	
			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
		ELIF pBandera = '11' THEN
			EXECUTE PROCEDURE "informix".sp_ope_chequeduplicado(pUsuario , pIdFuncion , pIdCheque , pFecha , pCodigo)
			INTO cCodRet, bIsChequeDuplicado;
			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;

		ELIF pBandera = '12' THEN
			EXECUTE PROCEDURE "informix".sp_ope_consbloquearchivopresentado(pUsuario , pIdFuncion, pIdConsulta )
			INTO cCodRet, iNoBloque;
			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;

		ELIF pBandera = '13' THEN
		FOREACH
			EXECUTE PROCEDURE "informix".sp_ope_consultachequetamdif(pUsuario, pIdFuncion, pDireccionMac, pRegistros, pRecuperacion)
			INTO cCodRet, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion,
				cChqCodSeguridad, cChqDigVerPre, cChqDigVerInter, cIndImgCheque, iTamAnversoImagen,
				iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso
			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2 WITH RESUME;
		END FOREACH;

		ELIF pBandera = '14' THEN
			FOREACH 
			EXECUTE PROCEDURE "informix".sp_ope_consultadetallechequecodigo40(pUsuario, pIdFuncion, pDireccionMac, pRegistros, pRecuperacion)
				INTO cCodRet, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion,
				cChqCodSeguridad, cChqDigVerPre, cChqDigVerInter, cIndImgCheque, iTamAnversoImagen,
				iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, iIdRegistro, cIdStatusProceso
				
				RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
				cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
				iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2 WITH RESUME;
			END FOREACH;
		ELIF pBandera = '15' THEN
			EXECUTE PROCEDURE "informix".sp_ope_consultadetallechequecodigo40_totales(pUsuario , pIdFuncion , pDireccionMac)
			INTO cCodRet, iNoRegistros, iNoDocsIncompletos, mMontoTotalInvalido, iNoChequesValidos, mMontoTotalValido, iNoImagenes;
			LET mMontoTotalInvalido= NVL(mMontoTotalInvalido, 0.0);
			LET mMontoTotalValido = NVL(mMontoTotalValido, 0.0);

			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;

		ELIF pBandera = '16' THEN
			EXECUTE PROCEDURE "informix".sp_ope_datoscarga_genarchivo(pUsuario , pIdFuncion )
			INTO cCodRet, dFechaHabilAnt, cNoBanco;

			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
		ELIF pBandera = '17' THEN
			EXECUTE PROCEDURE "informix".sp_ope_datosgral_archivocod46_ccep(pUsuario , pIdFuncion )
			INTO cCodRet,dFecha,cNoBanco,dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;

			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
		ELIF pBandera = '18' THEN
			EXECUTE PROCEDURE "informix".sp_ope_consultaimportececoban(pUsuario , pIdFuncion)
			INTO cCodRet,importeTotal;

			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
		ELIF pBandera = '19' THEN
			EXECUTE PROCEDURE "informix".sp_ope_validachequeduplicado(pUsuario , pIdFuncion, pRutaDescarga, pNoBanco, pRutaDescarga, pImporteTotal)
			INTO cCodRet,cNombreArchivo,importeTotal;

			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
		ELIF pBandera = '20' THEN
			EXECUTE PROCEDURE "informix".sp_ope_generarchivopresentado(pUsuario , pIdFuncion, pNoBloque, pRutaDescarga, pDireccionMac)
			INTO cCodRet,iTotalRegTruncados,cNombreArchivo;

			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
		ELIF pBandera = '21' THEN
			EXECUTE PROCEDURE "informix".sp_ope_genera_archivo_img_presentado(pUsuario , pIdFuncion, pNoBloque, pRutaDescarga, pDireccionMac, pOpcion)
			INTO cCodRet,cNombreArchivo;

			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
		ELIF pBandera = '22' THEN
			EXECUTE PROCEDURE bditef:"informix".sp_tef_grab_arch_cam(pUsuario, pRegistros, pImporteTotal, pIdRegistro, pnombrearchivo, pRecuperacion, pOpcion)
			INTO cCodRet,cObservaciones;

			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
		ELIF pBandera = '23' THEN
			EXECUTE PROCEDURE "informix".sp_valida_descargaimg_ccep(pUsuario, pIdFuncion, pDireccionMac)
			INTO cCodRet,iNoRegistros, cIdStatusProceso;

			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
		ELIF pBandera = '24' THEN
			EXECUTE PROCEDURE "informix".sp_eliminasinprocesartmpcod40(pUsuario, pIdFuncion, pDireccionMac)
			INTO cCodRet;
			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
		ELIF pBandera = '25' THEN
            FOREACH
			EXECUTE PROCEDURE "informix".sp_ope_consultadetallechequecodigo46(pUsuario, pIdFuncion, pDireccionMac, pRegistros, pRecuperacion)
			INTO cCodRet, iIdRegistro, cNoBanco, cDescripcionBanco, cCuentaReferencia, cNumCheque,
				mImporte, cCuentaDeposito, cTransaccion, cObservaciones, cMotivoDevolucion,
				cIndImgCheque, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cTipoCtaDeposito, cNombreCliente, cRfcCliente, cCurpCliente, cNombreArchivo, iTamAnversoImagen, iTamReversoImagen
				
			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2 WITH RESUME;
            END FOREACH;
		ELIF pBandera = '26' THEN
			EXECUTE PROCEDURE "informix".sp_totalesconsultacod41(pUsuario, pIdFuncion, pDireccionMac)
			INTO cCodRet, iNoRegistros;
				
			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
		ELIF pBandera = '27' THEN
			FOREACH
			EXECUTE PROCEDURE "informix".sp_ope_reportecodigo46(pUsuario, pIdFuncion, pFecha, pRegistros, pRecuperacion) 
			INTO cCodRet, cDescripcionBanco, cCuentaReferencia, cNumCheque, importeTotal, cCuentaDeposito, cNombreCliente, cMotivoDevolucion, cObservaciones
				
			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
            END FOREACH;
		ELIF pBandera = '28' THEN
			FOREACH 
                EXECUTE PROCEDURE "informix".sp_ope_consultadetallechequecodigo47(pUsuario, pIdFuncion, pDireccionMac, pRegistros, pRecuperacion) 
                INTO cCodRet, idRowDetalle, cNoBanco, cDescripcionBanco, cCuentaReferencia, cNumCheque, importeTotal, cCuentaDeposito,
                cObservaciones,cIndImgCheque, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, cTipoCtaDeposito, cNombreArchivo, iTamAnversoImagen, iTamReversoImagen
				
			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2 WITH RESUME;
            END FOREACH;
		ELIF pBandera = '29' THEN
			SELECT fecha_hoy 
			INTO dFecha
			FROM bdicheq:'informix'.sc_fechas
			WHERE empresa = cEmpresa;
			
			RETURN cCodRet,bBanDet,importeTotal,iNoRegistros,iTotalValidos,dMontoTotalValido,iNoBloque, idRowDetalle,cBancoLibrado,cDescbancoLibrado,mImporte,
			cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevolucion,cprocesar,dFecha,cNoBanco,cProcesado,dFechaHabilAnt,
			iTotalRegTruncados,cNombreArchivo, bIsChequeDuplicado, cCveBanco, cDescripcionBanco, cCuentaReferencia, iNoCheque, mImporte,
				cCuentaDeposito, cSuscursalOperadora, cChqProcesado, cChqCompensacion, cChqTransaccion, cChqCodSeguridad, cChqDigVerPre, 
				cChqDigVerInter, cIndImgCheque, iTamAnversoImagen, iTamReversoImagen, cTransaccion, cNombreCliente, cRfcCliente, cCurpCliente, 
				cTipoCtaDeposito, iIdRegistro, cIdStatusProceso, iNoRegistros, iNoDocsIncompletos, NVL(mMontoTotalInvalido, 0.0), 
				iNoChequesValidos, NVL(mMontoTotalValido, 0.0), iNoImagenes, dFechaHabilProx,dFechaHabilAnt,dFechaHabilAnt2;
		END IF;
	END;

END PROCEDURE;
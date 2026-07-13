CREATE PROCEDURE "informix".sp_consultatotalenviospagodinya(pUsuario CHAR(8), pIdFuncion CHAR(10), pConvenio CHAR(3),
					pImporte1 CHAR(16), pImporte2 CHAR (16), pSucursalOrigen CHAR(4), pNombre1Remitente CHAR(26),
					pNombre2Remitente CHAR(26), pApellido1Remitente CHAR(26), pApellido2Remitente CHAR(26), pFechaEnvio1 DATE,
					pFechaEnvio2 DATE, pNombre1Beneficiario CHAR(26), pNombre2Beneneficiario CHAR(26), 
					pApellido1Beneneficiario CHAR(26), pApellido2Beneneficiario CHAR(26))
	RETURNING CHAR(5) AS codret,
				INTEGER AS total_registros;
				
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	-- VARIABLES DEL SP PRODUCTIVO
	DEFINE cNoControl CHAR(12);
	DEFINE dFechaEnvio DATE;
	DEFINE cSucursalOrigen CHAR(4);
	DEFINE cNombre1Remitente CHAR(26);
	DEFINE cNombre2Remitente CHAR(26);
	DEFINE cApellido1Remitente CHAR(26);
	DEFINE cApellido2Remitente CHAR(26);
	DEFINE mImporteEnviado MONEY (16,2);
	DEFINE cStatus CHAR(20);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	-- VARIABLES DEL SP PRODUCTIVO
	LET cNoControl = '';
	LET dFechaEnvio = NULL;
	LET cSucursalOrigen = '';
	LET cNombre1Remitente = '';
	LET cNombre2Remitente = '';
	LET cApellido1Remitente = '';
	LET cApellido2Remitente = '';
	LET mImporteEnviado = NULL;
	LET cStatus = '';

	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultatotalenviospagodinya.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
				RETURN cCodRet, iNoRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH EXECUTE PROCEDURE bdisac:sp_dinya_obtenerenviospagos(pConvenio, pImporte1, pImporte2, pSucursalOrigen,
													pNombre1Remitente, pNombre2Remitente, pApellido1Remitente, pApellido2Remitente,
													pFechaEnvio1, pFechaEnvio2,
													pNombre1Beneficiario, pNombre2Beneneficiario, pApellido1Beneneficiario, pApellido2Beneneficiario)
			INTO cCodRetSp, cNoControl, dFechaEnvio, cSucursalOrigen, cNombre1Remitente, cNombre2Remitente, cApellido1Remitente, cApellido2Remitente, mImporteEnviado, cStatus
			
			IF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP PRODUCTIVO sp_dinya_obtenerenviospagos';
			END IF;
			
			LET iNoRegistros = iNoRegistros + 1;
		
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iNoRegistros;
	
	END;
				
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 05/02/2014',
'DESCRIPCION: Consulta el total de los envios de ordenes de pago',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_obtieneparametrobts(pUsuario CHAR(8), pIdFuncion CHAR(10), pParametro INTEGER)
	RETURNING CHAR(5) AS codret,
			CHAR(100) AS valor_parametro;
			
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cValorParametro CHAR(100);
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iSqlErr = 0;
	LET cValorParametro = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cValorParametro;
		END EXCEPTION;
        
		--SET DEBUG FILE TO '/tmp/mfinis/sp_obtieneparametrobts.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pParametro IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cValorParametro;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cValorParametro;
		END IF;
		
		
		SET ISOLATION TO DIRTY READ;
		EXECUTE PROCEDURE bdisac:"informix".sp_obtieneparametro(pParametro) INTO cCodRetSp, cValorParametro;
		
		IF cCodRetSp::INTEGER < 0 THEN
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdisac:sp_obtieneparametro';
		ELIF cCodRetSp::INTEGER = 1 THEN
			LET cCodRet = '00003';
		END IF;
		
		RETURN cCodRet, cValorParametro;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 10/02/2014',
'DESCRIPCION: Consulta parametros en la base bdisac',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validareferenciabts(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumeroBTS CHAR(11))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iSqlErr INTEGER;
	DEFINE cMensaje CHAR(80);
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iSqlErr = 0;
	LET cMensaje = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_validareferenciabts.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumeroBTS = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		EXECUTE PROCEDURE bdisac:"informix".sp_validabts(pNumeroBTS) INTO cCodRetSp, cMensaje;
		
		IF cCodRetSp::INTEGER < 0 THEN
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bdisac:sp_validabts';
		ELIF cCodRetSp::INTEGER = 1 THEN -- DIGITO VERIFICADOR INVALIDO
			LET cCodRet = '00240';
		ELIF cCodRetSp::INTEGER = 2 THEN -- REFERENCIA DIFERENTE A 11 DIGITOS
			LET cCodRet = '00241';
		ELIF cCodRetSp::INTEGER = 3 THEN -- EL NUMERO DE REFERENCIA CONTIENE UNA LETRA
			LET cCodRet = '00242';
		END IF;
	
		RETURN cCodRet;
	
	END;
		
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde', 
'FECHA: 10/02/2014', 
'DESCRIPCION: Valida si el digito verificador capturado en la consulta de pagos de remesas BTS es correcto',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_encabezadoreportesemanalsac(pUsuario CHAR(8), pIdFuncion CHAR(10), pConvenio CHAR(5))
	RETURNING CHAR(5) AS codigoRetorno,
	CHAR(100) AS encabezado1,
	CHAR(100) AS encabezado2,
	CHAR(100) AS encabezado3,
	CHAR(100) AS encabezado4;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEncabezado1 CHAR(100);
	DEFINE cEncabezado2 CHAR(100);
	DEFINE cEncabezado3 CHAR(100);
	DEFINE cEncabezado4 CHAR(100);
	DEFINE cValor1 CHAR(5);
	DEFINE cValor2 CHAR(5);
	DEFINE cValor3 CHAR(5);
	DEFINE cValor4 CHAR(5);
	DEFINE iNumRows  INTEGER;
	DEFINE cCategoria CHAR(2);
	DEFINE cConvenio CHAR(3);
	DEFINE cDireccionEmpresa CHAR(100);

	LET cCodRet = '00000';
	LET cEncabezado1 = '';
	LET iSqlErr = 0;
	LET cEncabezado1 = '';
	LET cEncabezado2 = '';
	LET cEncabezado3 = '';
	LET cEncabezado4 = '';
	LET cValor1  = '';
	LET cValor2  = '';
	LET cValor3  = '';
	LET cValor4  = '';
	LET iNumRows = 0;
	LET cCategoria = SUBSTRING(pConvenio FROM 1 FOR 2);	LET cConvenio = SUBSTRING(pConvenio FROM 3 FOR 3);	LET cDireccionEmpresa = '';

	BEGIN
		ON EXCEPTION SET iSqlErr
		IF	iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cEncabezado1, cEncabezado2, cEncabezado3, cEncabezado4;
		END IF;
		END EXCEPTION;
		
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_encabezadoreportesemanalsac_TEMP.out';
		--TRACE ON;
		
		IF 	pUsuario = '' OR pIdFuncion = '' OR pConvenio = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cEncabezado1, cEncabezado2, cEncabezado3, cEncabezado4;
		END IF;

		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF	cCodRet <> '00000' THEN
			RETURN cCodRet, cEncabezado1, cEncabezado2, cEncabezado3, cEncabezado4;
		END IF;
		
		SELECT COUNT(*)
		INTO iNumRows
		FROM bdisac:sac_convenios
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;
		IF iNumRows <> 0 THEN
			SELECT nomconvenio, departamento, ciudad, 		estado, 		direccionempresa
			INTO cEncabezado1, 	cEncabezado2, cEncabezado3, cEncabezado4, cDireccionEmpresa
			FROM bdisac:sac_convenios
			WHERE numcategoria = cCategoria
			AND numconvenio = cConvenio;

			SELECT nombreciudad 
			INTO cEncabezado3
			FROM bdinteg:si_catciudades
			WHERE numerociudad = cEncabezado3;
			
			SELECT nombre 
			INTO cEncabezado4
			FROM bdinteg:si_estados
			WHERE estado = cEncabezado4;
			RETURN cCodRet, cEncabezado1, cEncabezado2, TRIM(cDireccionEmpresa)||', '||(cEncabezado3), cEncabezado4;
		ELSE
			LET cCodRet = '00017';
			RETURN cCodRet, cEncabezado1, cEncabezado2, cEncabezado3, cEncabezado4;
		END IF ;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando',
'DescripciÃ³n: SP para los encabezados de los Reportes semanales',
'Fecha: 12/12/2013',
'DB: bdicnweb';

CREATE PROCEDURE "informix".sp_reporteconciliacionconveniosucursal(pUsuario CHAR(8), pIdfuncion CHAR(10), pConvenio CHAR(5), pSucursal CHAR(4), pFechaIni DATE, pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codigoretorno,
	CHAR(4) AS idsucursal,
	INTEGER AS numpagos, 
	CHAR(40) AS nomconvenio, 
	MONEY(16,2) AS importepago, 
	MONEY(16,2) AS importecomisionconvenio,
	MONEY(16,2) AS ivacomisionconvenio, 
	MONEY(16,2) AS importecomisioncte,
	MONEY(16,2) AS iva_comisioncte,
	INTEGER AS flagconfirmacioncentral,
	INTEGER AS flagconfirmacionsucursal;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE cIdSucursal CHAR(5);
	DEFINE cNumPagos INTEGER; 
	DEFINE cNomconvenio CHAR(40); 
	DEFINE mImportePago MONEY(16,2); 
	DEFINE mImporteComisionConvenio MONEY(16,2);
	DEFINE mIvaComisionConvenio MONEY(16,2);
	DEFINE mImporteComisionCte MONEY(16,2);
	DEFINE mIvaComisionCte MONEY(16,2);
	DEFINE iFlagConfirmacionCentral INTEGER;
	DEFINE iFlagConfirmacionSucursal INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iNoRegs  INTEGER;
	DEFINE iRecuperacion  INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cIdSucursal = '';
	LET cNumPagos = 0;
	LET cNomconvenio = '';
	LET mImportePago = 0;
	LET mImporteComisionConvenio = 0;
	LET mIvaComisionConvenio = 0;
	LET mImporteComisionCte = 0;
	LET mIvaComisionCte = 0;
	LET iFlagConfirmacionCentral = 0;
	LET iFlagConfirmacionSucursal = 0;
	LET iRegistros = 0;
	LET iNoRegs = 0;
	LET iRecuperacion = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodret = iSqlErr;
			RETURN cCodRet, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
			mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_reporteconciliacionconveniosucursal.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdfuncion = '' OR LENGTH(pConvenio) <> 5 OR LENGTH(pSucursal) <> 4 OR pFechaIni = '' OR pFechaFin = '' OR pRegistros = '' OR pRecuperacion = ''THEN
			LET cCodret = '00003';
			RETURN cCodRet, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
			mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
		END IF;
		IF pRecuperacion < 0 THEN
			LET cCodret = '00098';
			RETURN cCodRet, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
			mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
		END IF;

		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
			mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH EXECUTE PROCEDURE bdisac:sp_sacreporteconciliacionconveniosucursal(pConvenio, pSucursal, pFechaIni, pFechaFin) INTO
			cCodRetSp, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
			mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal

			IF 	NVL(cIdSucursal, '') = '' AND 
				NVL(cNumPagos, '') = '' AND 
				NVL(cNomconvenio, '')  = '' AND 
				NVL(mImportePago, '') = ''  AND 
				NVL(mImporteComisionConvenio, '') = '' AND
				NVL(mIvaComisionConvenio, '') = '' AND 
				NVL(mImporteComisionCte, '') = '' AND 
				NVL(mIvaComisionCte,'') = '' AND 
				NVL(iFlagConfirmacionCentral,'') = '' AND 
				NVL(iFlagConfirmacionSucursal,'') = '' THEN
				
				LET cCodRet = '00017';
				RETURN cCodRet, '', '', '', 0, 0, 0, 0, 0, 0, 0;
			ELSE
				IF cCodRetSp <> '00000' THEN
					LET cCodRet = cCodRetSp;
					RETURN cCodRet, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio, mImporteComisionCte, mIvaComisionCte,
					iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
				ELSE
					IF iRegistros >= pRegistros THEN
						IF iRecuperacion < pRecuperacion THEN
							LET iRecuperacion = iRecuperacion + 1;
							RETURN cCodRet, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio,
							mIvaComisionConvenio, mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal WITH RESUME;
							LET iNoRegs = iNoRegs + 1;
						END IF;
					END IF;
						LET iRegistros = iRegistros + 1;
				END IF;
			END IF;
		END FOREACH;
		 IF iNoRegs = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, '', '', '', 0, 0, 0, 0, 0, 0, 0;
		ELIF iNoRegs = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, '', '', '', 0, 0, 0, 0, 0, 0, 0;
		END IF;
	END;
END PROCEDURE
DOCUMENT "AUTOR:Esparza Brenis Fernando Martin",
"FECHA: 12/12/2013",
"DESCRIPCION: SP para el reporte de conciliaciÃ³n por convenios",
"DB: bdicnweb";

CREATE PROCEDURE "informix".sp_reporteremesasnoconciliadassac( pUsuario CHAR(8), pIdFuncion CHAR(10),pFechaInicio DATE, pFechaFin DATE,pConvenio CHAR(5),pTipo CHAR(1), 
pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING
	CHAR(5)         AS RetCodigoRet,
	DATE            AS RetFecha,
	INTEGER         AS RetServicios,
	INTEGER         AS RetCheques,
	INTEGER         AS RetWUCaja,
	INTEGER         AS RetAbonoCuenta,
	CHAR(16)    	AS RetDiferencia;
		
	--DEFINICION DE VARIABLES
	DEFINE iSqlError			INTEGER;
	DEFINE cCodRet				CHAR(5);
	DEFINE cCodRetsp			CHAR(5);
	DEFINE dFechaIni			DATE;
	DEFINE iCantidadPagosServ	INTEGER;
	DEFINE iCantidadPagos		INTEGER;
	DEFINE iCantidadPagosREVI   INTEGER;
	DEFINE RetAbonoCuenta		INTEGER;
	DEFINE cDiferencia			CHAR(16);
	DEFINE iRegistros			INTEGER;
	DEFINE iRecuperacion		INTEGER;
	DEFINE iNoRegs				INTEGER;
	DEFINE iNumDias SMALLINT;
	DEFINE iDiasParametrizados SMALLINT;
	
	--INICIALIZAMOS LAS VARIABLES
	LET iSqlError = 0;
	LET cCodRet = '00000';
	LET cCodRetsp = '';
	LET dFechaIni = CURRENT;
	LET iCantidadPagosServ = 0;
	LET iCantidadPagos = 0;
	LET iCantidadPagosREVI  = 0;
	LET RetAbonoCuenta = 0;
	LET cDiferencia ="Sin Diferencia";
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET iNoRegs = 0;
	LET iNumDias = 0;
	LET iDiasParametrizados = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlError
		IF iSqlError <> 0 THEN
			LET cCodRet = iSqlError;
			RETURN cCodRet,dFechaIni,iCantidadPagosServ,iCantidadPagos,iCantidadPagosREVI,RetAbonoCuenta,cDiferencia;
		END IF;
		END EXCEPTION;
		
		IF pUsuario = '' OR pIdFuncion  = '' OR  pFechaInicio  = '' OR  pFechaFin  = '' OR  pConvenio  = '' OR  pTipo  = '' OR  pRegistros  = '' OR  pRecuperacion = '' THEN
			LET cCodRet = '00003'; --Parametros vacios
			RETURN cCodRet,'','','','','','';
		END IF;
		
		--SET DEBUG FILE TO "/tmp/mfinis/bdicnweb/sp_reporteremesasnoconciliadassac.out";
		--TRACE ON;
		
		IF pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,dFechaIni,iCantidadPagosServ,iCantidadPagos,iCantidadPagosREVI,RetAbonoCuenta,cDiferencia;
		END IF;
			
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,dFechaIni,iCantidadPagosServ,iCantidadPagos,iCantidadPagosREVI,RetAbonoCuenta,cDiferencia;
		END IF;
		
		LET iNumDias = pFechaFin - pFechaInicio;
		
		-- Conulta de dias parametrizados
		SELECT valor
		INTO iDiasParametrizados
		FROM bdisac:sac_param WHERE cod_param = 87019;
		
		IF iNumDias >= iDiasParametrizados THEN
			LET cCodRet = '00232';
			RETURN cCodRet,dFechaIni,iCantidadPagosServ,iCantidadPagos,iCantidadPagosREVI,RetAbonoCuenta, cDiferencia;
		ELSE	
			IF pTipo = 'P' THEN -- If tipo o algo asÃ­
				-- Este es un elif
				IF pConvenio = '07004' THEN
					FOREACH EXECUTE PROCEDURE bdisac:sp_sacreportesremesasnoconciliadasbts(pFechaInicio, pFechaFin, pUsuario)
						INTO  cCodRetSp,dFechaIni,iCantidadPagosServ,iCantidadPagos, iCantidadPagosREVI, RetAbonoCuenta, cDiferencia
						IF cCodRetSp = '00000' THEN
							IF iRegistros >=  pRegistros THEN
								IF  iRecuperacion < pRecuperacion THEN
									LET iRecuperacion = iRecuperacion + 1;
									RETURN cCodRet,dFechaIni,iCantidadPagosServ,iCantidadPagos,iCantidadPagosREVI,RetAbonoCuenta, cDiferencia WITH RESUME;
									LET iNoRegs = iNoRegs + 1;
								END IF;
							END IF;
							LET iRegistros = iRegistros + 1;
						ELSE
							LET cCodRet = cCodRetSp;
							RETURN cCodRet,'','','','','','';
						END IF;
					END FOREACH;
				ELIF pConvenio = '07006' OR pConvenio = '07007' OR pConvenio = '07008' THEN	
					FOREACH EXECUTE PROCEDURE bdisac:sp_sacreportesremesasnoconciliadaswu(pFechaInicio, pFechaFin, pUsuario, pConvenio)
						INTO  cCodRetSp,dFechaIni,iCantidadPagosServ,iCantidadPagos, iCantidadPagosREVI, cDiferencia
						IF cCodRetSp = '00000' THEN
							IF iRegistros >=  pRegistros THEN
								IF  iRecuperacion < pRecuperacion THEN
									LET iRecuperacion = iRecuperacion + 1;
									RETURN cCodRet,dFechaIni,iCantidadPagosServ,iCantidadPagos,iCantidadPagosREVI,RetAbonoCuenta, cDiferencia WITH RESUME;
									LET iNoRegs = iNoRegs + 1;
								END IF;
							END IF;
							LET iRegistros = iRegistros + 1;
						ELSE
							LET cCodRet = cCodRetSp;
							RETURN cCodRet,'','','','','','';
						END IF;
					END FOREACH;			
				END IF; -- Del IF pConvenio ... (108)
			ELIF pTipo = 'R' THEN
				IF pConvenio = '07004' THEN
					FOREACH EXECUTE PROCEDURE bdisac:sp_sacreportesremesasnoconciliadasbtsrev(pFechaInicio, pFechaFin, pUsuario)
						INTO  cCodRetSp,dFechaIni,iCantidadPagosServ,iCantidadPagos, iCantidadPagosREVI, cDiferencia
						IF cCodRetSp = '00000' THEN
							IF iRegistros >=  pRegistros THEN
								IF  iRecuperacion < pRecuperacion THEN
									LET iRecuperacion = iRecuperacion + 1;
									RETURN cCodRet,dFechaIni,iCantidadPagosServ,iCantidadPagos,iCantidadPagosREVI,RetAbonoCuenta, cDiferencia WITH RESUME;
									LET iNoRegs = iNoRegs + 1;
								END IF;
							END IF;
							LET iRegistros = iRegistros + 1;
						ELSE
							LET cCodRet = cCodRetSp;
							RETURN cCodRet,'','','','','',''; 
						END IF;
					END FOREACH;
				ELIF pConvenio = '07006' OR pConvenio = '07007' OR pConvenio = '07008' THEN
					FOREACH EXECUTE PROCEDURE bdisac:sp_sacreportesremesasnoconciliadaswurev(pFechaInicio, pFechaFin, pUsuario, pConvenio)
					INTO  cCodRetSp,dFechaIni,iCantidadPagosServ,iCantidadPagos, cDiferencia
						IF cCodRetSp = '00000' THEN
							IF iRegistros >=  pRegistros THEN
								IF  iRecuperacion < pRecuperacion THEN
									LET iRecuperacion = iRecuperacion + 1;
									RETURN cCodRet,dFechaIni,iCantidadPagosServ,iCantidadPagos,iCantidadPagosREVI,RetAbonoCuenta, cDiferencia WITH RESUME;
									LET iNoRegs = iNoRegs + 1;
								END IF;
							END IF;
							LET iRegistros = iRegistros + 1;
						ELSE
							LET cCodRet = cCodRetSp;
							RETURN cCodRet,'','','','','','';
						END IF;
					END FOREACH;
				END IF;
				IF iNoRegs = 0 AND pRegistros = 0 THEN
					LET cCodRet = '00017';
					RETURN cCodRet,dFechaIni,iCantidadPagosServ,iCantidadPagos,iCantidadPagosREVI,RetAbonoCuenta,cDiferencia;
				ELIF iNoRegs = 0 AND pRegistros > 0 THEN
					LET cCodRet = '1001';
					RETURN cCodRet,'','','','','','';
				END IF;
			END IF; -- else del tipo o algo asÃ­
		END IF;			
	END; 
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'DescripciÃ³n: SP para los Reportes de las remesas no conciliadas de SAC',
'Fecha: 2013/12/12',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_sw_ro_buscaxrfc2(pUsuario CHAR(8), pIdFunciON CHAR(10), pIdOficio INT, pIdBusqueda INT, 
										pRfc CHAR(15), pRegistros INT, pRecuperaciON INT, pIp CHAR(15), 
										pMac CHAR(12))
	RETURNING CHAR(5)  AS codret,
			  CHAR(20) AS numerocliente,
			  CHAR(13) AS rfc,
			  CHAR(1)  AS nivelcliente,
			  CHAR(26) AS nombre1,
			  CHAR(26) AS nombre2,
			  CHAR(26) AS ap_paterno,
			  CHAR(26) AS ap_materno,
			  CHAR(60) AS razon_social,
			  CHAR(2)  AS tipo_persona,
			  CHAR(1)  AS tipo_cliente,
			  INT      AS status_busqueda,
			  CHAR(20) AS desc_status_busqueda,
			  INT      AS id_encontrado
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cNumCte CHAR(20);
	DEFINE cNumCta CHAR(20);
	DEFINE cNumTar CHAR(20);
	-- Variables de retorno
	DEFINE cNumeroCliente CHAR(20);
	DEFINE cRfc CHAR(13);
	DEFINE cNivelCliente CHAR(1);
	DEFINE cNombre1 CHAR(26);
	DEFINE cNombre2 CHAR(26);
	DEFINE cApPaterno CHAR(26);
	DEFINE cApMaterno CHAR(26);
	DEFINE cRazonSocial CHAR(60);
	DEFINE iNoRegistros INT;
	DEFINE cEtiqueta CHAR(20);
	DEFINE iStatusBusqueda SMALLINT;
	DEFINE cTipoPersona CHAR(2);
	DEFINE cTipoCliente CHAR(1);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iRegsProc INT;
	DEFINE iIdGenerado INT;
	-- -- -- --
	DEFINE cDescTipoCliente CHAR(40);
	DEFINE dFechaNacimiento DATE;
	DEFINE cSexo CHAR(1);
	DEFINE cDescTipoPersona CHAR(20);
	DEFINE dFechaAlta DATE;
	DEFINE cCveSucursalAltaCte CHAR(4);
	DEFINE cPlazaAlta CHAR(3);
	DEFINE cCveSitEspecial CHAR(5);
	DEFINE cDescSitEspecial CHAR(75);
	DEFINE iSecuencia INT;
	DEFINE cCalle CHAR(40);
	DEFINE cNoExt CHAR(10);
	DEFINE cNoINT CHAR(10);
	DEFINE cDepto CHAR(6);
	DEFINE cColonia CHAR(60);
	DEFINE cDelMun CHAR(60);
	DEFINE cCiudad CHAR(60);
	DEFINE cEstado CHAR(30);
	DEFINE cPais CHAR(20);
	DEFINE cCodPostal CHAR(5);
	DEFINE cTelParticular CHAR(13);
	DEFINE cTelCelular CHAR(13);
	DEFINE cTelOficina CHAR(13);
	DEFINE cExt CHAR(5);
	DEFINE iNivelCliente INT;
	DEFINE iNivel INT;
	DEFINE cDescNivelCliente CHAR(60);
	DEFINE cTipoCuenta CHAR(2);
	DEFINE cTipoBusquedaPersona CHAR(1);
	DEFINE cNoCteRfcAlterno CHAR(20);
	DEFINE cNoCteRfc CHAR(20);
	DEFINE inRfcAlterno SMALLINT;
	DEFINE cBrfc		CHAR(13);
	DEFINE iCuentac		INT;
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cNumeroCliente = '';
	LET cRfc = '';
	LET cNivelCliente = '';
	LET cNombre1 = '';
	LET cNombre2 = '';
	LET cApPaterno = '';
	LET cApMaterno = '';
	LET cRazonSocial = '';
	LET iNoRegistros = 0;
	LET cEtiqueta = 'NO LOCALIZADO';
	LET iStatusBusqueda = 0; -- 0. No encontrado, 1. Encontrado, 2. Homonimo
	LET cTipoPersona = '';
	LET cTipoCliente = '';
	LET cCodRetSp = '';
	LET iRegsProc = 0;
	LET iIdGenerado = 0;
	LET cNumCte = '';
	LET cNumCta = '';
	LET cNumTar = '';
	LET cNoCteRfcAlterno = '';
	LET cNoCteRfc = '';
	LET cDescTipoCliente = '';
	LET dFechaNacimiento = NULL;
	LET cSexo = '';
	LET cDescTipoPersona = '';
	LET dFechaAlta = NULL;
	LET cCveSucursalAltaCte = '';
	LET cPlazaAlta = '';
	LET cCveSitEspecial = '';
	LET cDescSitEspecial = '';
	LET iSecuencia = 0;
	LET cCalle = '';
	LET cNoExt = '';
	LET cNoINT = '';
	LET cDepto = '';
	LET cColonia = '';
	LET cDelMun = '';
	LET cCiudad = '';
	LET cEstado = '';
	LET cPais = '';
	LET cCodPostal = '';
	LET cTelParticular = '';
	LET cTelCelular = '';
	LET cTelOficina = '';
	LET cExt = '';
	LET iNivelCliente = 0;
	LET iNivel = 0;
	LET cDescNivelCliente = '';
	LET cTipoCuenta = '';
	LET inRfcAlterno = 0;
	LET cBrfc='';
	LET iCuentac=0;
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cNumeroCliente, cRfc, cNivelCliente,
						cNombre1, cNombre2, cApPaterno, cApMaterno, 
						cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
						cEtiqueta, 0;
			END IF;
		END EXCEPTION;
		-- Se busca al cliente primero por el rfc alterno
		LET iCuentac=LENGTH(pRfc);
		IF iCuentac=10 THEN
			SET ISOLATION TO DIRTY READ;
			FOREACH
				SELECT {+INDEX (bdinteg:si_cliente idx_cliente_rfc_alterno)} first 2 rfc_alterno
				INTO cBrfc
				FROM bdinteg:si_cliente
				WHERE rfc_alterno [1,10] = pRfc
			END FOREACH;
			LET iNoRegistros = dbinfo("sqlca.sqlerrd2");	
			IF iNoRegistros = 0 THEN
				LET inRfcAlterno = 0;
				SET ISOLATION TO DIRTY READ;
				FOREACH
					SELECT {+INDEX (bdinteg:si_cliente idx_cliente_rfc)} first 2 rfc
					INTO cBrfc
					FROM bdinteg:si_cliente
					WHERE rfc [1,10] = pRfc
			END FOREACH;
			LET iNoRegistros = dbinfo("sqlca.sqlerrd2");	
			ELSE
				LET inRfcAlterno = 1;
			END IF;
		ELSE
			SET ISOLATION TO DIRTY READ;
			FOREACH
				SELECT {+INDEX (bdinteg:si_cliente idx_cliente_rfc_alterno)} first 2 rfc_alterno
				INTO cBrfc
				FROM bdinteg:si_cliente
				WHERE rfc_alterno [1,13] = pRfc
			END FOREACH;
			LET iNoRegistros = dbinfo("sqlca.sqlerrd2");	
			IF iNoRegistros = 0 THEN
				LET inRfcAlterno = 0;
				SET ISOLATION TO DIRTY READ;
				FOREACH
					SELECT {+INDEX (bdinteg:si_cliente idx_cliente_rfc)} first 2 rfc
					INTO cBrfc
					FROM bdinteg:si_cliente
					WHERE rfc [1,13] = pRfc
			END FOREACH;
			LET iNoRegistros = dbinfo("sqlca.sqlerrd2");	
			ELSE
				LET inRfcAlterno = 1;
			END IF;
		END IF;

		IF iNoRegistros = 0 THEN
			EXECUTE PROCEDURE sp_sw_ro_bitacoraresultados(pUsuario, pIdBusqueda, pIdOficio,cApPaterno, 
															cApMaterno, cNombre1, cNombre2, cRazonSocial, 
															pRfc, cNumCte, cNumCta, cNumTar, 
															cTipoCuenta, cTipoCliente, iStatusBusqueda, pIp, 
															pMac)
			INTO cCodRetSp, iRegsProc;
			IF cCodRetSp <> '00000' THEN
				RETURN cCodRetSp, cNumCte, pRfc, cNivelCliente, 
						cNombre1, cNombre2, cApPaterno, cApMaterno, 
						cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
						cEtiqueta, 0;
			END IF;
			LET cCodRet = '00000';
			LET cNivelCliente = '9';
			RETURN cCodRet, cNumCte, pRfc, cNivelCliente, 
					cNombre1, cNombre2, cApPaterno, cApMaterno, 
					cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
					cEtiqueta, 0;
		ELIF iNoRegistros > 1 THEN
			LET iNivelCliente = 9; -- Falta buscar el nivel del cliente
			LET iStatusBusqueda = 2;
			LET cNivelCliente = iNivelCliente;
			LET cEtiqueta = 'HOMONIMO';
			LET iNoRegistros = 0;
			IF inRfcAlterno = 1 THEN
					EXECUTE PROCEDURE sp_sw_ro_bitacoraresultados(pUsuario, pIdBusqueda, pIdOficio, cApPaterno, 
																	cApMaterno, cNombre1, cNombre2, cRazonSocial, 
																	pRfc, cNumeroCliente, cNumCta, cNumTar, 
																	cTipoCuenta, cTipoCliente, iStatusBusqueda, pIp, 
																	pMac)
					INTO cCodRetSp, iRegsProc;
					IF cCodRetSp <> '00000' THEN
						RETURN cCodRetSp, cNumCte, pRfc, cNivelCliente, 
								cNombre1, cNombre2, cApPaterno, cApMaterno, 
								cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
								cEtiqueta, 0;
					END IF;

					RETURN cCodRet, cNumeroCliente, pRfc, cNivelCliente, 
							cNombre1, cNombre2, cApPaterno, cApMaterno, 
							cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
							cEtiqueta, 0;
			ELIF inRfcAlterno = 0 THEN
					EXECUTE PROCEDURE sp_sw_ro_bitacoraresultados(pUsuario, pIdBusqueda, pIdOficio,cApPaterno, 
																	cApMaterno, cNombre1, cNombre2, cRazonSocial, 
																	pRfc, cNumeroCliente, cNumCta, cNumTar, 
																	cTipoCuenta,cTipoCliente, iStatusBusqueda, pIp, 
																	pMac)
					INTO cCodRetSp, iRegsProc;
					IF cCodRetSp <> '00000' THEN
						RETURN cCodRetSp, cNumCte, pRfc, cNivelCliente, 
								cNombre1, cNombre2, cApPaterno, cApMaterno, 
								cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
								cEtiqueta, 0;
					END IF;
					RETURN cCodRet, cNumeroCliente, pRfc, cNivelCliente, 
							cNombre1, cNombre2, cApPaterno, cApMaterno, 
							cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
							cEtiqueta, 0;
			END IF;
		ELIF iNoRegistros = 1 THEN
			IF inRfcAlterno = 1 THEN
				IF iCuentac=10 THEN
					SET ISOLATION TO DIRTY READ;
					SELECT {+INDEX (bdinteg:si_cliente idx_cliente_rfc_alterno)} numcte, rfc_alterno, nombre1, nombre2, 
							apell_paterno, apell_materno, razon_social, tpo_persona, 
							tipo_cliente 
					INTO cNumeroCliente, cRfc,  cNombre1, cNombre2, 
							cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, 
							cTipoCliente
					FROM bdinteg:si_cliente 
					WHERE rfc_alterno [1,10] = pRfc;
				ELSE
					SET ISOLATION TO DIRTY READ;
					SELECT {+INDEX (bdinteg:si_cliente idx_cliente_rfc_alterno)} numcte, rfc_alterno, nombre1, nombre2, 
							apell_paterno, apell_materno, razon_social, tpo_persona, 
							tipo_cliente 
					INTO cNumeroCliente, cRfc,  cNombre1, cNombre2, 
							cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, 
							cTipoCliente
					FROM bdinteg:si_cliente 
					WHERE rfc_alterno [1,13] = pRfc;
				END IF;
			ELIF inRfcAlterno = 0 THEN
				IF iCuentac=10 THEN
					SET ISOLATION TO DIRTY READ;
					SELECT {+INDEX (bdinteg:si_cliente idx_cliente_rfc)} numcte, rfc, nombre1, nombre2, 
							apell_paterno, apell_materno, razon_social, tpo_persona, 
							tipo_cliente 
					INTO cNumeroCliente, cRfc,  cNombre1, cNombre2, 
							cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, 
							cTipoCliente
					FROM bdinteg:si_cliente WHERE rfc [1,10] = pRfc;
				ELSE
					SET ISOLATION TO DIRTY READ;
					SELECT {+INDEX (bdinteg:si_cliente idx_cliente_rfc)} numcte, rfc, nombre1, nombre2, 
							apell_paterno, apell_materno, razon_social, tpo_persona, 
							tipo_cliente 
					INTO cNumeroCliente, cRfc,  cNombre1, cNombre2, 
							cApPaterno, cApMaterno, cRazonSocial, cTipoPersona, 
							cTipoCliente
					FROM bdinteg:si_cliente WHERE rfc [1,13] = pRfc;
				END IF;
			END IF;
			
			EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_valida_nivelacceso_funcionalidad(pUsuario, pIdFunciON) INTO cCodRet, iNivel;
			IF iNivel=0 THEN
				LET cCodRet = '00076';
				RETURN cCodRet, '', '', '', '', '', '', '', '', '', '', '', '', '';
			ELSE
				SELECT NVL(nivel,0) INTO iNivelCliente FROM bdinteg:"informix".si_cliente_nivel WHERE numcte=cNumeroCliente;
				IF  iNivelCliente < iNivel THEN
					LET cCodRet = '00075';
					RETURN cCodRet, '', '', '', '', '', '', '', '', '', '', '', '', '';
				END IF;
			END IF;
			
			LET iNivelCliente = 9; -- Falta buscar el nivel del cliente
			LET iStatusBusqueda = 1;
			LET cNivelCliente = iNivelCliente;
			LET cEtiqueta = 'LOCALIZADO';
			-- Se almacena la busqueda
			EXECUTE PROCEDURE sp_sw_ro_bitacoraresultados(pUsuario, pIdBusqueda, pIdOficio, cApPaterno, 
															cApMaterno, cNombre1, cNombre2, cRazonSocial, 
															cRfc, cNumeroCliente, cNumCta, cNumTar, 
															cTipoCuenta, cTipoCliente, iStatusBusqueda, pIp, 
															pMac)
			INTO cCodRetSp, iIdGenerado;
			IF cCodRetSp <> '00000' THEN
				RETURN cCodRetSp, cNumeroCliente, cRfc, cNivelCliente, 
						cNombre1, cNombre2, cApPaterno, cApMaterno, 
						cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
						cEtiqueta, 0;
			END IF;
			-- Se almacena al cliente encontrado
			EXECUTE PROCEDURE sp_sw_ro_bitacoracteenc(pUsuario, pIdBusqueda, pIdOficio, iIdGenerado, 
														cNumeroCliente, cApPaterno, cApMaterno, cNombre1, 
														cNombre2, cRazonSocial, cRfc, pIp, 
														pMac)
			INTO cCodRetSp, iRegsProc;
			IF cCodRetSp <> '00000' THEN
				RETURN cCodRetSp, cNumeroCliente, cRfc, cNivelCliente, 
						cNombre1, cNombre2, cApPaterno, cApMaterno, 
						cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
						cEtiqueta, 0;
			END IF;
			-- Se buscan las cuentas y participaciones del cliente
			IF cTipoCliente = '1' THEN
				EXECUTE PROCEDURE sp_sw_ro_consctascteparticipacion(pUsuario, pIdFuncion, pIdOficio, pIdBusqueda, 
																	iRegsProc, cNumeroCliente, 10, pIp, 
																	pMac) 
				INTO cCodRetSp;
				IF cCodRetSp <> '00000' THEN
					RETURN cCodRetSp, 'En 1 part', cRfc, cNivelCliente, 
							cNombre1, cNombre2, cApPaterno, cApMaterno, 
							cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
							cEtiqueta, iRegsProc;
				END IF;
			ELIF cTipoCliente = '2' THEN
				EXECUTE PROCEDURE sp_sw_ro_buscaparticipacion(pUsuario, pIdOficio, pIdBusqueda, iRegsProc, 
																cNumeroCliente, pIp, pMac) 
				INTO cCodRetSp;
				IF cCodRetSp <> '00000' THEN
					RETURN cCodRetSp, 'en 2 part', cRfc, cNivelCliente, 
							cNombre1, cNombre2, cApPaterno, cApMaterno, 
							cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
							cEtiqueta, iRegsProc;
				END IF;
			END IF;
			RETURN cCodRet, cNumeroCliente, cRfc, cNivelCliente, 
					cNombre1, cNombre2, cApPaterno, cApMaterno, 
					cRazonSocial, cTipoPersona, cTipoCliente, iStatusBusqueda, 
					cEtiqueta, iRegsProc;
		END IF;
	END
END PROCEDURE;
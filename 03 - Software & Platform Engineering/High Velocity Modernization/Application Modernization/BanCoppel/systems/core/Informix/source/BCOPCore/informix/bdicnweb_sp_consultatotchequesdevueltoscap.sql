CREATE PROCEDURE "informix".sp_consultatotchequesdevueltoscap(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20), pFechaInicial DATE, pFechaFinal DATE, pCausalesDevolucion CHAR(100), pCodigosAlertamiento CHAR(30))
	RETURNING CHAR(5) AS codret,
			INTEGER AS no_registros;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE dFecha DATE;
	DEFINE cCuentaDeposito CHAR(20);
	DEFINE cCodigoAlertamiento CHAR(2);
	DEFINE cDescCodAlertamiento CHAR(35);
	DEFINE cCuentaCheque CHAR(20);
	DEFINE cBancoEmisor CHAR(45);
	DEFINE cNombreBeneficiario CHAR(40);
	DEFINE iNoRegistros INTEGER;
	DEFINE cQuery CHAR(200);
	DEFINE cFromQuery CHAR(450);
	DEFINE cWhereQuery CHAR(500);
	DEFINE cCaracter CHAR(1);
	DEFINE i INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET dFecha = NULL;
	LET cCuentaDeposito = '';
	LET cCodigoAlertamiento = '';
	LET cDescCodAlertamiento = '';
	LET cCuentaCheque = '';
	LET cBancoEmisor = '';
	LET cNombreBeneficiario = '';
	LET iNoRegistros = 0;
	LET cQuery = '';
	LET cFromQuery = '';
	LET cWhereQuery = '';
	LET cCaracter = '';
	LET i = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultatotchequesdevueltoscap.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicial IS NULL OR pFechaFinal IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD	
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_permisosejecutivo (pUsuario, pIdFuncion, pCuenta, '01', 1) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;	
		
		LET cQuery = "SELECT count(*)";
		LET cFromQuery = "FROM ((bditef:cce_cheques_dev a INNER JOIN bditef:cce_detalle b ON b.cuenta_dep = a.cta_deposito AND b.num_cheque = a.numcheque AND MDY(SUBSTRING(b.fecha_presini FROM 5 FOR 2), SUBSTRING(b.fecha_presini FROM 7 FOR 2), SUBSTRING(b.fecha_presini FROM 1 FOR 4))= a.fechapresenta) INNER JOIN bdinteg:si_coddevcam c ON c.codigo = a.motivo) INNER JOIN bdinteg:si_bancos d ON d.banco = a.cvebanco";
		LET cWhereQuery = "WHERE a.cta_deposito = '"||TRIM(pCuenta)||"' AND a.fechapresenta BETWEEN '"||pFechaInicial||"' AND '"||pFechaFinal||"'";
		
		IF pCausalesDevolucion <> '' THEN
			LET cWhereQuery = TRIM(cWhereQuery)||" AND a.motivo IN ('";
			FOR i = 1 TO LENGTH(TRIM(pCausalesDevolucion))
				LET cCaracter = SUBSTR(TRIM(pCausalesDevolucion), i, 1);
				IF cCaracter <> '|' THEN
					LET cWhereQuery = TRIM(cWhereQuery)||cCaracter;
				ELSE
					LET cWhereQuery = TRIM(cWhereQuery)||"', '";
				END IF;
			END FOR;
			
			LET cWhereQuery = TRIM(cWhereQuery)||"')";
		END IF;
		
		IF pCodigosAlertamiento <> '' THEN
			LET cWhereQuery = TRIM(cWhereQuery)||" AND b.alertamiento IN ('";
			FOR i = 1 TO LENGTH(TRIM(pCodigosAlertamiento))
				LET cCaracter = SUBSTR(TRIM(pCodigosAlertamiento), i, 1);
				IF cCaracter <> '|' THEN
					LET cWhereQuery = TRIM(cWhereQuery)||cCaracter;
				ELSE
					LET cWhereQuery = TRIM(cWhereQuery)||"', '";
				END IF;
			END FOR;
			
			LET cWhereQuery = TRIM(cWhereQuery)||"')";
		END IF;
		
		PREPARE stmtId FROM TRIM(cQuery)||' '||TRIM(cFromQuery)||' '||TRIM(cWhereQuery);
		DECLARE custCur cursor FOR stmtId;
		OPEN custCur;
		
		FETCH custCur INTO iNoRegistros;
		
		CLOSE custCur;
		FREE custCur;
		FREE stmtId;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		RETURN cCodRet, iNoRegistros;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 19/03/2014',
'DESCRIPCION: Consulta el total de los posibles cheques devueltos para la detección de fraudes',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_actualizastatusnvasfuncre(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCredito CHAR(20))
		RETURNING CHAR(5) AS codret;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cMensajeRetorno CHAR(120);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cMensajeRetorno = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_actualizastatusnvasfuncre.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCredito = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_permisosejecutivo(pUsuario, pIdFuncion, pNumCredito, '06', '1') INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		EXECUTE PROCEDURE bdicred:"informix".sp_actualizastatuscred(cEmpresa, pNumCredito)
		INTO cCodRetSp, cMensajeRetorno;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_actualizastatuscred';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00276';
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '00277';
		END IF;
		
		RETURN cCodRet;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 31/03/2014',
'DESCRIPCION: Realizar la actualizacion del estatus de credito de acuerdo al cuadre de credito proporcionado',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultamovtosnvasfuncre(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCredito CHAR(20))
		RETURNING CHAR(5) AS codret,
				CHAR(20) AS numcte,
				CHAR(4) AS sucursal,
				CHAR(2) AS statuscred,
				INTEGER AS plazo,
				DATE AS fechaapertura,
				DATE AS fechavencimiento,
				DECIMAL(9,6) AS tasainteres,
				DECIMAL(9,6) AS tasamoratorios,
				DECIMAL(18,2) AS sdoretenido,
				DECIMAL(18,2) AS sdonoexig,
				DECIMAL(18,2) AS sdocontabmora,
				DECIMAL(18,2) AS sdocapital,
				DECIMAL(18,2) AS sdocapinsoluto,
				DECIMAL(18,2) AS sdomtovdo,
				DECIMAL(18,2) AS mtovdotrasp,
				DECIMAL(18,2) AS mtofinanciado,
				DECIMAL(18,2) AS mtootorgado,
				DECIMAL(18,2) AS captrasnovdo,
				DECIMAL(18,2) AS mtovdoint,
				DECIMAL(18,2) AS mtovdotrasint,
				DECIMAL(18,2) AS inttranoexig,
				CHAR(60) AS desctpocart,
				CHAR(2) AS codtpocred,
				DECIMAL(5,3) AS porciva,
				DECIMAL(18,2) AS moratorio,
				DECIMAL(18,2) AS ivamoratorio,
				DECIMAL(18,2) AS ivaintvenc,
				DECIMAL(18,2) AS interesmes,
				DECIMAL(18,2) AS ivames,
				DECIMAL(18,2) AS totalliquidacion,
				DECIMAL(18,2) AS intmoracope,
				DECIMAL(18,2) AS ivaintmoracope,
				DECIMAL(18,2) AS intmorabase,
				DECIMAL(18,2) AS ivaintmorabase,
				DECIMAL(18,2) AS ivaintmoracopebase,
				DECIMAL(18,2) AS capitaltotal,
				DECIMAL(18,2) AS interesvigente,
				DECIMAL(18,2) AS ivainteresvigente;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cMensajeRetorno CHAR(120);
	DEFINE cEmpresa CHAR(3);
	-- VARIABLES DEL SP
	DEFINE cNumCliente CHAR(20);
	DEFINE cSucursal CHAR(4);
	DEFINE cStatusCred CHAR(2);
	DEFINE iPlazo INTEGER;
	DEFINE dFechaApertura DATE;
	DEFINE dFechaVencimiento DATE;
	DEFINE dTasaInteres DECIMAL(9,6);
	DEFINE dTasaMoratorios DECIMAL(9,6);
	DEFINE dSdoRetenido DECIMAL(18,2);
	DEFINE dSdoNoExig DECIMAL(18,2);
	DEFINE dSdoContabMora DECIMAL(18,2);
	DEFINE dSdoCapital DECIMAL(18,2);
	DEFINE dSdoCapInsoluto DECIMAL(18,2);
	DEFINE dSdoMtoVdo DECIMAL(18,2);
	DEFINE dMtoVdoTrasp DECIMAL(18,2);
	DEFINE dMtoFinanciado DECIMAL(18,2);
	DEFINE dMtoOtorgado DECIMAL(18,2);
	DEFINE dCapTrasnoVdo DECIMAL(18,2);
	DEFINE dMtoVdoInt DECIMAL(18,2);
	DEFINE dMtoVdoTrasInt DECIMAL(18,2);
	DEFINE dIntTraNoExig DECIMAL(18,2);
	DEFINE cDescTpoCart CHAR(60);
	DEFINE cCodTpoCred CHAR(2);
	DEFINE dPorcIva DECIMAL(5,3);
	DEFINE dMoratorio DECIMAL(18,2);
	DEFINE dIvaMoratorio DECIMAL(18,2);
	DEFINE dIvaIntVenc DECIMAL(18,2);
	DEFINE dInteresMes DECIMAL(18,2);
	DEFINE dIvaMes DECIMAL(18,2);
	DEFINE dTotalLiquidacion DECIMAL(18,2);
	DEFINE dIntMoraCope DECIMAL(18,2);
	DEFINE dIvaIntMoraCope DECIMAL(18,2);
	DEFINE dIntMoraBase DECIMAL(18,2);
	DEFINE dIvaIntMoraBase DECIMAL(18,2);
	DEFINE dIvaIntMoraCopeBase DECIMAL(18,2);
	DEFINE dCapitalTotal DECIMAL(18,2);
	DEFINE dInteresVigente DECIMAL(18,2);
	DEFINE dIvaInteresVigente DECIMAL(18,2);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cMensajeRetorno = '';
	LET cEmpresa = '001';
	-- VARIABLES DEL SP
	LET cNumCliente = '';
	LET cSucursal = '';
	LET cStatusCred = '';
	LET iPlazo = 0;
	LET dFechaApertura = NULL;
	LET dFechaVencimiento = NULL;
	LET dTasaInteres = NULL;
	LET dTasaMoratorios = NULL;
	LET dSdoRetenido = NULL;
	LET dSdoNoExig = NULL;
	LET dSdoContabMora = NULL;
	LET dSdoCapital = NULL;
	LET dSdoCapInsoluto = NULL;
	LET dSdoMtoVdo = NULL;
	LET dMtoVdoTrasp = NULL;
	LET dMtoFinanciado = NULL;
	LET dMtoOtorgado = NULL;
	LET dCapTrasnoVdo = NULL;
	LET dMtoVdoInt = NULL;
	LET dMtoVdoTrasInt = NULL;
	LET dIntTraNoExig = NULL;
	LET cDescTpoCart = '';
	LET cCodTpoCred = '';
	LET dPorcIva = NULL;
	LET dMoratorio = NULL;
	LET dIvaMoratorio = NULL;
	LET dIvaIntVenc = NULL;
	LET dInteresMes = NULL;
	LET dIvaMes = NULL;
	LET dTotalLiquidacion = NULL;
	LET dIntMoraCope = NULL;
	LET dIvaIntMoraCope = NULL;
	LET dIntMoraBase = NULL;
	LET dIvaIntMoraBase = NULL;
	LET dIvaIntMoraCopeBase = NULL;
	LET dCapitalTotal = NULL;
	LET dInteresVigente = NULL;
	LET dIvaInteresVigente = NULL;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumCliente, cSucursal, cStatusCred, iPlazo, dFechaApertura, dFechaVencimiento, dTasaInteres, dTasaMoratorios, dSdoRetenido, 
					dSdoNoExig, dSdoContabMora, dSdoCapital, dSdoCapInsoluto, dSdoMtoVdo, dMtoVdoTrasp, dMtoFinanciado, dMtoOtorgado, dCapTrasnoVdo, dMtoVdoInt, 
					dMtoVdoTrasInt, dIntTraNoExig, cDescTpoCart, cCodTpoCred, dPorcIva, dMoratorio, dIvaMoratorio, dIvaIntVenc, dInteresMes, dIvaMes, dTotalLiquidacion, 
					dIntMoraCope, dIvaIntMoraCope, dIntMoraBase, dIvaIntMoraBase, dIvaIntMoraCopeBase, dCapitalTotal, dInteresVigente, dIvaInteresVigente;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultamovtosnvasfuncre.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCredito = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumCliente, cSucursal, cStatusCred, iPlazo, dFechaApertura, dFechaVencimiento, dTasaInteres, dTasaMoratorios, dSdoRetenido, 
					dSdoNoExig, dSdoContabMora, dSdoCapital, dSdoCapInsoluto, dSdoMtoVdo, dMtoVdoTrasp, dMtoFinanciado, dMtoOtorgado, dCapTrasnoVdo, dMtoVdoInt, 
					dMtoVdoTrasInt, dIntTraNoExig, cDescTpoCart, cCodTpoCred, dPorcIva, dMoratorio, dIvaMoratorio, dIvaIntVenc, dInteresMes, dIvaMes, dTotalLiquidacion, 
					dIntMoraCope, dIvaIntMoraCope, dIntMoraBase, dIvaIntMoraBase, dIvaIntMoraCopeBase, dCapitalTotal, dInteresVigente, dIvaInteresVigente;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_permisosejecutivo(pUsuario, pIdFuncion, pNumCredito, '06', '1') INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumCliente, cSucursal, cStatusCred, iPlazo, dFechaApertura, dFechaVencimiento, dTasaInteres, dTasaMoratorios, dSdoRetenido, 
					dSdoNoExig, dSdoContabMora, dSdoCapital, dSdoCapInsoluto, dSdoMtoVdo, dMtoVdoTrasp, dMtoFinanciado, dMtoOtorgado, dCapTrasnoVdo, dMtoVdoInt, 
					dMtoVdoTrasInt, dIntTraNoExig, cDescTpoCart, cCodTpoCred, dPorcIva, dMoratorio, dIvaMoratorio, dIvaIntVenc, dInteresMes, dIvaMes, dTotalLiquidacion, 
					dIntMoraCope, dIvaIntMoraCope, dIntMoraBase, dIvaIntMoraBase, dIvaIntMoraCopeBase, dCapitalTotal, dInteresVigente, dIvaInteresVigente;
		END IF;
		
		
		EXECUTE PROCEDURE bdicred:"informix".sp_cargamovtosnvasfunc(cEmpresa, pNumCredito)
		INTO cCodRetSp, cMensajeRetorno, cNumCliente, cSucursal, cStatusCred, iPlazo, dFechaApertura, dFechaVencimiento, dTasaInteres, dTasaMoratorios, 
			dSdoRetenido, dSdoNoExig, dSdoContabMora, dSdoCapital, dSdoCapInsoluto, dSdoMtoVdo, dMtoVdoTrasp, dMtoFinanciado, dMtoOtorgado, dCapTrasnoVdo, 
			dMtoVdoInt, dMtoVdoTrasInt, dIntTraNoExig, cDescTpoCart, cCodTpoCred, dPorcIva, dMoratorio, dIvaMoratorio, dIvaIntVenc, dInteresMes, dIvaMes, 
			dTotalLiquidacion, dIntMoraCope, dIvaIntMoraCope, dIntMoraBase, dIvaIntMoraBase, dIvaIntMoraCopeBase, dCapitalTotal, dInteresVigente, dIvaInteresVigente;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, cMensajeRetorno;
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00003';
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '00009';
		END IF;
		
		RETURN cCodRet, cNumCliente, cSucursal, cStatusCred, iPlazo, dFechaApertura, dFechaVencimiento, dTasaInteres, dTasaMoratorios, dSdoRetenido, 
					dSdoNoExig, dSdoContabMora, dSdoCapital, dSdoCapInsoluto, dSdoMtoVdo, dMtoVdoTrasp, dMtoFinanciado, dMtoOtorgado, dCapTrasnoVdo, dMtoVdoInt, 
					dMtoVdoTrasInt, dIntTraNoExig, cDescTpoCart, cCodTpoCred, dPorcIva, dMoratorio, dIvaMoratorio, dIvaIntVenc, dInteresMes, dIvaMes, dTotalLiquidacion, 
					dIntMoraCope, dIvaIntMoraCope, dIntMoraBase, dIvaIntMoraBase, dIvaIntMoraCopeBase, dCapitalTotal, dInteresVigente, dIvaInteresVigente;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 31/03/2014',
'DESCRIPCION: Consulta de los movimientos de saldos maestros de credito de una cuenta',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_modmaesdoscentralnvasfuncre(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCredito CHAR(20), pTipoSaldo CHAR(2), pQuitaAbono DECIMAL(18,2),
													pCastigoAbono DECIMAL(18,2), pQuebrantoAbono DECIMAL(18,2), pAjusteCargo DECIMAL(18,2), pAjusteAbono DECIMAL(18,2),
													pCondonacionAbono DECIMAL(18,2), pIvaInteresVigente DECIMAL(18,2), pIvaInteresVencido DECIMAL(18,2), pMontoActual DECIMAL(18,2),
													pDescripcionMovimiento CHAR(100))
		RETURNING CHAR(5) AS codret,
				CHAR(80) AS mensaje_retorno,
				DECIMAL(18,2) AS monto_actual,
				DECIMAL(18,2) AS cantidad_actualizar,
				DECIMAL(18,2) AS monto_actual_despues_afectacion,
				CHAR(16) AS folio;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cMensajeretorno CHAR(80);
	DEFINE dMontoActual DECIMAL(18,2);
	DEFINE dCantidadActuaizar DECIMAL(18,2);
	DEFINE dMontoActualDespuesAfectacion DECIMAL(18,2);
	DEFINE cFolio CHAR(16);
	DEFINE bInTransaction BOOLEAN;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cMensajeretorno = '';
	LET dMontoActual = NULL;
	LET dCantidadActuaizar = NULL;
	LET dMontoActualDespuesAfectacion = NULL;
	LET cFolio = '';
	LET bInTransaction = 'f';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			
			IF bInTransaction = 'f' THEN
				BEGIN;
			END IF;
			
			RETURN cCodRet, UPPER(cMensajeretorno), NVL(dMontoActual, 0), NVL(dCantidadActuaizar, 0), NVL(dMontoActualDespuesAfectacion, 0), cFolio;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaction = 't';
			COMMIT WORK;
		END EXCEPTION WITH RESUME;
		
		ON EXCEPTION IN (-255)
			LET bInTransaction = 'f';
		END EXCEPTION WITH RESUME;
		
		BEGIN;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_modmaesdoscentralnvasfuncre.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCredito = '' OR pTipoSaldo = '' OR pAjusteCargo IS NULL OR pAjusteAbono IS NULL OR 
				pCondonacionAbono IS NULL OR pIvaInteresVigente IS NULL OR 
				pIvaInteresVencido IS NULL OR pMontoActual IS NULL THEN
			LET cCodRet = '00003';
			
			IF bInTransaction THEN
				BEGIN WORK;
			ELSE
				ROLLBACK;
			END IF;
			
			RETURN cCodRet, UPPER(cMensajeretorno), NVL(dMontoActual, 0), NVL(dCantidadActuaizar, 0), NVL(dMontoActualDespuesAfectacion, 0), cFolio;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_permisosejecutivo(pUsuario, pIdFuncion, pNumCredito, '06', '1') INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, UPPER(cMensajeretorno), NVL(dMontoActual, 0), NVL(dCantidadActuaizar, 0), NVL(dMontoActualDespuesAfectacion, 0), cFolio;
		END IF;
		
		EXECUTE PROCEDURE bdicred:"informix".sp_modmaesdos_central(cEmpresa, pNumCredito, pTipoSaldo, pQuitaAbono, pCastigoAbono, pQuebrantoAbono, pAjusteCargo, pAjusteAbono, 
															pCondonacionAbono, pIvaInteresVigente, pIvaInteresVencido, pMontoActual, pDescripcionMovimiento, pUsuario, '')
		INTO cCodRetSp, cMensajeretorno, dMontoActual, dCantidadActuaizar, dMontoActual, cFolio;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_modmaesdos_central';
		ELIF iCodRetSp > 0 THEN
			LET cCodRet = '90000';
		END IF;
		
		IF bInTransaction THEN
			BEGIN;
		END IF;
		
		IF bInTransaction = 'f' THEN
			BEGIN;
		END IF;
		
		RETURN cCodRet, UPPER(cMensajeretorno), NVL(dMontoActual, 0), NVL(dCantidadActuaizar, 0), NVL(dMontoActualDespuesAfectacion, 0), cFolio;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 31/03/2014',
'DESCRIPCION: Actualiza los saldos de capital en el maestro de saldos de credito',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultahuellascte(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4), pNumCliente CHAR(20))
		RETURNING CHAR(5) AS codret,
				CHAR(942) AS mapad,
				CHAR(942) AS mapai;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cHuellaDerecha CHAR(942);
	DEFINE cHuellaIzquierda CHAR(942);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cHuellaDerecha = '';
	LET cHuellaIzquierda = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cHuellaDerecha, cHuellaIzquierda;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultahuellascte.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSucursal = '' OR pNumCliente = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cHuellaDerecha, cHuellaIzquierda;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cHuellaDerecha, cHuellaIzquierda;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_conhuella(cEmpresa, pSucursal, pUsuario, pNumCliente)
		INTO cCodRetSp, cHuellaDerecha, cHuellaIzquierda;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_conhuella';
		ELIF iCodRetSp = 110 THEN
			LET cCodRet = '00003';
		ELIF iCodRetSp = 112 THEN
			LET cCodRet = '00006';
		ELIF iCodRetSp = 132 THEN
			LET cCodRet = '00312';
		END IF;
		
		RETURN cCodRet, cHuellaDerecha, cHuellaIzquierda;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 18/06/2014',
'DESCRIPCION: Consulta las huellas de un cliente fÃ­sico',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_guardacausaimpresionedocta(pUsuario CHAR(8), pIdFuncion CHAR(10), pNoCliente CHAR(20), pNoCuenta CHAR(20), pSistemaCuenta CHAR(2), pIdMotivo INTEGER)
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iRegs INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iRegs = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_guardacausaimpresionedocta.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNoCliente = '' OR pNoCuenta = '' OR pSistemaCuenta = '' OR pIdMotivo IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		INSERT INTO "informix".kw_motivos_impresion_cfdi(cliente, cuenta, sistema_cuenta, id_motivo)
		VALUES (pNoCliente, pNoCuenta, pSistemaCuenta, pIdMotivo);
		
		LET iRegs = DBINFO('sqlca.sqlerrd2');
		IF iRegs = 0 THEN
			LET cCodRet = '00282';
		END IF;
		
		RETURN cCodRet;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 23/07/2014',
'DESCRIPCION: Guarda el motivo de impresiÃ³n de un estado de cuenta CFDI en el kiosko',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultaperiodosreportesespecialesac(pUsuario CHAR(8), pIdFuncion CHAR(10), pConvenio CHAR(5),  pTipoPeriodo CHAR(1)) --S => Semanal, M => Mensual
	RETURNING CHAR(5) AS codigoRetorno,
	CHAR(10) AS fecIniperiodo,
	CHAR(10) AS fecFinperiodo,
	INTEGER AS consecutivoconvenio;

	DEFINE cCodRet CHAR(5);
	DEFINE isqlerr INTEGER;
	DEFINE cFecIniperiodo CHAR(10);
	DEFINE cFecFinperiodo CHAR(10);
	DEFINE iNumRows INTEGER;
	DEFINE iConsecutivoConvenio INTEGER;
	DEFINE cQuery CHAR(1500);
	DEFINE cTabla CHAR(200);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cFecIniperiodo = '';
	LET cFecFinperiodo = '';
	LET iNumRows = 0;
	LET iConsecutivoConvenio = 0;
	LET cTabla = '';
	LET cQuery = '';

	BEGIN
		ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iConsecutivoConvenio, cFecIniperiodo, cFecFinperiodo;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinissp_consultaperiodosreportesespecialesac.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pConvenio = '' OR pTipoPeriodo = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iConsecutivoConvenio, cFecIniperiodo, cFecFinperiodo;
		END IF;

		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
				RETURN cCodRet, cFecIniperiodo, cFecFinperiodo, iConsecutivoConvenio;
		END IF;

		IF pTipoPeriodo = 'S' THEN --SEMANAL
			SELECT COUNT(id_convenio) INTO iNumRows FROM bdisac:sac_liquidacionsemanal WHERE id_convenio = pConvenio;
			IF iNumRows <> 0 THEN
				FOREACH
					SELECT consecutivo_convenio, to_char(fec_iniperiodo, '%d/%m/%Y'), to_char(fec_finperiodo, '%d/%m/%Y')
					INTO iConsecutivoConvenio, cFecIniperiodo, cFecFinperiodo
					FROM bdisac:sac_liquidacionsemanal WHERE id_convenio =  pConvenio
					RETURN cCodRet, cFecIniperiodo, cFecFinperiodo, iConsecutivoConvenio WITH RESUME;
				END FOREACH;
			ELSE
				LET cCodRet = '00017';
				RETURN cCodRet, cFecIniperiodo, cFecFinperiodo, iConsecutivoConvenio;
			END IF;
		ELIF pTipoPeriodo  = 'M' THEN --MENSUAL
			SELECT COUNT(id_convenio) INTO iNumRows FROM bdisac:sac_liquidacionmensual WHERE id_convenio = pConvenio;
			IF iNumRows <> 0 THEN
				LET cTabla = TRIM(cTabla)||"sac_liquidacionmensual WHERE id_convenio = '"||TRIM(pConvenio)||"'GROUP BY id_convenio, aniomes ORDER BY aniomes;";
			ELIF pConvenio = '06001' THEN
				LET cTabla = ' sac_liquidacionmensualsky GROUP BY 1,2 ORDER BY 2';
			ELIF pConvenio = '06002' THEN
				LET cTabla = 'sac_liquidacionmensualdish GROUP BY 1,2 ORDER BY 2';
				ELIF pConvenio = '06003' THEN
				LET cTabla = 'sac_liquidacionmensualmastv GROUP BY 1,2 ORDER BY 2';
			ELSE
				LET cCodRet = '00017';
				RETURN cCodRet, cFecIniperiodo, cFecFinperiodo, iConsecutivoConvenio;
			END IF;
			LET cQuery = "SELECT DECODE(SUBSTRING(aniomes FROM 5 FOR 2), '01', 'ENERO', '02', 'FEBRERO', '03', 'MARZO',  '04', 'ABRIL', '05', 'MAYO',";
			LET cQuery = TRIM(cQuery)||" '06', 'JUNIO', '07', 'JULIO', '08', 'AGOSTO', '09', 'SEPTIEMBRE', '10', 'OCTUBRE', '11', 'NOVIEMBRE', '12', 'DICIEMBRE')";
			LET cQuery = TRIM(cQuery)||" as periodo, SUBSTRING(aniomes FROM 1 FOR 4) as aniomes";
			LET cQuery = TRIM(cQuery)||" FROM bdisac:"||TRIM(cTabla);

			PREPARE countQry FROM TRIM(cQuery);
			DECLARE countcur CURSOR FOR countQry;
			OPEN countcur;
			FETCH countcur INTO cFecIniperiodo, cFecFinperiodo;
			IF (SQLCODE = 100) THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cFecIniperiodo, cFecFinperiodo, iConsecutivoConvenio;
			END IF;
			WHILE(SQLCODE = 0)
				RETURN cCodRet, iConsecutivoConvenio, cFecIniperiodo, cFecFinperiodo WITH RESUME;
				FETCH countcur INTO cFecIniperiodo, cFecFinperiodo;
			END WHILE
			CLOSE countcur;
			FREE countcur;
			FREE countQry;
		END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martín';

CREATE PROCEDURE "informix".sp_reportesemanalconveniosac(pUsuario CHAR(8), pIdFuncion CHAR(10), pConvenio CHAR (5), pKeyCons INTEGER)
	RETURNING
	CHAR(5) AS codigoRetorno,
	INTEGER AS recLunes,
	INTEGER AS recMartes,
	INTEGER AS recMiercoles,
	INTEGER AS recJueves,
	INTEGER AS recViernes,
	INTEGER AS recSabado,
	INTEGER AS recDomingo,
	MONEY(16,2) AS cobLunes,
	MONEY(16,2) AS cobMartes,
	MONEY(16,2) AS cobMiercoles,
	MONEY(16,2) AS cobJueves,
	MONEY(16,2) AS cobViernes,
	MONEY(16,2) AS cobSabado,
	MONEY(16,2) AS cobDomingo,
	INTEGER AS recEfectivo,
	INTEGER AS recChequemb,
	INTEGER AS recChequeob,
	INTEGER AS recTarcred,
	MONEY(16,2) AS cobEfectivo,
	MONEY(16,2) AS cobCheqmb,
	MONEY(16,2) AS cobCheqob,
	MONEY(16,2) AS cobTarcred,
	MONEY(16,2) AS liqLunes,
	MONEY(16,2) AS liqMartes,
	MONEY(16,2) AS liqMiercoles,
	MONEY(16,2) AS liqJueves,
	MONEY(16,2) AS liqViernes,
	MONEY(16,2) AS liqSabado,
	MONEY(16,2) AS liqDomingo,
	MONEY(16,2) AS aclaraciones,
	MONEY(16,2) AS comision,
	MONEY(16,2) AS ivaComision,
	DATE AS fecIniperiodo,
	DATE AS fecFinperiodo,
	INTEGER AS iKeyx;

	DEFINE cCodRet CHAR (5);
	DEFINE cCodRetSp CHAR (6);
	DEFINE iSqlErr INTEGER;
	DEFINE iNumRows INTEGER;
	DEFINE iRecLunes INTEGER;
	DEFINE iRecMartes INTEGER;
	DEFINE iRecMiercoles INTEGER;
	DEFINE iRecJueves INTEGER;
	DEFINE iRecViernes INTEGER;
	DEFINE iRecSabado INTEGER;
	DEFINE iRecDomingo INTEGER;
	DEFINE mCobLunes MONEY(16,2);
	DEFINE mCobMartes MONEY(16,2);
	DEFINE mCobMiercoles MONEY(16,2);
	DEFINE mCobJueves MONEY(16,2);
	DEFINE mCobViernes MONEY(16,2);
	DEFINE mCobSabado MONEY(16,2);
	DEFINE mCobDomingo MONEY(16,2);
	DEFINE iRecEfectivo INTEGER;
	DEFINE iRecChequemb INTEGER;
	DEFINE iRecChequeob INTEGER;
	DEFINE iRecTarcred INTEGER;
	DEFINE mCobEfectivo INTEGER;
	DEFINE mCobCheqmb MONEY(16,2);
	DEFINE mCobCheqob MONEY(16,2);
	DEFINE mCobTarcred MONEY(16,2);
	DEFINE mLiqLunes MONEY(16,2);
	DEFINE mLiqMartes MONEY(16,2);
	DEFINE mLiqMiercoles MONEY(16,2);
	DEFINE mLiqJueves MONEY(16,2);
	DEFINE mLiqViernes MONEY(16,2);
	DEFINE mLiqSabado MONEY(16,2);
	DEFINE mLiqDomingo MONEY(16,2);
	DEFINE mAclaraciones MONEY(16,2);
	DEFINE mComision MONEY(16,2);
	DEFINE mIvaComision MONEY(16,2);
	DEFINE dFecIniPeriodo DATE;
	DEFINE dFecFinPeriodo DATE;
	DEFINE iKeyx INTEGER;

	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iSqlErr = 0;
	LET iNumRows = 0;
	LET iRecLunes  = 0;
	LET iRecMartes  = 0;
	LET iRecMiercoles  = 0;
	LET iRecJueves  = 0;
	LET iRecViernes  = 0;
	LET iRecSabado  = 0;
	LET iRecDomingo  = 0;
	LET mCobLunes  = 0;
	LET mCobMartes  = 0;
	LET mCobMiercoles  = 0;
	LET mCobJueves  = 0;
	LET mCobViernes  = 0;
	LET mCobSabado  = 0;
	LET mCobDomingo  = 0;
	LET iRecEfectivo  = 0;
	LET iRecChequemb  = 0;
	LET iRecChequeob  = 0;
	LET iRecTarcred  = 0;
	LET mCobEfectivo  = 0;
	LET mCobCheqmb  = 0;
	LET mCobCheqob  = 0;
	LET mCobTarcred  = 0;
	LET mLiqLunes  = 0;
	LET mLiqMartes  = 0;
	LET mLiqMiercoles  = 0;
	LET mLiqJueves  = 0;
	LET mLiqViernes  = 0;
	LET mLiqSabado  = 0;
	LET mLiqDomingo  = 0;
	LET mAclaraciones  = 0;
	LET mComision  = 0;
	LET mIvaComision  = 0;
	LET dFecIniPeriodo = NULL;
	LET dFecFinPeriodo = NULL;
	LET iKeyx = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
					LET cCodRet = iSqlErr;
					RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes,
					mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred,
					mCobEfectivo, mCobCheqmb, mCobCheqob, mCobTarcred,  mLiqLunes, mLiqMartes, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqSabado, mLiqDomingo, mAclaraciones, mComision, mIvaComision, dFecIniperiodo, dFecFinperiodo, iKeyx;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_reportesemanalconveniosac_dos.out';
		--TRACE ON;

		IF pUsuario = '' OR  pIdFuncion = '' OR pConvenio = '' OR pKeyCons = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes,
				mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred,
				mCobEfectivo, mCobCheqmb, mCobCheqob, mCobTarcred,   mLiqLunes, mLiqMartes, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqSabado, 
				mLiqDomingo, mAclaraciones, mComision, mIvaComision, dFecIniperiodo, dFecFinperiodo, iKeyx;
		END IF;

		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF      cCodRet <> '00000' THEN
				RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes,
				mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred,
				mCobEfectivo, mCobCheqmb, mCobCheqob, mCobTarcred,  mLiqLunes, mLiqMartes, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqSabado, mLiqDomingo, mAclaraciones, mComision, mIvaComision, dFecIniperiodo, dFecFinperiodo, iKeyx;
		END IF;

		SELECT COUNT(*)
		INTO iNumRows
		FROM bdisac:sac_liquidacionsemanal
		WHERE id_convenio = pConvenio AND  consecutivo_convenio  = pKeyCons;
		IF iNumRows <> 0 THEN
			FOREACH
				EXECUTE PROCEDURE bdisac:sp_sacreportesemanal(pConvenio ,pKeyCons)
				INTO cCodRetSp,iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes,
					mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, mCobEfectivo,
						mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqLunes, mLiqMartes, mAclaraciones, mComision,
						mIvaComision, dFecIniPeriodo, dFecFinPeriodo, pKeyCons
					IF cCodRetSp = '000000' THEN
						RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo,
						mCobLunes, mCobMartes,
						mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, 
					iRecChequeob, iRecTarcred, mCobEfectivo, mCobCheqmb, mCobCheqob, mCobTarcred,  mLiqLunes, mLiqMartes, 
						mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqSabado, mLiqDomingo,
						mAclaraciones, mComision, mIvaComision, dFecIniperiodo, dFecFinperiodo, iKeyx WITH RESUME;
					ELSE
						LET cCodRet = cCodRetSp;
						RETURN cCodRet, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0,0, 0, 0, NULL, NULL, 0;
					END IF;
			END FOREACH;
		ELSE
			LET cCodRet = '00017';
			RETURN cCodRet, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0,0, 0, 0, NULL, NULL, 0;
		END IF;
	END;
END PROCEDURE;
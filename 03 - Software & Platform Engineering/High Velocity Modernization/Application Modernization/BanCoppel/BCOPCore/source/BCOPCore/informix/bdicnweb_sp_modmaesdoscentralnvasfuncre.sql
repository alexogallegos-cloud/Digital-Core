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
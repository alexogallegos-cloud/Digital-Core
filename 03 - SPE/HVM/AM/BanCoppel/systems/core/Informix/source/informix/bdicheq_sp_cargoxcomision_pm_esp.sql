CREATE PROCEDURE "informix".sp_cargoxcomision_pm_esp()
RETURNING
	CHAR(6)		AS cod_ret

	---DECLARACIONES
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cCodRet			CHAR(6);

	DEFINE pNumcte			CHAR(20);
	DEFINE pCuenta			CHAR(20);
	DEFINE pProducto		CHAR(4);
	DEFINE pTransacc		CHAR(4);
	DEFINE dSdoPromMen		DECIMAL(18,2);
	DEFINE dMontoAplica		MONEY;
	DEFINE dMtoAplicComis	MONEY;
	DEFINE cAnioMesAnte		CHAR(6);
	DEFINE mValorSdoPos		MONEY;
	DEFINE mDisponible      MONEY(14,2);
	DEFINE cCodRetGF		CHAR(3);
	DEFINE cFolioGF			CHAR(16);
	DEFINE cCodRetCR		CHAR(5);
	DEFINE cComisionCR		CHAR(4);
	DEFINE mIva				MONEY(14,2);
	DEFINE dValIva			DECIMAL(9,6);
	DEFINE mMontoPen		MONEY(14,2);
	DEFINE mMtoCom			MONEY(14,2);
	DEFINE cTranCom         CHAR(4);
	DEFINE vTranIva         CHAR(4);
	DEFINE mSdoPromMM		MONEY;
	DEFINE mComCgoNoSMM		MONEY;
	DEFINE cTpoPersona		CHAR(1);
	DEFINE mComInacCta		MONEY;
	DEFINE dtFecUltDep		DATE;
	DEFINE dtFecUltRet		DATE;
	DEFINE dtFecUltMov		DATE;

	DEFINE iDifDias			INT8;
	DEFINE sBandCtaNva		SMALLINT;
	DEFINE sBandCargo		SMALLINT;
	DEFINE cDescTranRef		CHAR(40);
	DEFINE cDescIvaRef		CHAR(40);
	DEFINE sFecComision		DATE;
	DEFINE mAcumSdoPos		MONEY;
	DEFINE iDiaSdoPos		SMALLINT;
	DEFINE dtFechaHoy		DATE;
	DEFINE dtFechaAlta		DATE;
	DEFINE mServAnualidad	MONEY;
	DEFINE mServAnualPrimCta	MONEY;
    DEFINE dtConsMovhis 	DATE;
    DEFINE dtConsMovhisold 	DATE;
    DEFINE dtConsMovhisold2 DATE;
	DEFINE sBandDetcomis	SMALLINT;
	DEFINE cTranSdoprommm	CHAR(4);
	DEFINE cTranInaccta		CHAR(4);
	DEFINE cTrananuaserv	CHAR(4);
	DEFINE cCtaCargoInaccta	CHAR(20);
	DEFINE cPrimerCta		CHAR(20);
	DEFINE mSaldoCta		MONEY;
	DEFINE iNumCtas			SMALLINT;
	DEFINE cBandCtaValida	CHAR(1);
	DEFINE cBandPrimCtaValida	CHAR(1);
	DEFINE sFecComBit		DATE;
	DEFINE sBandComBit		SMALLINT;
	DEFINE cCodRetCS		CHAR(5);
	DEFINE cStaCtaCS		CHAR(1);




	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cCodRet             = "000000";

	LET pNumcte				= "";
	LET pCuenta				= "";
	LET pProducto			= "";
	LET pTransacc			= "";
	LET dSdoPromMen			= 0.0;
	LET dMontoAplica		= 0.0;
	let dMtoAplicComis		= 0.0;
	LET cAnioMesAnte		= "";
	LET mValorSdoPos		= 0.0;
	LET mDisponible  		= 0;
	LET cCodRetGF			= "000";
	LET cFolioGF			= "";
	LET cCodRetCR			= "000";
	LET cComisionCR			= "";
	LET	mIva				= 0.0;
	LET dValIva				= 0.0;
	LET mMontoPen			= 0.0;
	LET mMtoCom             = 0.0;
	LET cTranCom         	= "";
	LET vTranIva         	= 0.0;
	LET mSdoPromMM			= 0.0;
	LET mComCgoNoSMM		= 0.0;
	LET cTpoPersona			= "";
	LET mComInacCta			= 0.0;
	LET dtFecUltDep			= NULL;
	LET dtFecUltRet			= NULL;
	LET dtFecUltMov			= NULL;
	LET iDifDias			= 0;
	LET sBandCtaNva			= NULL;
	LET sBandCargo			= 0;
	LET cDescTranRef		= "";
	LET cDescIvaRef			= "";
	LET sFecComision		= NULL;
	LET mAcumSdoPos			= 0.0;
	LET iDiaSdoPos			= 0;
	LET dtFechaHoy			= DATE(1);
	LET dtFechaAlta			= DATE(1);
	LET mServAnualidad		= 0.0;
	LET mServAnualPrimCta	= 0.0;
    LET dtConsMovhis 		= DATE(1);
    LET dtConsMovhisold 	= DATE(1);
    LET dtConsMovhisold2 	= DATE(1);
	LET sBandDetcomis		= 0;
	LET cTranSdoprommm		= "";
	LET cTranInaccta		= "";
	LET cTrananuaserv		= "";
	LET cCtaCargoInaccta	= "";
	LET mSaldoCta			= 0.0;
	LET cPrimerCta			= "";
	LET iNumCtas			= 0;
	LET cBandCtaValida		= "0";
	LET cBandPrimCtaValida	= 0;
	LET sFecComBit			= DATE(1);
	LET sBandComBit			= 0;
	LET cCodRetCS			= "000";
	LET cStaCtaCS			= "";


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/moha/sp_cargoxcomision_pm_esp.out';
	--TRACE ON;

	SELECT fecha_hoy
	INTO dtFechaHoy
	FROM "informix".sc_fechas
	WHERE empresa = "001";

	SELECT TRIM(valor)
	INTO cTranSdoprommm
	FROM sc_param
	WHERE empresa = "001"
	AND codparam = 'transdoprommm';

	SELECT TRIM(valor)
	INTO cTranInaccta
	FROM sc_param
	WHERE empresa = "001"
	AND codparam = 'transinaccta1';

	SELECT TRIM(valor)
	INTO cTrananuaserv
	FROM sc_param
	WHERE empresa = "001"
	AND codparam = 'transanuserven';

	--// OBTIENE EL VALOR DEL PARAMETRO DEL IVA
	SELECT TRIM(valor)
	INTO dValIva
	FROM bdinteg:"informix".si_param
	WHERE empresa = "001"
	AND cod_param = 47;

	-- CICLO DE LAS TRANSACCIONES
	FOREACH
		SELECT TRIM(valor)
		INTO pTransacc
		FROM "informix".sc_param
		WHERE empresa = "001"
		AND codparam IN ("transdoprommm","transinaccta1","transanuserven")

		--// OBTIENE EL VALOR DE LA COMISION A COBRAR DE LA TABLA sc_comisiones
		SELECT monto_aplica, transacc_com, transacc_iva
		INTO dMtoAplicComis, cTranCom, vTranIva
		FROM "informix".sc_comisiones
		WHERE empresa = "001"
		AND comision = pTransacc;

		LET dMtoAplicComis = NVL(dMtoAplicComis,0);

		--// CICLO PRINCIPAL DONDE BARRE TODAS LAS CUENTAS DE PERSONA MORAL
		FOREACH
			SELECT mae.cuenta, mae.producto, mae.num_cte, fecultdep, fecultret, pro.sdoprommen, noc.fecha_alta
			INTO pCuenta, pProducto, pNumcte, dtFecUltDep, dtFecUltRet, dSdoPromMen, dtFechaAlta
			FROM "informix".sc_producto pro, "informix".sc_maechq mae, "informix".sc_maenoc noc
			WHERE pro.empresa = "001"
			AND pro.producto = mae.producto
			AND pro.pago_interes = 'M'
			AND mae.empresa = pro.empresa
			AND mae.producto = pro.producto
			AND pro.producto IN ("1600","1200","2200")
			AND mae.status_cta IN ("1","4","5")
			AND noc.empresa = mae.empresa
			AND noc.cuenta = mae.cuenta

			LET sBandCargo = 0;

			IF pTransacc = cTranSdoprommm THEN
				--//////////////////////////////////////////////////////////--
				--// COMISION / CARGO POR NO TENER SALDO PROMEDIO MINIMO MENSUAL
				LET mSdoPromMM = 0.0;
				LET mComCgoNoSMM = 0.0;
				LET mAcumSdoPos	= 0.0;
				LET iDiaSdoPos = 0;

				--// OBTIENE EL SALDO PROMEDIO MENSUAL Y LA COMISION EN LA TABLA MAESTRA DE LAS COMISIONES DE LA CUENTAS DE PERSONAS MORALES
				SELECT sdo_prom_mm, com_cgo_no_smm
				INTO mSdoPromMM, mComCgoNoSMM
				FROM "informix".sc_maecomtasserv_pm
				WHERE num_cte = pNumcte
				AND cuenta = pCuenta;

				IF mSdoPromMM IS NOT NULL THEN
					LET dSdoPromMen = mSdoPromMM;
				ELSE
					LET mSdoPromMM = 0;

				END IF

				IF mComCgoNoSMM IS NOT NULL THEN
					LET dMontoAplica = mComCgoNoSMM;
				ELSE
					LET dMontoAplica = dMtoAplicComis;
				END IF

				IF dMontoAplica = 0 OR pCuenta IN ("12000000602","12000001102","12000000270","12000000963") THEN
					LET sBandCargo = 0;
				ELSE
					-- OBTIENE EL AÃO Y EL MES ANTERIOR
					LET cAnioMesAnte = YEAR(dtFechaHoy - 1 units MONTH) || LPAD(MONTH(dtFechaHoy - 1 units MONTH),2,"0");
					--// OBTIENE EL VALOR ACUMULADO Y EL DIA DEL SALDO POS DE LA CUENTA
					SELECT acum_sdo_pos, dia_sdo_pos
					INTO mAcumSdoPos, iDiaSdoPos
					FROM "informix".sc_maehis
					WHERE aniomes = cAnioMesAnte
					AND cuenta = pCuenta;

					LET mAcumSdoPos = NVL(mAcumSdoPos, 0);
					LET iDiaSdoPos = NVL(iDiaSdoPos, 0);

					IF iDiaSdoPos = 0 THEN
						LET mValorSdoPos = 0;
					ELSE
						LET mValorSdoPos = mAcumSdoPos / iDiaSdoPos;
					END IF

					--// VALIDA SI EL SALDO POS ES MENOR AL SALDO PROMEDIO DE LA sc_producto
					IF mValorSdoPos < dSdoPromMen THEN
						LET sBandCargo = 1;
						LET cDescTranRef = "COMISION X NO TENER SALDO PROMEDIO MENS";
						LET cDescIvaRef = "IVA COMISION X NO TENER SALDO PROM MENS";
					END IF
				END IF
			ELIF pTransacc = cTranInaccta THEN
				--//////////////////////////////////////////////////////////--
				--// COMISION/CARGO POR INACTIVIDAD DE LA CUENTA DURANTE 1 AÃO
				LET mComInacCta = 0;
				LET dtFecUltMov	= NULL;

				SELECT com_ina_cta
				INTO mComInacCta
				FROM "informix".sc_maecomtasserv_pm
				WHERE num_cte = pNumcte
				AND cuenta = pCuenta;

				IF mComInacCta IS NOT NULL THEN
					LET dMontoAplica = mComInacCta;
				ELSE
					LET mComInacCta = 0;
					LET dMontoAplica = dMtoAplicComis;
				END IF

				IF dMontoAplica = 0 THEN
					LET sBandCargo = 0;
				ELSE
					-- VALIDA QUE LA CUENTA TENGA POR LO MENOS UN AÃO DE VIDA
					IF (dtFechaHoy - dtFechaAlta) > 360 THEN

						IF dtFecUltDep IS NULL AND dtFecUltRet IS NULL THEN
							LET sBandCargo = 1;
						ELSE
							IF dtFecUltDep IS NOT NULL THEN
								LET dtFecUltMov = dtFecUltDep;
							END IF

							IF dtFecUltRet IS NOT NULL THEN
								IF dtFecUltRet > dtFecUltMov THEN
									LET dtFecUltMov = dtFecUltRet;
								END IF
							END IF

							IF (dtFechaHoy - dtFecUltMov) < 361 THEN
								LET sBandCargo = 0;
							ELSE
								LET sBandCargo = 1;
								LET cDescTranRef = "COMISION X INACTIVIDAD DE LA CTA 1 AÃO";
								LET cDescIvaRef = "IVA COMISION X INACT DE LA CTA 1 AÃO";
							END IF
						END IF
					END IF
				END IF
			ELIF pTransacc = cTrananuaserv THEN
				--//////////////////////////////////////////////////////////--
				--// COMISION/CARGO POR ANUALIDAD DEL SERVICIO DE EMPRESANET
				LET iDifDias = 0;
				LET sBandCtaNva = NULL;
				LET iNumCtas = 0;
				LET cBandCtaValida = "0";
				LET sFecComBit = DATE(1);
				LET sBandComBit	= 0;
				LET cPrimerCta = "";
				LET mServAnualPrimCta = 0.0;
				LET mServAnualidad = 0.0;
				LET mSaldoCta = 0.0;
				LET cCtaCargoInaccta = "";

				--// OBTIENE EL NUMERO DE DIAS DE LA FECHA ACTUAL RESPECTO A SU FECHA DE REGISTRO
				SELECT dtFechaHoy - f_registro
				INTO iDifDias
				FROM bdibei: "informix".bei_contratacion
				WHERE empresa = "001"
				AND num_cliente = pNumcte
				AND status_contrato = '30';

				IF iDifDias IS NULL THEN
					LET sBandCargo = 0;
				ELSE
					IF iDifDias > 31 AND iDifDias < 361 THEN
						LET sBandCargo = 0;
					ELSE
						IF iDifDias < 32 THEN
							LET sBandCtaNva = 1;
						ELSE
							LET sBandCtaNva = 0;
						END IF

						LET iNumCtas = 0;
						LET cBandCtaValida = "0";
						LET iDifDias = 0;

						SELECT MAX(fecha_gencom)
						INTO sFecComBit
						FROM "informix".sc_bitacora_compm
						WHERE tpo_com = cTrananuaserv
						AND num_cte = pNumcte;

						LET sBandComBit = 0;

						IF sFecComBit IS NOT NULL THEN
							LET iDifDias = dtFechaHoy - sFecComBit;
							IF sBandCtaNva = 1 THEN
								LET sBandComBit = 1;
							ELIF sBandCtaNva = 0 THEN
								IF iDifDias < 361 THEN
									LET sBandComBit = 1;
								END IF
							END IF
						END IF

						IF sBandComBit = 0 THEN
							FOREACH
								SELECT LIMIT 1 cuenta
								INTO cPrimerCta
								FROM bdicheq:"informix".sc_maechq
								WHERE empresa = "001"
								AND num_cte = pNumcte
								ORDER BY cuenta
							END FOREACH

							SELECT serv_anualidad
							INTO mServAnualPrimCta
							FROM "informix".sc_maecomtasserv_pm
							WHERE cuenta = cPrimerCta;

							IF cPrimerCta IS NOT NULL THEN
								-- // OBTIENE EL SALDO DE LA CUENTA
								EXECUTE PROCEDURE "informix".cons_saldo(cPrimerCta)
								INTO cCodRetCS, mSaldoCta, cStaCtaCS;

								LET iNumCtas = 1;

								IF mServAnualPrimCta IS NOT NULL THEN
									LET dMontoAplica = mServAnualPrimCta;
								ELSE
									LET dMontoAplica = dMtoAplicComis;
								END IF

								IF mSaldoCta >= dMontoAplica THEN
									LET cBandPrimCtaValida = 1;
								END IF
							END IF

							IF cBandPrimCtaValida = 1 THEN
								LET pCuenta = cPrimerCta;
							ELSE
								--// SE BARREN LAS CUENTAS DE DEBITO DEL CTE
								FOREACH
									SELECT cuenta, saldo
									INTO cCtaCargoInaccta, mSaldoCta
									FROM
									(
										--RQM 09 704. Se agrega el campo de saldo inmovilizado en el calculo de saldo disponible.DHG
										SELECT t1.cuenta, t1.sdo_actual - (t1.sdo_retenido + t1.sdo_cong + t1.imp_sbg_ccc + t1.saldo_sbc) AS saldo
										FROM "informix".sc_maechq t1, "informix".sc_maenoc t2
										WHERE t1.num_cte = pNumcte
										AND t1.cuenta = t2.cuenta
										AND t1.cuenta <> cPrimerCta
										AND t1.status_cta = "1"
										AND t1.producto IN ("1600","1200","2200")
										ORDER BY t2.fecha_alta
									)

									LET pCuenta = cCtaCargoInaccta;

									LET iNumCtas = iNumCtas + 1;

									IF iNumCtas = 1 THEN
										LET cPrimerCta = cCtaCargoInaccta;
									END IF

									SELECT serv_anualidad
									INTO mServAnualidad
									FROM "informix".sc_maecomtasserv_pm
									WHERE cuenta = pCuenta;

									IF mServAnualPrimCta IS NOT NULL THEN
										LET mServAnualidad = mServAnualPrimCta;
									ELSE
										LET mServAnualPrimCta = 0;
									END IF

									IF mServAnualidad IS NOT NULL THEN
										LET dMontoAplica = mServAnualidad;
									END IF

									IF dMontoAplica > mSaldoCta THEN
										CONTINUE FOREACH;
									ELSE
										LET cBandCtaValida = "1";
										EXIT FOREACH;
									END IF
								END FOREACH
							END IF

							-- VALIDA CUANDO NO HAY CUENTAS ACTIVAS PARA EL CLIENTE
							IF iNumCtas = 0 THEN
								LET sBandCargo = 0;
							ELSE
								IF dMontoAplica > 0 THEN
									LET sBandCargo = 1;
								END IF
							END IF
						END IF
					END IF
				END IF
			END IF

			--// VALIDA SI SE CUMPLEN LAS CONDICIONES PARA SEGUIR CON EL CARGO
			IF sBandCargo = 1 THEN
				LET mDisponible = 0;
				LET mMtoCom = 0.0;
				LET mMontoPen = 0.0;
				LET	mIva = 0.0;
				LET cCodRetGF = "000";
				LET cFolioGF = "";
				LET cCodRetCR = "000";
				LET cComisionCR = "";

				let dMontoAplica = dMontoAplica;

				IF pTransacc = cTrananuaserv THEN
					INSERT INTO "informix".sc_bitacora_compm (tpo_com, num_cte, num_cta, fecha_gencom)
					VALUES (cTrananuaserv, pNumcte, pCuenta, dtFechaHoy);
					LET cDescTranRef = "COMISION X ANUALIDAD SERVICIO EMPRESANET";
					LET cDescIvaRef = "IVA COMISION X ANUALIDAD SERV EMPRESANET";
				END IF

				-- // OBTIENE EL SALDO DE LA CUENTA
				EXECUTE	PROCEDURE "informix".cons_saldo(pCuenta)
				INTO cCodRetCS, mDisponible, cStaCtaCS;

				-- // Aplica Cargo por Comision
				IF mDisponible > 5 THEN
					--// VALIDA SI EL SALDO DISPONIBLE ALCANZA PARA HACER EL COBRO SINO RECALCULA LA COMISION Y EL IVA
					IF mDisponible < (dMontoAplica * (1 + dValIva)) THEN
						LET mMtoCom   = dMontoAplica;
						LET dMontoAplica = ROUND(mDisponible / (1 + dValIva),2);
						LET mMontoPen = mMtoCom - dMontoAplica;
						LET mIva = mDisponible - dMontoAplica;
					ELSE
						LET mIva = TRUNC((dMontoAplica * dValIva),2);
					END IF;
					--// GENERA EL FOLIO DEL MOVIMIENTO
					EXECUTE PROCEDURE "informix".sp_generafolionomina ("informix")
					INTO cCodRetGF, cFolioGF;
					IF cCodRetGF::INTEGER <> 0 THEN
						LET cCodRet = cCodRetGF;
						RETURN cCodRet;
					END IF
					--// GENERA EL CARGO POR EL VALOR DE LA COMISION
					EXECUTE PROCEDURE "informix".cargon_ref("001", "9250", "informix", cTranCom, "0000", cFolioGF, pCuenta, 0, dMontoAplica, "01", cDescTranRef,"","")
					INTO cCodRetCR, cComisionCR;
					IF cCodRetCR::INTEGER <> 0 THEN
						LET cCodRet = cCodRetCR;
						RETURN cCodRet;
					END IF
					--// GENERA EL CARGO POR EL VALOR DEL IVA DE LA COMISION
					EXECUTE PROCEDURE "informix".cargon_ref("001", "9250", "informix", vTranIva, "0000", cFolioGF, pCuenta, 0, mIva, "01", cDescIvaRef,"","")
					INTO cCodRetCR, cComisionCR;
					IF cCodRetCR::INTEGER <> 0 THEN
						LET cCodRet = cCodRetCR;
						RETURN cCodRet;
					END IF
					-- // Registra comision pendiente si es el caso
					IF mMontoPen > 0 THEN
						INSERT INTO "informix".sc_detcomis
						VALUES("001", pCuenta, cTranCom, mMontoPen  , 0, TODAY, "", "P", cFolioGF);

						UPDATE "informix".sc_maechq
						SET com_pendiente =  com_pendiente + mMontoPen
						WHERE empresa = "001"
						AND cuenta  = pCuenta;
					END IF;
				ELSE
					INSERT INTO "informix".sc_detcomis
					VALUES("001", pCuenta, cTranCom, dMontoAplica, 0, TODAY, "", "P", cFolioGF);

					UPDATE "informix".sc_maechq
					SET com_pendiente =  com_pendiente + dMontoAplica
					WHERE empresa = "001"
					AND cuenta  = pCuenta;
				END IF;
			END IF
		END FOREACH
	END FOREACH

	RETURN cCodRet;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para el cargo parametrizado de comisiones para personas morales',
'BD: bdicheq',
'AUTOR: Mohamed CarreÃ³n ',
'FECHA: Octubre 2014',
'MODIFICO: Daniel Hernandez Garcia',
'FECHA: 26-08-2025',
'MODIFICACION: Se modifica la forma de calculo de saldo disponible para considerar un nuevo campo', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDICHEQ',
'VERSION: 1.0.1';

CREATE PROCEDURE "informix".reverprov(pempresa  char(3),
                                      psucursal char(4),
                                      pusuario  char(8),
                                      pfolio    char(16),
                                      ptiporev  char(1),
				      pcuenta   char(20))

   RETURNING char(5);

   DEFINE sql_err             integer;
   DEFINE isam_err            integer;
   DEFINE cod_ret             char(5);
   DEFINE contador            smallint;
   DEFINE wcompend            money(14,2);
   DEFINE wtiptran            char(2);
   DEFINE wnum_serial         integer;
   DEFINE wtransacc           char(4);
   DEFINE wcuenta             char(20);
   DEFINE wmonto_tot          money(14,2);
   DEFINE wmonto_tot1         money(14,2);
   DEFINE montoaux            money(14,2);
   DEFINE wfirme              money(14,2);
   DEFINE wen_sbc             money(14,2);
   DEFINE wremesas            money(14,2);
   DEFINE wdias_ret           smallint;
   DEFINE wnum_cheq           integer;
   DEFINE wimp_sbg_ccc        money(14,2);
   DEFINE wimp_chq_sbg        money(14,2);
   DEFINE wimp_int_ccc        money(14,2);
   DEFINE wimp_int_sbg        money(14,2);
   DEFINE wchq_exp_mes        smallint;
   DEFINE wnaturaleza         char(1);
   DEFINE wvalida_docto       char(1);
   DEFINE wtipo               char(1);
   DEFINE wsaldo_cuenta       money(14,2);
   DEFINE wsdo_actual         money(14,2);
   DEFINE wsdo_retenido       money(14,2);
   DEFINE wsdo_cong           money(14,2);
   DEFINE wmontoaux           money(14,2);
   DEFINE wlim_chq_sbc        money(14,2);
   DEFINE wimp_chq_sbc        money(14,2);
   DEFINE wlim_chq_rem        money(14,2);
   DEFINE wimp_chq_rem        money(14,2);
   DEFINE wreferencia         char(40);
   DEFINE wstatus_envio       char(1);
   DEFINE wrowid              integer;
   DEFINE wfechoy             date;
   DEFINE pfolio1             char(16);
   DEFINE wtpcheque           char(2);
   DEFINE wfechahora          datetime hour to fraction(3);
   DEFINE vtranusoccc         char(4);
   DEFINE vtrancancta         char(4);
   DEFINE vtranintccc         char(4);
   DEFINE vtranusosbg         char(4);
   DEFINE vtranintsbg         char(4);
   DEFINE wcomision           char(4);
   DEFINE wsuc_cuen           char(4);
   DEFINE wproducto           char(4);
   define vnum_tarjeta        char(16);
   define vmaxsec             smallint;
   DEFINE vProdCrec           CHAR(4);
   define vanio               char(6);
   --RQM 09 704. Se agregan las siguientes variable DFTL 
   define mSaldoSbc       MONEY(14,2);
   define cCodRetConsSdo       CHAR(5); --Codigo de retorno de SP de consulta de saldo.
   define cMensajeRetConsSdo   CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
   

   LET sql_err = 0;
   LET cod_ret = "000";
   --RQM 09 704. Se agregan las siguientes variable DFTL
   LET mSaldoSbc           = 0;
   LET cCodRetConsSdo      = '00000';
   LET cMensajeRetConsSdo  = '';


   BEGIN
      ON EXCEPTION
         SET sql_err, isam_err
         IF (sql_err <> 0) THEN
            SET DEBUG FILE TO "reversionch.err";
            TRACE sql_err || " * " || isam_err;
            LET cod_ret = sql_err;
            RETURN cod_ret;
         END IF;
      END EXCEPTION;

      SELECT fecha_hoy into wfechoy
         FROM sc_fechas where empresa = pempresa;

      SELECT TRIM(valor)
        INTO vProdCrec
        FROM sc_param
       WHERE empresa = pempresa
         AND codparam ="PRODCREC";


      SELECT COUNT(*) INTO contador
         FROM sc_movhis m, bdinteg:si_transacc t
         WHERE m.empresa = pempresa and m.cuenta = pcuenta
	       and fech_alt ="01/02/2008"
	       and folio_suc = pfolio and
	       m.cuenta = pcuenta and
               m.empresa = t.empresa and m.transacc = t.numero and
               reversable = "S" and cancelad <> "S";

      IF (contador = 0) THEN
         SELECT COUNT(*) INTO contador
            FROM  sc_docret
            WHERE empresa = pempresa and folio_suc = pfolio and
                  fecha_alta = wfechoy;
         IF (contador = 0) THEN
            RETURN cod_ret;
         ELSE
            update sc_docret
               set cancelado = "S"
               WHERE empresa = pempresa and folio_suc = pfolio and
                     fecha_alta = wfechoy;
            RETURN cod_ret;
         end if
      end if

      select valor into vtrancancta
         from sc_param
         where empresa = pempresa and codparam = "trancancta";

      select valor into vtranusoccc
         from sc_param
         where empresa = pempresa and codparam = "tranusoccc";

      select valor into vtranintccc
         from sc_param
         where empresa = pempresa and codparam = "tranintccc";

      select valor into vtranusosbg
         from sc_param
         where empresa = pempresa and codparam = "tranusosbg";

      select valor into vtranintsbg
         from sc_param
         where empresa = pempresa and codparam = "tranintsbg";

      FOREACH
         select num_serial,transacc,cuenta,monto_tot,firme,en_sbc,remesas,
                md.dias_ret,num_cheq,naturaleza,valida_docto,tr.tipo_tran,
                referencia,suc_cuen,producto, aniomes
            into wnum_serial,wtransacc,wcuenta,wmonto_tot,wfirme,wen_sbc,
                 wremesas,wdias_ret,wnum_cheq,wnaturaleza,wvalida_docto,
                 wtiptran,wreferencia,wsuc_cuen,wproducto, vanio
            FROM sc_movhis md, bdinteg:si_transacc tr
            WHERE md.empresa = pempresa and folio_suc = pfolio and
		  md.cuenta = pcuenta
                  AND cancelad <> "S" and reversable = "S"
                  AND md.empresa = tr.empresa and numero = transacc
	--	  and transacc in ("3276", "3381")
            ORDER BY naturaleza desc
         select max(secuencia) into vmaxsec
            from sc_tarjeta
            where empresa = pempresa and cuenta = wcuenta and
                  tipo_tarjeta = "T";
         select num_tarjeta into vnum_tarjeta
            from sc_tarjeta
            where empresa = pempresa and cuenta = wcuenta and
                  secuencia = vmaxsec;
         LET wimp_sbg_ccc = 0;
         LET wimp_chq_sbg = 0;
         LET wimp_int_ccc = 0;
         LET wimp_int_sbg = 0;
         LET wchq_exp_mes = 0;
         let wcompend = 0;

         IF wtiptran = "01" THEN
            LET wchq_exp_mes  = 1;
         ELIF wtransacc = vtranusoccc THEN
            LET wimp_sbg_ccc = wmonto_tot;
         ELIF wtransacc = vtranusosbg THEN
            LET wimp_chq_sbg = wmonto_tot;
         ELIF wtransacc = vtranintccc THEN
            LET wimp_int_ccc = wmonto_tot;
         ELIF wtransacc = vtranintsbg THEN
            LET wimp_int_sbg = wmonto_tot;
         ELIF wtiptran = "05" THEN
            LET wcompend = wmonto_tot;
            let wcomision = trim(wreferencia);
         END IF;
         select sdo_actual into wsdo_actual
            from sc_maechq
            where empresa = pempresa and cuenta = wcuenta;

         IF wnaturaleza = "C" THEN
            UPDATE sc_maechq
               SET sdo_actual = sdo_actual + wmonto_tot,
                   imp_cgos_mes = imp_cgos_mes - wmonto_tot,
                   num_cgos_mes = num_cgos_mes - 1,
                   chq_exp_mes = chq_exp_mes - wchq_exp_mes,
                   imp_sbg_ccc = imp_sbg_ccc + wimp_sbg_ccc,
                   imp_int_ccc = imp_int_ccc + wimp_int_ccc,
                   imp_chq_sbg = imp_chq_sbg + wimp_chq_sbg,
                   imp_int_sbg = imp_int_sbg + wimp_int_sbg,
                   com_pendiente = com_pendiente + wcompend
               WHERE empresa = pempresa and cuenta = wcuenta;
            if wtransacc = vtrancancta then
               update sc_maechq
                  set status_cta = "1",
                      fec_cancelac = "",
                      motivo = " "
                  WHERE empresa = pempresa and cuenta = wcuenta;
            end if
            if wtiptran = "05" then
               update sc_detcomis
                  set pago_com = pago_com - wmonto_tot,
                      estado_com = "P"
                  where empresa = pempresa and cuenta = wcuenta and
                        comision = wcomision and fecult_pago = wfechoy;
            end if;
            if ptiporev = "A" then
               delete from sc_movhis
                  where num_serial = wnum_serial;
            else
               UPDATE sc_movhis
                  SET cancelad = "S"
                  WHERE num_serial = wnum_serial;
               INSERT INTO sc_movhis
                  VALUES(0,pfolio,psucursal,pusuario,wfechoy,wfechoy,
                      current hour to fraction(3),wtransacc,wsuc_cuen,
                      wproducto,pempresa,wcuenta," ",wnum_cheq,
                      wmonto_tot * -1,0,0,0,0,"S"," ",wsdo_actual,"0000",
                      "REV",0,vnum_tarjeta,"","");
            end if
            IF wtiptran = "01" THEN
               UPDATE sc_contch
                  SET estado = "N",
                      importe = 0
                  WHERE empresa = pempresa and cuenta = wcuenta AND
                        numero = wnum_cheq;
               UPDATE sc_histch
                  SET estado = "N",
                      importe = 0
                  WHERE empresa = pempresa and cuenta = wcuenta AND
                        numero = wnum_cheq;
            END IF;
         ELSE
            IF (wnaturaleza = "A") THEN
               LET wsaldo_cuenta       = 0;
               LET wsdo_actual         = 0;
               LET wsdo_retenido       = 0;
               LET wsdo_cong           = 0;

               SELECT sdo_actual, sdo_retenido, sdo_cong, saldo_sbc
                  INTO wsdo_actual,wsdo_retenido,wsdo_cong, mSaldoSbc
                  FROM sc_maechq
                  WHERE empresa = pempresa and cuenta = wcuenta;

               --RQM 09 704. Se ejecuta el siguiente SP para el calculo del saldo disponible DFTL 
               EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', wsdo_actual, wsdo_retenido, null, mSaldoSbc, null, null, null, 'F', 3)     
               INTO cCodRetConsSdo, cMensajeRetConsSdo, wsaldo_cuenta;

               IF wsaldo_cuenta < wfirme THEN
                  LET cod_ret = "413";
                  RETURN cod_ret;
               END IF;
               UPDATE sc_maechq
                  SET sdo_actual = sdo_actual - wmonto_tot,
                      sdo_retenido= sdo_retenido - wen_sbc,
                      imp_sbg_ccc = imp_sbg_ccc - wimp_sbg_ccc,
                      imp_chq_sbg = imp_chq_sbg - wimp_chq_sbg,
                      num_abonos_mes = num_abonos_mes - 1,
                      imp_abonos_mes = imp_abonos_mes - wmonto_tot
                  WHERE  empresa = pempresa and cuenta = wcuenta;
               if wen_sbc > 0 then
                  update sc_docret
                     set cancelado = "S"
                     where empresa = pempresa and cuenta = wcuenta
                           and folio_suc = pfolio
                           and fecha_alta = wfechoy;
               end if;

	       IF vProdCrec = wproducto THEN
		 UPDATE sc_maechq
		    SET marca_ret = "0"
		  WHERE empresa = pempresa
		    AND cuenta = wcuenta;
	       END IF

               IF (cod_ret = "000") THEN
                  if ptiporev = "A" then
                     delete from sc_movhis
                        where num_serial = wnum_serial;
                  else
                     {UPDATE sc_movhis
                        SET cancelad = "S"
			WHERE cuenta = pcuenta
			  AND fech_alt = "01/02/2008"
                          AND num_serial = wnum_serial;}
                     INSERT INTO sc_movhistmp
                        VALUES(vanio, 0,pfolio,psucursal,pusuario,wfechoy,
			       wfechoy,
                           current hour to fraction(3),wtransacc,wsuc_cuen,
                           wproducto,pempresa,wcuenta," ",wnum_cheq,
                           wmonto_tot * -1,0,0,0,0,"S"," ",wsdo_actual,"0000",
                           "REV",0,vnum_tarjeta,"");
                  end if
               END IF;
            END IF;
         END IF;
      END FOREACH;
   END;
   RETURN cod_ret;
END PROCEDURE DOCUMENT "Version 1.00.000",
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   2025/07/07',
'RAZON:                 Se agrega la nueva variable sdo_sbc (saldo buen cobro)',
'                       a la operacion aritmetica para el nuevo calculo de',
'                       saldo disponible.',
'PROYECTO:              RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdicheq',
'VER:                   1.2';

CREATE PROCEDURE "informix".sp_prog_cierre()
    RETURNING CHAR(5) AS vCodRet1, CHAR(1000) AS vCodRet2, CHAR(1000) AS vCodRet3;

    DEFINE Sql_Err         INTEGER;
    DEFINE Isam_Err        INTEGER;
    DEFINE vCodRet1        CHAR(5);
    DEFINE vCodRet2        CHAR(1000);
    DEFINE vCodRet3        CHAR(1000);
    DEFINE vFechaHoy       DATE;
    DEFINE vTotal          INTEGER;
    DEFINE vOrigen         CHAR(4);
    DEFINE vDestino        CHAR(4);
	DEFINE vOrigen_c       CHAR(4);
    DEFINE vDestino_c      CHAR(4);
    DEFINE vestatus1       INTEGER;
    DEFINE vestatus0       INTEGER;
    DEFINE v_contador      INT;
    DEFINE v_contador2      INT;
    DEFINE iIsamErr        SMALLINT;
    DEFINE cDescErr        CHAR(80);
    DEFINE vsqlerr         INTEGER;
	DEFINE vErrorInfo      CHAR(80);
	DEFINE vstatus		   INTEGER;

    -- Retorno de SP interno
    DEFINE vRetCod         CHAR(5);
    DEFINE vRetMsg         CHAR(1000);
    DEFINE vRetDetalle     CHAR(1000);
    DEFINE vLog            CHAR(1000);
    DEFINE cErrorInfo      CHAR(80);
	DEFINE vstatus_maximo  CHAR(1);

    -- Acumulador de mensajes
    LET Sql_Err    = 0;
    LET Isam_Err   = 0;
    LET vCodRet1   = '00000';
    LET vCodRet2   = 'OPERACION EXITOSA';
    LET vCodRet3   = '';
    LET vLog       = 'No hay sucursales por procesar No hay registros con estatus 0 ni 1.';
    LET vestatus0  = 0;
    LET vestatus1  = 1;
    LET v_contador = 0;
    LET v_contador2 = 0;
    LET iIsamErr   = 0; 
    LET vsqlerr    = 0; 
    LET vErrorInfo = "INICIO DEL PROCESO";
    LET cErrorInfo = "";   


    BEGIN


        ON EXCEPTION SET vsqlerr, iIsamErr, cDescErr
            SET DEBUG FILE TO "/RESPALDOSNEW/sp_control_cierre_sucursal.err";
            TRACE ON;
            IF vsqlerr <> 0 THEN
                LET vCodRet1   = vsqlerr;
                LET vErrorInfo = cErrorInfo;
             RETURN vCodRet1, vCodRet2, vCodRet3;
            END IF;
        END EXCEPTION;

		--SET DEBUG FILE TO "/RESPALDOSNEW/sp_cierre_reproceso.out";
		--TRACE ON;

   
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        SELECT fecha_hoy INTO vFechaHoy
        FROM informix.sc_fechas
        WHERE empresa = '001';
		
		--LET vFechaHoy = '07082025';

        -- Validar si hay registros con estatus 0 o 1
        SELECT COUNT(*) INTO vTotal
        FROM sc_prog_cierre
        WHERE estatus IN (0,1);

        IF vTotal = 0 THEN
            LET vCodRet3 = vLog;
			RETURN vCodRet1, vCodRet2, vCodRet3;
        END IF;

        -- Procesar estatus 0 y fecha = hoy
        SELECT COUNT(*) INTO vTotal
        FROM sc_prog_cierre
        WHERE estatus = 0 AND fecha_proceso = vFechaHoy;

        IF vTotal > 0 THEN
            FOREACH c0 WITH HOLD FOR
                SELECT origen, destino
                INTO vOrigen, vDestino
                FROM sc_prog_cierre
                WHERE estatus = 0 AND fecha_proceso = vFechaHoy

                CALL sp_control_cierre_sucursal(vOrigen, vDestino)
                RETURNING vRetCod,vRetDetalle;
                
                --LET vRetCod = '00000';

                IF vRetCod <> '00000' THEN
					
					IF  vRetCod = -668 THEN
					    
						UPDATE sc_prog_cierre
						SET estatus = '0'
						WHERE origen = vOrigen
						AND destino = vDestino 
						AND fecha_proceso = vFechaHoy;
						
						
						UPDATE bdicheq:sc_ctrl_cierre_suc
						SET 
						extrae_cuentas = '0'  -- Nuevo valor para el campo extrae_cuentas
						WHERE sucursal_origen = vOrigen
						AND sucursal_destino = vDestino;
					
					END  IF;
				
				
					LET vCodRet1 =  vRetCod;
                    LET vCodRet2 = 'DESCRIPCION  cierres con estatus 0 ' || vRetDetalle;
					
                    RETURN vCodRet1, vCodRet2, vCodRet3;
					
                END IF;
                 LET v_contador = v_contador + 1;
            END FOREACH;
            LET vLog =   'Procesados cierres con estatus 0. ' || v_contador;
			
			UPDATE bdicheq:sc_prog_cierre
			SET 
			estatus = '2'  -- se cambia el estatus a 2 si el proceso corrio exitosamente
			WHERE origen = vOrigen
			AND destino = vDestino
			AND fecha_proceso = vFechaHoy;
			
        END IF;

        -- Procesar estatus 1 y fecha = hoy (reproceso)
        SELECT COUNT(*) INTO vTotal
        FROM sc_prog_cierre
        WHERE estatus = 1 AND fecha_proceso = vFechaHoy;

        IF vTotal > 0 THEN
 
			SELECT origen, destino
            INTO vOrigen, vDestino
            FROM sc_prog_cierre
            WHERE estatus = 1 AND fecha_proceso = vFechaHoy;
				
			SELECT 
				MAX(GREATEST(
					NVL(extrae_cuentas, 0),
					NVL(ejecuta_bdicheq, 0),
					NVL(ejecuta_bdibpi, 0),
					NVL(ejecuta_bdicred, 0),
					NVL(ejecuta_bdicred_crd, 0),
					NVL(ejecuta_bdinteg, 0),
					NVL(ejecuta_bdinvers, 0),
					NVL(ejecuta_bdisolic, 0),
					NVL(ejecuta_bdicheq_comp, 0)
				))  AS status_maximo
			INTO vstatus_maximo
			FROM sc_ctrl_cierre_suc
			WHERE sucursal_origen = vOrigen 
    		AND sucursal_destino = vDestino;

			
            LET v_contador = 0;
			
            FOREACH c1 WITH HOLD FOR
                SELECT origen, destino
                INTO vOrigen, vDestino
                FROM sc_prog_cierre
                WHERE estatus = 1 AND fecha_proceso = vFechaHoy
				
                CALL sp_cierre_reproceso(vOrigen, vDestino,vstatus_maximo)
                RETURNING vRetCod, vRetMsg, vRetDetalle, vstatus;

                --LET vRetCod = '00000';

                IF vRetCod <> '00000' THEN

					IF  vRetCod = -668 THEN
					    
						UPDATE sc_prog_cierre
						SET estatus = '0'
						WHERE origen = vOrigen
						AND destino = vDestino 
						AND fecha_proceso = vFechaHoy;

						UPDATE bdicheq:sc_ctrl_cierre_suc
						SET 
						extrae_cuentas = '0'  -- Nuevo valor para el campo extrae_cuentas
						WHERE sucursal_origen = vOrigen
						AND sucursal_destino = vDestino;
					
					END  IF;
					
                    LET vCodRet1 =  vRetCod;
                    LET vCodRet2 = 'DESCRIPCION Reprocesados cierres con estatus 1' || vRetDetalle;
                    LET vCodRet3 = 'Error en el bloque: ' || vstatus;
					
                    RETURN vCodRet1, vCodRet2, vCodRet3;
                END IF;
                LET v_contador = v_contador + 1;
            END FOREACH;
			
			UPDATE bdicheq:sc_prog_cierre
			SET 
			estatus = '2'  -- se cambia el estatus a 2 si el proceso corrio exitosamente 
			WHERE origen = vOrigen
			AND destino = vDestino
			AND fecha_proceso = vFechaHoy;
			
            LET vLog =  'Reprocesados cierres con estatus 1 : ' || v_contador;
        END IF;

        
        -- Resultado final
        LET vCodRet1 = '00000';
        LET vCodRet2 = 'EJECUCION COMPLETA';
        LET vCodRet3 = vLog;

        RETURN vCodRet1, vCodRet2, vCodRet3;

    END;

END PROCEDURE;
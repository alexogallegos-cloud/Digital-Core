CREATE PROCEDURE "informix".sp_reporteliquidacionaxtel(pConvenio CHAR(5))

--DEFINICION DE VARIABLES
DEFINE cCodret           CHAR(5);
DEFINE cCodRet2          CHAR(5);
DEFINE cAnioMes          CHAR(6);
DEFINE cInfoErr          CHAR(100);
DEFINE cCategoria        CHAR(2);
DEFINE cConvenio         CHAR(3);
DEFINE cFechaLiq         CHAR(10);
DEFINE iSqlErr           INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE iRecEfe           INTEGER;
DEFINE iRecEfeAux        CHAR(16);
DEFINE iRecCC            INTEGER;
DEFINE iRecCCAux         CHAR(16);
DEFINE iRecMix           INTEGER;
DEFINE iRecEfeT          INTEGER;
DEFINE iRecCCT           INTEGER;
DEFINE iRecMixT          INTEGER;
DEFINE iRecTot           INTEGER;
DEFINE iRecAux           INTEGER;
DEFINE iRecLun           INTEGER;
DEFINE iRecMAr           INTEGER;
DEFINE iRecMie           INTEGER;
DEFINE iRecJue           INTEGER;
DEFINE iRecVie           INTEGER;
DEFINE iRecSab           INTEGER;
DEFINE iRecDom           INTEGER;
DEFINE iNumOpe           INTEGER;
DEFINE iDias             INTEGER;
DEFINE mLiqlun           MONEY(16,2);
DEFINE mLiqMar           MONEY(16,2);
DEFINE mLiqMier          MONEY(16,2);
DEFINE mLiqJue           MONEY(16,2);
DEFINE mLiqVie           MONEY(16,2);
DEFINE mLiqResguardo     MONEY(16,2);
DEFINE mCobEfe           MONEY(16,2);
DEFINE mCobEfeAux        MONEY(16,2);
DEFINE mCobMix           MONEY(16,2);
DEFINE mCobCC            MONEY(16,2);
DEFINE mCobCCAux         MONEY(16,2);
DEFINE mCobEfeT          MONEY(16,2);
DEFINE mCobMixT          MONEY(16,2);
DEFINE mCobCCT           MONEY(16,2);
DEFINE mCobTot           MONEY(16,2);
DEFINE mCobAux           MONEY(16,2);
DEFINE mCobLun           MONEY(16,2);
DEFINE mCobMar           MONEY(16,2);
DEFINE mCobMie           MONEY(16,2);
DEFINE mCobJue           MONEY(16,2);
DEFINE mCobVie           MONEY(16,2);
DEFINE mCobSab           MONEY(16,2);
DEFINE mCobDom           MONEY(16,2);
DEFINE mTotComision      MONEY(16,2);
DEFINE mTotIvaCom        MONEY(16,2);
DEFINE mComision         MONEY(16,2);
DEFINE mComisionAux      MONEY(16,2);
DEFINE mIvaCom           MONEY(16,2);
DEFINE mIvaComAux        MONEY(16,2);
DEFINE mAcumulado        MONEY(16,2);
DEFINE dFechaAux         DATE;
DEFINE dfecha_Hoy        DATE;
DEFINE dFechaIni         DATE;
DEFINE dPriDiaMes        DATE;
DEFINE dUltDiaMes        DATE;
DEFINE iFlagCen          INTEGER;
DEFINE iFlagSuc          INTEGER;
DEFINE cFolio            CHAR(16);
DEFINE iCuantos          INTEGER;

--INICIALIZACION DE VARIABLES
LET cCodRet2	= "00000";
LET cCodret		= "000000";
LET cInfoErr	= '';
LET cAnioMes	= '';
LET mCobEfe		= 0;
LET mCobEfeAux	= 0;
LET mCobCC		= 0;
LET mCobCCAux	= 0;
LET mCobMix		= 0;
LET iRecEfe		= 0;
LET iRecEfeAux	= '';
LET iRecCC		= 0;
LET iRecCCAux	= '';
LET iRecMix		= 0;
LET mComision	= 0;
LET mComisionAux	= 0;
LET mIvaCom		= 0;
LET mIvaComAux	= 0;
LET mCobEfeT	= 0;
LET mCobCCT		= 0;
LET iRecEfeT	= 0;
LET iRecCCT		= 0;
LET mTotComision	= 0;
LET mTotIvaCom	= 0;
LET iRecLun		= 0;
LET mCobLun		= 0;
LET iRecMar		= 0;
LET mCobMar		= 0;
LET iRecMie		= 0;
LET mCobMie		= 0;
LET iRecJue		= 0;
LET mCobJue		= 0;
LET iRecVie		= 0;
LET mCobVie		= 0;
LET iRecSab		= 0;
LET mCobSab		= 0;
LET iRecDom		= 0;
LET mCobDom		= 0;
LET cCategoria	= SUBSTRING(pConvenio FROM 1 FOR 2);
LET cConvenio	= SUBSTRING(pConvenio FROM 3 FOR 3);
LET dFechaAux	= '';
LET dfecha_Hoy	= '';
LET dFechaIni	= '';
LET dPriDiaMes	= '';
LET dUltDiaMes	= '';
LET iNumOpe		= 0;
LET mLiqlun		= 0;
LET mLiqMar		= 0;
LET mLiqMier	= 0;
LET mLiqJue		= 0;
LET mLiqVie		= 0;
LET cFechaLiq	= "";
LET mLiqResguardo	= 0;
LET mAcumulado	= 0;
LET iFlagCen	= 0;
LET iFlagSuc	= 0;
LET cFolio		= '';
LET iCuantos	= 0;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO '/respaldosbd/hugovaz/sp_reporteliquidacionaxtel.out';
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE "informix".sac_controlreportesespeciales
				SET retorno = cCodRet
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio;
				EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_reporteliquidacionaxtel");
			END IF;
		END EXCEPTION;

		SELECT fecha_hoy, pri_dia_mes, ult_dia_mes
		INTO dfecha_Hoy, dPriDiaMes, dUltDiaMes
		FROM "informix".sac_fechas;

		IF TO_CHAR(dfecha_Hoy,"%A") = "Sunday" THEN

			LET dFechaAux = dfecha_Hoy - 6;
			LET dFechaIni = dFechaAux;

			SELECT NVL(liq_resguardo ,0)
			INTO mAcumulado
			FROM "informix".sac_liquidacionsemanal
			WHERE id_convenio = cCategoria||cConvenio
			AND consecutivo_convenio = (SELECT MAX(consecutivo_convenio)
								FROM "informix".sac_liquidacionsemanal
								WHERE id_convenio = cCategoria||cConvenio
								AND consecutivo_convenio <> 0);

			IF mAcumulado IS NULL THEN
				LET mAcumulado = 0;
			END IF;
			
			WHILE dFechaAux <= dfecha_Hoy

				LET mCobEfe = 0.00;
				LET mCobCC = 0.00;
				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iRecEfe = 0;
				LET iRecCC = 0;

				FOREACH
					SELECT
						NVL(efe,0),
						NVL(cc,0),
						NVL(Rec1,''),
						NVL(Rec2,""),
						NVL(comision, 0),
						NVL(iva_com,0),
						flag_confirmacion_central,
						flag_confirmacion_sucursal,
						folio_suc
					INTO
						mCobEfeAux,
						mCobCCAux,
						iRecEfeAux,
						iRecCCAux,
						mComisionAux,
						mIvaComAux,
						iFlagCen,
						iFlagSuc,
						cFolio
					FROM TABLE(
						MULTISET(
							SELECT importe_comision_convenio AS comision, iva_comision_convenio AS iva_com,
									CASE WHEN forma_pago = 1 THEN NVL(importe_pago, 0) END AS efe,
									CASE WHEN forma_pago = 2 THEN NVL(importe_pago, 0) END AS cc,
									CASE WHEN forma_pago = 1 THEN folio_suc END AS Rec1,
									CASE WHEN forma_pago = 2 THEN folio_suc END AS Rec2,
									flag_confirmacion_central,
									flag_confirmacion_sucursal,
									folio_suc
							FROM "informix".sac_movimientoshistorial
							WHERE numcategoria = cCategoria
							AND numconvenio = cConvenio
							AND fecha_pago  = dFechaAux
							AND status_cancelado = 'N'
							AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)))

					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mCobEfe = mCobEfe + mCobEfeAux;
								LET mCobCC = mCobCC + mCobCCAux;
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
									LET iRecEfe = iRecEfe +1;
								END IF;
								IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
									LET iRecCC = iRecCC +1;
								END IF;
							END IF;
						ELSE
							LET mCobEfe = mCobEfe + mCobEfeAux;
							LET mCobCC = mCobCC + mCobCCAux;
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
								LET iRecEfe = iRecEfe +1;
							END IF;
							IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
								LET iRecCC = iRecCC +1;
							END IF;
						END IF;
					ELSE
						LET mCobEfe = mCobEfe + mCobEfeAux;
						LET mCobCC = mCobCC + mCobCCAux;
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
							LET iRecEfe = iRecEfe +1;
						END IF;
						IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
							LET iRecCC = iRecCC +1;
						END IF;
					END IF;
				END FOREACH;

				LET mCobEfeT = mCobEfeT + mCobEfe;
				LET mCobCCT = mCobCCT + mCobCC;
				LET iRecEfeT = iRecEfeT + iRecEfe ;
				LET iRecCCT = iRecCCT + iRecCC;
				LET mTotComision = mTotComision + mComision;
				LET mTotIvaCom = mTotIvaCom + mIvaCom;

				EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(dFechaAux)
				INTO cCodRet2,cFechaLiq;

				IF CAST(cCodRet2 AS INTEGER) = 0 THEN

					LET iDias =  cFechaLiq::DATE - dFechaAux::DATE;

					IF TO_CHAR(dFechaAux,"%A") = "Monday" THEN
						LET iRecLun = iRecEfe + iRecCC ;
						LET mCobLun = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMar = mLiqMar + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqMar = mLiqMar + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;


					IF TO_CHAR(dFechaAux,"%A") = "Tuesday" THEN
						LET iRecMar = iRecEfe + iRecCC ;
						LET mCobMar = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMier =  mLiqMier + mCobMar;
							IF mAcumulado <> 0 THEN
							    LET mLiqMier = mLiqMier + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Wednesday" THEN
						LET iRecMie = iRecEfe + iRecCC ;
						LET mCobMie = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqJue = mLiqJue + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Thursday" THEN
						LET iRecJue = iRecEfe + iRecCC ;
						LET mCobJue = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqVie = mLiqVie + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Friday"  THEN
						LET iRecVie = iRecEfe + iRecCC ;
						LET mCobVie = mCobEfe + mCobCC ;

						IF iDias >= 1 AND iDias <= 3 THEN
							LET mLiqlun =  mLiqlun + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo =mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
					    END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Saturday"   THEN
						LET iRecSab = iRecEfe + iRecCC ;
						LET mCobSab = mCobEfe + mCobCC ;

						IF iDias >= 1  AND iDias <= 2 THEN
							LET mLiqlun =  mLiqlun + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqlun =mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Sunday" THEN
						LET iRecDom = iRecEfe + iRecCC ;
						LET mCobDom = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqlun =  mLiqlun + mCobDom;

							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobDom;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

				LET dFechaAux = dFechaAux + 1;

				END IF;
			END WHILE;

			IF cCodRet2::INTEGER = 0 THEN

				INSERT INTO "informix".sac_liquidacionsemanal (id_convenio, rec_lunes, rec_martes, 				rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo, cob_lunes, 			 cob_martes, cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo, 			   rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred, cob_efectivo,
							  cob_cheqmb,cob_cheqob, cob_tarcred, liq_lunes, liq_martes, liq_miercoles, liq_jueves, liq_viernes,aclaraciones,comision, iva_comision, fec_iniperiodo, fec_finperiodo, liq_resguardo, consecutivo_convenio, fecha_insert)
				VALUES(cCategoria||cConvenio, iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom, mCobLun, mCobMar, mCobMie, mCobJue, mCobVie, mCobSab, mCobDom,iRecEfeT, iRecCCT,0, 0,  mCobEfeT, mCobCCT, 0, 0,mLiqlun, mLiqMar, mLiqMier, mLiqJue, mLiqVie,0,mTotComision, mTotIvaCom, dFechaIni,dfecha_Hoy, mLiqResguardo,
					  (SELECT NVL(MAX(consecutivo_convenio + 1 ),1) FROM "informix".sac_liquidacionsemanal
					   WHERE id_convenio = cCategoria||cConvenio) , CURRENT);
			END IF;
		END IF;

		IF dfecha_Hoy = dUltDiaMes AND CAST(cCodRet2 AS INTEGER) = 0 THEN
			LET dFechaAux = dPriDiaMes;
			LET cAnioMes = TO_CHAR(dfecha_Hoy,"%Y%m");

			WHILE dFechaAux <= dfecha_Hoy

				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iNumOpe = 0;

				FOREACH
					SELECT NVL(importe_comision_convenio,0),NVL(iva_comision_convenio,0),
						flag_confirmacion_central, flag_confirmacion_sucursal,folio_suc
					INTO mComisionAux, mIvaComAux,iFlagCen,iFlagSuc,cFolio
					FROM bdisac:"informix".sac_movimientoshistorial
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio
					AND fecha_pago  = dFechaAux
					AND status_cancelado = 'N'
					AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)

					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia
						WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis
							WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								LET iNumOpe = iNumOpe + 1;
							END IF;
						ELSE
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							LET iNumOpe = iNumOpe + 1;
						END IF;
					ELSE
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						LET iNumOpe = iNumOpe + 1;
					END IF;

				END FOREACH;

				INSERT INTO "informix".sac_liquidacionmensual(id_convenio, aniomes, fecha, num_operaciones, comision, iva, fecha_insert)
				VALUES(cCategoria||cConvenio, cAnioMes, dFechaAux, iNumOpe, mComision, mIvaCom, CURRENT);

				LET dFechaAux = dFechaAux + 1;
			END WHILE;

		END IF;

		IF CAST(cCodRet2 AS INTEGER) <> 0 THEN
			LET cCodRet = LPAD(TRIM(cCodRet2), 5, '0');
		END IF;

		UPDATE "informix".sac_controlreportesespeciales
		SET retorno = cCodret
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

	END;
END PROCEDURE
DOCUMENT
'AUTOR: EPG',
'DESCRIPCIÓN: Genera la información para los Reportes Semanal y Mensual de Pagos referenciados (AXTEL)',
'EJECUTADO O LLAMADO POR: sp_GeneraInformacionReportesEspeciales(), el cual  es llamado de sp_ProcesoCierreSAC()',
'FECHA: 22-04-2015',
'VERSIÓN: 20140625.1218',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_reporteliquidacioncablemas(pConvenio CHAR(5))

--DEFINICION DE VARIABLES
DEFINE cCodret           CHAR(5);
DEFINE cCodRet2          CHAR(5);
DEFINE cAnioMes          CHAR(6);
DEFINE cInfoErr          CHAR(100);
DEFINE cCategoria        CHAR(2);
DEFINE cConvenio         CHAR(3);
DEFINE cFechaLiq         CHAR(10);
DEFINE iSqlErr           INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE iRecEfe           INTEGER;
DEFINE iRecEfeAux        CHAR(16);
DEFINE iRecCC            INTEGER;
DEFINE iRecCCAux         CHAR(16);
DEFINE iRecMix           INTEGER;
DEFINE iRecEfeT          INTEGER;
DEFINE iRecCCT           INTEGER;
DEFINE iRecMixT          INTEGER;
DEFINE iRecTot           INTEGER;
DEFINE iRecAux           INTEGER;
DEFINE iRecLun           INTEGER;
DEFINE iRecMAr           INTEGER;
DEFINE iRecMie           INTEGER;
DEFINE iRecJue           INTEGER;
DEFINE iRecVie           INTEGER;
DEFINE iRecSab           INTEGER;
DEFINE iRecDom           INTEGER;
DEFINE iNumOpe           INTEGER;
DEFINE iDias             INTEGER;
DEFINE mLiqlun           MONEY(16,2);
DEFINE mLiqMar           MONEY(16,2);
DEFINE mLiqMier          MONEY(16,2);
DEFINE mLiqJue           MONEY(16,2);
DEFINE mLiqVie           MONEY(16,2);
DEFINE mLiqResguardo     MONEY(16,2);
DEFINE mCobEfe           MONEY(16,2);
DEFINE mCobEfeAux        MONEY(16,2);
DEFINE mCobMix           MONEY(16,2);
DEFINE mCobCC            MONEY(16,2);
DEFINE mCobCCAux         MONEY(16,2);
DEFINE mCobEfeT          MONEY(16,2);
DEFINE mCobMixT          MONEY(16,2);
DEFINE mCobCCT           MONEY(16,2);
DEFINE mCobTot           MONEY(16,2);
DEFINE mCobAux           MONEY(16,2);
DEFINE mCobLun           MONEY(16,2);
DEFINE mCobMar           MONEY(16,2);
DEFINE mCobMie           MONEY(16,2);
DEFINE mCobJue           MONEY(16,2);
DEFINE mCobVie           MONEY(16,2);
DEFINE mCobSab           MONEY(16,2);
DEFINE mCobDom           MONEY(16,2);
DEFINE mTotComision      MONEY(16,2);
DEFINE mTotIvaCom        MONEY(16,2);
DEFINE mComision         MONEY(16,2);
DEFINE mComisionAux      MONEY(16,2);
DEFINE mIvaCom           MONEY(16,2);
DEFINE mIvaComAux        MONEY(16,2);
DEFINE mAcumulado        MONEY(16,2);
DEFINE dFechaAux         DATE;
DEFINE dfecha_Hoy        DATE;
DEFINE dFechaIni         DATE;
DEFINE dPriDiaMes        DATE;
DEFINE dUltDiaMes        DATE;
DEFINE iFlagCen          INTEGER;
DEFINE iFlagSuc          INTEGER;
DEFINE cFolio            CHAR(16);
DEFINE iCuantos          INTEGER;

--INICIALIZACION DE VARIABLES
LET cCodRet2	= "00000";
LET cCodret		= "000000";
LET cInfoErr	= '';
LET cAnioMes	= '';
LET mCobEfe		= 0;
LET mCobEfeAux	= 0;
LET mCobCC		= 0;
LET mCobCCAux	= 0;
LET mCobMix		= 0;
LET iRecEfe		= 0;
LET iRecEfeAux	= '';
LET iRecCC		= 0;
LET iRecCCAux	= '';
LET iRecMix		= 0;
LET mComision	= 0;
LET mComisionAux	= 0;
LET mIvaCom		= 0;
LET mIvaComAux	= 0;
LET mCobEfeT	= 0;
LET mCobCCT		= 0;
LET iRecEfeT	= 0;
LET iRecCCT		= 0;
LET mTotComision	= 0;
LET mTotIvaCom	= 0;
LET iRecLun		= 0;
LET mCobLun		= 0;
LET iRecMar		= 0;
LET mCobMar		= 0;
LET iRecMie		= 0;
LET mCobMie		= 0;
LET iRecJue		= 0;
LET mCobJue		= 0;
LET iRecVie		= 0;
LET mCobVie		= 0;
LET iRecSab		= 0;
LET mCobSab		= 0;
LET iRecDom		= 0;
LET mCobDom		= 0;
LET cCategoria	= SUBSTRING(pConvenio FROM 1 FOR 2);
LET cConvenio	= SUBSTRING(pConvenio FROM 3 FOR 3);
LET dFechaAux	= '';
LET dfecha_Hoy	= '';
LET dFechaIni	= '';
LET dPriDiaMes	= '';
LET dUltDiaMes	= '';
LET iNumOpe		= 0;
LET mLiqlun		= 0;
LET mLiqMar		= 0;
LET mLiqMier	= 0;
LET mLiqJue		= 0;
LET mLiqVie		= 0;
LET cFechaLiq	= "";
LET mLiqResguardo	= 0;
LET mAcumulado	= 0;
LET iFlagCen	= 0;
LET iFlagSuc	= 0;
LET cFolio		= '';
LET iCuantos	= 0;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO '/respaldosbd/hugovaz/sp_reporteliquidacioncablemas.out';
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE "informix".sac_controlreportesespeciales
				SET retorno = cCodRet
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio;
				EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_reporteliquidacioncablemas");
			END IF;
		END EXCEPTION;

		SELECT fecha_hoy, pri_dia_mes, ult_dia_mes
		INTO dfecha_Hoy, dPriDiaMes, dUltDiaMes
		FROM "informix".sac_fechas;

		IF TO_CHAR(dfecha_Hoy,"%A") = "Sunday" THEN

			LET dFechaAux = dfecha_Hoy - 6;
			LET dFechaIni = dFechaAux;

			SELECT NVL(liq_resguardo ,0)
			INTO mAcumulado
			FROM "informix".sac_liquidacionsemanal
			WHERE id_convenio = cCategoria||cConvenio
			AND consecutivo_convenio = (SELECT MAX(consecutivo_convenio)
								FROM "informix".sac_liquidacionsemanal
								WHERE id_convenio = cCategoria||cConvenio
								AND consecutivo_convenio <> 0);

			IF mAcumulado IS NULL THEN
				LET mAcumulado = 0;
			END IF;
			
			WHILE dFechaAux <= dfecha_Hoy

				LET mCobEfe = 0.00;
				LET mCobCC = 0.00;
				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iRecEfe = 0;
				LET iRecCC = 0;

				FOREACH
					SELECT
						NVL(efe,0),
						NVL(cc,0),
						NVL(Rec1,''),
						NVL(Rec2,""),
						NVL(comision, 0),
						NVL(iva_com,0),
						flag_confirmacion_central,
						flag_confirmacion_sucursal,
						folio_suc
					INTO
						mCobEfeAux,
						mCobCCAux,
						iRecEfeAux,
						iRecCCAux,
						mComisionAux,
						mIvaComAux,
						iFlagCen,
						iFlagSuc,
						cFolio
					FROM TABLE(
						MULTISET(
							SELECT importe_comision_convenio AS comision, iva_comision_convenio AS iva_com,
									CASE WHEN forma_pago = 1 THEN NVL(importe_pago, 0) END AS efe,
									CASE WHEN forma_pago = 2 THEN NVL(importe_pago, 0) END AS cc,
									CASE WHEN forma_pago = 1 THEN folio_suc END AS Rec1,
									CASE WHEN forma_pago = 2 THEN folio_suc END AS Rec2,
									flag_confirmacion_central,
									flag_confirmacion_sucursal,
									folio_suc
							FROM "informix".sac_movimientoshistorial
							WHERE numcategoria = cCategoria
							AND numconvenio = cConvenio
							AND fecha_pago  = dFechaAux
							AND status_cancelado = 'N'
							AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)))

					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mCobEfe = mCobEfe + mCobEfeAux;
								LET mCobCC = mCobCC + mCobCCAux;
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
									LET iRecEfe = iRecEfe +1;
								END IF;
								IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
									LET iRecCC = iRecCC +1;
								END IF;
							END IF;
						ELSE
							LET mCobEfe = mCobEfe + mCobEfeAux;
							LET mCobCC = mCobCC + mCobCCAux;
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
								LET iRecEfe = iRecEfe +1;
							END IF;
							IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
								LET iRecCC = iRecCC +1;
							END IF;
						END IF;
					ELSE
						LET mCobEfe = mCobEfe + mCobEfeAux;
						LET mCobCC = mCobCC + mCobCCAux;
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
							LET iRecEfe = iRecEfe +1;
						END IF;
						IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
							LET iRecCC = iRecCC +1;
						END IF;
					END IF;
				END FOREACH;

				LET mCobEfeT = mCobEfeT + mCobEfe;
				LET mCobCCT = mCobCCT + mCobCC;
				LET iRecEfeT = iRecEfeT + iRecEfe ;
				LET iRecCCT = iRecCCT + iRecCC;
				LET mTotComision = mTotComision + mComision;
				LET mTotIvaCom = mTotIvaCom + mIvaCom;

				EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(dFechaAux)
				INTO cCodRet2,cFechaLiq;

				IF CAST(cCodRet2 AS INTEGER) = 0 THEN

					LET iDias =  cFechaLiq::DATE - dFechaAux::DATE;

					IF TO_CHAR(dFechaAux,"%A") = "Monday" THEN
						LET iRecLun = iRecEfe + iRecCC ;
						LET mCobLun = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMar = mLiqMar + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqMar = mLiqMar + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;


					IF TO_CHAR(dFechaAux,"%A") = "Tuesday" THEN
						LET iRecMar = iRecEfe + iRecCC ;
						LET mCobMar = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMier =  mLiqMier + mCobMar;
							IF mAcumulado <> 0 THEN
							    LET mLiqMier = mLiqMier + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Wednesday" THEN
						LET iRecMie = iRecEfe + iRecCC ;
						LET mCobMie = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqJue = mLiqJue + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Thursday" THEN
						LET iRecJue = iRecEfe + iRecCC ;
						LET mCobJue = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqVie = mLiqVie + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Friday"  THEN
						LET iRecVie = iRecEfe + iRecCC ;
						LET mCobVie = mCobEfe + mCobCC ;

						IF iDias >= 1 AND iDias <= 3 THEN
							LET mLiqlun =  mLiqlun + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo =mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
					    END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Saturday"   THEN
						LET iRecSab = iRecEfe + iRecCC ;
						LET mCobSab = mCobEfe + mCobCC ;

						IF iDias >= 1  AND iDias <= 2 THEN
							LET mLiqlun =  mLiqlun + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqlun =mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Sunday" THEN
						LET iRecDom = iRecEfe + iRecCC ;
						LET mCobDom = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqlun =  mLiqlun + mCobDom;

							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobDom;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

				LET dFechaAux = dFechaAux + 1;

				END IF;
			END WHILE;

			IF cCodRet2::INTEGER = 0 THEN

				INSERT INTO "informix".sac_liquidacionsemanal (id_convenio, rec_lunes, rec_martes, 				rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo, cob_lunes, 			 cob_martes, cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo, 			   rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred, cob_efectivo,
							  cob_cheqmb,cob_cheqob, cob_tarcred, liq_lunes, liq_martes, liq_miercoles, liq_jueves, liq_viernes,aclaraciones,comision, iva_comision, fec_iniperiodo, fec_finperiodo, liq_resguardo, consecutivo_convenio, fecha_insert)
				VALUES(cCategoria||cConvenio, iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom, mCobLun, mCobMar, mCobMie, mCobJue, mCobVie, mCobSab, mCobDom,iRecEfeT, iRecCCT,0, 0,  mCobEfeT, mCobCCT, 0, 0,mLiqlun, mLiqMar, mLiqMier, mLiqJue, mLiqVie,0,mTotComision, mTotIvaCom, dFechaIni,dfecha_Hoy, mLiqResguardo,
					  (SELECT NVL(MAX(consecutivo_convenio + 1 ),1) FROM "informix".sac_liquidacionsemanal
					   WHERE id_convenio = cCategoria||cConvenio) , CURRENT);
			END IF;
		END IF;

		IF dfecha_Hoy = dUltDiaMes AND CAST(cCodRet2 AS INTEGER) = 0 THEN
			LET dFechaAux = dPriDiaMes;
			LET cAnioMes = TO_CHAR(dfecha_Hoy,"%Y%m");

			WHILE dFechaAux <= dfecha_Hoy

				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iNumOpe = 0;

				FOREACH
					SELECT NVL(importe_comision_convenio,0),NVL(iva_comision_convenio,0),
						flag_confirmacion_central, flag_confirmacion_sucursal,folio_suc
					INTO mComisionAux, mIvaComAux,iFlagCen,iFlagSuc,cFolio
					FROM bdisac:"informix".sac_movimientoshistorial
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio
					AND fecha_pago  = dFechaAux
					AND status_cancelado = 'N'
					AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)

					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia
						WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis
							WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								LET iNumOpe = iNumOpe + 1;
							END IF;
						ELSE
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							LET iNumOpe = iNumOpe + 1;
						END IF;
					ELSE
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						LET iNumOpe = iNumOpe + 1;
					END IF;

				END FOREACH;

				INSERT INTO "informix".sac_liquidacionmensual(id_convenio, aniomes, fecha, num_operaciones, comision, iva, fecha_insert)
				VALUES(cCategoria||cConvenio, cAnioMes, dFechaAux, iNumOpe, mComision, mIvaCom, CURRENT);

				LET dFechaAux = dFechaAux + 1;
			END WHILE;

		END IF;

		IF CAST(cCodRet2 AS INTEGER) <> 0 THEN
			LET cCodRet = LPAD(TRIM(cCodRet2), 5, '0');
		END IF;

		UPDATE "informix".sac_controlreportesespeciales
		SET retorno = cCodret
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

	END;
END PROCEDURE
DOCUMENT
'AUTOR: EPG',
'DESCRIPCIÓN: Genera la información para los Reportes Semanal y Mensual de Pagos referenciados (CABLEMAS)',
'EJECUTADO O LLAMADO POR: sp_GeneraInformacionReportesEspeciales(), el cual  es llamado de p_ProcesoCierreSAC()',
'FECHA: 22-04-2015',
'VERSIÓN: 20140625.1218',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_reporteliquidacioncfe(pConvenio CHAR(5))

--DEFINICION DE VARIABLES
DEFINE cCodret           CHAR(5);
DEFINE cCodRet2          CHAR(5);
DEFINE cAnioMes          CHAR(6);
DEFINE cInfoErr          CHAR(100);
DEFINE cCategoria        CHAR(2);
DEFINE cConvenio         CHAR(3);
DEFINE cFechaLiq         CHAR(10);
DEFINE iSqlErr           INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE iRecEfe           INTEGER;
DEFINE iRecEfeAux        CHAR(16);
DEFINE iRecCC            INTEGER;
DEFINE iRecCCAux         CHAR(16);
DEFINE iRecMix           INTEGER;
DEFINE iRecEfeT          INTEGER;
DEFINE iRecCCT           INTEGER;
DEFINE iRecMixT          INTEGER;
DEFINE iRecTot           INTEGER;
DEFINE iRecAux           INTEGER;
DEFINE iRecLun           INTEGER;
DEFINE iRecMAr           INTEGER;
DEFINE iRecMie           INTEGER;
DEFINE iRecJue           INTEGER;
DEFINE iRecVie           INTEGER;
DEFINE iRecSab           INTEGER;
DEFINE iRecDom           INTEGER;
DEFINE iNumOpe           INTEGER;
DEFINE iDias             INTEGER;
DEFINE mLiqlun           MONEY(16,2);
DEFINE mLiqMar           MONEY(16,2);
DEFINE mLiqMier          MONEY(16,2);
DEFINE mLiqJue           MONEY(16,2);
DEFINE mLiqVie           MONEY(16,2);
DEFINE mLiqResguardo     MONEY(16,2);
DEFINE mCobEfe           MONEY(16,2);
DEFINE mCobEfeAux        MONEY(16,2);
DEFINE mCobMix           MONEY(16,2);
DEFINE mCobCC            MONEY(16,2);
DEFINE mCobCCAux         MONEY(16,2);
DEFINE mCobEfeT          MONEY(16,2);
DEFINE mCobMixT          MONEY(16,2);
DEFINE mCobCCT           MONEY(16,2);
DEFINE mCobTot           MONEY(16,2);
DEFINE mCobAux           MONEY(16,2);
DEFINE mCobLun           MONEY(16,2);
DEFINE mCobMar           MONEY(16,2);
DEFINE mCobMie           MONEY(16,2);
DEFINE mCobJue           MONEY(16,2);
DEFINE mCobVie           MONEY(16,2);
DEFINE mCobSab           MONEY(16,2);
DEFINE mCobDom           MONEY(16,2);
DEFINE mTotComision      MONEY(16,2);
DEFINE mTotIvaCom        MONEY(16,2);
DEFINE mComision         MONEY(16,2);
DEFINE mComisionAux      MONEY(16,2);
DEFINE mIvaCom           MONEY(16,2);
DEFINE mIvaComAux        MONEY(16,2);
DEFINE mAcumulado        MONEY(16,2);
DEFINE dFechaAux         DATE;
DEFINE dfecha_Hoy        DATE;
DEFINE dFechaIni         DATE;
DEFINE dPriDiaMes        DATE;
DEFINE dUltDiaMes        DATE;
DEFINE iFlagCen          INTEGER;
DEFINE iFlagSuc          INTEGER;
DEFINE cFolio            CHAR(16);
DEFINE iCuantos          INTEGER;

--INICIALIZACION DE VARIABLES
LET cCodRet2	= "00000";
LET cCodret		= "000000";
LET cInfoErr	= '';
LET cAnioMes	= '';
LET mCobEfe		= 0;
LET mCobEfeAux	= 0;
LET mCobCC		= 0;
LET mCobCCAux	= 0;
LET mCobMix		= 0;
LET iRecEfe		= 0;
LET iRecEfeAux	= '';
LET iRecCC		= 0;
LET iRecCCAux	= '';
LET iRecMix		= 0;
LET mComision	= 0;
LET mComisionAux	= 0;
LET mIvaCom		= 0;
LET mIvaComAux	= 0;
LET mCobEfeT	= 0;
LET mCobCCT		= 0;
LET iRecEfeT	= 0;
LET iRecCCT		= 0;
LET mTotComision	= 0;
LET mTotIvaCom	= 0;
LET iRecLun		= 0;
LET mCobLun		= 0;
LET iRecMar		= 0;
LET mCobMar		= 0;
LET iRecMie		= 0;
LET mCobMie		= 0;
LET iRecJue		= 0;
LET mCobJue		= 0;
LET iRecVie		= 0;
LET mCobVie		= 0;
LET iRecSab		= 0;
LET mCobSab		= 0;
LET iRecDom		= 0;
LET mCobDom		= 0;
LET cCategoria	= SUBSTRING(pConvenio FROM 1 FOR 2);
LET cConvenio	= SUBSTRING(pConvenio FROM 3 FOR 3);
LET dFechaAux	= '';
LET dfecha_Hoy	= '';
LET dFechaIni	= '';
LET dPriDiaMes	= '';
LET dUltDiaMes	= '';
LET iNumOpe		= 0;
LET mLiqlun		= 0;
LET mLiqMar		= 0;
LET mLiqMier	= 0;
LET mLiqJue		= 0;
LET mLiqVie		= 0;
LET cFechaLiq	= "";
LET mLiqResguardo	= 0;
LET mAcumulado	= 0;
LET iFlagCen	= 0;
LET iFlagSuc	= 0;
LET cFolio		= '';
LET iCuantos	= 0;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO '/respaldosbd/hugovaz/sp_reporteliquidacioncfe.out';
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE "informix".sac_controlreportesespeciales
				SET retorno = cCodRet
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio;
				EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_reporteliquidacioncfe");
			END IF;
		END EXCEPTION;

		SELECT fecha_hoy, pri_dia_mes, ult_dia_mes
		INTO dfecha_Hoy, dPriDiaMes, dUltDiaMes
		FROM "informix".sac_fechas;

		IF TO_CHAR(dfecha_Hoy,"%A") = "Sunday" THEN

			LET dFechaAux = dfecha_Hoy - 6;
			LET dFechaIni = dFechaAux;

			SELECT NVL(liq_resguardo ,0)
			INTO mAcumulado
			FROM "informix".sac_liquidacionsemanal
			WHERE id_convenio = cCategoria||cConvenio
			AND consecutivo_convenio = (SELECT MAX(consecutivo_convenio)
								FROM "informix".sac_liquidacionsemanal
								WHERE id_convenio = cCategoria||cConvenio
								AND consecutivo_convenio <> 0);

			IF mAcumulado IS NULL THEN
				LET mAcumulado = 0;
			END IF;
			
			WHILE dFechaAux <= dfecha_Hoy

				LET mCobEfe = 0.00;
				LET mCobCC = 0.00;
				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iRecEfe = 0;
				LET iRecCC = 0;

				FOREACH
					SELECT
						NVL(efe,0),
						NVL(cc,0),
						NVL(Rec1,''),
						NVL(Rec2,""),
						NVL(comision, 0),
						NVL(iva_com,0),
						flag_confirmacion_central,
						flag_confirmacion_sucursal,
						folio_suc
					INTO
						mCobEfeAux,
						mCobCCAux,
						iRecEfeAux,
						iRecCCAux,
						mComisionAux,
						mIvaComAux,
						iFlagCen,
						iFlagSuc,
						cFolio
					FROM TABLE(
						MULTISET(
							SELECT importe_comision_convenio AS comision, iva_comision_convenio AS iva_com,
									CASE WHEN forma_pago = 1 THEN NVL(importe_pago, 0) END AS efe,
									CASE WHEN forma_pago = 2 THEN NVL(importe_pago, 0) END AS cc,
									CASE WHEN forma_pago = 1 THEN folio_suc END AS Rec1,
									CASE WHEN forma_pago = 2 THEN folio_suc END AS Rec2,
									flag_confirmacion_central,
									flag_confirmacion_sucursal,
									folio_suc
							FROM "informix".sac_movimientoshistorial
							WHERE numcategoria = cCategoria
							AND numconvenio = cConvenio
							AND fecha_pago  = dFechaAux
							AND status_cancelado = 'N'
							AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)))

					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mCobEfe = mCobEfe + mCobEfeAux;
								LET mCobCC = mCobCC + mCobCCAux;
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
									LET iRecEfe = iRecEfe +1;
								END IF;
								IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
									LET iRecCC = iRecCC +1;
								END IF;
							END IF;
						ELSE
							LET mCobEfe = mCobEfe + mCobEfeAux;
							LET mCobCC = mCobCC + mCobCCAux;
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
								LET iRecEfe = iRecEfe +1;
							END IF;
							IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
								LET iRecCC = iRecCC +1;
							END IF;
						END IF;
					ELSE
						LET mCobEfe = mCobEfe + mCobEfeAux;
						LET mCobCC = mCobCC + mCobCCAux;
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
							LET iRecEfe = iRecEfe +1;
						END IF;
						IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
							LET iRecCC = iRecCC +1;
						END IF;
					END IF;
				END FOREACH;

				LET mCobEfeT = mCobEfeT + mCobEfe;
				LET mCobCCT = mCobCCT + mCobCC;
				LET iRecEfeT = iRecEfeT + iRecEfe ;
				LET iRecCCT = iRecCCT + iRecCC;
				LET mTotComision = mTotComision + mComision;
				LET mTotIvaCom = mTotIvaCom + mIvaCom;

				EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(dFechaAux)
				INTO cCodRet2,cFechaLiq;

				IF CAST(cCodRet2 AS INTEGER) = 0 THEN

					LET iDias =  cFechaLiq::DATE - dFechaAux::DATE;

					IF TO_CHAR(dFechaAux,"%A") = "Monday" THEN
						LET iRecLun = iRecEfe + iRecCC ;
						LET mCobLun = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMar = mLiqMar + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqMar = mLiqMar + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;


					IF TO_CHAR(dFechaAux,"%A") = "Tuesday" THEN
						LET iRecMar = iRecEfe + iRecCC ;
						LET mCobMar = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMier =  mLiqMier + mCobMar;
							IF mAcumulado <> 0 THEN
							    LET mLiqMier = mLiqMier + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Wednesday" THEN
						LET iRecMie = iRecEfe + iRecCC ;
						LET mCobMie = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqJue = mLiqJue + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Thursday" THEN
						LET iRecJue = iRecEfe + iRecCC ;
						LET mCobJue = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqVie = mLiqVie + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Friday"  THEN
						LET iRecVie = iRecEfe + iRecCC ;
						LET mCobVie = mCobEfe + mCobCC ;

						IF iDias >= 1 AND iDias <= 3 THEN
							LET mLiqlun =  mLiqlun + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo =mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
					    END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Saturday"   THEN
						LET iRecSab = iRecEfe + iRecCC ;
						LET mCobSab = mCobEfe + mCobCC ;

						IF iDias >= 1  AND iDias <= 2 THEN
							LET mLiqlun =  mLiqlun + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqlun =mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Sunday" THEN
						LET iRecDom = iRecEfe + iRecCC ;
						LET mCobDom = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqlun =  mLiqlun + mCobDom;

							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobDom;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

				LET dFechaAux = dFechaAux + 1;

				END IF;
			END WHILE;

			IF cCodRet2::INTEGER = 0 THEN

				INSERT INTO "informix".sac_liquidacionsemanal (id_convenio, rec_lunes, rec_martes, 				rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo, cob_lunes, 			 cob_martes, cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo, 			   rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred, cob_efectivo,
							  cob_cheqmb,cob_cheqob, cob_tarcred, liq_lunes, liq_martes, liq_miercoles, liq_jueves, liq_viernes,aclaraciones,comision, iva_comision, fec_iniperiodo, fec_finperiodo, liq_resguardo, consecutivo_convenio, fecha_insert)
				VALUES(cCategoria||cConvenio, iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom, mCobLun, mCobMar, mCobMie, mCobJue, mCobVie, mCobSab, mCobDom,iRecEfeT, iRecCCT,0, 0,  mCobEfeT, mCobCCT, 0, 0,mLiqlun, mLiqMar, mLiqMier, mLiqJue, mLiqVie,0,mTotComision, mTotIvaCom, dFechaIni,dfecha_Hoy, mLiqResguardo,
					  (SELECT NVL(MAX(consecutivo_convenio + 1 ),1) FROM "informix".sac_liquidacionsemanal
					   WHERE id_convenio = cCategoria||cConvenio) , CURRENT);
			END IF;
		END IF;

		IF dfecha_Hoy = dUltDiaMes AND CAST(cCodRet2 AS INTEGER) = 0 THEN
			LET dFechaAux = dPriDiaMes;
			LET cAnioMes = TO_CHAR(dfecha_Hoy,"%Y%m");

			WHILE dFechaAux <= dfecha_Hoy

				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iNumOpe = 0;

				FOREACH
					SELECT NVL(importe_comision_convenio,0),NVL(iva_comision_convenio,0),
						flag_confirmacion_central, flag_confirmacion_sucursal,folio_suc
					INTO mComisionAux, mIvaComAux,iFlagCen,iFlagSuc,cFolio
					FROM bdisac:"informix".sac_movimientoshistorial
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio
					AND fecha_pago  = dFechaAux
					AND status_cancelado = 'N'
					AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)

					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia
						WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis
							WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								LET iNumOpe = iNumOpe + 1;
							END IF;
						ELSE
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							LET iNumOpe = iNumOpe + 1;
						END IF;
					ELSE
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						LET iNumOpe = iNumOpe + 1;
					END IF;

				END FOREACH;

				INSERT INTO "informix".sac_liquidacionmensual(id_convenio, aniomes, fecha, num_operaciones, comision, iva, fecha_insert)
				VALUES(cCategoria||cConvenio, cAnioMes, dFechaAux, iNumOpe, mComision, mIvaCom, CURRENT);

				LET dFechaAux = dFechaAux + 1;
			END WHILE;

		END IF;

		IF CAST(cCodRet2 AS INTEGER) <> 0 THEN
			LET cCodRet = LPAD(TRIM(cCodRet2), 5, '0');
		END IF;

		UPDATE "informix".sac_controlreportesespeciales
		SET retorno = cCodret
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

	END;
END PROCEDURE
DOCUMENT
'AUTOR: EPG',
'DESCRIPCIÓN: Genera la información para los Reportes Semanal y Mensual de Pagos referenciados (CFE)',
'EJECUTADO O LLAMADO POR: sp_GeneraInformacionReportesEspeciales(), el cual  es llamado de p_ProcesoCierreSAC()',
'FECHA: 22-04-2015',
'VERSIÓN: 20140625.1218',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_reporteliquidacionjapac(pConvenio CHAR(5))

--DEFINICION DE VARIABLES
DEFINE cCodret           CHAR(5);
DEFINE cCodRet2          CHAR(5);
DEFINE cAnioMes          CHAR(6);
DEFINE cInfoErr          CHAR(100);
DEFINE cCategoria        CHAR(2);
DEFINE cConvenio         CHAR(3);
DEFINE cFechaLiq         CHAR(10);
DEFINE iSqlErr           INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE iRecEfe           INTEGER;
DEFINE iRecEfeAux        CHAR(16);
DEFINE iRecCC            INTEGER;
DEFINE iRecCCAux         CHAR(16);
DEFINE iRecMix           INTEGER;
DEFINE iRecEfeT          INTEGER;
DEFINE iRecCCT           INTEGER;
DEFINE iRecMixT          INTEGER;
DEFINE iRecTot           INTEGER;
DEFINE iRecAux           INTEGER;
DEFINE iRecLun           INTEGER;
DEFINE iRecMAr           INTEGER;
DEFINE iRecMie           INTEGER;
DEFINE iRecJue           INTEGER;
DEFINE iRecVie           INTEGER;
DEFINE iRecSab           INTEGER;
DEFINE iRecDom           INTEGER;
DEFINE iNumOpe           INTEGER;
DEFINE iDias             INTEGER;
DEFINE mLiqlun           MONEY(16,2);
DEFINE mLiqMar           MONEY(16,2);
DEFINE mLiqMier          MONEY(16,2);
DEFINE mLiqJue           MONEY(16,2);
DEFINE mLiqVie           MONEY(16,2);
DEFINE mLiqResguardo     MONEY(16,2);
DEFINE mCobEfe           MONEY(16,2);
DEFINE mCobEfeAux        MONEY(16,2);
DEFINE mCobMix           MONEY(16,2);
DEFINE mCobCC            MONEY(16,2);
DEFINE mCobCCAux         MONEY(16,2);
DEFINE mCobEfeT          MONEY(16,2);
DEFINE mCobMixT          MONEY(16,2);
DEFINE mCobCCT           MONEY(16,2);
DEFINE mCobTot           MONEY(16,2);
DEFINE mCobAux           MONEY(16,2);
DEFINE mCobLun           MONEY(16,2);
DEFINE mCobMar           MONEY(16,2);
DEFINE mCobMie           MONEY(16,2);
DEFINE mCobJue           MONEY(16,2);
DEFINE mCobVie           MONEY(16,2);
DEFINE mCobSab           MONEY(16,2);
DEFINE mCobDom           MONEY(16,2);
DEFINE mTotComision      MONEY(16,2);
DEFINE mTotIvaCom        MONEY(16,2);
DEFINE mComision         MONEY(16,2);
DEFINE mComisionAux      MONEY(16,2);
DEFINE mIvaCom           MONEY(16,2);
DEFINE mIvaComAux        MONEY(16,2);
DEFINE mAcumulado        MONEY(16,2);
DEFINE dFechaAux         DATE;
DEFINE dfecha_Hoy        DATE;
DEFINE dFechaIni         DATE;
DEFINE dPriDiaMes        DATE;
DEFINE dUltDiaMes        DATE;
DEFINE iFlagCen          INTEGER;
DEFINE iFlagSuc          INTEGER;
DEFINE cFolio            CHAR(16);
DEFINE iCuantos          INTEGER;

--INICIALIZACION DE VARIABLES
LET cCodRet2	= "00000";
LET cCodret		= "000000";
LET cInfoErr	= '';
LET cAnioMes	= '';
LET mCobEfe		= 0;
LET mCobEfeAux	= 0;
LET mCobCC		= 0;
LET mCobCCAux	= 0;
LET mCobMix		= 0;
LET iRecEfe		= 0;
LET iRecEfeAux	= '';
LET iRecCC		= 0;
LET iRecCCAux	= '';
LET iRecMix		= 0;
LET mComision	= 0;
LET mComisionAux	= 0;
LET mIvaCom		= 0;
LET mIvaComAux	= 0;
LET mCobEfeT	= 0;
LET mCobCCT		= 0;
LET iRecEfeT	= 0;
LET iRecCCT		= 0;
LET mTotComision	= 0;
LET mTotIvaCom	= 0;
LET iRecLun		= 0;
LET mCobLun		= 0;
LET iRecMar		= 0;
LET mCobMar		= 0;
LET iRecMie		= 0;
LET mCobMie		= 0;
LET iRecJue		= 0;
LET mCobJue		= 0;
LET iRecVie		= 0;
LET mCobVie		= 0;
LET iRecSab		= 0;
LET mCobSab		= 0;
LET iRecDom		= 0;
LET mCobDom		= 0;
LET cCategoria	= SUBSTRING(pConvenio FROM 1 FOR 2);
LET cConvenio	= SUBSTRING(pConvenio FROM 3 FOR 3);
LET dFechaAux	= '';
LET dfecha_Hoy	= '';
LET dFechaIni	= '';
LET dPriDiaMes	= '';
LET dUltDiaMes	= '';
LET iNumOpe		= 0;
LET mLiqlun		= 0;
LET mLiqMar		= 0;
LET mLiqMier	= 0;
LET mLiqJue		= 0;
LET mLiqVie		= 0;
LET cFechaLiq	= "";
LET mLiqResguardo	= 0;
LET mAcumulado	= 0;
LET iFlagCen	= 0;
LET iFlagSuc	= 0;
LET cFolio		= '';
LET iCuantos	= 0;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO '/respaldosbd/hugovaz/sp_reporteliquidacionjapac.out';
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE "informix".sac_controlreportesespeciales
				SET retorno = cCodRet
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio;
				EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_reporteliquidacionjapac");
			END IF;
		END EXCEPTION;

		SELECT fecha_hoy, pri_dia_mes, ult_dia_mes
		INTO dfecha_Hoy, dPriDiaMes, dUltDiaMes
		FROM "informix".sac_fechas;

		IF TO_CHAR(dfecha_Hoy,"%A") = "Sunday" THEN

			LET dFechaAux = dfecha_Hoy - 6;
			LET dFechaIni = dFechaAux;

			SELECT NVL(liq_resguardo ,0)
			INTO mAcumulado
			FROM "informix".sac_liquidacionsemanal
			WHERE id_convenio = cCategoria||cConvenio
			AND consecutivo_convenio = (SELECT MAX(consecutivo_convenio)
								FROM "informix".sac_liquidacionsemanal
								WHERE id_convenio = cCategoria||cConvenio
								AND consecutivo_convenio <> 0);

			IF mAcumulado IS NULL THEN
				LET mAcumulado = 0;
			END IF;
			
			WHILE dFechaAux <= dfecha_Hoy

				LET mCobEfe = 0.00;
				LET mCobCC = 0.00;
				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iRecEfe = 0;
				LET iRecCC = 0;

				FOREACH
					SELECT
						NVL(efe,0),
						NVL(cc,0),
						NVL(Rec1,''),
						NVL(Rec2,""),
						NVL(comision, 0),
						NVL(iva_com,0),
						flag_confirmacion_central,
						flag_confirmacion_sucursal,
						folio_suc
					INTO
						mCobEfeAux,
						mCobCCAux,
						iRecEfeAux,
						iRecCCAux,
						mComisionAux,
						mIvaComAux,
						iFlagCen,
						iFlagSuc,
						cFolio
					FROM TABLE(
						MULTISET(
							SELECT importe_comision_convenio AS comision, iva_comision_convenio AS iva_com,
									CASE WHEN forma_pago = 1 THEN NVL(importe_pago, 0) END AS efe,
									CASE WHEN forma_pago = 2 THEN NVL(importe_pago, 0) END AS cc,
									CASE WHEN forma_pago = 1 THEN folio_suc END AS Rec1,
									CASE WHEN forma_pago = 2 THEN folio_suc END AS Rec2,
									flag_confirmacion_central,
									flag_confirmacion_sucursal,
									folio_suc
							FROM "informix".sac_movimientoshistorial
							WHERE numcategoria = cCategoria
							AND numconvenio = cConvenio
							AND fecha_pago  = dFechaAux
							AND status_cancelado = 'N'
							AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)))

					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mCobEfe = mCobEfe + mCobEfeAux;
								LET mCobCC = mCobCC + mCobCCAux;
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
									LET iRecEfe = iRecEfe +1;
								END IF;
								IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
									LET iRecCC = iRecCC +1;
								END IF;
							END IF;
						ELSE
							LET mCobEfe = mCobEfe + mCobEfeAux;
							LET mCobCC = mCobCC + mCobCCAux;
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
								LET iRecEfe = iRecEfe +1;
							END IF;
							IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
								LET iRecCC = iRecCC +1;
							END IF;
						END IF;
					ELSE
						LET mCobEfe = mCobEfe + mCobEfeAux;
						LET mCobCC = mCobCC + mCobCCAux;
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
							LET iRecEfe = iRecEfe +1;
						END IF;
						IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
							LET iRecCC = iRecCC +1;
						END IF;
					END IF;
				END FOREACH;

				LET mCobEfeT = mCobEfeT + mCobEfe;
				LET mCobCCT = mCobCCT + mCobCC;
				LET iRecEfeT = iRecEfeT + iRecEfe ;
				LET iRecCCT = iRecCCT + iRecCC;
				LET mTotComision = mTotComision + mComision;
				LET mTotIvaCom = mTotIvaCom + mIvaCom;

				EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(dFechaAux)
				INTO cCodRet2,cFechaLiq;

				IF CAST(cCodRet2 AS INTEGER) = 0 THEN

					LET iDias =  cFechaLiq::DATE - dFechaAux::DATE;

					IF TO_CHAR(dFechaAux,"%A") = "Monday" THEN
						LET iRecLun = iRecEfe + iRecCC ;
						LET mCobLun = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMar = mLiqMar + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqMar = mLiqMar + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;


					IF TO_CHAR(dFechaAux,"%A") = "Tuesday" THEN
						LET iRecMar = iRecEfe + iRecCC ;
						LET mCobMar = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMier =  mLiqMier + mCobMar;
							IF mAcumulado <> 0 THEN
							    LET mLiqMier = mLiqMier + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Wednesday" THEN
						LET iRecMie = iRecEfe + iRecCC ;
						LET mCobMie = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqJue = mLiqJue + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Thursday" THEN
						LET iRecJue = iRecEfe + iRecCC ;
						LET mCobJue = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqVie = mLiqVie + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Friday"  THEN
						LET iRecVie = iRecEfe + iRecCC ;
						LET mCobVie = mCobEfe + mCobCC ;

						IF iDias >= 1 AND iDias <= 3 THEN
							LET mLiqlun =  mLiqlun + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo =mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
					    END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Saturday"   THEN
						LET iRecSab = iRecEfe + iRecCC ;
						LET mCobSab = mCobEfe + mCobCC ;

						IF iDias >= 1  AND iDias <= 2 THEN
							LET mLiqlun =  mLiqlun + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqlun =mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Sunday" THEN
						LET iRecDom = iRecEfe + iRecCC ;
						LET mCobDom = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqlun =  mLiqlun + mCobDom;

							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobDom;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

				LET dFechaAux = dFechaAux + 1;

				END IF;
			END WHILE;

			IF cCodRet2::INTEGER = 0 THEN

				INSERT INTO "informix".sac_liquidacionsemanal (id_convenio, rec_lunes, rec_martes, 				rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo, cob_lunes, 			 cob_martes, cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo, 			   rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred, cob_efectivo,
							  cob_cheqmb,cob_cheqob, cob_tarcred, liq_lunes, liq_martes, liq_miercoles, liq_jueves, liq_viernes,aclaraciones,comision, iva_comision, fec_iniperiodo, fec_finperiodo, liq_resguardo, consecutivo_convenio, fecha_insert)
				VALUES(cCategoria||cConvenio, iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom, mCobLun, mCobMar, mCobMie, mCobJue, mCobVie, mCobSab, mCobDom,iRecEfeT, iRecCCT,0, 0,  mCobEfeT, mCobCCT, 0, 0,mLiqlun, mLiqMar, mLiqMier, mLiqJue, mLiqVie,0,mTotComision, mTotIvaCom, dFechaIni,dfecha_Hoy, mLiqResguardo,
					  (SELECT NVL(MAX(consecutivo_convenio + 1 ),1) FROM "informix".sac_liquidacionsemanal
					   WHERE id_convenio = cCategoria||cConvenio) , CURRENT);
			END IF;
		END IF;

		IF dfecha_Hoy = dUltDiaMes AND CAST(cCodRet2 AS INTEGER) = 0 THEN
			LET dFechaAux = dPriDiaMes;
			LET cAnioMes = TO_CHAR(dfecha_Hoy,"%Y%m");

			WHILE dFechaAux <= dfecha_Hoy

				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iNumOpe = 0;

				FOREACH
					SELECT NVL(importe_comision_convenio,0),NVL(iva_comision_convenio,0),
						flag_confirmacion_central, flag_confirmacion_sucursal,folio_suc
					INTO mComisionAux, mIvaComAux,iFlagCen,iFlagSuc,cFolio
					FROM bdisac:"informix".sac_movimientoshistorial
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio
					AND fecha_pago  = dFechaAux
					AND status_cancelado = 'N'
					AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)

					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia
						WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis
							WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								LET iNumOpe = iNumOpe + 1;
							END IF;
						ELSE
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							LET iNumOpe = iNumOpe + 1;
						END IF;
					ELSE
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						LET iNumOpe = iNumOpe + 1;
					END IF;

				END FOREACH;

				INSERT INTO "informix".sac_liquidacionmensual(id_convenio, aniomes, fecha, num_operaciones, comision, iva, fecha_insert)
				VALUES(cCategoria||cConvenio, cAnioMes, dFechaAux, iNumOpe, mComision, mIvaCom, CURRENT);

				LET dFechaAux = dFechaAux + 1;
			END WHILE;

		END IF;

		IF CAST(cCodRet2 AS INTEGER) <> 0 THEN
			LET cCodRet = LPAD(TRIM(cCodRet2), 5, '0');
		END IF;

		UPDATE "informix".sac_controlreportesespeciales
		SET retorno = cCodret
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

	END;
END PROCEDURE
DOCUMENT
'AUTOR: EPG',
'DESCRIPCIÓN: Genera la información para los Reportes Semanal y Mensual de Pagos referenciados (JAPAC)',
'EJECUTADO O LLAMADO POR: sp_GeneraInformacionReportesEspeciales(), el cual  es llamado de p_ProcesoCierreSAC()',
'FECHA: 22-04-2015',
'VERSIÓN: 20140625.1218',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_generaarchivocobranzacoppel_pba(cId_convenio CHAR(5))

--DEFINICION DE VARIABLES

    DEFINE cCodRet              CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iIsamErr             INTEGER;
    DEFINE cInfoErr             CHAR(100);
    DEFINE iSucursal            INTEGER;
    DEFINE iImporte             INTEGER;
    DEFINE iCantidad            INTEGER;
    DEFINE i                    INTEGER;
    DEFINE cClave               CHAR(1);
    DEFINE cCategoria           CHAR(2);
    DEFINE cMes                 CHAR(2);
    DEFINE cDia                 CHAR(2);
    DEFINE cConvenio            CHAR(3);
    DEFINE cAnio                CHAR(4);
    DEFINE cExtUnl              CHAR(4);
    DEFINE cExtTxt              CHAR(4);
    DEFINE cNomArchCPL          CHAR(15);
    DEFINE cNomArchCPLF         CHAR(15);
    DEFINE cNomArchTot          CHAR(15);
    DEFINE cNomArchTotF         CHAR(15);
    DEFINE cRutaArchCoppelTmp   CHAR(20);
    DEFINE cRutaArchTotalTmp    CHAR(25);
    DEFINE cRuta                CHAR(40);
    DEFINE cRutaFC              CHAR(50);
    DEFINE cRutaFT              CHAR(50);
    DEFINE cSql                 CHAR(100);
    DEFINE cStmt                CHAR(100);
    DEFINE cSql_Stmt            CHAR(1250);
    DEFINE dFechaIni            DATE;
    DEFINE dFecha_Hoy           DATE;
    DEFINE bFlagSeguro          BOOLEAN;
    DEFINE bFlagMovto           BOOLEAN;
	DEFINE iFlagCen             INTEGER;
	DEFINE iFlagSuc             INTEGER;
	DEFINE cFolio               CHAR(16);
	DEFINE iCuantos             INTEGER;
	DEFINE dFecha_Pago           DATE;
	DEFINE cReferencia1          CHAR(20);

 --   SET DEBUG FILE TO "/informix/EPG/Coppel.out";
 --   TRACE ON;

    --INICIALIZACION DE VARIABLES
    LET cCodRet = '00000';
    LET cStmt = '' ;
    LET cNomArchCPL = '';
    LET cNomArchCPLF = '';
    LET cRuta = '';
    LET cSql = '';
    LET bFlagSeguro = 'f';
    LET bFlagMovto = 'f';
    LET iImporte = 0;
    LET iCantidad = 0;
    LET cExtUnl = ".unl";
    LET cExtTxt = ".txt";
    LET cCategoria = SUBSTRING(cId_convenio FROM 1 FOR 2);
    LET cConvenio = SUBSTRING(cId_convenio FROM 3 FOR 3);
	LET iFlagCen      = 0;
	LET iFlagSuc      = 0;
	LET cFolio        ='';
	LET iCuantos      = 0;
	LET dFecha_Pago    = DATE(1);
	LET cReferencia1  		  = '';

    BEGIN

        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                DELETE FROM bdisac:tmpSac_MovimientosDetalleHistorial;

                UPDATE sac_controlarchivoscobranza
                SET retorno = cCodRet
                WHERE numcategoria = cCategoria
                AND numconvenio = cConvenio;

                EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_GeneraArchivoCobranzaCoppel");
            END IF;
        END EXCEPTION;

        SELECT fecha_hoy INTO dFecha_Hoy FROM bdisac:sac_fechas;

        SELECT fecha_ultimo_archivo
        INTO dFechaIni
        FROM bdisac:sac_controlarchivoscobranza
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;

        INSERT INTO bdisac:tmpSac_MovimientosDetalleHistorial (clave, tipomovimiento, sucursal, ciudad, cliente, clienteetp, caja, recibo, factura, importe, saldoinicial, saldofinal,
                           saldocuenta, vencidoinicial, minimoinicial, montodolar, base, fechasaldacon, importesaldacon, tipoconvenio, subtipoconvenio, plazoconvenio,
                           ejercicio, clavetdaocob, grabacartera, anexo, clavelocal, clientelocalizar, tiposeguro, flagseguroconyugal, movtoseguro, flagmontoseguro,
                           statusseguro, causabaja, cantidadseguros, cantidadsegurosanterior, cantidadmeses, bonificacion, mesesvencidos, fechanacimiento, edad, sexo,
                           areaajuste, fechaabonoajuste, claveajuste, ajuste, sucursalorigen, numerocontrol, comision, clienteremitente, tipogastoviaje, centro, flagincluyerecibo,
                           ruta, folio, cuenta, iva, telefono, compania, contrato, credito, fechavencimiento, fechavencimientoanterior, fecha, efectuo, cajaoriginal, foliosucursal,
                           rpu, flagmovtosupervisor, interes, importeventa, folioanterior, digito, sac, fechadocumento, numerocuenta, numerosubcuenta, numeroconcepto,
                           registropatronal, formaaportacionafore, ipcarteracliente, fechamovto, candidato, statusafore)
        SELECT clave, tipomovimiento, sucursal, ciudad, cliente,clienteetp, caja, recibo, factura,importe * 100, saldoinicial, saldofinal, saldocuenta, vencidoinicial,
        minimoinicial, montodolar, base, fechasaldacon, importesaldacon, tipoconvenio, subtipoconvenio, plazoconvenio,ejercicio, clavetdaocob, grabacartera,
        anexo, clavelocal, clientelocalizar, tiposeguro, flagseguroconyugal, movtoseguro,flagmontoseguro, statusseguro, causabaja, cantidadseguros,
        cantidadsegurosanterior, cantidadmeses, bonificacion, mesesvencidos, fechanacimiento, edad, sexo, areaajuste, fechaabonoajuste, claveajuste,
        ajuste, sucursalorigen, numerocontrol, comision, clienteremitente, tipogastoviaje, centro, flagincluyerecibo, ruta, folio, cuenta, iva, telefono,
        compania, contrato, credito, fechavencimiento, fechavencimientoanterior, fecha, efectuo, cajaoriginal, foliosucursal, rpu, flagmovtosupervisor,
        interes, importeventa, folioanterior, digito, sac, fechadocumento, numerocuenta, numerosubcuenta, numeroconcepto, registropatronal, formaaportacionafore,
        ipcarteracliente, fechamovto, candidato, statusafore
        FROM bdisac:sac_movimientosdetallehistorial a, bdisac:sac_movimientoshistorial b
        ---WHERE a.fecha::date > dFechaIni
        WHERE a.fecha > dFechaIni
        ---AND a.fecha::date <= dFecha_Hoy
        AND a.fecha <= dFecha_Hoy
        AND a.cliente = b.referencia1
        AND a.recibo = b.referencia2
        AND b.numcategoria = cCategoria
        AND b.numconvenio = cConvenio
        AND NOT (status_cancelado = 'S' AND status_coppel = 0);

        LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
        LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
        LET cAnio = LPAD(YEAR(dFecha_Hoy::DATE) , 4, '0');

        SELECT TRIM(valor)
        INTO cRuta
        FROM bdisac:sac_param
        WHERE cod_param =  3;

        LET cNomArchCPL = "mvb"|| cDia||cMes||cAnio ||cExtUnl;
        LET cNomArchCPLF = "mvb"|| cDia||cMes||cAnio ||cExtTxt;
        LET cNomArchTot = "cfv"|| cDia||cMes||cAnio ||cExtUnl;
        LET cNomArchTotF = "cfv"|| cDia||cMes||cAnio ||cExtTxt;
        LET cRutaFC = TRIM(cRuta) || cNomArchCPL;
        LET cRutaFT = TRIM(cRuta) || cNomArchTot;

        LET cSql_Stmt = 'echo "UNLOAD TO ''' || SUBSTRING(cRutaFC FROM 1 FOR LENGTH(cRutaFC)) ||''' SELECT clave, tipomovimiento, sucursal, ciudad, cliente,clienteetp, caja, recibo, factura, ' ||
                        'importe, saldoinicial, saldofinal, saldocuenta, vencidoinicial, minimoinicial, montodolar, base, fechasaldacon, importesaldacon, '||
                        'tipoconvenio, subtipoconvenio, plazoconvenio,ejercicio, clavetdaocob, grabacartera, anexo, clavelocal, clientelocalizar, tiposeguro, '||
                        'flagseguroconyugal, movtoseguro,flagmontoseguro, statusseguro, causabaja, cantidadseguros, cantidadsegurosanterior, cantidadmeses, '||
                        'bonificacion, mesesvencidos, fechanacimiento, edad, sexo, areaajuste, fechaabonoajuste, claveajuste, ajuste, sucursalorigen, numerocontrol, '||
                        'comision, clienteremitente, tipogastoviaje, centro, flagincluyerecibo, ruta, folio, cuenta, iva, telefono, compania, contrato, credito, '||
                        'fechavencimiento, fechavencimientoanterior, fecha, efectuo, cajaoriginal, foliosucursal, rpu, flagmovtosupervisor, interes, importeventa, '||
                        'folioanterior, digito, sac, fechadocumento, numerocuenta, numerosubcuenta, numeroconcepto, registropatronal, formaaportacionafore, '||
                        'ipcarteracliente, fechamovto, candidato, statusafore FROM bdisac:tmpSac_MovimientosDetalleHistorial ORDER BY sucursal, caja, recibo;"'||
                        '> /tmp/tmp.sql';
        SYSTEM cSql_Stmt;

        LET cStmt = 'dbaccess bdisac /tmp/tmp.sql';
        SYSTEM cStmt;

        LET cSql = "sed 's/|$//g' " || SUBSTRING(cRutaFC FROM 1 FOR LENGTH(cRutaFC)) || " > "|| TRIM(cRuta)||cNomArchCPLF;
        SYSTEM cSql;

        FOREACH
            SELECT DISTINCT(sucursal)
            INTO iSucursal
            FROM tmpSac_MovimientosDetalleHistorial
            ORDER BY sucursal

            FOR i = 1 TO 23
                    IF i = 1 THEN
                        LET bFlagMovto = 't';
                        LET cClave = 'S';
                    ELIF i = 2 THEN
                        LET bFlagMovto = 't';
                        LET cClave = 'I';
                    ELIF i = 3 THEN
                        LET bFlagSeguro = 't';
                        LET bFlagMovto = 't';
                        LET cClave = 'G';
                    ELIF i = 4 THEN
                        LET bFlagSeguro = 't';
                        LET bFlagMovto = 't';
                        LET cClave = 'G';
                    ELIF i = 18 THEN
                        LET bFlagMovto = 't';
                        LET cClave = 'S';
                    ELIF i = 19 THEN
                        LET bFlagMovto = 't';
                        LET cClave = 'S';
                    ELIF i = 21 THEN
                        LET bFlagMovto = 't';
                        LET cClave = 'S';
                    END IF;

                    IF bFlagMovto = 't' THEN
                        IF bFlagSeguro= 't' THEN
                            IF i = 3 THEN
                                SELECT NVL(SUM(importe / 100), 0), COUNT(clave)
                                INTO iImporte, iCantidad
                                FROM TABLE(MULTISET(SELECT CASE WHEN clave = UPPER(cClave) THEN importe END AS importe, clave
                                                    FROM bdisac:tmpSac_MovimientosDetalleHistorial
                                                    WHERE clave in (UPPER(cClave) , LOWER(cClave))
                                                    AND tipomovimiento = '1'
                                                    AND movtoseguro <> 'C'
                                                    AND sucursal = iSucursal));
                            ELIF i = 4 THEN
                                SELECT NVL(SUM(importe / 100), 0), COUNT(clave)
                                INTO iImporte, iCantidad
                                FROM TABLE(MULTISET(SELECT CASE WHEN clave = UPPER(cClave) THEN importe END AS importe, clave
                                                    FROM bdisac:tmpSac_MovimientosDetalleHistorial
                                                    WHERE clave in (UPPER(cClave) , LOWER(cClave))
                                                    AND tipomovimiento = '1'
                                                    AND movtoseguro = 'C'
                                                    AND sucursal = iSucursal));
                            END IF;
                        ELSE
                            IF i = 1 THEN
                                SELECT NVL(SUM(importe / 100), 0), COUNT(clave)
                                INTO iImporte, iCantidad
                                FROM TABLE(MULTISET(SELECT CASE WHEN clave = UPPER(cClave) THEN importe END AS importe, clave
                                                    FROM bdisac:tmpSac_MovimientosDetalleHistorial
                                                    WHERE clave in (UPPER(cClave) , LOWER(cClave))
                                                    AND tipomovimiento IN ('1', '5', '6', '7', 'I', 'J', 'K', 'L', 'R', 'S')
                                                    AND sucursal = iSucursal));
                            ELIF i = 2 THEN
                                SELECT NVL(SUM(importe / 100), 0), COUNT(clave)
                                INTO iImporte, iCantidad
                                FROM TABLE(MULTISET(SELECT CASE WHEN clave = UPPER(cClave) THEN importe END AS importe, clave
                                                    FROM bdisac:tmpSac_MovimientosDetalleHistorial
                                                    WHERE clave in (UPPER(cClave) , LOWER(cClave))
                                                    AND tipomovimiento IN ('1', '2', '3', '4')
                                                    AND sucursal = iSucursal));
                            ELIF i = 18 THEN
                                SELECT NVL(SUM(importe / 100), 0), COUNT(clave)
                                INTO iImporte, iCantidad
                                FROM TABLE(MULTISET(SELECT CASE WHEN clave = UPPER(cClave) THEN importe END AS importe, clave
                                                    FROM bdisac:tmpSac_MovimientosDetalleHistorial
                                                    WHERE clave in (UPPER(cClave) , LOWER(cClave))
                                                    AND tipomovimiento = 'B'
                                                    AND sucursal = iSucursal));
                            ELIF i = 19 THEN
                                SELECT NVL(SUM(importe / 100), 0), COUNT(clave)
                                INTO iImporte, iCantidad
                                FROM TABLE(MULTISET(SELECT CASE WHEN clave = UPPER(cClave) THEN importe END AS importe, clave
                                                    FROM bdisac:tmpSac_MovimientosDetalleHistorial
                                                    WHERE clave in (UPPER(cClave) , LOWER(cClave))
                                                    AND tipomovimiento = 'D'
                                                    AND sucursal = iSucursal));
                            ELIF i = 21 THEN
                                SELECT NVL(SUM(importe / 100), 0), COUNT(clave)
                                INTO iImporte, iCantidad
                                FROM TABLE(MULTISET(SELECT CASE WHEN clave = UPPER(cClave) THEN importe END AS importe, clave
                                                    FROM bdisac:tmpSac_MovimientosDetalleHistorial
                                                    WHERE clave in (UPPER(cClave) , LOWER(cClave))
                                                    AND tipomovimiento = 'C'
                                                    AND sucursal = iSucursal));
                            END IF;
                        END IF;
                    END IF ;
                    INSERT INTO bdisac:sac_totalmovimientosdetallehistorial (tipo, importe, cantidad, sucursal, fecha, fecha_movto)
                    VALUES (i, iImporte, iCantidad, iSucursal, dFecha_hoy, CURRENT);
								
                    LET bFlagMovto = 'f';
                    LET bFlagSeguro= 'f';
                    LET cClave = '';
                    LET iImporte = 0;
                    LET iCantidad = 0;
            END FOR;
		END FOREACH;
		
		FOREACH
			SELECT {+INDEX (bdisac:sac_movimientoshistorial idxsac_movhisfe)} referencia1,flag_confirmacion_central, flag_confirmacion_sucursal, folio_suc, fecha_pago
			INTO  cReferencia1, iFlagCen, iFlagSuc, cFolio, dFecha_Pago
			FROM bdisac:sac_movimientoshistorial
			WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio
				AND fecha_pago > dFechaIni
				AND fecha_pago <= dFecha_Hoy
				AND status_cancelado <> 'S'
				AND (flag_confirmacion_central = 1
				OR flag_confirmacion_sucursal = 1)
				
			IF iFlagCen = 0 or iFlagSuc =0 THEN
				SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movdia WHERE empresa = '001' AND folio_suc = cFolio
--2014.06.02 FRG-i
				and cancelad <> 'S';
--2014.06.02 FRG-f
				IF iCuantos = 0 THEN
					SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movhis WHERE empresa = '001' AND folio_suc = cFolio AND fech_alt = dFecha_Pago
--2014.06.02 FRG-i
				and cancelad <> 'S';
--2014.06.02 FRG-f
					IF iCuantos = 0 THEN
						CONTINUE FOREACH;
					END IF;
				END IF;
				IF iCuantos > 0 THEN            
					UPDATE bdisac:sac_movimientoshistorial SET flag_confirmacion_sucursal='1'
					WHERE numcategoria = cCategoria
						AND numconvenio = cConvenio
						AND fecha_pago = dFecha_Pago
						AND folio_suc = cFolio
						AND referencia1 = cReferencia1
						AND status_cancelado <> 'S'
						AND flag_confirmacion_sucursal = 0;  

					INSERT INTO "informix".sac_bitacora_flags(numcategoria,numconvenio,referencia,folio_suc,fecha_pago,fecha_insert)
					VALUES (cCategoria,cConvenio,cReferencia1,cFolio,dFecha_Pago,current);
				END IF;
			END IF;
		END FOREACH;

        LET cSql_Stmt = '';
        LET cSql_Stmt = 'echo "UNLOAD TO ''' || SUBSTRING(cRutaFT FROM 1 FOR LENGTH(cRutaFT)) || ''' SELECT tipo, importe, cantidad, sucursal, fecha, fecha_movto ' ||
                        'FROM bdisac:sac_totalmovimientosdetallehistorial WHERE fecha = (SELECT fecha_hoy FROM bdisac:sac_fechas) " > /tmp/tmp.sql';

        SYSTEM cSql_Stmt;

        LET cStmt = 'dbaccess bdisac /tmp/tmp.sql';
        SYSTEM cStmt;

        LET cSql = "sed 's/|$//g' "|| SUBSTRING(cRutaFT FROM 1 FOR LENGTH(cRutaFT)) || " > " || TRIM(cRuta) || cNomArchTotF;
        SYSTEM cSql;

        DELETE FROM bdisac:tmpSac_MovimientosDetalleHistorial;
        LET cStmt = 'rm -f /tmp/tmp.sql';
        SYSTEM cStmt;

        UPDATE sac_controlarchivoscobranza
        SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;

    END;
END PROCEDURE
DOCUMENT
'AUTOR : José Angel López Adams',
'DESCRIPCION: Genera el archivo de cobranza Coppel de acuerdo a Layout proporcionado por la misma empresa',
'Sucursales',
'EJECUTADO O LLAMADO POR:',
'sp_genera_ArchivosCobranzaCentral()',
'FECHA : Agosto de 2008',
'VERSION: 200808',
'BD    : bdisac',
'MODIFICACION: Se modifica el criterio de extraccin de la informacion de la tabla temporal para contemplar el numero de convenio coppel',
'FECHA : 01/06/2009',
'AUTOR : José Angel López Adams',
'MODIFICACION: Se modifica para que seleccione todos los movimientos sin importar si estan cancelados o no ',
'FECHA MODIFICACION: 19/06/2009',
'AUTOR MODIFICACION: Dulce Ramírez',
'MODIFICACION: Se modifica al contabilizar el número de movimientos se contemplen los CANCELADOS, pero la sumatoria de importes solo se hará de los ACTIVOS ',
'FECHA MODIFICACION: 17/07/2009',
'AUTOR : José Angel López Adams',
'MODIFICACION: Se modifica para contemplar en el archivo de cobranza los movimientos para tiempo aire y deuda bancoppel',
'FECHA MODIFICACION: 30/07/2009',
'AUTOR : Raul Rene Ruiz Rodriguez',
'MODIFICACION: Se modifica para contabilizar correctamente los movimientos de seguros ya que los movimientos de seguros afirme se estaban contemplando tambien dentro del conteo de los seguros club',
'FECHA MODIFICACION: 16/10/2009',
'AUTOR : José Angel López Adams',
'MODIFICACION: Se modifica para descartar los movimientos que no sean confirmados y esten cancelados(reversos automaticos)',
'FECHA MODIFICACION: 21/10/2009',
'AUTOR : Julio Cesar Polanco Inzunza',
'AUTOR: FRG',
'DESCRIPCIÓN: se agrega condición para considerar registros de cheques que NO estén reversados.',
'FECHA:02/Jun/2014';

CREATE PROCEDURE "informix".sp_generaarchivocobranzajapac(pConvenio CHAR(5))

-- DEFINICION DE VARIABLES
DEFINE cCodRet				CHAR(5);
DEFINE iSqlErr				INTEGER;
DEFINE cDia					CHAR(2);
DEFINE cMes					CHAR(2);
DEFINE cAnio				CHAR(2);
DEFINE cAnio2				CHAR(4);
DEFINE cDiaI				CHAR(2);
DEFINE cMesI				CHAR(2);
DEFINE cAnioI				CHAR(4);
DEFINE cDiaPago				CHAR(2);
DEFINE cMesPago				CHAR(2);
DEFINE cAnioPago				CHAR(4);
DEFINE cCategoria				CHAR(2);
DEFINE cConvenio				CHAR(3);
DEFINE cReferencia1			CHAR(22);
DEFINE cRutaArchJAPAC		CHAR(100);
DEFINE cStmt				CHAR(250);
DEFINE cFolio				CHAR(16);
DEFINE cTpoOperacion			CHAR(1);
DEFINE dFechaIni				DATE;
DEFINE dFecha_Hoy				DATE;
DEFINE iImporte_Pago			DECIMAL(9,0);
DEFINE iTotal_Pago			DECIMAL(12,0);
DEFINE iFlagCen				INTEGER;
DEFINE iFlagSuc				INTEGER;
DEFINE iCuantos				INTEGER;
DEFINE iNumPagos				INTEGER;
DEFINE cHora				CHAR(2);
DEFINE cMinuto	  			CHAR(2);
DEFINE cSucursal				CHAR(4);
DEFINE dFechaPago				DATE;
DEFINE cNombreSuc			CHAR(25);

--INICIALIZACION DE VARIABLES--
LET cCodRet					= "00000";
LET iSqlErr					= 0;
LET cCategoria				= SUBSTRING(pConvenio FROM 1 FOR 2);
LET cConvenio				= SUBSTRING(pConvenio FROM 3 FOR 3);
LET cReferencia1				= '';
LET cDia					= '';
LET cMes					= '';
LET cAnio					= '';
LET cAnio2					= '';
LET cDiaI					= '';
LET cMesI					= '';
LET cAnioI					= '';
LET cDiaPago				= '';
LET cMesPago				= '';
LET cAnioPago				= '';
LET iImporte_Pago				= 0;
LET iTotal_Pago				= 0;
LET cFolio					= '';
LET iFlagCen				= 0;
LET iFlagSuc				= 0;
LET cRutaArchJAPAC			= '';
LET iCuantos				= 0;
LET cStmt					= '';
LET dFechaIni				= DATE(1);
LET dFecha_Hoy				= DATE(1);
LET cTpoOperacion				= '2';
LET iNumPagos				= 0;
LET cHora					= '';
LET cMinuto					= '';
LET cSucursal				= '';
LET dFechaPago				= DATE(1);
LET cNombreSuc				= '';

	--SET DEBUG FILE TO  '/informix/adrian/sp_generaarchivocobranzajapac.out';
	--TRACE ON;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE "informix".sac_controlarchivoscobranza
				SET retorno = cCodRet
				WHERE numcategoria = cCategoria
				AND   numconvenio = cConvenio;
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		SELECT fecha_hoy
		INTO dFecha_Hoy
		FROM "informix".sac_fechas
		WHERE empresa = "001";
		
		--SELECCIONA LA FECHA DEL ULTIMO ARCHIVO GENERADO
		SELECT fecha_ultimo_archivo
		INTO dFechaIni
		FROM "informix".sac_controlarchivoscobranza
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

		--ASIGNA VALOR PARA FECHA INICIAL
		IF dFechaIni = dFecha_Hoy THEN
			LET cDiaI = LPAD(DAY(dFechaIni::DATE) , 2, '0');
		ELSE
			LET cDiaI = LPAD(DAY((dFechaIni + 1 UNITS DAY)::DATE) , 2, '0');
		END IF;
		LET cMEsI = LPAD(MONTH(dFechaIni::DATE), 2, '0');
		LET cAnioI = LPAD(YEAR(dFechaIni::DATE),4,'0');
		
		--ASIGNA VALOR PARA FECHA FIN
		LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
		LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
		LET cAnio = LPAD(SUBSTRING(YEAR(dFecha_Hoy ::DATE) FROM 3 FOR 2), 2, '0'); 
		LET cAnio2 = YEAR(dFecha_Hoy ::DATE); 

		--SELECCIONA LA RUTA DONDE SE GUARDARA EL ARCHIVO
		SELECT TRIM(ruta_archivo_cobranza )|| TRIM(nombre_archivo_cobranza)
		INTO cRutaArchJAPAC
		FROM "informix".sac_convenios
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

		
		LET cRutaArchJAPAC = REPLACE(cRutaArchJAPAC,'DD',cDia);
		LET cRutaArchJAPAC = REPLACE(cRutaArchJAPAC,'MM',cMes);
		LET cRutaArchJAPAC = REPLACE(cRutaArchJAPAC,'AA',cAnio);
	

		--IMPRIME EL ENCABEZADO DEL ARCHIVO
		LET cStmt='echo "' || '1,001 JAPAC           ,' || cAnioI || cMEsI || cDiaI || ',' || cAnio2 || cMes || cDia || '" >> ' || cRutaArchJAPAC;
			SYSTEM cStmt;
			
		FOREACH

			SELECT fecha_pago,
				LPAD(DAY(fecha_pago::DATE), 2, '0'),
				LPAD(MONTH(fecha_pago::DATE), 2, '0'),
				LPAD(YEAR(fecha_pago::DATE), 4, '0'),
				LPAD(SUBSTR(fecha_insert,12,2),2,'0'),
				LPAD(SUBSTR(fecha_insert,15,2),2,'0'),
				case when origen = 'CPL' then LPAD(REPLACE(NVL(sucursal_cpl,''),'','0'),4,'0') else LPAD(REPLACE(NVL(id_sucursal,''),'','0'),4,'0') end,
				NVL(folio_suc,''),
				NVL(referencia1,''),
				NVL(importe_pago,0)*100,
				NVL(flag_confirmacion_central,0),
				NVL(flag_confirmacion_sucursal,0)
				INTO dFechaPago,cDiaPago,cMesPago,cAnioPago,cHora,cMinuto,cSucursal,cFolio,cReferencia1,iImporte_Pago,iFlagCen,iFlagSuc
				FROM "informix".sac_movimientoshistorial
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio
				AND fecha_pago > dFechaIni
				AND fecha_pago <= dFecha_Hoy
				AND status_cancelado <> 'S'
				AND (flag_confirmacion_central = 1
				OR flag_confirmacion_sucursal = 1)		
				
				IF EXISTS (SELECT 1 FROM bdinteg:"informix".si_sucursales
					WHERE sucursal = cSucursal) THEN
					SELECT NVL(REPLACE(nombre,',',' '),'')
					INTO cNombreSuc
					FROM bdinteg:"informix".si_sucursales
					WHERE sucursal = cSucursal;
				ELSE
					LET cNombreSuc = '';
				END IF;

				--ACTUALIZACION DE FLAG_CONFIRMACION_SUCURSAL = 1 EN CASO DE QUE NO SE HAYA CONFIRMADO EN SUCURSAL POR ALGUN MOTIVO
				IF iFlagCen = 0 OR iFlagSuc = 0 THEN
					SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio AND cancelad <> 'S';
					IF iCuantos = 0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio AND cancelad <> 'S' AND  fech_alt = dFechaPago;
						IF iCuantos = 0 THEN
							CONTINUE FOREACH;
						END IF;
					END IF;
				END IF;

				IF iCuantos > 0 THEN
					UPDATE "informix".sac_movimientoshistorial SET flag_confirmacion_sucursal = '1'
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio
					AND fecha_pago = dFechaPago
					AND folio_suc = cFolio
					AND referencia1 = cReferencia1
					AND status_cancelado <> 'S'
					AND flag_confirmacion_sucursal = 0;
				END IF;

				LET iTotal_Pago = iTotal_Pago + iImporte_Pago ;
				LET iNumPagos = iNumPagos + 1;

				--IMPRIME RENGLON DE LAS OPERACIONES
				LET cStmt = 'echo "' || cTpoOperacion || ',' || SUBSTR(cReferencia1,4,9) || ',' || SUBSTR(cReferencia1,13,9) || ',' || LPAD(iImporte_Pago,9,0) || ',' || cAnioPago || cMesPago || cDiaPago || ',' || cHora || cMinuto || '  ,' || cSucursal || ' ' || RPAD(cNombreSuc, 25,' ') || '" >> ' || cRutaArchJAPAC;
				SYSTEM cStmt;
		END FOREACH;		

		--IMPRIME RENGLON DE TOTAL
		LET cTpoOperacion = '3';			
		LET cStmt = 'echo "' || cTpoOperacion || ',' || RPAD((iNumPagos::CHAR), 4, ' ') || ',' || LPAD(iTotal_Pago, 12, 0) || '" >> ' || cRutaArchJAPAC;
		SYSTEM cStmt;
		
		--ACTUALIZA LA FECHA DEL ULTIMO ARCHIVO GENERADO
		UPDATE "informix".sac_controlarchivoscobranza
		SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

	END;
END PROCEDURE;
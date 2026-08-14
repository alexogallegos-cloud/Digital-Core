CREATE PROCEDURE "informix".sp_reporteliquidaciondepinfona(cId_Convenio CHAR(5) )
   DEFINE cCodret CHAR(5);
   DEFINE cInfoErr CHAR(100);   
   DEFINE iSqlErr,iIsamErr   INTEGER;
   DEFINE iRecEfe INTEGER;
   DEFINE iRecCC INTEGER;
   DEFINE iRecMix INTEGER;
   DEFINE iRecEfeT INTEGER;
   DEFINE iRecCCT INTEGER;
   DEFINE iRecMixT INTEGER;
   DEFINE iRecTot INTEGER;
   DEFINE iRecAux INTEGER;
   DEFINE iRecLun INTEGER;
   DEFINE iRecMAr INTEGER;
   DEFINE iRecMie INTEGER;
   DEFINE iRecJue INTEGER;
   DEFINE iRecVie INTEGER;
   DEFINE iRecSab INTEGER;
   DEFINE iRecDom INTEGER;
   DEFINE deCobEfe MONEY(16,2);
   DEFINE deCobMix MONEY(16,2);
   DEFINE deCobCC MONEY(16,2);
   DEFINE deCobEfeT MONEY(16,2);
   DEFINE deCobMixT MONEY(16,2);
   DEFINE deCobCCT MONEY(16,2);
   DEFINE deCobTot MONEY(16,2);
   DEFINE deCobAux MONEY(16,2);
   DEFINE deCobLun MONEY(16,2);
   DEFINE deCobMar MONEY(16,2);
   DEFINE deCobMie MONEY(16,2);
   DEFINE deCobJue MONEY(16,2);
   DEFINE deCobVie MONEY(16,2);
   DEFINE deCobSab MONEY(16,2);
   DEFINE deCobDom MONEY(16,2);
   DEFINE deTotComision MONEY(16,2);
   DEFINE deTotIvaCom MONEY(16,2);
   DEFINE deComision MONEY(16,2);
   DEFINE deIvaCom MONEY(16,2);
   DEFINE cCategoria CHAR(2);
   DEFINE cConvenio CHAR(3);
   DEFINE dFechaAux DATE;
   DEFINE dfecha_Hoy DATE;
   DEFINE dFechaIni DATE;
   DEFINE cAnioMes CHAR(6);
   DEFINE iNumOpe INTEGER;
   DEFINE mComision MONEY(16,2);
   DEFINE mComisionAux MONEY(16,2);
   DEFINE mIvaCom MONEY(16,2);
   DEFINE mIvaComAux MONEY(16,2);
   DEFINE iFlagCen INTEGER;
   DEFINE iFlagSuc INTEGER;
   DEFINE cFolio CHAR(16);
   DEFINE iCuantos INTEGER;
   DEFINE dPriDiaMes DATE;
   DEFINE dUltDiaMes DATE;

   
   LET cInfoErr = '';
   LET iSqlErr =0;
   LET iIsamErr   = 0;
   LET iRecEfe = 0;
   LET iRecCC = 0;
   LET iRecMix = 0;
   LET iRecMixT = 0;
   LET iRecTot = 0;
   LET iRecAux = 0;
   LET iRecLun = 0;
   LET iRecMAr = 0;
   LET iRecMie = 0;
   LET iRecJue = 0;
   LET iRecVie = 0;
   LET iRecSab = 0;
   LET iRecDom = 0;
   LET deCobEfe = 0;
   LET deCobMix = 0;
   LET deCobCC = 0;
   LET deCobEfeT = 0;
   LET deCobMixT = 0;
   LET deCobTot = 0;
   LET deCobLun = 0;
   LET deCobMar = 0;
   LET deCobMie = 0;
   LET deCobJue = 0;
   LET deCobVie = 0;
   LET deCobSab = 0;
   LET deCobDom = 0;
   LET deComision = 0;
   LET deIvaCom = 0;
   LET dFechaAux = '';
   LET dfecha_Hoy = '';
   LET dFechaIni = '';
   LET dPriDiaMes = '';
   LET dUltDiaMes = '';
   LET cAnioMes = '';
   LET mComision = 0;
   LET mComisionAux = 0;
   LET mIvaCom = 0;
   LET mIvaComAux = 0;
   LET iNumOpe = 0;
   LET iFlagCen = 0; 
   LET iFlagSuc = 0;
   LET cFolio = '';
   LET iCuantos = 0;
   LET cCodret = "00000";
   LET deCobAux = 0;
   LET decobefet = 0;
   LET iRecEfeT = 0;
   LET deCobCCT = 0;
   LET iRecCCT = 0;
   LET deTotComision = 0;
   LET deTotIvaCom = 0;
   LET cCategoria = SUBSTRING(cId_Convenio FROM 1 FOR 2);
   LET cConvenio = SUBSTRING(cId_Convenio FROM 3 FOR 3);

   
   --SET DEBUG FILE TO "/respaldosbd/mario/sp_reporteliquidacionsky.out";
   --TRACE ON; 
   
   BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;

                    UPDATE bdisac:"informix".sac_controlreportesespeciales
                    SET retorno = cCodRet
                    WHERE numcategoria = cCategoria
                    AND numconvenio = cConvenio;

                    EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_reporteliquidacionsky");
                END IF;
        END EXCEPTION;

		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;		
		
        SELECT fecha_hoy, pri_dia_mes, ult_dia_mes
        INTO dfecha_Hoy, dPriDiaMes, dUltDiaMes
        FROM bdisac:"informix".sac_fechas;

        IF TO_CHAR(dfecha_Hoy,"%A") = "Sunday" THEN

                LET dFechaAux = dfecha_Hoy - 6;
                LET dFechaIni = dFechaAux;

                WHILE dFechaAux <= dfecha_Hoy
                      SELECT NVL(SUM(efe),0), NVL(SUM(cc),0), NVL(SUM(mix),0), COUNT(Rec1), COUNT(Rec2), COUNT(Rec3), nvl(SUM(comision), 0), nvl(SUM(iva_com),0)
                      INTO deCobEfe, deCobCC, deCobMix, iRecEfe, iRecCC, iRecMix, deComision, deIvaCom
                      FROM TABLE(
                          MULTISET(
                              SELECT importe_comision_convenio AS comision, iva_comision_convenio AS iva_com,
                                             CASE WHEN forma_pago = 1 THEN NVL(importe_pago, 0) END AS efe,
                                             CASE WHEN forma_pago = 2 THEN NVL(importe_pago, 0) END AS cc,
                                             CASE WHEN forma_pago = 3 THEN NVL(importe_pago, 0) END AS mix,
                                             CASE WHEN forma_pago = 1 THEN folio_suc END AS Rec1,
                                             CASE WHEN forma_pago = 2 THEN folio_suc END AS Rec2,
                                             CASE WHEN forma_pago = 3 THEN folio_suc END AS Rec3
                              FROM bdisac:"informix".sac_movimientoshistorial
                              WHERE numcategoria = cCategoria
                              AND numconvenio = cConvenio
                              AND fecha_pago  = dFechaAux
                              AND status_cancelado = 'N'));

                      LET deCobEfeT = deCobEfeT + deCobEfe + deCobMix;
                      LET deCobCCT = deCobCCT + deCobCC;

                      LET iRecEfeT = iRecEfeT + iRecEfe + iRecMix;
                      LET iRecCCT = iRecCCT + iRecCC;

                      LET deTotComision = deTotComision + deComision;
                      LET deTotIvaCom = deTotIvaCom + deIvaCom;

                      IF TO_CHAR(dFechaAux,"%A") = "Monday" THEN
                           LET iRecLun = iRecEfe + iRecCC + iRecMix;
                           LET deCobLun = deCobEfe + deCobCC + deCobMix;
                      END IF;
                      IF TO_CHAR(dFechaAux,"%A") = "Tuesday" THEN
                          LET iRecMar = iRecEfe + iRecCC + iRecMix;
                          LET deCobMar = deCobEfe + deCobCC + deCobMix;
                      END IF;
                       IF TO_CHAR(dFechaAux,"%A") = "Wednesday" THEN
                           LET iRecMie = iRecEfe + iRecCC + iRecMix;
                          LET deCobMie = deCobEfe + deCobCC + deCobMix;
                      END IF;
                      IF TO_CHAR(dFechaAux,"%A") = "Thursday" THEN
                          LET iRecJue = iRecEfe + iRecCC + iRecMix;
                          LET deCobJue = deCobEfe + deCobCC + deCobMix;
                      END IF;
                      IF TO_CHAR(dFechaAux,"%A") = "Friday"  THEN
                          LET iRecVie = iRecEfe + iRecCC + iRecMix;
                          LET deCobVie = deCobEfe + deCobCC + deCobMix;
                      END IF;
                      IF TO_CHAR(dFechaAux,"%A") = "Saturday"   THEN
                          LET iRecSab = iRecEfe + iRecCC + iRecMix;
                          LET deCobSab = deCobEfe + deCobCC + deCobMix;
                      END IF;
                      IF TO_CHAR(dFechaAux,"%A") = "Sunday" THEN
                          LET iRecDom = iRecEfe + iRecCC + iRecMix;
                          LET deCobDom = deCobEfe + deCobCC + deCobMix;
                      END IF;

                      LET dFechaAux = dFechaAux + 1;

                END WHILE;

	            INSERT INTO bdisac:"informix".sac_liquidacionsemanal (id_convenio, rec_lunes, rec_martes, rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo,
																	  cob_lunes, cob_martes, cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo,
																	  rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred,
																	  cob_efectivo, cob_cheqmb, cob_cheqob, cob_tarcred,
																	  liq_lunes, liq_martes, liq_miercoles, liq_jueves, liq_viernes,
																	  aclaraciones,comision, iva_comision, fec_iniperiodo, fec_finperiodo, liq_resguardo, consecutivo_convenio, fecha_insert)
               VALUES(cId_Convenio,iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom,
                       deCobLun, deCobMar, deCobMie, deCobJue, deCobVie, deCobSab, deCobDom,
                       iRecEfeT, iRecCCT, 0, 0,
                       deCobEfeT, deCobCCT, 0, 0,
                       deCobLun, deCobMar, deCobMie, deCobJue, deCobVie + deCobSab + deCobDom,
	                    0, deTotComision, deTotIvaCom, dFechaIni,dfecha_Hoy, 0, (SELECT NVL(MAX(consecutivo_convenio + 1 ),1) FROM bdisac:"informix".sac_liquidacionsemanal WHERE id_convenio = cCategoria||cConvenio) , CURRENT);
						
        END IF;
        
        IF dfecha_Hoy = dUltDiaMes  THEN
            LET dFechaAux = dPriDiaMes;
            LET cAnioMes = TO_CHAR(dfecha_Hoy,"%Y%m");

            WHILE dFechaAux <= dfecha_Hoy
				
				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iNumOpe = 0;

				FOREACH
					SELECT 
						NVL(importe_comision_convenio,0), 
						NVL(iva_comision_convenio,0),
						flag_confirmacion_central, 
						flag_confirmacion_sucursal,
						folio_suc
					INTO 
						mComisionAux, 
						mIvaComAux,
						iFlagCen,
						iFlagSuc,
						cFolio
					FROM bdisac:"informix".sac_movimientoshistorial
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio
					AND fecha_pago  = dFechaAux
					AND status_cancelado = 'N'
					AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)
					
					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio;
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
				
			INSERT INTO bdisac:"informix".sac_liquidacionmensual(id_convenio, aniomes, fecha, num_operaciones, comision, iva, fecha_insert)
			VALUES(cCategoria||cConvenio, cAnioMes, dFechaAux, iNumOpe, mComision, mIvaCom, CURRENT);
				
				LET dFechaAux = dFechaAux + 1;
            END WHILE;

        END IF;
		
	    UPDATE bdisac:"informix".sac_controlreportesespeciales
	    SET retorno = cCodret
	    WHERE numcategoria = cCategoria
	    AND numconvenio = cConvenio;
		
    END;
END PROCEDURE;
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
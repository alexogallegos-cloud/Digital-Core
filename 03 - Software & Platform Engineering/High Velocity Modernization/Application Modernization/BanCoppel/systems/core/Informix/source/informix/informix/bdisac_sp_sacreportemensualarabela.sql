CREATE PROCEDURE "informix".sp_sacreportemensualarabela(cConvenio CHAR(5), cPeriodo CHAR(6))
RETURNING
	CHAR (6) AS retorno,
	CHAR(6) AS aniomes,
	DATE AS fecha,
	INTEGER AS num_operaciones,
	MONEY (16,2) AS comision,
	MONEY (16,2) AS iva;
    
DEFINE cCodRet					CHAR (6);
DEFINE cAnioMes					CHAR(6);
DEFINE dFecha					DATE ;
DEFINE iNumOperaciones			INTEGER;
DEFINE mComision				MONEY(16,2);
DEFINE mIva						MONEY(16,2);
DEFINE iSqlErr					INTEGER;
DEFINE iIsamErr					INTEGER;
DEFINE cInfoErr                 CHAR(100);

LET cCodRet				= '000000';
LET cAnioMes			= '';
LET dFecha				= '01-01-1900';
LET iNumOperaciones		= 0;
LET mComision			= 0;
LET mIva				= 0;
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET cInfoErr			= '';

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr

		IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportemensualarabela");
				RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva;
		END IF;

	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	
-- SET DEBUG FILE TO  '/tmp/sp_sacreportemensualarabela.out';
-- TRACE ON;

	IF  cPeriodo = "" OR LENGTH(cPeriodo) <> 6 THEN
		LET cCodRet = "00001";
		RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva;
	ELSE   
		SET ISOLATION TO DIRTY READ;
		FOREACH
			
			SELECT aniomes, fecha, num_operaciones, comision, iva
			INTO cAnioMes, dFecha, iNumOperaciones, mComision, mIva
			FROM bdisac:"informix".sac_liquidacionmensual
			WHERE aniomes = cPeriodo
			AND id_convenio = cConvenio
			ORDER BY fecha
			
			RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva
			WITH RESUME;
		END FOREACH;
	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR : Dulce Ramírez',
'DESCRIPCION: Obtiene la informacion para la generacion del reporte mensual Arabela',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : Septiembre 2011',
'VERSION: 20110915.1814',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_sacreportemensualeci(cConvenio CHAR(5), cPeriodo CHAR(6))
RETURNING
	CHAR (6) AS retorno,
	CHAR(6) AS aniomes,
	DATE AS fecha,
	INTEGER AS num_operaciones,
	MONEY (16,2) AS comision,
	MONEY (16,2) AS iva;
    
DEFINE cCodRet					CHAR (6);
DEFINE cAnioMes					CHAR(6);
DEFINE dFecha					DATE ;
DEFINE iNumOperaciones			INTEGER;
DEFINE mComision				MONEY(16,2);
DEFINE mIva						MONEY(16,2);
DEFINE iSqlErr					INTEGER;
DEFINE iIsamErr					INTEGER;
DEFINE cInfoErr                 CHAR(100);

LET cCodRet				= '000000';
LET cAnioMes			= '';
LET dFecha				= '01-01-1900';
LET iNumOperaciones		= 0;
LET mComision			= 0;
LET mIva				= 0;
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET cInfoErr			= '';

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr

		IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportemensualeci");
				RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva;
		END IF;

	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	
-- SET DEBUG FILE TO  '/tmp/sp_sacreportemensualeci.out';
-- TRACE ON;

	IF  cPeriodo = "" OR LENGTH(cPeriodo) <> 6 THEN
		LET cCodRet = "00001";
		RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva;
	ELSE   
		SET ISOLATION TO DIRTY READ;
		FOREACH
			--SELECT {+INDEX (bdisac:sac_liquidacionmensualdish bdisac:"informix".idx_sacliqmesdish)} aniomes, fecha, num_operaciones, comision, iva
			--checar lo index y costos
			SELECT aniomes, fecha, num_operaciones, comision, iva
			INTO cAnioMes, dFecha, iNumOperaciones, mComision, mIva
			FROM bdisac:"informix".sac_liquidacionmensual
			WHERE aniomes = cPeriodo
			AND id_convenio = cConvenio
			ORDER BY fecha
			
			RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva
			WITH RESUME;
		END FOREACH;
	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR : Dulce Ramírez',
'DESCRIPCION: Obtiene la informacion para la generacion del reporte mensual ECI',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : Septiembre 2011',
'VERSION: 20110912.1854',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_sacreportesemanalarabela(sConvenio CHAR (5),iConsecutivo INTEGER)
	RETURNING
		CHAR (6) AS retorno,
        INTEGER AS rec_lunes , 
        INTEGER AS rec_martes, 
        INTEGER AS rec_miercoles, 
        INTEGER AS rec_jueves, 
        INTEGER AS rec_viernes, 
        INTEGER AS rec_sabado, 
        INTEGER AS rec_domingo, 
        MONEY(16,2) AS cob_lunes, 
        MONEY(16,2) AS cob_martes, 
        MONEY(16,2) AS cob_miercoles, 
        MONEY(16,2) AS cob_jueves, 
        MONEY(16,2) AS cob_viernes, 
        MONEY(16,2) AS cob_sabado, 
        MONEY(16,2) AS cob_domingo, 
        INTEGER AS rec_efectivo, 
        INTEGER AS rec_chequemb, 
        INTEGER AS rec_chequeob, 
        INTEGER AS rec_tarcred, 
        MONEY(16,2) AS cob_efectivo, 
        MONEY(16,2) AS cob_cheqmb, 
        MONEY(16,2) AS cob_cheqob, 
        MONEY(16,2) AS cob_tarcred, 
        MONEY(16,2) AS liq_miercoles, 
        MONEY(16,2) AS liq_jueves, 
        MONEY(16,2) AS liq_viernes,
        MONEY(16,2) AS liq_lunes, 
        MONEY(16,2) AS liq_martes, 
        MONEY(16,2) AS aclaraciones, 
        MONEY(16,2) AS comision, 
        MONEY(16,2) AS iva_comision, 
        DATE AS fec_iniperiodo, 
        DATE AS fec_finperiodo, 
        INTEGER AS keyx;
     
		DEFINE cCodRet			CHAR (6);
        DEFINE iRecLunes		INTEGER; 
        DEFINE iRecMartes		INTEGER;
        DEFINE iRecMiercoles	INTEGER;
        DEFINE iRecJueves		INTEGER;
        DEFINE iRecViernes		INTEGER;
        DEFINE iRecSabado		INTEGER;
        DEFINE iRecDomingo		INTEGER;
        DEFINE mCobLunes		MONEY(16,2);
        DEFINE mCobMartes		MONEY(16,2); 
        DEFINE mCobMiercoles	MONEY(16,2);
        DEFINE mCobJueves		MONEY(16,2);
        DEFINE mCobViernes		MONEY(16,2);
        DEFINE mCobSabado		MONEY(16,2);
        DEFINE mCobDomingo		MONEY(16,2);
        DEFINE iRecEfectivo		INTEGER;
        DEFINE iRecChequemb		INTEGER;
        DEFINE iRecChequeob		INTEGER;
        DEFINE iRecTarcred		INTEGER;
        DEFINE mCobEfectivo		INTEGER;
        DEFINE mCobCheqmb		MONEY(16,2);
        DEFINE mCobCheqob		MONEY(16,2);
        DEFINE mCobTarcred		MONEY(16,2);
        DEFINE mLiqMiercoles	MONEY(16,2);
        DEFINE mLiqJueves		MONEY(16,2);
        DEFINE mLiqViernes		MONEY(16,2);
        DEFINE mLiqLunes		MONEY(16,2);
        DEFINE mLiqMartes		MONEY(16,2);
        DEFINE mAclaraciones	MONEY(16,2);
        DEFINE mComision		MONEY(16,2);
        DEFINE mIvaComision		MONEY(16,2);
        DEFINE dFecIniPeriodo	DATE;
        DEFINE dFecFinPeriodo	DATE;
		DEFINE iSqlErr			INTEGER;
		DEFINE iIsamErr			INTEGER;
		DEFINE cInfoErr         CHAR(100);

		LET cCodRet			= '000000';
        LET iRecLunes		= 0;
        LET iRecMartes		= 0;
        LET iRecMiercoles	= 0;
        LET iRecJueves		= 0;
        LET iRecViernes		= 0;
        LET iRecSabado		= 0;
        LET iRecDomingo		= 0;
        LET mCobLunes		= 0;
        LET mCobMartes		= 0;
        LET mCobMiercoles	= 0;
        LET mCobJueves		= 0;
        LET mCobViernes		= 0;
        LET mCobSabado		= 0;
        LET mCobDomingo		= 0;
        LET iRecEfectivo	= 0;
        LET iRecChequemb	= 0;
        LET iRecChequeob	= 0;
        LET iRecTarcred		= 0;
        LET mCobEfectivo	= 0;
        LET mCobCheqmb		= 0;
        LET mCobCheqob		= 0;
        LET mCobTarcred		= 0;
        LET mLiqMiercoles	= 0;
        LET mLiqJueves		= 0;
        LET mLiqViernes		= 0;
        LET mLiqLunes		= 0;
        LET mLiqMartes		= 0;
        LET mAclaraciones	= 0;
        LET mComision		= 0;
        LET mIvaComision	= 0;
        LET dFecIniPeriodo	= '01-01-1900';
        LET dFecFinPeriodo	= '01-01-1900';
		LET iSqlErr			= 0;
		LET iIsamErr		= 0;
		LET cInfoErr		= '';

		BEGIN
			ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr

				IF iSqlErr <> 0 THEN
						LET cCodRet = iSqlErr;
						EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportesemanalarabela");
						RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes, 
							mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, mCobEfectivo, 
							mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqLunes, mLiqMartes, mAclaraciones, mComision, 
							mIvaComision, dFecIniPeriodo, dFecFinPeriodo, iConsecutivo;
				END IF;

			END EXCEPTION;
			
			SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO  '/tmp/sp_sacreportesemanalARA.out';
	 --TRACE ON;

			IF  iConsecutivo IS NULL THEN
				LET cCodRet = "00001";
				RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes, 
					mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, mCobEfectivo, 
					mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqLunes, mLiqMartes, mAclaraciones, mComision, 
					mIvaComision, dFecIniPeriodo, dFecFinPeriodo, iConsecutivo;
			ELSE   
				SET ISOLATION TO DIRTY READ;
					FOREACH
						SELECT {+INDEX (bdisac:"informix".sac_liquidacionsemanal idx_sacliqsem)} rec_lunes, rec_martes, rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo, cob_lunes, cob_martes, 
							cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo, rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred, 
							cob_efectivo, cob_cheqmb, cob_cheqob, cob_tarcred, liq_miercoles, liq_jueves, liq_viernes, liq_lunes, liq_martes, 
							aclaraciones, comision, iva_comision, fec_iniperiodo, fec_finperiodo
						INTO iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes, 
							mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, mCobEfectivo, 
							mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqLunes, mLiqMartes, mAclaraciones, mComision, 
							mIvaComision, dFecIniPeriodo, dFecFinPeriodo 
						FROM bdisac:"informix".sac_liquidacionsemanal
						WHERE id_convenio = sConvenio 
						AND  consecutivo_convenio  = iConsecutivo 
						
												
						RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes, 
							mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, mCobEfectivo, 
							mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqLunes, mLiqMartes, mAclaraciones, mComision, 
							mIvaComision, dFecIniPeriodo, dFecFinPeriodo, iConsecutivo
						WITH RESUME;
					END FOREACH;
			END IF;
		END;
	END PROCEDURE
	DOCUMENT
	'AUTOR : Dulce Ramirez',
	'DESCRIPCION: Consulta la informacion para la generacion del reporte de liquidacion semanal de pagos Arabela',
	'EJECUTADO O LLAMADO POR: repsac.exe',
	'FECHA : Septiembre 2011',
	'VERSION: 20110912.0640',
	'BD    : bdisac';

CREATE PROCEDURE "informix".sp_sacreportesemanaleci(sConvenio CHAR (5), iConsecutivo INTEGER)
	RETURNING
		CHAR (6) AS retorno,
        INTEGER AS rec_lunes , 
        INTEGER AS rec_martes, 
        INTEGER AS rec_miercoles, 
        INTEGER AS rec_jueves, 
        INTEGER AS rec_viernes, 
        INTEGER AS rec_sabado, 
        INTEGER AS rec_domingo, 
        MONEY(16,2) AS cob_lunes, 
        MONEY(16,2) AS cob_martes, 
        MONEY(16,2) AS cob_miercoles, 
        MONEY(16,2) AS cob_jueves, 
        MONEY(16,2) AS cob_viernes, 
        MONEY(16,2) AS cob_sabado, 
        MONEY(16,2) AS cob_domingo, 
        INTEGER AS rec_efectivo, 
        INTEGER AS rec_chequemb, 
        INTEGER AS rec_chequeob, 
        INTEGER AS rec_tarcred, 
        MONEY(16,2) AS cob_efectivo, 
        MONEY(16,2) AS cob_cheqmb, 
        MONEY(16,2) AS cob_cheqob, 
        MONEY(16,2) AS cob_tarcred, 
        MONEY(16,2) AS liq_miercoles, 
        MONEY(16,2) AS liq_jueves, 
        MONEY(16,2) AS liq_viernes,
        MONEY(16,2) AS liq_lunes, 
        MONEY(16,2) AS liq_martes, 
        MONEY(16,2) AS aclaraciones, 
        MONEY(16,2) AS comision, 
        MONEY(16,2) AS iva_comision, 
        DATE AS fec_iniperiodo, 
        DATE AS fec_finperiodo, 
        INTEGER AS keyx;
     
		DEFINE cCodRet			CHAR (6);
        DEFINE iRecLunes		INTEGER; 
        DEFINE iRecMartes		INTEGER;
        DEFINE iRecMiercoles	INTEGER;
        DEFINE iRecJueves		INTEGER;
        DEFINE iRecViernes		INTEGER;
        DEFINE iRecSabado		INTEGER;
        DEFINE iRecDomingo		INTEGER;
        DEFINE mCobLunes		MONEY(16,2);
        DEFINE mCobMartes		MONEY(16,2); 
        DEFINE mCobMiercoles	MONEY(16,2);
        DEFINE mCobJueves		MONEY(16,2);
        DEFINE mCobViernes		MONEY(16,2);
        DEFINE mCobSabado		MONEY(16,2);
        DEFINE mCobDomingo		MONEY(16,2);
        DEFINE iRecEfectivo		INTEGER;
        DEFINE iRecChequemb		INTEGER;
        DEFINE iRecChequeob		INTEGER;
        DEFINE iRecTarcred		INTEGER;
        DEFINE mCobEfectivo		INTEGER;
        DEFINE mCobCheqmb		MONEY(16,2);
        DEFINE mCobCheqob		MONEY(16,2);
        DEFINE mCobTarcred		MONEY(16,2);
        DEFINE mLiqMiercoles	MONEY(16,2);
        DEFINE mLiqJueves		MONEY(16,2);
        DEFINE mLiqViernes		MONEY(16,2);
        DEFINE mLiqLunes		MONEY(16,2);
        DEFINE mLiqMartes		MONEY(16,2);
        DEFINE mAclaraciones	MONEY(16,2);
        DEFINE mComision		MONEY(16,2);
        DEFINE mIvaComision		MONEY(16,2);
        DEFINE dFecIniPeriodo	DATE;
        DEFINE dFecFinPeriodo	DATE;
        
		DEFINE iSqlErr			INTEGER;
		DEFINE iIsamErr			INTEGER;
		DEFINE cInfoErr         CHAR(100);

		LET cCodRet			= '000000';
        LET iRecLunes		= 0;
        LET iRecMartes		= 0;
        LET iRecMiercoles	= 0;
        LET iRecJueves		= 0;
        LET iRecViernes		= 0;
        LET iRecSabado		= 0;
        LET iRecDomingo		= 0;
        LET mCobLunes		= 0;
        LET mCobMartes		= 0;
        LET mCobMiercoles	= 0;
        LET mCobJueves		= 0;
        LET mCobViernes		= 0;
        LET mCobSabado		= 0;
        LET mCobDomingo		= 0;
        LET iRecEfectivo	= 0;
        LET iRecChequemb	= 0;
        LET iRecChequeob	= 0;
        LET iRecTarcred		= 0;
        LET mCobEfectivo	= 0;
        LET mCobCheqmb		= 0;
        LET mCobCheqob		= 0;
        LET mCobTarcred		= 0;
        LET mLiqMiercoles	= 0;
        LET mLiqJueves		= 0;
        LET mLiqViernes		= 0;
        LET mLiqLunes		= 0;
        LET mLiqMartes		= 0;
        LET mAclaraciones	= 0;
        LET mComision		= 0;
        LET mIvaComision	= 0;
        LET dFecIniPeriodo	= '01-01-1900';
        LET dFecFinPeriodo	= '01-01-1900';
        
		LET iSqlErr			= 0;
		LET iIsamErr		= 0;
		LET cInfoErr		= '';

		BEGIN
			ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr

				IF iSqlErr <> 0 THEN
						LET cCodRet = iSqlErr;
						EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportesemanaleci");
						RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes, 
							mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, mCobEfectivo, 
							mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqLunes, mLiqMartes, mAclaraciones, mComision, 
							mIvaComision, dFecIniPeriodo, dFecFinPeriodo, iConsecutivo;
				END IF;

			END EXCEPTION;

			SET LOCK MODE TO WAIT 3;
			
	--SET DEBUG FILE TO  '/tmp/sp_sacreportesemanalECI.out';
	-- TRACE ON;

			IF  iConsecutivo IS NULL THEN
				LET cCodRet = "00001";
				RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes, 
					mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, mCobEfectivo, 
					mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqLunes, mLiqMartes, mAclaraciones, mComision, 
					mIvaComision, dFecIniPeriodo, dFecFinPeriodo, iConsecutivo;
			ELSE   
				SET ISOLATION TO DIRTY READ;
					FOREACH
					
					
						SELECT {+INDEX (bdisac:"informix".sac_liquidacionsemanal idx_sacliqsem)} rec_lunes, rec_martes, rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo, cob_lunes, cob_martes, 
							cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo, rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred, 
							cob_efectivo, cob_cheqmb, cob_cheqob, cob_tarcred, liq_miercoles, liq_jueves, liq_viernes, liq_lunes, liq_martes, 
							aclaraciones, comision, iva_comision, fec_iniperiodo, fec_finperiodo 
						INTO iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes, 
							mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, mCobEfectivo, 
							mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqLunes, mLiqMartes, mAclaraciones, mComision, 
							mIvaComision, dFecIniPeriodo, dFecFinPeriodo 
						FROM bdisac:"informix".sac_liquidacionsemanal
						WHERE id_convenio = sConvenio
						AND consecutivo_convenio  = iConsecutivo 
						
						
						RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes, 
							mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, mCobEfectivo, 
							mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqLunes, mLiqMartes, mAclaraciones, mComision, 
							mIvaComision, dFecIniPeriodo, dFecFinPeriodo, iConsecutivo
						WITH RESUME;
					END FOREACH;
			END IF;
		END;
	END PROCEDURE
	DOCUMENT
	'AUTOR : Dulce Ramirez',
	'DESCRIPCION: Consulta la informacion para la generacion del reporte de liquidacion semanal de pagos ECI',
	'EJECUTADO O LLAMADO POR: repsac.exe',
	'FECHA : Septiembre 2011',
	'VERSION: 20110915.0534',
	'BD    : bdisac';

CREATE PROCEDURE "informix".sp_reportebts_edocta(pdFechaIni DATE, pdFechaFin DATE, pUsuario CHAR (9))

RETURNING
CHAR(10) AS fecha, 
CHAR(14) AS saldo_inicial,
CHAR(10) AS total_abonos,
CHAR(14) AS monto_total_abonos,
CHAR(10) AS total_cargos,
CHAR(14) AS monto_total_cargos,
CHAR(14) AS saldo_final,
CHAR(20) AS cuenta_concentradora,
CHAR(18) AS cuenta_clabe,
CHAR(5) AS cod_ret;

--***************************************************************************************************
-- DESCRIPCION:  GENERA REPORTE ESTADO DE CUENTA BTS
-- AUTOR : ROCHIN ROCHA EDGAR IVAN
-- FECHA : 2011/08/30
-- BD: BDISAC
-- SISTEMA : BTS
--***************************************************************************************************

DEFINE vsCodRet				CHAR(5);
DEFINE viSqlErr				INTEGER;
DEFINE vdFechaIni			DATE;
DEFINE vdFechaFin			DATE;
DEFINE vsFechaIni			CHAR(10);
DEFINE vsFechaAnt			CHAR(10);
DEFINE vsFechaParam         CHAR(10);
DEFINE vdFechaParam         DATE;
DEFINE vsAnioMes			CHAR(6);
DEFINE vsAnioMesAnt			CHAR(6);
DEFINE vsMes 			CHAR(6);
DEFINE vsCtaConcentradora	CHAR(20);
DEFINE vsCtaClabe			CHAR(20);
DEFINE vsNomTabla 			CHAR (30);


DEFINE vsFecha				CHAR(10);
DEFINE vsSaldoInicial		CHAR(14);
DEFINE vsTotalAbonos		CHAR(10);
DEFINE vsMontoTotalAbonos	CHAR(14);
DEFINE vsTotalCargos		CHAR(10);
DEFINE vsMontoTotalCargos	CHAR(14);
DEFINE vsSaldoFinal			CHAR(14);
DEFINE vsAnioInicio			char (4);
DEFINE vsAnioFin			CHAR(4);
DEFINE vsAniohoy			CHAR(4);
DEFINE vsMesIni				CHAR(4);	
DEFINE vsAnioMesIni			CHAR(14);
DEFINE vsAnioMesFin			CHAR(14);
DEFINE vdFechahoy			DATE;
--DEFINE vsql        char(200);
DEFINE vsNomTablaInicio     CHAR (30);
DEFINE vsNomTablaFin 	CHAR (30);
DEFINE iBandera 			INTEGER;
DEFINE vsSQL CHAR (1800) ;
DEFINE vsSQL1 CHAR (800);
DEFINE vsSQL2 CHAR (900) ;
DEFINE vsSQL3 CHAR (50) ;

LET vsSQL = '' ;
LET vsSQL1 = '' ;
LET vsSQL2 = '' ;
LET vsSQL3 = '' ;

LET vsNomTablaFin = ""; 
LET vsNomTablaInicio = "";
--LET vsql = "";
LET vsCodRet = "";
LET viSqlErr = 0;
LET vdFechaIni = CURRENT;
LET vdFechaFin = CURRENT;
LET vsFechaIni = "";
LET vsFechaAnt = "";
LET vsFechaParam = "";
LET vsAnioMes = "";
LET vsMes = "";
LET vsAnioMesAnt = "";
LET vsCtaConcentradora = "";
LET vsCtaClabe = "";

LET vsFecha = "";
LET vsSaldoInicial = "";
LET vsTotalAbonos = "0";
LET vsMontoTotalAbonos = "";
LET vsTotalCargos = "0";
LET vsMontoTotalCargos = "";
LET vsSaldoFinal = "";
LET vsAnioInicio		= "";
LET vsAnioFin		= "";
LET vsAniohoy		= "";
LET vsMes			= "";
LET vsAnioMesIni	= "";
LET vsAnioMesFin	= "";
LET vdFechahoy  =CURRENT;
LET vsNomTabla = "";
LET iBandera   = 0 ;

--SET DEBUG FILE TO "/respaldosbd/cris/sp_reportebts_edocta.out";
--TRACE ON;

BEGIN

	ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado
		IF viSqlErr <> 0 THEN
			--RETURN vsFecha, vsSaldoInicial, vsTotalAbonos, vsMontoTotalAbonos, vsTotalCargos, vsMontoTotalCargos, vsSaldoFinal, vsCtaConcentradora, vsCtaClabe, viSqlErr;
			RETURN vsFechaIni, NVL(vsSaldoInicial, 0.00),  vsTotalAbonos, NVL(vsMontoTotalAbonos, 0.00), vsTotalCargos, NVL(vsMontoTotalCargos, 0.00), NVL(vsSaldoFinal, 0.00), NVL(vsCtaConcentradora,''), NVL(vsCtaClabe,''), viSqlErr;
		END IF;
	END EXCEPTION;

	--Verifica parametros nulos o en blanco.
IF( pdFechaIni == "" OR pdFechaIni IS NULL ) OR ( pdFechaFin == "" OR pdFechaFin IS NULL )THEN
	LET vsCodRet = "00001";
	--RETURN vsFecha, vsSaldoInicial, vsTotalAbonos, vsMontoTotalAbonos, vsTotalCargos, vsMontoTotalCargos, vsSaldoFinal, vsCtaConcentradora, vsCtaClabe, vsCodRet;
	RETURN vsFechaIni, NVL(vsSaldoInicial, 0.00),  vsTotalAbonos, NVL(vsMontoTotalAbonos, 0.00), vsTotalCargos, NVL(vsMontoTotalCargos, 0.00), NVL(vsSaldoFinal, 0.00), NVL(vsCtaConcentradora,''), NVL(vsCtaClabe,''), viSqlErr ;
ELSE
	--Se asignan a variables los parametros recibidos.
	LET vdFechaIni = pdFechaIni;
	LET vdFechaFin = pdFechaFin;
	--Se obtiene el numero de cuenta concentradora y numero de cuenta clabe para BTS.
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	/*
	SELECT cuenta_prestadora INTO vsCtaConcentradora FROM bdisac:"informix".sac_convenios WHERE numcategoria = '07' AND numconvenio = '004';
	SELECT numcuentaclabe INTO vsCtaClabe FROM bdisac:"informix".sac_convenios WHERE numcategoria = '07' AND numconvenio = '004';
	*/
	SELECT cuenta_prestadora , numcuentaclabe INTO vsCtaConcentradora,vsCtaClabe
	FROM bdisac:"informix".sac_convenios WHERE numcategoria = '07' AND numconvenio = '004';	
	
	select valor INTO vsFechaParam FROM bdicheq:"informix".sc_param where codparam='fechcon_movhis';
	select fecha_hoy INTO vdFechahoy FROM bdicheq:"informix".sc_fechas WHERE empresa = '001';
		
	DELETE FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE USUARIO = pUsuario;
	
	LET vsAnioInicio = TRIM(SUBSTRING(vdFechaIni FROM 7 FOR 4));	
	LET vsAnioFin = TRIM(SUBSTRING(vdFechaFin FROM 7 FOR 4));	
	LET vsAniohoy =  TRIM(SUBSTRING(vdFechahoy FROM 7 FOR 4));	
	LET vsMesIni = TRIM(SUBSTRING(vdFechaIni FROM 1 FOR 2));
	LET vsAnioMesIni = TRIM(SUBSTRING(vdFechaIni FROM 7 FOR 4)) || TRIM(SUBSTRING(vdFechaIni FROM 1 FOR 2));
	LET vsAnioMesFin = TRIM(SUBSTRING(vdFechaFin FROM 7 FOR 4)) || TRIM(SUBSTRING(vdFechaFin FROM 1 FOR 2));
	
		
	LET vsSQL1 = 'echo " SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; INSERT INTO sc_sdodiarioc_edocta(cuenta,aniomes,sucursal,capvig1,intprovnp1,capvig2,intprovnp2,capvig3,intprovnp3,'
	||'capvig4,intprovnp4,capvig5,intprovnp5,capvig6,intprovnp6,capvig7,intprovnp7,capvig8,intprovnp8,capvig9,intprovnp9,capvig10,intprovnp10,'
	||'capvig11,intprovnp11,capvig12,intprovnp12,capvig13,intprovnp13,capvig14,intprovnp14,capvig15,intprovnp15,capvig16,intprovnp16,capvig17,'
	||'intprovnp17,capvig18,intprovnp18,capvig19,intprovnp19,capvig20,intprovnp20,capvig21,intprovnp21,capvig22,intprovnp22,capvig23,'
	||'intprovnp23,capvig24,intprovnp24,capvig25,intprovnp25,capvig26,intprovnp26,capvig27,intprovnp27,capvig28,intprovnp28,capvig29,'
	||'intprovnp29,capvig30,intprovnp30,capvig31,intprovnp31,capvigacum,diacum,usuario)';

	LET vsSQL3= '" > /tmp/sc_sdodiarioc_edocta.sql';
		
		
	IF (vsAnioInicio  = vsAnioFin ) AND (vsMesIni <> '01' )THEN
			IF ( vsAnioInicio = vsAniohoy) THEN
				LET vsNomTabla  = "sc_sdodiarioc";
			ELSE
				LET vsNomTabla  =  "sc_sdodiarioc_" || vsAnioInicio;
			END IF ;
			
		LET vsMesIni = vsMesIni::INTEGER - 1;
        LET vsAnioMesIni =  vsAnioInicio || LPAD(vsMesIni::CHAR,2,'0') ;
		LET  vsAnioMesIni = vsAnioMesIni;		
			
		IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE  tabname = vsNomTabla) THEN      	
			LET vsSQL2 = 'SELECT cuenta,aniomes,sucursal,capvig1,intprovnp1,capvig2,intprovnp2,capvig3,intprovnp3,capvig4,intprovnp4,capvig5,'
			||'intprovnp5,capvig6,intprovnp6,capvig7,intprovnp7,capvig8,intprovnp8,capvig9,intprovnp9,capvig10,intprovnp10,capvig11,intprovnp11,'
			||'capvig12,intprovnp12,capvig13,intprovnp13,capvig14,intprovnp14,capvig15,intprovnp15,capvig16,intprovnp16,capvig17,intprovnp17,capvig18,'
			||'intprovnp18,capvig19,intprovnp19,capvig20,intprovnp20,capvig21,intprovnp21,capvig22,intprovnp22,capvig23,intprovnp23,capvig24,'
			||'intprovnp24,capvig25,intprovnp25,capvig26,intprovnp26,capvig27,intprovnp27,capvig28,intprovnp28,capvig29,intprovnp29,capvig30,'
			||'intprovnp30,capvig31,intprovnp31,capvigacum,diacum,'''||TRIM(pUsuario)||''' FROM bdicheq:"informix".'
			|| TRIM (vsNomTabla ) || ' WHERE cuenta = '''|| TRIM( vsCtaConcentradora ) ||''' AND aniomes BETWEEN ''' || TRIM(vsAnioMesIni) || ''' AND ''' || TRIM(vsAnioMesFin) || '''';
			
			LET vsSQL1 = TRIM(vsSQL1);
			LET vsSQL2 = TRIM (vsSQL2);
			LET vsSQL3 = TRIM(vsSQL3);		
			LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;
			LET vsSQL = TRIM(vsSQL);
			SYSTEM  vsSQL ;
			LET vsSQL = '';
			LET vsSQL = 'dbaccess bdicheq /tmp/sc_sdodiarioc_edocta.sql';
			LET vsSQL = TRIM(vsSQL);
			SYSTEM vsSQL;
		END IF;
	ELSE
		
			
			IF (vsMesIni = '01') AND (vsAnioInicio  = vsAnioFin ) THEN
			
				LET vsAnioInicio = vsAnioInicio::INTEGER  - 1;
				LET vsAnioMesIni =  vsAnioInicio || '12' ;			
			
				IF (vsAnioFin = vsAniohoy ) THEN
					LET vsNomTablaInicio  =  "sc_sdodiarioc_" || vsAnioInicio;
					LET vsNomTablaFin =  "sc_sdodiarioc" ;
				ELSE
					LET vsNomTablaInicio  =  "sc_sdodiarioc_" || TRIM(vsAnioInicio);
					LET vsNomTablaFin =  "sc_sdodiarioc_" || TRIM(vsAnioFin) ;				
				END IF;
			ELSE		
				
				LET vsMesIni = vsMesIni::INTEGER - 1;
                LET vsAnioMesIni =  vsAnioInicio || LPAD(vsMesIni::CHAR,2,'0') ;
				LET vsAnioMesIni = vsAnioMesIni;
				IF (vsAnioFin <> vsAniohoy ) THEN
					LET vsNomTablaInicio  =  "sc_sdodiarioc_" || TRIM(vsAnioInicio);
					LET vsNomTablaFin =  "sc_sdodiarioc_" || TRIM(vsAnioFin) ;
				ELSE
					LET vsNomTablaInicio  =  "sc_sdodiarioc_" || TRIM(vsAnioInicio) ;
					LET vsNomTablaFin =  "sc_sdodiarioc";
				END IF;
				
			END IF;
			
			IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames   WHERE  tabname = vsNomTablaInicio) THEN      
  			
				LET vsSQL2 = 'SELECT cuenta,aniomes,sucursal,capvig1,intprovnp1,capvig2,intprovnp2,capvig3,intprovnp3,capvig4,intprovnp4,capvig5,'
				||'intprovnp5,capvig6,intprovnp6,capvig7,intprovnp7,capvig8,intprovnp8,capvig9,intprovnp9,capvig10,intprovnp10,capvig11,intprovnp11,'
				||'capvig12,intprovnp12,capvig13,intprovnp13,capvig14,intprovnp14,capvig15,intprovnp15,capvig16,intprovnp16,capvig17,intprovnp17,capvig18,'
				||'intprovnp18,capvig19,intprovnp19,capvig20,intprovnp20,capvig21,intprovnp21,capvig22,intprovnp22,capvig23,intprovnp23,capvig24,'
				||'intprovnp24,capvig25,intprovnp25,capvig26,intprovnp26,capvig27,intprovnp27,capvig28,intprovnp28,capvig29,intprovnp29,capvig30,'
				||'intprovnp30,capvig31,intprovnp31,capvigacum,diacum, ''' || TRIM(pUsuario) || ''' FROM bdicheq:"informix".'
				|| TRIM (vsNomTablaInicio) || ' WHERE  cuenta = '''|| TRIM(vsCtaConcentradora ) ||''' AND aniomes BETWEEN ''' || TRIM(vsAnioMesIni) || ''' AND ''' || TRIM(vsAnioMesFin) || '''';
				
				LET vsSQL1 = TRIM(vsSQL1);
				LET vsSQL2 = TRIM (vsSQL2);
				LET vsSQL3 = TRIM(vsSQL3);		
				LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;
				LET vsSQL = TRIM(vsSQL);
				SYSTEM  vsSQL ;
				LET vsSQL = '';
				LET vsSQL = 'dbaccess bdicheq /tmp/sc_sdodiarioc_edocta.sql';
				LET vsSQL = TRIM(vsSQL);
				SYSTEM vsSQL;
			END IF;
			
			IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames   WHERE  tabname = vsNomTablaFin) THEN
				LET  vsSQL2 = "";
				LET vsSQL2 = 'SELECT cuenta,aniomes,sucursal,capvig1,intprovnp1,capvig2,intprovnp2,capvig3,intprovnp3,capvig4,intprovnp4,capvig5,'
				||'intprovnp5,capvig6,intprovnp6,capvig7,intprovnp7,capvig8,intprovnp8,capvig9,intprovnp9,capvig10,intprovnp10,capvig11,intprovnp11,'
				||'capvig12,intprovnp12,capvig13,intprovnp13,capvig14,intprovnp14,capvig15,intprovnp15,capvig16,intprovnp16,capvig17,intprovnp17,capvig18,'
				||'intprovnp18,capvig19,intprovnp19,capvig20,intprovnp20,capvig21,intprovnp21,capvig22,intprovnp22,capvig23,intprovnp23,capvig24,'
				||'intprovnp24,capvig25,intprovnp25,capvig26,intprovnp26,capvig27,intprovnp27,capvig28,intprovnp28,capvig29,intprovnp29,capvig30,'
				||'intprovnp30,capvig31,intprovnp31,capvigacum,diacum, ''' || TRIM(pUsuario) || ''' FROM bdicheq:"informix".'		
				|| TRIM(vsNomTablaFin) || ' WHERE cuenta = '''|| TRIM(vsCtaConcentradora ) ||''' AND aniomes BETWEEN ''' || TRIM(vsAnioMesIni) || ''' AND ''' || TRIM(vsAnioMesFin) || '''';
				
				LET vsSQL1 = TRIM(vsSQL1);
				LET vsSQL2 = TRIM (vsSQL2);
				LET vsSQL3 = TRIM(vsSQL3);		
				LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;
				LET vsSQL = TRIM(vsSQL);
				SYSTEM  vsSQL ;
				LET vsSQL = '';
				LET vsSQL = 'dbaccess bdicheq /tmp/sc_sdodiarioc_edocta.sql';
				LET vsSQL = TRIM(vsSQL);
				SYSTEM vsSQL;
			END IF;
		
	END IF;
	
    LET vdFechaParam = vsFechaParam;	
	
	
	IF  DAY (vdFechaIni)  = 2 AND MONTH(vdFechaIni) =  1 THEN 
		LET iBandera = 1;					
	END IF;
	IF EXISTS(SELECT aniomes FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes <> '' AND usuario = pUsuario) THEN
		--Trabaja mientras la fecha inicial sea menor o igual a la fecha final.
		WHILE(vdFechaIni <= vdFechaFin)
			--Se asigna a variable la fecha inicio.
			LET vsFechaIni = vdFechaIni;
			--Se asigna a variable año y mes de la fecha inicio.
			LET vsAnioMes = TRIM(SUBSTRING(vdFechaIni FROM 7 FOR 4)) || TRIM(SUBSTRING(vdFechaIni FROM 1 FOR 2));
			LET vsMes = TRIM(SUBSTRING(vdFechaIni FROM 1 FOR 2));
			--Verifica si es el dia primero del mes.
			IF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "01" )THEN
				--Se le resta un dia a la fecha inicio y se asigna a variable, en este caso sera el ultimo dia del mes anterior.
				LET vsFechaAnt = vdFechaIni - INTERVAL (1) DAY TO DAY;
				--Se asigna a variable año y mes del dia anterior.
				LET vsAnioMesAnt = TRIM(SUBSTRING(vsFechaAnt FROM 1 FOR 4)) || TRIM(SUBSTRING(vsFechaAnt FROM 6 FOR 2));
				--Verifica que dia fue el anterior, 28, 29, 30 o 31, dependiendo que dia resulte ser obtendra el capital vigente de ese dia.
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				IF( TRIM(SUBSTRING(vsFechaAnt FROM 9 FOR 2)) = "28" )THEN
					SELECT capvig28 INTO vsSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMesAnt AND usuario = pUsuario;
				ELIF( TRIM(SUBSTRING(vsFechaAnt FROM 9 FOR 2)) = "29" )THEN
					SELECT capvig29 INTO vsSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMesAnt AND usuario = pUsuario;
				ELIF( TRIM(SUBSTRING(vsFechaAnt FROM 9 FOR 2)) = "30" )THEN
					SELECT capvig30 INTO vsSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMesAnt AND usuario = pUsuario;
				ELIF( TRIM(SUBSTRING(vsFechaAnt FROM 9 FOR 2)) = "31" )THEN			
					SELECT capvig31 INTO vsSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMesAnt AND usuario = pUsuario;					
				END IF;
				
				--Se obtiene el capital vigente del primer dia del mes.
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				LET vsCtaConcentradora = vsCtaConcentradora;
				LET vsAnioMes = vsAnioMes;
				
				IF vsMes <>"01" THEN
					SELECT capvig1 INTO vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
				ELSE
					LET vsSaldoFinal = "";
					LET vsSaldoFinal = vsSaldoInicial;
				END IF ;
				
				--Respectivamente se obtendra el capital vigente de cada dia correspondiente al rango de fechas a procesar.
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "02" )THEN			
				
				IF vsMes <> '01' THEN
					SELECT capvig1 ,capvig2 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
				ELSE
					IF iBandera = 1 THEN 
						LET vsFechaAnt = vdFechaIni - INTERVAL (2) DAY TO DAY;
					--Se asigna a variable año y mes del dia anterior.
						LET vsAnioMesAnt = TRIM(SUBSTRING(vsFechaAnt FROM 1 FOR 4)) || TRIM(SUBSTRING(vsFechaAnt FROM 6 FOR 2));
					--Verifica que dia fue el anterior, 28, 29, 30 o 31, dependiendo que dia resulte ser obtendra el capital vigente de ese dia.
						SELECT capvig31 INTO vsSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMesAnt AND usuario = pUsuario;												
						LET iBandera = 0 ;
					ELSE					
						LET vsSaldoInicial = "";
						LET vsSaldoInicial= vsSaldoFinal;
					END IF;
					SELECT capvig2 INTO vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
					
				END IF; 
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "03" )THEN
					SELECT capvig2 ,capvig3 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "04" )THEN
					SELECT capvig3 ,capvig4 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "05" )THEN
					SELECT capvig4 ,capvig5 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "06" )THEN
					SELECT capvig5 ,capvig6 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "07" )THEN
					SELECT capvig6 ,capvig7 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "08" )THEN
					SELECT capvig7 ,capvig8 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "09" )THEN
					SELECT capvig8 ,capvig9 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "10" )THEN
					SELECT capvig9 ,capvig10 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "11" )THEN
					SELECT capvig10 ,capvig11 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "12" )THEN
					SELECT capvig11 ,capvig12 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "13" )THEN
					SELECT capvig12 ,capvig13 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "14" )THEN
					SELECT capvig13 ,capvig14 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "15" )THEN
					SELECT capvig14 ,capvig15 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "16" )THEN					
					SELECT capvig15 ,capvig16 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "17" )THEN
					SELECT capvig16 ,capvig17 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "18" )THEN			
					SELECT capvig17 ,capvig18 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "19" )THEN				
					SELECT capvig18 ,capvig19 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "20" )THEN
					SELECT capvig19 ,capvig20 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "21" )THEN				
					SELECT capvig20 ,capvig21 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "22" )THEN				
					SELECT capvig21 ,capvig22 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "23" )THEN
					SELECT capvig22 ,capvig23 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "24" )THEN				
					SELECT capvig23 ,capvig24 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "25" )THEN
					IF vsMes <>"12" THEN
					
						SELECT capvig24 ,capvig25 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
					ELSE
						--	SELECT capvig24 INTO vsSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
						--	SELECT capvig24 INTO vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
						SELECT capvig24 ,capvig24 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
					END IF;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "26" )THEN
				if vsMes <>"12" THEN
						--	SELECT capvig25 INTO vsSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
						--	SELECT capvig26 INTO vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
							SELECT capvig25 ,capvig26 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
				ELSE
						--	SELECT capvig24 INTO vsSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
						--	SELECT capvig26 INTO vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
							SELECT capvig24 ,capvig26 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
				END if;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "27" )THEN
			--	SELECT capvig26 INTO vsSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
			--	SELECT capvig27 INTO vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
				SELECT capvig26 ,capvig27 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "28" )THEN
			--	SELECT capvig27 INTO vsSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
			--	SELECT capvig28 INTO vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
				SELECT capvig27 ,capvig28 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "29" )THEN
			--	SELECT capvig28 INTO vsSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
			--	SELECT capvig29 INTO vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
				SELECT capvig28 ,capvig29 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "30" )THEN
			--	SELECT capvig29 INTO vsSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
			--	SELECT capvig30 INTO vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
				SELECT capvig29 ,capvig30 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "31" )THEN
			--	SELECT capvig30 INTO vsSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
			--	SELECT capvig31 INTO vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
				SELECT capvig30 ,capvig31 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			END IF;
			
			--Se obtiene la cantidad de transacciones y el monto total de las transacciones de abono correspondientes del dia a consultar.
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			
	--		IF vsFechaIni >= vsFechaParam THEN
			IF vdFechaIni >= vdFechaParam THEN		
			SELECT COUNT(transacc), SUM(monto_tot) INTO vsTotalAbonos, vsMontoTotalAbonos FROM bdicheq:"informix".sc_movhis AS movhis, bdinteg:"informix".si_transacc AS trans WHERE movhis.fech_alt = vdFechaIni and movhis.cuenta = vsCtaConcentradora AND movhis.transacc = trans.numero AND trans.naturaleza = "A" AND movhis.cancelad <> 'S';
				--ELIF vsFechaIni <= vsFechaParam THEN
				--SELECT COUNT(transacc), SUM(monto_tot) INTO vsTotalAbonos, vsMontoTotalAbonos FROM bdicheq:"informix".sc_movhis_old AS movhisold, bdinteg:"informix".si_transacc AS trans WHERE movhisold.fech_alt = vdFechaIni and movhisold.cuenta = vsCtaConcentradora AND movhisold.transacc = trans.numero AND trans.naturaleza = "A" AND movhisold.cancelad <> 'S';
				else
				SELECT COUNT(transacc), SUM(monto_tot) INTO vsTotalAbonos, vsMontoTotalAbonos FROM bdicheq:"informix".sc_movhis_old AS movhisold, bdinteg:"informix".si_transacc AS trans WHERE movhisold.fech_alt = vdFechaIni and movhisold.cuenta = vsCtaConcentradora AND movhisold.transacc = trans.numero AND trans.naturaleza = "A" AND movhisold.cancelad <> 'S';
			END IF;
			--Se obtiene la cantidad de transacciones y el monto total de las transacciones de cargo correspondientes del dia a consultar.
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			
	--		IF vsFechaIni >= vsFechaParam THEN
			IF vdFechaIni >= vdFechaParam THEN
			SELECT COUNT(transacc), SUM(monto_tot) INTO vsTotalCargos, vsMontoTotalCargos FROM bdicheq:"informix".sc_movhis AS movhis, bdinteg:"informix".si_transacc AS trans WHERE movhis.fech_alt = vdFechaIni and movhis.cuenta = vsCtaConcentradora AND movhis.transacc = trans.numero AND trans.naturaleza = "C" AND movhis.cancelad <> 'S';
				--ELIF vsFechaIni <= vsFechaParam THEN
				--SELECT COUNT(transacc), SUM(monto_tot) INTO vsTotalCargos, vsMontoTotalCargos FROM bdicheq:"informix".sc_movhis_old AS movhisold, bdinteg:"informix".si_transacc AS trans WHERE movhisold.fech_alt = vdFechaIni and movhisold.cuenta = vsCtaConcentradora AND movhisold.transacc = trans.numero AND trans.naturaleza = "C" AND movhisold.cancelad <> 'S';
				else
				SELECT COUNT(transacc), SUM(monto_tot) INTO vsTotalCargos, vsMontoTotalCargos FROM bdicheq:"informix".sc_movhis_old AS movhisold, bdinteg:"informix".si_transacc AS trans WHERE movhisold.fech_alt = vdFechaIni and movhisold.cuenta = vsCtaConcentradora AND movhisold.transacc = trans.numero AND trans.naturaleza = "C" AND movhisold.cancelad <> 'S';
			END IF; 
			RETURN vsFechaIni, NVL(vsSaldoInicial, 0.00),  vsTotalAbonos, NVL(vsMontoTotalAbonos, 0.00), vsTotalCargos, NVL(vsMontoTotalCargos, 0.00), NVL(vsSaldoFinal, 0.00), NVL(vsCtaConcentradora,''), NVL(vsCtaClabe,''), viSqlErr WITH RESUME;
			--Se asigna a variable el dia siguiente del mes para continuar consultando.
			LET vdFechaIni = vdFechaIni + INTERVAL (1) DAY TO DAY;
		END WHILE;
	END IF;
END IF;
END
END PROCEDURE
DOCUMENT
'AUTOR: Rochin Rocha Edgar Ivan',
'Proyecto: BTS',
'Solicito: Jaime Gonzalez',
'Descripcion: GENERA REPORTE DE ESTADO DE CUENTA.',
'Fecha: 2011/08/30',
'Version: 20110830.1500',
'BD: BDISAC',
'AUTOR: José Angel Gaxiola / Cristian Valentina Aguilar ',
'Proyecto: BTS',
'Solicito: Jaime Gonzalez',
'Descripcion: Se modifica para que pueda generar el estado de cuenta contemplando que el periodo puede abarcar años diferentes al actual y diferentes entre sí.',
'Fecha: 2012/01/11',
'Version: 20120111.1901',
'BD: BDISAC',   
'AUTOR: José Angel Gaxiola / Cristian Valentina Aguilar ',
'Proyecto: BTS',
'Solicito: Jaime Gonzalez',
'Descripcion: Se modifico sp para que cuando se trate del primero de enero,muestre la misma cantidad tanto el saldo inicial como el saldo final',
'ya que ese día no hay movimientos en el banco, y pasar dicha cantidad al dia dos de enero como saldo inicial.',
'Fecha: 2012/01/23',
'Version: 20120123.1000',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_sac_generaarchivoptc( psNumEmpleado CHAR (10), psNombreArchivo CHAR(20) )

RETURNING CHAR (8) AS CodRespuesta,  CHAR (120) AS Mensaje;

--****************************************************************************************************
-- DESCRIPCION: Genera el archivo de pago a E-Global con base en la información de los catálogos.
-- AUTOR : Casanova Edeza Hector Juan
-- FECHA : 23/03/2010
-- BD: BdiSac
-- SISTEMA : PAGO INTERBANCARIO DE TARJETAS DE CREDITO (PITDC)
--****************************************************************************************************

DEFINE viSqlErr INTEGER;
DEFINE vsRepositorio CHAR(100);

DEFINE vsSQL CHAR(2204);
DEFINE vsSQL1 CHAR(100);
DEFINE vsSQL2 CHAR(2004);
DEFINE vsSQL3 CHAR(100);
DEFINE vsArchTemp CHAR(15);
DEFINE vsArchTemp1 CHAR(15);
DEFINE vsUsoFutBanc CHAR(12);

DEFINE vsRegistro CHAR(190);

DEFINE vsMensajeRet CHAR (120);
DEFINE vsCodRetorno CHAR (5);

LET viSqlErr = 0;
LET vsRepositorio = '';
LET vsSQL = '';
LET vsSQL1 = '';
LET vsSQL2 = '';
LET vsSQL3 = '';
LET vsArchTemp = '';
LET vsArchTemp1 = '';
LET vsUsoFutBanc = '';

LET vsRegistro = '';

LET vsMensajeRet = '';
LET vsCodRetorno = '';

--SET DEBUG FILE TO "/tmp/pitdc/sp_sac_generaarchivoptc.out";
--TRACE ON;

BEGIN

	ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado.
		
		
		--VALIDA SI EXISTE LA TABLA DE PASO
		SET ISOLATION TO DIRTY READ;
		IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames  WHERE tabname = 'sac_tmparchpitdc' AND dbsname= 'bdisac') THEN
			DROP TABLE sac_tmparchpitdc;
		END IF;
		
		LET vsCodRetorno = '00299'; --ERROR DE INFORMIX
		
		--OBTIENE EL MENSAJE CORRESPONDIENTE AL CODIGO DE RETORNO
		SELECT FIRST 1 Descripcion INTO vsMensajeRet FROM BdiSac:Sac_EGlobal_Mensajes_Error WHERE Cod_Ret = vsCodRetorno;
		
		LET vsMensajeRet = TRIM(vsMensajeRet) || ' ERROR (' || viSqlErr || ').' ;
		
		RETURN vsCodRetorno, vsMensajeRet ;
		
	END EXCEPTION;
	
	/*
	IF ( psNumEmpleado = '5' )	THEN
		--SET DEBUG FILE TO '/tmp/PITDC/GENERAR_ARCH_TIPDC.sql';
		SET DEBUG FILE TO '/home/sysifx/PITDC/GENERAR_ARCH_TIPDC.sql';
		TRACE ON ;
	END IF ;
	*/
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ ;
	--Se le quitan espacion en blanco a nombre de archivo
	LET psNombreArchivo = TRIM(psNombreArchivo);
	
	IF (TRIM(NVL(psNumEmpleado, '')) = '')THEN --VALIDA QUE EL NUMERODE EMPLEADO CONTENGA INFO
		--EL NUMERO DE EMPLEADO DEBE DE CONTENER INFORMACION
		LET vsCodRetorno = '00201';
	ELIF (TRIM(NVL(psNombreArchivo, '')) = '')THEN --VALIDA QUE EL NOMBRE DE ARCHIVO CONTENGA INFO
		--EL NOMBRE DE ARCHIVO DEBE DE CONTENER INFORMACION
		LET vsCodRetorno = '00207';
	ELIF (NOT EXISTS(SELECT Nombre_Archivo FROM BdiSac:Sac_EGlobal_Archivos WHERE Nombre_Archivo = TRIM(psNombreArchivo)))THEN
		--NO EXISTE EL REGISRO DEL  ARCHIVO INDICADO
		LET vsCodRetorno = '00204';
	ELIF (NOT EXISTS(SELECT Nombre_Archivo FROM BdiSac:Sac_EGlobal_Sumario WHERE Nombre_Archivo = TRIM(psNombreArchivo)))THEN
		--NO EXISTE EL REGISRO DEL SUMARIO PARA EL ARCHIVO INDICADO
		LET vsCodRetorno = '00202';
	ELIF (NOT EXISTS(SELECT Nombre_Archivo FROM BdiSac:Sac_EGlobal_Encabezado WHERE Nombre_Archivo = TRIM(psNombreArchivo)))THEN
		--NO EXISTE EL REGISRO DEL ENCABEZADO PARA EL ARCHIVO INDICADO
		LET vsCodRetorno = '00203';
	ELIF (NOT EXISTS(SELECT Valor FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33001') ) THEN --VALIDA KE EXISTA EN PARAMETRO DE LA RUTA DE GENRACION DEL ARCHIVO
		--NO EXISTE EL PARAMETRO DE LA RUTA DE GENRACION DEL ARCHIVO
		LET vsCodRetorno = '00205';
	ELSE
		
		
		--VALIDA SI EXISTE LA TABLA DE PASO
		SET ISOLATION TO DIRTY READ;
		IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames  WHERE tabname = 'sac_tmparchpitdc' AND dbsname= 'bdisac') THEN
			DROP TABLE sac_tmparchpitdc;
		END IF;

		--CREA LA TABLA TEMP
		CREATE TABLE BdiSac:sac_tmparchpitdc(
			Keyx SERIAL,
			Nombre_Archivo CHAR (20),
			Detalle CHAR (190)
		);
		
		
		SELECT (Cod_Txn || Bin_Adquiriente || Fecha_Intercambio || LPAD(Filler, 177, ' ')) AS DETALLE
		INTO vsRegistro 
		FROM BdiSac:Sac_EGlobal_Encabezado
		WHERE Nombre_Archivo = psNombreArchivo;
			
			
		--ENCABEZADO
		INSERT INTO BdiSac:sac_tmparchpitdc (Nombre_Archivo, Detalle) VALUES (psNombreArchivo, vsRegistro);
		
		FOREACH
			SELECT (Cod_Txn || Calificado_R_Codigo || Codigo_Registro || Numero_Tarjeta || Extension_Tarjeta || Ind_Limite_Piso || Ind_Cwb_Crb || Ind_Servicio || num_Referencia || num_Negocio 
			|| Fecha_Txn || Importe_Txn || Cod_Actual_Destino || Importe_Tasa || Cod_Actual_Origen || Nombre_Negocio || Poblacion_Negocio || Cod_Pais || Cod_Categoria 
			|| Cod_Postal || Cod_Estado || Reservado || Ind_Com_Elec || Cod_Uso || Cod_Razon || Ind_Liquidacion || Ind_Servicio2 || Num_Autorizaciones || Cap_Term_Pos 
			|| Filler1 || Met_Identificacion || Ban_Coleccion || Mod_Pos || Fecha_Proceso || Tipo_Captura || Categoria_Tasa || Ind_Medio_Acceso || Track2 || Ind_Cavv 
			|| Ind_Ucaf || Diferimiento || Parcializacion || Tipo_Plan || Ind_Deposito_Efectivo || LPAD(Filler, 8, ' ') ) AS DETALLE 
			INTO vsRegistro 
			FROM BdiSac:Sac_EGlobal_Detalle WHERE Nombre_Archivo = psNombreArchivo
			
			INSERT INTO BdiSac:sac_tmparchpitdc (Nombre_Archivo, Detalle) VALUES (psNombreArchivo, vsRegistro);
			
		END FOREACH;
		
		SELECT  (Cod_Txn || Total_Registros || Total_Pagos || Importe_Pagos || Total_Rechazos || Importe_Rechazos || LPAD(Filler, 146, ' ')) AS DETALLE
		INTO vsRegistro 
		FROM BdiSac:Sac_EGlobal_Sumario 
		WHERE Nombre_Archivo = psNombreArchivo;
			
		--SUMARIO
		INSERT INTO BdiSac:sac_tmparchpitdc (Nombre_Archivo, Detalle) VALUES (psNombreArchivo, vsRegistro);
		
		
			
			SELECT FIRST 1 NVL(Valor, '') INTO vsRepositorio FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param = '33001';
			--Genera archivo.
			LET vsArchTemp = 'temporal.txt';
			LET vsArchTemp1 = 'temporal1.txt';
			LET vsSQL1 = 'echo "UNLOAD TO ' || TRIM(vsRepositorio) || TRIM (vsArchTemp) || ' DELIMITER ' || '''?''';
			
			LET vsSQL2 = "SELECT LPAD(Detalle, 189, ' ') || ' Ø' FROM BdiSac:sac_tmparchpitdc WHERE Nombre_Archivo = '" || psNombreArchivo || "' ; ";
			
			LET vsSQL3 = ' " > '|| TRIM(vsRepositorio) || 'control_reporte.sql';
			LET vsSQL1 = TRIM(vsSQL1);
			LET vsSQL3 = TRIM(vsSQL3);
			LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;
			--Verifica que no este vacia la consulta.
			IF ( vsSQL <> '' ) THEN 
				SYSTEM vsSQL;
				--Permiso para la creacion de archivo.
				LET vsSQL = '' ;
				LET vsSQL = 'chmod 666 ' || TRIM(vsRepositorio) || 'control_reporte.sql' ;
				LET vsSQL = '' ;
				LET vsSQL = 'dbaccess BdiSac ' || TRIM(vsRepositorio) || 'control_reporte.sql' ;
				SYSTEM vsSQL ;
				--Borra el archivo de control.
				LET vsSQL = '' ;
				LET vsSQL = 'rm ' || TRIM(vsRepositorio) || 'control_reporte.sql';
				SYSTEM vsSQL;
				--Elimina el caracter delimitador '?'.
				LET vsSQL = '' ;
				LET vsSQL =  "sed 's/?$//g' " || TRIM(vsRepositorio) || TRIM (vsArchTemp) || " > " || TRIM(vsRepositorio) || 
				TRIM (vsArchTemp1);
				SYSTEM vsSQL;
				--Elimina el caracter delimitador 'x'.
--				LET vsSQL = '' ;
--				LET vsSQL =  "sed 's/x$//g' " || TRIM(vsRepositorio) || TRIM (vsArchTemp1) || " > " || TRIM(vsRepositorio) || 
--				TRIM (psNombreArchivo);
--				SYSTEM vsSQL;
			    LET vsSQL = '' ;
			    LET vsSQL =  "sed 's/Ø$//g' " || TRIM(vsRepositorio) || TRIM (vsArchTemp1) || " > " || TRIM(vsRepositorio) ||
			    TRIM (psNombreArchivo);
			    SYSTEM vsSQL;

				--Borra el archivo temporal.
				LET vsSQL = '' ;
				LET vsSQL = 'rm ' || TRIM(vsRepositorio) || TRIM(vsArchTemp);
				SYSTEM vsSQL; 
				--Borra el archivo temporal1.
				LET vsSQL = '' ;
				LET vsSQL = 'rm ' || TRIM(vsRepositorio) || TRIM(vsArchTemp1);
				SYSTEM vsSQL; 
				--Operacion exitosa "Archivo Generado".
				LET vsCodRetorno = '00000';
			ELSE 
				--NO FUE POSIBLE GENERAR EL ARCHIVO.
				LET vsCodRetorno = '00206';
			END IF ;
			
	END IF;
	
	--VALIDA SI EXISTE LA TABLA DE PASO
	SET ISOLATION TO DIRTY READ;
	IF EXISTS ( SELECT dbsname, tabname FROM sysmaster:SysTabNames  WHERE tabname = 'sac_tmparchpitdc' AND dbsname= 'bdisac') THEN
		DROP TABLE sac_tmparchpitdc;
	END IF;
		
	--OBTIENE EL MENSAJE CORRESPONDIENTE AL CODIGO DE RETORNO
	SELECT FIRST 1 Descripcion INTO vsMensajeRet FROM BdiSac:Sac_EGlobal_Mensajes_Error WHERE Cod_Ret = vsCodRetorno;
	
	RETURN vsCodRetorno, vsMensajeRet ;

END;
END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Pago interbancario de tarjetas de credito',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: Genera el archivo de pago a E-Global con base en la información de los catálogos.',
'Fecha: 2010/03/23',
'Version: 20100319.0153',
'BD: BdiSac';

CREATE PROCEDURE "informix".sp_sac_eliminamovshistoricos(fechmin DATE, fechmax DATE)
    RETURNING CHAR(5), char(6);  --Códigos de retorno

DEFINE cCodRet       CHAR(5);
DEFINE vfolio_suc    CHAR (16);
DEFINE vtotregshist  CHAR (6);
DEFINE iSqlErr       integer;
DEFINE cont_borra  integer;

LET cCodRet        = '00000';
LET vfolio_suc     = '0000000000000000';
LET vtotregshist   = '000000';
LET iSqlErr        = 0;
LET cont_borra     = 0;

 --SET DEBUG FILE TO "/informix/frg/sp_sac_eliminamovshistoricos.out";
 --TRACE ON;

BEGIN

   ON EXCEPTION SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;
                    RETURN cCodRet, vtotregshist;
                END IF;
    END EXCEPTION;

	SELECT count (*)
		into vtotregshist
        FROM bdisac:sac_movimientoshistorial
		WHERE
		fecha_pago between fechmin and fechmax;
	
	FOREACH cursor_borra WITH HOLD FOR
		SELECT folio_suc
			INTO vfolio_suc
			FROM bdisac:sac_movimientoshistorial
			WHERE
			fecha_pago between fechmin and fechmax
	
	IF cont_borra = 0 then
		let cont_borra = 1;
	END IF;
		DELETE FROM bdisac:sac_movimientoshistorial
			WHERE CURRENT OF cursor_borra;
		commit work;
		begin work;
    END FOREACH;

END;
RETURN cCodRet, vtotregshist;
END PROCEDURE
DOCUMENT
'AUTOR : FRG',
'DESCRIPCION: Elimina registros de tabla bdisac:sac_movimientoshistorial por medio de cursor, con fechas como parametro de entrada.',
'EJECUTADO O LLAMADO POR: Proceso especial (se ejecuta por script en casos especiales).',
'FECHA : Abril/2012',
'VERSION: 20120419',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_mueveregistrosaold_esp(dFecIni DATE, dFecFin DATE)

    RETURNING CHAR(5), integer, integer;  --Código de retorno

    DEFINE cCodRet                  CHAR(5);
    DEFINE cInfoErr                 CHAR(100);
    DEFINE iSqlErr                  INTEGER;
    DEFINE iIsamErr                 INTEGER;

	DEFINE vcontregshist 			INTEGER;
	DEFINE vcontregsold				INTEGER;
	DEFINE vMensaje 				CHAR (200);
	DEFINE vFecMov 					DATE;
	
	DEFINE CodRetMovs				CHAR (5);
	DEFINE totregsMovs				CHAR (6);
	
 	--	SET DEBUG FILE TO "/informix/frg/sp_mueveregistrosaold_esp.out";
	--	TRACE ON;
 
	LET cCodRet 		= '00000';
	LET cInfoErr 		= '';
	LET iSqlErr  		= 0;
	LET iIsamErr  		= 0;
	LET vcontregshist 	= 0;
	LET vcontregsold    = 0;
	LET vMensaje 		= '';
	LET CodRetMovs		= '00000';
	LET totregsMovs		= '000000';
	
    BEGIN

        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;
                    ROLLBACK WORK;
                    EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_mueveregistrosaold_esp");
                    RETURN cCodRet, vcontregshist, vcontregsold;
                END IF;
        END EXCEPTION;
        BEGIN WORK;

	select count (*) 
	into vcontregshist
	FROM bdisac:sac_movimientoshistorial
	where fecha_pago between dFecIni and dFecFin;
	
--	PROCESO DE INSERT DE LA TABLA DE HISTORICOS A REPOSITORIO (OLD):
	INSERT INTO bdisac:sac_movimientoshistorial_old 
				(id_sucursal, numcategoria, numconvenio, referencia1, referencia2, forma_pago, importe_pago, importe_comision_convenio, 
				iva_comision_convenio, importe_comision_cte, iva_comision_cte, cuenta_cargo, usuario, folio_suc, transacc_suc, 
				flag_confirmacion_central, flag_confirmacion_sucursal, fecha_pago, fecha_insert, status_cancelado)
		  SELECT id_sucursal, numcategoria, numconvenio, referencia1, referencia2, forma_pago, importe_pago, importe_comision_convenio,
				iva_comision_convenio, importe_comision_cte, iva_comision_cte, cuenta_cargo, usuario, folio_suc, transacc_suc,
				flag_confirmacion_central, flag_confirmacion_sucursal, fecha_pago, fecha_insert, status_cancelado
                FROM bdisac:sac_movimientoshistorial
                where fecha_pago between dFecIni and dFecFin;
	
	select count (*)
	into vcontregsold
	FROM bdisac:sac_movimientoshistorial_old
	where fecha_pago between dFecIni and dFecFin;
	
	if vcontregsold = vcontregshist
		then
			EXECUTE FUNCTION sp_sac_eliminamovshistoricos (dFecIni, dFecFin) into CodRetMovs, totregsMovs;
		else
			LET iSqlErr = 9999;
			LET iIsamErr = 9999;
			LET cInfoErr = 'No se insertaron en la tabla bdisac:sac_movimientoshistorial_old todos los registros.';
			EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_mueveregistrosaold_esp");
	end if;

        COMMIT WORK;
		
		RETURN cCodRet, vcontregshist, vcontregsold;
    END;
END PROCEDURE
DOCUMENT
'AUTOR : FRG',
'DESCRIPCION: Movimiento de registros de bdisac:sac_movimientoshistorial al repositorio bdisac:sac_movimientoshistorial_old',
'EJECUTADO O LLAMADO POR: Proceso especial (se ejecuta por script en casos especiales) con fecha inicio y fecha fin.',
'FECHA : Abril/2012',
'VERSION: 20120419',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_guardarespuestapayi2(pSucursal CHAR (4), 
                                        pTxn_Status CHAR(1), 
										pConfirmation_nm CHAR (11), 
										pBank_Ref_Num CHAR(20), 
                                        pUser_name CHAR(20), 
										pTerminal CHAR(15), 
										pAgent_Dt CHAR(8), 
										pAgent_Tm CHAR(6), 
	                                    pR_First_Name CHAR(40), 
										pR_Middle_Name CHAR(40), 
										pR_Last_Name CHAR(40), 
										pR_Mother_M_Name CHAR(40),
										pR_Type_Cd CHAR(3), 
										pR_Issuer_Cd CHAR(3), 
										pR_Issuer_State_Cd CHAR(3), 
										pR_Issuer_Country_Cd CHAR(3), 
										pR_Identif_Type CHAR(5),
	                                    pR_Identif_Nm CHAR(20), 
										pR_Expiration_Dt CHAR(8),
					                    pR_Fecha_Nac CHAR(8),
										pR_Nacionalidad CHAR(50),
										pR_pais_nac CHAR(20),	
										pR_Nom_Calle CHAR(50),
										pR_Num_Ext CHAR(5),
										pR_Num_Int CHAR(5),
										pR_Depto CHAR(10),
										pR_Colonia CHAR(80),
										pR_Cp CHAR(5),
										pR_Mncpo_Delg CHAR(50),
										pR_Ciudad CHAR(50),
										pR_Estado CHAR(50),
										pR_Telefono CHAR(15),
										pTipo_Pago CHAR(1),
										pOpCode CHAR(4), 
										pProcess_Msg CHAR(255), 	
										pError_Param_Full_Name CHAR(255), 
	                                    pTrans_Status_Cd CHAR(3), 
	                                    pTrans_Status_Dt CHAR(8),
	                                    pProcess_Dt CHAR(8), 
	                                    pProcess_Tm CHAR(6), 
	                                    pUsuario CHAR(8))


	--DATOS A REGRESAR---
    RETURNING
    CHAR(5);   -- Codigo de Retorno
	
	 --DEFINICION DE VARIABLES--
    DEFINE sql_err                INT;
    DEFINE cCodRet                CHAR(5);
	DEFINE cAgent_Trans_Type_Code CHAR(4);
	DEFINE cAgent_Cd              CHAR(3);
	DEFINE cRegion_Sd             CHAR(15);
	DEFINE cBranch_Sd             CHAR(15);
	DEFINE cState_Cd              CHAR(3);
	DEFINE cCountry_Cd            CHAR(3);
	
	
	
        --INICIALIZACION DE VARIABLES--
    LET sql_err                = 0;
    LET cCodRet                = '00000';
	LET cAgent_Trans_Type_Code = 'PAYI';
	LET cAgent_Cd              = '';
	LET cRegion_Sd             = '';
	LET cBranch_Sd             = '';
	LET cState_Cd              = '';
	LET cCountry_Cd            = '';
	
	
	--SET DEBUG FILE TO "/respaldosbd/Dulce/sp_GuardaRespuestaPayi2.out";
    --TRACE ON;
	
	BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cCodRet = sql_err;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
	
	IF pSucursal = "" OR  pSucursal IS NULL OR pTxn_Status = "" OR pTxn_Status IS NULL OR pConfirmation_nm = "" OR pConfirmation_nm IS NULL 
	    OR pBank_Ref_Num = "" OR pBank_Ref_Num IS NULL OR pUser_name = "" OR pUser_name IS NULL OR pTerminal = "" OR pTerminal IS NULL 
		OR pAgent_Dt = "" OR pAgent_Dt IS NULL OR pAgent_Tm = "" OR pAgent_Tm IS NULL 
		OR pR_First_Name = "" OR pR_First_Name IS NULL OR pR_Last_Name = "" OR pR_Last_Name IS NULL 
		OR pR_Type_Cd = "" OR pR_Type_Cd IS NULL OR pR_Issuer_Cd = "" OR pR_Issuer_Cd IS NULL 
		OR pR_Issuer_State_Cd = "" OR pR_Issuer_State_Cd IS NULL OR pR_Issuer_Country_Cd = "" OR pR_Issuer_Country_Cd IS NULL 
		OR pR_Identif_Nm = "" OR pR_Identif_Nm IS NULL OR pR_Expiration_Dt = "" OR pR_Expiration_Dt IS NULL 
		OR pUsuario = "" OR pUsuario IS NULL OR pR_pais_nac = "" OR pR_pais_nac IS NULL THEN
		LET cCodRet = "00001";
		RETURN cCodRet;
	END IF;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	EXECUTE PROCEDURE bdisac:"informix".sp_consultasucursal (pSucursal) 
	INTO cCodRet, cAgent_Cd, cRegion_Sd, cBranch_Sd, cState_Cd, cCountry_Cd;
	IF cCodRet = "00000" THEN
		INSERT INTO "informix".sac_bts_payi (txn_status, agent_trans_type_code, agent_cd, confirmation_nm, bank_ref_nm, region_sd, branch_sd, state_cd, 
		        country_cd, user_name, terminal, agent_dt, agent_tm, r_first_name, r_middle_name, r_last_name, r_mother_m_name, r_type_cd, 
				r_issuer_cd, r_issuer_state_cd, r_issuer_country_cd, r_identif_type, r_identif_nm, r_expiration_dt, r_fecha_nac, r_nacionalidad, r_pais_nac,
				r_nom_calle, r_num_ext, r_num_int, r_depto, r_colonia, r_cp, r_mncpo_deleg, r_ciudad, r_estado, r_telefono, tipo_pago, sucursal,
				opcode, process_msg, error_param_full_name, trans_status_cd, trans_status_dt, process_dt, process_tm, user_insert, fecha_insert)
		VALUES(pTxn_Status, cAgent_Trans_Type_Code, cAgent_Cd, pConfirmation_Nm, pBank_Ref_Num, cRegion_Sd, cBranch_Sd, cState_Cd,
         		cCountry_Cd, pUser_Name, pTerminal, pAgent_Dt, pAgent_Tm, pR_First_Name, pR_Middle_Name, pR_Last_Name, pR_Mother_M_Name, pR_Type_Cd,  
				pR_Issuer_Cd, pR_Issuer_State_Cd, pR_Issuer_Country_Cd, pR_Identif_Type, pR_Identif_Nm, pR_Expiration_Dt, pR_Fecha_Nac, pR_Nacionalidad, pR_pais_nac,
				pR_Nom_Calle, pR_Num_Ext, pR_Num_Int, pR_Depto, pR_Colonia, pR_Cp, pR_Mncpo_Delg, pR_Ciudad, pR_Estado, pR_Telefono, pTipo_Pago, pSucursal, 
				pOpCode, pProcess_Msg, pError_Param_Full_Name, pTrans_Status_Cd, pTrans_Status_Dt, pProcess_Dt, pProcess_Tm, pUsuario, CURRENT);			 
	END IF;
	
	RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea SP para guardar los datos de envio y recepción del mensaje PAYI de BTS',
'AUTOR : Dulce Ramirez',
'FECHA : 05/Enero/2011',
'Ver.  : 1.1',
'BD    : bdisac',
'VER   : 1.1',
'MODIFICO: Felipe Urias',
'FECHA : 12/Abril/2012',
'DESCRIPCION: se agrego el campo r_pais_nac como parametro a guardar en tabla',
'MODIFICO: FRG',
'FECHA : 09/Mayo/2012',
'DESCRIPCION: se clona el SP con nombre sp_guardarespuestapayi2.sql',
'para no afectar el flujo actual en Prod. al guardar el campo r_pais_nac';

CREATE PROCEDURE "informix".sp_guardarespuestapayi(pSucursal CHAR (4), 
                                        pTxn_Status CHAR(1), 
										pConfirmation_nm CHAR (11), 
										pBank_Ref_Num CHAR(20), 
                                        pUser_name CHAR(20), 
										pTerminal CHAR(15), 
										pAgent_Dt CHAR(8), 
										pAgent_Tm CHAR(6), 
	                                    pR_First_Name CHAR(40), 
										pR_Middle_Name CHAR(40), 
										pR_Last_Name CHAR(40), 
										pR_Mother_M_Name CHAR(40),
										pR_Type_Cd CHAR(3), 
										pR_Issuer_Cd CHAR(3), 
										pR_Issuer_State_Cd CHAR(3), 
										pR_Issuer_Country_Cd CHAR(3), 
										pR_Identif_Type CHAR(5),
	                                    pR_Identif_Nm CHAR(20), 
										pR_Expiration_Dt CHAR(8),
					                    pR_Fecha_Nac CHAR(8),
										pR_Nacionalidad CHAR(50),
										pR_pais_nac CHAR(20),	
										pR_Nom_Calle CHAR(50),
										pR_Num_Ext CHAR(5),
										pR_Num_Int CHAR(5),
										pR_Depto CHAR(10),
										pR_Colonia CHAR(80),
										pR_Cp CHAR(5),
										pR_Mncpo_Delg CHAR(50),
										pR_Ciudad CHAR(50),
										pR_Estado CHAR(50),
										pR_Telefono CHAR(15),
										pTipo_Pago CHAR(1),
										pOpCode CHAR(4), 
										pProcess_Msg CHAR(255), 	
										pError_Param_Full_Name CHAR(255), 
	                                    pTrans_Status_Cd CHAR(3), 
	                                    pTrans_Status_Dt CHAR(8),
	                                    pProcess_Dt CHAR(8), 
	                                    pProcess_Tm CHAR(6), 
	                                    pUsuario CHAR(8))


	--DATOS A REGRESAR---
    RETURNING
    CHAR(5);   -- Codigo de Retorno
	
	 --DEFINICION DE VARIABLES--
    DEFINE sql_err                INT;
    DEFINE cCodRet                CHAR(5);
	DEFINE cAgent_Trans_Type_Code CHAR(4);
	DEFINE cAgent_Cd              CHAR(3);
	DEFINE cRegion_Sd             CHAR(15);
	DEFINE cBranch_Sd             CHAR(15);
	DEFINE cState_Cd              CHAR(3);
	DEFINE cCountry_Cd            CHAR(3);
	
	
	
        --INICIALIZACION DE VARIABLES--
    LET sql_err                = 0;
    LET cCodRet                = '00000';
	LET cAgent_Trans_Type_Code = 'PAYI';
	LET cAgent_Cd              = '';
	LET cRegion_Sd             = '';
	LET cBranch_Sd             = '';
	LET cState_Cd              = '';
	LET cCountry_Cd            = '';
	
	
	--SET DEBUG FILE TO "/respaldosbd/Dulce/sp_GuardaRespuestaPayi2.out";
    --TRACE ON;
	
	BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cCodRet = sql_err;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
	
	IF pSucursal = "" OR  pSucursal IS NULL OR pTxn_Status = "" OR pTxn_Status IS NULL OR pConfirmation_nm = "" OR pConfirmation_nm IS NULL 
	    OR pBank_Ref_Num = "" OR pBank_Ref_Num IS NULL OR pUser_name = "" OR pUser_name IS NULL OR pTerminal = "" OR pTerminal IS NULL 
		OR pAgent_Dt = "" OR pAgent_Dt IS NULL OR pAgent_Tm = "" OR pAgent_Tm IS NULL 
		OR pR_First_Name = "" OR pR_First_Name IS NULL OR pR_Last_Name = "" OR pR_Last_Name IS NULL 
		OR pR_Type_Cd = "" OR pR_Type_Cd IS NULL OR pR_Issuer_Cd = "" OR pR_Issuer_Cd IS NULL 
		OR pR_Issuer_State_Cd = "" OR pR_Issuer_State_Cd IS NULL OR pR_Issuer_Country_Cd = "" OR pR_Issuer_Country_Cd IS NULL 
		OR pR_Identif_Nm = "" OR pR_Identif_Nm IS NULL OR pR_Expiration_Dt = "" OR pR_Expiration_Dt IS NULL 
		OR pUsuario = "" OR pUsuario IS NULL OR pR_pais_nac = "" OR pR_pais_nac IS NULL THEN
		LET cCodRet = "00001";
		RETURN cCodRet;
	END IF;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	EXECUTE PROCEDURE bdisac:"informix".sp_consultasucursal (pSucursal) 
	INTO cCodRet, cAgent_Cd, cRegion_Sd, cBranch_Sd, cState_Cd, cCountry_Cd;
	IF cCodRet = "00000" THEN
		INSERT INTO "informix".sac_bts_payi (txn_status, agent_trans_type_code, agent_cd, confirmation_nm, bank_ref_nm, region_sd, branch_sd, state_cd, 
		        country_cd, user_name, terminal, agent_dt, agent_tm, r_first_name, r_middle_name, r_last_name, r_mother_m_name, r_type_cd, 
				r_issuer_cd, r_issuer_state_cd, r_issuer_country_cd, r_identif_type, r_identif_nm, r_expiration_dt, r_fecha_nac, r_nacionalidad, r_pais_nac,
				r_nom_calle, r_num_ext, r_num_int, r_depto, r_colonia, r_cp, r_mncpo_deleg, r_ciudad, r_estado, r_telefono, tipo_pago, sucursal,
				opcode, process_msg, error_param_full_name, trans_status_cd, trans_status_dt, process_dt, process_tm, user_insert, fecha_insert)
		VALUES(pTxn_Status, cAgent_Trans_Type_Code, cAgent_Cd, pConfirmation_Nm, pBank_Ref_Num, cRegion_Sd, cBranch_Sd, cState_Cd,
         		cCountry_Cd, pUser_Name, pTerminal, pAgent_Dt, pAgent_Tm, pR_First_Name, pR_Middle_Name, pR_Last_Name, pR_Mother_M_Name, pR_Type_Cd,  
				pR_Issuer_Cd, pR_Issuer_State_Cd, pR_Issuer_Country_Cd, pR_Identif_Type, pR_Identif_Nm, pR_Expiration_Dt, pR_Fecha_Nac, pR_Nacionalidad, pR_pais_nac,
				pR_Nom_Calle, pR_Num_Ext, pR_Num_Int, pR_Depto, pR_Colonia, pR_Cp, pR_Mncpo_Delg, pR_Ciudad, pR_Estado, pR_Telefono, pTipo_Pago, pSucursal, 
				pOpCode, pProcess_Msg, pError_Param_Full_Name, pTrans_Status_Cd, pTrans_Status_Dt, pProcess_Dt, pProcess_Tm, pUsuario, CURRENT);			 
	END IF;
	
	RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea SP para guardar los datos de envio y recepción del mensaje PAYI de BTS',
'AUTOR : Dulce Ramirez',
'FECHA : 05/Enero/2011',
'Ver.  : 1.1',
'BD    : bdisac',
'VER   : 1.1',
'MODIFICO: Felipe Urias',
'FECHA : 12/Abril/2012',
'DESCRIPCION: se agrego el campo r_pais_nac como parametro a guardar en tabla',
'MODIFICO: FRG',
'FECHA : 09/Mayo/2012',
'DESCRIPCION: se clona el SP con nombre sp_guardarespuestapayi2.sql',
'para no afectar el flujo actual en Prod. al guardar el campo r_pais_nac';

CREATE PROCEDURE "informix".sp_sacreportemensualavon(pConvenio CHAR(5), pPeriodo CHAR(6))
RETURNING
		CHAR (6) 	 AS retorno,
		CHAR(6) 	 AS aniomes,
		DATE 	 	 AS fecha,
		INTEGER      AS num_operaciones,
		MONEY (16,2) AS comision,
		MONEY (16,2) AS iva;

--Definicion de Variables
DEFINE cCodRet			CHAR(6);
DEFINE cAnioMes			CHAR(6);
DEFINE cInfoErr         CHAR(100);
DEFINE dFecha			DATE;
DEFINE iNumOperaciones	INTEGER;
DEFINE iSqlErr			INTEGER;
DEFINE iIsamErr			INTEGER;
DEFINE mComision		MONEY(16,2);
DEFINE mIva				MONEY(16,2);

--Inicializacion de Variables
LET cCodRet				= '000000';
LET cAnioMes			= '';
LET dFecha				= DATE (1);
LET iNumOperaciones		= 0;
LET mComision			= 0;
LET mIva				= 0;
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET cInfoErr			= '';

-- SET DEBUG FILE TO  '/tmp/sp_sacreportemensualavon.out';
-- TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr

		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportemensualavon");
			RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva;
		END IF;

	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;

	IF  pPeriodo = "" OR LENGTH(pPeriodo) <> 6 THEN
		LET cCodRet = "00001";
		RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva;
	ELSE   
		SET ISOLATION TO DIRTY READ;
		FOREACH
			
			SELECT aniomes, fecha, num_operaciones, comision, iva
			INTO cAnioMes, dFecha, iNumOperaciones, mComision, mIva
			FROM bdisac:"informix".sac_liquidacionmensual
			WHERE aniomes = pPeriodo
			AND id_convenio = pConvenio
			ORDER BY fecha
			
			RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva WITH RESUME;
		END FOREACH;
	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR : Martín Eduardo Miranda',
'DESCRIPCIÓN: Obtiene la informacion para la generacion del reporte mensual Avon',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : 05 Julio 2012',
'VERSIÓN: 20120705.1454',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_sacreportemensualdyclass(pConvenio CHAR(5), pPeriodo CHAR(6))
RETURNING
		CHAR (6) 	 AS retorno,
		CHAR(6) 	 AS aniomes,
		DATE 	 	 AS fecha,
		INTEGER      AS num_operaciones,
		MONEY (16,2) AS comision,
		MONEY (16,2) AS iva;

--Definicion de Variables
DEFINE cCodRet			CHAR(6);
DEFINE cAnioMes			CHAR(6);
DEFINE cInfoErr         CHAR(100);
DEFINE dFecha			DATE;
DEFINE iNumOperaciones	INTEGER;
DEFINE iSqlErr			INTEGER;
DEFINE iIsamErr			INTEGER;
DEFINE mComision		MONEY(16,2);
DEFINE mIva				MONEY(16,2);

--Inicializacion de Variables
LET cCodRet				= '000000';
LET cAnioMes			= '';
LET dFecha				= DATE (1);
LET iNumOperaciones		= 0;
LET mComision			= 0;
LET mIva				= 0;
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET cInfoErr			= '';

-- SET DEBUG FILE TO  '/tmp/sp_sacreportemensualdyclass.out';
-- TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr

		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportemensualdyclass");
			RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva;
		END IF;

	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;

	IF  pPeriodo = "" OR LENGTH(pPeriodo) <> 6 THEN
		LET cCodRet = "00001";
		RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva;
	ELSE   
		SET ISOLATION TO DIRTY READ;
		FOREACH
			
			SELECT aniomes, fecha, num_operaciones, comision, iva
			INTO cAnioMes, dFecha, iNumOperaciones, mComision, mIva
			FROM bdisac:"informix".sac_liquidacionmensual
			WHERE aniomes = pPeriodo
			AND id_convenio = pConvenio
			ORDER BY fecha
			
			RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva WITH RESUME;
		END FOREACH;
	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR : Martín Eduardo Miranda',
'DESCRIPCIÓN: Obtiene la informacion para la generacion del reporte mensual Dyclass',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : 05 Julio 2012',
'VERSIÓN: 20120705.1454',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_sacreportesemanalavon(pConvenio CHAR (5),pConsecutivo INTEGER)
	RETURNING
			CHAR (6) 	AS retorno,
			INTEGER 	AS rec_lunes , 
			INTEGER 	AS rec_martes, 
			INTEGER 	AS rec_miercoles, 
			INTEGER 	AS rec_jueves, 
			INTEGER 	AS rec_viernes, 
			INTEGER 	AS rec_sabado, 
			INTEGER 	AS rec_domingo, 
			MONEY(16,2) AS cob_lunes, 
			MONEY(16,2) AS cob_martes, 
			MONEY(16,2) AS cob_miercoles, 
			MONEY(16,2) AS cob_jueves, 
			MONEY(16,2) AS cob_viernes, 
			MONEY(16,2) AS cob_sabado, 
			MONEY(16,2) AS cob_domingo, 
			INTEGER 	AS rec_efectivo, 
			INTEGER 	AS rec_chequemb, 
			INTEGER 	AS rec_chequeob, 
			INTEGER 	AS rec_tarcred, 
			MONEY(16,2) AS cob_efectivo, 
			MONEY(16,2) AS cob_cheqmb, 
			MONEY(16,2) AS cob_cheqob, 
			MONEY(16,2) AS cob_tarcred, 
			MONEY(16,2) AS liq_miercoles, 
			MONEY(16,2) AS liq_jueves, 
			MONEY(16,2) AS liq_viernes,
			MONEY(16,2) AS liq_lunes, 
			MONEY(16,2) AS liq_martes, 
			MONEY(16,2) AS aclaraciones, 
			MONEY(16,2) AS comision, 
			MONEY(16,2) AS iva_comision, 
			DATE        AS fec_iniperiodo, 
			DATE 	    AS fec_finperiodo, 
			INTEGER 	AS keyx;
			
 --Definicion de Variables    
	DEFINE cCodRet			CHAR (6);
	DEFINE cInfoErr         CHAR(100);
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE iRecLunes		INTEGER; 
	DEFINE iRecMartes		INTEGER;
	DEFINE iRecMiercoles	INTEGER;
	DEFINE iRecJueves		INTEGER;
	DEFINE iRecViernes		INTEGER;
	DEFINE iRecSabado		INTEGER;
	DEFINE iRecDomingo		INTEGER;
	DEFINE iRecEfectivo		INTEGER;
	DEFINE iRecChequemb		INTEGER;
	DEFINE iRecChequeob		INTEGER;
	DEFINE iRecTarcred		INTEGER;
	DEFINE iCobEfectivo		INTEGER;
	DEFINE dFecIniPeriodo	DATE;
	DEFINE dFecFinPeriodo	DATE;
	DEFINE mCobLunes		MONEY(16,2);
	DEFINE mCobMartes		MONEY(16,2); 
	DEFINE mCobMiercoles	MONEY(16,2);
	DEFINE mCobJueves		MONEY(16,2);
	DEFINE mCobViernes		MONEY(16,2);
	DEFINE mCobSabado		MONEY(16,2);
	DEFINE mCobDomingo		MONEY(16,2);
	DEFINE mCobCheqmb		MONEY(16,2);
	DEFINE mCobCheqob		MONEY(16,2);
	DEFINE mCobTarcred		MONEY(16,2);
	DEFINE mLiqMiercoles	MONEY(16,2);
	DEFINE mLiqJueves		MONEY(16,2);
	DEFINE mLiqViernes		MONEY(16,2);
	DEFINE mLiqLunes		MONEY(16,2);
	DEFINE mLiqMartes		MONEY(16,2);
	DEFINE mAclaraciones	MONEY(16,2);
	DEFINE mComision		MONEY(16,2);
	DEFINE mIvaComision		MONEY(16,2);

--Inicializacion de Variables
	LET cCodRet			= '000000';
	LET iRecLunes		= 0;
	LET iRecMartes		= 0;
	LET iRecMiercoles	= 0;
	LET iRecJueves		= 0;
	LET iRecViernes		= 0;
	LET iRecSabado		= 0;
	LET iRecDomingo		= 0;
	LET mCobLunes		= 0;
	LET mCobMartes		= 0;
	LET mCobMiercoles	= 0;
	LET mCobJueves		= 0;
	LET mCobViernes		= 0;
	LET mCobSabado		= 0;
	LET mCobDomingo		= 0;
	LET iRecEfectivo	= 0;
	LET iRecChequemb	= 0;
	LET iRecChequeob	= 0;
	LET iRecTarcred		= 0;
	LET iCobEfectivo	= 0;
	LET mCobCheqmb		= 0;
	LET mCobCheqob		= 0;
	LET mCobTarcred		= 0;
	LET mLiqMiercoles	= 0;
	LET mLiqJueves		= 0;
	LET mLiqViernes		= 0;
	LET mLiqLunes		= 0;
	LET mLiqMartes		= 0;
	LET mAclaraciones	= 0;
	LET mComision		= 0;
	LET mIvaComision	= 0;
	LET dFecIniPeriodo	= DATE (1);
	LET dFecFinPeriodo	= DATE (1);
	LET iSqlErr			= 0;
	LET iIsamErr		= 0;
	LET cInfoErr		= '';
	
	--SET DEBUG FILE TO  '/tmp/sp_sacreportesemanalavon.out';
	--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr

		IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportesemanalavon");
				RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes, 
					mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, iCobEfectivo, 
					mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqLunes, mLiqMartes, mAclaraciones, mComision, 
					mIvaComision, dFecIniPeriodo, dFecFinPeriodo, pConsecutivo;
		END IF;

	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;

	IF  pConsecutivo IS NULL THEN
		LET cCodRet = "00001";
		RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes, 
			mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, iCobEfectivo, 
			mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqLunes, mLiqMartes, mAclaraciones, mComision, 
			mIvaComision, dFecIniPeriodo, dFecFinPeriodo, pConsecutivo;
	ELSE   
		SET ISOLATION TO DIRTY READ;
			FOREACH
				SELECT {+INDEX (bdisac:"informix".sac_liquidacionsemanal idx_sacliqsem)} rec_lunes, rec_martes, rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo, cob_lunes, cob_martes, 
					cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo, rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred, 
					cob_efectivo, cob_cheqmb, cob_cheqob, cob_tarcred, liq_miercoles, liq_jueves, liq_viernes, liq_lunes, liq_martes, 
					aclaraciones, comision, iva_comision, fec_iniperiodo, fec_finperiodo
				INTO iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes, 
					mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, iCobEfectivo, 
					mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqLunes, mLiqMartes, mAclaraciones, mComision, 
					mIvaComision, dFecIniPeriodo, dFecFinPeriodo 
				FROM bdisac:"informix".sac_liquidacionsemanal
				WHERE id_convenio = pConvenio 
				AND  consecutivo_convenio  = pConsecutivo 
				
					
				RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes, 
					mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, iCobEfectivo, 
					mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqLunes, mLiqMartes, mAclaraciones, mComision, 
					mIvaComision, dFecIniPeriodo, dFecFinPeriodo, pConsecutivo WITH RESUME;
			END FOREACH;
	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR : Martín Eduardo Miranda',
'DESCRIPCIÓN: Consulta la informacion para la generacion del reporte de liquidacion semanal de pagos Avon',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : 05 Julio 2012',
'VERSIÓN: 20120705.1431',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_sacreportesemanaldyclass(pConvenio CHAR (5),pConsecutivo INTEGER)
	RETURNING
			CHAR (6) 	AS retorno,
			INTEGER 	AS rec_lunes , 
			INTEGER 	AS rec_martes, 
			INTEGER 	AS rec_miercoles, 
			INTEGER 	AS rec_jueves, 
			INTEGER 	AS rec_viernes, 
			INTEGER 	AS rec_sabado, 
			INTEGER 	AS rec_domingo, 
			MONEY(16,2) AS cob_lunes, 
			MONEY(16,2) AS cob_martes, 
			MONEY(16,2) AS cob_miercoles, 
			MONEY(16,2) AS cob_jueves, 
			MONEY(16,2) AS cob_viernes, 
			MONEY(16,2) AS cob_sabado, 
			MONEY(16,2) AS cob_domingo, 
			INTEGER 	AS rec_efectivo, 
			INTEGER 	AS rec_chequemb, 
			INTEGER 	AS rec_chequeob, 
			INTEGER 	AS rec_tarcred, 
			MONEY(16,2) AS cob_efectivo, 
			MONEY(16,2) AS cob_cheqmb, 
			MONEY(16,2) AS cob_cheqob, 
			MONEY(16,2) AS cob_tarcred, 
			MONEY(16,2) AS liq_miercoles, 
			MONEY(16,2) AS liq_jueves, 
			MONEY(16,2) AS liq_viernes,
			MONEY(16,2) AS liq_lunes, 
			MONEY(16,2) AS liq_martes, 
			MONEY(16,2) AS aclaraciones, 
			MONEY(16,2) AS comision, 
			MONEY(16,2) AS iva_comision, 
			DATE        AS fec_iniperiodo, 
			DATE 	    AS fec_finperiodo, 
			INTEGER 	AS keyx;
			
 --Definicion de Variables    
	DEFINE cCodRet			CHAR (6);
	DEFINE cInfoErr         CHAR(100);
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE iRecLunes		INTEGER; 
	DEFINE iRecMartes		INTEGER;
	DEFINE iRecMiercoles	INTEGER;
	DEFINE iRecJueves		INTEGER;
	DEFINE iRecViernes		INTEGER;
	DEFINE iRecSabado		INTEGER;
	DEFINE iRecDomingo		INTEGER;
	DEFINE iRecEfectivo		INTEGER;
	DEFINE iRecChequemb		INTEGER;
	DEFINE iRecChequeob		INTEGER;
	DEFINE iRecTarcred		INTEGER;
	DEFINE iCobEfectivo		INTEGER;
	DEFINE dFecIniPeriodo	DATE;
	DEFINE dFecFinPeriodo	DATE;
	DEFINE mCobLunes		MONEY(16,2);
	DEFINE mCobMartes		MONEY(16,2); 
	DEFINE mCobMiercoles	MONEY(16,2);
	DEFINE mCobJueves		MONEY(16,2);
	DEFINE mCobViernes		MONEY(16,2);
	DEFINE mCobSabado		MONEY(16,2);
	DEFINE mCobDomingo		MONEY(16,2);
	DEFINE mCobCheqmb		MONEY(16,2);
	DEFINE mCobCheqob		MONEY(16,2);
	DEFINE mCobTarcred		MONEY(16,2);
	DEFINE mLiqMiercoles	MONEY(16,2);
	DEFINE mLiqJueves		MONEY(16,2);
	DEFINE mLiqViernes		MONEY(16,2);
	DEFINE mLiqLunes		MONEY(16,2);
	DEFINE mLiqMartes		MONEY(16,2);
	DEFINE mAclaraciones	MONEY(16,2);
	DEFINE mComision		MONEY(16,2);
	DEFINE mIvaComision		MONEY(16,2);

--Inicializacion de Variables
	LET cCodRet			= '000000';
	LET iRecLunes		= 0;
	LET iRecMartes		= 0;
	LET iRecMiercoles	= 0;
	LET iRecJueves		= 0;
	LET iRecViernes		= 0;
	LET iRecSabado		= 0;
	LET iRecDomingo		= 0;
	LET mCobLunes		= 0;
	LET mCobMartes		= 0;
	LET mCobMiercoles	= 0;
	LET mCobJueves		= 0;
	LET mCobViernes		= 0;
	LET mCobSabado		= 0;
	LET mCobDomingo		= 0;
	LET iRecEfectivo	= 0;
	LET iRecChequemb	= 0;
	LET iRecChequeob	= 0;
	LET iRecTarcred		= 0;
	LET iCobEfectivo	= 0;
	LET mCobCheqmb		= 0;
	LET mCobCheqob		= 0;
	LET mCobTarcred		= 0;
	LET mLiqMiercoles	= 0;
	LET mLiqJueves		= 0;
	LET mLiqViernes		= 0;
	LET mLiqLunes		= 0;
	LET mLiqMartes		= 0;
	LET mAclaraciones	= 0;
	LET mComision		= 0;
	LET mIvaComision	= 0;
	LET dFecIniPeriodo	= DATE (1);
	LET dFecFinPeriodo	= DATE (1);
	LET iSqlErr			= 0;
	LET iIsamErr		= 0;
	LET cInfoErr		= '';
	
	--SET DEBUG FILE TO  '/tmp/sp_sacreportesemanaldyclass.out';
	--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr

		IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportesemanaldyclass");
				RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes, 
					mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, iCobEfectivo, 
					mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqLunes, mLiqMartes, mAclaraciones, mComision, 
					mIvaComision, dFecIniPeriodo, dFecFinPeriodo, pConsecutivo;
		END IF;

	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;

	IF  pConsecutivo IS NULL THEN
		LET cCodRet = "00001";
		RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes, 
			mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, iCobEfectivo, 
			mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqLunes, mLiqMartes, mAclaraciones, mComision, 
			mIvaComision, dFecIniPeriodo, dFecFinPeriodo, pConsecutivo;
	ELSE   
		SET ISOLATION TO DIRTY READ;
			FOREACH
				SELECT {+INDEX (bdisac:"informix".sac_liquidacionsemanal idx_sacliqsem)} rec_lunes, rec_martes, rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo, cob_lunes, cob_martes, 
					cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo, rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred, 
					cob_efectivo, cob_cheqmb, cob_cheqob, cob_tarcred, liq_miercoles, liq_jueves, liq_viernes, liq_lunes, liq_martes, 
					aclaraciones, comision, iva_comision, fec_iniperiodo, fec_finperiodo
				INTO iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes, 
					mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, iCobEfectivo, 
					mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqLunes, mLiqMartes, mAclaraciones, mComision, 
					mIvaComision, dFecIniPeriodo, dFecFinPeriodo 
				FROM bdisac:"informix".sac_liquidacionsemanal
				WHERE id_convenio = pConvenio 
				AND  consecutivo_convenio  = pConsecutivo 
				
					
				RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes, 
					mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, iCobEfectivo, 
					mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqLunes, mLiqMartes, mAclaraciones, mComision, 
					mIvaComision, dFecIniPeriodo, dFecFinPeriodo, pConsecutivo WITH RESUME;
			END FOREACH;
	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR : Martín Eduardo Miranda',
'DESCRIPCIÓN: Consulta la informacion para la generacion del reporte de liquidacion semanal de pagos Dyclass',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : 05 Julio 2012',
'VERSIÓN: 20120705.1431',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_bts_obtieneinfoidentificacion(pTipoEjec CHAR(1), pCodTipoIdent CHAR(3))
RETURNING
	CHAR(6)  		AS  COD_RET,
	VARCHAR(80) 	AS  MENS_RET,
	CHAR(3)  		AS  COD_IDENTIFICACION,
	CHAR(3) 		AS  DESC_IDENTIFICACION;

--DECLARACIONES
DEFINE iSqlErr         	INTEGER;
DEFINE iIsamErr			INTEGER;
DEFINE cErrorInfo		CHAR(80);
DEFINE cCodRet         	CHAR(6);
DEFINE vMensajeRet      VARCHAR(80);
DEFINE cCodTipoIdentificacion          CHAR(3);
DEFINE cDescTipoIdentificacion     CHAR(3);

--INICIALIZACIONES
LET iSqlErr            = 0;
LET iIsamErr           = 0;
LET cErrorInfo         = "";
LET cCodRet            = "000000";
LET vMensajeRet        = "SE REALIZO LA CONSULTA CORRECTAMENTE";
LET cCodTipoIdentificacion            = "";
LET cDescTipoIdentificacion       = "";

	BEGIN

		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				LET vMensajeRet = cErrorInfo;
				RETURN TRIM(cCodRet), TRIM(vMensajeRet),'','';
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--SET DEBUG FILE TO '/tmp/sp_bts_obtieneinfoidentificacion.out';
		--TRACE ON;

	IF pTipoEjec = "1" THEN
		--CONSULTA PARA OBTENER LOS TIPOS DE IDENTIFICACION VALIDOS PARA BTS
		FOREACH
			SELECT DISTINCT id_issuer_cd
			INTO  cDescTipoIdentificacion
			FROM bdisac:"informix".sac_identificacion
			WHERE flg_bts = 1

			RETURN cCodRet, TRIM(vMensajeRet),TRIM(NVL(cCodTipoIdentificacion, '')), TRIM(NVL(cDescTipoIdentificacion, '')) WITH RESUME;
		END FOREACH;
		-- VALIDA SI NO HAY DATOS
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet= "000002";
			LET vMensajeRet = "ERROR, NO SE ENCONTRO INFORMACION";
			RETURN TRIM(cCodRet), TRIM(vMensajeRet), '','';
		END IF;
		
	ELIF pTipoEjec = "2" THEN
		--CONSULTA PARA OBTENER LOS TIPOS DE IDENTIFICACION VALIDOS PARA BTS
		FOREACH
			SELECT id_type_cd
			INTO  cCodTipoIdentificacion
			FROM bdisac:"informix".sac_identificacion
			WHERE flg_bts = 1
			AND id_issuer_cd = pCodTipoIdent

			RETURN cCodRet, TRIM(vMensajeRet),TRIM(NVL(cCodTipoIdentificacion, '')), TRIM(NVL(cDescTipoIdentificacion, '')) WITH RESUME;
		END FOREACH;
		-- VALIDA SI NO HAY DATOS
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet= "000002";
			LET vMensajeRet = "ERROR, NO SE ENCONTRO INFORMACION";
			RETURN TRIM(cCodRet), TRIM(vMensajeRet), '','';
		END IF;

	ELIF pTipoEjec = "3" THEN
		--CONSULTA PARA OBTENER LOS TIPOS DE IDENTIFICACION VALIDOS PARA BTS
		FOREACH

			SELECT id_type_cd, id_issuer_cd
			INTO  cCodTipoIdentificacion, cDescTipoIdentificacion
			FROM bdisac:"informix".sac_identificacion
			WHERE flg_bts = 1

			RETURN cCodRet, TRIM(vMensajeRet),TRIM(NVL(cCodTipoIdentificacion, '')), TRIM(NVL(cDescTipoIdentificacion, '')) WITH RESUME;
		END FOREACH;

		-- VALIDA SI NO HAY DATOS
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet= "000002";
			LET vMensajeRet = "ERROR, NO SE ENCONTRO INFORMACION";
			RETURN TRIM(cCodRet), TRIM(vMensajeRet), '','';
		END IF;
	END IF
		
		
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION : Se realiza procedimiento para Obtener el listado de Sucursales',
'AUTOR : Jesus Aguilar',
'FECHA : 05/septiembre/2012',
'BD    : BDISAC',
'DESCRIPCION MODIFICACION: Se modifica para que se ejecute en 3 tipos de consulta para el codigo y tipo de identificacion',
'MODIFICO : Mohamed Carreon',
'VERSION:20121011.1207';

CREATE PROCEDURE "informix".sp_bts_recuperacdep(pcUsuario CHAR(8), piRegs_recup INTEGER, pcFecha_peticion CHAR(8), pcHora_peticion CHAR(6))
	RETURNING CHAR(5),CHAR(11),CHAR(4),CHAR(8),CHAR(6);

--Definicion de Variables
DEFINE iSqlErr INTEGER;
DEFINE iIsamError 		INTEGER;
DEFINE cCod_err 		CHAR(4);
DEFINE cConfirmation_nm CHAR(11);
DEFINE cOpcode_cdep 	CHAR(4);
DEFINE cFecha_proceso 	CHAR(8);
DEFINE cHora_proceso 	CHAR(6);
DEFINE cNombre_preceso	CHAR(19);
DEFINE cCadena_ent		CHAR(100);
DEFINE cOpcode 			CHAR(4);
DEFINE cDescr_mensaje 	CHAR(50);
DEFINE cCod_retorno		CHAR(5);

DEFINE cFecha_dia		CHAR(8);
DEFINE dtFecha_dia		DATE;
DEFINE cValor			CHAR(100);

--Inicializacion de Variables
LET iSqlErr = 0;
LET iIsamError = 0;
LET cCod_err = '0000';
LET cConfirmation_nm = '';
LET cOpcode_cdep = '0000';
LET cFecha_proceso = YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0');
LET cHora_proceso = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
LET cNombre_preceso = 'sp_bts_recuperacdep';
LET cCadena_ent = 	NVL(piRegs_recup,0) || '|' || TRIM(NVL(pcFecha_peticion,'NULL')) || '|' || TRIM(NVL(pcHora_peticion,'NULL'));
LET cOpcode 		= '';
LET cDescr_mensaje 	= '';
LET cCod_retorno 	= '';
LET cValor	 		= '';

LET cFecha_dia = '';
LET dtFecha_dia = CURRENT::DATE;

--SET DEBUG FILE TO '/tmp/RMBTS/sp_bts_recuperacdep.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr,iIsamError
		IF iSqlErr <> 0 THEN
			LET cCod_err = iSqlErr;			
			LET cDescr_mensaje = '';
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso, cCod_err, cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pcFecha_peticion, pcHora_peticion)
			INTO cCod_retorno;
			
			RETURN cCod_err,cConfirmation_nm,cOpcode_cdep,cFecha_proceso,cHora_proceso;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--Se inserta el registro del proceso en curso
	INSERT INTO bdisac:"informix".sac_ws_procesos(proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert)
	VALUES(cNombre_preceso,pcFecha_peticion,pcHora_peticion,'0','',pcUsuario,current::date,cHora_proceso);
	
	IF piRegs_recup > 0 THEN

		SELECT NVL(valor,'0')
			INTO cValor
			FROM bdisac:"informix".sac_param 
			WHERE cod_param = '87013';	
			
			FOREACH
				SELECT LIMIT piRegs_recup num_confirmacion
					INTO cConfirmation_nm
					FROM bdisac:"informix".sac_bts_sdep 
					WHERE estatus_sdep = '01'					
--					WHERE estatus_sdep = 'XX'										
						AND intentos_envio <= cValor
				
				RETURN LPAD(cCod_err,5,'0'),cConfirmation_nm,cOpcode_cdep,cFecha_proceso,cHora_proceso WITH RESUME;
			END FOREACH;
			
			 IF  dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCod_err = '9984';

					--Se obtienen los mensajes de error asi como el codigo del mensaje
				SELECT NVL(opcode, ''),NVL(opcode_sd, '')
					INTO cOpcode,cDescr_mensaje 
					FROM bdisac:"informix".sac_bts_catmensajes WHERE agent_trans_type_code = 'CDEP' AND opcode = cCod_err;
					
				--En caso de que no exista el codigo del mensaje se les asigna otros valores
				IF cOpcode IS NULL THEN			
					LET cDescr_mensaje = 'Código no registrado en catálogo.';			
				END IF;

				-- En caso de que existan registros que fueron bloqueados temporalmente estatus_sdep='08', se regresan a '01'
				UPDATE bdisac:"informix".sac_bts_sdep 
				SET estatus_sdep = '01'
				WHERE estatus_sdep = '08';							
					
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso, LPAD(cCod_err,5,'0'), cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pcFecha_peticion, pcHora_peticion)
					INTO cCod_retorno;

				RETURN LPAD(cCod_err,5,'0'),cConfirmation_nm,cOpcode_cdep,cFecha_proceso,cHora_proceso;
			END IF;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(2,cNombre_preceso, LPAD(cCod_err,5,'0'), cDescr_mensaje, '', '', cCadena_ent, pcUsuario, pcFecha_peticion, pcHora_peticion)		
			INTO cCod_retorno;
			
/*		ELSE
			LET cCod_err = '9986';
		END IF;*/
	ELSE
		LET cCod_err = '9001';
	END IF;
	
	IF cCod_err <> '0000' THEN		
		
		--Se obtienen los mensajes de error asi como el codigo del mensaje
		SELECT NVL(opcode, ''),NVL(opcode_sd, '')
		INTO cOpcode,cDescr_mensaje 
		FROM bdisac:"informix".sac_bts_catmensajes WHERE agent_trans_type_code = 'CDEP' AND opcode = cCod_err;
	
		--En caso de que no exista el codigo del mensaje se les asigna otros valores
		IF cOpcode IS NULL THEN			
			LET cDescr_mensaje = 'Código no registrado en catálogo.';			
		END IF;
		
		--Se inserta el error generado en la tabla sac_ws_errores Y Se actualiza la tabla sac_ws_procesos con el codigo de error generado
		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso, LPAD(cCod_err,5,'0'), cDescr_mensaje, '', '', cCadena_ent, pcUsuario, pcFecha_peticion, pcHora_peticion)		
		INTO cCod_retorno;		
		
		RETURN LPAD(cCod_err,5,'0'),cConfirmation_nm,cOpcode_cdep,cFecha_proceso,cHora_proceso;
	END IF;		
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Regresa un numero determinado de registros guadado0s de forma exitosa',
'AUTOR : José Luís Polanco B.',
'FECHA : 05 de Noviembre de 2012',
'VERSION: 1.0',
'BD: BDISAC',
'SISTEMA : Sistema Administrador de Convenios';

CREATE PROCEDURE "informix".sp_conciliaciontotalporconvenio_pba(cConvenio CHAR(5), dFechaIni DATE, dFechaFin DATE)
    RETURNING
    CHAR(5)         AS retorno,
    CHAR(40)        AS nomconvenio,
    DATE            AS fecha_pago,
    DECIMAL(16,2)   AS importe_archivo,
    CHAR(30)        AS cuenta_cheques,
    DECIMAL(16,2)   AS importe_cheq,
    CHAR(30)        AS cuenta_contable,
    DECIMAL(16,2)   AS importe_conta;

    DEFINE iSqlErr              INTEGER;
    DEFINE iIsamErr             INTEGER;
    DEFINE cInfoErr             CHAR(100);
    DEFINE cConveniosNoConciliables  CHAR(100);
    DEFINE cCodRet              CHAR(5);
    DEFINE cNomConvenio         CHAR(40);
    DEFINE cConv 		        CHAR(3);
    DEFINE cCateg       	  CHAR(2);
    DEFINE dFecha_pago          DATE;
    DEFINE deImporte_archivo    DECIMAL(16,2);
    DEFINE cCuenta_cheques      CHAR(30);
    DEFINE deImporte_cheq       DECIMAL(16,2);
    DEFINE cCuenta_contable     CHAR(30);
    DEFINE deImporte_conta      DECIMAL(16,2);
    DEFINE iTransCargoCuenta    INTEGER;
    DEFINE mCargoCuenta         MONEY(16,2);
    DEFINE mCargoEfectivo       MONEY(16,2);
    DEFINE cNumTransaccEfec     CHAR(4);
    DEFINE dFechaHoy            DATE;
    DEFINE iProceso_automatico  INTEGER;
    DEFINE vconsmovhis      CHAR(10);
    DEFINE vconsmovhisold   CHAR(10);

    	SET DEBUG FILE TO  'sp_conciliaciontotalporconvenio.trc';
    	TRACE ON;
    
	LET cCodRet  =   "00000";
    LET cNomConvenio  = "";
    LET cConv  = "";
    LET cCateg  = "";
    LET dFecha_pago  = "01-01-1990";
    LET deImporte_archivo  = 0;
    LET cCuenta_cheques   = "";
    LET deImporte_cheq  = 0;
    LET cCuenta_contable  = "";
    LET deImporte_conta =  0;
    LET dFecha_pago  = dFechaIni;
    LET iTransCargoCuenta = 0;
    LET mCargoCuenta = 0;
    LET mCargoEfectivo = 0;
    LET cNumTransaccEfec = '';
    LET cConveniosNoConciliables = '';
    LET dFechaHoy = '01-01-1900';
    LET iProceso_automatico = 0;

    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_ConciliacionTotalPorConvenio");
                RETURN cCodRet, cNomConvenio,  dFecha_pago,  deImporte_archivo,  cCuenta_cheques, deImporte_cheq, cCuenta_contable, deImporte_conta;
            END IF;
        END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		
        IF cConvenio = "" OR LENGTH(cConvenio) <> 5 THEN
            LET cCodRet = "00001";
            RETURN cCodRet, cNomConvenio,  dFecha_pago,  deImporte_archivo,  cCuenta_cheques, deImporte_cheq, cCuenta_contable, deImporte_conta;
        ELSE
		SET ISOLATION TO DIRTY READ;
            SELECT fecha_hoy
            INTO dFechaHoy
            FROM bdisac:"informix".sac_fechas;

			SET ISOLATION TO DIRTY READ;
			SELECT {+INDEX (bdisac:sac_param idxsc_par)} valor
			INTO cConveniosNoConciliables
			FROM bdisac:"informix".sac_param
			WHERE cod_param = 79;

			SET ISOLATION TO DIRTY READ;
            SELECT valor
              INTO vconsmovhis
              FROM bdicheq:"informix".sc_param
             WHERE codparam = 'fechcon_movhis'
               AND  empresa = '001';

			SET ISOLATION TO DIRTY READ;
            SELECT valor
              INTO vconsmovhisold
              FROM bdicheq:"informix".sc_param
             WHERE codparam = 'FechIniCon_movhis_ol'
               AND empresa = '001';	

			SET ISOLATION TO DIRTY READ;
			
			IF EXISTS(SELECT *  FROM sysmaster:"informix".systabnames  Where tabname = 'tmpcontable') THEN
                ---DROP TABLE tmpcontable;
            END IF;
			
            IF cConvenio = "00000" THEN      -- Todos los convenios
			SET ISOLATION TO DIRTY READ;

--	2013.02.01 I. Se optimiza consulta para obtener las cuentas contables de la tabla bdisac:sac_convenios y no usar la bdisac:sac_param
/* 
				SELECT 1 AS tabla, cc.convenio, a.ccmayor, a.ccsub, a.ccsubsub,
                                a.ccssubsub, a.ccsssubsub, a.sector, a.mes_dia, SUM(a.abonos_dia) AS monto
                FROM bdicont:"informix".co_sdodias a, TABLE ( MULTISET (SELECT {+INDEX (bdisac:sac_param idxsc_par)} SUBSTRING (cod_param FROM 2 FOR 5) AS convenio,
                                                                    SUBSTRING (valor FROM 1 FOR 4) AS ccmayor,
                                                                    SUBSTRING (valor FROM 5 FOR 2) AS ccsub,
                                                                    SUBSTRING (valor FROM 7 FOR 2) AS ccsubsub,
                                                                    SUBSTRING (valor FROM 9 FOR 2) AS ccssubsub,
                                                                    SUBSTRING (valor FROM 11 FOR 2) AS ccsssubsub,
                                                                    SUBSTRING (valor FROM 13 FOR 2) AS sector
                                                                    FROM bdisac:sac_param WHERE SUBSTRING(cod_param FROM 1 FOR 1) = '7'
                                                                    AND SUBSTRING (cod_param FROM 2 FOR 5) IN ( SELECT {+INDEX (bdisac:sac_convenios 103_4)} numcategoria || numconvenio
                                                                                                                FROM bdisac:"informix".sac_convenios
																												WHERE NOT cConveniosNoConciliables   LIKE
																												'%'|| TRIM(numcategoria)|| TRIM(numconvenio)||'%' AND proceso_automatico = 0))) cc
                WHERE a.ccmayor  = cc.ccmayor
                AND a.ccsub = cc.ccsub
                AND a.ccsubsub = cc.ccsubsub
                AND a.ccssubsub = cc.ccssubsub
                AND a.ccsssubsub = cc.ccsssubsub
                AND a.sector = cc.sector
                AND a.empresa = '001'
                AND a.moneda IS NOT NULL
                AND a.sucursal IS NOT NULL
                AND a.ciudad IS NOT NULL
                AND a.mes_dia <= dFechaFin
                GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
                UNION ALL
				SELECT 1 AS tabla, cc.convenio, a.ccmayor, a.ccsub, a.ccsubsub,
                                a.ccssubsub, a.ccsssubsub, a.sector, a.mes_dia, SUM(a.abonos_dia) AS monto
                FROM bdicont:"informix".co_sdodias a, TABLE ( MULTISET (SELECT numcategoria || numconvenio AS convenio,
			                                                    SUBSTRING (cuenta_contable FROM 1 FOR 4) AS ccmayor,
			                                                    SUBSTRING (cuenta_contable FROM 5 FOR 2) AS ccsub,
			                                                    SUBSTRING (cuenta_contable FROM 7 FOR 2) AS ccsubsub,
			                                                    SUBSTRING (cuenta_contable FROM 9 FOR 2) AS ccssubsub,
			                                                    SUBSTRING (cuenta_contable FROM 11 FOR 2) AS ccsssubsub,
			                                                    SUBSTRING (cuenta_contable FROM 13 FOR 2) AS sector
			                                                    FROM bdisac:"informix".sac_convenios WHERE proceso_automatico = 1)) cc
                WHERE a.ccmayor  = cc.ccmayor
                AND a.ccsub = cc.ccsub
                AND a.ccsubsub = cc.ccsubsub
                AND a.ccssubsub = cc.ccssubsub
                AND a.ccsssubsub = cc.ccsssubsub
                AND a.sector = cc.sector
                AND a.empresa = '001'
                AND a.moneda IS NOT NULL
                AND a.sucursal IS NOT NULL
                AND a.ciudad IS NOT NULL
                AND a.mes_dia <= dFechaFin
                GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
                UNION ALL
                SELECT 2 AS tabla, cc.convenio, a.ccmayor, a.ccsub, a.ccsubsub,
                                a.ccssubsub, a.ccsssubsub, a.sector, a.mes_dia, SUM(a.abonos_dia) AS monto
                FROM bdicont:"informix".co_histsdodias a, TABLE ( MULTISET (SELECT {+INDEX (bdisac:sac_param idxsc_par)} SUBSTRING (cod_param FROM 2 FOR 5) AS convenio,
                                                                      SUBSTRING (valor FROM 1 FOR 4) AS ccmayor,
                                                                      SUBSTRING (valor FROM 5 FOR 2) AS ccsub,
                                                                      SUBSTRING (valor FROM 7 FOR 2) AS ccsubsub,
                                                                      SUBSTRING (valor FROM 9 FOR 2) AS ccssubsub,
                                                                      SUBSTRING (valor FROM 11 FOR 2) AS ccsssubsub,
                                                                      SUBSTRING (valor FROM 13 FOR 2) AS sector
                                                                      FROM bdisac:"informix".sac_param WHERE SUBSTRING(cod_param FROM 1 FOR 1) = '7'
                                                                      AND SUBSTRING (cod_param FROM 2 FOR 5) IN ( SELECT {+INDEX (bdisac:"informix".sac_convenios 103_4)} numcategoria || numconvenio
                                                                                                                  FROM bdisac:"informix".sac_convenios
																												  WHERE NOT cConveniosNoConciliables   LIKE
																												'%'|| TRIM(numcategoria)|| TRIM(numconvenio)||'%' AND proceso_automatico = 0))) cc
                WHERE a.ccmayor  = cc.ccmayor
                AND a.ccsub = cc.ccsub
                AND a.ccsubsub = cc.ccsubsub
                AND a.ccssubsub = cc.ccssubsub
                AND a.ccsssubsub = cc.ccsssubsub
                AND a.sector = cc.sector
                AND a.empresa = '001'
                AND a.moneda IS NOT NULL
                AND a.sucursal IS NOT NULL
                AND a.ciudad IS NOT NULL
                AND mes_dia >= dFechaIni
                GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
				UNION ALL
				 SELECT 2 AS tabla, cc.convenio, a.ccmayor, a.ccsub, a.ccsubsub,
                                a.ccssubsub, a.ccsssubsub, a.sector, a.mes_dia, SUM(a.abonos_dia) AS monto
                FROM bdicont:"informix".co_histsdodias a, TABLE ( MULTISET (SELECT numcategoria || numconvenio AS convenio,
			                                                    SUBSTRING (cuenta_contable FROM 1 FOR 4) AS ccmayor,
			                                                    SUBSTRING (cuenta_contable FROM 5 FOR 2) AS ccsub,
			                                                    SUBSTRING (cuenta_contable FROM 7 FOR 2) AS ccsubsub,
			                                                    SUBSTRING (cuenta_contable FROM 9 FOR 2) AS ccssubsub,
			                                                    SUBSTRING (cuenta_contable FROM 11 FOR 2) AS ccsssubsub,
			                                                    SUBSTRING (cuenta_contable FROM 13 FOR 2) AS sector
			                                                    FROM bdisac:"informix".sac_convenios WHERE proceso_automatico = 1)) cc
                WHERE a.ccmayor  = cc.ccmayor
                AND a.ccsub = cc.ccsub
                AND a.ccsubsub = cc.ccsubsub
                AND a.ccssubsub = cc.ccssubsub
                AND a.ccsssubsub = cc.ccsssubsub
                AND a.sector = cc.sector
                AND a.empresa = '001'
                AND a.moneda IS NOT NULL
                AND a.sucursal IS NOT NULL
                AND a.ciudad IS NOT NULL
                AND mes_dia >= dFechaIni
                GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
				ORDER BY 9
                INTO TEMP tmpcontable
				WITH NO LOG;
*/
			SET ISOLATION TO DIRTY READ;
                SELECT 1 AS tabla, cc.convenio, a.ccmayor, a.ccsub, a.ccsubsub,
                                a.ccssubsub, a.ccsssubsub, a.sector, a.mes_dia, SUM(a.abonos_dia) AS monto
                FROM bdicont:"informix".co_sdodias a, TABLE ( MULTISET (SELECT  numcategoria || numconvenio AS convenio,
														SUBSTRING (cuenta_contable FROM 1 FOR 4) AS ccmayor,
                                                        SUBSTRING (cuenta_contable FROM 5 FOR 2) AS ccsub,
                                                        SUBSTRING (cuenta_contable FROM 7 FOR 2) AS ccsubsub,
                                                        SUBSTRING (cuenta_contable FROM 9 FOR 2) AS ccssubsub,
                                                        SUBSTRING (cuenta_contable FROM 11 FOR 2) AS ccsssubsub,
                                                        SUBSTRING (cuenta_contable FROM 13 FOR 2) AS sector
                                                        FROM bdisac:sac_convenios WHERE trans_suc_efectivo NOT IN ('8701', '8702', '8703'))) cc
                WHERE a.empresa = '001' and a.ccmayor in ('2101', '2402') and a.ccsub='01' and a.ccsubsub in ('03', '90')
				AND a.ccmayor  = cc.ccmayor
                AND a.ccsub = cc.ccsub
                AND a.ccsubsub = cc.ccsubsub
                AND a.ccssubsub = cc.ccssubsub
                AND a.ccsssubsub = cc.ccsssubsub
                AND a.sector = cc.sector
                AND a.ciudad IS NOT NULL
				AND a.sucursal IS NOT NULL
                AND a.moneda IS NOT NULL
                AND a.mes_dia <= dFechaFin
                GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
UNION ALL
                SELECT 2 AS tabla, cc.convenio, a.ccmayor, a.ccsub, a.ccsubsub,
                                a.ccssubsub, a.ccsssubsub, a.sector, a.mes_dia, SUM(a.abonos_dia) AS monto
                FROM bdicont:"informix".co_histsdodias a, TABLE ( MULTISET (SELECT  numcategoria || numconvenio AS convenio,
															SUBSTRING (cuenta_contable FROM 1 FOR 4) AS ccmayor,
                                                            SUBSTRING (cuenta_contable FROM 5 FOR 2) AS ccsub,
                                                            SUBSTRING (cuenta_contable FROM 7 FOR 2) AS ccsubsub,
                                                            SUBSTRING (cuenta_contable FROM 9 FOR 2) AS ccssubsub,
                                                            SUBSTRING (cuenta_contable FROM 11 FOR 2) AS ccsssubsub,
                                                            SUBSTRING (cuenta_contable FROM 13 FOR 2) AS sector
                                                            FROM bdisac:sac_convenios WHERE trans_suc_efectivo NOT IN ('8701', '8702', '8703'))) cc
                WHERE a.ccmayor  = cc.ccmayor
                AND a.ccsub = cc.ccsub
                AND a.ccsubsub = cc.ccsubsub
                AND a.ccssubsub = cc.ccssubsub
                AND a.ccsssubsub = cc.ccsssubsub
                AND a.sector = cc.sector
                AND a.empresa = '001'
                AND a.moneda IS NOT NULL
                AND a.sucursal IS NOT NULL
                AND a.ciudad IS NOT NULL
                AND mes_dia >= dFechaIni
                GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
				ORDER BY 9
                INTO TEMP tmpcontable
				WITH NO LOG;
--	2013.02.01 F. 
				SET ISOLATION TO DIRTY READ;
                FOREACH
                    -- Obtiene Nombre de Convenio
                    SELECT {+INDEX (bdisac:sac_convenios 103_4)} nomconvenio, numcategoria || numconvenio, numconvenio, numcategoria, NVL(cuenta_contable,''), 
					      NVL(cuenta_prestadora,''), NVL(proceso_automatico,0), NVL(trans_cen_abono_convenio,''), NVL(trans_cen_efectivo_cliente,'')
                    INTO cNomConvenio, cConvenio, cConv, cCateg, cCuenta_contable, 
					     cCuenta_cheques, iProceso_automatico, iTransCargoCuenta, cNumTransaccEfec
                    FROM bdisac:"informix".sac_convenios
					WHERE NOT cConveniosNoConciliables   LIKE
					'%'|| TRIM(numcategoria)|| TRIM(numconvenio)||'%'

                    -- Obtiene Cuenta Contable
                    IF iProceso_automatico = 0 THEN
					SET ISOLATION TO DIRTY READ;
                    SELECT {+INDEX (bdisac:"informix".sac_param idxsc_par)} valor
                    INTO cCuenta_contable
                    FROM bdisac:"informix".sac_param
                    WHERE SUBSTRING(cod_param FROM 1 FOR 1) = '7'
                    AND SUBSTRING (cod_param FROM 2 FOR 5) = cConvenio;
					END IF;	

                    WHILE dFecha_pago <= dFechaFin
							SET ISOLATION TO DIRTY READ;
                            -- Obtiene el Monto Total de los Movimientos
                            SELECT {+INDEX (bdisac:sac_movimientoshistorial idxsac_movhisfe)} NVL(SUM(importe_pago), 0)
                            INTO deImporte_archivo
                            FROM bdisac:"informix".sac_movimientoshistorial
                            WHERE numcategoria = cCateg AND numconvenio = cConv
                            AND fecha_pago = dFecha_pago
                            AND status_cancelado = 'N'
							AND flag_confirmacion_central = 1
							AND flag_confirmacion_sucursal = 1;
						IF iProceso_automatico = 0 THEN
							SET ISOLATION TO DIRTY READ;
                            SELECT NVL(SUM(CAST(transCargoCuenta AS INTEGER)), 0) AS transCargoCuenta, NVL(SUM(CAST(transEfec AS INTEGER)), 0) AS transEfec
                            INTO iTransCargoCuenta, cNumTransaccEfec
                            FROM TABLE(MULTISET(SELECT CASE WHEN SUBSTRING(cod_param FROM 1 FOR 1) = '5' AND SUBSTRING (cod_param FROM 2 FOR 5) = cConvenio THEN TRIM(VALOR) END AS transCargoCuenta,
                                        CASE WHEN SUBSTRING(cod_param FROM 1 FOR 1) = '9' AND SUBSTRING (cod_param FROM 2 FOR 5) = cConvenio THEN TRIM(VALOR) END AS transEfec
                                        FROM bdisac:"informix".sac_param));

                            -- Obtiene Numero de Cuenta de Cheques
                            SET ISOLATION TO DIRTY READ;
							SELECT {+INDEX (bdisac:sac_param idxsc_par)} valor
                            INTO cCuenta_cheques
                            FROM bdisac:"informix".sac_param
                            WHERE cod_param = SUBSTRING(cConvenio FROM 2 FOR 4);
                       END IF;							

                            -- Obtiene el Monto Total de la Cuenta Contable
                            IF MONTH(dFecha_pago) = MONTH(dFechaHoy) AND YEAR(dFecha_pago) = YEAR(dFechaHoy)  THEN
                                SET ISOLATION TO DIRTY READ;
								SELECT NVL(SUM(monto),0)
                                INTO deImporte_conta
                                FROM tmpcontable
                                WHERE convenio = cConvenio
                                AND mes_dia = dFecha_pago
                                AND tabla = 1;
                            ELSE
                                SET ISOLATION TO DIRTY READ;
								SELECT NVL(SUM(monto),0)
                                INTO deImporte_conta
                                FROM tmpcontable
                                WHERE convenio = cConvenio
                                AND mes_dia = dFecha_pago
                                AND tabla = 2;
                            END IF;
                            if dFechaIni >= vconsmovhis then
				IF(cConvenio = "07004")THEN
				   LET mCargoEfectivo = 0;
   				   SET LOCK MODE TO WAIT 3;
				   SET ISOLATION TO DIRTY READ;
					SELECT NVL(SUM(monto_tot), 0)
					INTO mCargoCuenta
					FROM bdicheq:"informix".sc_movhis
					WHERE cuenta = cCuenta_cheques
					AND fech_val = dFecha_pago
					AND transacc IN ('1140', '1110')
					AND NVL(cancelad, '') <> 'S';
				ELSE
					SET LOCK MODE TO WAIT 3;
					SET ISOLATION TO DIRTY READ;
 				    SELECT NVL(SUM(monto_totCargo), 0) AS totCargo, NVL(SUM(totEfectivo), 0) AS totEfectivo
                                    INTO mCargoCuenta, mCargoEfectivo
                                    FROM TABLE(MULTISET(SELECT CASE WHEN transacc = CAST(iTransCargoCuenta AS CHAR(4)) THEN monto_tot END AS monto_totCargo,
                                         CASE WHEN transacc = CAST(cNumTransaccEfec AS CHAR(4))  THEN monto_tot END AS totEfectivo
                                                    FROM bdicheq:"informix".sc_movhis
                                                    WHERE cuenta = cCuenta_cheques
                                                    AND fech_val = dFecha_pago
                                                    AND NVL(cancelad, '') <> 'S'));
				END IF;
                            else
				IF(cConvenio = "07004")THEN
				LET mCargoEfectivo = 0;
					SET LOCK MODE TO WAIT 3;
					SET ISOLATION TO DIRTY READ;
					SELECT NVL(SUM(monto_tot), 0)
 				        INTO mCargoCuenta
					FROM bdicheq:"informix".sc_movhis_old
					WHERE cuenta = cCuenta_cheques
					AND fech_val = dFecha_pago
					AND transacc IN ('1140', '1110')
					AND NVL(cancelad, '') <> 'S';
				ELSE
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				SELECT NVL(SUM(monto_totCargo), 0) AS totCargo, NVL(SUM(totEfectivo), 0) AS totEfectivo
                                INTO mCargoCuenta, mCargoEfectivo
                                FROM TABLE(MULTISET(SELECT CASE WHEN transacc = CAST(iTransCargoCuenta AS CHAR(4)) THEN monto_tot END AS monto_totCargo,
                                     CASE WHEN transacc = CAST(cNumTransaccEfec AS CHAR(4))  THEN monto_tot END AS totEfectivo
                                     FROM bdicheq:"informix".sc_movhis_old
                                     WHERE cuenta = cCuenta_cheques
                                     AND fech_val = dFecha_pago
    		                     AND NVL(cancelad, '') <> 'S'));
								END IF;
                            end if;
                            RETURN cCodRet, cNomConvenio,  dFecha_pago,  deImporte_archivo,  cCuenta_cheques, mCargoCuenta + mCargoEfectivo, cCuenta_contable, deImporte_conta
                            WITH RESUME;
                        LET dFecha_pago =  dFecha_pago + 1 UNITS DAY;
                    END WHILE;
                    LET dFecha_pago = dFechaIni;
                END FOREACH;
            ELSE-- Un Solo Convenio
				SET ISOLATION TO DIRTY READ;
                SELECT 1 AS tabla, cc.convenio, a.ccmayor, a.ccsub, a.ccsubsub,
                                a.ccssubsub, a.ccsssubsub, a.sector, a.mes_dia, SUM(a.abonos_dia) AS monto
                FROM bdicont:"informix".co_sdodias a, TABLE ( MULTISET (SELECT {+INDEX (bdisac:sac_param idxsc_par)} SUBSTRING (cod_param FROM 2 FOR 5) AS convenio,
                                                                    SUBSTRING (valor FROM 1 FOR 4) AS ccmayor,
                                                                    SUBSTRING (valor FROM 5 FOR 2) AS ccsub,
                                                                    SUBSTRING (valor FROM 7 FOR 2) AS ccsubsub,
                                                                    SUBSTRING (valor FROM 9 FOR 2) AS ccssubsub,
                                                                    SUBSTRING (valor FROM 11 FOR 2) AS ccsssubsub,
                                                                    SUBSTRING (valor FROM 13 FOR 2) AS sector
                                                                    FROM bdisac:sac_param WHERE SUBSTRING(cod_param FROM 1 FOR 1) = '7'
                                                                    AND SUBSTRING (cod_param FROM 2 FOR 5) = cConvenio
																	AND SUBSTRING (cod_param FROM 2 FOR 5) IN ( SELECT numcategoria || numconvenio
                                                                                                                FROM bdisac:sac_convenios 
																												WHERE proceso_automatico = 0))) cc
                WHERE a.ccmayor  = cc.ccmayor
                AND a.ccsub = cc.ccsub
                AND a.ccsubsub = cc.ccsubsub
                AND a.ccssubsub = cc.ccssubsub
                AND a.ccsssubsub = cc.ccsssubsub
                AND a.sector = cc.sector
                AND a.empresa = '001'
                AND a.moneda IS NOT NULL
                AND a.sucursal IS NOT NULL
                AND a.ciudad IS NOT NULL
                AND a.mes_dia <= dFechaFin
                GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
                UNION ALL
				SELECT 1 AS tabla, cc.convenio, a.ccmayor, a.ccsub, a.ccsubsub,
                                a.ccssubsub, a.ccsssubsub, a.sector, a.mes_dia, SUM(a.abonos_dia) AS monto
                FROM bdicont:"informix".co_sdodias a, TABLE ( MULTISET (SELECT numcategoria || numconvenio AS convenio,
                                                                SUBSTRING (cuenta_contable FROM 1 FOR 4) AS ccmayor,
																SUBSTRING (cuenta_contable FROM 5 FOR 2) AS ccsub,
																SUBSTRING (cuenta_contable FROM 7 FOR 2) AS ccsubsub,
																SUBSTRING (cuenta_contable FROM 9 FOR 2) AS ccssubsub,
																SUBSTRING (cuenta_contable FROM 11 FOR 2) AS ccsssubsub,
																SUBSTRING (cuenta_contable FROM 13 FOR 2) AS sector
																FROM bdisac:sac_convenios 
																WHERE TRIM(numcategoria) || TRIM(numconvenio) = cConvenio
																AND proceso_automatico = 1)) cc
                WHERE a.ccmayor  = cc.ccmayor
                AND a.ccsub = cc.ccsub
                AND a.ccsubsub = cc.ccsubsub
                AND a.ccssubsub = cc.ccssubsub
                AND a.ccsssubsub = cc.ccsssubsub
                AND a.sector = cc.sector
                AND a.empresa = '001'
                AND a.moneda IS NOT NULL
                AND a.sucursal IS NOT NULL
                AND a.ciudad IS NOT NULL
                AND a.mes_dia <= dFechaFin
                GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
                UNION ALL
                SELECT 2 AS tabla, cc.convenio, a.ccmayor, a.ccsub, a.ccsubsub,
                                a.ccssubsub, a.ccsssubsub, a.sector, a.mes_dia, SUM(a.abonos_dia) AS monto
                FROM bdicont:"informix".co_histsdodias a, TABLE ( MULTISET (SELECT {+INDEX (bdisac:sac_param idxsc_par)} SUBSTRING (cod_param FROM 2 FOR 5) AS convenio,
                                                                    SUBSTRING (valor FROM 1 FOR 4) AS ccmayor,
                                                                    SUBSTRING (valor FROM 5 FOR 2) AS ccsub,
                                                                    SUBSTRING (valor FROM 7 FOR 2) AS ccsubsub,
                                                                    SUBSTRING (valor FROM 9 FOR 2) AS ccssubsub,
                                                                    SUBSTRING (valor FROM 11 FOR 2) AS ccsssubsub,
                                                                    SUBSTRING (valor FROM 13 FOR 2) AS sector
                                                                    FROM bdisac:sac_param WHERE SUBSTRING(cod_param FROM 1 FOR 1) = '7'
                                                                    AND SUBSTRING (cod_param FROM 2 FOR 5) = cConvenio
																	AND SUBSTRING (cod_param FROM 2 FOR 5) IN ( SELECT numcategoria || numconvenio
                                                                                                                FROM bdisac:sac_convenios 
																												WHERE proceso_automatico = 0))) cc
                WHERE a.ccmayor  = cc.ccmayor
                AND a.ccsub = cc.ccsub
                AND a.ccsubsub = cc.ccsubsub
                AND a.ccssubsub = cc.ccssubsub
                AND a.ccsssubsub = cc.ccsssubsub
                AND a.sector = cc.sector
                AND a.empresa = '001'
                AND a.moneda IS NOT NULL
                AND a.sucursal IS NOT NULL
                AND a.ciudad IS NOT NULL
                AND mes_dia >= dFechaIni
                GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
                UNION ALL
				SELECT  2 AS tabla, cc.convenio, a.ccmayor, a.ccsub, a.ccsubsub,
                                a.ccssubsub, a.ccsssubsub, a.sector, a.mes_dia, SUM(a.abonos_dia) AS monto
                FROM bdicont:"informix".co_histsdodias a, TABLE ( MULTISET (SELECT numcategoria || numconvenio AS convenio,
																SUBSTRING (cuenta_contable FROM 1 FOR 4) AS ccmayor,
																SUBSTRING (cuenta_contable FROM 5 FOR 2) AS ccsub,
																SUBSTRING (cuenta_contable FROM 7 FOR 2) AS ccsubsub,
																SUBSTRING (cuenta_contable FROM 9 FOR 2) AS ccssubsub,
																SUBSTRING (cuenta_contable FROM 11 FOR 2) AS ccsssubsub,
																SUBSTRING (cuenta_contable FROM 13 FOR 2) AS sector
																FROM bdisac:"informix".sac_convenios 
																WHERE TRIM(numcategoria) || TRIM(numconvenio) = cConvenio
																AND proceso_automatico = 1)) cc
               WHERE a.ccmayor  = cc.ccmayor
                AND a.ccsub = cc.ccsub
                AND a.ccsubsub = cc.ccsubsub
                AND a.ccssubsub = cc.ccssubsub
                AND a.ccsssubsub = cc.ccsssubsub
                AND a.sector = cc.sector
                AND a.empresa = '001'
                AND a.moneda IS NOT NULL
                AND a.sucursal IS NOT NULL
                AND a.ciudad IS NOT NULL
                AND mes_dia >= dFechaIni
                GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
				ORDER BY 9
                INTO TEMP tmpcontable
				WITH NO LOG;
								
				SET ISOLATION TO DIRTY READ;
				
				SELECT {+INDEX (bdisac:sac_convenios 103_4)} nomconvenio, numcategoria || numconvenio, numconvenio, numcategoria, NVL(cuenta_contable,''), 
				     NVL(cuenta_prestadora,''), NVL(proceso_automatico,0), NVL(trans_cen_abono_convenio,''), NVL(trans_cen_efectivo_cliente,'')
                INTO cNomConvenio, cConvenio, cConv, cCateg, cCuenta_contable, 
				     cCuenta_cheques, iProceso_automatico, iTransCargoCuenta, cNumTransaccEfec
                FROM bdisac:"informix".sac_convenios
				WHERE numcategoria || numconvenio =  cConvenio
				AND NOT cConveniosNoConciliables   LIKE
				     '%'|| TRIM(numcategoria)|| TRIM(numconvenio)||'%';
				
			IF iProceso_automatico = 0 THEN
                -- Obtiene Cuenta Contable
				SET ISOLATION TO DIRTY READ;
                SELECT {+INDEX (bdisac:sac_param idxsc_par)} valor
                INTO cCuenta_contable
                FROM bdisac:"informix".sac_param
                WHERE SUBSTRING(cod_param FROM 1 FOR 1) = '7'
                AND SUBSTRING (cod_param FROM 2 FOR 5) = cConvenio;
			END IF;	

                WHILE dFecha_pago <= dFechaFin
                    -- Obtiene Monto Total de los Movimientos
                    SET ISOLATION TO DIRTY READ;
					SELECT {+INDEX (bdisac:"informix".sac_movimientoshistorial idxsac_movhisfe)} NVL(SUM(importe_pago), 0)
                    INTO deImporte_archivo
                    FROM bdisac:"informix".sac_movimientoshistorial
                    WHERE numcategoria = cCateg AND numconvenio = cConv
                    AND fecha_pago = dFecha_pago
					AND flag_confirmacion_central = 1
					AND flag_confirmacion_sucursal = 1
                    AND status_cancelado = 'N';

				IF iProceso_automatico = 0 THEN
                    SET ISOLATION TO DIRTY READ;
					SELECT NVL(SUM(CAST(transCargoCuenta AS INTEGER)), 0) AS transCargoCuenta, NVL(SUM(CAST(transEfec AS INTEGER)), 0) AS transEfec
                    INTO iTransCargoCuenta, cNumTransaccEfec
                    FROM TABLE(MULTISET(SELECT CASE WHEN SUBSTRING(cod_param FROM 1 FOR 1) = '5' AND SUBSTRING (cod_param FROM 2 FOR 5) = cConvenio THEN TRIM(VALOR) END AS transCargoCuenta,
                                               CASE WHEN SUBSTRING(cod_param FROM 1 FOR 1) = '9' AND SUBSTRING (cod_param FROM 2 FOR 5) = cConvenio THEN TRIM(VALOR) END AS transEfec
                                        FROM bdisac:"informix".sac_param));
                    -- Obtiene Numero de Cuenta de Cheques
                    SET ISOLATION TO DIRTY READ;
					SELECT {+INDEX (bdisac:sac_param idxsc_par)} valor
                    INTO cCuenta_cheques
                    FROM bdisac:"informix".sac_param
                    WHERE cod_param = SUBSTRING(cConvenio FROM 2 FOR 4);
				END IF;
                    -- Obtiene el Monto Total de la Cuenta Contable
                    IF MONTH(dFecha_pago) = MONTH(dFechaHoy) AND YEAR(dFecha_pago) = YEAR(dFechaHoy)  THEN
                            SET ISOLATION TO DIRTY READ;
							SELECT NVL(SUM(monto),0)
                            INTO deImporte_conta
                            FROM tmpcontable
                            WHERE mes_dia = dFecha_pago
                            AND tabla = 1;
                    ELSE
                            SET ISOLATION TO DIRTY READ;
							SELECT NVL(SUM(monto),0)
                            INTO deImporte_conta
                            FROM tmpcontable
                            WHERE mes_dia = dFecha_pago
                            AND tabla = 2;
                    END IF;
                    if dFechaIni >= vconsmovhis then
						--BTS
						IF(cConvenio = "07004")THEN
						LET mCargoEfectivo = 0;
							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
							SELECT NVL(SUM(monto_tot), 0)
							INTO mCargoCuenta
							FROM bdicheq:"informix".sc_movhis
							WHERE cuenta = cCuenta_cheques
							AND fech_val = dFecha_pago
							AND transacc IN ('1140', '1110')
							AND NVL(cancelad, '') <> 'S';
						ELSE
							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
                        SELECT NVL(SUM(monto_totCargo), 0) AS totCargo, NVL(SUM(totEfectivo), 0) AS totEfectivo
                        INTO mCargoCuenta, mCargoEfectivo
                        FROM TABLE(MULTISET(SELECT CASE WHEN transacc = CAST(iTransCargoCuenta AS CHAR(4)) THEN monto_tot END AS monto_totCargo,
                                                   CASE WHEN transacc = CAST(cNumTransaccEfec AS CHAR(4)) THEN monto_tot END AS totEfectivo
                                            FROM bdicheq:"informix".sc_movhis
                                            WHERE cuenta = cCuenta_cheques
                                            AND fech_val = dFecha_pago
                                            AND NVL(cancelad, '') <> 'S'));
						END IF;
                    else
						--BTS
						IF(cConvenio = "07004")THEN
				LET mCargoEfectivo = 0;
							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
							SELECT NVL(SUM(monto_tot), 0)
							INTO mCargoCuenta
							FROM bdicheq:"informix".sc_movhis_old
							WHERE cuenta = cCuenta_cheques
							AND fech_val = dFecha_pago
							AND transacc IN ('1140', '1110')
							AND NVL(cancelad, '') <> 'S';
						ELSE
							SET LOCK MODE TO WAIT 3;
							SET ISOLATION TO DIRTY READ;
						SELECT NVL(SUM(monto_totCargo), 0) AS totCargo, NVL(SUM(totEfectivo), 0) AS totEfectivo
                        INTO mCargoCuenta, mCargoEfectivo
                        FROM TABLE(MULTISET(SELECT CASE WHEN transacc = CAST(iTransCargoCuenta AS CHAR(4)) THEN monto_tot END AS monto_totCargo,
                                                   CASE WHEN transacc = CAST(cNumTransaccEfec AS CHAR(4)) THEN monto_tot END AS totEfectivo
                                            FROM bdicheq:"informix".sc_movhis_old
                                            WHERE cuenta = cCuenta_cheques
                                            AND fech_val = dFecha_pago
                                            AND NVL(cancelad, '') <> 'S'));
						END IF;                        
                    end if;
                    RETURN cCodRet, cNomConvenio,  dFecha_pago,  deImporte_archivo,  cCuenta_cheques, mCargoCuenta + mCargoEfectivo, cCuenta_contable, deImporte_conta
                    WITH RESUME;
                    LET dFecha_pago =  dFecha_pago + 1 UNITS DAY;
                END WHILE;
            END IF;
			SET ISOLATION TO DIRTY READ;
            IF EXISTS(SELECT *  FROM sysmaster:"informix".systabnames  Where tabname = 'tmpcontable') THEN
                ---DROP TABLE tmpcontable;
            END IF;
        END IF;
    END;
END PROCEDURE
DOCUMENT
'AUTOR : Jesus Alberto Moreno',
'FECHA  : Febrero del 2009',
'VERSION: 20090203.1308',
'BD     : bdisac',
'MODIFICACION: 12/Febrero/2009',
'AUTOR: Raúl René Ruiz',
'MODIFICACION: 20/Abril/2009',
'AUTOR: Raúl René Ruiz',
'Se modifica para que utilize los indices existentes en produccion',
'de las tablas co_historico y co_mensual de la bdicont',
'MODIFICACION: 27/Mayo/2009',
'AUTOR: José Angel López Adams',
'Se modifica para que se contemplen los movimientos con Naturaleza C',
'Se implemento el uso de una tabla temporal, para que la consulta de los movimientos',
'se haga de esta tabla, que previamente se cargo con informacion exclusiva de movimientos de servicios',
'de las tablas co_mensual y co_historico de la BD bdicont',
'MODIFICACION: Jesús Antonio Bastidas López',
'Se modifica para que no tome en cuenta en la conciliación los convenios de DineroYa',
'Se cambia la consulta al sysmaster debido a que si la tabla no tiene registro pero existe truena el proceso',
'Fecha:29/03/2010',
'VERSION: 20100329.0907',
'FECHA: 18/11/2010',
'AUTOR: Manuel Ramos Figueroa',
'MODIFICACION: Se modifica para que consulte las tablas co_sdodias y co_histsdodias en lugar de las co_mensual y co_historico',
'AUTOR: Dulce Ramirez',
'MODIFICACION: Se modifica para que se tome los parametros de la tabla sac_convenios',
'Fecha: 14/09/2010',
'VERSION: 20100914.1721',
'AUTOR: Edgar Ivan Rochin Rocha',
'MODIFICACION: Se modifica para que se sumen los montos para la cuenta concentradora de BTS unicamente, filtrado por transacc',
'Fecha: 26/05/2011',
'VERSION: 20110526.1747',
'AUTOR: FRG',
'MODIFICACION: Se optimiza consulta para obtener las cuentas contables de la tabla bdisac:sac_convenios y no usar la bdisac:sac_param',
'Fecha: 01/02/2013';

CREATE PROCEDURE "informix".sp_dinya_obtieneparam_pba (pEmpresa CHAR(3),pNumEmpleado CHAR(9))
	RETURNING CHAR(5),CHAR(2),CHAR(2),CHAR(100),CHAR(45),CHAR(30),DATE,CHAR(2),CHAR(5),CHAR(5);

--Declaracion de variables		  
DEFINE cSqlerr              INTEGER;
DEFINE cCodRet              CHAR(5);
DEFINE cLongitudCliente     CHAR(2);
DEFINE cCodMonNac           CHAR(2);
DEFINE cPathRep             CHAR(100);
DEFINE cNombreUsuario       CHAR(45);
DEFINE cNombreEmpresa       CHAR(30);
DEFINE dFecha_Hoy           DATE;
DEFINE cSistema             CHAR(2);
DEFINE cLongitudNoControl	CHAR(5);
DEFINE cLongitudCuenta 		CHAR(5);
DEFINE isam_err			INTEGER;
DEFINE cMensaje			CHAR(200);


--SET DEBUG FILE TO "/tmp/sp_dinya_obtieneParam.out";
--TRACE ON;

--inicializacion de  variables
LET cCodRet= '00000';
LET cLongitudCliente= '';
LET cCodMonNac= '';
LET cPathRep= '';                                             
LET cNombreUsuario= '';
LET cNombreEmpresa = '';
LET dFecha_Hoy = '';
LET cSistema = '';
LET cLongitudNoControl = '';
LET cLongitudCuenta = '';
LET isam_err	= '';
LET cMensaje	= '';


BEGIN
--Crea el control de errores
	ON EXCEPTION SET cSqlerr, isam_err, cMensaje
		IF cSqlerr != 0 THEN
			LET cCodRet= cSqlerr;
			INSERT INTO sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
			VALUES (cSqlerr,isam_err,cMensaje,'sp_dinya_obtieneParam',dFecha_Hoy,CURRENT );
			RETURN cCodRet,cLongitudCliente,cCodMonNac,cPathRep,cNombreUsuario,cNombreEmpresa,dFecha_Hoy,cSistema,cLongitudNoControl,cLongitudCuenta;
		END IF;
	END EXCEPTION;

	-- Obtengo Fecha del sistemal para la Captura de Parametros
	SELECT fecha_hoy 
	INTO dFecha_Hoy
	FROM bdisac:sac_fechas
    WHERE empresa = pEmpresa;
	
	--Obtengo el valor longitud del numero de cliente		
    SELECT Trim(valor)
	INTO cLongitudCliente 
	FROM bdinteg:si_param 
	WHERE empresa = pEmpresa AND cod_param = ('7'); 

	--Obtengo el valor codigo de la moneda nacional
	SELECT Trim(valor)
	INTO cCodMonNac 
	FROM bdinteg:si_param 
	WHERE empresa = pEmpresa AND cod_param = ('15'); 

	 --Obtengo el valor path de reportes
	SELECT Trim(valor)
	INTO cPathRep
	FROM bdisac:sac_param 
	WHERE empresa = pEmpresa AND cod_param = ('74');

	--Obtengo el nombre del usuario o ejecutivo
	SELECT nombre 
	INTO cNombreUsuario
	FROM bdinteg:si_ejecut
	WHERE ejecutivo = pNumEmpleado;
	 
	-- Obtengo el nombre de la empresa
	SELECT razon_social
	INTO cNombreEmpresa
	FROM bdinteg:si_empresas 
	WHERE empresa = pEmpresa;
	 
	--Obtengo codigo del sistema
	SELECT sistema
	INTO cSistema
	FROM bdinteg:si_sistema 
	WHERE siglas = 'SI';	
	
    -- se obtiene la longitud de la cuenta cLongitudCuenta
    SELECT valor
	INTO cLongitudCuenta
    FROM bdicheq:sc_param 
    WHERE empresa = pEmpresa AND codparam = 'longcta';

    --se obtiene el la longitud del numero de control
	SELECT valor 
	INTO cLongitudNoControl
    FROM bdisac:sac_param 
    WHERE empresa = pEmpresa AND cod_param = '77';
	
	RETURN cCodRet,cLongitudCliente,cCodMonNac,cPathRep,cNombreUsuario,cNombreEmpresa,dFecha_Hoy,cSistema,cLongitudNoControl,cLongitudCuenta;
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Genera una consulta en las tablas si_param, si_ejecut,si_empresas,sc_fechas,si_sistema', 
'tomando como parametro o dato de entrada, la empresa y el numero de empleado para obtener datos del empleado',
'Solicito : Armando Mercado',	
'AUTOR: César Valdéz Figueroa',
'FECHA: Octubre 2009',
'VERSION: 20091023.0700',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_altascambioscentral_pba(cNumcategoria CHAR(2), cNumconvenio CHAR(3), cNomconvenio CHAR(40), dFechaapertura DATE, dFechaclausura DATE,
                    cStatusconvenio CHAR(1), cTipo_Referencia CHAR(1), cNomlegalempresa CHAR(40), cRfcempresa CHAR(13), cNomcomercialempresa CHAR(40),
                    cDireccionempresa CHAR(80), cEstado CHAR(2), cCiudad CHAR(3), cCodpostal CHAR(5), cNumtelcorporativo CHAR(10), cNumfaxcorporativo CHAR(10),
                    cNomcontacto1 CHAR(40), cNumtelcontacto1 CHAR(10), cNumextcontacto1 CHAR(7), cEmailcontacto1 CHAR(40), cNomcontacto2 CHAR(40),
                    cNumtelcontacto2 CHAR(10), cNumextcontacto2 CHAR(7), cEmailcontacto2 CHAR(40), cNomcontacto3 CHAR(40), cNumtelcontacto3 CHAR(10),
                    cNumextcontacto3 CHAR(7), cEmailcontacto3 CHAR(40), cNumcuentaclabe CHAR(18), cTipopago CHAR(1), iFrecuenciapago INT, cFlgarchnotificacion CHAR(1),
                    iFrecnotificacion INT, cFlgporccomtrans_conv CHAR(1), dePorc_com_trans_conv DECIMAL, cFlgporccomtotal_conv CHAR(1),
                    dePorc_com_total_conv DECIMAL, cFlgimpcomtrans_conv CHAR(1), mImp_com_trans_conv MONEY(16,2), cFlgimpcomtotal_conv CHAR(1),
                    deImp_com_total_conv MONEY(16,2), cFlgivaincluido_conv CHAR(1), deIva_Convenio INT, cFlgPorcComTrans_Cte CHAR(1), dePorc_com_trans_cte DECIMAL,
                    cFlgImpComTrans_Cte CHAR(1), mImp_com_trans_cte MONEY(16,2), cFlg_Ref1 CHAR(1), iLongitudRef1  INT, cFlgcalculodv_ref1 CHAR(1), cNomrutinadv_ref1  CHAR(30),
                    cFlg_Ref2 CHAR(1), iLongitudRef2 INT, cFlgcalculodv_ref2 CHAR(1), cNomrutinadv_ref2 CHAR(30), cFlgreporte CHAR(1), cNomreporte CHAR(30), cUsuario CHAR(8))
    -- DATOS A REGRESAR
    RETURNING CHAR(5), CHAR(2), CHAR(3);  -- Codigo de Retorno
    -- DEFINICION DE VARIABLES
    DEFINE cCodRet              CHAR(5);
    DEFINE cFechaHoy            DATE;
    DEFINE iSqlErr              INTEGER;
    DEFINE iIsamErr             INTEGER;
    DEFINE cInfoErr             CHAR(200);
    DEFINE fecha_ultimo_pago    DATE;

    --INICIALIZACION DE VARIABLES--
    LET cCodRet = "00000";
    LET iSqlErr = 0;
    LET iIsamErr = 0;
    LET cInfoErr = "";
    LET fecha_ultimo_pago = '01-01-1900';

    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                        LET cCodRet = iSqlErr;
                        ROLLBACK WORK;
                        EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_AltasCambiosCentral");
                        RETURN cCodRet, '', '';
                END IF;
        END EXCEPTION;

        BEGIN WORK;
            SELECT fecha_hoy INTO cFechaHoy FROM bdisac:sac_fechas;

            IF EXISTS (SELECT {+INDEX (bdisac:sac_convenios 103_4)} * FROM sac_convenios WHERE  numcategoria = cNumcategoria AND numconvenio = cNumconvenio) THEN
                UPDATE {+INDEX (bdisac:sac_convenios 103_4)} sac_convenios
                SET nomconvenio = cNomconvenio, fechaapertura = dFechaapertura, fechaclausura = dFechaclausura, statusconvenio = cStatusconvenio,
                    tipo_referencia = cTipo_Referencia, nomlegalempresa = cNomlegalempresa, rfcempresa = cRfcempresa, nomcomercialempresa = cNomcomercialempresa,
                    direccionempresa = cDireccionempresa, ciudad = cCiudad, estado = cEstado, codpostal = cCodpostal, numtelcorporativo = cNumtelcorporativo,
                    numfaxcorporativo = cNumfaxcorporativo, nomcontacto1 = cNomcontacto1, numtelcontacto1 = cNumtelcontacto1, numextcontacto1 = cNumextcontacto1,
                    emailcontacto1 = cEmailcontacto1, nomcontacto2 = cNomcontacto2, numtelcontacto2 = cNumtelcontacto2, numextcontacto2 = cNumextcontacto2,
                    emailcontacto2 = cEmailcontacto2, nomcontacto3 = cNomcontacto3, numtelcontacto3 = cNumtelcontacto3, numextcontacto3 = cNumextcontacto3,
                    emailcontacto3 = cEmailcontacto3, numcuentaclabe = cNumcuentaclabe, tipopago = cTipopago, frecuenciapago = iFrecuenciapago, flgarchnotificacion = cFlgarchnotificacion,
                    frecnotificacion = iFrecnotificacion, flgporccomtrans_conv =cFlgporccomtrans_conv, porc_com_trans_conv = dePorc_com_trans_conv,
                    flgporccomtotal_conv = cFlgporccomtotal_conv, porc_com_total_conv = dePorc_com_total_conv, flgimpcomtrans_conv = cFlgimpcomtrans_conv,
                    imp_com_trans_conv = mImp_com_trans_conv, flgimpcomtotal_conv = cFlgimpcomtotal_conv, imp_com_total_conv = deImp_com_total_conv,
                    flgivaincluido_conv = cFlgivaincluido_conv, iva_convenio = deIva_Convenio, flgporccomtrans_cte = cFlgPorcComTrans_cte, porc_com_trans_cte = dePorc_com_trans_cte,
                    flgimpcomtrans_cte = cFlgImpComTrans_cte, imp_com_trans_cte = mImp_com_trans_cte, flg_ref1 = cFlg_Ref1, longitud_ref1 = iLongitudRef1,
                    flgcalculodv_ref1 = cFlgcalculodv_ref1, nomrutinadv_ref1 = cNomrutinadv_ref1, flg_ref2 = cFlg_Ref2, longitud_ref2  = iLongitudRef2,
                    flgcalculodv_ref2 = cFlgcalculodv_ref2, nomrutinadv_ref2 = cNomrutinadv_ref2, flgreporte = cFlgreporte, nomreporte  = cNomreporte,
                    fecha_ultimo_pago = fecha_ultimo_pago, usuario_actualiza = cUsuario, fechaactualizacion = cFechaHoy
                WHERE numcategoria = cNumcategoria
                AND numconvenio = cNumconvenio;
            ELSE

                SELECT {+INDEX (bdisac:sac_convenios 103_7)} MAX(numconvenio)
                INTO cNumconvenio
                FROM bdisac:sac_convenios
                WHERE numcategoria = cNumcategoria;

                IF cNumConvenio IS NULL THEN
                    LET cNumConvenio = '001';
                ELSE
                    LET cNumconvenio  = LPAD(CAST(cNumconvenio AS INTEGER) + 1, 3, '0');
                END IF;

                INSERT INTO sac_convenios (numcategoria, numconvenio, nomconvenio, fechaapertura, fechaclausura, fechaalta, statusconvenio,	tipo_referencia,
	                        nomlegalempresa, rfcempresa,nomcomercialempresa, direccionempresa, ciudad, estado, codpostal, numtelcorporativo, numfaxcorporativo, nomcontacto1, 
							numtelcontacto1, numextcontacto1, emailcontacto1, nomcontacto2, numtelcontacto2, numextcontacto2, emailcontacto2, nomcontacto3, 
							numtelcontacto3, numextcontacto3, emailcontacto3, numcuentaclabe, tipopago, frecuenciapago, flgarchnotificacion, frecnotificacion, 
							flgporccomtrans_conv, porc_com_trans_conv, flgporccomtotal_conv, porc_com_total_conv, flgimpcomtrans_conv, imp_com_trans_conv,	
							flgimpcomtotal_conv, imp_com_total_conv, flgivaincluido_conv, iva_convenio, flgporccomtrans_cte, porc_com_trans_cte, 
							flgimpcomtrans_cte, imp_com_trans_cte, flg_ref1, longitud_ref1, flgcalculodv_ref1, nomrutinadv_ref1, flg_ref2, longitud_ref2, 
							flgcalculodv_ref2, nomrutinadv_ref2, flgreporte, nomreporte, fecha_ultimo_pago, usuario_alta, usuario_actualiza, fechaactualizacion) 
                    VALUES( cNumcategoria, cNumconvenio, cNomconvenio, dFechaapertura, dFechaclausura, cFechaHoy, cStatusconvenio, cTipo_Referencia, 
					    	cNomlegalempresa, cRfcempresa, cNomcomercialempresa, cDireccionempresa, cCiudad, cEstado, cCodpostal, cNumtelcorporativo, cNumfaxcorporativo, cNomcontacto1,
                            cNumtelcontacto1, cNumextcontacto1, cEmailcontacto1, cNomcontacto2, cNumtelcontacto2, cNumextcontacto2, cEmailcontacto2, cNomcontacto3,
                            cNumtelcontacto3, cNumextcontacto3, cEmailcontacto3, cNumcuentaclabe, cTipopago, iFrecuenciapago, cFlgarchnotificacion, iFrecnotificacion,
                            cFlgporccomtrans_conv, dePorc_com_trans_conv, cFlgporccomtotal_conv, dePorc_com_total_conv, cFlgimpcomtrans_conv, mImp_com_trans_conv,
                            cFlgimpcomtotal_conv, deImp_com_total_conv, cFlgivaincluido_conv, deIva_Convenio, cFlgPorcComTrans_cte, dePorc_com_trans_cte,
                            cFlgImpComTrans_cte, mImp_com_trans_cte, cFlg_Ref1, iLongitudRef1, cFlgcalculodv_ref1, cNomrutinadv_ref1, cFlg_Ref2, iLongitudRef2,
                            cFlgcalculodv_ref2, cNomrutinadv_ref2, cFlgreporte, cNomreporte, fecha_ultimo_pago, cUsuario, cUsuario, cFechaHoy);

                INSERT INTO sac_controlarchivoscobranza (numcategoria, numconvenio, nom_rutina, fecha_ultimo_archivo)
                VALUES (cNumcategoria, cNumconvenio,'', fecha_ultimo_pago);

            END IF;
        COMMIT WORK;
        RETURN cCodret, cNumcategoria, cNumconvenio;
    END;
END PROCEDURE
DOCUMENT
'AUTOR : Hector Bojorquez',
'DESCRIPCION: Se encarga de insertar o actualizar el registro de un convenio en la tabla',
'             bdisac:sac_convenios de Central',
'EJECUTADO O LLAMADO POR: alcsac.exe, cacsac.exe del sistema de administracion de convenios',
'FECHA : Agosto de 2008',
'AUTOR MODIFICACION: Dulce Ramirez',
'DESCRIPCION MODIFICACION: Se especifican los campos de la tabla sac_convenios en el insert,',
'FECHA : Septiembre de 2010',
'VERSION: 20100920',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_actualizastatusconvenio_pba(cStatus CHAR(1), cNumConvenio CHAR(3), cNumCategoria CHAR(2))

    RETURNING
    CHAR(5);

    --Definicion de Variables
    DEFINE cCodRet      CHAR(5);
    DEFINE dFecha_hoy   DATE;
    DEFINE iSqlErr      INTEGER;
    DEFINE iIsamErr     INTEGER;
    DEFINE cInfoErr     CHAR(200);

    -- Inicializa variables
    LET cCodRet = "00000";
    LET iSqlErr = 0;
    LET iIsamErr = 0;
    LET cInfoErr = "";
    LET dFecha_hoy = '01-01-1900';

    --debug flag
    --SET DEBUG FILE TO "/tmp/sc_consdatosctacentral.out";
    --TRACE ON;

    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                        LET cCodRet = iSqlErr;
                        EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_actualizastatusconvenio");
                        RETURN cCodRet;
                END IF;
        END EXCEPTION;

        SELECT fecha_hoy INTO dFecha_hoy FROM bdisac:sac_fechas;

            UPDATE sac_convenios
            SET statusconvenio = cStatus,  fechaactualizacion = dFecha_hoy, fecha_ultimo_pago = dFecha_hoy
            WHERE numcategoria = cNumCategoria
            AND numconvenio = cNumConvenio;

            IF cStatus = 'A' THEN
                UPDATE sac_controlarchivoscobranza
                SET fecha_ultimo_archivo = dFecha_hoy
                WHERE numcategoria = cNumCategoria
                AND numconvenio = cNumConvenio;
            END IF;

        RETURN cCodRet;

    END;
END PROCEDURE
DOCUMENT
'AUTOR : Jose Angel Lopez Adams',
'DESCRIPCION: Se encarga de actualizar el status de un convenio previamente dado de alta en la tabla',
'             bdisac:sac_convenios de Central',
'EJECUTADO O LLAMADO POR: bacsac.exe del sistema de administracion de convenios',
'FECHA : Agosto de 2008',
'VERSION: 20080905',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_calcula_comisiones_pba(pcategoria CHAR(2),pconvenio CHAR(3),ppago MONEY(16,2))
returning CHAR(5),MONEY(14,2), MONEY(14,2), MONEY(14,2),MONEY(14,2);
	--************************************************************--
		--**	Elaboró: Ramon Octavio Romero Mascareño		**--
		--**	Actividad: Calcula Comisiones				**--
		--**	Solicito: Mauricio León						**--
		--**	Fecha: 10/07/09								**--
	--************************************************************--
		--**	Modificó: Manuel Osuna Valencia                 				**--
		--**	Actividad: Se modifica el tipo de dato de las variables de salida	**--
		--**	Solicito: Mauricio León								**--
		--**	Fecha: 05/08/09									**--
	--************************************************************--
DEFINE sql_err					INTEGER;
DEFINE cod_err					CHAR(5);
DEFINE vimpcomconvenio			MONEY(14,2);
DEFINE vIVAimpconvenio			MONEY(14,2);
DEFINE vimpcomcte				MONEY(14,2);
DEFINE vIVAimpcomcte			MONEY(14,2);
DEFINE vFlgporccomtrans_conv	CHAR(1);
DEFINE vPorc_com_trans_conv		MONEY(16,2);
DEFINE vFlgporccomtotal_conv	CHAR(1);
DEFINE vPorc_com_total_conv		MONEY(16,2);
DEFINE vFlgimpcomtrans_conv		CHAR(1);
DEFINE vImp_com_trans_conv		MONEY(16,2);
DEFINE vFlgimpcomtotal_conv		CHAR(1);
DEFINE vImp_com_total_conv		MONEY(16,2);
DEFINE vFlgivaincluido_conv		CHAR(1);
DEFINE vIva_convenio			INTEGER;
DEFINE vFlgporccomtrans_cte		CHAR(1);
DEFINE vPorc_com_trans_cte		MONEY(16,2);
DEFINE vFlgimpcomtrans_cte		CHAR(1);
DEFINE vImp_com_trans_cte		MONEY(16,2);

LET cod_err					="000";	
LET vimpcomconvenio 		= 0;
LET vIVAimpconvenio	 		= 0;
LET vimpcomcte 				= 0;
LET vIVAimpcomcte 			= 0;
LET vFlgporccomtrans_conv	="";
LET vPorc_com_trans_conv	= 0;
LET vFlgporccomtotal_conv	="";
LET vPorc_com_total_conv	= 0;
LET vFlgimpcomtrans_conv	="";
LET vImp_com_trans_conv		= 0;
LET vFlgimpcomtotal_conv	="";
LET vImp_com_total_conv		= 0;
LET vFlgivaincluido_conv	="";
LET vIva_convenio			= 0;
LET vFlgporccomtrans_cte	="";
LET vPorc_com_trans_cte		= 0;
LET vFlgimpcomtrans_cte		="";
LET vImp_com_trans_cte		= 0;


 BEGIN
  ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_err = sql_err;
            RETURN cod_err, vimpcomconvenio, vIVAimpconvenio, vimpcomcte, vIVAimpcomcte;
      END IF ;
END EXCEPTION ;


SELECT 
    flgporccomtrans_conv,porc_com_trans_conv,   
    flgporccomtotal_conv,porc_com_total_conv,   /* comisiones por % o por monto pero total por día*/
    flgimpcomtrans_conv, imp_com_trans_conv,    
    flgimpcomtotal_conv, imp_com_total_conv,    /* comisiones por % o por monto pero total por día*/
    flgivaincluido_conv, iva_convenio,  		/* = 1 incluye IVA la comision (quitar el IVA del monto de comisión)*/
												/* = 0 calcular IVA de la comision (no se altera el monto de comisión)*/
												/* y el valor para cálculo del IVA esta en el campo iva_convenio */
    flgporccomtrans_cte, porc_com_trans_cte,    /*comisión al cliente en % por transacción*/
                                                /*se toma el monto del pago y se calcula la comisión*/
    flgimpcomtrans_cte, imp_com_trans_cte       /*comisión al cliente en monto fijo por transacción*/
INTO vFlgporccomtrans_conv,vPorc_com_trans_conv,   
    vFlgporccomtotal_conv,vPorc_com_total_conv, vFlgimpcomtrans_conv, vImp_com_trans_conv,    
    vFlgimpcomtotal_conv, vImp_com_total_conv, vFlgivaincluido_conv, vIva_convenio, 
    vFlgporccomtrans_cte, vPorc_com_trans_cte, vFlgimpcomtrans_cte, vImp_com_trans_cte  	
FROM BDISAC:sac_convenios
where numcategoria = pcategoria
and numconvenio = pconvenio;

    /*comisión del convenio*/
    IF vFlgporccomtotal_conv = 1 OR vFlgimpcomtotal_conv = 1 THEN 		/* comisiones por % o por monto pero total por día*/
        LET vimpcomconvenio = 0;                                        /* no debe grabar nada en linea (ceros)*/
    ELIF vFlgporccomtrans_conv = 1 THEN                       			/*comision es % por monto de transacción*/
        LET vimpcomconvenio = ppago * (vPorc_com_trans_conv/100);
    ELIF vFlgimpcomtrans_conv = 1 THEN                        			/*comision en monto por transacción*/ 
        LET vimpcomconvenio = vImp_com_trans_conv;
    ELSE 
        LET vimpcomconvenio = 0 ;                                      	/*no debe grabar nada en linea (ceros)*/
    END IF;
          
    /*comisíón a cliente QUE SE DEBE SUMAR AL IMPORTE DE CARGO POR PAGO ADEMAS DE REGISTRARSE EN SAC_MOVIMIENTOS*/
    IF vFlgporccomtrans_cte = 1 THEN                         			/*comisión al cliente en % por transacción*/
        LET vimpcomcte = ppago * (vPorc_com_trans_cte/100);
    ELIF vFlgimpcomtrans_cte = vImp_com_trans_cte THEN     				/*comisión al cliente en monto fijo por transacción*/
        LET vimpcomcte = vImp_com_trans_cte;
    ELSE
        LET vimpcomcte = 0;
    END IF;

    /*CALCULA IVA DE COMISIONES*/
    LET vIVAimpconvenio = vimpcomconvenio * (vIva_convenio/100);    	/*calculo iva de convenio*/
    LET vIVAimpcomcte = vimpcomcte * (vIva_convenio/100);        		/*calculo iva de cliente*/

    IF vFlgivaincluido_conv = 1 THEN     /*SE EXTRAE IVA DE LA COMISION*/      
        LET vimpcomconvenio = vimpcomconvenio - vIVAimpconvenio;
        LET vimpcomcte = vimpcomcte - vIVAimpcomcte;
    END IF;

	RETURN cod_err, vimpcomconvenio, vIVAimpconvenio, vimpcomcte, vIVAimpcomcte;
END;
END PROCEDURE;
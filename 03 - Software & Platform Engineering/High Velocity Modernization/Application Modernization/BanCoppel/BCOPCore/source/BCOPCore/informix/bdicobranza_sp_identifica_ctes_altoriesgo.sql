CREATE PROCEDURE "informix".sp_identifica_ctes_altoriesgo()
returning VARCHAR(06),
          VARCHAR(80);
-----------------------------------------------------------------------
--  EXECUTE PROCEDURE "informix".sp_identifica_ctes_altoriesgo();

DEFINE SQL_ERR					INTEGER;
DEFINE ISAM_ERR					INTEGER;
DEFINE ERROR_INFO				VARCHAR(80);
DEFINE cProceso					CHAR(4);
DEFINE P_COD_RET				VARCHAR(6);
DEFINE P_MENSAJE				VARCHAR(80);
DEFINE cCodRet  				CHAR(6);
DEFINE VP_COD_RET				VARCHAR(6);

DEFINE cEmpresa					CHAR(3);
DEFINE cMensaje  				CHAR(100);
DEFINE dFecha					DATE;
DEFINE cCampania				CHAR(10);
DEFINE cNumCredito				CHAR(20);
DEFINE cNumcte					CHAR(20);
DEFINE cNumProducto				CHAR(04);
DEFINE dFechaApertura			DATE;
DEFINE dFechaVencido			DATE;
DEFINE sNumVencidos				SMALLINT;
DEFINE cDiaCorte				CHAR(02);
DEFINE dSdoTotalLiquidar		DECIMAL(18,2);
DEFINE dSdoVencido				DECIMAL(18,2);
DEFINE dSdoInsoluto				DECIMAL(18,2);
DEFINE cExclusion           	CHAR(1);

DEFINE cMensajeRetorno			CHAR(80);
DEFINE dPagoMinimo				DECIMAL(18,2);
DEFINE dIntVdo					DECIMAL(18,2);
DEFINE dIntMoratorio			DECIMAL(18,2);
DEFINE dIvaIntVdo				DECIMAL(18,2);
DEFINE dPagosVdos				DECIMAL(18,2);
DEFINE dIvaIntMoratorio			DECIMAL(18,2);
DEFINE dIntMes					DECIMAL(18,2);
DEFINE dIvaIntMes				DECIMAL(18,2);
DEFINE dIntVig					DECIMAL(18,2);
DEFINE dIvaIntVig				DECIMAL(18,2);

DEFINE iTotalInsertadas			INTEGER;
DEFINE iTotalExcluidasPP 		INTEGER;
DEFINE iTotalCuentasVencidasPP	INTEGER;
DEFINE dFechaProceso			DATE;
DEFINE dFechaProceso2			DATE;
DEFINE dFechaProcesoAuxIni		DATE;
DEFINE dFechaProcesoAuxFin		DATE;
DEFINE dFechaUltPago			DATE;

BEGIN 
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
     LET P_COD_RET = SQL_ERR;
     LET P_MENSAJE = 'Erro en la ejecucion proceso. '||cNumCredito;
     CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, P_COD_RET, P_MENSAJE, '02')
     RETURNING P_COD_RET;
     LET P_COD_RET = SQL_ERR;
     DROP TABLE IF EXISTS ctes_altoriesgo;
     RETURN P_COD_RET,P_MENSAJE;
   END EXCEPTION;

--SET DEBUG FILE TO "sp_identifica_ctes_altoriesgo.out";
--TRACE ON;

LET cProceso            		= '2008';
LET P_COD_RET           		= '000000';
LET cCodRet           			= '000000';
LET P_MENSAJE           		= 'El proceso de IDENTIFICA CTES. ALTO RIESGO se ejecuto correctamente.';
LET VP_COD_RET					= '000000';

LET cEmpresa            		= '001';
LET cMensaje					= '';
LET dFecha						= DATE(1);
LET cCampania					= '';
LET cNumCredito					= '';
LET cNumcte						= '';
LET cNumProducto				= '';
LET dFechaApertura				= DATE(1);
LET dFechaVencido				= DATE(1);
LET sNumVencidos				= 0;
LET cDiaCorte					= '';
LET dSdoTotalLiquidar			= 0;
LET dSdoVencido					= 0;
LET dSdoInsoluto				= 0;
LET cExclusion					= '';

LET cMensajeRetorno				= '';
LET dPagoMinimo					= 0;
LET dIntVdo						= 0;
LET dIntMoratorio				= 0;
LET dIvaIntVdo					= 0;
LET dPagosVdos					= 0;
LET dIvaIntMoratorio			= 0;
LET dIntMes						= 0;
LET dIvaIntMes					= 0;
LET dIntVig						= 0;
LET dIvaIntVig					= 0;

LET iTotalInsertadas			= 0;
LET iTotalExcluidasPP			= 0;
LET	iTotalCuentasVencidasPP		= 0;
LET dFechaProceso				= DATE(1);
LET dFechaProceso2				= DATE(1);
LET dFechaProcesoAuxIni			= DATE(1);
LET dFechaProcesoAuxFin			= DATE(1);
LET dFechaUltPago				= DATE(1);

CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, P_MENSAJE, '01')
	RETURNING P_COD_RET;

IF P_COD_RET != '000000' THEN
   LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
   RETURN P_COD_RET,P_MENSAJE;
END IF;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT fecha_hoy INTO dFechaProceso FROM bdicred:"informix".sd_fechas WHERE empresa = cEmpresa;

LET dFechaProceso2 = MDY(MONTH(dFechaProceso),1,YEAR(dFechaProceso)) - 1 UNITS DAY;

TRUNCATE TABLE "informix".cb_vencidos_findemes DROP STORAGE;

SELECT 
	mae.fecha,mae.num_credito,mae.numcte,mae.num_producto,mae.fecha_apertura,(mas.mto_venc_trasp+mas.monto_vencido) as mto_venc_trasp,mas.mto_fin_ven_trasp,mas.sdo_cap_insoluto,
	mas.sdo_intereses,mas.int_tra_no_exig,mas.mto_venc_int,mas.sdo_no_exig,mas.mto_finan_vdo,mas.sdo_moratorio,mas.sdo_contab_mora,suc.iva,
	maa.dia_corte, maa.fecha_ult_pago
  FROM bdicred:"informix".sd_maecredcontcrd mae
 INNER JOIN bdicred:"informix".sd_maesdoscontcrd mas ON mas.fecha = mae.fecha AND mas.empresa = mae.empresa AND mas.num_credito = mae.num_credito
 INNER JOIN bdicred:"informix".sd_maecredanexocrd maa ON maa.empresa = mae.empresa AND maa.num_credito = mae.num_credito
 INNER JOIN bdinteg:"informix".si_sucursales suc ON suc.empresa = mae.empresa AND suc.sucursal = mae.sucursal
 WHERE mae.fecha = dFechaProceso2
   AND mae.empresa = cEmpresa
   AND mae.num_producto IN('6300','7600','7700')
   AND mae.status_cred in ('BA','BT','E1','E2','E3')
   AND (mas.monto_vencido + mas.mto_venc_trasp) > 0
INTO TEMP ctes_altoriesgo WITH NO LOG;

CREATE INDEX ind_fecha_tmp ON ctes_altoriesgo(fecha);

UPDATE STATISTICS MEDIUM FOR TABLE ctes_altoriesgo;

-- Selecciona todos los vencidos e indetifica el tipo de campana para crear el universo a trabajar en el mes
FOREACH WITH HOLD
	SELECT fecha,num_credito,numcte,num_producto,fecha_apertura,mto_venc_trasp,mto_fin_ven_trasp,sdo_cap_insoluto,
			sdo_cap_insoluto + sdo_intereses + int_tra_no_exig + mto_venc_int + sdo_no_exig + (mto_finan_vdo + sdo_moratorio + sdo_contab_mora) * (1 + iva) sdo_total_liquidar,
			dia_corte,fecha_ult_pago
	  INTO dFecha,cNumCredito,cNumcte,cNumProducto,dFechaApertura,dSdoVencido,sNumVencidos,dSdoInsoluto,dSdoTotalLiquidar,cDiaCorte,dFechaUltPago
	  FROM ctes_altoriesgo WHERE fecha = dFechaProceso2

	LET	iTotalCuentasVencidasPP	= iTotalCuentasVencidasPP + 1;

	IF sNumVencidos >= 7 THEN LET cCampania = ''; LET cCampania = 'PP_VTAC7PV';
	ELIF sNumVencidos IN (4,5,6) THEN
		IF (sNumVencidos = 4) AND (dFechaUltPago IS NULL OR dFechaUltPago = '') THEN
			-- Se calcula 5 meses atras
			LET dFechaProcesoAuxIni = MDY(MONTH(dFechaProceso),1,YEAR(dFechaProceso)) - 5 UNITS MONTH;
			LET dFechaProcesoAuxFin = (MDY(MONTH(dFechaProcesoAuxIni),1,YEAR(dFechaProcesoAuxIni)) + 1 UNITS MONTH) - 1 UNITS DAY;
			IF (dFechaApertura >= dFechaProcesoAuxIni) AND (dFechaApertura <= dFechaProcesoAuxFin) THEN
				LET cCampania = '';
				LET cCampania = 'PP_VTACCON';
			ELSE
				LET	iTotalExcluidasPP = iTotalExcluidasPP + 1;
				CONTINUE FOREACH;
			END IF;
		ELIF (sNumVencidos = 5) AND (dFechaUltPago IS NULL OR dFechaUltPago = '') THEN
			-- Se calcula 6 meses atras
			LET dFechaProcesoAuxIni = MDY(MONTH(dFechaProceso),1,YEAR(dFechaProceso)) - 6 UNITS MONTH;
			LET dFechaProcesoAuxFin = (MDY(MONTH(dFechaProcesoAuxIni),1,YEAR(dFechaProcesoAuxIni)) + 1 UNITS MONTH) - 1 UNITS DAY;
			IF (dFechaApertura >= dFechaProcesoAuxIni) AND (dFechaApertura <= dFechaProcesoAuxFin) THEN
				LET cCampania = '';
				LET cCampania = 'PP_VTACCON';
			ELSE
				LET	iTotalExcluidasPP = iTotalExcluidasPP + 1;
				CONTINUE FOREACH;
			END IF;
		ELIF (sNumVencidos = 6) AND (dFechaUltPago IS NULL OR dFechaUltPago = '') THEN
			-- Se calcula 7 meses atras
			LET dFechaProcesoAuxIni = MDY(MONTH(dFechaProceso),1,YEAR(dFechaProceso)) - 7 UNITS MONTH;
			LET dFechaProcesoAuxFin = (MDY(MONTH(dFechaProcesoAuxIni),1,YEAR(dFechaProcesoAuxIni)) + 1 UNITS MONTH) - 1 UNITS DAY;
			IF (dFechaApertura >= dFechaProcesoAuxIni) AND (dFechaApertura <= dFechaProcesoAuxFin) THEN
				LET cCampania = '';
				LET cCampania = 'PP_VTACCON';
			ELSE
				LET	iTotalExcluidasPP = iTotalExcluidasPP + 1;
				CONTINUE FOREACH;
			END IF;
		ELIF (sNumVencidos = 6) AND (dFechaUltPago IS NOT NULL OR dFechaUltPago <> '') THEN
			IF NOT EXISTS (SELECT num_credito FROM "informix".cb_vencidos_findemes WHERE fecha = dFecha AND campania = 'PP_VTACCON' AND num_credito = cNumCredito) THEN --VALIDAR QUE NO ESTE EN LA CAMPANA PP_VTACCON
				LET cCampania = '';
				LET cCampania = 'PP_VTAC6PV';
			ELSE
				LET	iTotalExcluidasPP = iTotalExcluidasPP + 1;
				CONTINUE FOREACH;
			END IF;
		ELSE
			LET	iTotalExcluidasPP = iTotalExcluidasPP + 1;
			CONTINUE FOREACH;
		END IF;
	ELIF (sNumVencidos = 3) AND (dFechaUltPago IS NULL OR dFechaUltPago = '') THEN
		-- Se calcula 4 meses atras
		LET dFechaProcesoAuxIni = MDY(MONTH(dFechaProceso),1,YEAR(dFechaProceso)) - 4 UNITS MONTH;
		LET dFechaProcesoAuxFin = (MDY(MONTH(dFechaProcesoAuxIni),1,YEAR(dFechaProcesoAuxIni)) + 1 UNITS MONTH) - 1 UNITS DAY;
		IF (dFechaApertura >= dFechaProcesoAuxIni) AND (dFechaApertura <= dFechaProcesoAuxFin) THEN
			LET cCampania = '';
			LET cCampania = 'PP_CAIDA3M';
		ELSE
			LET	iTotalExcluidasPP = iTotalExcluidasPP + 1;
			CONTINUE FOREACH;
		END IF;
	ELIF (sNumVencidos = 2) AND (dFechaUltPago IS NULL OR dFechaUltPago = '') THEN
		-- Se calcula 3 meses atras
		LET dFechaProcesoAuxIni = MDY(MONTH(dFechaProceso),1,YEAR(dFechaProceso)) - 3 UNITS MONTH;
		LET dFechaProcesoAuxFin = (MDY(MONTH(dFechaProcesoAuxIni),1,YEAR(dFechaProcesoAuxIni)) + 1 UNITS MONTH) - 1 UNITS DAY;
		IF (dFechaApertura >= dFechaProcesoAuxIni) AND (dFechaApertura <= dFechaProcesoAuxFin) THEN
			LET cCampania = '';
			LET cCampania = 'PP_CAIDA2M';
		ELSE
			LET	iTotalExcluidasPP = iTotalExcluidasPP + 1;
			CONTINUE FOREACH;
		END IF;
	ELIF sNumVencidos = 1 THEN 
		-- Se calcula 2 meses atras
		LET dFechaProcesoAuxIni = MDY(MONTH(dFechaProceso),1,YEAR(dFechaProceso)) - 2 UNITS MONTH;
		LET dFechaProcesoAuxFin = (MDY(MONTH(dFechaProcesoAuxIni),1,YEAR(dFechaProcesoAuxIni)) + 1 UNITS MONTH) - 1 UNITS DAY;
		IF dFechaApertura >= dFechaProcesoAuxIni AND dFechaApertura <= dFechaProcesoAuxFin THEN
			LET cCampania = '';
			LET cCampania = 'PP_CAIDA1M';
		ELSE
			LET	iTotalExcluidasPP = iTotalExcluidasPP + 1;
			CONTINUE FOREACH;
		END IF;
	ELSE
		LET	iTotalExcluidasPP = iTotalExcluidasPP + 1;
		CONTINUE FOREACH;
	END IF;

-- Obtiene pago minimo
	SELECT MIN(fecha_cuota) INTO dFechaVencido
	FROM bdicred:"informix".sd_amortiza_creditocrd
	WHERE empresa 		= cEmpresa
	  AND num_credito 	= cNumCredito
	  AND capital_status IN ('6','7','2');

--	EXECUTE PROCEDURE bdicred:sp_obtener_pagomin(cEmpresa,cNumCredito) 
--		INTO P_COD_RET, cMensajeRetorno,dPagoMinimo,dIntVdo,dIntMoratorio,dIvaIntVdo,dIntMes,dIvaIntMes,dIntVig,dIvaIntVig;

	BEGIN WORK;
		INSERT INTO "informix".cb_vencidos_findemes(fecha, campania, num_credito, numcte, num_producto, fecha_apertura, motivo_exclusion, fecha_vencido, num_vencidos, num_vencidos_diaant, dia_corte, pago_minimo, sdo_total_liquidar, sdo_total_liquidar_diaant, sdo_vencido, sdo_vencido_diaante, sdo_insoluto, sdo_insoluto_diaante, pagos_realizados, num_envios_camp1, num_envios_camp2, status_vencidos, status_situacion, procesar, dia_procesar) 
			VALUES(dFecha, cCampania, cNumCredito, cNumcte, cNumProducto, dFechaApertura, cExclusion, dFechaVencido, sNumVencidos, NULL, cDiaCorte, dPagoMinimo, dSdoTotalLiquidar, null, dSdoVencido, null, dSdoInsoluto, null, 0, 0, 0, null, null, 0, '');
	COMMIT WORK;

	LET	iTotalInsertadas = iTotalInsertadas + 1;

END FOREACH;

UPDATE STATISTICS MEDIUM FOR TABLE "informix".cb_vencidos_findemes;

DROP TABLE ctes_altoriesgo;

LET cMensaje = 'TOTAL Cuentas vencidas procesadas PP : ' ||iTotalCuentasVencidasPP;
CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
LET cMensaje = "";
LET cMensaje = 'Cuentas excluidas PP : ' ||iTotalExcluidasPP;
LET cMensaje = trim(cMensaje) ||'    Cuentas insertadas PP : ' ||iTotalInsertadas;
CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
LET cMensaje = "";
CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, P_MENSAJE, '03') RETURNING P_COD_RET;

IF P_COD_RET != '000000' THEN
	LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
	RETURN P_COD_RET,P_MENSAJE;
END IF;

RETURN cCodRet,P_MENSAJE;

END;
END PROCEDURE;
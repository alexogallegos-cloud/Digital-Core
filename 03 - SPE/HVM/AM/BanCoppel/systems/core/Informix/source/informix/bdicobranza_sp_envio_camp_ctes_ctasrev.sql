CREATE PROCEDURE "informix".sp_envio_camp_ctes_ctasrev(pTipoEjecucion CHAR(01), pDiaEjecucion CHAR(02))
returning VARCHAR(06),
          VARCHAR(80);

DEFINE pfechahoy				DATE;
DEFINE SQL_ERR					INTEGER;
DEFINE ISAM_ERR					INTEGER;
DEFINE ERROR_INFO				VARCHAR(80);
DEFINE cProceso					CHAR(4);
DEFINE P_COD_RET				VARCHAR(6);
DEFINE P_MENSAJE				VARCHAR(80);
DEFINE cEmpresa					CHAR(3);
DEFINE cCodRet  				CHAR(6);
DEFINE cMensaje  				CHAR(100);

DEFINE dFecha					DATE;
DEFINE cFecha_ultimo_pago		DATE;
DEFINE cCampania				CHAR(10);
DEFINE cNumCredito				CHAR(20);
DEFINE cNumcte					CHAR(20);
DEFINE cNumProducto				CHAR(04);
DEFINE dFechaApertura			DATE;
DEFINE cMotivoExclusion			CHAR(01);
DEFINE dFechaVencido			DATE;
DEFINE sNumVencidos				SMALLINT;
DEFINE sNumVencidosDiaant		SMALLINT;
DEFINE cDiaCorte				CHAR(02);
DEFINE dPagoMinimo				DECIMAL(18,2);
DEFINE dSdoTotalLiquidar		DECIMAL(18,2);
DEFINE dSdoTotalLiquidarDiaant	DECIMAL(18,2);
DEFINE dSdoVencido				DECIMAL(18,2);
DEFINE dSdoVencidoDiaante		DECIMAL(18,2);
DEFINE dSdoInsoluto				DECIMAL(18,2);
DEFINE dSdoInsolutoDiaante		DECIMAL(18,2);
DEFINE dPagosRealizados			DECIMAL(18,2);
DEFINE sNumEnviosCamp1			SMALLINT;
DEFINE sNumEnviosCamp2			SMALLINT;
DEFINE vStatusVencidos			VARCHAR(20);
DEFINE vStatusSituacion			VARCHAR(20);
DEFINE cProcesar				CHAR(01);
DEFINE cExclusion           	CHAR(1);
DEFINE dSdoVencidoAct			DECIMAL(18,2);
DEFINE dmontoultimopago			DECIMAL(18,2);

DEFINE cMensajeRetorno			CHAR(80);
DEFINE dIntVdo					DECIMAL(18,2);
DEFINE dIntMoratorio			DECIMAL(18,2);
DEFINE dIvaIntVdo				DECIMAL(18,2);
DEFINE dIntMes					DECIMAL(18,2);
DEFINE dIvaIntMes				DECIMAL(18,2);
DEFINE dIntVig					DECIMAL(18,2);
DEFINE dIvaIntVig				DECIMAL(18,2);

DEFINE iTotalaEnviar2 			INTEGER;
DEFINE iTotalCuentasVencidas	INTEGER;
DEFINE iTotalExcluidasXSitEsp	INTEGER;
DEFINE iTotalExcluidasXAclara	INTEGER;
DEFINE iTotalExcluidasXConvAct	INTEGER;
DEFINE iTotalExcluidasXSaldo	INTEGER;
DEFINE iTotalaEnviar			INTEGER;
DEFINE dFechaaProcesar			DATE;
DEFINE cStatusCred				CHAR(02);
DEFINE cstatusvencidos			VARCHAR(02);
DEFINE cStatusSituacion 		VARCHAR(02);
DEFINE dfechavencido2			DATE;
DEFINE cSql						CHAR(2000);
DEFINE vtoday					DATE;


BEGIN 
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
     LET P_COD_RET = SQL_ERR;
     LET P_MENSAJE = 'Error al ejecutar el proceso. '||cNumCredito;
     CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, P_COD_RET, P_MENSAJE, '02')
     RETURNING P_COD_RET;
     LET P_COD_RET = SQL_ERR;

     RETURN P_COD_RET,P_MENSAJE;
   END EXCEPTION;

--SET DEBUG FILE TO "sp_envio_camp_ctes_ctasrev.out";
--TRACE ON;

LET cEmpresa            	= '001';
LET cProceso            	= '2012';
LET P_COD_RET           	= '000000';
LET cCodRet           		= '000000';
LET P_MENSAJE           	= 'El proceso de ENVIO CTES. CTAS. REV. se ejecuto correctamente.';
LET cMensaje				= '';

LET dFecha					= DATE(1);
LET cFecha_ultimo_pago		= DATE(1);
LET cCampania				= '';
LET cNumCredito				= '';
LET cNumcte					= '';
LET cNumProducto			= '';
LET dFechaApertura			= DATE(1);
LET cMotivoExclusion		= '';
LET dFechaVencido			= DATE(1);
LET sNumVencidos			= 0;
LET sNumVencidosDiaant		= 0;
LET cDiaCorte				= '';
LET dPagoMinimo				= 0;
LET dSdoTotalLiquidar		= 0;
LET dSdoTotalLiquidarDiaant	= 0;
LET dSdoVencido				= 0;
LET dSdoVencidoDiaante		= 0;
LET dSdoInsoluto			= 0;
LET dSdoInsolutoDiaante		= 0;
LET dPagosRealizados		= 0;
LET sNumEnviosCamp1			= 0;
LET sNumEnviosCamp2			= 0;
LET vStatusVencidos			= '';
LET vStatusSituacion		= '';
LET cProcesar				= '';
LET cExclusion				= '';
LET dSdoVencidoAct			= 0;
LET dmontoultimopago 		= 0;

LET cMensajeRetorno			= '';
LET dIntVdo					= 0;
LET dIntMoratorio			= 0;
LET dIvaIntVdo				= 0;
LET dIntMes					= 0;
LET dIvaIntMes				= 0;
LET dIntVig					= 0;
LET dIvaIntVig				= 0;

LET iTotalaEnviar2			= 0;
LET	iTotalCuentasVencidas	= 0;
LET	iTotalExcluidasXSitEsp	= 0;
LET	iTotalExcluidasXAclara	= 0;
LET	iTotalExcluidasXConvAct	= 0;
LET	iTotalExcluidasXSaldo	= 0;
LET iTotalaEnviar			= 0;
LET dFechaaProcesar			= DATE(1);
LET cStatusCred				= '';
LET cstatusvencidos			= '';
LET cStatusSituacion		= '';
LET dfechavencido2			= DATE(1);
LET cSql					= '';
LET vtoday					= MDY(MONTH(TODAY),pDiaEjecucion,YEAR(TODAY));


CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, P_MENSAJE, '01')
    RETURNING P_COD_RET;

IF P_COD_RET != '000000' THEN
   LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
   RETURN P_COD_RET,P_MENSAJE;
END IF;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- Valida parametros de entrada
IF pTipoEjecucion IN ('0','1') AND pDiaEjecucion IN ('1','7','12','22','25','28') THEN
	LET dFechaaProcesar = MDY(MONTH(TODAY),1,YEAR(TODAY)) - 1 UNITS DAY;
ELSE 
	LET cCodRet = '000001';
	LET cMensaje = 'PARAMETROS NO VALIDOS';
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	RETURN cCodRet,cMensaje;
END IF;

-----------------------------------------------------------------
-- Gestion del primer dia
-----------------------------------------------------------------
IF pDiaEjecucion = '1' THEN
-----------------------------------------------------------------
-- Genera envio de la campana TC_VTAC7PV
-----------------------------------------------------------------
	SELECT 
		a.fecha, b.numcte, a.num_credito, a.num_producto, a.fecha_apertura, a.num_vencidos,
		a.num_vencidos_diaant, a.sdo_total_liquidar, a.sdo_total_liquidar_diaant, a.sdo_vencido, a.sdo_vencido_diaante,
		a.sdo_insoluto, a.sdo_insoluto_diaante, a.pagos_realizados, a.num_envios_camp1, a.num_envios_camp2,
		a.status_vencidos, a.status_situacion, a.motivo_exclusion, a.pago_minimo
	FROM "informix".cb_vencidos_findemes_tdc a
	INNER JOIN bdicred:"informix".sd_maecred b ON (b.empresa = cEmpresa AND b.num_credito = a.num_credito)
	WHERE a.fecha = dFechaaProcesar
	AND a.campania = 'TC_VTAC7PV'
	AND a.procesar = '1'
	INTO TEMP ctes_enviarev WITH NO LOG;

	CREATE INDEX indx_vencido_tmprev ON ctes_enviarev(fecha);
	UPDATE STATISTICS MEDIUM FOR TABLE ctes_enviarev;

	FOREACH WITH HOLD
		SELECT 
			numcte, num_credito, num_producto, fecha_apertura, num_vencidos,
			num_vencidos_diaant, sdo_total_liquidar, sdo_total_liquidar_diaant, sdo_vencido, sdo_vencido_diaante,
			sdo_insoluto, sdo_insoluto_diaante, pagos_realizados, num_envios_camp1, num_envios_camp2,
			status_vencidos, status_situacion, motivo_exclusion, pago_minimo
			INTO cNumcte, cNumCredito, cNumProducto, dFechaApertura, sNumVencidos,
			sNumVencidosDiaant, dSdoTotalLiquidar, dSdoTotalLiquidarDiaant, dSdoVencido, dSdoVencidoDiaante,
			dSdoInsoluto, dSdoInsolutoDiaante, dPagosRealizados, sNumEnviosCamp1, sNumEnviosCamp2,
			vStatusVencidos, cStatusSituacion, cMotivoExclusion, dPagoMinimo
		FROM ctes_enviarev
		WHERE fecha = dFechaaProcesar

		LET	iTotalCuentasVencidas	= iTotalCuentasVencidas + 1;

		CALL bdimnsj:"informix".sp_registra_evento(2,'COBRA_SMS','TC_VTAC7PV',cNumcte,cNumCredito,'',2, 
													'','','','','',
													dPagoMinimo,sNumVencidosDiaant,'','','',
													'','',0,0,0,0,0,'','') RETURNING P_COD_RET;

		IF P_COD_RET != '00000' THEN
			LET P_MENSAJE  = 'Error en el llamado al sp_registra_evento. '||cNumCredito;
			RETURN P_COD_RET,P_MENSAJE;
		END IF;

		BEGIN WORK;
			UPDATE "informix".cb_vencidos_findemes_tdc
			SET numcte = cNumcte,
				num_envios_camp1 = sNumEnviosCamp1 + 1,
				procesar = '0'
			WHERE fecha = dFechaaProcesar
			AND campania = 'TC_VTAC7PV'
			AND num_credito = cNumCredito;
		COMMIT WORK;

/*		CALL "informix".sp_inserta_info_rep_envios (cEmpresa,'SMS',26, cNumCredito, cNumcte, cNumProducto, TODAY, '', cStatusSituacion,cMotivoExclusion,dPagoMinimo) returning P_COD_RET;

		IF P_COD_RET != '000000' THEN
			LET P_MENSAJE  = 'Error en el llamado al sp_inserta_info_rep_envios. '||cNumCredito;
			RETURN P_COD_RET,P_MENSAJE;
		END IF;*/

		LET iTotalaEnviar = iTotalaEnviar + 1;

		LET cNumcte, cNumCredito, cNumProducto, dFechaApertura, sNumVencidos = '', '', '', DATE(1), 0;
		LET sNumVencidosDiaant, dSdoTotalLiquidar, dSdoTotalLiquidarDiaant, dSdoVencido, dSdoVencidoDiaante = 0, 0, 0, 0, 0;
		LET dSdoInsoluto, dSdoInsolutoDiaante, dPagosRealizados, sNumEnviosCamp1, sNumEnviosCamp2 = 0, 0, 0, 0, 0;
		LET vStatusVencidos, cStatusSituacion, cMotivoExclusion, dPagoMinimo = '', '', '', 0;
	END FOREACH;

	LET cSql ='if [ -f /respaldos/TC_VENTA_CART_7PV_'||TO_CHAR(vtoday,'01%m%Y')||'.txt ]; then nice nice -n -30 rm -f /respaldos/TC_VENTA_CART_7PV_'||TO_CHAR(vtoday,'01%m%Y')||'.txt; fi';
	System cSql;

	--- TXT
	LET cSql = '';
	LET cSql = 'echo "UNLOAD TO /respaldos/TC_VENTA_CART_7PV_' ||TO_CHAR(vtoday,'01%m%Y')||'.txt'|| ' DELIMITER ' || '''|'''  || ' " >> /respaldos/tc_venta_cart_7pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "SELECT numcte, num_credito, num_producto, fecha_apertura, num_vencidos," >> /respaldos/tc_venta_cart_7pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "num_vencidos_diaant, sdo_total_liquidar, sdo_total_liquidar_diaant, sdo_vencido, sdo_vencido_diaante," >> /respaldos/tc_venta_cart_7pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "sdo_insoluto, sdo_insoluto_diaante, pagos_realizados, num_envios_camp1, num_envios_camp2," >> /respaldos/tc_venta_cart_7pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "status_vencidos, status_situacion, motivo_exclusion" >> /respaldos/tc_venta_cart_7pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "FROM "informix".cb_vencidos_findemes_tdc" >> /respaldos/tc_venta_cart_7pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "WHERE fecha = MDY(' ||MONTH(dFechaaProcesar)|| ',' ||DAY(dFechaaProcesar)|| ',' ||YEAR(dFechaaProcesar)|| ')" >> /respaldos/tc_venta_cart_7pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "AND campania = ' ||"'TC_VTAC7PV'"|| '" >> /respaldos/tc_venta_cart_7pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "AND dia_procesar = ' ||''''||TRIM(pDiaEjecucion)||''''|| '" >> /respaldos/tc_venta_cart_7pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql='chmod 777 /respaldos/tc_venta_cart_7pv.sql';
	System cSql;		

	LET cSql = '';
	LET cSql = 'dbaccess bdicobranza /respaldos/tc_venta_cart_7pv.sql';
	SYSTEM cSql;		

	LET cSql = '';
	LET cSql ='rm /respaldos/tc_venta_cart_7pv.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql='chmod 777 /respaldos/TC_VENTA_CART_7PV_' ||TO_CHAR(vtoday,'01%m%Y')||'.txt';
	System cSql;

	--Genera cifras de control
	LET cMensaje = ' ------- Cifras de Control campana TC_VTAC7PV ------- ';
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = '';
	LET cMensaje = 'TOTAL Cuentas vencidas procesadas : ' ||iTotalCuentasVencidas;
	LET cMensaje = trim(cMensaje) ||'    Cuentas a enviar : ' ||iTotalaEnviar;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	--Genera cifras de control

	LET cMensaje = '';
	LET iTotalaEnviar			= 0;
	LET	iTotalCuentasVencidas	= 0;
	LET cCampania = '';

	DROP TABLE ctes_enviarev;
-----------------------------------------------------------------
-- Genera campana TC_VTACCON
-----------------------------------------------------------------
	SELECT 
		a.fecha, b.numcte, a.num_credito, a.num_producto, a.fecha_apertura, a.num_vencidos,
		a.num_vencidos_diaant, a.sdo_total_liquidar, a.sdo_total_liquidar_diaant, a.sdo_vencido, a.sdo_vencido_diaante,
		a.sdo_insoluto, a.sdo_insoluto_diaante, a.pagos_realizados, a.num_envios_camp1, a.num_envios_camp2,
		a.status_vencidos, a.status_situacion, a.motivo_exclusion, a.pago_minimo
	FROM "informix".cb_vencidos_findemes_tdc a
	INNER JOIN bdicred:"informix".sd_maecred b ON (b.empresa = cEmpresa AND b.num_credito = a.num_credito)
	WHERE a.fecha = dFechaaProcesar
	AND a.campania = 'TC_VTACCON'
	AND a.procesar = '1'
	INTO TEMP ctes_enviarev WITH NO LOG;

	CREATE INDEX indx_vencido_tmprev ON ctes_enviarev(fecha);
	UPDATE STATISTICS MEDIUM FOR TABLE ctes_enviarev;

	FOREACH WITH HOLD
		SELECT 
			numcte, num_credito, num_producto, fecha_apertura, num_vencidos,
			num_vencidos_diaant, sdo_total_liquidar, sdo_total_liquidar_diaant, sdo_vencido, sdo_vencido_diaante,
			sdo_insoluto, sdo_insoluto_diaante, pagos_realizados, num_envios_camp1, num_envios_camp2,
			status_vencidos, status_situacion, motivo_exclusion, pago_minimo
			INTO cNumcte, cNumCredito, cNumProducto, dFechaApertura, sNumVencidos,
			sNumVencidosDiaant, dSdoTotalLiquidar, dSdoTotalLiquidarDiaant, dSdoVencido, dSdoVencidoDiaante,
			dSdoInsoluto, dSdoInsolutoDiaante, dPagosRealizados, sNumEnviosCamp1, sNumEnviosCamp2,
			vStatusVencidos, cStatusSituacion, cMotivoExclusion, dPagoMinimo
		FROM ctes_enviarev
		WHERE fecha = dFechaaProcesar

		LET	iTotalCuentasVencidas	= iTotalCuentasVencidas + 1;

		CALL bdimnsj:"informix".sp_registra_evento(2,'COBRA_SMS','TC_VTACCON',cNumcte,cNumCredito,'',2, 
													'','','','','',
													dPagoMinimo,sNumVencidosDiaant,'','','',
													'','',0,0,0,0,0,'','') RETURNING P_COD_RET;

		IF P_COD_RET != '00000' THEN
			LET P_MENSAJE  = 'Error en el llamado al sp_registra_evento. '||cNumCredito;
			RETURN P_COD_RET,P_MENSAJE;
		END IF;

		BEGIN WORK;
			UPDATE "informix".cb_vencidos_findemes_tdc
			SET numcte = cNumcte,
				num_envios_camp1 = sNumEnviosCamp1 + 1,
				procesar = '0'
			WHERE fecha = dFechaaProcesar
			AND campania = 'TC_VTACCON'
			AND num_credito = cNumCredito;
		COMMIT WORK;

/*		CALL "informix".sp_inserta_info_rep_envios (cEmpresa,'SMS',27, cNumCredito, cNumcte, cNumProducto, TODAY, '', cStatusSituacion,cMotivoExclusion,dPagoMinimo) returning P_COD_RET;

		IF P_COD_RET != '000000' THEN
			LET P_MENSAJE  = 'Error en el llamado al sp_inserta_info_rep_envios. '||cNumCredito;
			RETURN P_COD_RET,P_MENSAJE;
		END IF;*/

		LET iTotalaEnviar = iTotalaEnviar + 1;

		LET cNumcte, cNumCredito, cNumProducto, dFechaApertura, sNumVencidos = '', '', '', DATE(1), 0;
		LET sNumVencidosDiaant, dSdoTotalLiquidar, dSdoTotalLiquidarDiaant, dSdoVencido, dSdoVencidoDiaante = 0, 0, 0, 0, 0;
		LET dSdoInsoluto, dSdoInsolutoDiaante, dPagosRealizados, sNumEnviosCamp1, sNumEnviosCamp2 = 0, 0, 0, 0, 0;
		LET vStatusVencidos, cStatusSituacion, cMotivoExclusion, dPagoMinimo = '', '', '', 0;

	END FOREACH;

	LET cSql = '';
	LET cSql ='if [ -f /respaldos/TC_VTA_CART_CONFLICTO_'||TO_CHAR(vtoday,'01%m%Y')||'.txt ]; then nice nice -n -30 rm -f /respaldos/TC_VTA_CART_CONFLICTO_'||TO_CHAR(vtoday,'01%m%Y')||'.txt; fi';
	System cSql;

	--- TXT
	LET cSql = '';
	LET cSql = 'echo "UNLOAD TO /respaldos/TC_VTA_CART_CONFLICTO_' ||TO_CHAR(vtoday,'01%m%Y')||'.txt'|| ' DELIMITER ' || '''|'''  || ' " >> /respaldos/tc_vta_cart_conflicto.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "SELECT numcte, num_credito, num_producto, fecha_apertura, num_vencidos," >> /respaldos/tc_vta_cart_conflicto.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "num_vencidos_diaant, sdo_total_liquidar, sdo_total_liquidar_diaant, sdo_vencido, sdo_vencido_diaante," >> /respaldos/tc_vta_cart_conflicto.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "sdo_insoluto, sdo_insoluto_diaante, pagos_realizados, num_envios_camp1, num_envios_camp2," >> /respaldos/tc_vta_cart_conflicto.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "status_vencidos, status_situacion, motivo_exclusion" >> /respaldos/tc_vta_cart_conflicto.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "FROM "informix".cb_vencidos_findemes_tdc" >> /respaldos/tc_vta_cart_conflicto.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "WHERE fecha = MDY(' ||MONTH(dFechaaProcesar)|| ',' ||DAY(dFechaaProcesar)|| ',' ||YEAR(dFechaaProcesar)|| ')" >> /respaldos/tc_vta_cart_conflicto.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "AND campania = ' ||"'TC_VTACCON'"|| '" >> /respaldos/tc_vta_cart_conflicto.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "AND dia_procesar = ' ||''''||TRIM(pDiaEjecucion)||''''|| '" >> /respaldos/tc_vta_cart_conflicto.sql';
	System cSql;

	LET cSql = '';
	LET cSql='chmod 777 /respaldos/tc_vta_cart_conflicto.sql';
	System cSql;		

	LET cSql = '';
	LET cSql = 'dbaccess bdicobranza /respaldos/tc_vta_cart_conflicto.sql';
	SYSTEM cSql;		

	LET cSql = '';
	LET cSql ='rm /respaldos/tc_vta_cart_conflicto.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql='chmod 777 /respaldos/TC_VTA_CART_CONFLICTO_' ||TO_CHAR(vtoday,'01%m%Y')||'.txt';
	System cSql;

	--Genera cifras de control
	LET cMensaje = ' ------- Cifras de Control campana TC_VTACCON ------- ';
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

	LET cMensaje = '';
	LET cMensaje = 'TOTAL Cuentas vencidas procesadas : ' ||iTotalCuentasVencidas;
	LET cMensaje = trim(cMensaje) ||'    Cuentas a enviar : ' ||iTotalaEnviar;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	--Genera cifras de control

	LET cMensaje = '';
	LET iTotalaEnviar			= 0;
	LET	iTotalCuentasVencidas	= 0;
	LET cCampania = '';

	DROP TABLE ctes_enviarev;
END IF;

-----------------------------------------------------------------
-- Gestion de los dias restantes
-----------------------------------------------------------------
IF pDiaEjecucion IN ('7','12','22','25') THEN
	IF pDiaEjecucion = 25 THEN
		LET cCampania = 'TC_VTC7PVL';
	ELSE
		LET cCampania = 'TC_VTAC7PV';
	END IF;

	SELECT 
		a.fecha, b.numcte, a.num_credito, a.num_producto, a.fecha_apertura, a.num_vencidos,
		a.num_vencidos_diaant, a.sdo_total_liquidar, a.sdo_total_liquidar_diaant, a.sdo_vencido, a.sdo_vencido_diaante,
		a.sdo_insoluto, a.sdo_insoluto_diaante, a.pagos_realizados, a.num_envios_camp1, a.num_envios_camp2,
		a.status_vencidos, a.status_situacion, a.motivo_exclusion, a.pago_minimo
	FROM "informix".cb_vencidos_findemes_tdc a
	INNER JOIN bdicred:"informix".sd_maecred b ON (b.empresa = cEmpresa AND b.num_credito = a.num_credito)
	WHERE a.fecha = dFechaaProcesar
	AND a.campania = 'TC_VTAC7PV'
	AND a.procesar = '1'
	INTO TEMP ctes_enviarev WITH NO LOG;

	CREATE INDEX indx_vencido_tmprev ON ctes_enviarev(fecha);
	UPDATE STATISTICS MEDIUM FOR TABLE ctes_enviarev;

-----------------------------------------------------------------
-- Genera envio de la campana TC_VTAC7PV
-----------------------------------------------------------------

	FOREACH WITH HOLD
		SELECT 
			numcte, num_credito, num_producto, fecha_apertura, num_vencidos,
			num_vencidos_diaant, sdo_total_liquidar, sdo_total_liquidar_diaant, sdo_vencido, sdo_vencido_diaante,
			sdo_insoluto, sdo_insoluto_diaante, pagos_realizados, num_envios_camp1, num_envios_camp2,
			status_vencidos, status_situacion, motivo_exclusion, pago_minimo
			INTO cNumcte, cNumCredito, cNumProducto, dFechaApertura, sNumVencidos,
			sNumVencidosDiaant, dSdoTotalLiquidar, dSdoTotalLiquidarDiaant, dSdoVencido, dSdoVencidoDiaante,
			dSdoInsoluto, dSdoInsolutoDiaante, dPagosRealizados, sNumEnviosCamp1, sNumEnviosCamp2,
			vStatusVencidos, cStatusSituacion, cMotivoExclusion, dPagoMinimo
		FROM ctes_enviarev
		WHERE fecha = dFechaaProcesar

		LET	iTotalCuentasVencidas	= iTotalCuentasVencidas + 1;

		CALL bdimnsj:"informix".sp_registra_evento(2,'COBRA_SMS',TRIM(cCampania),cNumcte,cNumCredito,'',2, 
													'','','','','',
													dPagoMinimo,sNumVencidosDiaant,'','','',
													'','',0,0,0,0,0,'','') RETURNING P_COD_RET;

		IF P_COD_RET != '00000' THEN
			LET P_MENSAJE  = 'Error en el llamado al sp_registra_evento. '||cNumCredito;
			RETURN P_COD_RET,P_MENSAJE;
		END IF;

		IF pDiaEjecucion = 25 THEN
			BEGIN WORK;
				UPDATE "informix".cb_vencidos_findemes_tdc
				SET numcte = cNumcte,
					num_envios_camp2 = sNumEnviosCamp2 + 1,
					procesar = '0'
				WHERE fecha = dFechaaProcesar
				AND campania = 'TC_VTAC7PV'
				AND num_credito = cNumCredito;
			COMMIT WORK;
		ELSE
			BEGIN WORK;
				UPDATE "informix".cb_vencidos_findemes_tdc
				SET numcte = cNumcte,
					num_envios_camp1 = sNumEnviosCamp1 + 1,
					procesar = '0'
				WHERE fecha = dFechaaProcesar
				AND campania = 'TC_VTAC7PV'
				AND num_credito = cNumCredito;
			COMMIT WORK;
		END IF;

/*		CALL "informix".sp_inserta_info_rep_envios (cEmpresa,'SMS',26, cNumCredito, cNumcte, cNumProducto, TODAY, '', cStatusSituacion,cMotivoExclusion,dPagoMinimo) returning P_COD_RET;

		IF P_COD_RET != '000000' THEN
			LET P_MENSAJE  = 'Error en el llamado al sp_inserta_info_rep_envios. '||cNumCredito;
			RETURN P_COD_RET,P_MENSAJE;
		END IF;*/

		LET iTotalaEnviar = iTotalaEnviar + 1;
		
		LET cNumcte, cNumCredito, cNumProducto, dFechaApertura, sNumVencidos = '', '', '', DATE(1), 0;
		LET sNumVencidosDiaant, dSdoTotalLiquidar, dSdoTotalLiquidarDiaant, dSdoVencido, dSdoVencidoDiaante = 0, 0, 0, 0, 0;
		LET dSdoInsoluto, dSdoInsolutoDiaante, dPagosRealizados, sNumEnviosCamp1, sNumEnviosCamp2 = 0, 0, 0, 0, 0;
		LET vStatusVencidos, cStatusSituacion, cMotivoExclusion, dPagoMinimo = '', '', '', 0;

	END FOREACH;

	LET cSql = '';
	LET cSql ='if [ -f /respaldos/TC_VENTA_CART_7PV_'||TO_CHAR(vtoday,'%d%m%Y')||'.txt ]; then nice nice -n -30 rm -f /respaldos/TC_VENTA_CART_7PV_'||TO_CHAR(vtoday,'%d%m%Y')||'.txt; fi';
	System cSql;

	--- TXT
	LET cSql = '';
	LET cSql = 'echo "UNLOAD TO /respaldos/TC_VENTA_CART_7PV_'||TO_CHAR(vtoday,'%d%m%Y')||'.txt'|| ' DELIMITER ' || '''|'''  || ' " >> /respaldos/tc_venta_cart_7pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "SELECT numcte, num_credito, num_producto, fecha_apertura, num_vencidos," >> /respaldos/tc_venta_cart_7pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "num_vencidos_diaant, sdo_total_liquidar, sdo_total_liquidar_diaant, sdo_vencido, sdo_vencido_diaante," >> /respaldos/tc_venta_cart_7pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "sdo_insoluto, sdo_insoluto_diaante, pagos_realizados, num_envios_camp1, num_envios_camp2," >> /respaldos/tc_venta_cart_7pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "status_vencidos, status_situacion, motivo_exclusion" >> /respaldos/tc_venta_cart_7pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "FROM "informix".cb_vencidos_findemes_tdc" >> /respaldos/tc_venta_cart_7pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "WHERE fecha = MDY(' ||MONTH(dFechaaProcesar)|| ',' ||DAY(dFechaaProcesar)|| ',' ||YEAR(dFechaaProcesar)|| ')" >> /respaldos/tc_venta_cart_7pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "AND campania = ' ||"'TC_VTAC7PV'"|| '" >> /respaldos/tc_venta_cart_7pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "AND dia_procesar = ' ||''''||TRIM(pDiaEjecucion)||''''|| '" >> /respaldos/tc_venta_cart_7pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql='chmod 777 /respaldos/tc_venta_cart_7pv.sql';
	System cSql;		

	LET cSql = '';
	LET cSql = 'dbaccess bdicobranza /respaldos/tc_venta_cart_7pv.sql';
	SYSTEM cSql;		

	LET cSql = '';
	LET cSql ='rm /respaldos/tc_venta_cart_7pv.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql='chmod 777 /respaldos/TC_VENTA_CART_7PV_'||TO_CHAR(vtoday,'%d%m%Y')|| '.txt';
	System cSql;

	--Genera cifras de control
	LET cMensaje = ' ------- Cifras de Control campana '||TRIM(cCampania)||' ------- ';
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

	LET cMensaje = '';
	LET cMensaje = 'TOTAL Cuentas vencidas procesadas : ' ||iTotalCuentasVencidas;
	LET cMensaje = trim(cMensaje) ||'    Cuentas a enviar : ' ||iTotalaEnviar;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	--Genera cifras de control

	LET cMensaje = '';
	LET iTotalaEnviar			= 0;
	LET	iTotalCuentasVencidas	= 0;
	LET cCampania = '';

	DROP TABLE ctes_enviarev;
-----------------------------------------------------------------
-- Genera campana TC_VTACCON
-----------------------------------------------------------------
	IF pDiaEjecucion = 25 THEN
		LET cCampania = 'TC_VTACCUL';
	ELSE
		LET cCampania = 'TC_VTACCON';
	END IF;
	
	SELECT 
		a.fecha, b.numcte, a.num_credito, a.num_producto, a.fecha_apertura, a.num_vencidos,
		a.num_vencidos_diaant, a.sdo_total_liquidar, a.sdo_total_liquidar_diaant, a.sdo_vencido, a.sdo_vencido_diaante,
		a.sdo_insoluto, a.sdo_insoluto_diaante, a.pagos_realizados, a.num_envios_camp1, a.num_envios_camp2,
		a.status_vencidos, a.status_situacion, a.motivo_exclusion, a.pago_minimo
	FROM "informix".cb_vencidos_findemes_tdc a
	INNER JOIN bdicred:"informix".sd_maecred b ON (b.empresa = cEmpresa AND b.num_credito = a.num_credito)
	WHERE a.fecha = dFechaaProcesar
	AND a.campania = 'TC_VTACCON'
	AND a.procesar = '1'
	INTO TEMP ctes_enviarev WITH NO LOG;

	CREATE INDEX indx_vencido_tmprev ON ctes_enviarev(fecha);
	UPDATE STATISTICS MEDIUM FOR TABLE ctes_enviarev;

	FOREACH WITH HOLD
		SELECT 
			numcte, num_credito, num_producto, fecha_apertura, num_vencidos,
			num_vencidos_diaant, sdo_total_liquidar, sdo_total_liquidar_diaant, sdo_vencido, sdo_vencido_diaante,
			sdo_insoluto, sdo_insoluto_diaante, pagos_realizados, num_envios_camp1, num_envios_camp2,
			status_vencidos, status_situacion, motivo_exclusion, pago_minimo
			INTO cNumcte, cNumCredito, cNumProducto, dFechaApertura, sNumVencidos,
			sNumVencidosDiaant, dSdoTotalLiquidar, dSdoTotalLiquidarDiaant, dSdoVencido, dSdoVencidoDiaante,
			dSdoInsoluto, dSdoInsolutoDiaante, dPagosRealizados, sNumEnviosCamp1, sNumEnviosCamp2,
			vStatusVencidos, cStatusSituacion, cMotivoExclusion, dPagoMinimo
		FROM ctes_enviarev
		WHERE fecha = dFechaaProcesar

		LET	iTotalCuentasVencidas	= iTotalCuentasVencidas + 1;

		CALL bdimnsj:"informix".sp_registra_evento(2,'COBRA_SMS',TRIM(cCampania),cNumcte,cNumCredito,'',2, 
													'','','','','',
													dPagoMinimo,sNumVencidosDiaant,'','','',
													'','',0,0,0,0,0,'','') RETURNING P_COD_RET;

		IF P_COD_RET != '00000' THEN
			LET P_MENSAJE  = 'Error en el llamado al sp_registra_evento. '||cNumCredito;
			RETURN P_COD_RET,P_MENSAJE;
		END IF;

		IF pDiaEjecucion = 25 THEN
			BEGIN WORK;
				UPDATE "informix".cb_vencidos_findemes_tdc
				SET numcte = cNumcte,
					num_envios_camp2 = sNumEnviosCamp2 + 1,
					procesar = '0'
				WHERE fecha = dFechaaProcesar
				AND campania = 'TC_VTACCON'
				AND num_credito = cNumCredito;
			COMMIT WORK;
		ELSE
			BEGIN WORK;
				UPDATE "informix".cb_vencidos_findemes_tdc
				SET numcte = cNumcte,
					num_envios_camp1 = sNumEnviosCamp1 + 1,
					procesar = '0'
				WHERE fecha = dFechaaProcesar
				AND campania = 'TC_VTACCON'
				AND num_credito = cNumCredito;
			COMMIT WORK;
		END IF;

/*		CALL "informix".sp_inserta_info_rep_envios (cEmpresa,'SMS',27, cNumCredito, cNumcte, cNumProducto, TODAY, '', cStatusSituacion,cMotivoExclusion,dPagoMinimo) returning P_COD_RET;

		IF P_COD_RET != '000000' THEN
			LET P_MENSAJE  = 'Error en el llamado al sp_inserta_info_rep_envios. '||cNumCredito;
			RETURN P_COD_RET,P_MENSAJE;
		END IF;*/

		LET iTotalaEnviar = iTotalaEnviar + 1;

		LET cNumcte, cNumCredito, cNumProducto, dFechaApertura, sNumVencidos = '', '', '', DATE(1), 0;
		LET sNumVencidosDiaant, dSdoTotalLiquidar, dSdoTotalLiquidarDiaant, dSdoVencido, dSdoVencidoDiaante = 0, 0, 0, 0, 0;
		LET dSdoInsoluto, dSdoInsolutoDiaante, dPagosRealizados, sNumEnviosCamp1, sNumEnviosCamp2 = 0, 0, 0, 0, 0;
		LET vStatusVencidos, cStatusSituacion, cMotivoExclusion, dPagoMinimo = '', '', '', 0;

	END FOREACH;

	LET cSql = '';
	LET cSql ='if [ -f /respaldos/TC_VTA_CART_CONFLICTO_'||TO_CHAR(vtoday,'%d%m%Y')||'.txt ]; then nice nice -n -30 rm -f /respaldos/TC_VTA_CART_CONFLICTO_'||TO_CHAR(vtoday,'%d%m%Y')||'.txt; fi';
	System cSql;

	--- TXT
	LET cSql = '';
	LET cSql = 'echo "UNLOAD TO /respaldos/TC_VTA_CART_CONFLICTO_'||TO_CHAR(vtoday,'%d%m%Y')||'.txt'|| ' DELIMITER ' || '''|'''  || ' " >> /respaldos/tc_vta_cart_conflicto.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "SELECT numcte, num_credito, num_producto, fecha_apertura, num_vencidos," >> /respaldos/tc_vta_cart_conflicto.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "num_vencidos_diaant, sdo_total_liquidar, sdo_total_liquidar_diaant, sdo_vencido, sdo_vencido_diaante," >> /respaldos/tc_vta_cart_conflicto.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "sdo_insoluto, sdo_insoluto_diaante, pagos_realizados, num_envios_camp1, num_envios_camp2," >> /respaldos/tc_vta_cart_conflicto.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "status_vencidos, status_situacion, motivo_exclusion" >> /respaldos/tc_vta_cart_conflicto.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "FROM "informix".cb_vencidos_findemes_tdc" >> /respaldos/tc_vta_cart_conflicto.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "WHERE fecha = MDY(' ||MONTH(dFechaaProcesar)|| ',' ||DAY(dFechaaProcesar)|| ',' ||YEAR(dFechaaProcesar)|| ')" >> /respaldos/tc_vta_cart_conflicto.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "AND campania = ' ||"'TC_VTACCON'"|| '" >> /respaldos/tc_vta_cart_conflicto.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "AND dia_procesar = ' ||''''||TRIM(pDiaEjecucion)||''''|| '" >> /respaldos/tc_vta_cart_conflicto.sql';
	System cSql;

	LET cSql = '';
	LET cSql='chmod 777 /respaldos/tc_vta_cart_conflicto.sql';
	System cSql;		

	LET cSql = '';
	LET cSql = 'dbaccess bdicobranza /respaldos/tc_vta_cart_conflicto.sql';
	SYSTEM cSql;		

	LET cSql = '';
	LET cSql ='rm /respaldos/tc_vta_cart_conflicto.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql='chmod 777 /respaldos/TC_VTA_CART_CONFLICTO_'||TO_CHAR(vtoday,'%d%m%Y')||'.txt';
	System cSql;

	--Genera cifras de control
	LET cMensaje = ' ------- Cifras de Control campana '||TRIM(cCampania)||' ------- ';
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

	LET cMensaje = '';
	LET cMensaje = 'TOTAL Cuentas vencidas procesadas : ' ||iTotalCuentasVencidas;
	LET cMensaje = trim(cMensaje) ||'    Cuentas a enviar : ' ||iTotalaEnviar;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	--Genera cifras de control

	LET cMensaje = '';
	LET iTotalaEnviar			= 0;
	LET	iTotalCuentasVencidas	= 0;
	LET cCampania = '';

	DROP TABLE ctes_enviarev;
END IF;

-----------------------------------------------------------------
-- Gestion del primer dia
-----------------------------------------------------------------
IF pDiaEjecucion = '1' THEN
-----------------------------------------------------------------
-- Genera campana TC_VTAC6PV
-----------------------------------------------------------------
	SELECT 
		a.fecha, b.numcte, a.num_credito, a.num_producto, a.fecha_apertura, a.num_vencidos,
		a.num_vencidos_diaant, a.sdo_total_liquidar, a.sdo_total_liquidar_diaant, a.sdo_vencido, a.sdo_vencido_diaante,
		a.sdo_insoluto, a.sdo_insoluto_diaante, a.pagos_realizados, a.num_envios_camp1, a.num_envios_camp2,
		a.status_vencidos, a.status_situacion, a.motivo_exclusion, a.pago_minimo
	FROM "informix".cb_vencidos_findemes_tdc a
	INNER JOIN bdicred:"informix".sd_maecred b ON (b.empresa = cEmpresa AND b.num_credito = a.num_credito)
	WHERE a.fecha = dFechaaProcesar
	AND a.campania = 'TC_VTAC6PV'
	AND a.procesar = '1'
	INTO TEMP ctes_enviarev WITH NO LOG;

	CREATE INDEX indx_vencido_tmprev ON ctes_enviarev(fecha);
	UPDATE STATISTICS MEDIUM FOR TABLE ctes_enviarev;

	FOREACH WITH HOLD
		SELECT 
			numcte, num_credito, num_producto, fecha_apertura, num_vencidos,
			num_vencidos_diaant, sdo_total_liquidar, sdo_total_liquidar_diaant, sdo_vencido, sdo_vencido_diaante,
			sdo_insoluto, sdo_insoluto_diaante, pagos_realizados, num_envios_camp1, num_envios_camp2,
			status_vencidos, status_situacion, motivo_exclusion, pago_minimo
			INTO cNumcte, cNumCredito, cNumProducto, dFechaApertura, sNumVencidos,
			sNumVencidosDiaant, dSdoTotalLiquidar, dSdoTotalLiquidarDiaant, dSdoVencido, dSdoVencidoDiaante,
			dSdoInsoluto, dSdoInsolutoDiaante, dPagosRealizados, sNumEnviosCamp1, sNumEnviosCamp2,
			vStatusVencidos, cStatusSituacion, cMotivoExclusion, dPagoMinimo
		FROM ctes_enviarev
		WHERE fecha = dFechaaProcesar

		LET	iTotalCuentasVencidas	= iTotalCuentasVencidas + 1;

		CALL bdimnsj:"informix".sp_registra_evento(2,'COBRA_SMS','TC_VTAC6PV',cNumcte,cNumCredito,'',2, 
													'','','','','',
													dPagoMinimo,sNumVencidosDiaant,'','','',
													'','',0,0,0,0,0,'','') RETURNING P_COD_RET;

		IF P_COD_RET != '00000' THEN
			LET P_MENSAJE  = 'Error en el llamado al sp_registra_evento. '||cNumCredito;
			RETURN P_COD_RET,P_MENSAJE;
		END IF;

		BEGIN WORK;
			UPDATE "informix".cb_vencidos_findemes_tdc
			SET numcte = cNumcte,
				num_envios_camp1 = sNumEnviosCamp1 + 1,
				procesar = '0'
			WHERE fecha = dFechaaProcesar
			AND campania = 'TC_VTAC6PV'
			AND num_credito = cNumCredito;
		COMMIT WORK;

/*		CALL "informix".sp_inserta_info_rep_envios (cEmpresa,'SMS',30, cNumCredito, cNumcte, cNumProducto, TODAY, '', cStatusSituacion,cMotivoExclusion,dPagoMinimo) returning P_COD_RET;

		IF P_COD_RET != '000000' THEN
			LET P_MENSAJE  = 'Error en el llamado al sp_inserta_info_rep_envios. '||cNumCredito;
			RETURN P_COD_RET,P_MENSAJE;
		END IF;*/

		LET iTotalaEnviar = iTotalaEnviar + 1;

		LET cNumcte, cNumCredito, cNumProducto, dFechaApertura, sNumVencidos = '', '', '', DATE(1), 0;
		LET sNumVencidosDiaant, dSdoTotalLiquidar, dSdoTotalLiquidarDiaant, dSdoVencido, dSdoVencidoDiaante = 0, 0, 0, 0, 0;
		LET dSdoInsoluto, dSdoInsolutoDiaante, dPagosRealizados, sNumEnviosCamp1, sNumEnviosCamp2 = 0, 0, 0, 0, 0;
		LET vStatusVencidos, cStatusSituacion, cMotivoExclusion, dPagoMinimo = '', '', '', 0;

	END FOREACH;

	LET cSql = '';
	LET cSql ='if [ -f /respaldos/TC_VENTA_CART_6PV_'||TO_CHAR(vtoday,'01%m%Y')||'.txt ]; then nice nice -n -30 rm -f /respaldos/TC_VENTA_CART_6PV_'||TO_CHAR(vtoday,'01%m%Y')||'.txt; fi';
	System cSql;

	--- TXT
	LET cSql = '';
	LET cSql = 'echo "UNLOAD TO /respaldos/TC_VENTA_CART_6PV_' ||TO_CHAR(vtoday,'01%m%Y')||'.txt'|| ' DELIMITER ' || '''|'''  || ' " >> /respaldos/tc_venta_cart_6pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "SELECT numcte, num_credito, num_producto, fecha_apertura, num_vencidos," >> /respaldos/tc_venta_cart_6pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "num_vencidos_diaant, sdo_total_liquidar, sdo_total_liquidar_diaant, sdo_vencido, sdo_vencido_diaante," >> /respaldos/tc_venta_cart_6pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "sdo_insoluto, sdo_insoluto_diaante, pagos_realizados, num_envios_camp1, num_envios_camp2," >> /respaldos/tc_venta_cart_6pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "status_vencidos, status_situacion, motivo_exclusion" >> /respaldos/tc_venta_cart_6pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "FROM "informix".cb_vencidos_findemes_tdc" >> /respaldos/tc_venta_cart_6pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "WHERE fecha = MDY(' ||MONTH(dFechaaProcesar)|| ',' ||DAY(dFechaaProcesar)|| ',' ||YEAR(dFechaaProcesar)|| ')" >> /respaldos/tc_venta_cart_6pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "AND campania = ' ||"'TC_VTAC6PV'"|| '" >> /respaldos/tc_venta_cart_6pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "AND dia_procesar = ' ||''''||TRIM(pDiaEjecucion)||''''|| '" >> /respaldos/tc_venta_cart_6pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql='chmod 777 /respaldos/tc_venta_cart_6pv.sql';
	System cSql;		

	LET cSql = '';
	LET cSql = 'dbaccess bdicobranza /respaldos/tc_venta_cart_6pv.sql';
	SYSTEM cSql;		

	LET cSql = '';
	LET cSql ='rm /respaldos/tc_venta_cart_6pv.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql='chmod 777 /respaldos/TC_VENTA_CART_6PV_' ||TO_CHAR(vtoday,'01%m%Y')||'.txt';
	System cSql;

	--Genera cifras de control
	LET cMensaje = ' ------- Cifras de Control campana TC_VTAC6PV ------- ';
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

	LET cMensaje = '';
	LET cMensaje = 'TOTAL Cuentas vencidas procesadas : ' ||iTotalCuentasVencidas;
	LET cMensaje = trim(cMensaje) ||'    Cuentas a enviar : ' ||iTotalaEnviar;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	--Genera cifras de control

	LET cMensaje = '';
	LET iTotalaEnviar			= 0;
	LET	iTotalCuentasVencidas	= 0;
	LET cCampania = '';

	DROP TABLE ctes_enviarev;
-----------------------------------------------------------------
-- Genera campana TC_CAIDA2M
-----------------------------------------------------------------
	SELECT 
		a.fecha, b.numcte, a.num_credito, a.num_producto, a.fecha_apertura, a.num_vencidos,
		a.num_vencidos_diaant, a.sdo_total_liquidar, a.sdo_total_liquidar_diaant, a.sdo_vencido, a.sdo_vencido_diaante,
		a.sdo_insoluto, a.sdo_insoluto_diaante, a.pagos_realizados, a.num_envios_camp1, a.num_envios_camp2,
		a.status_vencidos, a.status_situacion, a.motivo_exclusion, a.pago_minimo
	FROM "informix".cb_vencidos_findemes_tdc a
	INNER JOIN bdicred:"informix".sd_maecred b ON (b.empresa = cEmpresa AND b.num_credito = a.num_credito)
	WHERE a.fecha = dFechaaProcesar
	AND a.campania = 'TC_CAIDA2M'
	AND a.procesar = '1'
	INTO TEMP ctes_enviarev WITH NO LOG;

	CREATE INDEX indx_vencido_tmprev ON ctes_enviarev(fecha);
	UPDATE STATISTICS MEDIUM FOR TABLE ctes_enviarev;

	FOREACH WITH HOLD
		SELECT 
			numcte, num_credito, num_producto, fecha_apertura, num_vencidos,
			num_vencidos_diaant, sdo_total_liquidar, sdo_total_liquidar_diaant, sdo_vencido, sdo_vencido_diaante,
			sdo_insoluto, sdo_insoluto_diaante, pagos_realizados, num_envios_camp1, num_envios_camp2,
			status_vencidos, status_situacion, motivo_exclusion, pago_minimo
			INTO cNumcte, cNumCredito, cNumProducto, dFechaApertura, sNumVencidos,
			sNumVencidosDiaant, dSdoTotalLiquidar, dSdoTotalLiquidarDiaant, dSdoVencido, dSdoVencidoDiaante,
			dSdoInsoluto, dSdoInsolutoDiaante, dPagosRealizados, sNumEnviosCamp1, sNumEnviosCamp2,
			vStatusVencidos, cStatusSituacion, cMotivoExclusion, dPagoMinimo
		FROM ctes_enviarev
		WHERE fecha = dFechaaProcesar

		LET	iTotalCuentasVencidas	= iTotalCuentasVencidas + 1;

		CALL bdimnsj:"informix".sp_registra_evento(2,'COBRA_SMS','TC_CAIDA2M',cNumcte,cNumCredito,'',2, 
													'','','','','',
													dPagoMinimo,sNumVencidosDiaant,'','','',
													'','',0,0,0,0,0,'','') RETURNING P_COD_RET;

		IF P_COD_RET != '00000' THEN
			LET P_MENSAJE  = 'Error en el llamado al sp_registra_evento. '||cNumCredito;
			RETURN P_COD_RET,P_MENSAJE;
		END IF;

		BEGIN WORK;
			UPDATE "informix".cb_vencidos_findemes_tdc
			SET numcte = cNumcte,
				num_envios_camp1 = sNumEnviosCamp1 + 1,
				procesar = '0'
			WHERE fecha = dFechaaProcesar
			AND campania = 'TC_CAIDA2M'
			AND num_credito = cNumCredito;
		COMMIT WORK;

/*		CALL "informix".sp_inserta_info_rep_envios (cEmpresa,'SMS',32, cNumCredito, cNumcte, cNumProducto, TODAY, '', cStatusSituacion,cMotivoExclusion,dPagoMinimo) returning P_COD_RET;

		IF P_COD_RET != '000000' THEN
			LET P_MENSAJE  = 'Error en el llamado al sp_inserta_info_rep_envios. '||cNumCredito;
			RETURN P_COD_RET,P_MENSAJE;
		END IF;*/

		LET iTotalaEnviar = iTotalaEnviar + 1;

		LET cNumcte, cNumCredito, cNumProducto, dFechaApertura, sNumVencidos = '', '', '', DATE(1), 0;
		LET sNumVencidosDiaant, dSdoTotalLiquidar, dSdoTotalLiquidarDiaant, dSdoVencido, dSdoVencidoDiaante = 0, 0, 0, 0, 0;
		LET dSdoInsoluto, dSdoInsolutoDiaante, dPagosRealizados, sNumEnviosCamp1, sNumEnviosCamp2 = 0, 0, 0, 0, 0;
		LET vStatusVencidos, cStatusSituacion, cMotivoExclusion, dPagoMinimo = '', '', '', 0;

	END FOREACH;

	LET cSql = '';
	LET cSql ='if [ -f /respaldos/TC_CAIDA_2_MORAS_'||TO_CHAR(vtoday,'01%m%Y')||'.txt ]; then nice nice -n -30 rm -f /respaldos/TC_CAIDA_2_MORAS_'||TO_CHAR(vtoday,'01%m%Y')||'.txt; fi';
	System cSql;

	--- TXT
	LET cSql = '';
	LET cSql = 'echo "UNLOAD TO /respaldos/TC_CAIDA_2_MORAS_' ||TO_CHAR(vtoday,'01%m%Y')||'.txt'|| ' DELIMITER ' || '''|'''  || ' " >> /respaldos/tc_caida_2_moras.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "SELECT numcte, num_credito, num_producto, fecha_apertura, num_vencidos," >> /respaldos/tc_caida_2_moras.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "num_vencidos_diaant, sdo_total_liquidar, sdo_total_liquidar_diaant, sdo_vencido, sdo_vencido_diaante," >> /respaldos/tc_caida_2_moras.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "sdo_insoluto, sdo_insoluto_diaante, pagos_realizados, num_envios_camp1, num_envios_camp2," >> /respaldos/tc_caida_2_moras.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "status_vencidos, status_situacion, motivo_exclusion" >> /respaldos/tc_caida_2_moras.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "FROM "informix".cb_vencidos_findemes_tdc" >> /respaldos/tc_caida_2_moras.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "WHERE fecha = MDY(' ||MONTH(dFechaaProcesar)|| ',' ||DAY(dFechaaProcesar)|| ',' ||YEAR(dFechaaProcesar)|| ')" >> /respaldos/tc_caida_2_moras.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "AND campania = ' ||"'TC_CAIDA2M'"|| '" >> /respaldos/tc_caida_2_moras.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "AND dia_procesar = ' ||''''||TRIM(pDiaEjecucion)||''''|| '" >> /respaldos/tc_caida_2_moras.sql';
	System cSql;

	LET cSql = '';
	LET cSql='chmod 777 /respaldos/tc_caida_2_moras.sql';
	System cSql;		

	LET cSql = '';
	LET cSql = 'dbaccess bdicobranza /respaldos/tc_caida_2_moras.sql';
	SYSTEM cSql;		

	LET cSql = '';
	LET cSql ='rm /respaldos/tc_caida_2_moras.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql='chmod 777 /respaldos/TC_CAIDA_2_MORAS_' ||TO_CHAR(vtoday,'01%m%Y')||'.txt';
	System cSql;

	--Genera cifras de control
	LET cMensaje = ' ------- Cifras de Control campana TC_CAIDA2M ------- ';
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

	LET cMensaje = '';
	LET cMensaje = 'TOTAL Cuentas vencidas procesadas : ' ||iTotalCuentasVencidas;
	LET cMensaje = trim(cMensaje) ||'    Cuentas a enviar : ' ||iTotalaEnviar;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	--Genera cifras de control

	LET cMensaje = '';
	LET iTotalaEnviar			= 0;
	LET	iTotalCuentasVencidas	= 0;
	LET cCampania = '';

	DROP TABLE ctes_enviarev;
-----------------------------------------------------------------
-- Genera campana TC_CAIDA1M
-----------------------------------------------------------------
	SELECT 
		a.fecha, b.numcte, a.num_credito, a.num_producto, a.fecha_apertura, a.num_vencidos,
		a.num_vencidos_diaant, a.sdo_total_liquidar, a.sdo_total_liquidar_diaant, a.sdo_vencido, a.sdo_vencido_diaante,
		a.sdo_insoluto, a.sdo_insoluto_diaante, a.pagos_realizados, a.num_envios_camp1, a.num_envios_camp2,
		a.status_vencidos, a.status_situacion, a.motivo_exclusion, a.pago_minimo
	FROM "informix".cb_vencidos_findemes_tdc a
	INNER JOIN bdicred:"informix".sd_maecred b ON (b.empresa = cEmpresa AND b.num_credito = a.num_credito)
	WHERE a.fecha = dFechaaProcesar
	AND a.campania = 'TC_CAIDA1M'
	AND a.procesar = '1'
	INTO TEMP ctes_enviarev WITH NO LOG;

	CREATE INDEX indx_vencido_tmprev ON ctes_enviarev(fecha);
	UPDATE STATISTICS MEDIUM FOR TABLE ctes_enviarev;

	FOREACH WITH HOLD
		SELECT 
			numcte, num_credito, num_producto, fecha_apertura, num_vencidos,
			num_vencidos_diaant, sdo_total_liquidar, sdo_total_liquidar_diaant, sdo_vencido, sdo_vencido_diaante,
			sdo_insoluto, sdo_insoluto_diaante, pagos_realizados, num_envios_camp1, num_envios_camp2,
			status_vencidos, status_situacion, motivo_exclusion, pago_minimo
			INTO cNumcte, cNumCredito, cNumProducto, dFechaApertura, sNumVencidos,
			sNumVencidosDiaant, dSdoTotalLiquidar, dSdoTotalLiquidarDiaant, dSdoVencido, dSdoVencidoDiaante,
			dSdoInsoluto, dSdoInsolutoDiaante, dPagosRealizados, sNumEnviosCamp1, sNumEnviosCamp2,
			vStatusVencidos, cStatusSituacion, cMotivoExclusion, dPagoMinimo
		FROM ctes_enviarev
		WHERE fecha = dFechaaProcesar

		LET	iTotalCuentasVencidas	= iTotalCuentasVencidas + 1;

		CALL bdimnsj:"informix".sp_registra_evento(2,'COBRA_SMS','TC_CAIDA1M',cNumcte,cNumCredito,'',2, 
													'','','','','',
													dPagoMinimo,sNumVencidosDiaant,'','','',
													'','',0,0,0,0,0,'','') RETURNING P_COD_RET;

		IF P_COD_RET != '00000' THEN
			LET P_MENSAJE  = 'Error en el llamado al sp_registra_evento. '||cNumCredito;
			RETURN P_COD_RET,P_MENSAJE;
		END IF;

		BEGIN WORK;
			UPDATE "informix".cb_vencidos_findemes_tdc
			SET numcte = cNumcte,
				num_envios_camp1 = sNumEnviosCamp1 + 1,
				procesar = '0'
			WHERE fecha = dFechaaProcesar
			AND campania = 'TC_CAIDA1M'
			AND num_credito = cNumCredito;
		COMMIT WORK;

/*		CALL "informix".sp_inserta_info_rep_envios (cEmpresa,'SMS',33, cNumCredito, cNumcte, cNumProducto, TODAY, '', cStatusSituacion,cMotivoExclusion,dPagoMinimo) returning P_COD_RET;

		IF P_COD_RET != '000000' THEN
			LET P_MENSAJE  = 'Error en el llamado al sp_inserta_info_rep_envios. '||cNumCredito;
			RETURN P_COD_RET,P_MENSAJE;
		END IF;*/

		LET iTotalaEnviar = iTotalaEnviar + 1;

		LET cNumcte, cNumCredito, cNumProducto, dFechaApertura, sNumVencidos = '', '', '', DATE(1), 0;
		LET sNumVencidosDiaant, dSdoTotalLiquidar, dSdoTotalLiquidarDiaant, dSdoVencido, dSdoVencidoDiaante = 0, 0, 0, 0, 0;
		LET dSdoInsoluto, dSdoInsolutoDiaante, dPagosRealizados, sNumEnviosCamp1, sNumEnviosCamp2 = 0, 0, 0, 0, 0;
		LET vStatusVencidos, cStatusSituacion, cMotivoExclusion, dPagoMinimo = '', '', '', 0;

	END FOREACH;

	LET cSql = '';
	LET cSql ='if [ -f /respaldos/TC_CAIDA_1_MORA_'||TO_CHAR(vtoday,'01%m%Y')||'.txt ]; then nice nice -n -30 rm -f /respaldos/TC_CAIDA_1_MORA_'||TO_CHAR(vtoday,'01%m%Y')||'.txt; fi';
	System cSql;

	--- TXT
	LET cSql = '';
	LET cSql = 'echo "UNLOAD TO /respaldos/TC_CAIDA_1_MORA_' ||TO_CHAR(vtoday,'01%m%Y')||'.txt'|| ' DELIMITER ' || '''|'''  || ' " >> /respaldos/tc_caida_1_mora.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "SELECT numcte, num_credito, num_producto, fecha_apertura, num_vencidos," >> /respaldos/tc_caida_1_mora.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "num_vencidos_diaant, sdo_total_liquidar, sdo_total_liquidar_diaant, sdo_vencido, sdo_vencido_diaante," >> /respaldos/tc_caida_1_mora.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "sdo_insoluto, sdo_insoluto_diaante, pagos_realizados, num_envios_camp1, num_envios_camp2," >> /respaldos/tc_caida_1_mora.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "status_vencidos, status_situacion, motivo_exclusion" >> /respaldos/tc_caida_1_mora.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "FROM "informix".cb_vencidos_findemes_tdc" >> /respaldos/tc_caida_1_mora.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "WHERE fecha = MDY(' ||MONTH(dFechaaProcesar)|| ',' ||DAY(dFechaaProcesar)|| ',' ||YEAR(dFechaaProcesar)|| ')" >> /respaldos/tc_caida_1_mora.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "AND campania = ' ||"'TC_CAIDA1M'"|| '" >> /respaldos/tc_caida_1_mora.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "AND dia_procesar = ' ||''''||TRIM(pDiaEjecucion)||''''|| '" >> /respaldos/tc_caida_1_mora.sql';
	System cSql;

	LET cSql = '';
	LET cSql='chmod 777 /respaldos/tc_caida_1_mora.sql';
	System cSql;		

	LET cSql = '';
	LET cSql = 'dbaccess bdicobranza /respaldos/tc_caida_1_mora.sql';
	SYSTEM cSql;		

	LET cSql = '';
	LET cSql ='rm /respaldos/tc_caida_1_mora.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql='chmod 777 /respaldos/TC_CAIDA_1_MORA_' ||TO_CHAR(vtoday,'01%m%Y')||'.txt';
	System cSql;

	--Genera cifras de control
	LET cMensaje = ' ------- Cifras de Control campana TC_CAIDA1M ------- ';
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

	LET cMensaje = '';
	LET cMensaje = 'TOTAL Cuentas vencidas procesadas : ' ||iTotalCuentasVencidas;
	LET cMensaje = trim(cMensaje) ||'    Cuentas a enviar : ' ||iTotalaEnviar;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	--Genera cifras de control

	LET cMensaje = '';
	LET iTotalaEnviar			= 0;
	LET	iTotalCuentasVencidas	= 0;
	LET cCampania = '';

	DROP TABLE ctes_enviarev;
END IF;

-----------------------------------------------------------------
-- Gestion de los dias restantes
-----------------------------------------------------------------
IF pDiaEjecucion IN ('7','12','22','28') THEN
-----------------------------------------------------------------
-- Genera campana TC_VTAC6PV
-----------------------------------------------------------------
	SELECT 
		a.fecha, b.numcte, a.num_credito, a.num_producto, a.fecha_apertura, a.num_vencidos,
		a.num_vencidos_diaant, a.sdo_total_liquidar, a.sdo_total_liquidar_diaant, a.sdo_vencido, a.sdo_vencido_diaante,
		a.sdo_insoluto, a.sdo_insoluto_diaante, a.pagos_realizados, a.num_envios_camp1, a.num_envios_camp2,
		a.status_vencidos, a.status_situacion, a.motivo_exclusion, a.pago_minimo
	FROM "informix".cb_vencidos_findemes_tdc a
	INNER JOIN bdicred:"informix".sd_maecred b ON (b.empresa = cEmpresa AND b.num_credito = a.num_credito)
	WHERE a.fecha = dFechaaProcesar
	AND a.campania = 'TC_VTAC6PV'
	AND a.procesar = '1'
	INTO TEMP ctes_enviarev WITH NO LOG;

	CREATE INDEX indx_vencido_tmprev ON ctes_enviarev(fecha);
	UPDATE STATISTICS MEDIUM FOR TABLE ctes_enviarev;

	FOREACH WITH HOLD
		SELECT 
			numcte, num_credito, num_producto, fecha_apertura, num_vencidos,
			num_vencidos_diaant, sdo_total_liquidar, sdo_total_liquidar_diaant, sdo_vencido, sdo_vencido_diaante,
			sdo_insoluto, sdo_insoluto_diaante, pagos_realizados, num_envios_camp1, num_envios_camp2,
			status_vencidos, status_situacion, motivo_exclusion, pago_minimo
			INTO cNumcte, cNumCredito, cNumProducto, dFechaApertura, sNumVencidos,
			sNumVencidosDiaant, dSdoTotalLiquidar, dSdoTotalLiquidarDiaant, dSdoVencido, dSdoVencidoDiaante,
			dSdoInsoluto, dSdoInsolutoDiaante, dPagosRealizados, sNumEnviosCamp1, sNumEnviosCamp2,
			vStatusVencidos, cStatusSituacion, cMotivoExclusion, dPagoMinimo
		FROM ctes_enviarev
		WHERE fecha = dFechaaProcesar

		LET	iTotalCuentasVencidas	= iTotalCuentasVencidas + 1;

		CALL bdimnsj:"informix".sp_registra_evento(2,'COBRA_SMS','TC_VTAC6PV',cNumcte,cNumCredito,'',2, 
													'','','','','',
													dPagoMinimo,sNumVencidosDiaant,'','','',
													'','',0,0,0,0,0,'','') RETURNING P_COD_RET;

		IF P_COD_RET != '00000' THEN
			LET P_MENSAJE  = 'Error en el llamado al sp_registra_evento. '||cNumCredito;
			RETURN P_COD_RET,P_MENSAJE;
		END IF;

		BEGIN WORK;
			UPDATE "informix".cb_vencidos_findemes_tdc
			SET numcte = cNumcte,
				num_envios_camp1 = sNumEnviosCamp1 + 1,
				procesar = '0'
			WHERE fecha = dFechaaProcesar
			AND campania = 'TC_VTAC6PV'
			AND num_credito = cNumCredito;
		COMMIT WORK;

/*		CALL "informix".sp_inserta_info_rep_envios (cEmpresa,'SMS',30, cNumCredito, cNumcte, cNumProducto, TODAY, '', cStatusSituacion,cMotivoExclusion,dPagoMinimo) returning P_COD_RET;

		IF P_COD_RET != '000000' THEN
			LET P_MENSAJE  = 'Error en el llamado al sp_inserta_info_rep_envios.';
			RETURN P_COD_RET,P_MENSAJE;
		END IF;*/

		LET iTotalaEnviar = iTotalaEnviar + 1;

		LET cNumcte, cNumCredito, cNumProducto, dFechaApertura, sNumVencidos = '', '', '', DATE(1), 0;
		LET sNumVencidosDiaant, dSdoTotalLiquidar, dSdoTotalLiquidarDiaant, dSdoVencido, dSdoVencidoDiaante = 0, 0, 0, 0, 0;
		LET dSdoInsoluto, dSdoInsolutoDiaante, dPagosRealizados, sNumEnviosCamp1, sNumEnviosCamp2 = 0, 0, 0, 0, 0;
		LET vStatusVencidos, cStatusSituacion, cMotivoExclusion, dPagoMinimo = '', '', '', 0;

	END FOREACH;

	LET cSql = '';
	LET cSql ='if [ -f /respaldos/TC_VENTA_CART_6PV_'||TO_CHAR(vtoday,'%d%m%Y')||'.txt ]; then nice nice -n -30 rm -f /respaldos/TC_VENTA_CART_6PV_'||TO_CHAR(vtoday,'%d%m%Y')||'.txt; fi';
	System cSql;

	--- TXT
	LET cSql = '';
	LET cSql = 'echo "UNLOAD TO /respaldos/TC_VENTA_CART_6PV_'||TO_CHAR(vtoday,'%d%m%Y')||'.txt'|| ' DELIMITER ' || '''|'''  || ' " >> /respaldos/tc_venta_cart_6pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "SELECT numcte, num_credito, num_producto, fecha_apertura, num_vencidos," >> /respaldos/tc_venta_cart_6pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "num_vencidos_diaant, sdo_total_liquidar, sdo_total_liquidar_diaant, sdo_vencido, sdo_vencido_diaante," >> /respaldos/tc_venta_cart_6pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "sdo_insoluto, sdo_insoluto_diaante, pagos_realizados, num_envios_camp1, num_envios_camp2," >> /respaldos/tc_venta_cart_6pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "status_vencidos, status_situacion, motivo_exclusion" >> /respaldos/tc_venta_cart_6pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "FROM "informix".cb_vencidos_findemes_tdc" >> /respaldos/tc_venta_cart_6pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "WHERE fecha = MDY(' ||MONTH(dFechaaProcesar)|| ',' ||DAY(dFechaaProcesar)|| ',' ||YEAR(dFechaaProcesar)|| ')" >> /respaldos/tc_venta_cart_6pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "AND campania = ' ||"'TC_VTAC6PV'"|| '" >> /respaldos/tc_venta_cart_6pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "AND dia_procesar = ' ||''''||TRIM(pDiaEjecucion)||''''|| '" >> /respaldos/tc_venta_cart_6pv.sql';
	System cSql;

	LET cSql = '';
	LET cSql='chmod 777 /respaldos/tc_venta_cart_6pv.sql';
	System cSql;		

	LET cSql = '';
	LET cSql = 'dbaccess bdicobranza /respaldos/tc_venta_cart_6pv.sql';
	SYSTEM cSql;		

	LET cSql = '';
	LET cSql ='rm /respaldos/tc_venta_cart_6pv.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql='chmod 777 /respaldos/TC_VENTA_CART_6PV_'||TO_CHAR(vtoday,'%d%m%Y')||'.txt';
	System cSql;

	--Genera cifras de control
	LET cMensaje = ' ------- Cifras de Control campana TC_VTAC6PV ------- ';
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

	LET cMensaje = '';
	LET cMensaje = 'TOTAL Cuentas vencidas procesadas : ' ||iTotalCuentasVencidas;
	LET cMensaje = trim(cMensaje) ||'    Cuentas a enviar : ' ||iTotalaEnviar;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	--Genera cifras de control

	LET cMensaje = '';
	LET iTotalaEnviar			= 0;
	LET	iTotalCuentasVencidas	= 0;
	LET cCampania = '';	

	DROP TABLE ctes_enviarev;
-----------------------------------------------------------------
-- Genera campana TC_CAIDA2M
-----------------------------------------------------------------
	IF pDiaEjecucion IN ('22','28') THEN
		LET cCampania = 'TC_CAID2MB';
	ELSE
		LET cCampania = 'TC_CAIDA2M';
	END IF;

	SELECT 
		a.fecha, b.numcte, a.num_credito, a.num_producto, a.fecha_apertura, a.num_vencidos,
		a.num_vencidos_diaant, a.sdo_total_liquidar, a.sdo_total_liquidar_diaant, a.sdo_vencido, a.sdo_vencido_diaante,
		a.sdo_insoluto, a.sdo_insoluto_diaante, a.pagos_realizados, a.num_envios_camp1, a.num_envios_camp2,
		a.status_vencidos, a.status_situacion, a.motivo_exclusion, a.pago_minimo
	FROM "informix".cb_vencidos_findemes_tdc a
	INNER JOIN bdicred:"informix".sd_maecred b ON (b.empresa = cEmpresa AND b.num_credito = a.num_credito)
	WHERE a.fecha = dFechaaProcesar
	AND a.campania = 'TC_CAIDA2M'
	AND a.procesar = '1'
	INTO TEMP ctes_enviarev WITH NO LOG;

	CREATE INDEX indx_vencido_tmprev ON ctes_enviarev(fecha);
	UPDATE STATISTICS MEDIUM FOR TABLE ctes_enviarev;

	FOREACH WITH HOLD
		SELECT 
			numcte, num_credito, num_producto, fecha_apertura, num_vencidos,
			num_vencidos_diaant, sdo_total_liquidar, sdo_total_liquidar_diaant, sdo_vencido, sdo_vencido_diaante,
			sdo_insoluto, sdo_insoluto_diaante, pagos_realizados, num_envios_camp1, num_envios_camp2,
			status_vencidos, status_situacion, motivo_exclusion, pago_minimo
			INTO cNumcte, cNumCredito, cNumProducto, dFechaApertura, sNumVencidos,
			sNumVencidosDiaant, dSdoTotalLiquidar, dSdoTotalLiquidarDiaant, dSdoVencido, dSdoVencidoDiaante,
			dSdoInsoluto, dSdoInsolutoDiaante, dPagosRealizados, sNumEnviosCamp1, sNumEnviosCamp2,
			vStatusVencidos, cStatusSituacion, cMotivoExclusion, dPagoMinimo
		FROM ctes_enviarev 
		WHERE fecha = dFechaaProcesar

		LET	iTotalCuentasVencidas	= iTotalCuentasVencidas + 1;

		CALL bdimnsj:"informix".sp_registra_evento(2,'COBRA_SMS',TRIM(cCampania),cNumcte,cNumCredito,'',2, 
													'','','','','',
													dPagoMinimo,sNumVencidosDiaant,'','','',
													'','',0,0,0,0,0,'','') RETURNING P_COD_RET;

		IF P_COD_RET != '00000' THEN
			LET P_MENSAJE  = 'Error en el llamado al sp_registra_evento.';
			RETURN P_COD_RET,P_MENSAJE;
		END IF;

		IF pDiaEjecucion IN ('22','28') THEN
			BEGIN WORK;
				UPDATE "informix".cb_vencidos_findemes_tdc
				SET numcte = cNumcte,
					num_envios_camp2 = sNumEnviosCamp2 + 1,
					procesar = '0'
				WHERE fecha = dFechaaProcesar
				AND campania = 'TC_CAIDA2M'
				AND num_credito = cNumCredito;
			COMMIT WORK;

			LET iTotalaEnviar2 = iTotalaEnviar2 + 1;
		ELSE
			BEGIN WORK;
				UPDATE "informix".cb_vencidos_findemes_tdc
				SET numcte = cNumcte,
					num_envios_camp1 = sNumEnviosCamp1 + 1,
					procesar = '0'
				WHERE fecha = dFechaaProcesar
				AND campania = 'TC_CAIDA2M'
				AND num_credito = cNumCredito;
			COMMIT WORK;

			LET iTotalaEnviar = iTotalaEnviar + 1;
		END IF;
		
/*		CALL "informix".sp_inserta_info_rep_envios (cEmpresa,'SMS',32, cNumCredito, cNumcte, cNumProducto, TODAY, '', cStatusSituacion,cMotivoExclusion,dPagoMinimo) returning P_COD_RET;

		IF P_COD_RET != '000000' THEN
			LET P_MENSAJE  = 'Error en el llamado al sp_inserta_info_rep_envios.';
			RETURN P_COD_RET,P_MENSAJE;
		END IF;*/

		LET cNumcte, cNumCredito, cNumProducto, dFechaApertura, sNumVencidos = '', '', '', DATE(1), 0;
		LET sNumVencidosDiaant, dSdoTotalLiquidar, dSdoTotalLiquidarDiaant, dSdoVencido, dSdoVencidoDiaante = 0, 0, 0, 0, 0;
		LET dSdoInsoluto, dSdoInsolutoDiaante, dPagosRealizados, sNumEnviosCamp1, sNumEnviosCamp2 = 0, 0, 0, 0, 0;
		LET vStatusVencidos, cStatusSituacion, cMotivoExclusion, dPagoMinimo = '', '', '', 0;

	END FOREACH;

	LET cSql = '';
	LET cSql ='if [ -f /respaldos/TC_CAIDA_2_MORAS_' ||TO_CHAR(vtoday,'%d%m%Y')||'.txt ]; then nice nice -n -30 rm -f /respaldos/TC_CAIDA_2_MORAS_'||TO_CHAR(vtoday,'%d%m%Y')||'.txt; fi';
	System cSql;

	--- TXT
	LET cSql = '';
	LET cSql = 'echo "UNLOAD TO /respaldos/TC_CAIDA_2_MORAS_'||TO_CHAR(vtoday,'%d%m%Y')||'.txt'|| ' DELIMITER ' || '''|'''  || ' " >> /respaldos/tc_caida_2_moras.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "SELECT numcte, num_credito, num_producto, fecha_apertura, num_vencidos," >> /respaldos/tc_caida_2_moras.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "num_vencidos_diaant, sdo_total_liquidar, sdo_total_liquidar_diaant, sdo_vencido, sdo_vencido_diaante," >> /respaldos/tc_caida_2_moras.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "sdo_insoluto, sdo_insoluto_diaante, pagos_realizados, num_envios_camp1, num_envios_camp2," >> /respaldos/tc_caida_2_moras.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "status_vencidos, status_situacion, motivo_exclusion" >> /respaldos/tc_caida_2_moras.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "FROM "informix".cb_vencidos_findemes_tdc" >> /respaldos/tc_caida_2_moras.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "WHERE fecha = MDY(' ||MONTH(dFechaaProcesar)|| ',' ||DAY(dFechaaProcesar)|| ',' ||YEAR(dFechaaProcesar)|| ')" >> /respaldos/tc_caida_2_moras.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "AND campania = ' ||"'TC_CAIDA2M'"|| '" >> /respaldos/tc_caida_2_moras.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "AND dia_procesar = ' ||''''||TRIM(pDiaEjecucion)||''''|| '" >> /respaldos/tc_caida_2_moras.sql';
	System cSql;

	LET cSql = '';
	LET cSql='chmod 777 /respaldos/tc_caida_2_moras.sql';
	System cSql;		

	LET cSql = '';
	LET cSql = 'dbaccess bdicobranza /respaldos/tc_caida_2_moras.sql';
	SYSTEM cSql;		

	LET cSql = '';
	LET cSql ='rm /respaldos/tc_caida_2_moras.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql='chmod 777 /respaldos/TC_CAIDA_2_MORAS_'||TO_CHAR(vtoday,'%d%m%Y')||'.txt';
	System cSql;

	--Genera cifras de control
	LET cMensaje = ' ------- Cifras de Control campana TC_CAIDA2M ------- ';
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

	LET cMensaje = '';
	LET cMensaje = 'TOTAL Cuentas vencidas procesadas : ' ||iTotalCuentasVencidas;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = '';
	LET cMensaje = 'Cuentas a enviar TC_CAIDA2M: ' ||iTotalaEnviar;
	LET cMensaje = trim(cMensaje) ||'    Cuentas a enviar TC_CAID2MB: ' ||iTotalaEnviar2;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	--Genera cifras de control

	LET cMensaje = '';
	LET iTotalaEnviar			= 0;
	LET iTotalaEnviar2			= 0;
	LET	iTotalCuentasVencidas	= 0;
	LET cCampania = '';

	DROP TABLE ctes_enviarev;
-----------------------------------------------------------------
-- Genera campana TC_CAIDA1M
-----------------------------------------------------------------
	IF pDiaEjecucion IN ('22','28') THEN
		LET cCampania = 'TC_CAID1MB';
	ELSE
		LET cCampania = 'TC_CAIDA1M';
	END IF;

	SELECT 
		a.fecha, b.numcte, a.num_credito, a.num_producto, a.fecha_apertura, a.num_vencidos,
		a.num_vencidos_diaant, a.sdo_total_liquidar, a.sdo_total_liquidar_diaant, a.sdo_vencido, a.sdo_vencido_diaante,
		a.sdo_insoluto, a.sdo_insoluto_diaante, a.pagos_realizados, a.num_envios_camp1, a.num_envios_camp2,
		a.status_vencidos, a.status_situacion, a.motivo_exclusion, a.pago_minimo
	FROM "informix".cb_vencidos_findemes_tdc a
	INNER JOIN bdicred:"informix".sd_maecred b ON (b.empresa = cEmpresa AND b.num_credito = a.num_credito)
	WHERE a.fecha = dFechaaProcesar
	AND a.campania = 'TC_CAIDA1M'
	AND a.procesar = '1'
	INTO TEMP ctes_enviarev WITH NO LOG;

	CREATE INDEX indx_vencido_tmprev ON ctes_enviarev(fecha);
	UPDATE STATISTICS MEDIUM FOR TABLE ctes_enviarev;

	FOREACH WITH HOLD
		SELECT 
			numcte, num_credito, num_producto, fecha_apertura, num_vencidos,
			num_vencidos_diaant, sdo_total_liquidar, sdo_total_liquidar_diaant, sdo_vencido, sdo_vencido_diaante,
			sdo_insoluto, sdo_insoluto_diaante, pagos_realizados, num_envios_camp1, num_envios_camp2,
			status_vencidos, status_situacion, motivo_exclusion, pago_minimo
			INTO cNumcte, cNumCredito, cNumProducto, dFechaApertura, sNumVencidos,
			sNumVencidosDiaant, dSdoTotalLiquidar, dSdoTotalLiquidarDiaant, dSdoVencido, dSdoVencidoDiaante,
			dSdoInsoluto, dSdoInsolutoDiaante, dPagosRealizados, sNumEnviosCamp1, sNumEnviosCamp2,
			vStatusVencidos, cStatusSituacion, cMotivoExclusion, dPagoMinimo
		FROM ctes_enviarev
		WHERE fecha = dFechaaProcesar

		LET	iTotalCuentasVencidas	= iTotalCuentasVencidas + 1;

		CALL bdimnsj:"informix".sp_registra_evento(2,'COBRA_SMS',TRIM(cCampania),cNumcte,cNumCredito,'',2, 
													'','','','','',
													dPagoMinimo,sNumVencidosDiaant,'','','',
													'','',0,0,0,0,0,'','') RETURNING P_COD_RET;

		IF P_COD_RET != '00000' THEN
			LET P_MENSAJE  = 'Error en el llamado al sp_registra_evento.';
			RETURN P_COD_RET,P_MENSAJE;
		END IF;

		IF pDiaEjecucion IN ('22','28') THEN
			BEGIN WORK;
				UPDATE "informix".cb_vencidos_findemes_tdc
				SET numcte = cNumcte,
					num_envios_camp2 = sNumEnviosCamp2 + 1,
					procesar = '0'
				WHERE fecha = dFechaaProcesar
				AND campania = 'TC_CAIDA1M'
				AND num_credito = cNumCredito;
			COMMIT WORK;

			LET iTotalaEnviar2 = iTotalaEnviar2 + 1;
		ELSE
			BEGIN WORK;
				UPDATE "informix".cb_vencidos_findemes_tdc
				SET numcte = cNumcte,
					num_envios_camp1 = sNumEnviosCamp1 + 1,
					procesar = '0'
				WHERE fecha = dFechaaProcesar
				AND campania = 'TC_CAIDA1M'
				AND num_credito = cNumCredito;
			COMMIT WORK;

			LET iTotalaEnviar = iTotalaEnviar + 1;
		END IF;

/*		CALL "informix".sp_inserta_info_rep_envios (cEmpresa,'SMS',33, cNumCredito, cNumcte, cNumProducto, TODAY, '', cStatusSituacion,cMotivoExclusion,dPagoMinimo) returning P_COD_RET;

		IF P_COD_RET != '000000' THEN
			LET P_MENSAJE  = 'Error en el llamado al sp_inserta_info_rep_envios.';
			RETURN P_COD_RET,P_MENSAJE;
		END IF;*/

		LET cNumcte, cNumCredito, cNumProducto, dFechaApertura, sNumVencidos = '', '', '', DATE(1), 0;
		LET sNumVencidosDiaant, dSdoTotalLiquidar, dSdoTotalLiquidarDiaant, dSdoVencido, dSdoVencidoDiaante = 0, 0, 0, 0, 0;
		LET dSdoInsoluto, dSdoInsolutoDiaante, dPagosRealizados, sNumEnviosCamp1, sNumEnviosCamp2 = 0, 0, 0, 0, 0;
		LET vStatusVencidos, cStatusSituacion, cMotivoExclusion, dPagoMinimo = '', '', '', 0;

	END FOREACH;

	LET cSql = '';
	LET cSql ='if [ -f /respaldos/TC_CAIDA_1_MORA_'||TO_CHAR(vtoday,'%d%m%Y')||'.txt ]; then nice nice -n -30 rm -f /respaldos/TC_CAIDA_1_MORA_' ||TO_CHAR(vtoday,'%d%m%Y')||'.txt; fi';
	System cSql;

	--- TXT
	LET cSql = '';
	LET cSql = 'echo "UNLOAD TO /respaldos/TC_CAIDA_1_MORA_'||TO_CHAR(vtoday,'%d%m%Y')||'.txt'|| ' DELIMITER ' || '''|'''  || ' " >> /respaldos/tc_caida_1_mora.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "SELECT numcte, num_credito, num_producto, fecha_apertura, num_vencidos," >> /respaldos/tc_caida_1_mora.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "num_vencidos_diaant, sdo_total_liquidar, sdo_total_liquidar_diaant, sdo_vencido, sdo_vencido_diaante," >> /respaldos/tc_caida_1_mora.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "sdo_insoluto, sdo_insoluto_diaante, pagos_realizados, num_envios_camp1, num_envios_camp2," >> /respaldos/tc_caida_1_mora.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "status_vencidos, status_situacion, motivo_exclusion" >> /respaldos/tc_caida_1_mora.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "FROM "informix".cb_vencidos_findemes_tdc" >> /respaldos/tc_caida_1_mora.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "WHERE fecha = MDY(' ||MONTH(dFechaaProcesar)|| ',' ||DAY(dFechaaProcesar)|| ',' ||YEAR(dFechaaProcesar)|| ')" >> /respaldos/tc_caida_1_mora.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "AND campania = ' ||"'TC_CAIDA1M'"|| '" >> /respaldos/tc_caida_1_mora.sql';
	System cSql;

	LET cSql = '';
	LET cSql = 'echo "AND dia_procesar = ' ||''''||TRIM(pDiaEjecucion)||''''|| '" >> /respaldos/tc_caida_1_mora.sql';
	System cSql;

	LET cSql = '';
	LET cSql='chmod 777 /respaldos/tc_caida_1_mora.sql';
	System cSql;		

	LET cSql = '';
	LET cSql = 'dbaccess bdicobranza /respaldos/tc_caida_1_mora.sql';
	SYSTEM cSql;		

	LET cSql = '';
	LET cSql ='rm /respaldos/tc_caida_1_mora.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql='chmod 777 /respaldos/TC_CAIDA_1_MORA_'||TO_CHAR(vtoday,'%d%m%Y')||'.txt';
	System cSql;

	--Genera cifras de control
	LET cMensaje = ' ------- Cifras de Control campana TC_CAIDA1M ------- ';
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

	LET cMensaje = '';
	LET cMensaje = 'TOTAL Cuentas vencidas procesadas : ' ||iTotalCuentasVencidas;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = '';
	LET cMensaje = 'Cuentas a enviar TC_CAIDA1M: ' ||iTotalaEnviar;
	LET cMensaje = trim(cMensaje) ||'    Cuentas a enviar TC_CAID1MB: ' ||iTotalaEnviar2;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	--Genera cifras de control

	LET cMensaje = '';
	LET iTotalaEnviar			= 0;
	LET iTotalaEnviar2			= 0;
	LET	iTotalCuentasVencidas	= 0;
	LET cCampania = '';

	DROP TABLE ctes_enviarev;
END IF;

CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, P_MENSAJE, '03') RETURNING P_COD_RET;

IF P_COD_RET != '000000' THEN
	LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
	RETURN P_COD_RET,P_MENSAJE;
END IF;

END
RETURN cCodRet,P_MENSAJE;
END PROCEDURE;
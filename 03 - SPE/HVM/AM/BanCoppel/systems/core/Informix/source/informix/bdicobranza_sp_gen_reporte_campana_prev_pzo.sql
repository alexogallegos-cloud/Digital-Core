CREATE PROCEDURE "informix".sp_gen_reporte_campana_prev_pzo(pEmpresa CHAR(3))
returning VARCHAR(06),
          VARCHAR(80);

-- EXECUTE PROCEDURE "informix".sp_gen_reporte_campana_prev_pzo('001');

DEFINE SQL_ERR					INTEGER;
DEFINE ISAM_ERR					INTEGER;
DEFINE ERROR_INFO				VARCHAR(80);
DEFINE cProceso					CHAR(4);
DEFINE P_COD_RET				VARCHAR(6);
DEFINE P_MENSAJE				VARCHAR(80);
DEFINE cCodRet  				CHAR(6);
DEFINE cMensaje  				CHAR(500);

DEFINE dFecha					DATE;
DEFINE dFecha_cierre			DATE;
DEFINE dFecha_ven				DATE;
DEFINE dFecha_ini_mp1			DATE;
DEFINE dFecha_fin_mp1			DATE;
DEFINE dFecha_ini_mp2			DATE;
DEFINE dFecha_fin_mp2			DATE;
DEFINE dFecha_ini_mp3			DATE;
DEFINE dFecha_fin_mp3			DATE;
DEFINE dFechaCuota				DATE;
DEFINE cNumCredito				VARCHAR(20);
DEFINE cNumcte					VARCHAR(20);
DEFINE cNumProducto				VARCHAR(04);
DEFINE cfech_corte				DATE;
DEFINE v_telcelular				VARCHAR(10);
DEFINE dPagoMin					DECIMAL(18,2);
DEFINE v_no_ven_fec_lim			INTEGER;
DEFINE v_no_ven_cierre			INTEGER;
DEFINE v_monto_pagos_1			DECIMAL(18,2);
DEFINE v_monto_pagos_2			DECIMAL(18,2);
DEFINE vCampana					VARCHAR(10);
DEFINE vNo_sms					INTEGER;
DEFINE vNo_sms2					INTEGER;
DEFINE vNo_llamadas				INTEGER;
DEFINE vBandera					VARCHAR(1);
DEFINE vBandera2				VARCHAR(1);
DEFINE cExist					VARCHAR(1);
DEFINE cSql						CHAR(2000);

DEFINE iTotalCuentas			INTEGER;
DEFINE iTotalaEnviar			INTEGER;
DEFINE iDuplicado				INTEGER;


BEGIN 
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
     LET P_COD_RET = SQL_ERR;
     LET P_MENSAJE = 'Error al ejecutar el proceso. '||cNumCredito;
     CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, P_COD_RET, P_MENSAJE, '02')
     RETURNING P_COD_RET;
     LET P_COD_RET = SQL_ERR;

     RETURN P_COD_RET,P_MENSAJE;
   END EXCEPTION;

--SET DEBUG FILE TO "sp_gen_reporte_campana_prev_pzo.out";
--TRACE ON;

LET cProceso            	= '2057';
LET P_COD_RET           	= '000000';
LET cCodRet           		= '000000';
LET P_MENSAJE           	= 'El proceso que GENERA REPORTE PREVPP se ejecuto correctamente.';
LET cMensaje				= '';

LET dFecha					= DATE(1);
LET dFecha_cierre			= DATE(1);
LET dFecha_ven				= DATE(1);
LET dFecha_ini_mp1			= DATE(1);
LET dFecha_fin_mp1			= DATE(1);
LET dFecha_ini_mp2			= DATE(1);
LET dFecha_fin_mp2			= DATE(1);
LET dFechaCuota				= DATE(1);
LET cNumCredito				= '';
LET cNumcte					= '';
LET cNumProducto			= '';
LET cfech_corte				= DATE(1);
LET dPagoMin				= 0;
LET v_no_ven_fec_lim		= 0;
LET v_no_ven_cierre			= 0;
LET v_monto_pagos_1			= 0;
LET v_monto_pagos_2			= 0;
LET vCampana				= '';
LET vNo_sms					= 0;
LET vNo_sms2				= 0;
LET vNo_llamadas			= 0;
LET vBandera				= '';
LET vBandera2				= '';
LET cExist					= '';
LET cSql					= '';

LET iTotalCuentas 			= 0;
LET iTotalaEnviar			= 0;
LET iDuplicado				= 0;


CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, P_MENSAJE, '01')
    RETURNING P_COD_RET;

IF P_COD_RET != '000000' THEN
   LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
   RETURN P_COD_RET,P_MENSAJE;
END IF;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT fecha_hoy INTO dFecha FROM bdicred:"informix".sd_fechas WHERE empresa = pEmpresa;

LET dFecha_cierre = dFecha - 1 UNITS DAY;

-----------------------------------------------------------------
-- Genera reporte de campana preventiva revolvente
-----------------------------------------------------------------
SELECT a.num_credito, a.numcte, a.num_producto, b.prox_fecha_pago
FROM "informix".cb_campana_prev_sms a
INNER JOIN bdicred:"informix".sd_maecredanexocrd b ON (b.empresa = pEmpresa AND b.num_credito = a.num_credito AND b.fecha_proceso >= DATE(1))
WHERE num_producto IN ('6300','7600','7700')
UNION ALL
SELECT a.num_credito, a.numcte, a.num_producto, b.prox_fecha_pago
FROM "informix".cb_campana_prev a
INNER JOIN bdicred:"informix".sd_maecredanexocrd b ON (b.empresa = pEmpresa AND b.num_credito = a.num_credito AND b.fecha_proceso >= DATE(1))
WHERE num_producto IN ('6300','7600','7700')
INTO TEMP cuentas_rep_pp WITH NO LOG;

CREATE INDEX inx_producto_sms_tdc ON cuentas_rep_pp(num_producto) in dbs_movhis_idx3;
UPDATE STATISTICS MEDIUM FOR TABLE cuentas_rep_pp;

FOREACH WITH HOLD
	SELECT UNIQUE(num_credito), numcte, num_producto, prox_fecha_pago
	INTO cNumCredito, cNumcte, cNumProducto, cfech_corte
	FROM cuentas_rep_pp
	WHERE num_producto IN ('6300','7600','7700')

	LET iTotalCuentas = iTotalCuentas + 1;

	SELECT FIRST 1 '1'
	INTO cExist
	FROM "informix".cb_report_campana_prev
	WHERE num_credito = cNumCredito
	AND fecha = dFecha;

	IF(cExist = '1') THEN
		LET iDuplicado = iDuplicado + 1;
		CONTINUE FOREACH;
	END IF;

	LET dFecha_ven = MDY(MONTH(dFecha_cierre),DAY(cfech_corte),YEAR(dFecha_cierre));

	LET dFecha_ini_mp1 = MDY(MONTH(dFecha_cierre),DAY(cfech_corte),YEAR(dFecha_cierre)) - 6 UNITS DAY;

	LET dFecha_fin_mp1 = MDY(MONTH(dFecha_cierre),DAY(cfech_corte),YEAR(dFecha_cierre));

	LET dFecha_ini_mp2 = MDY(MONTH(dFecha_cierre),DAY(cfech_corte),YEAR(dFecha_cierre));

	LET dFecha_fin_mp2 = MDY(MONTH(dFecha_cierre),DAY(cfech_corte),YEAR(dFecha_cierre)) + 5 UNITS DAY;

	SELECT mto_fin_ven_trasp
	INTO v_no_ven_fec_lim
	FROM bdicred:"informix".sd_maesdoshistcrd
	WHERE empresa = pEmpresa
	AND num_credito = cNumCredito
	AND fecha = dFecha_ven;

	IF(v_no_ven_fec_lim IS NULL) THEN LET v_no_ven_fec_lim = 0; END IF;
	
	SELECT MAX(fecha_cuota)
	INTO dFechaCuota
	FROM bdicred:"informix".sd_amortiza_creditocrd
	WHERE empresa = pEmpresa
	AND num_credito = cNumCredito
	AND capital_status = "3";
	
	IF(dFechaCuota IS NULL) THEN LET dFechaCuota = DATE(1); END IF;
	
	SELECT capital_mto_cuota
	INTO dPagoMin
	FROM bdicred:"informix".sd_amortiza_creditocrd
	WHERE empresa = pEmpresa 
	AND num_credito = cNumCredito 
	AND capital_status = "3"
	AND fecha_cuota = dFechaCuota;

	IF(dPagoMin IS NULL) THEN LET dPagoMin = 0; END IF;

	SELECT mto_fin_ven_trasp
	INTO v_no_ven_cierre
	FROM bdicred:"informix".sd_maesdoscontcrd
	WHERE empresa = pEmpresa
	AND num_credito = cNumCredito
	AND fecha = dFecha_cierre;

	IF(v_no_ven_cierre IS NULL) THEN LET v_no_ven_cierre = 0; END IF;

	SELECT SUM(monto)
	INTO v_monto_pagos_1
	FROM bdicred:"informix".sd_movhiscrd
	WHERE empresa = pEmpresa
	AND fecha_mov > dFecha_ini_mp1
	AND fecha_mov <= dFecha_fin_mp1
	AND num_credito = cNumCredito
	AND codigo_fun IN (select cod_fun from bdicred:"informix".sd_conceptospagomanualcrd WHERE num_producto = cNumProducto)
	AND codigo_ref = 1 
	AND reversado = 'N';

	IF(v_monto_pagos_1 IS NULL) THEN LET v_monto_pagos_1 = 0; END IF;

	SELECT SUM(monto)
	INTO v_monto_pagos_2
	FROM bdicred:"informix".sd_movhiscrd
	WHERE empresa = pEmpresa
	AND fecha_mov > dFecha_ini_mp2
	AND fecha_mov <= dFecha_fin_mp2
	AND num_credito = cNumCredito
	AND codigo_fun IN (select cod_fun from bdicred:"informix".sd_conceptospagomanualcrd WHERE num_producto = cNumProducto)
	AND codigo_ref = 1 
	AND reversado = 'N';

	IF(v_monto_pagos_2 IS NULL) THEN LET v_monto_pagos_2 = 0; END IF;

	SELECT FIRST 1 "1"
	INTO vBandera
	FROM "informix".cb_campana_prev
	WHERE num_credito = cNumCredito
	AND num_producto = cNumProducto;

	IF(vBandera IS NULL) THEN LET vBandera = ''; END IF;

	SELECT FIRST 1 "1"
	INTO vBandera2
	FROM "informix".cb_campana_prev_sms
	WHERE num_credito = cNumCredito
	AND num_producto = cNumProducto;

	IF(vBandera2 IS NULL) THEN LET vBandera2 = ''; END IF;

	IF (vBandera = "1") AND (vBandera2 = "1") THEN
		LET vCampana = "CAT y SMS";

		SELECT cont_sms
		INTO vNo_sms
		FROM "informix".cb_campana_prev
		WHERE num_credito = cNumCredito
		AND num_producto = cNumProducto;

		IF(vNo_sms IS NULL) THEN LET vNo_sms = 0; END IF;

		SELECT cont_sms
		INTO vNo_sms2
		FROM "informix".cb_campana_prev
		WHERE num_credito = cNumCredito
		AND num_producto = cNumProducto;

		IF(vNo_sms2 IS NULL) THEN LET vNo_sms2 = 0; END IF;

		LET vNo_sms = vNo_sms + vNo_sms2;
	ELIF (vBandera = "1") THEN
		LET vCampana = "CAT";

		SELECT cont_sms
		INTO vNo_sms
		FROM "informix".cb_campana_prev
		WHERE num_credito = cNumCredito
		AND num_producto = cNumProducto;

		IF(vNo_sms IS NULL) THEN LET vNo_sms = 0; END IF;
	ELIF (vBandera2 = "1") THEN
		LET vCampana = "SMS";

		SELECT cont_sms
		INTO vNo_sms
		FROM "informix".cb_campana_prev_sms
		WHERE num_credito = cNumCredito
		AND num_producto = cNumProducto;

		IF(vNo_sms IS NULL) THEN LET vNo_sms = 0; END IF;
	END IF;

	IF vNo_sms > 1 THEN
		LET vNo_sms = 2;
	END IF;
	
	SELECT COUNT(num_credito)
	INTO vNo_llamadas
	FROM "informix".cb_resultados_detallado_prev
	WHERE num_credito = cNumCredito;
	
	IF(vNo_llamadas IS NULL) THEN LET vNo_llamadas = 0; END IF;

	BEGIN;
		INSERT INTO "informix".cb_report_campana_prev(fecha, numcte, num_credito, num_producto, no_vencidos_fec_lim, no_vencidos_cierre, pago_minimo, monto_pagos_1, monto_pagos_2, monto_pagos_3, campana, no_sms, no_llamadas, fingestion, razonincumplimiento)
		VALUES(dFecha, TRIM(cNumcte), TRIM(cNumCredito), TRIM(cNumProducto), v_no_ven_fec_lim, v_no_ven_cierre, dPagoMin, v_monto_pagos_1, v_monto_pagos_2, 0, TRIM(vCampana), vNo_sms, vNo_llamadas, "", "");
	COMMIT;

	LET iTotalaEnviar = iTotalaEnviar + 1;

	LET cNumcte, cNumCredito, cNumProducto, v_no_ven_fec_lim, v_no_ven_cierre = '', '', '', 0, 0;
	LET dPagoMin, v_monto_pagos_1, v_monto_pagos_2, vCampana = 0, 0, 0, '';
	LET vNo_sms, vNo_llamadas, dFechaCuota, dFecha_ven, dFecha_ini_mp1 = 0, 0, DATE(1), DATE(1), DATE(1);
	LET dFecha_fin_mp1, dFecha_ini_mp2, dFecha_fin_mp2 = DATE(1), DATE(1), DATE(1);
END FOREACH;

DROP TABLE cuentas_rep_pp;

UPDATE STATISTICS MEDIUM FOR TABLE "informix".cb_report_campana_prev;

LET cSql ='if [ -f /respaldos/RepCampanaPrevPP'||YEAR(dFecha)||MONTH(dFecha)||'01.txt.gz ]; then nice nice -n -30 rm -f /respaldos/RepCampanaPrevPP'||YEAR(dFecha)||MONTH(dFecha)||'01.txt.gz; fi';
System cSql;

LET cSql = '';
LET cSql = 'echo "numcte|num_credito|num_producto|no_vencidos_fec_lim|no_vencidos_cierre|pago_minimo|monto_pagos_1|monto_pagos_2|campana|no_sms|no_llamadas|" > /respaldos/RepCampanaPrevPP'||YEAR(dFecha)||MONTH(dFecha)||'01.txt';
System cSql;

LET cSql = '';
LET cSql = 'echo "UNLOAD TO /respaldos/RepCampanaPrevPP_aux'||YEAR(dFecha)||MONTH(dFecha)||'01.txt'|| ' DELIMITER ' || '''|'''  || ' " >> /respaldos/rep_campana_prevpp.sql';
System cSql;

LET cSql = '';
LET cSql = 'echo "SELECT numcte, num_credito, num_producto, no_vencidos_fec_lim, no_vencidos_cierre," >> /respaldos/rep_campana_prevpp.sql';
System cSql;

LET cSql = '';
LET cSql = 'echo "pago_minimo, monto_pagos_1, monto_pagos_2, campana, no_sms," >> /respaldos/rep_campana_prevpp.sql';
System cSql;

LET cSql = '';
LET cSql = 'echo "no_llamadas" >> /respaldos/rep_campana_prevpp.sql';
System cSql;

LET cSql = '';
LET cSql = 'echo "FROM "informix".cb_report_campana_prev" >> /respaldos/rep_campana_prevpp.sql';
System cSql;

LET cSql = '';
LET cSql = 'echo "WHERE num_producto IN (' ||"'6300'"|| ',' ||"'7600'"|| ',' ||"'7700'"|| ')" >> /respaldos/rep_campana_prevpp.sql';
System cSql;

LET cSql = '';
LET cSql = 'echo "AND fecha = MDY(' ||MONTH(dFecha)|| ',' ||DAY(dFecha)|| ',' ||YEAR(dFecha)|| ');" >> /respaldos/rep_campana_prevpp.sql';
System cSql;

LET cSql = '';
LET cSql='chmod 777 /respaldos/rep_campana_prevpp.sql';
System cSql;		

LET cSql = '';
LET cSql = 'dbaccess bdicobranza /respaldos/rep_campana_prevpp.sql';
SYSTEM cSql;		

LET cSql = '';
LET cSql ='rm /respaldos/rep_campana_prevpp.sql';
SYSTEM cSql;

LET cSql = '';
LET cSql ='cat /respaldos/RepCampanaPrevPP_aux'||YEAR(dFecha)||MONTH(dFecha)||'01.txt >> /respaldos/RepCampanaPrevPP'||YEAR(dFecha)||MONTH(dFecha)||'01.txt';
SYSTEM cSql;

LET cSql = '';
LET cSql ='rm /respaldos/RepCampanaPrevPP_aux'||YEAR(dFecha)||MONTH(dFecha)||'01.txt';
SYSTEM cSql;

LET cSql = '';
LET cSql='chmod 777 /respaldos/RepCampanaPrevPP'||YEAR(dFecha)||MONTH(dFecha)||'01.txt';
System cSql;

LET cSql = '';
LET cSql='gzip /respaldos/RepCampanaPrevPP'||YEAR(dFecha)||MONTH(dFecha)||'01.txt';
System cSql;

LET cSql = '';
LET cSql='chmod 777 /respaldos/RepCampanaPrevPP'||YEAR(dFecha)||MONTH(dFecha)||'01.txt.gz';
System cSql;

--Genera cifras de control
LET cMensaje = ' ------- Cifras de Control REPORTE PREVPP ------- ';
CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

LET cMensaje = '';
LET cMensaje = 'TOTAL Cuentas procesadas : ' ||iTotalCuentas;
CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
LET cMensaje = '';
LET cMensaje = 'Cuentas DUPLICADAS : ' ||iDuplicado;
CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
LET cMensaje = '';
LET cMensaje = 'Cuentas agregadas al Reporte: ' ||iTotalaEnviar;
CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
--Genera cifras de control

LET cMensaje 				= '';
LET iTotalCuentas 			= 0;
LET iTotalaEnviar			= 0;
LET iDuplicado				= 0;

TRUNCATE TABLE "informix".cb_resultados_detallado_prev DROP STORAGE;

CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, P_MENSAJE, '03') RETURNING P_COD_RET;

IF P_COD_RET != '000000' THEN
	LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
	RETURN P_COD_RET,P_MENSAJE;
END IF;

END
RETURN cCodRet,P_MENSAJE;
END PROCEDURE;
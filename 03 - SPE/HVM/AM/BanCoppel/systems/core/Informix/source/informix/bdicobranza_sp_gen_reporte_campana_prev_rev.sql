CREATE PROCEDURE "informix".sp_gen_reporte_campana_prev_rev(pEmpresa CHAR(3))
returning VARCHAR(06),
          VARCHAR(80);

-- EXECUTE PROCEDURE "informix".sp_gen_reporte_campana_prev_rev('001');

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
DEFINE cNumCredito				VARCHAR(20);
DEFINE cNumcte					VARCHAR(20);
DEFINE cNumProducto				VARCHAR(04);
DEFINE v_telcelular				VARCHAR(10);
DEFINE dPagoMin					DECIMAL(18,2);
DEFINE v_no_ven_fec_lim			INTEGER;
DEFINE v_no_ven_cierre			INTEGER;
DEFINE v_monto_pagos_1			DECIMAL(18,2);
DEFINE v_monto_pagos_2			DECIMAL(18,2);
DEFINE v_monto_pagos_3			DECIMAL(18,2);
DEFINE vCampana					VARCHAR(10);
DEFINE vNo_sms					INTEGER;
DEFINE vNo_sms2					INTEGER;
DEFINE vNo_llamadas				INTEGER;
DEFINE vBandera					VARCHAR(1);
DEFINE vBandera2				VARCHAR(1);
DEFINE cExist					VARCHAR(1);
DEFINE cSql						CHAR(2000);
DEFINE pReinicio				CHAR(1);

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

--SET DEBUG FILE TO "sp_gen_reporte_campana_prev_rev.out";
--TRACE ON;

LET cProceso            	= '2056';
LET P_COD_RET           	= '000000';
LET cCodRet           		= '000000';
LET P_MENSAJE           	= 'El proceso que GENERA REPORTE PREVTDC se ejecuto correctamente.';
LET cMensaje				= '';

LET dFecha					= DATE(1);
LET dFecha_cierre			= DATE(1);
LET dFecha_ven				= DATE(1);
LET dFecha_ini_mp1			= DATE(1);
LET dFecha_fin_mp1			= DATE(1);
LET dFecha_ini_mp2			= DATE(1);
LET dFecha_fin_mp2			= DATE(1);
LET dFecha_ini_mp3			= DATE(1);
LET dFecha_fin_mp3			= DATE(1);
LET cNumCredito				= '';
LET cNumcte					= '';
LET cNumProducto			= '';
LET dPagoMin				= 0;
LET v_no_ven_fec_lim		= 0;
LET v_no_ven_cierre			= 0;
LET v_monto_pagos_1			= 0;
LET v_monto_pagos_2			= 0;
LET v_monto_pagos_3			= 0;
LET vCampana				= '';
LET vNo_sms					= 0;
LET vNo_sms2				= 0;
LET vNo_llamadas			= 0;
LET vBandera				= '';
LET vBandera2				= '';
LET cExist					= '';
LET cSql					= '';
LET pReinicio				= '';

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

SELECT FIRST 1 '1' INTO pReinicio FROM "informix".cb_report_campana_prev WHERE fecha >= MDY(MONTH(dFecha),1,YEAR(dFecha));

IF pReinicio IS NULL OR pReinicio = '' THEN
	TRUNCATE TABLE "informix".cb_report_campana_prev DROP STORAGE;
	CALL "informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, 'BORRADO DE TABLA FECHA '|| dFecha, '02') RETURNING P_COD_RET;
	IF P_COD_RET != '000000' THEN
		LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
		RETURN P_COD_RET,P_MENSAJE;
	END IF;
ELSE
	CALL "informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, 'SIN BORRADO DE TABLE FECHA '|| dFecha, '02') RETURNING P_COD_RET;
	IF P_COD_RET != '000000' THEN
		LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
		RETURN P_COD_RET,P_MENSAJE;
	END IF;
END IF;

LET dFecha_cierre = dFecha - 1 UNITS DAY;

LET dFecha_ven = MDY(MONTH(dFecha_cierre),20,YEAR(dFecha_cierre));

LET dFecha_ini_mp1 = MDY(MONTH(dFecha_cierre),10,YEAR(dFecha_cierre));

LET dFecha_fin_mp1 = MDY(MONTH(dFecha_cierre),16,YEAR(dFecha_cierre));

LET dFecha_ini_mp2 = MDY(MONTH(dFecha_cierre),17,YEAR(dFecha_cierre));

LET dFecha_fin_mp2 = MDY(MONTH(dFecha_cierre),20,YEAR(dFecha_cierre));

LET dFecha_ini_mp3 = MDY(MONTH(dFecha_cierre),21,YEAR(dFecha_cierre));

LET dFecha_fin_mp3 = dFecha_cierre;

-----------------------------------------------------------------
-- Genera reporte de campana preventiva revolvente
-----------------------------------------------------------------
SELECT num_credito, numcte, num_producto
FROM "informix".cb_campana_prev_sms
WHERE num_producto = '6001'
UNION ALL
SELECT num_credito, numcte, num_producto
FROM "informix".cb_campana_prev
WHERE num_producto = '6001'
INTO TEMP cuentas_rep_tdc WITH NO LOG;

CREATE INDEX inx_producto_sms_tdc ON cuentas_rep_tdc(num_producto) in dbs_movhis_idx3;
UPDATE STATISTICS MEDIUM FOR TABLE cuentas_rep_tdc;

FOREACH WITH HOLD
	SELECT UNIQUE(num_credito), numcte, num_producto
	INTO cNumCredito, cNumcte, cNumProducto
	FROM cuentas_rep_tdc
	WHERE num_producto = '6001'

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

	SELECT mto_fin_ven_trasp, monto_financiado
	INTO v_no_ven_fec_lim, dPagoMin
	FROM bdicred:"informix".sd_maesdoshist
	WHERE empresa = pEmpresa
	AND num_credito = cNumCredito
	AND fecha = dFecha_ven;

	IF(v_no_ven_fec_lim IS NULL) THEN LET v_no_ven_fec_lim = 0; END IF;

	IF(dPagoMin IS NULL) THEN LET dPagoMin = 0; END IF;

	SELECT mto_fin_ven_trasp
	INTO v_no_ven_cierre
	FROM bdicred:"informix".sd_maesdoscont
	WHERE empresa = pEmpresa
	AND num_credito = cNumCredito
	AND fecha = dFecha_cierre;

	IF(v_no_ven_cierre IS NULL) THEN LET v_no_ven_cierre = 0; END IF;

	SELECT SUM(monto)
	INTO v_monto_pagos_1
	FROM bdicred:"informix".sd_movhis
	WHERE empresa = pEmpresa
	AND fecha_mov >= dFecha_ini_mp1
	AND fecha_mov <= dFecha_fin_mp1
	AND num_credito = cNumCredito
	AND codigo_fun IN (select cod_fun from bdicred:"informix".sd_conceptospagomanual WHERE cod_fun > '')
	AND codigo_ref = 1 
	AND reversado = 'N';

	IF(v_monto_pagos_1 IS NULL) THEN LET v_monto_pagos_1 = 0; END IF;

	SELECT SUM(monto)
	INTO v_monto_pagos_2
	FROM bdicred:"informix".sd_movhis
	WHERE empresa = pEmpresa
	AND fecha_mov >= dFecha_ini_mp2
	AND fecha_mov <= dFecha_fin_mp2
	AND num_credito = cNumCredito
	AND codigo_fun IN (select cod_fun from bdicred:"informix".sd_conceptospagomanual WHERE cod_fun > '')
	AND codigo_ref = 1 
	AND reversado = 'N';

	IF(v_monto_pagos_2 IS NULL) THEN LET v_monto_pagos_2 = 0; END IF;

	SELECT SUM(monto)
	INTO v_monto_pagos_3
	FROM bdicred:"informix".sd_movhis
	WHERE empresa = pEmpresa
	AND fecha_mov >= dFecha_ini_mp3
	AND fecha_mov <= dFecha_fin_mp3
	AND num_credito = cNumCredito
	AND codigo_fun IN (select cod_fun from bdicred:"informix".sd_conceptospagomanual WHERE cod_fun > '')
	AND codigo_ref = 1 
	AND reversado = 'N';

	IF(v_monto_pagos_3 IS NULL) THEN LET v_monto_pagos_3 = 0; END IF;

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
		VALUES(dFecha, TRIM(cNumcte), TRIM(cNumCredito), cNumProducto, v_no_ven_fec_lim, v_no_ven_cierre, dPagoMin, v_monto_pagos_1, v_monto_pagos_2, v_monto_pagos_3, TRIM(vCampana), vNo_sms, vNo_llamadas, "", "");
	COMMIT;

	LET iTotalaEnviar = iTotalaEnviar + 1;

	LET cNumcte, cNumCredito, cNumProducto, v_no_ven_fec_lim, v_no_ven_cierre = '', '', '', 0, 0;
	LET dPagoMin, v_monto_pagos_1, v_monto_pagos_2, v_monto_pagos_3, vCampana = 0, 0, 0, 0, '';
	LET vNo_sms, vNo_llamadas = 0, 0;
END FOREACH;

DROP TABLE cuentas_rep_tdc;

UPDATE STATISTICS MEDIUM FOR TABLE "informix".cb_report_campana_prev;

LET cSql ='if [ -f /respaldos/RepCampanaPrevTdC'||YEAR(dFecha)||MONTH(dFecha)||'01.txt.gz ]; then nice nice -n -30 rm -f /respaldos/RepCampanaPrevTdC'||YEAR(dFecha)||MONTH(dFecha)||'01.txt.gz; fi';
System cSql;

LET cSql = '';
LET cSql = 'echo "numcte|num_credito|num_producto|no_vencidos_fec_lim|no_vencidos_cierre|pago_minimo|monto_pagos_1|monto_pagos_2|monto_pagos_3|campana|no_sms|no_llamadas|" > /respaldos/RepCampanaPrevTdC'||YEAR(dFecha)||MONTH(dFecha)||'01.txt';
System cSql;

LET cSql = '';
LET cSql = 'echo "UNLOAD TO /respaldos/RepCampanaPrevTdC_aux'||YEAR(dFecha)||MONTH(dFecha)||'01.txt'|| ' DELIMITER ' || '''|'''  || ' " >> /respaldos/rep_campana_prevtdc.sql';
System cSql;

LET cSql = '';
LET cSql = 'echo "SELECT numcte, num_credito, num_producto, no_vencidos_fec_lim, no_vencidos_cierre," >> /respaldos/rep_campana_prevtdc.sql';
System cSql;

LET cSql = '';
LET cSql = 'echo "pago_minimo, monto_pagos_1, monto_pagos_2, monto_pagos_3, campana," >> /respaldos/rep_campana_prevtdc.sql';
System cSql;

LET cSql = '';
LET cSql = 'echo "no_sms, no_llamadas" >> /respaldos/rep_campana_prevtdc.sql';
System cSql;

LET cSql = '';
LET cSql = 'echo "FROM "informix".cb_report_campana_prev" >> /respaldos/rep_campana_prevtdc.sql';
System cSql;

LET cSql = '';
LET cSql = 'echo "WHERE num_producto = ' ||"'6001'"|| '" >> /respaldos/rep_campana_prevtdc.sql';
System cSql;

LET cSql = '';
LET cSql = 'echo "AND fecha = MDY(' ||MONTH(dFecha)|| ',' ||DAY(dFecha)|| ',' ||YEAR(dFecha)|| ');" >> /respaldos/rep_campana_prevtdc.sql';
System cSql;

LET cSql = '';
LET cSql='chmod 777 /respaldos/rep_campana_prevtdc.sql';
System cSql;		

LET cSql = '';
LET cSql = 'dbaccess bdicobranza /respaldos/rep_campana_prevtdc.sql';
SYSTEM cSql;		

LET cSql = '';
LET cSql ='rm /respaldos/rep_campana_prevtdc.sql';
SYSTEM cSql;

LET cSql = '';
LET cSql ='cat /respaldos/RepCampanaPrevTdC_aux'||YEAR(dFecha)||MONTH(dFecha)||'01.txt >> /respaldos/RepCampanaPrevTdC'||YEAR(dFecha)||MONTH(dFecha)||'01.txt';
SYSTEM cSql;

LET cSql = '';
LET cSql ='rm /respaldos/RepCampanaPrevTdC_aux'||YEAR(dFecha)||MONTH(dFecha)||'01.txt';
SYSTEM cSql;

LET cSql = '';
LET cSql='chmod 777 /respaldos/RepCampanaPrevTdC'||YEAR(dFecha)||MONTH(dFecha)||'01.txt';
System cSql;

LET cSql = '';
LET cSql='gzip /respaldos/RepCampanaPrevTdC'||YEAR(dFecha)||MONTH(dFecha)||'01.txt';
System cSql;

LET cSql = '';
LET cSql='chmod 777 /respaldos/RepCampanaPrevTdC'||YEAR(dFecha)||MONTH(dFecha)||'01.txt.gz';
System cSql;

--Genera cifras de control
LET cMensaje = ' ------- Cifras de Control REPORTE PREVTDC ------- ';
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

CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, P_MENSAJE, '03') RETURNING P_COD_RET;

IF P_COD_RET != '000000' THEN
	LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
	RETURN P_COD_RET,P_MENSAJE;
END IF;

END
RETURN cCodRet,P_MENSAJE;
END PROCEDURE;
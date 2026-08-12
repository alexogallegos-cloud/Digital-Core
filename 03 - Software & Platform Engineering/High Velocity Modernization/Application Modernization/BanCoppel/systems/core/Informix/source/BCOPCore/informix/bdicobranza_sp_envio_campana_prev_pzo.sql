CREATE PROCEDURE "informix".sp_envio_campana_prev_pzo(pEmpresa CHAR(3))
returning VARCHAR(06),
          VARCHAR(80);

-- EXECUTE PROCEDURE "informix".sp_envio_campana_prev_pzo('001');

DEFINE SQL_ERR					INTEGER;
DEFINE ISAM_ERR					INTEGER;
DEFINE ERROR_INFO				VARCHAR(80);
DEFINE cProceso					CHAR(4);
DEFINE P_COD_RET				VARCHAR(6);
DEFINE P_MENSAJE				VARCHAR(80);
DEFINE cCodRet  				CHAR(6);
DEFINE cMensaje  				CHAR(500);

DEFINE dFecha					DATE;
DEFINE cNumCredito				CHAR(20);
DEFINE cNumcte					CHAR(20);
DEFINE cNumProducto				CHAR(04);
DEFINE v_telcelular				VARCHAR(10);
DEFINE v_fecha_lim_pago			VARCHAR(10);
DEFINE v_prox_fecha_pago		DATE;
DEFINE vconta					INTEGER;
DEFINE vCont_sms				INTEGER;
DEFINE vBandera					CHAR(1);
DEFINE vBandera2				CHAR(1);
DEFINE dFechaInicio				INTEGER;
DEFINE v_cubrio					DECIMAL(18,2);
DEFINE v_capital_debe			DECIMAL(18,2);
DEFINE v_capital_pagado			DECIMAL(18,2);
DEFINE dFech_ini				DATE;

DEFINE iTotalCuentas			INTEGER;
DEFINE iTotalaEnviar			INTEGER;
DEFINE iTotalExcluidas			INTEGER;
DEFINE iTotalExcluidasXestar	INTEGER;
DEFINE iTotalExcluidaXpago		INTEGER;


BEGIN 
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
     LET P_COD_RET = SQL_ERR;
     LET P_MENSAJE = 'Error al ejecutar el proceso. '||cNumCredito;
     CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, P_COD_RET, P_MENSAJE, '02')
     RETURNING P_COD_RET;
     LET P_COD_RET = SQL_ERR;

     RETURN P_COD_RET,P_MENSAJE;
   END EXCEPTION;

--SET DEBUG FILE TO "sp_envio_campana_prev_pzo.out";
--TRACE ON;

LET cProceso            	= '2055';
LET P_COD_RET           	= '000000';
LET cCodRet           		= '000000';
LET P_MENSAJE           	= 'El proceso de ENVIO CAMPANA PREVPP se ejecuto correctamente.';
LET cMensaje				= '';

LET dFecha					= DATE(1);
LET cNumCredito				= '';
LET cNumcte					= '';
LET cNumProducto			= '';
LET v_fecha_lim_pago		= '';
LET v_prox_fecha_pago		= DATE(1);
LET vconta					= 0;
LET vCont_sms				= 0;
LET vBandera				= '';
LET vBandera2				= '';
LET dFechaInicio			= 0;
LET v_cubrio				= 0;
LET v_capital_debe			= 0;
LET v_capital_pagado		= 0;
LET dFech_ini				= DATE(1);

LET iTotalCuentas 			= 0;
LET iTotalaEnviar			= 0;
LET iTotalExcluidas			= 0;
LET iTotalExcluidasXestar	= 0;
LET iTotalExcluidaXpago		= 0;


CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, P_MENSAJE, '01')
    RETURNING P_COD_RET;

IF P_COD_RET != '000000' THEN
   LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
   RETURN P_COD_RET,P_MENSAJE;
END IF;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT fecha_hoy INTO dFecha FROM bdicred:"informix".sd_fechas WHERE empresa = pEmpresa;

IF(DAY(dFecha) >= 1 AND DAY(dFecha) <= 5) THEN
	LET dFechaInicio = 1;
ELIF(DAY(dFecha) >= 6 AND DAY(dFecha) <= 10) THEN
	LET dFechaInicio = 6;
ELIF(DAY(dFecha) >= 11 AND DAY(dFecha) <= 15) THEN
	LET dFechaInicio = 11;
ELIF(DAY(dFecha) >= 16 AND DAY(dFecha) <= 20) THEN
	LET dFechaInicio = 16;
ELIF(DAY(dFecha) >= 21 AND DAY(dFecha) <= 25) THEN
	LET dFechaInicio = 21;
ELIF(DAY(dFecha) >= 26 AND DAY(dFecha) <= 31) THEN
	LET dFechaInicio = 26;
END IF;

SELECT a.num_credito, b.numcte, a.telcelular, a.num_producto, c.prox_fecha_pago
FROM "informix".cb_campana_prev_sms a
INNER JOIN bdicred:"informix".sd_maecredcrd b ON (b.num_credito = a.num_credito AND b.num_producto IN ('6300','7600','7700') AND b.status_cred IN ('AA','E1') AND b.fecha_apertura > dFech_ini)
INNER JOIN bdicred:"informix".sd_maecredanexocrd c ON (c.num_credito = a.num_credito AND c.dia_corte = day(dFechaInicio))
INNER JOIN bdicred:"informix".sd_maesdoscrd d ON (d.num_credito = a.num_credito AND (d.monto_vencido + d.mto_venc_trasp) = 0)
WHERE a.num_producto IN ('6300','7600','7700')
UNION ALL
SELECT a.num_credito, b.numcte, a.telcelular, a.num_producto, c.prox_fecha_pago
FROM "informix".cb_campana_prev a
INNER JOIN bdicred:"informix".sd_maecredcrd b ON (b.num_credito = a.num_credito AND b.num_producto IN ('6300','7600','7700') AND b.status_cred IN ('AA','E1') AND b.fecha_apertura > dFech_ini)
INNER JOIN bdicred:"informix".sd_maecredanexocrd c ON (c.num_credito = a.num_credito AND c.dia_corte = day(dFechaInicio))
INNER JOIN bdicred:"informix".sd_maesdoscrd d ON (d.num_credito = a.num_credito AND (d.monto_vencido + d.mto_venc_trasp) = 0)
WHERE a.num_producto IN ('6300','7600','7700')
INTO TEMP cuentas_sms_pp WITH NO LOG;

CREATE INDEX inx_productos_sms_pp ON cuentas_sms_pp(num_producto) in dbs_movhis_idx3;
CREATE INDEX inx_ctecred_sms_pp ON cuentas_sms_pp(num_credito) in dbs_movhis_idx3;
UPDATE STATISTICS MEDIUM FOR TABLE cuentas_sms_pp;

FOREACH WITH HOLD
	SELECT UNIQUE(num_credito), numcte, telcelular, num_producto, prox_fecha_pago
	INTO cNumCredito, cNumcte, v_telcelular, cNumProducto, v_prox_fecha_pago
	FROM cuentas_sms_pp
	WHERE num_producto IN ('6300','7600','7700')

	LET iTotalCuentas = iTotalCuentas + 1;

	SELECT FIRST 1 '1'
	INTO vBandera
	FROM "informix".cb_campana_prev_sms
	WHERE campana = 'SMS'
	AND procesar = '1'
	AND num_credito = cNumCredito;

	IF vBandera = '1' THEN
		LET	iTotalExcluidasXestar = iTotalExcluidasXestar + 1;
		CONTINUE FOREACH;
	ELSE
		IF(v_telcelular = '') OR (v_telcelular IS NULL) THEN
			LET	iTotalExcluidas = iTotalExcluidas + 1;
			CONTINUE FOREACH;
		ELSE
			SELECT capital_debe, capital_pagado
			INTO v_capital_debe, v_capital_pagado
			FROM bdicred:"informix".sd_amortiza_creditocrd
			WHERE num_credito = cNumCredito
			AND fecha_cuota = dFecha;

			IF (v_capital_debe IS NULL) OR (v_capital_debe = "") THEN LET v_capital_debe = 0; END IF;

			IF (v_capital_pagado IS NULL) OR (v_capital_pagado = "") THEN LET v_capital_pagado = 0; END IF;

			LET v_cubrio = v_capital_debe - v_capital_pagado;

			IF(v_prox_fecha_pago IS NULL) THEN LET v_prox_fecha_pago = DATE(1); END IF;

			LET v_fecha_lim_pago = TO_CHAR(v_prox_fecha_pago,'%d/%m/%Y');

			IF (v_cubrio > 0) THEN
				CALL bdimnsj:"informix".sp_registra_evento('2','COBRA_SMS','PP_PAGCOMS',cNumcte,cNumCredito,'','2',
													v_fecha_lim_pago,'','','','',
													'','','','','',
													'',v_telcelular,0,0,0,0,0,'','') RETURNING P_COD_RET;

				IF P_COD_RET != '00000' THEN
					LET P_MENSAJE  = 'Error en el llamado al sp_registra_evento. '||cNumCredito;
					RETURN P_COD_RET,P_MENSAJE;
				END IF;

				/*CALL "informix".sp_inserta_info_rep_envios (pEmpresa,'SMS',26, cNumCredito, cNumcte, cNumProducto, TODAY, '', cStatusSituacion,cMotivoExclusion,dPagoMinimo) returning P_COD_RET;

				IF P_COD_RET != '000000' THEN
					LET P_MENSAJE  = 'Error en el llamado al sp_inserta_info_rep_envios. '||cNumCredito;
					RETURN P_COD_RET,P_MENSAJE;
				END IF;*/

				LET iTotalaEnviar = iTotalaEnviar + 1;
				
				SELECT COUNT(num_credito)
				INTO vConta
				FROM cuentas_sms_pp
				WHERE num_credito = cNumCredito
				AND num_producto = cNumProducto;
				
				IF (vConta IS NULL) THEN LET vConta = 0; END IF;
				
				IF(vConta > 1) THEN
					SELECT cont_sms
					INTO vCont_sms
					FROM "informix".cb_campana_prev_sms
					WHERE num_credito = cNumCredito
					AND num_producto = cNumProducto;

					IF (vCont_sms IS NULL) THEN LET vCont_sms = 0; END IF;

					IF(vCont_sms > 1) THEN
						LET vCont_sms = 2;
					ELSE
						LET vCont_sms = 1;
					END IF;

					BEGIN WORK;
						UPDATE "informix".cb_campana_prev_sms
							SET numcte = cNumcte,
								cont_sms = vCont_sms
						WHERE num_credito = cNumCredito
						AND num_producto = cNumProducto;
					COMMIT WORK;
				ELSE
					SELECT FIRST 1 '1'
					INTO vBandera2
					FROM "informix".cb_campana_prev_sms
					WHERE num_credito = cNumCredito
					AND num_producto = cNumProducto;

					IF(vBandera2 = '1') THEN
						SELECT cont_sms
						INTO vCont_sms
						FROM "informix".cb_campana_prev_sms
						WHERE num_credito = cNumCredito
						AND num_producto = cNumProducto;

						IF (vCont_sms IS NULL) THEN LET vCont_sms = 0; END IF;

						IF(vCont_sms > 1) THEN
							LET vCont_sms = 2;
						ELSE
							LET vCont_sms = 1;
						END IF;

						BEGIN WORK;
							UPDATE "informix".cb_campana_prev_sms
								SET numcte = cNumcte,
									cont_sms = vCont_sms
							WHERE num_credito = cNumCredito
							AND num_producto = cNumProducto;
						COMMIT WORK;
					ELSE
						SELECT cont_sms
						INTO vCont_sms
						FROM "informix".cb_campana_prev
						WHERE num_credito = cNumCredito
						AND num_producto = cNumProducto;

						IF (vCont_sms IS NULL) THEN LET vCont_sms = 0; END IF;

						IF(vCont_sms > 1) THEN
							LET vCont_sms = 2;
						ELSE
							LET vCont_sms = 1;
						END IF;

						BEGIN WORK;
							UPDATE "informix".cb_campana_prev
								SET numcte = cNumcte,
									cont_sms = vCont_sms
							WHERE num_credito = cNumCredito
							AND num_producto = cNumProducto;
						COMMIT WORK;
					END IF;
				END IF;
			ELSE
				LET	iTotalExcluidaXpago = iTotalExcluidaXpago + 1;
			END IF;
		END IF;
	END IF;

	LET cNumcte, v_telcelular, cNumProducto, cNumCredito, v_fecha_lim_pago, vCont_sms, vBandera, vBandera2 = '', '', '', '', DATE(1), 0, '', '';
	LET v_prox_fecha_pago, v_capital_debe, v_capital_pagado, v_cubrio = DATE(1), 0, 0, 0;
END FOREACH;

DROP TABLE cuentas_sms_pp;

--Genera cifras de control
LET cMensaje = ' ------- Cifras de Control campana PP_PAGCOMS ------- ';
CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

LET cMensaje = '';
LET cMensaje = 'TOTAL Cuentas procesadas : ' ||iTotalCuentas;
LET cMensaje = TRIM(cMensaje)||'   Cuentas a enviar PP_PAGCOMS : ' ||iTotalaEnviar;
CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
LET cMensaje = '';
LET cMensaje = 'Cuentas excluidas X CEL NO VALIDO : ' ||iTotalExcluidas;
LET cMensaje = TRIM(cMensaje)||'   Cuentas excluidas X PAGO MINIMO : ' ||iTotalExcluidaXpago;
CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
LET cMensaje = '';
LET cMensaje = 'Cuentas excluidas X DOBLE SMS : ' ||iTotalExcluidasXestar;
CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
LET cMensaje = '';
--Genera cifras de control

LET cMensaje 				= '';
LET iTotalCuentas 			= 0;
LET iTotalaEnviar			= 0;
LET iTotalExcluidas			= 0;
LET iTotalExcluidaXpago		= 0;
LET iTotalExcluidasXestar	= 0;

-----------------------------------------------------------------
-- Genera envio de la campana PP_PAGCOMS
-----------------------------------------------------------------
FOREACH WITH HOLD
	SELECT b.numcte, a.telcelular, a.num_producto, a.num_credito, a.fecha_lim_pago, a.cont_sms
	INTO cNumcte, v_telcelular, cNumProducto, cNumCredito, v_fecha_lim_pago, vCont_sms
	FROM "informix".cb_campana_prev_sms a
	INNER JOIN bdicred:"informix".sd_maecredcrd b ON (b.num_credito = a.num_credito)
	WHERE a.campana = 'SMS'
	AND a.procesar = '1'
	AND a.num_producto IN ('6300','7600','7700')

	LET iTotalCuentas = iTotalCuentas + 1;

	CALL bdimnsj:"informix".sp_registra_evento('2','COBRA_SMS','PP_PAGCOMS',cNumcte,cNumCredito,'','2',
												v_fecha_lim_pago,'','','','',
												'','','','','',
												'',v_telcelular,0,0,0,0,0,'','') RETURNING P_COD_RET;

	IF P_COD_RET != '00000' THEN
		LET P_MENSAJE  = 'Error en el llamado al sp_registra_evento. '||cNumCredito;
		RETURN P_COD_RET,P_MENSAJE;
	END IF;

	IF(vCont_sms > 1) THEN
		LET vCont_sms = 2;
	ELSE
		LET vCont_sms = 1;
	END IF;

	BEGIN WORK;
		UPDATE "informix".cb_campana_prev_sms
			SET numcte = cNumcte,
				procesar = '0',
				cont_sms = vCont_sms
		WHERE num_credito = cNumCredito
		AND num_producto = cNumProducto;
	COMMIT WORK;

/*		CALL "informix".sp_inserta_info_rep_envios (pEmpresa,'SMS',26, cNumCredito, cNumcte, cNumProducto, TODAY, '', cStatusSituacion,cMotivoExclusion,dPagoMinimo) returning P_COD_RET;

	IF P_COD_RET != '000000' THEN
		LET P_MENSAJE  = 'Error en el llamado al sp_inserta_info_rep_envios. '||cNumCredito;
		RETURN P_COD_RET,P_MENSAJE;
	END IF;*/

	LET iTotalaEnviar = iTotalaEnviar + 1;

	LET cNumcte, v_telcelular, cNumProducto, cNumCredito, v_fecha_lim_pago, vCont_sms = '', '', '', '', DATE(1), 0;
END FOREACH;

--Genera cifras de control
LET cMensaje = ' ------- Cifras de Control campana PP_PAGCOMS ------- ';
CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

LET cMensaje = '';
LET cMensaje = 'TOTAL Cuentas procesadas : ' ||iTotalCuentas;
CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
LET cMensaje = '';
LET cMensaje = 'Cuentas a enviar PP_PAGCOMS: ' ||iTotalaEnviar;
CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
--Genera cifras de control

LET cMensaje 				= '';
LET iTotalCuentas 			= 0;
LET iTotalaEnviar			= 0;

CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, P_MENSAJE, '03') RETURNING P_COD_RET;

IF P_COD_RET != '000000' THEN
	LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
	RETURN P_COD_RET,P_MENSAJE;
END IF;

END
RETURN cCodRet,P_MENSAJE;
END PROCEDURE;
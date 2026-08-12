CREATE PROCEDURE "informix".sp_envio_campana_prev_rev(pEmpresa CHAR(3))
returning VARCHAR(06),
          VARCHAR(80);

-- EXECUTE PROCEDURE "informix".sp_envio_campana_prev_rev('001');

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
DEFINE dPagoMin					DECIMAL(18,2);
DEFINE vCont_sms				INTEGER;
DEFINE vConta					INTEGER;
DEFINE vCampana					CHAR(3);
DEFINE dTotalLiq				DECIMAL(18,2);
DEFINE vBandera					CHAR(1);
DEFINE vBandera2				CHAR(1);

DEFINE iTotalCuentas			INTEGER;
DEFINE iTotalaEnviar			INTEGER;
DEFINE iTotalExcluidas			INTEGER;
--DEFINE iTotalExcluidaXpago		INTEGER;
DEFINE dFech_ini				DATE;


BEGIN 
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
     LET P_COD_RET = SQL_ERR;
     LET P_MENSAJE = 'Error al ejecutar el proceso. '||cNumCredito;
     CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, P_COD_RET, P_MENSAJE, '02')
     RETURNING P_COD_RET;
     LET P_COD_RET = SQL_ERR;

     RETURN P_COD_RET,P_MENSAJE;
   END EXCEPTION;

--SET DEBUG FILE TO "sp_envio_campana_prev_rev.out";
--TRACE ON;

LET cProceso            	= '2053';
LET P_COD_RET           	= '000000';
LET cCodRet           		= '000000';
LET P_MENSAJE           	= 'El proceso de ENVIO CAMPANA PREVTDC se ejecuto correctamente.';
LET cMensaje				= '';

LET dFecha					= DATE(1);
LET cNumCredito				= '';
LET cNumcte					= '';
LET cNumProducto			= '';
LET dPagoMin				= 0;
LET vCont_sms				= 0;
LET vConta					= 0;
LET vCampana				= '';
LET dTotalLiq				= 0;
LET vBandera				= '';
LET vBandera2				= '';

LET iTotalCuentas 			= 0;
LET iTotalaEnviar			= 0;
LET iTotalExcluidas			= 0;
--LET iTotalExcluidaXpago		= 0;
LET dFech_ini				= DATE(1);


CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, P_MENSAJE, '01')
    RETURNING P_COD_RET;

IF P_COD_RET != '000000' THEN
   LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
   RETURN P_COD_RET,P_MENSAJE;
END IF;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT fecha_hoy INTO dFecha FROM bdicred:"informix".sd_fechas WHERE empresa = pEmpresa;

IF (DAY(dFecha) = 15) THEN
-----------------------------------------------------------------
-- Genera envio de la campana TCC_PREV
-----------------------------------------------------------------
	FOREACH WITH HOLD
		SELECT a.numcte, a.telcelular, a.num_credito, a.pago_minimo, a.cont_sms
		INTO cNumcte, v_telcelular, cNumCredito, dPagoMin, vCont_sms
		FROM "informix".cb_campana_prev_sms a
		--INNER JOIN bdicred:"informix".sd_maecred b ON (b.empresa = pEmpresa AND b.num_credito = a.num_credito)
		WHERE a.campana = 'SMS'
		AND a.procesar = '1'
		AND a.num_producto = '6001'

		LET iTotalCuentas = iTotalCuentas + 1;

		CALL bdimnsj:"informix".sp_registra_evento('2','COBRA_SMS','TCC_PREV',cNumcte,cNumCredito,'','2',
													'','','','','',
													'','','','','',
													'',v_telcelular,dPagoMin,0,0,0,0,'','') RETURNING P_COD_RET;

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
			WHERE num_credito = cNumCredito;
		COMMIT WORK;

/*		CALL "informix".sp_inserta_info_rep_envios (pEmpresa,'SMS',26, cNumCredito, cNumcte, cNumProducto, TODAY, '', cStatusSituacion,cMotivoExclusion,dPagoMinimo) returning P_COD_RET;

		IF P_COD_RET != '000000' THEN
			LET P_MENSAJE  = 'Error en el llamado al sp_inserta_info_rep_envios. '||cNumCredito;
			RETURN P_COD_RET,P_MENSAJE;
		END IF;*/

		LET iTotalaEnviar = iTotalaEnviar + 1;

		LET cNumcte, v_telcelular, cNumCredito, dPagoMin, vCont_sms = '', '', '', 0, 0;
	END FOREACH;

	--Genera cifras de control
	LET cMensaje = ' ------- Cifras de Control campana TCC_PREV ------- ';
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

	LET cMensaje = '';
	LET cMensaje = 'TOTAL Cuentas procesadas : ' ||iTotalCuentas;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = '';
	LET cMensaje = 'Cuentas a enviar TCC_PREV: ' ||iTotalaEnviar;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	--Genera cifras de control

	LET cMensaje 				= '';
	LET iTotalCuentas 			= 0;
	LET iTotalaEnviar			= 0;
ELIF (DAY(dFecha) = 20) THEN
-----------------------------------------------------------------
-- Genera envio de la campana TCB_PAGMIS
-----------------------------------------------------------------
	SELECT a.num_credito, b.numcte, a.telcelular, a.num_producto, d.monto_financiado
	FROM "informix".cb_campana_prev_sms a
	INNER JOIN bdicred:"informix".sd_maecred b ON (b.empresa = pEmpresa AND b.num_credito = a.num_credito AND b.status_cred IN ('AA','E1') AND b.fecha_apertura > dFech_ini)
	INNER JOIN bdicred:"informix".sd_maesdos d ON (d.num_credito = a.num_credito AND d.monto_financiado > 0 AND (d.monto_vencido + d.mto_venc_trasp) = 0)
	WHERE a.num_producto = '6001'
	UNION ALL
	SELECT a.num_credito, b.numcte, a.telcelular, a.num_producto, d.monto_financiado
	FROM "informix".cb_campana_prev a
	INNER JOIN bdicred:"informix".sd_maecred b ON (b.empresa = pEmpresa AND b.num_credito = a.num_credito AND b.status_cred IN ('AA','E1') AND b.fecha_apertura > dFech_ini)
	INNER JOIN bdicred:"informix".sd_maesdos d ON (d.num_credito = a.num_credito AND d.monto_financiado > 0 AND (d.monto_vencido + d.mto_venc_trasp) = 0)
	WHERE a.num_producto = '6001'
	INTO TEMP cuentas_sms_tdc WITH NO LOG;

	CREATE INDEX inx_producto_sms_tdc ON cuentas_sms_tdc(num_producto) in dbs_movhis_idx3;
	CREATE INDEX inx_cred_sms_tdc ON cuentas_sms_tdc(num_credito) in dbs_movhis_idx3;
	UPDATE STATISTICS MEDIUM FOR TABLE cuentas_sms_tdc;

	FOREACH WITH HOLD
		SELECT UNIQUE(num_credito), numcte, telcelular, monto_financiado
		INTO cNumCredito, cNumcte, v_telcelular, dPagoMin
		FROM cuentas_sms_tdc
		WHERE num_producto = '6001'

		LET iTotalCuentas = iTotalCuentas + 1;

		IF(v_telcelular = '') OR (v_telcelular IS NULL) THEN
			LET	iTotalExcluidas = iTotalExcluidas + 1;
			CONTINUE FOREACH;
		ELSE
/*			SELECT monto_financiado
			INTO dPagoMin
			FROM bdicred:"informix".sd_maesdos
			WHERE empresa = pEmpresa
			AND num_credito = cNumCredito;
			
			IF(dPagoMin IS NULL) THEN LET dPagoMin = 0; END IF;*/

--			IF (dPagoMin > 0) THEN
				CALL bdimnsj:"informix".sp_registra_evento('2','COBRA_SMS','TCB_PAGMIS',cNumcte,cNumCredito,'','2',
													'','','','','',
													'','','','','',
													'',v_telcelular,dPagoMin,0,0,0,0,'','') RETURNING P_COD_RET;

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
				FROM cuentas_sms_tdc
				WHERE num_credito = cNumCredito;
				
				IF (vConta IS NULL) THEN LET vConta = 0; END IF;
				
				IF(vConta > 1) THEN
					SELECT cont_sms
					INTO vCont_sms
					FROM "informix".cb_campana_prev_sms
					WHERE num_credito = cNumCredito;

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
						WHERE num_credito = cNumCredito;
					COMMIT WORK;
				ELSE
					SELECT FIRST 1 '1'
					INTO vBandera2
					FROM "informix".cb_campana_prev_sms
					WHERE num_credito = cNumCredito;

					IF(vBandera2 = '1') THEN
						SELECT cont_sms
						INTO vCont_sms
						FROM "informix".cb_campana_prev_sms
						WHERE num_credito = cNumCredito;

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
							WHERE num_credito = cNumCredito;
						COMMIT WORK;
					ELSE
						SELECT cont_sms
						INTO vCont_sms
						FROM "informix".cb_campana_prev
						WHERE num_credito = cNumCredito;

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
							WHERE num_credito = cNumCredito;
						COMMIT WORK;
					END IF;
				END IF;
/*			ELSE
				LET	iTotalExcluidaXpago = iTotalExcluidaXpago + 1;
			END IF;*/
		END IF;

		LET cNumcte, v_telcelular, cNumCredito, dPagoMin, vCont_sms, vBandera, vBandera2 = '', '', '', 0, 0, '', '';
	END FOREACH;

	DROP TABLE cuentas_sms_tdc;

	--Genera cifras de control
	LET cMensaje = ' ------- Cifras de Control campana TCB_PAGMIS ------- ';
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

	LET cMensaje = '';
	LET cMensaje = 'TOTAL Cuentas procesadas : ' ||iTotalCuentas;
	LET cMensaje = TRIM(cMensaje)||'   Cuentas a enviar TCB_PAGMIS : ' ||iTotalaEnviar;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = '';
	LET cMensaje = 'Cuentas excluidas X CEL NO VALIDO : ' ||iTotalExcluidas;
--	LET cMensaje = TRIM(cMensaje)||'   Cuentas excluidas X PAGO MINIMO : ' ||iTotalExcluidaXpago;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	--Genera cifras de control

	LET cMensaje 				= '';
	LET iTotalCuentas 			= 0;
	LET iTotalaEnviar			= 0;
	LET iTotalExcluidas			= 0;
--	LET iTotalExcluidaXpago		= 0;
ELSE
	LET cMensaje = 'Fecha de ejecución no valida';
	LET cCodRet = '000001';
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	RETURN cCodRet,cMensaje;
END IF;

CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, P_MENSAJE, '03') RETURNING P_COD_RET;

IF P_COD_RET != '000000' THEN
	LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
	RETURN P_COD_RET,P_MENSAJE;
END IF;

END
RETURN cCodRet,P_MENSAJE;
END PROCEDURE;
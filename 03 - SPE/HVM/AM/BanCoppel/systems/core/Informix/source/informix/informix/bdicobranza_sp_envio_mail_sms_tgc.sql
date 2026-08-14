CREATE PROCEDURE "informix".sp_envio_mail_sms_tgc(pempresa CHAR(3))
RETURNING 	
CHAR(06)  AS codigo_retorno,
CHAR(150)  AS mensaje_retorno;
-------------------------------------------------------------------------------------------------------------

---DECLARACIONES
DEFINE cCodRet						CHAR(6); 
DEFINE iSqlErr						INTEGER;
DEFINE isam_err						INTEGER;
DEFINE error_info					CHAR(150);
DEFINE P_COD_RET					CHAR(06);
DEFINE P_MENSAJE					CHAR(150);
DEFINE cMensaje						VARCHAR(150);
DEFINE vproceso         			CHAR(4);

DEFINE dtFechaHoy					DATE;
DEFINE vpri_dia_mes					DATE;
DEFINE cNumCred						CHAR(20);
DEFINE cNumCte						CHAR(20);
DEFINE vnumprod						CHAR(4);
DEFINE mtoVencido					DECIMAL(18,2);
DEFINE v_monto_vencido				DECIMAL(18,2);
DEFINE v_mto_venc_trasp				DECIMAL(18,2);
DEFINE v_monto_financiado			DECIMAL(18,2);
DEFINE v_sdo_moratorio				DECIMAL(18,2);
DEFINE v_sdo_contab_mora			DECIMAL(18,2);
DEFINE v_sucursal					CHAR(4);
DEFINE v_interes_iva				DECIMAL(18,2);
DEFINE v_iva						DECIMAL(5,3);
DEFINE v_moratorio					DECIMAL(18,2);
DEFINE v_sdo_venc_int_mora			DECIMAL(18,2);
DEFINE vMensualidad					DECIMAL(18,2);
DEFINE vpago_minimo_total			DECIMAL(18,2);
DEFINE vPagoVenc					CHAR(10);
DEFINE vfechapago					DATE;

DEFINE iCuentasProcesadas			INTEGER;
DEFINE iCount_TGC_PREVEN			INTEGER;
DEFINE iCount_TGC_MORAS1			INTEGER;
DEFINE iCount_TGC_MORAS2			INTEGER;
DEFINE iCount_TGC_MORAS1S			INTEGER;
DEFINE iCount_TGC_MORAS2S			INTEGER;
DEFINE iCount_TGC_ULTAVPA 			INTEGER;
DEFINE iCount_TGC_PAGCOMS 			INTEGER;
DEFINE iCuentasExcluidasXPagoMin 	INTEGER;


---INICIALIZACIONES
LET cCodRet 						= "000000";
LET iSqlErr 						= 0;
LET isam_err 						= 0;
LET error_info						= "";
LET P_COD_RET 						= "000000";
LET P_MENSAJE 						= 'El proceso de las campaÃ±as EMAILs y SMS TGC se realizÃ³ correctamente.';
LET cMensaje 						= '';
LET vproceso 						= '0067';


LET dtFechaHoy						= DATE(1);
LET vpri_dia_mes					= DATE(1);
LET cNumCred						= "";
LET cNumCte							= "";
LET vnumprod 						= "";
LET mtoVencido 						= 0;
LET v_monto_vencido 				= 0;
LET v_mto_venc_trasp 				= 0;
LET v_monto_financiado 				= 0;
LET v_sdo_moratorio 				= 0;
LET v_sdo_contab_mora 				= 0;
LET v_sucursal 						= "";
LET v_interes_iva 					= 0;
LET v_iva 							= 0;
LET v_moratorio 					= 0;
LET v_sdo_venc_int_mora 			= 0;
LET vMensualidad 					= 0;
LET vpago_minimo_total 				= 0;
LET vPagoVenc 						= "";
LET vfechapago						= DATE(1);

LET iCuentasProcesadas 				= 0;
LET iCount_TGC_PREVEN 				= 0;
LET iCount_TGC_MORAS1 				= 0;
LET iCount_TGC_MORAS2 				= 0;
LET iCount_TGC_MORAS1S 				= 0;
LET iCount_TGC_MORAS2S 				= 0;
LET iCount_TGC_ULTAVPA 				= 0;
LET iCount_TGC_PAGCOMS 				= 0;
LET iCuentasExcluidasXPagoMin 		= 0;



BEGIN

ON EXCEPTION SET iSqlErr
--ON EXCEPTION SET iSqlErr, isam_err, error_info
    LET cCodRet= iSqlErr;
    LET P_COD_RET= iSqlErr;
    LET P_MENSAJE = 'Error al ejecutar el proceso.';
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '02')RETURNING cCodRet; 
    RETURN P_COD_RET,P_MENSAJE;
END EXCEPTION;

--SET DEBUG FILE TO 'sp_envio_mail_sms_tgc.out';
--TRACE ON;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '01')RETURNING cCodRet; 

     if cCodRet != '000000' then
        let P_COD_RET = cCodRet;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;

	SELECT fecha_hoy, pri_dia_mes
	INTO dtFechaHoy, vpri_dia_mes
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = '001';

--temporal solo para pruebas
-- LET dtFechaHoy = mdy('09','30','2014');
-- LET vpri_dia_mes = mdy('09','01','2014');
--temporal solo para pruebas
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION DIRTY READ;

	IF (DAY(dtFechaHoy) = 9) THEN
		FOREACH	WITH HOLD
			SELECT a.numcte, a.num_credito, a.num_producto
				INTO cNumCte, cNumCred, vnumprod
			FROM bdicred:"informix".sd_maecred a
			INNER JOIN bdicred:"informix".sd_maesdos b ON (b.empresa = a.empresa AND b.num_credito = a.num_credito)
			WHERE a.empresa = pempresa
				AND a.num_credito > ''
				AND a.status_cred IN ('AA','E1')
				AND b.monto_vencido + b.mto_venc_trasp = 0
				AND a.campo_trab3 <> 'BAJA'
				AND a.num_producto = '8500'
				AND b.monto_financiado > 0

			let iCuentasProcesadas = iCuentasProcesadas + 1;

			CALL bdimnsj:"informix".sp_registra_evento('1','COBRA_MAIL','TGC_PREVENT',cNumcte,cNumCred,'','2',
						'','','','','','','','','','','','',0,0,0,0,0,TODAY,'') RETURNING cCodRet;

			LET iCount_TGC_PREVEN = iCount_TGC_PREVEN + 1;
		END FOREACH;

		--Genera cifras de control
		if iCuentasProcesadas > 0 then
		   let cMensaje = 'TOTAL Cuentas procesadas campaÃ±a EMAILs PREVENTIVA TC ORO : ' ||iCuentasProcesadas;
		   let cMensaje = trim(cMensaje) ||'    EMAILs enviados PREVENTIVA : ' ||iCount_TGC_PREVEN;
		   CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, trim(cMensaje), '02') RETURNING cCodRet;
		end if;
		--Genera cifras de control

		LET iCuentasProcesadas = 0;
	END IF;
	
	FOREACH	WITH HOLD
		SELECT a.num_credito, a.numcte, b.mto_fin_ven_trasp, b.monto_vencido, b.mto_venc_trasp, monto_financiado, b.sdo_moratorio, b.sdo_contab_mora, a.num_producto, a.sucursal
			INTO cNumCred, cNumcte, mtoVencido, v_monto_vencido, v_mto_venc_trasp, v_monto_financiado, v_sdo_moratorio, v_sdo_contab_mora, vnumprod, v_sucursal
		FROM bdicred:sd_maecred a
		INNER JOIN bdicred:sd_maesdos b ON (b.empresa = a.empresa AND b.num_credito = a.num_credito)
		WHERE a.empresa = pempresa
			AND a.num_credito > ''
			AND a.status_cred IN ('BT','BA','E1','E2','E3')
			AND b.monto_vencido + b.mto_venc_trasp > 0
			AND a.num_producto = '8500'
			AND a.campo_trab3 <> 'BAJA'
			AND b.mto_fin_ven_trasp >= 1 AND b.mto_fin_ven_trasp <= 2

		LET iCuentasProcesadas = iCuentasProcesadas + 1;

		SELECT SUM(interes_debe - interes_pagado) + SUM(iva_debe - iva_pagado)
		INTO v_interes_iva
		from bdicred:"informix".sd_amortiza_credito
		WHERE empresa = pempresa
		AND num_credito = cNumCred
		AND capital_status IN ('2','7','6');

		IF v_interes_iva IS NULL THEN LET v_interes_iva = 0; END IF;

		SELECT iva
		INTO v_iva
		FROM bdinteg:"informix".si_sucursales
		WHERE empresa = pempresa
		AND sucursal = v_sucursal;

		IF v_iva IS NULL THEN LET v_iva = 0; END IF;

		LET v_moratorio = round((v_sdo_moratorio + v_sdo_contab_mora) * (1 + v_iva),2);

		LET v_sdo_venc_int_mora = (v_monto_vencido + v_mto_venc_trasp + v_moratorio + v_interes_iva);

		LET vMensualidad = (v_monto_financiado - v_monto_vencido - v_mto_venc_trasp);
		
		LET vpago_minimo_total = v_sdo_venc_int_mora + vMensualidad;

		IF (mtoVencido = 1) THEN LET vPagoVenc = 'primer';
		ELIF (mtoVencido = 2) THEN LET vPagoVenc = 'segundo'; END IF;

		IF(mtoVencido = 1) THEN
			IF (weekday(dtFechaHoy) = 1) THEN
				CALL bdimnsj:"informix".sp_registra_evento('1','COBRA_MAIL','TGC_MORA1',cNumcte,cNumCred,'','2',
						'',vPagoVenc,'','','','','','','','','','',0,0,0,0,0,TODAY,'') RETURNING cCodRet;

				LET iCount_TGC_MORAS1 = iCount_TGC_MORAS1 + 1;
			END IF;
			
			IF vpago_minimo_total <= 0 THEN LET iCuentasExcluidasXPagoMin = iCuentasExcluidasXPagoMin + 1; CONTINUE FOREACH; END IF;

			CALL bdimnsj:"informix".sp_registra_evento('2','COBRA_SMS','TGC_MORAS1S',cNumcte,cNumCred,'','2',
					'','','','','','','','','','','','',vpago_minimo_total,0,0,0,0,TODAY,'') RETURNING cCodRet;

			LET iCount_TGC_MORAS1S = iCount_TGC_MORAS1S + 1;
		ELIF(mtoVencido = 2) THEN
			IF (weekday(dtFechaHoy) = 1) THEN
				CALL bdimnsj:"informix".sp_registra_evento('1','COBRA_MAIL','TGC_MORA2',cNumcte,cNumCred,'','2',
						'',vPagoVenc,'','','','','','','','','','',0,0,0,0,0,TODAY,'') RETURNING cCodRet;

				LET iCount_TGC_MORAS2 = iCount_TGC_MORAS2 + 1;
			END IF;

			CALL bdimnsj:"informix".sp_registra_evento('2','COBRA_SMS','TGC_MORAS2S',cNumcte,cNumCred,'','2',
					'','','','','','','','','','','','',vpago_minimo_total,0,0,0,0,TODAY,'') RETURNING cCodRet;

			LET iCount_TGC_MORAS2S = iCount_TGC_MORAS2S + 1;
		ELIF (mtoVencido >= 3) AND (weekday(dtFechaHoy) = 1) THEN
			CALL bdimnsj:"informix".sp_registra_evento('1','COBRA_MAIL','TGC_MORAS2S',cNumcte,cNumCred,'','2',
					'','','','','','','','','','','','',mtoVencido,0,0,0,0,TODAY,'') RETURNING cCodRet;

			LET iCount_TGC_MORAS2S = iCount_TGC_MORAS2S + 1;
		END IF;
	END FOREACH;

	--Genera cifras de control
	IF iCuentasProcesadas > 0 THEN
	   LET cMensaje = 'TOTAL Cuentas procesadas campaÃ±a EMAILs y SMS MORAS TC ORO : ' ||iCuentasProcesadas;
	   CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCodRet;
	   LET cMensaje = '';
	   LET cMensaje = 'EMAILs enviados MORA 1 : ' ||iCount_TGC_MORAS1;
	   LET cMensaje = TRIM(cMensaje) ||'    SMS enviados MORA 1 : ' ||iCount_TGC_MORAS1S;
	   CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCodRet;
	   LET cMensaje = '';
	   LET cMensaje = 'EMAILs enviados MORA 2 : ' ||iCount_TGC_MORAS2;
	   LET cMensaje = TRIM(cMensaje) ||'    SMS enviados MORA 2 : ' ||iCount_TGC_MORAS2S;
	   CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCodRet;
	   LET cMensaje = '';
	   LET cMensaje = 'EXCLUIDOS X PAGO MINIMO MENOS 0 : ' ||iCuentasExcluidasXPagoMin;
	   LET cMensaje = TRIM(cMensaje) ||'    EMAILs enviados ULTAVPA : ' ||iCount_TGC_ULTAVPA;
	   CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCodRet;
	END IF;
	--Genera cifras de control

	LET iCuentasProcesadas = 0;

	FOREACH	WITH HOLD
		SELECT a.numcte, a.num_credito, d.prox_fecha_pago
			INTO cNumCte, cNumCred, vfechapago
		FROM bdicred:"informix".sd_maecred a
		INNER JOIN bdicred:"informix".sd_maesdos b ON (b.empresa = a.empresa AND b.num_credito = a.num_credito)
		INNER JOIN bdicred:sd_maecredanexo d ON (d.empresa = a.empresa AND d.num_credito = a.num_credito)
		WHERE a.empresa = pempresa 
			AND a.num_credito > ''
			AND a.num_producto = '8500'
			AND a.status_cred IN ('AA','E1')
			AND a.campo_trab3 <> 'BAJA'
			AND b.mto_fin_ven_trasp = 0
			AND b.monto_vencido + b.mto_venc_trasp = 0
			AND b.monto_financiado > 0

		LET iCuentasProcesadas = iCuentasProcesadas + 1;

		CALL bdimnsj:"informix".sp_registra_evento('2','COBRA_SMS','TGC_PAGCOMS',cNumcte,cNumCred,'','2',
				DAY(vfechapago),'','','','','','','','','','','',0,0,0,0,0,TODAY,'') RETURNING cCodRet;

		LET iCount_TGC_PAGCOMS = iCount_TGC_PAGCOMS + 1;
	END FOREACH;

	--Genera cifras de control
	IF iCuentasProcesadas > 0 THEN
	   LET cMensaje = 'TOTAL Cuentas procesadas campaÃ±a EMAILs y SMS MORAS TC ORO : ' ||iCuentasProcesadas;
	   CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCodRet;
	   LET cMensaje = '';
	   LET cMensaje = 'SMS enviados RECORDATORIO PAGO COMPLETO : ' ||iCount_TGC_PAGCOMS;
	   CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCodRet;
	END IF;
	--Genera cifras de control

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '03') RETURNING cCodRet;

     if cCodRet != '000000' then
        let P_COD_RET = cCodRet;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;

	RETURN P_COD_RET,P_MENSAJE;

END
END PROCEDURE;
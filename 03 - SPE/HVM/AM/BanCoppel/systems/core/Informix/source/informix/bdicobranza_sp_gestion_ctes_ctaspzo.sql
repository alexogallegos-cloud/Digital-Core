CREATE PROCEDURE "informix".sp_gestion_ctes_ctaspzo(pTipoEjecucion CHAR(01), pDiaEjecucion CHAR(02))
returning VARCHAR(06),
          VARCHAR(80);

DEFINE pfechahoy			DATE;
DEFINE SQL_ERR				INTEGER;
DEFINE ISAM_ERR				INTEGER;
DEFINE ERROR_INFO			VARCHAR(80);
DEFINE cProceso				CHAR(4);
DEFINE P_COD_RET			VARCHAR(6);
DEFINE P_MENSAJE			VARCHAR(80);
DEFINE cEmpresa				CHAR(3);
DEFINE cCodRet  			CHAR(6);
DEFINE cMensaje  			CHAR(100);

DEFINE dFecha				DATE;
DEFINE cFecha_ultimo_pago	DATE;
DEFINE cCampania			CHAR(10);
DEFINE cNumCredito			CHAR(20);
DEFINE cNumcte				CHAR(20);
DEFINE cNumProducto			CHAR(04);
DEFINE dFechaApertura		DATE;
DEFINE cMotivoExclusion		CHAR(01);
DEFINE dFechaVencido		DATE;
DEFINE sNumVencidos			SMALLINT;
DEFINE sNumVencidosDiaant	SMALLINT;
DEFINE cDiaCorte			CHAR(02);
DEFINE dPagoMinimo			DECIMAL(18,2);
DEFINE dSdoTotalLiquidar	DECIMAL(18,2);
DEFINE dSdoTotalLiquidarDiaant	DECIMAL(18,2);
DEFINE dSdoVencido			DECIMAL(18,2);
DEFINE dSdoVencidoDiaante	DECIMAL(18,2);
DEFINE dSdoInsoluto			DECIMAL(18,2);
DEFINE dSdoInsolutoDiaante	DECIMAL(18,2);
DEFINE dPagosRealizados		DECIMAL(18,2);
DEFINE sNumEnviosCamp1		SMALLINT;
DEFINE sNumEnviosCamp2		SMALLINT;
DEFINE vStatusVencidos		VARCHAR(20);
DEFINE vStatusSituacion		VARCHAR(20);
DEFINE cProcesar			CHAR(01);
DEFINE cExclusion           CHAR(1);
DEFINE dSdoVencidoAct		DECIMAL(18,2);
DEFINE dmontoultimopago		DECIMAL(18,2);

--DEFINE dFechaVencido			DATE;

DEFINE cMensajeRetorno	CHAR(80);
--DEFINE dPagoMinimo		DECIMAL(18,2);
DEFINE dIntVdo			DECIMAL(18,2);
DEFINE dIntMoratorio	DECIMAL(18,2);
DEFINE dIvaIntVdo		DECIMAL(18,2);
DEFINE dIntMes			DECIMAL(18,2);
DEFINE dIvaIntMes		DECIMAL(18,2);
DEFINE dIntVig			DECIMAL(18,2);
DEFINE dIvaIntVig		DECIMAL(18,2);

DEFINE iTotalExcluidas 			INTEGER;
DEFINE iTotalCuentasVencidas	INTEGER;
DEFINE iTotalExcluidasXSitEsp	INTEGER;
DEFINE iTotalExcluidasXAclara	INTEGER;
DEFINE iTotalExcluidasXConvAct	INTEGER;
DEFINE iTotalExcluidasXSaldo	INTEGER;
DEFINE iTotalaEnviar	INTEGER;
DEFINE dFechaaProcesar	DATE;
DEFINE cStatusCred		CHAR(02);
DEFINE cstatusvencidos	VARCHAR(02);
DEFINE cStatusSituacion VARCHAR(02);
DEFINE dfechavencido2	DATE;
DEFINE pDiaProcesar		CHAR(2);
DEFINE cDescripcion		CHAR(60);

BEGIN 
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
     LET P_COD_RET = SQL_ERR;
     LET P_MENSAJE = 'Erro en la ejecucion proceso. '||cNumCredito;
     CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, P_COD_RET, P_MENSAJE, '02')
     RETURNING P_COD_RET;
     LET P_COD_RET = SQL_ERR;

     RETURN P_COD_RET,P_MENSAJE;
   END EXCEPTION;

--SET DEBUG FILE TO "sp_gestion_ctes_ctaspzo.out";
--TRACE ON;

LET cEmpresa            = '001';
LET cProceso            = '2009';
LET P_COD_RET           = '000000';
LET cCodRet           	= '000000';
LET P_MENSAJE           = 'El proceso de GESTION CTES. CTAS. PZO. se ejecuto correctamente.';
LET cMensaje			= '';

LET dFecha				= DATE(1);
LET cFecha_ultimo_pago	= DATE(1);
LET cCampania			= '';
LET cNumCredito			= '';
LET cNumcte				= '';
LET cNumProducto		= '';
LET dFechaApertura		= DATE(1);
LET cMotivoExclusion	= '';
LET dFechaVencido		= DATE(1);
LET sNumVencidos		= 0;
LET sNumVencidosDiaant	= 0;
LET cDiaCorte			= '';
LET dPagoMinimo			= 0;
LET dSdoTotalLiquidar	= 0;
LET dSdoTotalLiquidarDiaant	= 0;
LET dSdoVencido			= 0;
LET dSdoVencidoDiaante	= 0;
LET dSdoInsoluto		= 0;
LET dSdoInsolutoDiaante	= 0;
LET dPagosRealizados	= 0;
LET sNumEnviosCamp1		= 0;
LET sNumEnviosCamp2		= 0;
LET vStatusVencidos		= '';
LET vStatusSituacion	= '';
LET cProcesar			= '';
LET cExclusion			= '';
LET dSdoVencidoAct		= 0;
LET dmontoultimopago 	= 0;

--LET dFechaVencido			= DATE(1);

LET cMensajeRetorno		= '';
--LET dPagoMinimo			= 0;
LET dIntVdo				= 0;
LET dIntMoratorio		= 0;
LET dIvaIntVdo			= 0;
LET dIntMes				= 0;
LET dIvaIntMes			= 0;
LET dIntVig				= 0;
LET dIvaIntVig			= 0;

LET iTotalExcluidas			= 0;
LET	iTotalCuentasVencidas	= 0;
LET	iTotalExcluidasXSitEsp	= 0;
LET	iTotalExcluidasXAclara	= 0;
LET	iTotalExcluidasXConvAct	= 0;
LET	iTotalExcluidasXSaldo	= 0;
LET iTotalaEnviar			= 0;
LET dFechaaProcesar			= DATE(1);
LET cStatusCred			= '';
LET cstatusvencidos		= '';
LET cStatusSituacion	= '';
LET dfechavencido2		= DATE(1);
LET pDiaProcesar		= '';
LET cDescripcion		= '';


CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, P_MENSAJE, '01')
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
	LET cMensaje = 'PARAMETROS NO VALIDOS';
	LET cCodRet  = '000001';
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	RETURN cCodRet,cMensaje;
END IF;

-----------------------------------------------------------------
-- Gestion del primer dia
-----------------------------------------------------------------
IF pDiaEjecucion = '1' THEN
-----------------------------------------------------------------
-- Genera campana PP_VTAC7PV
-----------------------------------------------------------------
	SELECT 
		ven.fecha,ven.campania,ven.num_credito,ven.numcte,ven.procesar,ven.fecha_vencido,mae.status_cred,mas.mto_venc_trasp+mas.monto_vencido mto_venc_trasp,ven.sdo_vencido,mas.mto_fin_ven_trasp,mas.sdo_cap_insoluto,
		mas.sdo_intereses,mas.int_tra_no_exig,mas.mto_venc_int,mas.sdo_no_exig,mas.mto_finan_vdo,mas.sdo_moratorio,mas.sdo_contab_mora,suc.iva,ven.num_producto
	  FROM "informix".cb_vencidos_findemes ven
	 INNER JOIN bdicred:"informix".sd_maecredcrd mae ON mae.num_credito = ven.num_credito
	 INNER JOIN bdicred:"informix".sd_maesdoscrd mas ON mas.num_credito = ven.num_credito AND mas.mto_fin_ven_trasp >= 7
	 INNER JOIN bdinteg:"informix".si_sucursales suc ON suc.empresa = mae.empresa AND suc.sucursal = mae.sucursal
	 WHERE ven.fecha = dFechaaProcesar
	   AND ven.campania = 'PP_VTAC7PV'
	   AND ven.procesar = '0'
	INTO TEMP ctes_ctaspzo WITH NO LOG;

	CREATE INDEX ind_vencido_tmp ON ctes_ctaspzo(fecha);
	UPDATE STATISTICS MEDIUM FOR TABLE ctes_ctaspzo;

	-- Selecciona todos los vencidos e indetifica el tipo de campana para crear el universo a trabajar en el mes
	FOREACH WITH HOLD
		SELECT fecha,campania,num_credito,numcte,procesar,fecha_vencido,status_cred,mto_venc_trasp,sdo_vencido,mto_fin_ven_trasp,sdo_cap_insoluto,
			sdo_cap_insoluto + sdo_intereses + int_tra_no_exig + mto_venc_int + sdo_no_exig + (mto_finan_vdo + sdo_moratorio + sdo_contab_mora) * (1 + iva) sdo_total_liquidar,num_producto
		  INTO dFecha,cCampania,cNumCredito,cNumcte,cProcesar,dFechaVencido,cStatusCred,dSdoVencido,dSdoVencidoAct,sNumVencidos,dSdoInsoluto,dSdoTotalLiquidar,cNumProducto
		  FROM ctes_ctaspzo WHERE fecha = dFechaaProcesar

		LET	iTotalCuentasVencidas	= iTotalCuentasVencidas + 1;

	-- Valida motivo de exclusiones, si tiene
		EXECUTE PROCEDURE "informix".sp_identifica_exclusiones(cEmpresa,cNumCredito,cNumcte) INTO P_COD_RET,cExclusion;

		IF 	 cExclusion = '1' 	THEN 	LET	iTotalExcluidasXSitEsp	= iTotalExcluidasXSitEsp + 1;
		ELIF cExclusion = '2' 	THEN 	LET	iTotalExcluidasXAclara	= iTotalExcluidasXAclara + 1;
		ELIF cExclusion = '3' 	THEN 	LET	iTotalExcluidasXConvAct	= iTotalExcluidasXConvAct + 1;
		ELIF cExclusion = '4' 	THEN 	LET	iTotalExcluidasXSaldo	= iTotalExcluidasXSaldo + 1;
		END IF;
		
		IF cExclusion != '0' THEN LET cProcesar = '0'; ELSE LET cProcesar = '1'; LET iTotalaEnviar = iTotalaEnviar + 1; LET pDiaProcesar = pDiaEjecucion; END IF;

		SELECT fecha_ult_pago INTO cFecha_ultimo_pago 
		  FROM  bdicred:"informix".sd_maecredanexocrd
		WHERE empresa 		= cEmpresa
		  AND num_credito 	= cNumCredito;

		SELECT NVL(SUM(monto),0) INTO dMontoUltimoPago
		FROM bdicred:"informix".sd_movhiscrd 
		WHERE empresa = cEmpresa 
		AND fecha_mov = cFecha_ultimo_pago
		AND num_credito = cNumCredito
		AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd WHERE num_producto = cNumProducto) 
		AND codigo_ref = 1 AND reversado = "N";

		IF dSdoVencido < dSdoVencidoAct THEN
			LET cStatusVencidos = 'MEJORA';
		ELIF dSdoVencido = dSdoVencidoAct THEN
			LET cStatusVencidos = 'ESTABLE';
		ELIF dSdoVencido > dSdoVencidoAct THEN
			LET cStatusVencidos = 'DETERIORO';
		END IF;

		IF cStatusCred = 'CV' THEN
			LET cStatusSituacion = 'VENDIDO';
		ELIF cStatusCred = 'FF' THEN
			LET cStatusSituacion = 'LIQUIDADO';
		ELIF cStatusCred = 'FI' THEN
			LET cStatusSituacion = 'INMATERIAL';
		ELIF cStatusCred = 'FC' THEN
			LET cStatusSituacion = 'REESTRUCTURADO';
		ELIF cStatusCred = 'AA' THEN
			LET cStatusSituacion = 'VIGENTE';
		ELIF cStatusCred = 'BT' THEN
			LET cStatusSituacion = 'VENCIDO';
		ELIF cStatusCred = 'BA' THEN
			LET cStatusSituacion = 'VENCIDO_TRANSITORIO';
		ELIF cStatusCred IN ('E1','E2','E3') THEN
			SELECT descripcion INTO cDescripcion FROM bdicred:sd_tipocartera WHERE empresa = cEmpresa AND status_cred = cStatusCred;
			LET cStatusSituacion = TRIM(cDescripcion);
		END IF;
		
	-- Valida si realizo pago correspondiente a una mensualidad completa
		SELECT MIN(fecha_cuota) INTO dFechaVencido2
		FROM bdicred:"informix".sd_amortiza_creditocrd
		WHERE empresa 		= cEmpresa
		  AND num_credito 	= cNumCredito
		  AND capital_status IN ('6','7','2');
		
		IF dFechaVencido2 IS NULL OR dFechaVencido2 = '' THEN LET dFechaVencido2 = DATE(1); END IF;
		
		IF dFechaVencido < dFechaVencido2 THEN LET cProcesar = '9'; LET iTotalaEnviar = iTotalaEnviar - 1; LET pDiaProcesar = ''; END IF;

		BEGIN WORK;
		UPDATE "informix".cb_vencidos_findemes
		   SET 	motivo_exclusion			= cExclusion,
				num_vencidos_diaant 		= sNumVencidos,
				pago_minimo 				= dPagoMinimo,
				sdo_total_liquidar_diaant 	= dSdoTotalLiquidar,
				sdo_vencido_diaante 		= dSdoVencido,
				sdo_insoluto_diaante 		= dSdoInsoluto,
				pagos_realizados 			= dMontoUltimoPago,
				num_envios_camp1 			= sNumEnviosCamp1,
				num_envios_camp2 			= sNumEnviosCamp2,
				status_vencidos 			= cStatusVencidos,
				status_situacion 			= cStatusSituacion,
				procesar					= cProcesar,
				dia_procesar				= pDiaProcesar
		 WHERE fecha		= dFecha
		   AND campania		= cCampania
		   AND num_credito	= cNumCredito;
		COMMIT WORK;
		
		LET cExclusion			= '';
		LET sNumVencidos		= 0;
		LET dPagoMinimo			= 0;
		LET dSdoTotalLiquidar	= 0;
		LET dSdoVencido			= 0;
		LET dSdoInsoluto		= 0;
		LET cFecha_ultimo_pago	= DATE(1);
		LET dMontoUltimoPago	= 0;
		LET sNumEnviosCamp1		= 0;
		LET sNumEnviosCamp2		= 0;
		LET cStatusVencidos		= '';
		LET cStatusSituacion	= '';
		LET cProcesar			= '';
		LET pDiaProcesar		= '';
		LET cNumProducto		= '';

	END FOREACH;

	DROP TABLE ctes_ctaspzo;

	--Genera cifras de control
	LET cMensaje = ' ------- Cifras de Control campana PP_VTAC7PV ------- ';
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

	LET cMensaje = '';
	LET cMensaje = 'TOTAL Cuentas vencidas procesadas : ' ||iTotalCuentasVencidas;
	LET cMensaje = trim(cMensaje) ||'    Cuentas excluidas X situacion especial: ' ||iTotalExcluidasXSitEsp;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = '';
	LET cMensaje = 'Cuentas excluidas X proceso de aclaracion : ' ||iTotalExcluidasXAclara;
	LET cMensaje = trim(cMensaje) ||'    Cuentas excluidas X convenio activo : ' ||iTotalExcluidasXConvAct;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = '';
	LET cMensaje = 'Cuentas excluidas X saldo menor a 100 pesos : ' ||iTotalExcluidasXSaldo;
	LET cMensaje = trim(cMensaje) ||'    Cuentas a enviar : ' ||iTotalaEnviar;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	--Genera cifras de control

	LET cMensaje = '';
	LET iTotalExcluidasXSitEsp	= 0;
	LET iTotalExcluidasXAclara	= 0;
	LET iTotalExcluidasXConvAct	= 0;
	LET iTotalExcluidasXSaldo	= 0;
	LET iTotalaEnviar			= 0;
	LET	iTotalCuentasVencidas	= 0;
	LET pDiaProcesar			= '';

-----------------------------------------------------------------
-- Genera campana PP_VTACCON
-----------------------------------------------------------------
	SELECT 
		ven.fecha,ven.campania,ven.num_credito,ven.numcte,ven.procesar,ven.fecha_vencido,mae.status_cred,mas.mto_venc_trasp+mas.monto_vencido mto_venc_trasp,ven.sdo_vencido,mas.mto_fin_ven_trasp,mas.sdo_cap_insoluto,
		mas.sdo_intereses,mas.int_tra_no_exig,mas.mto_venc_int,mas.sdo_no_exig,mas.mto_finan_vdo,mas.sdo_moratorio,mas.sdo_contab_mora,suc.iva,ven.num_producto
	  FROM "informix".cb_vencidos_findemes ven
	 INNER JOIN bdicred:"informix".sd_maecredcrd mae ON mae.num_credito = ven.num_credito
	 INNER JOIN bdicred:"informix".sd_maesdoscrd mas ON mas.num_credito = ven.num_credito
	 INNER JOIN bdinteg:"informix".si_sucursales suc ON suc.empresa = mae.empresa AND suc.sucursal = mae.sucursal
	 WHERE ven.fecha = dFechaaProcesar
	   AND ven.campania = 'PP_VTACCON'
	   AND ven.procesar = '0'
	INTO TEMP ctes_ctaspzo WITH NO LOG;

	CREATE INDEX ind_vencido_tmp ON ctes_ctaspzo(fecha);
	UPDATE STATISTICS MEDIUM FOR TABLE ctes_ctaspzo;

	-- Selecciona todos los vencidos e indetifica el tipo de campana para crear el universo a trabajar en el mes
	FOREACH WITH HOLD
		SELECT fecha,campania,num_credito,numcte,procesar,fecha_vencido,status_cred,mto_venc_trasp,sdo_vencido,mto_fin_ven_trasp,sdo_cap_insoluto,
			sdo_cap_insoluto + sdo_intereses + int_tra_no_exig + mto_venc_int + sdo_no_exig + (mto_finan_vdo + sdo_moratorio + sdo_contab_mora) * (1 + iva) sdo_total_liquidar,num_producto
		  INTO dFecha,cCampania,cNumCredito,cNumcte,cProcesar,dFechaVencido,cStatusCred,dSdoVencido,dSdoVencidoAct,sNumVencidos,dSdoInsoluto,dSdoTotalLiquidar,cNumProducto
		  FROM ctes_ctaspzo WHERE fecha = dFechaaProcesar

		LET	iTotalCuentasVencidas	= iTotalCuentasVencidas + 1;

	-- Valida motivo de exclusiones, si tiene
		EXECUTE PROCEDURE "informix".sp_identifica_exclusiones(cEmpresa,cNumCredito,cNumcte) INTO P_COD_RET,cExclusion;

		IF 	 cExclusion = '1' 	THEN 	LET	iTotalExcluidasXSitEsp	= iTotalExcluidasXSitEsp + 1;
		ELIF cExclusion = '2' 	THEN 	LET	iTotalExcluidasXAclara	= iTotalExcluidasXAclara + 1;
		ELIF cExclusion = '3' 	THEN 	LET	iTotalExcluidasXConvAct	= iTotalExcluidasXConvAct + 1;
		ELIF cExclusion = '4' 	THEN 	LET	iTotalExcluidasXSaldo	= iTotalExcluidasXSaldo + 1;
		END IF;
		
		IF cExclusion != '0' THEN LET cProcesar = '0'; ELSE LET cProcesar = '1'; LET iTotalaEnviar = iTotalaEnviar + 1; LET pDiaProcesar = pDiaEjecucion; END IF;

		SELECT fecha_ult_pago INTO cFecha_ultimo_pago 
		  FROM  bdicred:"informix".sd_maecredanexocrd
		WHERE empresa 		= cEmpresa
		  AND num_credito 	= cNumCredito;

		SELECT NVL(SUM(monto),0) INTO dMontoUltimoPago
		FROM bdicred:"informix".sd_movhiscrd 
		WHERE empresa = cEmpresa 
		AND fecha_mov = cFecha_ultimo_pago
		AND num_credito = cNumCredito
		AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd WHERE num_producto = cNumProducto) 
		AND codigo_ref = 1 AND reversado = "N";

		IF dSdoVencido < dSdoVencidoAct THEN
			LET cStatusVencidos = 'MEJORA';
		ELIF dSdoVencido = dSdoVencidoAct THEN
			LET cStatusVencidos = 'ESTABLE';
		ELIF dSdoVencido > dSdoVencidoAct THEN
			LET cStatusVencidos = 'DETERIORO';
		END IF;

		IF cStatusCred = 'CV' THEN
			LET cStatusSituacion = 'VENDIDO';
		ELIF cStatusCred = 'FF' THEN
			LET cStatusSituacion = 'LIQUIDADO';
		ELIF cStatusCred = 'FI' THEN
			LET cStatusSituacion = 'INMATERIAL';
		ELIF cStatusCred = 'FC' THEN
			LET cStatusSituacion = 'REESTRUCTURADO';
		ELIF cStatusCred = 'AA' THEN
			LET cStatusSituacion = 'VIGENTE';
		ELIF cStatusCred = 'BT' THEN
			LET cStatusSituacion = 'VENCIDO';
		ELIF cStatusCred = 'BA' THEN
			LET cStatusSituacion = 'VENCIDO_TRANSITORIO';
		ELIF cStatusCred IN ('E1','E2','E3') THEN
			SELECT descripcion INTO cDescripcion FROM bdicred:sd_tipocartera WHERE empresa = cEmpresa AND status_cred = cStatusCred;
			LET cStatusSituacion = TRIM(cDescripcion);
		END IF;

		IF ((cFecha_ultimo_pago >= mdy(MONTH(TODAY),1,YEAR(TODAY))) AND (cFecha_ultimo_pago <= mdy(MONTH(TODAY),pDiaEjecucion,YEAR(TODAY)))) THEN
			LET cProcesar = '9';
			LET iTotalaEnviar = iTotalaEnviar - 1;
			LET pDiaProcesar = '';
		END IF;

		BEGIN WORK;
		UPDATE "informix".cb_vencidos_findemes
		   SET 	motivo_exclusion			= cExclusion,
				num_vencidos_diaant 		= sNumVencidos,
				pago_minimo 				= dPagoMinimo,
				sdo_total_liquidar_diaant 	= dSdoTotalLiquidar,
				sdo_vencido_diaante 		= dSdoVencido,
				sdo_insoluto_diaante 		= dSdoInsoluto,
				pagos_realizados 			= dMontoUltimoPago,
				num_envios_camp1 			= sNumEnviosCamp1,
				num_envios_camp2 			= sNumEnviosCamp2,
				status_vencidos 			= cStatusVencidos,
				status_situacion 			= cStatusSituacion,
				procesar					= cProcesar,
				dia_procesar				= pDiaProcesar
		 WHERE fecha		= dFecha
		   AND campania		= cCampania
		   AND num_credito	= cNumCredito;
		COMMIT WORK;

		LET cExclusion			= '';
		LET sNumVencidos		= 0;
		LET dPagoMinimo			= 0;
		LET dSdoTotalLiquidar	= 0;
		LET dSdoVencido			= 0;
		LET dSdoInsoluto		= 0;
		LET cFecha_ultimo_pago	= DATE(1);
		LET dMontoUltimoPago	= 0;
		LET sNumEnviosCamp1		= 0;
		LET sNumEnviosCamp2		= 0;
		LET cStatusVencidos		= '';
		LET cStatusSituacion	= '';
		LET cProcesar			= '';
		LET pDiaProcesar		= '';
		LET cNumProducto		= '';

	END FOREACH;

	DROP TABLE ctes_ctaspzo;

	--Genera cifras de control
	LET cMensaje = ' ------- Cifras de Control campana PP_VTACCON ------- ';
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

	LET cMensaje = '';
	LET cMensaje = 'TOTAL Cuentas vencidas procesadas : ' ||iTotalCuentasVencidas;
	LET cMensaje = trim(cMensaje) ||'    Cuentas excluidas X situacion especial: ' ||iTotalExcluidasXSitEsp;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = '';
	LET cMensaje = 'Cuentas excluidas X proceso de aclaracion : ' ||iTotalExcluidasXAclara;
	LET cMensaje = trim(cMensaje) ||'    Cuentas excluidas X convenio activo : ' ||iTotalExcluidasXConvAct;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = '';
	LET cMensaje = 'Cuentas excluidas X saldo menor a 100 pesos : ' ||iTotalExcluidasXSaldo;
	LET cMensaje = trim(cMensaje) ||'    Cuentas a enviar : ' ||iTotalaEnviar;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	--Genera cifras de control

	LET cMensaje = '';
	LET iTotalExcluidasXSitEsp	= 0;
	LET iTotalExcluidasXAclara	= 0;
	LET iTotalExcluidasXConvAct	= 0;
	LET iTotalExcluidasXSaldo	= 0;
	LET iTotalaEnviar			= 0;
	LET	iTotalCuentasVencidas	= 0;
	LET pDiaProcesar			= '';

END IF;

-----------------------------------------------------------------
-- Gestion de los dias restantes
-----------------------------------------------------------------
IF pDiaEjecucion IN ('7','12','22','25') THEN
-----------------------------------------------------------------
-- Genera campana PP_VTAC7PV
-----------------------------------------------------------------
	SELECT 
		ven.fecha,ven.campania,ven.num_credito,ven.numcte,ven.procesar,ven.fecha_vencido,mae.status_cred,mas.mto_venc_trasp+mas.monto_vencido mto_venc_trasp,ven.sdo_vencido,mas.mto_fin_ven_trasp,mas.sdo_cap_insoluto,
		mas.sdo_intereses,mas.int_tra_no_exig,mas.mto_venc_int,mas.sdo_no_exig,mas.mto_finan_vdo,mas.sdo_moratorio,mas.sdo_contab_mora,suc.iva,ven.num_producto
	  FROM "informix".cb_vencidos_findemes ven
	 INNER JOIN bdicred:"informix".sd_maecredcrd mae ON mae.num_credito = ven.num_credito
	 INNER JOIN bdicred:"informix".sd_maesdoscrd mas ON mas.num_credito = ven.num_credito AND mas.mto_fin_ven_trasp >= 7
	 INNER JOIN bdinteg:"informix".si_sucursales suc ON suc.empresa = mae.empresa AND suc.sucursal = mae.sucursal
	 WHERE ven.fecha = dFechaaProcesar
	   AND ven.campania = 'PP_VTAC7PV'
	   AND ven.dia_corte >= pDiaEjecucion
	   AND ven.procesar in ('0','1')
	INTO TEMP ctes_ctaspzo WITH NO LOG;

	CREATE INDEX ind_vencido_tmp ON ctes_ctaspzo(fecha);
	UPDATE STATISTICS MEDIUM FOR TABLE ctes_ctaspzo;

	-- Selecciona todos los vencidos e indetifica el tipo de campana para crear el universo a trabajar en el mes
	FOREACH WITH HOLD
		SELECT fecha,campania,num_credito,numcte,procesar,fecha_vencido,status_cred,mto_venc_trasp,sdo_vencido,mto_fin_ven_trasp,sdo_cap_insoluto,
			sdo_cap_insoluto + sdo_intereses + int_tra_no_exig + mto_venc_int + sdo_no_exig + (mto_finan_vdo + sdo_moratorio + sdo_contab_mora) * (1 + iva) sdo_total_liquidar,num_producto
		  INTO dFecha,cCampania,cNumCredito,cNumcte,cProcesar,dFechaVencido,cStatusCred,dSdoVencido,dSdoVencidoAct,sNumVencidos,dSdoInsoluto,dSdoTotalLiquidar,cNumProducto
		  FROM ctes_ctaspzo WHERE fecha = dFechaaProcesar

		LET	iTotalCuentasVencidas	= iTotalCuentasVencidas + 1;

	-- Valida motivo de exclusiones, si tiene
		EXECUTE PROCEDURE "informix".sp_identifica_exclusiones(cEmpresa,cNumCredito,cNumcte) INTO P_COD_RET,cExclusion;

		IF 	 cExclusion = '1' 	THEN 	LET	iTotalExcluidasXSitEsp	= iTotalExcluidasXSitEsp + 1;
		ELIF cExclusion = '2' 	THEN 	LET	iTotalExcluidasXAclara	= iTotalExcluidasXAclara + 1;
		ELIF cExclusion = '3' 	THEN 	LET	iTotalExcluidasXConvAct	= iTotalExcluidasXConvAct + 1;
		ELIF cExclusion = '4' 	THEN 	LET	iTotalExcluidasXSaldo	= iTotalExcluidasXSaldo + 1;
		END IF;
		
		IF cExclusion != '0' THEN LET cProcesar = '0'; ELSE LET cProcesar = '1'; LET iTotalaEnviar = iTotalaEnviar + 1; LET pDiaProcesar = pDiaEjecucion; END IF;

		SELECT fecha_ult_pago INTO cFecha_ultimo_pago 
		  FROM  bdicred:"informix".sd_maecredanexocrd
		WHERE empresa 		= cEmpresa
		  AND num_credito 	= cNumCredito;

		SELECT NVL(SUM(monto),0) INTO dMontoUltimoPago
		FROM bdicred:"informix".sd_movhiscrd 
		WHERE empresa = cEmpresa 
		AND fecha_mov = cFecha_ultimo_pago
		AND num_credito = cNumCredito
		AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd WHERE num_producto = cNumProducto) 
		AND codigo_ref = 1 AND reversado = "N";

		IF dSdoVencido < dSdoVencidoAct THEN
			LET cStatusVencidos = 'MEJORA';
		ELIF dSdoVencido = dSdoVencidoAct THEN
			LET cStatusVencidos = 'ESTABLE';
		ELIF dSdoVencido > dSdoVencidoAct THEN
			LET cStatusVencidos = 'DETERIORO';
		END IF;

		IF cStatusCred = 'CV' THEN
			LET cStatusSituacion = 'VENDIDO';
		ELIF cStatusCred = 'FF' THEN
			LET cStatusSituacion = 'LIQUIDADO';
		ELIF cStatusCred = 'FI' THEN
			LET cStatusSituacion = 'INMATERIAL';
		ELIF cStatusCred = 'FC' THEN
			LET cStatusSituacion = 'REESTRUCTURADO';
		ELIF cStatusCred = 'AA' THEN
			LET cStatusSituacion = 'VIGENTE';
		ELIF cStatusCred = 'BT' THEN
			LET cStatusSituacion = 'VENCIDO';
		ELIF cStatusCred = 'BA' THEN
			LET cStatusSituacion = 'VENCIDO_TRANSITORIO';
		ELIF cStatusCred IN ('E1','E2','E3') THEN
			SELECT descripcion INTO cDescripcion FROM bdicred:sd_tipocartera WHERE empresa = cEmpresa AND status_cred = cStatusCred;
			LET cStatusSituacion = TRIM(cDescripcion);
		END IF;

	-- Valida si realizo pago correspondiente a una mensualidad completa
		SELECT MIN(fecha_cuota) INTO dFechaVencido2
		FROM bdicred:"informix".sd_amortiza_creditocrd
		WHERE empresa 		= cEmpresa
		  AND num_credito 	= cNumCredito
		  AND capital_status IN ('6','7','2');
		
		IF dFechaVencido2 IS NULL OR dFechaVencido2 = '' THEN LET dFechaVencido2 = DATE(1); END IF;
		
		IF dFechaVencido < dFechaVencido2 THEN LET cProcesar = '9'; LET	iTotalaEnviar = iTotalaEnviar - 1; LET pDiaProcesar = ''; END IF;

		BEGIN WORK;
		UPDATE "informix".cb_vencidos_findemes
		   SET 	motivo_exclusion			= cExclusion,
				num_vencidos_diaant 		= sNumVencidos,
				pago_minimo 				= dPagoMinimo,
				sdo_total_liquidar_diaant 	= dSdoTotalLiquidar,
				sdo_vencido_diaante 		= dSdoVencido,
				sdo_insoluto_diaante 		= dSdoInsoluto,
				pagos_realizados 			= dMontoUltimoPago,
				num_envios_camp1 			= sNumEnviosCamp1,
				num_envios_camp2 			= sNumEnviosCamp2,
				status_vencidos 			= cStatusVencidos,
				status_situacion 			= cStatusSituacion,
				procesar					= cProcesar,
				dia_procesar	 			= pDiaProcesar
		 WHERE fecha		= dFecha
		   AND campania		= cCampania
		   AND num_credito	= cNumCredito;
		COMMIT WORK;
		
		LET cExclusion			= '';
		LET sNumVencidos		= 0;
		LET dPagoMinimo			= 0;
		LET dSdoTotalLiquidar	= 0;
		LET dSdoVencido			= 0;
		LET dSdoInsoluto		= 0;
		LET cFecha_ultimo_pago	= DATE(1);
		LET dMontoUltimoPago	= 0;
		LET sNumEnviosCamp1		= 0;
		LET sNumEnviosCamp2		= 0;
		LET cStatusVencidos		= '';
		LET cStatusSituacion	= '';
		LET cProcesar			= '';
		LET cNumProducto		= '';
		LET pDiaProcesar		= '';

	END FOREACH;

	DROP TABLE ctes_ctaspzo;

	--Genera cifras de control
	LET cMensaje = ' ------- Cifras de Control campana PP_VTAC7PV ------- ';
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

	LET cMensaje = '';
	LET cMensaje = 'TOTAL Cuentas vencidas procesadas : ' ||iTotalCuentasVencidas;
	LET cMensaje = trim(cMensaje) ||'    Cuentas excluidas X situacion especial: ' ||iTotalExcluidasXSitEsp;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = '';
	LET cMensaje = 'Cuentas excluidas X proceso de aclaracion : ' ||iTotalExcluidasXAclara;
	LET cMensaje = trim(cMensaje) ||'    Cuentas excluidas X convenio activo : ' ||iTotalExcluidasXConvAct;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = '';
	LET cMensaje = 'Cuentas excluidas X saldo menor a 100 pesos : ' ||iTotalExcluidasXSaldo;
	LET cMensaje = trim(cMensaje) ||'    Cuentas a enviar : ' ||iTotalaEnviar;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	--Genera cifras de control

	LET cMensaje = '';
	LET iTotalExcluidasXSitEsp	= 0;
	LET iTotalExcluidasXAclara	= 0;
	LET iTotalExcluidasXConvAct	= 0;
	LET iTotalExcluidasXSaldo	= 0;
	LET iTotalaEnviar			= 0;
	LET	iTotalCuentasVencidas	= 0;
	LET pDiaProcesar			= '';

-----------------------------------------------------------------
-- Genera campana PP_VTACCON
-----------------------------------------------------------------
	SELECT 
		ven.fecha,ven.campania,ven.num_credito,ven.numcte,ven.procesar,ven.fecha_vencido,mae.status_cred,mas.mto_venc_trasp+mas.monto_vencido mto_venc_trasp,ven.sdo_vencido,mas.mto_fin_ven_trasp,mas.sdo_cap_insoluto,
		mas.sdo_intereses,mas.int_tra_no_exig,mas.mto_venc_int,mas.sdo_no_exig,mas.mto_finan_vdo,mas.sdo_moratorio,mas.sdo_contab_mora,suc.iva,ven.num_producto
	  FROM "informix".cb_vencidos_findemes ven
	 INNER JOIN bdicred:"informix".sd_maecredcrd mae ON mae.num_credito = ven.num_credito
	 INNER JOIN bdicred:"informix".sd_maesdoscrd mas ON mas.num_credito = ven.num_credito
	 INNER JOIN bdinteg:"informix".si_sucursales suc ON suc.empresa = mae.empresa AND suc.sucursal = mae.sucursal
	 WHERE ven.fecha = dFechaaProcesar
	   AND ven.campania = 'PP_VTACCON'
	   AND ven.procesar in ('0','1')
	INTO TEMP ctes_ctaspzo WITH NO LOG;

	CREATE INDEX ind_vencido_tmp ON ctes_ctaspzo(fecha);
	UPDATE STATISTICS MEDIUM FOR TABLE ctes_ctaspzo;

	-- Selecciona todos los vencidos e indetifica el tipo de campana para crear el universo a trabajar en el mes
	FOREACH WITH HOLD
		SELECT fecha,campania,num_credito,numcte,procesar,fecha_vencido,status_cred,mto_venc_trasp,sdo_vencido,mto_fin_ven_trasp,sdo_cap_insoluto,
			sdo_cap_insoluto + sdo_intereses + int_tra_no_exig + mto_venc_int + sdo_no_exig + (mto_finan_vdo + sdo_moratorio + sdo_contab_mora) * (1 + iva) sdo_total_liquidar,num_producto
		  INTO dFecha,cCampania,cNumCredito,cNumcte,cProcesar,dFechaVencido,cStatusCred,dSdoVencido,dSdoVencidoAct,sNumVencidos,dSdoInsoluto,dSdoTotalLiquidar,cNumProducto
		  FROM ctes_ctaspzo WHERE fecha = dFechaaProcesar

		LET	iTotalCuentasVencidas	= iTotalCuentasVencidas + 1;

	-- Valida motivo de exclusiones, si tiene
		EXECUTE PROCEDURE "informix".sp_identifica_exclusiones(cEmpresa,cNumCredito,cNumcte) INTO P_COD_RET,cExclusion;

		IF 	 cExclusion = '1' 	THEN 	LET	iTotalExcluidasXSitEsp	= iTotalExcluidasXSitEsp + 1;
		ELIF cExclusion = '2' 	THEN 	LET	iTotalExcluidasXAclara	= iTotalExcluidasXAclara + 1;
		ELIF cExclusion = '3' 	THEN 	LET	iTotalExcluidasXConvAct	= iTotalExcluidasXConvAct + 1;
		ELIF cExclusion = '4' 	THEN 	LET	iTotalExcluidasXSaldo	= iTotalExcluidasXSaldo + 1;
		END IF;
		
		IF cExclusion != '0' THEN LET cProcesar = '0'; ELSE LET cProcesar = '1'; LET iTotalaEnviar = iTotalaEnviar + 1; LET pDiaProcesar = pDiaEjecucion; END IF;

		SELECT fecha_ult_pago INTO cFecha_ultimo_pago 
		  FROM  bdicred:"informix".sd_maecredanexocrd
		WHERE empresa 		= cEmpresa
		  AND num_credito 	= cNumCredito;

		SELECT NVL(SUM(monto),0) INTO dMontoUltimoPago
		FROM bdicred:"informix".sd_movhiscrd 
		WHERE empresa = cEmpresa 
		AND fecha_mov = cFecha_ultimo_pago
		AND num_credito = cNumCredito
		AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd WHERE num_producto = cNumProducto) 
		AND codigo_ref = 1 AND reversado = "N";

		IF dSdoVencido < dSdoVencidoAct THEN
			LET cStatusVencidos = 'MEJORA';
		ELIF dSdoVencido = dSdoVencidoAct THEN
			LET cStatusVencidos = 'ESTABLE';
		ELIF dSdoVencido > dSdoVencidoAct THEN
			LET cStatusVencidos = 'DETERIORO';
		END IF;

		IF cStatusCred = 'CV' THEN
			LET cStatusSituacion = 'VENDIDO';
		ELIF cStatusCred = 'FF' THEN
			LET cStatusSituacion = 'LIQUIDADO';
		ELIF cStatusCred = 'FI' THEN
			LET cStatusSituacion = 'INMATERIAL';
		ELIF cStatusCred = 'FC' THEN
			LET cStatusSituacion = 'REESTRUCTURADO';
		ELIF cStatusCred = 'AA' THEN
			LET cStatusSituacion = 'VIGENTE';
		ELIF cStatusCred = 'BT' THEN
			LET cStatusSituacion = 'VENCIDO';
		ELIF cStatusCred = 'BA' THEN
			LET cStatusSituacion = 'VENCIDO_TRANSITORIO';
		ELIF cStatusCred IN ('E1','E2','E3') THEN
			SELECT descripcion INTO cDescripcion FROM bdicred:sd_tipocartera WHERE empresa = cEmpresa AND status_cred = cStatusCred;
			LET cStatusSituacion = TRIM(cDescripcion);
		END IF;

		IF ((cFecha_ultimo_pago >= mdy(MONTH(TODAY),1,YEAR(TODAY))) AND (cFecha_ultimo_pago <= mdy(MONTH(TODAY),pDiaEjecucion,YEAR(TODAY)))) THEN
			LET cProcesar = '9';
			LET iTotalaEnviar = iTotalaEnviar - 1;
			LET pDiaProcesar = '';
		END IF;

		BEGIN WORK;
		UPDATE "informix".cb_vencidos_findemes
		   SET 	motivo_exclusion			= cExclusion,
				num_vencidos_diaant 		= sNumVencidos,
				pago_minimo 				= dPagoMinimo,
				sdo_total_liquidar_diaant 	= dSdoTotalLiquidar,
				sdo_vencido_diaante 		= dSdoVencido,
				sdo_insoluto_diaante 		= dSdoInsoluto,
				pagos_realizados 			= dMontoUltimoPago,
				num_envios_camp1 			= sNumEnviosCamp1,
				num_envios_camp2 			= sNumEnviosCamp2,
				status_vencidos 			= cStatusVencidos,
				status_situacion 			= cStatusSituacion,
				procesar					= cProcesar,
				dia_procesar				= pDiaProcesar
		 WHERE fecha		= dFecha
		   AND campania		= cCampania
		   AND num_credito	= cNumCredito;
		COMMIT WORK;

		LET cExclusion			= '';
		LET sNumVencidos		= 0;
		LET dPagoMinimo			= 0;
		LET dSdoTotalLiquidar	= 0;
		LET dSdoVencido			= 0;
		LET dSdoInsoluto		= 0;
		LET cFecha_ultimo_pago	= DATE(1);
		LET dMontoUltimoPago	= 0;
		LET sNumEnviosCamp1		= 0;
		LET sNumEnviosCamp2		= 0;
		LET cStatusVencidos		= '';
		LET cStatusSituacion	= '';
		LET cProcesar			= '';
		LET pDiaProcesar		= '';
		LET cNumProducto		= '';

	END FOREACH;

	DROP TABLE ctes_ctaspzo;

	--Genera cifras de control
	LET cMensaje = ' ------- Cifras de Control campana PP_VTACCON ------- ';
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

	LET cMensaje = '';
	LET cMensaje = 'TOTAL Cuentas vencidas procesadas : ' ||iTotalCuentasVencidas;
	LET cMensaje = trim(cMensaje) ||'    Cuentas excluidas X situacion especial: ' ||iTotalExcluidasXSitEsp;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = '';
	LET cMensaje = 'Cuentas excluidas X proceso de aclaracion : ' ||iTotalExcluidasXAclara;
	LET cMensaje = trim(cMensaje) ||'    Cuentas excluidas X convenio activo : ' ||iTotalExcluidasXConvAct;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = '';
	LET cMensaje = 'Cuentas excluidas X saldo menor a 100 pesos : ' ||iTotalExcluidasXSaldo;
	LET cMensaje = trim(cMensaje) ||'    Cuentas a enviar : ' ||iTotalaEnviar;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	--Genera cifras de control

	LET cMensaje = '';
	LET iTotalExcluidasXSitEsp	= 0;
	LET iTotalExcluidasXAclara	= 0;
	LET iTotalExcluidasXConvAct	= 0;
	LET iTotalExcluidasXSaldo	= 0;
	LET iTotalaEnviar			= 0;
	LET	iTotalCuentasVencidas	= 0;
	LET pDiaProcesar			= '';

END IF;

--*****************************************************************************************--

-----------------------------------------------------------------
-- Gestion del primer dia
-----------------------------------------------------------------
IF pDiaEjecucion = '1' THEN
-----------------------------------------------------------------
-- Genera campana PP_VTAC6PV
-----------------------------------------------------------------
	SELECT 
		ven.fecha,ven.campania,ven.num_credito,ven.numcte,ven.procesar,ven.fecha_vencido,mae.status_cred,mas.mto_venc_trasp+mas.monto_vencido mto_venc_trasp,ven.sdo_vencido,mas.mto_fin_ven_trasp,mas.sdo_cap_insoluto,
		mas.sdo_intereses,mas.int_tra_no_exig,mas.mto_venc_int,mas.sdo_no_exig,mas.mto_finan_vdo,mas.sdo_moratorio,mas.sdo_contab_mora,suc.iva,ven.num_producto
	  FROM "informix".cb_vencidos_findemes ven
	 INNER JOIN bdicred:"informix".sd_maecredcrd mae ON mae.num_credito = ven.num_credito
	 INNER JOIN bdicred:"informix".sd_maesdoscrd mas ON mas.num_credito = ven.num_credito AND mas.mto_fin_ven_trasp >= 6
	 INNER JOIN bdinteg:"informix".si_sucursales suc ON suc.empresa = mae.empresa AND suc.sucursal = mae.sucursal
	 WHERE ven.fecha = dFechaaProcesar
	   AND ven.campania = 'PP_VTAC6PV'
	   AND ven.procesar = '0'
	INTO TEMP ctes_ctaspzo WITH NO LOG;

	CREATE INDEX ind_vencido_tmp ON ctes_ctaspzo(fecha);
	UPDATE STATISTICS MEDIUM FOR TABLE ctes_ctaspzo;

	-- Selecciona todos los vencidos e indetifica el tipo de campana para crear el universo a trabajar en el mes
	FOREACH WITH HOLD
		SELECT fecha,campania,num_credito,numcte,procesar,fecha_vencido,status_cred,mto_venc_trasp,sdo_vencido,mto_fin_ven_trasp,sdo_cap_insoluto,
			sdo_cap_insoluto + sdo_intereses + int_tra_no_exig + mto_venc_int + sdo_no_exig + (mto_finan_vdo + sdo_moratorio + sdo_contab_mora) * (1 + iva) sdo_total_liquidar,num_producto
		  INTO dFecha,cCampania,cNumCredito,cNumcte,cProcesar,dFechaVencido,cStatusCred,dSdoVencido,dSdoVencidoAct,sNumVencidos,dSdoInsoluto,dSdoTotalLiquidar,cNumProducto
		  FROM ctes_ctaspzo WHERE fecha = dFechaaProcesar

		LET	iTotalCuentasVencidas	= iTotalCuentasVencidas + 1;

	-- Valida motivo de exclusiones, si tiene
		EXECUTE PROCEDURE "informix".sp_identifica_exclusiones(cEmpresa,cNumCredito,cNumcte) INTO P_COD_RET,cExclusion;

		IF 	 cExclusion = '1' 	THEN 	LET	iTotalExcluidasXSitEsp	= iTotalExcluidasXSitEsp + 1;
		ELIF cExclusion = '2' 	THEN 	LET	iTotalExcluidasXAclara	= iTotalExcluidasXAclara + 1;
		ELIF cExclusion = '3' 	THEN 	LET	iTotalExcluidasXConvAct	= iTotalExcluidasXConvAct + 1;
		ELIF cExclusion = '4' 	THEN 	LET	iTotalExcluidasXSaldo	= iTotalExcluidasXSaldo + 1;
		END IF;
		
		IF cExclusion != '0' THEN LET cProcesar = '0'; ELSE LET cProcesar = '1'; LET iTotalaEnviar = iTotalaEnviar + 1; LET pDiaProcesar = pDiaEjecucion; END IF;

		SELECT fecha_ult_pago INTO cFecha_ultimo_pago 
		  FROM  bdicred:"informix".sd_maecredanexocrd
		WHERE empresa 		= cEmpresa
		  AND num_credito 	= cNumCredito;

		SELECT NVL(SUM(monto),0) INTO dMontoUltimoPago
		FROM bdicred:"informix".sd_movhiscrd 
		WHERE empresa = cEmpresa 
		AND fecha_mov = cFecha_ultimo_pago
		AND num_credito = cNumCredito
		AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd WHERE num_producto = cNumProducto) 
		AND codigo_ref = 1 AND reversado = "N";

		IF dSdoVencido < dSdoVencidoAct THEN
			LET cStatusVencidos = 'MEJORA';
		ELIF dSdoVencido = dSdoVencidoAct THEN
			LET cStatusVencidos = 'ESTABLE';
		ELIF dSdoVencido > dSdoVencidoAct THEN
			LET cStatusVencidos = 'DETERIORO';
		END IF;

		IF cStatusCred = 'CV' THEN
			LET cStatusSituacion = 'VENDIDO';
		ELIF cStatusCred = 'FF' THEN
			LET cStatusSituacion = 'LIQUIDADO';
		ELIF cStatusCred = 'FI' THEN
			LET cStatusSituacion = 'INMATERIAL';
		ELIF cStatusCred = 'FC' THEN
			LET cStatusSituacion = 'REESTRUCTURADO';
		ELIF cStatusCred = 'AA' THEN
			LET cStatusSituacion = 'VIGENTE';
		ELIF cStatusCred = 'BT' THEN
			LET cStatusSituacion = 'VENCIDO';
		ELIF cStatusCred = 'BA' THEN
			LET cStatusSituacion = 'VENCIDO_TRANSITORIO';
		ELIF cStatusCred IN ('E1','E2','E3') THEN
			SELECT descripcion INTO cDescripcion FROM bdicred:sd_tipocartera WHERE empresa = cEmpresa AND status_cred = cStatusCred;
			LET cStatusSituacion = TRIM(cDescripcion);
		END IF;

	-- Valida si realizo pago correspondiente a una mensualidad completa
		SELECT MIN(fecha_cuota) INTO dFechaVencido2
		FROM bdicred:"informix".sd_amortiza_creditocrd
		WHERE empresa 		= cEmpresa
		  AND num_credito 	= cNumCredito
		  AND capital_status IN ('6','7','2');
		
		IF dFechaVencido2 IS NULL OR dFechaVencido2 = '' THEN LET dFechaVencido2 = DATE(1); END IF;
		
		IF dFechaVencido < dFechaVencido2 THEN LET cProcesar = '9'; LET iTotalaEnviar = iTotalaEnviar - 1; LET pDiaProcesar = ''; END IF;
		
		BEGIN WORK;
		UPDATE "informix".cb_vencidos_findemes
		   SET 	motivo_exclusion			= cExclusion,
				num_vencidos_diaant 		= sNumVencidos,
				pago_minimo 				= dPagoMinimo,
				sdo_total_liquidar_diaant 	= dSdoTotalLiquidar,
				sdo_vencido_diaante 		= dSdoVencido,
				sdo_insoluto_diaante 		= dSdoInsoluto,
				pagos_realizados 			= dMontoUltimoPago,
				num_envios_camp1 			= sNumEnviosCamp1,
				num_envios_camp2 			= sNumEnviosCamp2,
				status_vencidos 			= cStatusVencidos,
				status_situacion 			= cStatusSituacion,
				procesar					= cProcesar,
				dia_procesar				= pDiaProcesar
		 WHERE fecha		= dFecha
		   AND campania		= cCampania
		   AND num_credito	= cNumCredito;
		COMMIT WORK;
		
		LET cExclusion			= '';
		LET sNumVencidos		= 0;
		LET dPagoMinimo			= 0;
		LET dSdoTotalLiquidar	= 0;
		LET dSdoVencido			= 0;
		LET dSdoInsoluto		= 0;
		LET cFecha_ultimo_pago	= DATE(1);
		LET dMontoUltimoPago	= 0;
		LET sNumEnviosCamp1		= 0;
		LET sNumEnviosCamp2		= 0;
		LET cStatusVencidos		= '';
		LET cStatusSituacion	= '';
		LET cProcesar			= '';
		LET pDiaProcesar		= '';
		LET cNumProducto		= '';

	END FOREACH;

	DROP TABLE ctes_ctaspzo;

	--Genera cifras de control
	LET cMensaje = ' ------- Cifras de Control campana PP_VTAC6PV ------- ';
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

	LET cMensaje = '';
	LET cMensaje = 'TOTAL Cuentas vencidas procesadas : ' ||iTotalCuentasVencidas;
	LET cMensaje = trim(cMensaje) ||'    Cuentas excluidas X situacion especial: ' ||iTotalExcluidasXSitEsp;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = '';
	LET cMensaje = 'Cuentas excluidas X proceso de aclaracion : ' ||iTotalExcluidasXAclara;
	LET cMensaje = trim(cMensaje) ||'    Cuentas excluidas X convenio activo : ' ||iTotalExcluidasXConvAct;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = '';
	LET cMensaje = 'Cuentas excluidas X saldo menor a 100 pesos : ' ||iTotalExcluidasXSaldo;
	LET cMensaje = trim(cMensaje) ||'    Cuentas a enviar : ' ||iTotalaEnviar;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	--Genera cifras de control

	LET cMensaje = '';
	LET iTotalExcluidasXSitEsp	= 0;
	LET iTotalExcluidasXAclara	= 0;
	LET iTotalExcluidasXConvAct	= 0;
	LET iTotalExcluidasXSaldo	= 0;
	LET iTotalaEnviar			= 0;
	LET	iTotalCuentasVencidas	= 0;
	LET pDiaProcesar			= '';

-----------------------------------------------------------------	
-- Genera campana PP_CAIDA3M
-----------------------------------------------------------------
	SELECT 
		ven.fecha,ven.campania,ven.num_credito,ven.numcte,ven.procesar,ven.fecha_vencido,mae.status_cred,mas.mto_venc_trasp+mas.monto_vencido mto_venc_trasp,ven.sdo_vencido,mas.mto_fin_ven_trasp,mas.sdo_cap_insoluto,
		mas.sdo_intereses,mas.int_tra_no_exig,mas.mto_venc_int,mas.sdo_no_exig,mas.mto_finan_vdo,mas.sdo_moratorio,mas.sdo_contab_mora,suc.iva,ven.num_producto
	  FROM "informix".cb_vencidos_findemes ven
	 INNER JOIN bdicred:"informix".sd_maecredcrd mae ON mae.num_credito = ven.num_credito
	 INNER JOIN bdicred:"informix".sd_maesdoscrd mas ON mas.num_credito = ven.num_credito
	 INNER JOIN bdinteg:"informix".si_sucursales suc ON suc.empresa = mae.empresa AND suc.sucursal = mae.sucursal
	 WHERE ven.fecha = dFechaaProcesar
	   AND ven.campania = 'PP_CAIDA3M'
	   AND ven.procesar = '0'
	INTO TEMP ctes_ctaspzo WITH NO LOG;

	CREATE INDEX ind_vencido_tmp ON ctes_ctaspzo(fecha);
	UPDATE STATISTICS MEDIUM FOR TABLE ctes_ctaspzo;

	-- Selecciona todos los vencidos e indetifica el tipo de campana para crear el universo a trabajar en el mes
	FOREACH WITH HOLD
		SELECT fecha,campania,num_credito,numcte,procesar,fecha_vencido,status_cred,mto_venc_trasp,sdo_vencido,mto_fin_ven_trasp,sdo_cap_insoluto,
			sdo_cap_insoluto + sdo_intereses + int_tra_no_exig + mto_venc_int + sdo_no_exig + (mto_finan_vdo + sdo_moratorio + sdo_contab_mora) * (1 + iva) sdo_total_liquidar,num_producto
		  INTO dFecha,cCampania,cNumCredito,cNumcte,cProcesar,dFechaVencido,cStatusCred,dSdoVencido,dSdoVencidoAct,sNumVencidos,dSdoInsoluto,dSdoTotalLiquidar,cNumProducto
		  FROM ctes_ctaspzo WHERE fecha = dFechaaProcesar

		LET	iTotalCuentasVencidas	= iTotalCuentasVencidas + 1;

	-- Valida motivo de exclusiones, si tiene
		EXECUTE PROCEDURE "informix".sp_identifica_exclusiones(cEmpresa,cNumCredito,cNumcte) INTO P_COD_RET,cExclusion;

		IF 	 cExclusion = '1' 	THEN 	LET	iTotalExcluidasXSitEsp	= iTotalExcluidasXSitEsp + 1;
		ELIF cExclusion = '2' 	THEN 	LET	iTotalExcluidasXAclara	= iTotalExcluidasXAclara + 1;
		ELIF cExclusion = '3' 	THEN 	LET	iTotalExcluidasXConvAct	= iTotalExcluidasXConvAct + 1;
		ELIF cExclusion = '4' 	THEN 	LET	iTotalExcluidasXSaldo	= iTotalExcluidasXSaldo + 1;
		END IF;
		
		IF cExclusion != '0' THEN LET cProcesar = '0'; ELSE LET cProcesar = '1'; LET iTotalaEnviar = iTotalaEnviar + 1; LET pDiaProcesar = pDiaEjecucion; END IF;

		SELECT fecha_ult_pago INTO cFecha_ultimo_pago 
		  FROM  bdicred:"informix".sd_maecredanexocrd
		WHERE empresa 		= cEmpresa
		  AND num_credito 	= cNumCredito;

		SELECT NVL(SUM(monto),0) INTO dMontoUltimoPago
		FROM bdicred:"informix".sd_movhiscrd 
		WHERE empresa = cEmpresa 
		AND fecha_mov = cFecha_ultimo_pago
		AND num_credito = cNumCredito
		AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd WHERE num_producto = cNumProducto) 
		AND codigo_ref = 1 AND reversado = "N";

		IF dSdoVencido < dSdoVencidoAct THEN
			LET cStatusVencidos = 'MEJORA';
		ELIF dSdoVencido = dSdoVencidoAct THEN
			LET cStatusVencidos = 'ESTABLE';
		ELIF dSdoVencido > dSdoVencidoAct THEN
			LET cStatusVencidos = 'DETERIORO';
		END IF;

		IF cStatusCred = 'CV' THEN
			LET cStatusSituacion = 'VENDIDO';
		ELIF cStatusCred = 'FF' THEN
			LET cStatusSituacion = 'LIQUIDADO';
		ELIF cStatusCred = 'FI' THEN
			LET cStatusSituacion = 'INMATERIAL';
		ELIF cStatusCred = 'FC' THEN
			LET cStatusSituacion = 'REESTRUCTURADO';
		ELIF cStatusCred = 'AA' THEN
			LET cStatusSituacion = 'VIGENTE';
		ELIF cStatusCred = 'BT' THEN
			LET cStatusSituacion = 'VENCIDO';
		ELIF cStatusCred = 'BA' THEN
			LET cStatusSituacion = 'VENCIDO_TRANSITORIO';
		ELIF cStatusCred IN ('E1','E2','E3') THEN
			SELECT descripcion INTO cDescripcion FROM bdicred:sd_tipocartera WHERE empresa = cEmpresa AND status_cred = cStatusCred;
			LET cStatusSituacion = TRIM(cDescripcion);
		END IF;

		IF ((cFecha_ultimo_pago >= mdy(MONTH(TODAY),1,YEAR(TODAY))) AND (cFecha_ultimo_pago <= mdy(MONTH(TODAY),pDiaEjecucion,YEAR(TODAY)))) THEN
			LET cProcesar = '9';
			LET	iTotalaEnviar = iTotalaEnviar - 1;
			LET pDiaProcesar = '';
		END IF;

		BEGIN WORK;
		UPDATE "informix".cb_vencidos_findemes
		   SET 	motivo_exclusion			= cExclusion,
				num_vencidos_diaant 		= sNumVencidos,
				pago_minimo 				= dPagoMinimo,
				sdo_total_liquidar_diaant 	= dSdoTotalLiquidar,
				sdo_vencido_diaante 		= dSdoVencido,
				sdo_insoluto_diaante 		= dSdoInsoluto,
				pagos_realizados 			= dMontoUltimoPago,
				num_envios_camp1 			= sNumEnviosCamp1,
				num_envios_camp2 			= sNumEnviosCamp2,
				status_vencidos 			= cStatusVencidos,
				status_situacion 			= cStatusSituacion,
				procesar					= cProcesar,
				dia_procesar				= pDiaProcesar
		 WHERE fecha		= dFecha
		   AND campania		= cCampania
		   AND num_credito	= cNumCredito;
		COMMIT WORK;

		LET cExclusion			= '';
		LET sNumVencidos		= 0;
		LET dPagoMinimo			= 0;
		LET dSdoTotalLiquidar	= 0;
		LET dSdoVencido			= 0;
		LET dSdoInsoluto		= 0;
		LET cFecha_ultimo_pago	= DATE(1);
		LET dMontoUltimoPago	= 0;
		LET sNumEnviosCamp1		= 0;
		LET sNumEnviosCamp2		= 0;
		LET cStatusVencidos		= '';
		LET cStatusSituacion	= '';
		LET cProcesar			= '';
		LET pDiaProcesar		= '';
		LET cNumProducto		= '';

	END FOREACH;

	DROP TABLE ctes_ctaspzo;

	--Genera cifras de control
	LET cMensaje = ' ------- Cifras de Control campana PP_CAIDA3M ------- ';
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

	LET cMensaje = '';
	LET cMensaje = 'TOTAL Cuentas vencidas procesadas : ' ||iTotalCuentasVencidas;
	LET cMensaje = trim(cMensaje) ||'    Cuentas excluidas X situacion especial: ' ||iTotalExcluidasXSitEsp;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = '';
	LET cMensaje = 'Cuentas excluidas X proceso de aclaracion : ' ||iTotalExcluidasXAclara;
	LET cMensaje = trim(cMensaje) ||'    Cuentas excluidas X convenio activo : ' ||iTotalExcluidasXConvAct;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = '';
	LET cMensaje = 'Cuentas excluidas X saldo menor a 100 pesos : ' ||iTotalExcluidasXSaldo;
	LET cMensaje = trim(cMensaje) ||'    Cuentas a enviar : ' ||iTotalaEnviar;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	--Genera cifras de control

	LET cMensaje = '';
	LET iTotalExcluidasXSitEsp	= 0;
	LET iTotalExcluidasXAclara	= 0;
	LET iTotalExcluidasXConvAct	= 0;
	LET iTotalExcluidasXSaldo	= 0;
	LET iTotalaEnviar			= 0;
	LET	iTotalCuentasVencidas	= 0;
	LET pDiaProcesar			= '';

-----------------------------------------------------------------
-- Genera campana PP_CAIDA2M
-----------------------------------------------------------------
	SELECT 
		ven.fecha,ven.campania,ven.num_credito,ven.numcte,ven.procesar,ven.fecha_vencido,mae.status_cred,mas.mto_venc_trasp+mas.monto_vencido mto_venc_trasp,ven.sdo_vencido,mas.mto_fin_ven_trasp,mas.sdo_cap_insoluto,
		mas.sdo_intereses,mas.int_tra_no_exig,mas.mto_venc_int,mas.sdo_no_exig,mas.mto_finan_vdo,mas.sdo_moratorio,mas.sdo_contab_mora,suc.iva,ven.num_producto
	  FROM "informix".cb_vencidos_findemes ven
	 INNER JOIN bdicred:"informix".sd_maecredcrd mae ON mae.num_credito = ven.num_credito
	 INNER JOIN bdicred:"informix".sd_maesdoscrd mas ON mas.num_credito = ven.num_credito AND mas.mto_fin_ven_trasp = 2
	 INNER JOIN bdinteg:"informix".si_sucursales suc ON suc.empresa = mae.empresa AND suc.sucursal = mae.sucursal
	 WHERE ven.fecha = dFechaaProcesar
	   AND ven.campania = 'PP_CAIDA2M'
	   AND ven.procesar = '0'
	INTO TEMP ctes_ctaspzo WITH NO LOG;

	CREATE INDEX ind_vencido_tmp ON ctes_ctaspzo(fecha);
	UPDATE STATISTICS MEDIUM FOR TABLE ctes_ctaspzo;

	-- Selecciona todos los vencidos e indetifica el tipo de campana para crear el universo a trabajar en el mes
	FOREACH WITH HOLD
		SELECT fecha,campania,num_credito,numcte,procesar,fecha_vencido,status_cred,mto_venc_trasp,sdo_vencido,mto_fin_ven_trasp,sdo_cap_insoluto,
			sdo_cap_insoluto + sdo_intereses + int_tra_no_exig + mto_venc_int + sdo_no_exig + (mto_finan_vdo + sdo_moratorio + sdo_contab_mora) * (1 + iva) sdo_total_liquidar,num_producto
		  INTO dFecha,cCampania,cNumCredito,cNumcte,cProcesar,dFechaVencido,cStatusCred,dSdoVencido,dSdoVencidoAct,sNumVencidos,dSdoInsoluto,dSdoTotalLiquidar,cNumProducto
		  FROM ctes_ctaspzo WHERE fecha = dFechaaProcesar

		LET	iTotalCuentasVencidas	= iTotalCuentasVencidas + 1;

	-- Valida motivo de exclusiones, si tiene
		EXECUTE PROCEDURE "informix".sp_identifica_exclusiones(cEmpresa,cNumCredito,cNumcte) INTO P_COD_RET,cExclusion;

		IF 	 cExclusion = '1' 	THEN 	LET	iTotalExcluidasXSitEsp	= iTotalExcluidasXSitEsp + 1;
		ELIF cExclusion = '2' 	THEN 	LET	iTotalExcluidasXAclara	= iTotalExcluidasXAclara + 1;
		ELIF cExclusion = '3' 	THEN 	LET	iTotalExcluidasXConvAct	= iTotalExcluidasXConvAct + 1;
		ELIF cExclusion = '4' 	THEN 	LET	iTotalExcluidasXSaldo	= iTotalExcluidasXSaldo + 1;
		END IF;
		
		IF cExclusion != '0' THEN LET cProcesar = '0'; ELSE LET cProcesar = '1'; LET iTotalaEnviar = iTotalaEnviar + 1; LET pDiaProcesar = pDiaEjecucion; END IF;

		SELECT fecha_ultimo_pago INTO cFecha_ultimo_pago 
		  FROM  bdicred:"informix".sd_indicador_cred_crd
		WHERE empresa 		= cEmpresa
		  AND num_credito 	= cNumCredito;

		SELECT NVL(SUM(monto),0) INTO dMontoUltimoPago
		FROM bdicred:"informix".sd_movhiscrd 
		WHERE empresa = cEmpresa 
		AND fecha_mov = cFecha_ultimo_pago
		AND num_credito = cNumCredito
		AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd WHERE num_producto = cNumProducto) 
		AND codigo_ref = 1 AND reversado = "N";

		IF dSdoVencido < dSdoVencidoAct THEN
			LET cStatusVencidos = 'MEJORA';
		ELIF dSdoVencido = dSdoVencidoAct THEN
			LET cStatusVencidos = 'ESTABLE';
		ELIF dSdoVencido > dSdoVencidoAct THEN
			LET cStatusVencidos = 'DETERIORO';
		END IF;

		IF cStatusCred = 'CV' THEN
			LET cStatusSituacion = 'VENDIDO';
		ELIF cStatusCred = 'FF' THEN
			LET cStatusSituacion = 'LIQUIDADO';
		ELIF cStatusCred = 'FI' THEN
			LET cStatusSituacion = 'INMATERIAL';
		ELIF cStatusCred = 'FC' THEN
			LET cStatusSituacion = 'REESTRUCTURADO';
		ELIF cStatusCred = 'AA' THEN
			LET cStatusSituacion = 'VIGENTE';
		ELIF cStatusCred = 'BT' THEN
			LET cStatusSituacion = 'VENCIDO';
		ELIF cStatusCred = 'BA' THEN
			LET cStatusSituacion = 'VENCIDO_TRANSITORIO';
		ELIF cStatusCred IN ('E1','E2','E3') THEN
			SELECT descripcion INTO cDescripcion FROM bdicred:sd_tipocartera WHERE empresa = cEmpresa AND status_cred = cStatusCred;
			LET cStatusSituacion = TRIM(cDescripcion);
		END IF;

	-- Valida si realizo pago correspondiente a una mensualidad completa
		SELECT MIN(fecha_cuota) INTO dFechaVencido2
		FROM bdicred:"informix".sd_amortiza_creditocrd
		WHERE empresa 		= cEmpresa
		  AND num_credito 	= cNumCredito
		  AND capital_status IN ('6','7','2');
		
		IF dFechaVencido2 IS NULL OR dFechaVencido2 = '' THEN LET dFechaVencido2 = DATE(1); END IF;
		
		IF dFechaVencido < dFechaVencido2 THEN LET cProcesar = 9; LET iTotalaEnviar = iTotalaEnviar - 1; LET pDiaProcesar = ''; END IF;
		
		BEGIN WORK;
		UPDATE "informix".cb_vencidos_findemes
		   SET 	motivo_exclusion			= cExclusion,
				num_vencidos_diaant 		= sNumVencidos,
				pago_minimo 				= dPagoMinimo,
				sdo_total_liquidar_diaant 	= dSdoTotalLiquidar,
				sdo_vencido_diaante 		= dSdoVencido,
				sdo_insoluto_diaante 		= dSdoInsoluto,
				pagos_realizados 			= dMontoUltimoPago,
				num_envios_camp1 			= sNumEnviosCamp1,
				num_envios_camp2 			= sNumEnviosCamp2,
				status_vencidos 			= cStatusVencidos,
				status_situacion 			= cStatusSituacion,
				procesar					= cProcesar,
				dia_procesar				= pDiaProcesar
		 WHERE fecha		= dFecha
		   AND campania		= cCampania
		   AND num_credito	= cNumCredito;
		COMMIT WORK;
		
		LET cExclusion			= '';
		LET sNumVencidos		= 0;
		LET dPagoMinimo			= 0;
		LET dSdoTotalLiquidar	= 0;
		LET dSdoVencido			= 0;
		LET dSdoInsoluto		= 0;
		LET cFecha_ultimo_pago	= DATE(1);
		LET dMontoUltimoPago	= 0;
		LET sNumEnviosCamp1		= 0;
		LET sNumEnviosCamp2		= 0;
		LET cStatusVencidos		= '';
		LET cStatusSituacion	= '';
		LET cProcesar			= '';
		LET pDiaProcesar		= '';
		LET cNumProducto		= '';

	END FOREACH;

	DROP TABLE ctes_ctaspzo;

	--Genera cifras de control
	LET cMensaje = ' ------- Cifras de Control campana PP_CAIDA2M ------- ';
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

	LET cMensaje = '';
	LET cMensaje = 'TOTAL Cuentas vencidas procesadas : ' ||iTotalCuentasVencidas;
	LET cMensaje = trim(cMensaje) ||'    Cuentas excluidas X situacion especial: ' ||iTotalExcluidasXSitEsp;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = '';
	LET cMensaje = 'Cuentas excluidas X proceso de aclaracion : ' ||iTotalExcluidasXAclara;
	LET cMensaje = trim(cMensaje) ||'    Cuentas excluidas X convenio activo : ' ||iTotalExcluidasXConvAct;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = '';
	LET cMensaje = 'Cuentas excluidas X saldo menor a 100 pesos : ' ||iTotalExcluidasXSaldo;
	LET cMensaje = trim(cMensaje) ||'    Cuentas a enviar : ' ||iTotalaEnviar;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	--Genera cifras de control

	LET cMensaje = '';
	LET iTotalExcluidasXSitEsp	= 0;
	LET iTotalExcluidasXAclara	= 0;
	LET iTotalExcluidasXConvAct	= 0;
	LET iTotalExcluidasXSaldo	= 0;
	LET iTotalaEnviar			= 0;
	LET	iTotalCuentasVencidas	= 0;
	LET pDiaProcesar			= '';

-----------------------------------------------------------------
-- Genera campana PP_CAIDA1M
-----------------------------------------------------------------
	SELECT 
		ven.fecha,ven.campania,ven.num_credito,ven.numcte,ven.procesar,ven.fecha_vencido,mae.status_cred,mas.mto_venc_trasp+mas.monto_vencido mto_venc_trasp,ven.sdo_vencido,mas.mto_fin_ven_trasp,mas.sdo_cap_insoluto,
		mas.sdo_intereses,mas.int_tra_no_exig,mas.mto_venc_int,mas.sdo_no_exig,mas.mto_finan_vdo,mas.sdo_moratorio,mas.sdo_contab_mora,suc.iva,ven.num_producto
	  FROM "informix".cb_vencidos_findemes ven
	 INNER JOIN bdicred:"informix".sd_maecredcrd mae ON mae.num_credito = ven.num_credito
	 INNER JOIN bdicred:"informix".sd_maesdoscrd mas ON mas.num_credito = ven.num_credito AND mas.mto_fin_ven_trasp = 1
	 INNER JOIN bdinteg:"informix".si_sucursales suc ON suc.empresa = mae.empresa AND suc.sucursal = mae.sucursal
	 WHERE ven.fecha = dFechaaProcesar
	   AND ven.campania = 'PP_CAIDA1M'
	   AND ven.procesar = '0'
	INTO TEMP ctes_ctaspzo WITH NO LOG;

	CREATE INDEX ind_vencido_tmp ON ctes_ctaspzo(fecha);
	UPDATE STATISTICS MEDIUM FOR TABLE ctes_ctaspzo;

	-- Selecciona todos los vencidos e indetifica el tipo de campana para crear el universo a trabajar en el mes
	FOREACH WITH HOLD
		SELECT fecha,campania,num_credito,numcte,procesar,fecha_vencido,status_cred,mto_venc_trasp,sdo_vencido,mto_fin_ven_trasp,sdo_cap_insoluto,
			sdo_cap_insoluto + sdo_intereses + int_tra_no_exig + mto_venc_int + sdo_no_exig + (mto_finan_vdo + sdo_moratorio + sdo_contab_mora) * (1 + iva) sdo_total_liquidar,num_producto
		  INTO dFecha,cCampania,cNumCredito,cNumcte,cProcesar,dFechaVencido,cStatusCred,dSdoVencido,dSdoVencidoAct,sNumVencidos,dSdoInsoluto,dSdoTotalLiquidar,cNumProducto
		  FROM ctes_ctaspzo WHERE fecha = dFechaaProcesar

		LET	iTotalCuentasVencidas	= iTotalCuentasVencidas + 1;

	-- Valida motivo de exclusiones, si tiene
		EXECUTE PROCEDURE "informix".sp_identifica_exclusiones(cEmpresa,cNumCredito,cNumcte) INTO P_COD_RET,cExclusion;

		IF 	 cExclusion = '1' 	THEN 	LET	iTotalExcluidasXSitEsp	= iTotalExcluidasXSitEsp + 1;
		ELIF cExclusion = '2' 	THEN 	LET	iTotalExcluidasXAclara	= iTotalExcluidasXAclara + 1;
		ELIF cExclusion = '3' 	THEN 	LET	iTotalExcluidasXConvAct	= iTotalExcluidasXConvAct + 1;
		ELIF cExclusion = '4' 	THEN 	LET	iTotalExcluidasXSaldo	= iTotalExcluidasXSaldo + 1;
		END IF;
		
		IF cExclusion != '0' THEN LET cProcesar = '0'; ELSE LET cProcesar = '1'; LET iTotalaEnviar = iTotalaEnviar + 1; LET pDiaProcesar = pDiaEjecucion; END IF;

		SELECT fecha_ultimo_pago INTO cFecha_ultimo_pago 
		  FROM  bdicred:"informix".sd_indicador_cred_crd
		WHERE empresa 		= cEmpresa
		  AND num_credito 	= cNumCredito;

		SELECT NVL(SUM(monto),0) INTO dMontoUltimoPago
		FROM bdicred:"informix".sd_movhiscrd 
		WHERE empresa = cEmpresa 
		AND fecha_mov = cFecha_ultimo_pago
		AND num_credito = cNumCredito
		AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd WHERE num_producto = cNumProducto) 
		AND codigo_ref = 1 AND reversado = "N";

		IF dSdoVencido < dSdoVencidoAct THEN
			LET cStatusVencidos = 'MEJORA';
		ELIF dSdoVencido = dSdoVencidoAct THEN
			LET cStatusVencidos = 'ESTABLE';
		ELIF dSdoVencido > dSdoVencidoAct THEN
			LET cStatusVencidos = 'DETERIORO';
		END IF;

		IF cStatusCred = 'CV' THEN
			LET cStatusSituacion = 'VENDIDO';
		ELIF cStatusCred = 'FF' THEN
			LET cStatusSituacion = 'LIQUIDADO';
		ELIF cStatusCred = 'FI' THEN
			LET cStatusSituacion = 'INMATERIAL';
		ELIF cStatusCred = 'FC' THEN
			LET cStatusSituacion = 'REESTRUCTURADO';
		ELIF cStatusCred = 'AA' THEN
			LET cStatusSituacion = 'VIGENTE';
		ELIF cStatusCred = 'BT' THEN
			LET cStatusSituacion = 'VENCIDO';
		ELIF cStatusCred = 'BA' THEN
			LET cStatusSituacion = 'VENCIDO_TRANSITORIO';
		ELIF cStatusCred IN ('E1','E2','E3') THEN
			SELECT descripcion INTO cDescripcion FROM bdicred:sd_tipocartera WHERE empresa = cEmpresa AND status_cred = cStatusCred;
			LET cStatusSituacion = TRIM(cDescripcion);
		END IF;

	-- Valida si realizo pago correspondiente a una mensualidad completa
		SELECT MIN(fecha_cuota) INTO dFechaVencido2
		FROM bdicred:"informix".sd_amortiza_creditocrd
		WHERE empresa 		= cEmpresa
		  AND num_credito 	= cNumCredito
		  AND capital_status IN ('6','7','2');
		
		IF dFechaVencido2 IS NULL OR dFechaVencido2 = '' THEN LET dFechaVencido2 = DATE(1); END IF;
		
		IF dFechaVencido < dFechaVencido2 THEN LET cProcesar = '9'; LET	iTotalaEnviar = iTotalaEnviar - 1; LET pDiaProcesar = ''; END IF;
		
		BEGIN WORK;
		UPDATE "informix".cb_vencidos_findemes
		   SET 	motivo_exclusion			= cExclusion,
				num_vencidos_diaant 		= sNumVencidos,
				pago_minimo 				= dPagoMinimo,
				sdo_total_liquidar_diaant 	= dSdoTotalLiquidar,
				sdo_vencido_diaante 		= dSdoVencido,
				sdo_insoluto_diaante 		= dSdoInsoluto,
				pagos_realizados 			= dMontoUltimoPago,
				num_envios_camp1 			= sNumEnviosCamp1,
				num_envios_camp2 			= sNumEnviosCamp2,
				status_vencidos 			= cStatusVencidos,
				status_situacion 			= cStatusSituacion,
				procesar					= cProcesar,
				dia_procesar				= pDiaProcesar
		 WHERE fecha		= dFecha
		   AND campania		= cCampania
		   AND num_credito	= cNumCredito;
		COMMIT WORK;

		LET cExclusion			= '';
		LET sNumVencidos		= 0;
		LET dPagoMinimo			= 0;
		LET dSdoTotalLiquidar	= 0;
		LET dSdoVencido			= 0;
		LET dSdoInsoluto		= 0;
		LET cFecha_ultimo_pago	= DATE(1);
		LET dMontoUltimoPago	= 0;
		LET sNumEnviosCamp1		= 0;
		LET sNumEnviosCamp2		= 0;
		LET cStatusVencidos		= '';
		LET cStatusSituacion	= '';
		LET cProcesar			= '';
		LET pDiaProcesar		= '';
		LET cNumProducto		= '';

	END FOREACH;

	DROP TABLE ctes_ctaspzo;

	--Genera cifras de control
	LET cMensaje = ' ------- Cifras de Control campana PP_CAIDA1M ------- ';
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

	LET cMensaje = '';
	LET cMensaje = 'TOTAL Cuentas vencidas procesadas : ' ||iTotalCuentasVencidas;
	LET cMensaje = trim(cMensaje) ||'    Cuentas excluidas X situacion especial: ' ||iTotalExcluidasXSitEsp;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = '';
	LET cMensaje = 'Cuentas excluidas X proceso de aclaracion : ' ||iTotalExcluidasXAclara;
	LET cMensaje = trim(cMensaje) ||'    Cuentas excluidas X convenio activo : ' ||iTotalExcluidasXConvAct;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = '';
	LET cMensaje = 'Cuentas excluidas X saldo menor a 100 pesos : ' ||iTotalExcluidasXSaldo;
	LET cMensaje = trim(cMensaje) ||'    Cuentas a enviar : ' ||iTotalaEnviar;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	--Genera cifras de control

	LET cMensaje = '';
	LET iTotalExcluidasXSitEsp	= 0;
	LET iTotalExcluidasXAclara	= 0;
	LET iTotalExcluidasXConvAct	= 0;
	LET iTotalExcluidasXSaldo	= 0;
	LET iTotalaEnviar			= 0;
	LET pDiaProcesar			= '';

END IF;

-----------------------------------------------------------------
-- Gestion de los dias restantes
-----------------------------------------------------------------
IF pDiaEjecucion IN ('7','12','22','28') THEN
-----------------------------------------------------------------
-- Genera campana PP_VTAC6PV
-----------------------------------------------------------------
	SELECT 
		ven.fecha,ven.campania,ven.num_credito,ven.numcte,ven.procesar,ven.fecha_vencido,mae.status_cred,mas.mto_venc_trasp+mas.monto_vencido mto_venc_trasp,ven.sdo_vencido,mas.mto_fin_ven_trasp,mas.sdo_cap_insoluto,
		mas.sdo_intereses,mas.int_tra_no_exig,mas.mto_venc_int,mas.sdo_no_exig,mas.mto_finan_vdo,mas.sdo_moratorio,mas.sdo_contab_mora,suc.iva,ven.num_producto
	  FROM "informix".cb_vencidos_findemes ven
	 INNER JOIN bdicred:"informix".sd_maecredcrd mae ON mae.num_credito = ven.num_credito
	 INNER JOIN bdicred:"informix".sd_maesdoscrd mas ON mas.num_credito = ven.num_credito AND mas.mto_fin_ven_trasp >= 6
	 INNER JOIN bdinteg:"informix".si_sucursales suc ON suc.empresa = mae.empresa AND suc.sucursal = mae.sucursal
	 WHERE ven.fecha = dFechaaProcesar
	   AND ven.campania = 'PP_VTAC6PV'
	   AND ven.dia_corte >= pDiaEjecucion
	   AND ven.procesar in ('0','1')
	INTO TEMP ctes_ctaspzo WITH NO LOG;

	CREATE INDEX ind_vencido_tmp ON ctes_ctaspzo(fecha);
	UPDATE STATISTICS MEDIUM FOR TABLE ctes_ctaspzo;

	-- Selecciona todos los vencidos e indetifica el tipo de campana para crear el universo a trabajar en el mes
	FOREACH WITH HOLD
		SELECT fecha,campania,num_credito,numcte,procesar,fecha_vencido,status_cred,mto_venc_trasp,sdo_vencido,mto_fin_ven_trasp,sdo_cap_insoluto,
			sdo_cap_insoluto + sdo_intereses + int_tra_no_exig + mto_venc_int + sdo_no_exig + (mto_finan_vdo + sdo_moratorio + sdo_contab_mora) * (1 + iva) sdo_total_liquidar,num_producto
		  INTO dFecha,cCampania,cNumCredito,cNumcte,cProcesar,dFechaVencido,cStatusCred,dSdoVencido,dSdoVencidoAct,sNumVencidos,dSdoInsoluto,dSdoTotalLiquidar,cNumProducto
		  FROM ctes_ctaspzo WHERE fecha = dFechaaProcesar

		LET	iTotalCuentasVencidas	= iTotalCuentasVencidas + 1;

	-- Valida motivo de exclusiones, si tiene
		EXECUTE PROCEDURE "informix".sp_identifica_exclusiones(cEmpresa,cNumCredito,cNumcte) INTO P_COD_RET,cExclusion;

		IF 	 cExclusion = '1' 	THEN 	LET	iTotalExcluidasXSitEsp	= iTotalExcluidasXSitEsp + 1;
		ELIF cExclusion = '2' 	THEN 	LET	iTotalExcluidasXAclara	= iTotalExcluidasXAclara + 1;
		ELIF cExclusion = '3' 	THEN 	LET	iTotalExcluidasXConvAct	= iTotalExcluidasXConvAct + 1;
		ELIF cExclusion = '4' 	THEN 	LET	iTotalExcluidasXSaldo	= iTotalExcluidasXSaldo + 1;
		END IF;
		
		IF cExclusion != '0' THEN LET cProcesar = '0'; ELSE LET cProcesar = '1'; LET iTotalaEnviar = iTotalaEnviar + 1; LET pDiaProcesar = pDiaEjecucion; END IF;

		SELECT fecha_ult_pago INTO cFecha_ultimo_pago 
		  FROM  bdicred:"informix".sd_maecredanexocrd
		WHERE empresa 		= cEmpresa
		  AND num_credito 	= cNumCredito;

		SELECT NVL(SUM(monto),0) INTO dMontoUltimoPago
		FROM bdicred:"informix".sd_movhiscrd 
		WHERE empresa = cEmpresa 
		AND fecha_mov = cFecha_ultimo_pago
		AND num_credito = cNumCredito
		AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd WHERE num_producto = cNumProducto) 
		AND codigo_ref = 1 AND reversado = "N";

		IF dSdoVencido < dSdoVencidoAct THEN
			LET cStatusVencidos = 'MEJORA';
		ELIF dSdoVencido = dSdoVencidoAct THEN
			LET cStatusVencidos = 'ESTABLE';
		ELIF dSdoVencido > dSdoVencidoAct THEN
			LET cStatusVencidos = 'DETERIORO';
		END IF;

		IF cStatusCred = 'CV' THEN
			LET cStatusSituacion = 'VENDIDO';
		ELIF cStatusCred = 'FF' THEN
			LET cStatusSituacion = 'LIQUIDADO';
		ELIF cStatusCred = 'FI' THEN
			LET cStatusSituacion = 'INMATERIAL';
		ELIF cStatusCred = 'FC' THEN
			LET cStatusSituacion = 'REESTRUCTURADO';
		ELIF cStatusCred = 'AA' THEN
			LET cStatusSituacion = 'VIGENTE';
		ELIF cStatusCred = 'BT' THEN
			LET cStatusSituacion = 'VENCIDO';
		ELIF cStatusCred = 'BA' THEN
			LET cStatusSituacion = 'VENCIDO_TRANSITORIO';
		ELIF cStatusCred IN ('E1','E2','E3') THEN
			SELECT descripcion INTO cDescripcion FROM bdicred:sd_tipocartera WHERE empresa = cEmpresa AND status_cred = cStatusCred;
			LET cStatusSituacion = TRIM(cDescripcion);
		END IF;

	-- Valida si realizo pago correspondiente a una mensualidad completa
		SELECT MIN(fecha_cuota) INTO dFechaVencido2
		FROM bdicred:"informix".sd_amortiza_creditocrd
		WHERE empresa 		= cEmpresa
		  AND num_credito 	= cNumCredito
		  AND capital_status IN ('6','7','2');
		
		IF dFechaVencido2 IS NULL OR dFechaVencido2 = '' THEN LET dFechaVencido2 = DATE(1); END IF;
		
		IF dFechaVencido < dFechaVencido2 THEN LET cProcesar = '9'; LET	iTotalaEnviar = iTotalaEnviar - 1; LET pDiaProcesar = ''; END IF;
		
		BEGIN WORK;
		UPDATE "informix".cb_vencidos_findemes
		   SET 	motivo_exclusion			= cExclusion,
				num_vencidos_diaant 		= sNumVencidos,
				pago_minimo 				= dPagoMinimo,
				sdo_total_liquidar_diaant 	= dSdoTotalLiquidar,
				sdo_vencido_diaante 		= dSdoVencido,
				sdo_insoluto_diaante 		= dSdoInsoluto,
				pagos_realizados 			= dMontoUltimoPago,
				num_envios_camp1 			= sNumEnviosCamp1,
				num_envios_camp2 			= sNumEnviosCamp2,
				status_vencidos 			= cStatusVencidos,
				status_situacion 			= cStatusSituacion,
				procesar					= cProcesar,
				dia_procesar				= pDiaProcesar
		 WHERE fecha		= dFecha
		   AND campania		= cCampania
		   AND num_credito	= cNumCredito;
		COMMIT WORK;
		
		LET cExclusion			= '';
		LET sNumVencidos		= 0;
		LET dPagoMinimo			= 0;
		LET dSdoTotalLiquidar	= 0;
		LET dSdoVencido			= 0;
		LET dSdoInsoluto		= 0;
		LET cFecha_ultimo_pago	= DATE(1);
		LET dMontoUltimoPago	= 0;
		LET sNumEnviosCamp1		= 0;
		LET sNumEnviosCamp2		= 0;
		LET cStatusVencidos		= '';
		LET cStatusSituacion	= '';
		LET cProcesar			= '';
		LET pDiaProcesar		= '';
		LET cNumProducto		= '';

	END FOREACH;

	DROP TABLE ctes_ctaspzo;

	--Genera cifras de control
	LET cMensaje = ' ------- Cifras de Control campana PP_VTAC6PV ------- ';
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

	LET cMensaje = '';
	LET cMensaje = 'TOTAL Cuentas vencidas procesadas : ' ||iTotalCuentasVencidas;
	LET cMensaje = trim(cMensaje) ||'    Cuentas excluidas X situacion especial: ' ||iTotalExcluidasXSitEsp;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = '';
	LET cMensaje = 'Cuentas excluidas X proceso de aclaracion : ' ||iTotalExcluidasXAclara;
	LET cMensaje = trim(cMensaje) ||'    Cuentas excluidas X convenio activo : ' ||iTotalExcluidasXConvAct;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = '';
	LET cMensaje = 'Cuentas excluidas X saldo menor a 100 pesos : ' ||iTotalExcluidasXSaldo;
	LET cMensaje = trim(cMensaje) ||'    Cuentas a enviar : ' ||iTotalaEnviar;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	--Genera cifras de control

	LET cMensaje = '';
	LET iTotalExcluidasXSitEsp	= 0;
	LET iTotalExcluidasXAclara	= 0;
	LET iTotalExcluidasXConvAct	= 0;
	LET iTotalExcluidasXSaldo	= 0;
	LET iTotalaEnviar			= 0;
	LET	iTotalCuentasVencidas	= 0;
	LET pDiaProcesar			= '';

-----------------------------------------------------------------	
-- Genera campana PP_CAIDA3M
-----------------------------------------------------------------
	SELECT 
		ven.fecha,ven.campania,ven.num_credito,ven.numcte,ven.procesar,ven.fecha_vencido,mae.status_cred,mas.mto_venc_trasp+mas.monto_vencido mto_venc_trasp,ven.sdo_vencido,mas.mto_fin_ven_trasp,mas.sdo_cap_insoluto,
		mas.sdo_intereses,mas.int_tra_no_exig,mas.mto_venc_int,mas.sdo_no_exig,mas.mto_finan_vdo,mas.sdo_moratorio,mas.sdo_contab_mora,suc.iva,ven.num_producto
	  FROM "informix".cb_vencidos_findemes ven
	 INNER JOIN bdicred:"informix".sd_maecredcrd mae ON mae.num_credito = ven.num_credito
	 INNER JOIN bdicred:"informix".sd_maesdoscrd mas ON mas.num_credito = ven.num_credito
	 INNER JOIN bdinteg:"informix".si_sucursales suc ON suc.empresa = mae.empresa AND suc.sucursal = mae.sucursal
	 WHERE ven.fecha = dFechaaProcesar
	   AND ven.campania = 'PP_CAIDA3M'
	   AND ven.procesar in ('0','1')
	INTO TEMP ctes_ctaspzo WITH NO LOG;

	CREATE INDEX ind_vencido_tmp ON ctes_ctaspzo(fecha);
	UPDATE STATISTICS MEDIUM FOR TABLE ctes_ctaspzo;

	-- Selecciona todos los vencidos e indetifica el tipo de campana para crear el universo a trabajar en el mes
	FOREACH WITH HOLD
		SELECT fecha,campania,num_credito,numcte,procesar,fecha_vencido,status_cred,mto_venc_trasp,sdo_vencido,mto_fin_ven_trasp,sdo_cap_insoluto,
			sdo_cap_insoluto + sdo_intereses + int_tra_no_exig + mto_venc_int + sdo_no_exig + (mto_finan_vdo + sdo_moratorio + sdo_contab_mora) * (1 + iva) sdo_total_liquidar,num_producto
		  INTO dFecha,cCampania,cNumCredito,cNumcte,cProcesar,dFechaVencido,cStatusCred,dSdoVencido,dSdoVencidoAct,sNumVencidos,dSdoInsoluto,dSdoTotalLiquidar,cNumProducto
		  FROM ctes_ctaspzo WHERE fecha = dFechaaProcesar

		LET	iTotalCuentasVencidas	= iTotalCuentasVencidas + 1;

	-- Valida motivo de exclusiones, si tiene
		EXECUTE PROCEDURE "informix".sp_identifica_exclusiones(cEmpresa,cNumCredito,cNumcte) INTO P_COD_RET,cExclusion;

		IF 	 cExclusion = '1' 	THEN 	LET	iTotalExcluidasXSitEsp	= iTotalExcluidasXSitEsp + 1;
		ELIF cExclusion = '2' 	THEN 	LET	iTotalExcluidasXAclara	= iTotalExcluidasXAclara + 1;
		ELIF cExclusion = '3' 	THEN 	LET	iTotalExcluidasXConvAct	= iTotalExcluidasXConvAct + 1;
		ELIF cExclusion = '4' 	THEN 	LET	iTotalExcluidasXSaldo	= iTotalExcluidasXSaldo + 1;
		END IF;
		
		IF cExclusion != '0' THEN LET cProcesar = '0'; ELSE LET cProcesar = '1'; LET iTotalaEnviar = iTotalaEnviar + 1; LET pDiaProcesar = pDiaEjecucion; END IF;

		SELECT fecha_ult_pago INTO cFecha_ultimo_pago 
		  FROM  bdicred:"informix".sd_maecredanexocrd
		WHERE empresa 		= cEmpresa
		  AND num_credito 	= cNumCredito;

		SELECT NVL(SUM(monto),0) INTO dMontoUltimoPago
		FROM bdicred:"informix".sd_movhiscrd 
		WHERE empresa = cEmpresa 
		AND fecha_mov = cFecha_ultimo_pago
		AND num_credito = cNumCredito
		AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd WHERE num_producto = cNumProducto) 
		AND codigo_ref = 1 AND reversado = "N";

		IF dSdoVencido < dSdoVencidoAct THEN
			LET cStatusVencidos = 'MEJORA';
		ELIF dSdoVencido = dSdoVencidoAct THEN
			LET cStatusVencidos = 'ESTABLE';
		ELIF dSdoVencido > dSdoVencidoAct THEN
			LET cStatusVencidos = 'DETERIORO';
		END IF;

		IF cStatusCred = 'CV' THEN
			LET cStatusSituacion = 'VENDIDO';
		ELIF cStatusCred = 'FF' THEN
			LET cStatusSituacion = 'LIQUIDADO';
		ELIF cStatusCred = 'FI' THEN
			LET cStatusSituacion = 'INMATERIAL';
		ELIF cStatusCred = 'FC' THEN
			LET cStatusSituacion = 'REESTRUCTURADO';
		ELIF cStatusCred = 'AA' THEN
			LET cStatusSituacion = 'VIGENTE';
		ELIF cStatusCred = 'BT' THEN
			LET cStatusSituacion = 'VENCIDO';
		ELIF cStatusCred = 'BA' THEN
			LET cStatusSituacion = 'VENCIDO_TRANSITORIO';
		ELIF cStatusCred IN ('E1','E2','E3') THEN
			SELECT descripcion INTO cDescripcion FROM bdicred:sd_tipocartera WHERE empresa = cEmpresa AND status_cred = cStatusCred;
			LET cStatusSituacion = TRIM(cDescripcion);
		END IF;

		IF ((cFecha_ultimo_pago >= mdy(MONTH(TODAY),1,YEAR(TODAY))) AND (cFecha_ultimo_pago <= mdy(MONTH(TODAY),pDiaEjecucion,YEAR(TODAY)))) THEN
			LET cProcesar = '9';
			LET	iTotalaEnviar = iTotalaEnviar - 1;
			LET pDiaProcesar = '';
		END IF;

		BEGIN WORK;
		UPDATE "informix".cb_vencidos_findemes
		   SET 	motivo_exclusion			= cExclusion,
				num_vencidos_diaant 		= sNumVencidos,
				pago_minimo 				= dPagoMinimo,
				sdo_total_liquidar_diaant 	= dSdoTotalLiquidar,
				sdo_vencido_diaante 		= dSdoVencido,
				sdo_insoluto_diaante 		= dSdoInsoluto,
				pagos_realizados 			= dMontoUltimoPago,
				num_envios_camp1 			= sNumEnviosCamp1,
				num_envios_camp2 			= sNumEnviosCamp2,
				status_vencidos 			= cStatusVencidos,
				status_situacion 			= cStatusSituacion,
				procesar					= cProcesar,
				dia_procesar				= pDiaProcesar
		 WHERE fecha		= dFecha
		   AND campania		= cCampania
		   AND num_credito	= cNumCredito;
		COMMIT WORK;

		LET cExclusion			= '';
		LET sNumVencidos		= 0;
		LET dPagoMinimo			= 0;
		LET dSdoTotalLiquidar	= 0;
		LET dSdoVencido			= 0;
		LET dSdoInsoluto		= 0;
		LET cFecha_ultimo_pago	= DATE(1);
		LET dMontoUltimoPago	= 0;
		LET sNumEnviosCamp1		= 0;
		LET sNumEnviosCamp2		= 0;
		LET cStatusVencidos		= '';
		LET cStatusSituacion	= '';
		LET cProcesar			= '';
		LET pDiaProcesar		= '';
		LET cNumProducto		= '';

	END FOREACH;

	DROP TABLE ctes_ctaspzo;

	--Genera cifras de control
	LET cMensaje = ' ------- Cifras de Control campana PP_CAIDA3M ------- ';
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

	LET cMensaje = '';
	LET cMensaje = 'TOTAL Cuentas vencidas procesadas : ' ||iTotalCuentasVencidas;
	LET cMensaje = trim(cMensaje) ||'    Cuentas excluidas X situacion especial: ' ||iTotalExcluidasXSitEsp;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = '';
	LET cMensaje = 'Cuentas excluidas X proceso de aclaracion : ' ||iTotalExcluidasXAclara;
	LET cMensaje = trim(cMensaje) ||'    Cuentas excluidas X convenio activo : ' ||iTotalExcluidasXConvAct;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = '';
	LET cMensaje = 'Cuentas excluidas X saldo menor a 100 pesos : ' ||iTotalExcluidasXSaldo;
	LET cMensaje = trim(cMensaje) ||'    Cuentas a enviar : ' ||iTotalaEnviar;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	--Genera cifras de control

	LET cMensaje = '';
	LET iTotalExcluidasXSitEsp	= 0;
	LET iTotalExcluidasXAclara	= 0;
	LET iTotalExcluidasXConvAct	= 0;
	LET iTotalExcluidasXSaldo	= 0;
	LET iTotalaEnviar			= 0;
	LET	iTotalCuentasVencidas	= 0;
	LET pDiaProcesar			= '';

-----------------------------------------------------------------
-- Genera campana PP_CAIDA2M
-----------------------------------------------------------------
	SELECT 
		ven.fecha,ven.campania,ven.num_credito,ven.numcte,ven.procesar,ven.fecha_vencido,mae.status_cred,mas.mto_venc_trasp+mas.monto_vencido mto_venc_trasp,ven.sdo_vencido,mas.mto_fin_ven_trasp,mas.sdo_cap_insoluto,
		mas.sdo_intereses,mas.int_tra_no_exig,mas.mto_venc_int,mas.sdo_no_exig,mas.mto_finan_vdo,mas.sdo_moratorio,mas.sdo_contab_mora,suc.iva,ven.num_producto
	  FROM "informix".cb_vencidos_findemes ven
	 INNER JOIN bdicred:"informix".sd_maecredcrd mae ON mae.num_credito = ven.num_credito
	 INNER JOIN bdicred:"informix".sd_maesdoscrd mas ON mas.num_credito = ven.num_credito AND mas.mto_fin_ven_trasp = 2
	 INNER JOIN bdinteg:"informix".si_sucursales suc ON suc.empresa = mae.empresa AND suc.sucursal = mae.sucursal
	 WHERE ven.fecha = dFechaaProcesar
	   AND ven.campania = 'PP_CAIDA2M'
	   AND ven.dia_corte >= pDiaEjecucion
	   AND ven.procesar in ('0','1')
	INTO TEMP ctes_ctaspzo WITH NO LOG;

	INSERT INTO ctes_ctaspzo
	SELECT 
		ven.fecha,ven.campania,ven.num_credito,ven.numcte,ven.procesar,ven.fecha_vencido,mae.status_cred,mas.mto_venc_trasp+mas.monto_vencido,ven.sdo_vencido,mas.mto_fin_ven_trasp,mas.sdo_cap_insoluto,
		mas.sdo_intereses,mas.int_tra_no_exig,mas.mto_venc_int,mas.sdo_no_exig,mas.mto_finan_vdo,mas.sdo_moratorio,mas.sdo_contab_mora,suc.iva,ven.num_producto
	  FROM "informix".cb_vencidos_findemes ven
	 INNER JOIN bdicred:"informix".sd_maecredcrd mae ON mae.num_credito = ven.num_credito
	 INNER JOIN bdicred:"informix".sd_maesdoscrd mas ON mas.num_credito = ven.num_credito AND mas.mto_fin_ven_trasp = 3
	 INNER JOIN bdinteg:"informix".si_sucursales suc ON suc.empresa = mae.empresa AND suc.sucursal = mae.sucursal
	 WHERE ven.fecha = dFechaaProcesar
	   AND ven.campania = 'PP_CAIDA2M'
	   AND ven.procesar in ('0','1');

	CREATE INDEX ind_vencido_tmp ON ctes_ctaspzo(fecha);
	UPDATE STATISTICS MEDIUM FOR TABLE ctes_ctaspzo;

	-- Selecciona todos los vencidos e indetifica el tipo de campana para crear el universo a trabajar en el mes
	FOREACH WITH HOLD
		SELECT fecha,campania,num_credito,numcte,procesar,fecha_vencido,status_cred,mto_venc_trasp,sdo_vencido,mto_fin_ven_trasp,sdo_cap_insoluto,
			sdo_cap_insoluto + sdo_intereses + int_tra_no_exig + mto_venc_int + sdo_no_exig + (mto_finan_vdo + sdo_moratorio + sdo_contab_mora) * (1 + iva) sdo_total_liquidar,num_producto
		  INTO dFecha,cCampania,cNumCredito,cNumcte,cProcesar,dFechaVencido,cStatusCred,dSdoVencido,dSdoVencidoAct,sNumVencidos,dSdoInsoluto,dSdoTotalLiquidar,cNumProducto
		  FROM ctes_ctaspzo WHERE fecha = dFechaaProcesar

		LET	iTotalCuentasVencidas	= iTotalCuentasVencidas + 1;

	-- Valida motivo de exclusiones, si tiene
		EXECUTE PROCEDURE "informix".sp_identifica_exclusiones(cEmpresa,cNumCredito,cNumcte) INTO P_COD_RET,cExclusion;

		IF 	 cExclusion = '1' 	THEN 	LET	iTotalExcluidasXSitEsp	= iTotalExcluidasXSitEsp + 1;
		ELIF cExclusion = '2' 	THEN 	LET	iTotalExcluidasXAclara	= iTotalExcluidasXAclara + 1;
		ELIF cExclusion = '3' 	THEN 	LET	iTotalExcluidasXConvAct	= iTotalExcluidasXConvAct + 1;
		ELIF cExclusion = '4' 	THEN 	LET	iTotalExcluidasXSaldo	= iTotalExcluidasXSaldo + 1;
		END IF;
		
		IF cExclusion != '0' THEN LET cProcesar = '0'; ELSE LET cProcesar = '1'; LET iTotalaEnviar = iTotalaEnviar + 1; LET pDiaProcesar = pDiaEjecucion; END IF;

		SELECT fecha_ultimo_pago INTO cFecha_ultimo_pago 
		  FROM  bdicred:"informix".sd_indicador_cred_crd
		WHERE empresa 		= cEmpresa
		  AND num_credito 	= cNumCredito;

		SELECT NVL(SUM(monto),0) INTO dMontoUltimoPago
		FROM bdicred:"informix".sd_movhiscrd 
		WHERE empresa = cEmpresa 
		AND fecha_mov = cFecha_ultimo_pago
		AND num_credito = cNumCredito
		AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd WHERE num_producto = cNumProducto) 
		AND codigo_ref = 1 AND reversado = "N";

		IF dSdoVencido < dSdoVencidoAct THEN
			LET cStatusVencidos = 'MEJORA';
		ELIF dSdoVencido = dSdoVencidoAct THEN
			LET cStatusVencidos = 'ESTABLE';
		ELIF dSdoVencido > dSdoVencidoAct THEN
			LET cStatusVencidos = 'DETERIORO';
		END IF;

		IF cStatusCred = 'CV' THEN
			LET cStatusSituacion = 'VENDIDO';
		ELIF cStatusCred = 'FF' THEN
			LET cStatusSituacion = 'LIQUIDADO';
		ELIF cStatusCred = 'FI' THEN
			LET cStatusSituacion = 'INMATERIAL';
		ELIF cStatusCred = 'FC' THEN
			LET cStatusSituacion = 'REESTRUCTURADO';
		ELIF cStatusCred = 'AA' THEN
			LET cStatusSituacion = 'VIGENTE';
		ELIF cStatusCred = 'BT' THEN
			LET cStatusSituacion = 'VENCIDO';
		ELIF cStatusCred = 'BA' THEN
			LET cStatusSituacion = 'VENCIDO_TRANSITORIO';
		ELIF cStatusCred IN ('E1','E2','E3') THEN
			SELECT descripcion INTO cDescripcion FROM bdicred:sd_tipocartera WHERE empresa = cEmpresa AND status_cred = cStatusCred;
			LET cStatusSituacion = TRIM(cDescripcion);
		END IF;

	-- Valida si realizo pago correspondiente a una mensualidad completa
		SELECT MIN(fecha_cuota) INTO dFechaVencido2
		FROM bdicred:"informix".sd_amortiza_creditocrd
		WHERE empresa 		= cEmpresa
		  AND num_credito 	= cNumCredito
		  AND capital_status IN ('6','7','2');
		
		IF dFechaVencido2 IS NULL OR dFechaVencido2 = '' THEN LET dFechaVencido2 = DATE(1); END IF;
		
		IF dFechaVencido < dFechaVencido2 THEN LET cProcesar = 9; LET iTotalaEnviar = iTotalaEnviar - 1; LET pDiaProcesar = ''; END IF;
		
		BEGIN WORK;
		UPDATE "informix".cb_vencidos_findemes
		   SET 	motivo_exclusion			= cExclusion,
				num_vencidos_diaant 		= sNumVencidos,
				pago_minimo 				= dPagoMinimo,
				sdo_total_liquidar_diaant 	= dSdoTotalLiquidar,
				sdo_vencido_diaante 		= dSdoVencido,
				sdo_insoluto_diaante 		= dSdoInsoluto,
				pagos_realizados 			= dMontoUltimoPago,
				num_envios_camp1 			= sNumEnviosCamp1,
				num_envios_camp2 			= sNumEnviosCamp2,
				status_vencidos 			= cStatusVencidos,
				status_situacion 			= cStatusSituacion,
				procesar					= cProcesar,
				dia_procesar				= pDiaProcesar
		 WHERE fecha		= dFecha
		   AND campania		= cCampania
		   AND num_credito	= cNumCredito;
		COMMIT WORK;
		
		LET cExclusion			= '';
		LET sNumVencidos		= 0;
		LET dPagoMinimo			= 0;
		LET dSdoTotalLiquidar	= 0;
		LET dSdoVencido			= 0;
		LET dSdoInsoluto		= 0;
		LET cFecha_ultimo_pago	= DATE(1);
		LET dMontoUltimoPago	= 0;
		LET sNumEnviosCamp1		= 0;
		LET sNumEnviosCamp2		= 0;
		LET cStatusVencidos		= '';
		LET cStatusSituacion	= '';
		LET cProcesar			= '';
		LET pDiaProcesar		= '';
		LET cNumProducto		= '';

	END FOREACH;

	DROP TABLE ctes_ctaspzo;

	--Genera cifras de control
	LET cMensaje = ' ------- Cifras de Control campana PP_CAIDA2M ------- ';
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

	LET cMensaje = '';
	LET cMensaje = 'TOTAL Cuentas vencidas procesadas : ' ||iTotalCuentasVencidas;
	LET cMensaje = trim(cMensaje) ||'    Cuentas excluidas X situacion especial: ' ||iTotalExcluidasXSitEsp;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = '';
	LET cMensaje = 'Cuentas excluidas X proceso de aclaracion : ' ||iTotalExcluidasXAclara;
	LET cMensaje = trim(cMensaje) ||'    Cuentas excluidas X convenio activo : ' ||iTotalExcluidasXConvAct;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = '';
	LET cMensaje = 'Cuentas excluidas X saldo menor a 100 pesos : ' ||iTotalExcluidasXSaldo;
	LET cMensaje = trim(cMensaje) ||'    Cuentas a enviar : ' ||iTotalaEnviar;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	--Genera cifras de control

	LET cMensaje = '';
	LET iTotalExcluidasXSitEsp	= 0;
	LET iTotalExcluidasXAclara	= 0;
	LET iTotalExcluidasXConvAct	= 0;
	LET iTotalExcluidasXSaldo	= 0;
	LET iTotalaEnviar			= 0;
	LET	iTotalCuentasVencidas	= 0;
	LET pDiaProcesar			= '';

-----------------------------------------------------------------
-- Genera campana PP_CAIDA1M
-----------------------------------------------------------------
	SELECT 
		ven.fecha,ven.campania,ven.num_credito,ven.numcte,ven.procesar,ven.fecha_vencido,mae.status_cred,mas.mto_venc_trasp+mas.monto_vencido mto_venc_trasp,ven.sdo_vencido,mas.mto_fin_ven_trasp,mas.sdo_cap_insoluto,
		mas.sdo_intereses,mas.int_tra_no_exig,mas.mto_venc_int,mas.sdo_no_exig,mas.mto_finan_vdo,mas.sdo_moratorio,mas.sdo_contab_mora,suc.iva,ven.num_producto
	  FROM "informix".cb_vencidos_findemes ven
	 INNER JOIN bdicred:"informix".sd_maecredcrd mae ON mae.num_credito = ven.num_credito
	 INNER JOIN bdicred:"informix".sd_maesdoscrd mas ON mas.num_credito = ven.num_credito AND mas.mto_fin_ven_trasp = 1
	 INNER JOIN bdinteg:"informix".si_sucursales suc ON suc.empresa = mae.empresa AND suc.sucursal = mae.sucursal
	 WHERE ven.fecha = dFechaaProcesar
	   AND ven.campania = 'PP_CAIDA1M'
	   AND ven.dia_corte >= pDiaEjecucion
	   AND ven.procesar in ('0','1')
	INTO TEMP ctes_ctaspzo WITH NO LOG;

	INSERT INTO ctes_ctaspzo
	SELECT 
		ven.fecha,ven.campania,ven.num_credito,ven.numcte,ven.procesar,ven.fecha_vencido,mae.status_cred,mas.mto_venc_trasp+mas.monto_vencido mto_venc_trasp,ven.sdo_vencido,mas.mto_fin_ven_trasp,mas.sdo_cap_insoluto,
		mas.sdo_intereses,mas.int_tra_no_exig,mas.mto_venc_int,mas.sdo_no_exig,mas.mto_finan_vdo,mas.sdo_moratorio,mas.sdo_contab_mora,suc.iva,ven.num_producto
	  FROM "informix".cb_vencidos_findemes ven
	 INNER JOIN bdicred:"informix".sd_maecredcrd mae ON mae.num_credito = ven.num_credito
	 INNER JOIN bdicred:"informix".sd_maesdoscrd mas ON mas.num_credito = ven.num_credito AND mas.mto_fin_ven_trasp = 2
	 INNER JOIN bdinteg:"informix".si_sucursales suc ON suc.empresa = mae.empresa AND suc.sucursal = mae.sucursal
	 WHERE ven.fecha = dFechaaProcesar
	   AND ven.campania = 'PP_CAIDA1M'
	   AND ven.procesar in ('0','1');

	CREATE INDEX ind_vencido_tmp ON ctes_ctaspzo(fecha);
	UPDATE STATISTICS MEDIUM FOR TABLE ctes_ctaspzo;

	-- Selecciona todos los vencidos e indetifica el tipo de campana para crear el universo a trabajar en el mes
	FOREACH WITH HOLD
		SELECT fecha,campania,num_credito,numcte,procesar,fecha_vencido,status_cred,mto_venc_trasp,sdo_vencido,mto_fin_ven_trasp,sdo_cap_insoluto,
			sdo_cap_insoluto + sdo_intereses + int_tra_no_exig + mto_venc_int + sdo_no_exig + (mto_finan_vdo + sdo_moratorio + sdo_contab_mora) * (1 + iva) sdo_total_liquidar,num_producto
		  INTO dFecha,cCampania,cNumCredito,cNumcte,cProcesar,dFechaVencido,cStatusCred,dSdoVencido,dSdoVencidoAct,sNumVencidos,dSdoInsoluto,dSdoTotalLiquidar,cNumProducto
		  FROM ctes_ctaspzo WHERE fecha = dFechaaProcesar

		LET	iTotalCuentasVencidas	= iTotalCuentasVencidas + 1;

	-- Valida motivo de exclusiones, si tiene
		EXECUTE PROCEDURE "informix".sp_identifica_exclusiones(cEmpresa,cNumCredito,cNumcte) INTO P_COD_RET,cExclusion;

		IF 	 cExclusion = '1' 	THEN 	LET	iTotalExcluidasXSitEsp	= iTotalExcluidasXSitEsp + 1;
		ELIF cExclusion = '2' 	THEN 	LET	iTotalExcluidasXAclara	= iTotalExcluidasXAclara + 1;
		ELIF cExclusion = '3' 	THEN 	LET	iTotalExcluidasXConvAct	= iTotalExcluidasXConvAct + 1;
		ELIF cExclusion = '4' 	THEN 	LET	iTotalExcluidasXSaldo	= iTotalExcluidasXSaldo + 1;
		END IF;
		
		IF cExclusion != '0' THEN LET cProcesar = '0'; ELSE LET cProcesar = '1'; LET iTotalaEnviar = iTotalaEnviar + 1; LET pDiaProcesar = pDiaEjecucion; END IF;

		SELECT fecha_ultimo_pago INTO cFecha_ultimo_pago 
		  FROM  bdicred:"informix".sd_indicador_cred_crd
		WHERE empresa 		= cEmpresa
		  AND num_credito 	= cNumCredito;

		SELECT NVL(SUM(monto),0) INTO dMontoUltimoPago
		FROM bdicred:"informix".sd_movhiscrd 
		WHERE empresa = cEmpresa 
		AND fecha_mov = cFecha_ultimo_pago
		AND num_credito = cNumCredito
		AND codigo_fun IN(SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd WHERE num_producto = cNumProducto) 
		AND codigo_ref = 1 AND reversado = "N";

		IF dSdoVencido < dSdoVencidoAct THEN
			LET cStatusVencidos = 'MEJORA';
		ELIF dSdoVencido = dSdoVencidoAct THEN
			LET cStatusVencidos = 'ESTABLE';
		ELIF dSdoVencido > dSdoVencidoAct THEN
			LET cStatusVencidos = 'DETERIORO';
		END IF;

		IF cStatusCred = 'CV' THEN
			LET cStatusSituacion = 'VENDIDO';
		ELIF cStatusCred = 'FF' THEN
			LET cStatusSituacion = 'LIQUIDADO';
		ELIF cStatusCred = 'FI' THEN
			LET cStatusSituacion = 'INMATERIAL';
		ELIF cStatusCred = 'FC' THEN
			LET cStatusSituacion = 'REESTRUCTURADO';
		ELIF cStatusCred = 'AA' THEN
			LET cStatusSituacion = 'VIGENTE';
		ELIF cStatusCred = 'BT' THEN
			LET cStatusSituacion = 'VENCIDO';
		ELIF cStatusCred = 'BA' THEN
			LET cStatusSituacion = 'VENCIDO_TRANSITORIO';
		ELIF cStatusCred IN ('E1','E2','E3') THEN
			SELECT descripcion INTO cDescripcion FROM bdicred:sd_tipocartera WHERE empresa = cEmpresa AND status_cred = cStatusCred;
			LET cStatusSituacion = TRIM(cDescripcion);
		END IF;

	-- Valida si realizo pago correspondiente a una mensualidad completa
		SELECT MIN(fecha_cuota) INTO dFechaVencido2
		FROM bdicred:"informix".sd_amortiza_creditocrd
		WHERE empresa 		= cEmpresa
		  AND num_credito 	= cNumCredito
		  AND capital_status IN ('6','7','2');
		
		IF dFechaVencido2 IS NULL OR dFechaVencido2 = '' THEN LET dFechaVencido2 = DATE(1); END IF;
		
		IF dFechaVencido < dFechaVencido2 THEN LET cProcesar = '9'; LET	iTotalaEnviar = iTotalaEnviar - 1; LET pDiaProcesar = ''; END IF;
		
		BEGIN WORK;
		UPDATE "informix".cb_vencidos_findemes
		   SET 	motivo_exclusion			= cExclusion,
				num_vencidos_diaant 		= sNumVencidos,
				pago_minimo 				= dPagoMinimo,
				sdo_total_liquidar_diaant 	= dSdoTotalLiquidar,
				sdo_vencido_diaante 		= dSdoVencido,
				sdo_insoluto_diaante 		= dSdoInsoluto,
				pagos_realizados 			= dMontoUltimoPago,
				num_envios_camp1 			= sNumEnviosCamp1,
				num_envios_camp2 			= sNumEnviosCamp2,
				status_vencidos 			= cStatusVencidos,
				status_situacion 			= cStatusSituacion,
				procesar					= cProcesar,
				dia_procesar				= pDiaProcesar
		 WHERE fecha		= dFecha
		   AND campania		= cCampania
		   AND num_credito	= cNumCredito;
		COMMIT WORK;

		LET cExclusion			= '';
		LET sNumVencidos		= 0;
		LET dPagoMinimo			= 0;
		LET dSdoTotalLiquidar	= 0;
		LET dSdoVencido			= 0;
		LET dSdoInsoluto		= 0;
		LET cFecha_ultimo_pago	= DATE(1);
		LET dMontoUltimoPago	= 0;
		LET sNumEnviosCamp1		= 0;
		LET sNumEnviosCamp2		= 0;
		LET cStatusVencidos		= '';
		LET cStatusSituacion	= '';
		LET cProcesar			= '';
		LET pDiaProcesar		= '';
		LET cNumProducto		= '';

	END FOREACH;

	DROP TABLE ctes_ctaspzo;

	--Genera cifras de control
	LET cMensaje = ' ------- Cifras de Control campana PP_CAIDA1M ------- ';
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

	LET cMensaje = '';
	LET cMensaje = 'TOTAL Cuentas vencidas procesadas : ' ||iTotalCuentasVencidas;
	LET cMensaje = trim(cMensaje) ||'    Cuentas excluidas X situacion especial: ' ||iTotalExcluidasXSitEsp;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = '';
	LET cMensaje = 'Cuentas excluidas X proceso de aclaracion : ' ||iTotalExcluidasXAclara;
	LET cMensaje = trim(cMensaje) ||'    Cuentas excluidas X convenio activo : ' ||iTotalExcluidasXConvAct;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = '';
	LET cMensaje = 'Cuentas excluidas X saldo menor a 100 pesos : ' ||iTotalExcluidasXSaldo;
	LET cMensaje = trim(cMensaje) ||'    Cuentas a enviar : ' ||iTotalaEnviar;
	CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	--Genera cifras de control

	LET cMensaje = '';
	LET iTotalExcluidasXSitEsp	= 0;
	LET iTotalExcluidasXAclara	= 0;
	LET iTotalExcluidasXConvAct	= 0;
	LET iTotalExcluidasXSaldo	= 0;
	LET iTotalaEnviar			= 0;
	LET pDiaProcesar			= '';

END IF;

CALL "informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, P_MENSAJE, '03') RETURNING P_COD_RET;

IF P_COD_RET != '000000' THEN
	LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
	RETURN P_COD_RET,P_MENSAJE;
END IF;

END
RETURN cCodRet,P_MENSAJE;
END PROCEDURE;
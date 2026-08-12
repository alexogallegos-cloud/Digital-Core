CREATE PROCEDURE "informix".sp_registradatos_motor_pp(
----Parametros de entrada
	pEmpresa CHAR(4),
	pNumSol CHAR(20),
	pNumCteBanco CHAR(20),
	cProducto CHAR(4),
	cMensajeMotivoCC CHAR(100),
	cRespSic CHAR(1),
	dMonto_Hipoteca MONEY,
	cTipo_sol CHAR(1),
	cNuevoStatus CHAR(2),
	cCausaSolicitud CHAR(3),
	vMorAct DECIMAL(10,2),
	vNuevoStatus_grupo5 CHAR(2),
	dSituacionPagoCoppel DECIMAL(10,2),
	PuntosESTADO_CIVIL_VAR_INT DECIMAL(10,2),
	vNumVecesTiendaComercial CHAR(20),
	PuntosUT0034 DECIMAL(10,2),
	PuntosvVI_Ocup_TmpOcup DECIMAL(10,2),
	PuntosVI_Edad_Escolaridad DECIMAL(10,2),
	v_min_flujo DECIMAL(14,2),
	v_salariomin DECIMAL(14,2),
	cSituacionCredito CHAR(1),
	v_comprobancoCRNOM DECIMAL(14,2),
	vgrupo_sol CHAR(1),
	vGrupoSol CHAR(1),
	v_lineasinTopes DECIMAL(14,2),
	v_ingreso_ant MONEY(14,2),
	v_ingresomensual_lc CHAR(20),
	cElementOs DECIMAL(14,2),
	v_limiteSup DECIMAL(14,2),
	v_tasasiniva DECIMAL(10,6),
	v_comprobancoPP DECIMAL(14,2),
	v_linea DECIMAL(14,2),
	v_factor_vp DECIMAL(21,10),
	v_flujo_libre1 DECIMAL(14,2),
	v_hereda_status CHAR(2),
	VI_Edad_Escolaridad DECIMAL(14,8),
	v_compromisos_33 MONEY(16,2),
	dCompromisosTotal MONEY(14,2),
	dCRA DECIMAL(14,2),
	v_ingreso CHAR(20),
	v_Valor_3s DECIMAL(14,2),
	v_valor DECIMAL(14,2),
	v_valor_2s DECIMAL(14,2),
	v_tasa DECIMAL(9,6),
	vcompromiso_coppel DECIMAL(14,2),
	v_porcentaje_compromiso DECIMAL(14,2),
	v_lineaAnt DECIMAL(14,2),
	v_lineaban DECIMAL(14,2),--sin uso
	v_meses DECIMAL(18,2),
	dPorcIncr DECIMAL(14,2),
	dPorcDecr DECIMAL(14,2),
	dMontoIncr DECIMAL(14,2),
	dMontoDecr DECIMAL(14,2),
	v_lineaRR DECIMAL(14,2),
	cBanderaRR CHAR(1),
	v_monto_cap_pago CHAR(20),
	cRevisionMC CHAR(1),
	dPorHipo DECIMAL(14,2),
	dPorSic DECIMAL(14,2),
	dPorOtros DECIMAL(14,2),
	iMotivoOs DECIMAL(10,2),-----------
	iProdMC DECIMAL(10,2),
	vMesesyMonto DECIMAL(14,8),
	vMesesAperCtaAntiguaRev CHAR(80),
	dOtrosComp DECIMAL(14,2),
	v_tope_ingreso DECIMAL(14,2),
	v_bs_score DECIMAL(14,2),
	dlinea_min_prod DECIMAL(18,2),
	ptipogrupoAux CHAR(1),
	v_comprobancoTDC DECIMAL(14,2),
	iSecuenciaOs DECIMAL(10,2),
	iFiltroParam DECIMAL(10,2),
	v_limiteInf DECIMAL(14,2),
	iMeses DECIMAL(10,2),
	cStatusRespOs CHAR(1),
	suma_gastos DECIMAL(14,2),
	ptipogrupo CHAR(2),
	cTieneOstel CHAR(1),
	cResultadoOsTel CHAR(1),
	bandera_grupo5 DECIMAL(10,2),
	cCanalv1 DECIMAL(10,2),
	cbanobligadosol DECIMAL(14,2),
	ccapturaobligsol DECIMAL(14,2),
	cCteProsp CHAR(20),
	Flag2credito DECIMAL(14,2),
	sBanAuto DECIMAL(14,2),
	IQ0002 DECIMAL(10,2),
	cEdo_civil CHAR(80), --sin uso
	cCompIngresos CHAR(1),
	dIngresoCac DECIMAL(14,2),
	iISM DECIMAL(14,2),
	v_flujo_libre2 DECIMAL(14,2),
	v_tasaMens DECIMAL(9,6),
	iSolMc DECIMAL(10,2),
	iFlagForzarEnvioMC DECIMAL(14,2),
	cStatusMovil CHAR(2),
	BC_101 INTEGER,--BC_101 CHAR(2) MACM
	v_capacidad MONEY(14,2),
	ESTADO_CIVIL_VAR_INT DECIMAL(18,2),
	dValorOs DECIMAL(10,4),
	iBanderaFaltaOSTEL DECIMAL(10,2),
	vPorcCta30oMasDias DECIMAL(10,2),
	iBanderaProsNoTit DECIMAL(10,2),
	v_comprobanco MONEY,
	iEnviarMC DECIMAL(10,2),
	UT0034 DECIMAL(10,2),
	iTotalParametrico DECIMAL(10,2),
	pmonto_autorizado DECIMAL(14,2),
	vMaxPlazoDias DECIMAL(14,2),
	VI_TpResid_TmpResid DECIMAL(14,2),
	vMensajeStatus CHAR(80),
	vlMontoHipoteca DECIMAL(10,2),
	vlMontoHipoteca_ant DECIMAL(14,2),
	vflagoro DECIMAL(14,2),
	iIdRiesgo DECIMAL(10,2),
	cStatusSolicitud CHAR(2),
	v_compromisos_sic_lc MONEY(14,2),
	cNuevoStatusOstel CHAR(2),
	v_linea_tienda MONEY(14,2),
	vPorcUso DECIMAL(15,8),
	vPromAntigMesesCtaRepUlt3Meses DECIMAL(10,2),
	vPromAntMax DECIMAL(14,2),
	vPromAntMin DECIMAL(14,2),
	vPuntualidad DECIMAL(14,8),
	vRatioConsUlt3M12M DECIMAL(10,2),
	vScoreEficUltSemMax DECIMAL(14,2),
	vScoreEficUltSemMin DECIMAL(14,2),
	vScorePlazoDiasMax DECIMAL(14,2),
	vScorePlazoDiasMin DECIMAL(14,2),
	vScorePorcjCta30oMasDiasMax DECIMAL(14,2),
	vScorePorcjCta30oMasDiasMin DECIMAL(14,2),
	vScorePorcjUsoMax DECIMAL(14,2),
	vScorePorcjUsoMin DECIMAL(14,2),
	vScoreRatioCon3MMax DECIMAL(14,2),
	vScoreRatioCon3MMin DECIMAL(14,2),
	vTipoHit DECIMAL(14,2),
	vValorCivil DECIMAL(14,2), --sin uso
	vVI_Ocup_TmpOcup DECIMAL(10,4),
	cSegmento CHAR(1),
	dFecha_Respuesta CHAR(10),
	dFechaVencimiento CHAR(10),
	IAsignaCapSaturada CHAR(10),
	PuntosvEstado DECIMAL(10,2),
	sHist_meses DECIMAL(14,2),
	PuntosVI_TpResid_TmpResid DECIMAL(10,2),
	PuntosvMesesyMonto DECIMAL(10,2),
	PuntosvPuntualidad DECIMAL(10,2),
	PuntosvScorminelementRev DECIMAL(10,2),
	PuntosBC_101 DECIMAL(10,2),
	PuntosIQ0002 DECIMAL(10,2),
	out_SCod_Ret CHAR(6),
	v_ingreso_salariomin CHAR(2),
	v_ingreso_valida CHAR(20),
	sts_prev_pa CHAR(20),
	vBanCoppelTiendaComercial DECIMAL(14,2),
	vCompromisos MONEY,
	vEficUltSem DECIMAL(14,2),
	vEstado DECIMAL(10,2),
	cSucursal   		CHAR(4),
	iValorICC	         DECIMAL(14,2),
	vCuentasPF   DECIMAL(14,8), --sin uso
	vMesesAperCtaAntigua DECIMAL(14,8),--sin uso
	PorcRangfijoMin 					DECIMAL(14,2),
	PorcRangofijoMax 				DECIMAL(14,2),
	vScorePorcSdoMin 				DECIMAL(14,8),
	vScorePorcSdoMax 			DECIMAL(14,2),
	vScoreMorActMin 	            DECIMAL(14,2),
	vScoreMorActMax 				DECIMAL(14,2),
	vAntiguedad            CHAR(1),-------------Agregar a BRM PP
    Capacidad_pago MONEY(14,2),
    PuntosGrupo72 DECIMAL(10,2),
    PuntosGrupo73 DECIMAL(10,2),
    PuntosGrupo74 DECIMAL(10,2),
    PuntosGrupo75 DECIMAL(10,2),
    PuntosGrupo76 DECIMAL(10,2),
    PuntosGrupo77 DECIMAL(10,2),
    PuntosGrupo78 DECIMAL(10,2),
    PuntosGrupo79 DECIMAL(10,2),
    cStatusPr CHAR(2),
    vcompromiso_coppel_2 DECIMAL(14,8),
	cNuevoStatusProsecto CHAR(2),
	vScorminelementRev DECIMAL(14,8),
	Origenout1 VARCHAR(30),--tasasiniva
	Origenout2 VARCHAR(30),
	Origenout3 VARCHAR(30),
	Origenout4 VARCHAR(30),
	Origenout5 DECIMAL(14,2),
	Origenout6 DECIMAL(14,2),
	Origenout7 DECIMAL(14,2),
	Origenout8 DECIMAL(14,2),
	pIngresoAjustado    	DECIMAL(10,2),-----
	pMoraCoppel 	         	DECIMAL(10,2),
	pMoraBancoppel  	DECIMAL(10,2),
	pSaldoVenCoppel	DECIMAL(10,2),
	pSaldoVencBancoppel		DECIMAL(10,2),
	pQuebranto			INTEGER,
	pSituacionEsp			CHAR(50),
	pReestructura			Integer,
	pFraudes			Integer,
	pListaNegra			SMALLINT,
	pIdenFalsa			SMALLINT,
	pnoTramiteDia_TDC		Integer,
	pcNoTramiteDia_PP		Integer,
	iHawk				Integer,
	sModelo			CHAR(50),
	iTipoSegmento		CHAR(50),
	dSics_montoPagar_revolvente  VARCHAR(250),
	dSics_montoPagar_noRevolvente 	VARCHAR(250),
	dSic_saldoActual_revolvente  VARCHAR(250),
	dSic_saldoActual_noRevolvente 	VARCHAR(250),
	dGc_saldoActual_Coppel   		DECIMAL (10,2),
	dGc_saldoActual_Banco   		DECIMAL (10,2),
	dCompromisos_cliente  		 DECIMAL (10,2),
	dCapacidadPago     			DECIMAL (10,2),
	dDecil       				Integer,
	dPti       				DECIMAL (10,2),
	dDti       				DECIMAL (10,2),
	dTasa       				DECIMAL (10,2),
	iPlazo2      				Integer,
	dVeces_Ingreso     			DECIMAL (10,2),
	dMaximo_Monto     			DECIMAL (10,2),
	cTipoColectivo     			VARCHAR(50),
	dMonto       				DECIMAL (10,2),
	dCuota       				DECIMAL (10,2),
	dPti_Real      				DECIMAL (10,2),
	dDti_Real      				DECIMAL (10,2),
	dPuntos_promedio_ingresom_ult4d	DECIMAL (10,2),
	dPromedio_ingresom_ult4d			Integer,
	pPuntos_continuidad_depositos_nomina	DECIMAL (10,2),
	pContinuidad_depositos_nomina		Integer,
	pOrigenout9					VARCHAR(50),
	pOrigenout10					VARCHAR(50),
	pOrigenout11					VARCHAR(50),
	pOrigenout12					VARCHAR(50),
	pOrigenout13					VARCHAR(50),
	pOrigenout14					Integer,
	pOrigenout15					Integer,
	pOrigenout16					Integer,
	pOrigenout17					Integer,
	pOrigenout18					Integer,
	pEdition_ss                      SMALLINT, 
    pEditiondate_ss CHAR (10))

RETURNING CHAR(5);

----Declaracion de variables--------	

DEFINE v_hoy                  DATE;
DEFINE vfechaServ DATE;
DEFINE sConsulta               SMALLINT;
DEFINE vCodUdi      CHAR(2);
DEFINE vCodUs       CHAR(2);
DEFINE vTpCambioUdi DECIMAL(14,6);
DEFINE vTpCambioUs  DECIMAL(14,6);
DEFINE vClase        CHAR(1);
DEFINE v_mod_parame           CHAR(1);
DEFINE v_valor_4s             DECIMAL(14,2);
DEFINE v_seccion              SMALLINT;
DEFINE iPlazo                  INTEGER;
DEFINE cTipoMovto            CHAR(1);
DEFINE isolcomp			INTEGER; -- se utiliza para condicionar insert en ss_solicitudes_cac
DEFINE iValido   		INTEGER; -- se utiliza para condicionar insert en ss_solicitudes_cac
DEFINE cMensajeRet   	CHAR(100); -- auxiliar para retorno de SP  sp_valida_comprobante
DEFINE iNewMPP INTEGER; -- sin uso, condicionaba el llamado de calula_variables
DEFINE existe_gpo5			INTEGER; -- condiciona insercion en bitacora_os_gpo5
DEFINE dTl13 DATE;

-----------------------------
DEFINE ppeso SMALLINT;
DEFINE pelemento SMALLINT;
DEFINE pgrupo SMALLINT;

------------------------------

DEFINE scod_ret              CHAR(5);
DEFINE cCodRet2Cred              CHAR(6);
DEFINE cProducto2    CHAR(4); -- cProducto

DEFINE vsqlerr                INTEGER;
DEFINE isam_err	SMALLINT;
DEFINE error_info CHAR(100);
DEFINE wBegin       CHAR(1);

----Inicializacion de variables-----

LET v_hoy = DATE(1);
LET vfechaServ = DATE(1);
LET sConsulta = 0;
LET vCodUdi = "";
LET vCodUs = "";
LET vTpCambioUdi = 0;
LET vTpCambioUs = 0;
LET vClase = "";
LET v_mod_parame = "2";
LET v_valor_4s = 0;
LET v_seccion = 2;
LET iPlazo = 0;
LET cTipoMovto = "";
LET isolcomp = 0; 
LET iValido = 0;
LET cMensajeRet = "";
LET iNewMPP = 1;
LET existe_gpo5 = 0;
LET ppeso = 0;
LET pelemento = 0;
LET pgrupo = 0;

LET scod_ret = "00000";
LET cCodRet2Cred = "00000";

LET cProducto2 = "";
LET vsqlerr = 0;
LET isam_err = 0;
LET error_info = "";
LET wBegin = "N";

LET vMensajeStatus = trim(vMensajeStatus);
LET cMensajeMotivoCC = trim(cMensajeMotivoCC);

-- ****************************************************************************
-- *                        CONTROL DE CAMBIOS                                *
-- ****************************************************************************
----------------------------------------------------------------------------------------------------------------',
--DESCRIPCION: Se agregan variables que se necesitan para el motor de evaluacion de prestamos personales MACM', 
--AUTOR:Marco Antonio Cardenas Medina ',
--FECHA:15/08/2024',
--BD: BDICRED';
--DESCRIPCION: Se topa el valor de la variable ut0034 a 999999 por desbordamiento.
--AUTOR:Marco Antonio Cardenas Medina ',
--FECHA:28/10/2024',
--BD: BDICRED';
--DESCRIPCION: Se actualiza la columna "cOrigenout3_ss" por el nombre "cNivelEndeudamiento_ss",
--AUTOR:Kevin Galvez Parra ',
--FECHA:02/04/2025',
--BD: BDICRED';
																		   
	--SET DEBUG FILE TO '/tmp/sp_registradatos_motor_pp_'||trim(pNumSol)||'.out';
	--TRACE ON;
	
	--SET debug file to '/informix/MarcoCardenas/PruebasMotor/registradatos/sp_registradatos_motor_pp_'||trim(pNumSol)||'.out';
	--TRACE ON;
	
	-- SET DEBUG FILE TO '/home/e10001126/logsapp/sp_registradatos_motor_pp_'||trim(pNumSol)||'.out';
	-- TRACE ON;

BEGIN
	----Control de excepciones
	ON EXCEPTION SET vsqlerr, isam_err, error_info
		IF vsqlerr != 0 THEN
			LET scod_ret=vsqlerr;
			INSERT INTO bdisolic:"informix".ax_paso values ("bdicred:sp_registradatos_motor_pp", vsqlerr, CURRENT ||error_info||' sol '||TRIM(pNumSol));
			IF wbegin = 'S' THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF;
			RETURN  scod_ret;
		END IF;
	END EXCEPTION;

	ON EXCEPTION IN (-255)
		LET wBegin = "B";
	END EXCEPTION WITH RESUME;

	ON EXCEPTION IN (-535)
		LET wBegin = "S";
		COMMIT WORK;
		BEGIN WORK;
	END EXCEPTION WITH RESUME;	

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	

	----
	BEGIN WORK;

	insert into bdisolic:"informix".ss_certif_evaluacion_salida_pp(
		pNumSol_ss,pNumCteBanco_ss,vNumVecesTiendaComercial_ss,v_hereda_status_ss,
		iFlagForzarEnvioMC_ss,iSecuenciaOs_ss,cStatusRespOs_ss,cResultadoOsTel_ss,bandera_grupo5_ss,iMeses_ss,v_compromisos_33_ss,v_monto_cap_pago_ss,
		iProdMC_ss,v_valor_ss,iFiltroParam_ss,v_lineaban_ss,cTieneOstel_ss,cCanalv1_ss,cbanobligadosol_ss,ccapturaobligsol_ss,cCteProsp_ss,Flag2credito_ss,
		sBanAuto_ss,IQ0002_ss,cEdo_civil_ss,iSolMc_ss,cStatusMovil_ss,iBanderaProsNoTit_ss,iEnviarMC_ss,iTotalParametrico_ss,vflagoro_ss,cStatusSolicitud_ss,
		cNuevoStatusOstel_ss,vScoreEficUltSemMax_ss,vScoreEficUltSemMin_ss,vScorePlazoDiasMax_ss,vScorePlazoDiasMin_ss,vScorePorcjCta30oMasDiasMax_ss,
		vScorePorcjCta30oMasDiasMin_ss,vScorePorcjUsoMax_ss,vScorePorcjUsoMin_ss,vScoreRatioCon3MMax_ss,vScoreRatioCon3MMin_ss,vValorCivil_ss,
		dFechaVencimiento_ss,IAsignaCapSaturada_ss,sHist_meses_ss,out_SCod_Ret_ss,v_ingreso_salariomin_ss,v_ingreso_valida_ss,sts_prev_pa_ss,
		vCuentasPF_ss,vMesesAperCtaAntigua_ss,PorcRangfijoMin_ss,PorcRangofijoMax_ss,vScorePorcSdoMin_ss,vScorePorcSdoMax_ss,vScoreMorActMin_ss,
		vScoreMorActMax_ss,vAntiguedad_ss,cStatusPr_ss,vcompromiso_coppel_2_ss,vMaxPlazoDias_ss,vScorminelementRev_ss,vPromAntMin_ss,vPromAntMax_ss,
		cOrigenout1_ss,cOrigenout2_ss,cNivelEndeudamiento_ss,cOrigenout4_ss,cOrigenout5_ss,cOrigenout6_ss,cOrigenout7_ss,cOrigenout8_ss,fecha_insert_ss)
	values(
		pNumSol,pNumCteBanco,vNumVecesTiendaComercial,v_hereda_status,
		iFlagForzarEnvioMC,iSecuenciaOs,cStatusRespOs,cResultadoOsTel,bandera_grupo5,iMeses,v_compromisos_33,v_monto_cap_pago,
		iProdMC,v_valor,iFiltroParam,v_lineaban,cTieneOstel,cCanalv1,cbanobligadosol,ccapturaobligsol,cCteProsp,Flag2credito,
		sBanAuto,IQ0002,cEdo_civil,iSolMc,cStatusMovil,iBanderaProsNoTit,iEnviarMC,iTotalParametrico,vflagoro,cStatusSolicitud,
		cNuevoStatusOstel,vScoreEficUltSemMax,vScoreEficUltSemMin,vScorePlazoDiasMax,vScorePlazoDiasMin,vScorePorcjCta30oMasDiasMax,
		vScorePorcjCta30oMasDiasMin,vScorePorcjUsoMax,vScorePorcjUsoMin,vScoreRatioCon3MMax,vScoreRatioCon3MMin,vValorCivil,
		dFechaVencimiento,IAsignaCapSaturada,sHist_meses,out_SCod_Ret,v_ingreso_salariomin,v_ingreso_valida,sts_prev_pa,
		vCuentasPF,vMesesAperCtaAntigua,PorcRangfijoMin,PorcRangofijoMax,vScorePorcSdoMin,vScorePorcSdoMax,vScoreMorActMin,
		vScoreMorActMax,vAntiguedad,cStatusPr,vcompromiso_coppel_2,vMaxPlazoDias,vScorminelementRev,vPromAntMin,vPromAntMax,
		Origenout1,Origenout2,Origenout3,Origenout4,Origenout5,Origenout6,Origenout7,Origenout8,current);

	LET BC_101 = BC_101;	
      IF(cProducto ='6400')THEN
		insert into bdisolic:"informix".ss_certif_evaluacion_salida_pp_2(pnumsol_ss,pnumctebanco_ss,cproducto_ss,ingreso_ajustado_ss,
		mora_coppel_ss,mora_bancoppel_ss,saldo_vencido_coppel_ss,saldo_vencido_bancoppel_ss,quebranto_ss,situacion_especial_ss,reestructuras_ss,
		fraudes_ss,lista_negra_ss,identificacion_falsa_ss,no_tramitedia_tdc_ss,no_tramitedia_pp_ss,hawk_ss,modelo_ss,tipo_segmento_ss,
		sics_montopagar_revolvente_ss,sics_montopagar_norevolvente_ss,sics_saldoactual_revolvente_ss,sics_saldoactual_norevolvente_ss,gc_saldoactual_coppel_ss,
		gc_saldoactual_bancoppel_ss,compromisos_cliente_ss,capacidad_pago_ss,decil_ss,pti_ss,dti_ss,tasa_ss,plazo_ss,veces_ingreso_ss,
		maximo_monto_ss,tipo_colectivo_ss,monto_ss,cuota_ss,pti_real_ss,dti_real_ss,puntos_promedio_ingresom_ult4d_ss,vpromedio_ingresom_ult4d_ss,
		puntos_continuidad_depositos_nomina_ss,vcontinuidad_depositos_nomina_ss,origenout9_ss,origenout10_ss,origenout11_ss,origenout12_ss,
		origenout13_ss,origenout14_ss,origenout15_ss,origenout16_ss,origenout17_ss,origenout18_ss,edition_ss,editiondate_ss,fecha_insert)
		values(pNumSol,pNumCteBanco,cProducto,pIngresoAjustado,pMoraCoppel,pMoraBancoppel,pSaldoVenCoppel,pSaldoVencBancoppel,pQuebranto,
		pSituacionEsp,pReestructura,pFraudes,pListaNegra,pIdenFalsa,pnoTramiteDia_TDC,pcNoTramiteDia_PP,iHawk,sModelo,iTipoSegmento,dSics_montoPagar_revolvente,
		dSics_montoPagar_noRevolvente,dSic_saldoActual_revolvente,dSic_saldoActual_noRevolvente,dGc_saldoActual_Coppel,dGc_saldoActual_Banco,
		dCompromisos_cliente,dCapacidadPago,dDecil ,dPti,dDti,dTasa,iPlazo2,dVeces_Ingreso,dMaximo_Monto,cTipoColectivo,dMonto,dCuota,dPti_Real,dDti_Real,dPuntos_promedio_ingresom_ult4d,
		dPromedio_ingresom_ult4d,pPuntos_continuidad_depositos_nomina,pContinuidad_depositos_nomina,pOrigenout9,pOrigenout10,pOrigenout11,pOrigenout12,pOrigenout13,pOrigenout14,pOrigenout15,pOrigenout16,pOrigenout17,pOrigenout18,pEdition_ss,pEditiondate_ss,current);
     --actualizar capacidad_pres
	 
	UPDATE bdisolic:"informix".ss_solicitudes
                SET  capacidad_pres = dCapacidadPago
                WHERE empresa = pEmpresa
                AND num_solicitud = pNumSol;
				
	UPDATE bdisolic:"informix".ss_revision_determinacion 
	SET tasa = dTasa
	WHERE empresa = pEmpresa 
	AND num_solicitud = pNumSol;
	
	END IF;
	/*IF(out_SCod_Ret = '00007') THEN
		IF wbegin = 'S' THEN
			COMMIT WORK;
			BEGIN WORK;
		ELSE
			COMMIT WORK;
		END IF;
		RETURN scod_ret;
	END IF;*/

	SELECT fecha_hoy
	INTO v_hoy
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = pEmpresa;

	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE 
	INTO vfechaServ
	FROM sysmaster:sysshmvals;

    SELECT tipo_movimiento
    INTO cTipoMovto
    FROM  bdisolic:"informix".ss_resum_scor_fin
    WHERE empresa =  pEmpresa
    AND num_solicitud = pNumSol;

	IF v_hoy < vfechaServ THEN
		LET v_hoy = vfechaServ;
	END IF;

	UPDATE bdisolic:"informix".ss_solicitudes 
	SET tp_gen_planpago = vTipoHit  
	WHERE empresa = pEmpresa 
	AND num_solicitud = pNumSol;  				

	UPDATE bdisolic:"informix".ss_resum_scor_fin
	SET evalua_cc = cRespSic,
	motivo_cc = cMensajeMotivoCC,
	pago_minimo = v_compromisos_sic_lc,
	secuenciaconsulta = sConsulta,         
	monto_hipoteca = dMonto_Hipoteca
	WHERE empresa = pEmpresa
	AND num_solicitud = pNumSol;

	----
	SELECT TRIM(valor) INTO vCodUdi
	FROM bdinteg:"informix".si_param
	WHERE empresa = pEmpresa
	AND cod_param = 16;

	SELECT TRIM(valor) INTO vCodUs
	FROM bdinteg:"informix".si_param
	WHERE empresa = pEmpresa
	AND cod_param = 17;

	SELECT TRIM(valor) INTO vClase
	FROM bdicred:"informix".sd_param
	WHERE empresa = pEmpresa
	AND cod_param = "336";

	EXECUTE PROCEDURE bdinteg:"informix".valor_divisa_pesos(pEmpresa, v_hoy,vCodUdi,vClase,'0')
	INTO scod_ret,vTpCambioUdi;

	IF scod_ret<>'00000' THEN
		RETURN scod_ret;
	END IF;

	EXECUTE PROCEDURE bdinteg:"informix".valor_divisa_pesos(pEmpresa, v_hoy,vCodUs,vClase,'1')
	INTO scod_ret,vTpCambioUs;
	IF scod_ret<>'00000' THEN
		RETURN scod_ret;
	END IF;

	-- mahr-cnbv Se actualiza el grupo para que los calculos se realicen en base a ese grupo.
	UPDATE bdisolic:"informix".ss_revision_determinacion 
	SET monto_hipoteca = dMonto_Hipoteca,
	evalua_cc = cRespSic,
	compromiso_sic = v_compromisos_sic_lc,
	tipo_cambio_udi = vTpCambioUdi,
	tipo_cambio_dls = vTpCambioUs
	WHERE empresa = pEmpresa 
	AND num_solicitud = pNumSol;

	----
	IF cRespSic in ('1','2','3','4') AND cTipo_sol NOT IN ('C')  THEN --JMAH  Solicitudes coppel no se rechazan			
		
		EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol (pEmpresa, 'sistema',pNumSol, cNuevoStatus, cCausaSolicitud, vMensajeStatus)
						INTO scod_ret;

		IF NVL(pNumSol,'') <> '' THEN	
			UPDATE bdisolic:"informix".ss_solicitudes_movil
			SET status = '3',--finalizado
			descripcion_status = vMensajeStatus 
			WHERE 	empresa  = pEmpresa 
			AND  num_solicitud = pNumSol;
		END IF;                

		IF scod_ret <> '00000' THEN
			LET scod_ret = '00003'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
			IF wbegin = 'S' THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF;
			RETURN scod_ret;
		END IF;

		IF wbegin = 'S' THEN
			COMMIT WORK;
			BEGIN WORK;
		ELSE
			COMMIT WORK;
		END IF;

		RETURN scod_ret;
	END IF; 	

	/*select count(*) into iNewMPP 
	from bdisolic:"informix".ss_param_mpp 
	WHERE empresa = '001'
	AND idSuc = cSucursal
	AND produc = cProducto;*/
	
	IF UT0034 > 999999 THEN 
		LET UT0034 = 999999;
	END IF;
	
	IF iNewMPP > 0 THEN--Nuevo modelo PP
		DELETE FROM bdisolic:"informix".ss_detalle_modelo where num_solicitud = pNumSol;
	
		DELETE FROM bdisolic:"informix".ss_detalle_scoring WHERE empresa = '001' and seccion = '2' 
		and grupo >= 26 and grupo <= 37 and tpo_persona = '01' and  num_solicitud = pNumSol; 
									
		DELETE FROM bdisolic:"informix".ss_detalle_scoring WHERE empresa = '001' and seccion = '2' 
		and grupo >= 44 and grupo <= 47 and tpo_persona = '01' and  num_solicitud = pNumSol;

		DELETE FROM bdisolic:"informix".ss_detalle_scoring WHERE empresa = '001' and seccion = '2' 
		and grupo in (16,49,50,51,52,53,54,55,56,57,63,64,65,66,67,60,68,61) and tpo_persona = '01' and  num_solicitud = pNumSol;
								
		DELETE FROM bdisolic:"informix".ss_detalle_scoring WHERE empresa = '001' AND seccion ='2'  
		AND grupo IN (27,51,52,56,60,61,67,69,70,71,72,73,74,75,76,77,78,79,80) AND tpo_persona = '01' AND num_solicitud = pNumSol; 						

		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'BC_101',BC_101,current,user);		
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'UT0034',UT0034,current,user);		
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'OCUPACION_&_TIEMPO_OCUPACION',vVI_Ocup_TmpOcup,current,user);		
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'IQ0002',IQ0002,current,user);		
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'Residencia_&_Tpo_Residencia',VI_TpResid_TmpResid,current,user);			
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'EDO_CIVIL_&_GENERO',ESTADO_CIVIL_VAR_INT,current,user);	
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'Edad&_Escolaridad',VI_Edad_Escolaridad,current,user);	
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'Estado',vEstado,current,user);		
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'Diferencias_Meses_&CtaMasAntigua_CtaRevolvente',vMesesAperCtaAntiguaRev,current,user);		
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'Meses_y_monto_de_la_fecha_de_morosidad_mas_grave_mas_reciente',vMesesyMonto,current,user);	
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'Porcentaje_Cuentas_30_o_Mas_Dias_Atraso',vPorcCta30oMasDias,current,user);	
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'Maximo_plazo_en_dias',vMaxPlazoDias,current,user);	
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'Ratio_numero_de_consultas_en_los_ultimos_3_meses_entre_numero_de_consultas_de_los_ultimos_12_meses',vRatioConsUlt3M12M,current,user);	
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'PRODUCTO BANCOPPEL-TIENDA COMERCIAL',vBanCoppelTiendaComercial,current,user);	
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'Promedio_de_la_antiguedad_en_meses_de_cuentas_reportadas_en_los_ultimos_3_meses',vPromAntigMesesCtaRepUlt3Meses,current,user);	
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'Eficiencia_Ultimo_Semestre',vEficUltSem,current,user);		
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'Mora_Actual',vMorAct,current,user);	
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'Porcentaje_de_Uso',vPorcUso,current,user);	
		insert into bdisolic:"informix".ss_detalle_modelo values(pEmpresa,pNumSol,'Puntualidad',vPuntualidad,current,user);

		UPDATE BDISOLIC:"informix".ss_detalle_scoring SET valor = 0 WHERE empresa =  pEmpresa AND seccion = 2 AND num_solicitud = pNumSol;
		
		INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosBC_101
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo = 27 AND elemento = BC_101);

        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosUT0034
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo = 51 AND UT0034 BETWEEN rango_min AND rango_max AND (
            (elemento between PorcRangfijoMin AND PorcRangofijoMax) OR (elemento between vScorePorcSdoMin AND vScorePorcSdoMax) OR  elemento IN (29)));
        
        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosvVI_Ocup_TmpOcup
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo = 52 AND elemento = vVI_Ocup_TmpOcup);

        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosIQ0002
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo = 56 AND IQ0002 BETWEEN rango_min AND rango_max AND elemento IN (6,7,8,9,10));

		INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosVI_TpResid_TmpResid
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo = 60 AND elemento = VI_TpResid_TmpResid);

        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosESTADO_CIVIL_VAR_INT
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo = 61 AND elemento = ESTADO_CIVIL_VAR_INT);

        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosVI_Edad_Escolaridad
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo = 67 AND elemento = VI_Edad_Escolaridad);

        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosvEstado
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo = 69 AND elemento = vEstado);

        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosvScorminelementRev
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo = 70 AND elemento = vScorminelementRev);

        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosvMesesyMonto
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo = 71 AND elemento = vMesesyMonto);

        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosGrupo72 --(vPorcCta30oMasDias)
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo = 72 AND vPorcCta30oMasDias BETWEEN rango_min AND rango_max AND elemento between vScorePorcjCta30oMasDiasMin AND vScorePorcjCta30oMasDiasMax);

        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosGrupo73 --(vMaxPlazoDias)
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo = 73 AND vMaxPlazoDias BETWEEN rango_min AND rango_max AND elemento between vScorePlazoDiasMin AND vScorePlazoDiasMax);

        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosGrupo74 --(vRatioConsUlt3M12M)
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo=74 and vRatioConsUlt3M12M BETWEEN rango_min AND rango_max AND elemento between vScoreRatioCon3MMin AND vScoreRatioCon3MMax);
        
        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosGrupo75 --(vNumVecesTiendaComercial)
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo=75 and vNumVecesTiendaComercial BETWEEN rango_min AND rango_max AND elemento = vBanCoppelTiendaComercial);

        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosGrupo76 --(vPromAntigMesesCtaRepUlt3Meses)
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo=76 and vPromAntigMesesCtaRepUlt3Meses  BETWEEN rango_min AND rango_max AND elemento BETWEEN vPromAntMin AND vPromAntMax);
        
		LET cTipo_sol = cTipo_sol;
		LET vEficUltSem = vEficUltSem;
		LET vScoreEficUltSemMin = vScoreEficUltSemMin;
		LET vScoreEficUltSemMax = vScoreEficUltSemMax;
        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosGrupo77 --(vEficUltSem)
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo=77 and vEficUltSem BETWEEN rango_min AND rango_max AND elemento between vScoreEficUltSemMin AND vScoreEficUltSemMax);

        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosGrupo78 
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo=78 and elemento between  vScoreMorActMin AND vScoreMorActMax);

        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosGrupo79 --(vPorcUso)
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo=79 and vPorcUso BETWEEN rango_min AND rango_max AND ((elemento between vScorePorcjUsoMin AND vScorePorcjUsoMax) OR  elemento IN (1,13)));

        INSERT INTO BDISOLIC:"informix".ss_detalle_scoring
		SELECT pEmpresa,'2',grupo,elemento,'01',pNumSol, PuntosvPuntualidad
		FROM BDISOLIC:"informix".ss_parametricos WHERE tipo_parametrico = '2'
        AND tp_solicitud = cTipo_sol AND (grupo = 80 AND elemento = vPuntualidad);

        
	END IF;
	
	--MACM
	IF ( dSituacionPagoCoppel < 0  ) THEN
       LET v_meses = 0;
       LET dSituacionPagoCoppel = 0;
    END IF;

    UPDATE bdisolic:"informix".ss_revision_determinacion 
    SET situacion_pago = dSituacionPagoCoppel,
    meses_historia = v_meses, 
    situacion_credito = cSituacionCredito,
    bs_score = v_bs_score,--v_valor_1s,
    score_prop = v_valor_2s,
    fico_score = v_valor_3s,
    linea_tienda = v_linea_tienda
    WHERE empresa = pEmpresa
    AND num_solicitud = pNumSol;	

	----
    DELETE FROM bdisolic:"informix".ss_resumen_scoring
    WHERE empresa = pEmpresa
    AND num_solicitud = pNumSol;

    DELETE FROM bdisolic:"informix".ss_autorizacion
    WHERE empresa = pEmpresa
    AND num_solicitud = pNumSol
    AND status_solicitud IN ("RT","EE");


    -- Se inserta valor de la seccion 1
    INSERT INTO bdisolic:"informix".ss_resumen_scoring (empresa, num_solicitud, seccion, evaluacion)
    VALUES (pEmpresa, pNumSol, 1, v_bs_score);

    --Se inserta valor de la seccion 2
    INSERT INTO bdisolic:"informix".ss_resumen_scoring (empresa, num_solicitud, seccion, evaluacion)
    VALUES (pEmpresa, pNumSol, v_seccion, v_valor_2s);

    -- FICO SCORE/Se inserta valor de la seccion 3
    INSERT INTO bdisolic:"informix".ss_resumen_scoring (empresa, num_solicitud, seccion, evaluacion)
    VALUES (pEmpresa, pNumSol, 3, v_valor_3s);

	----
    IF v_mod_parame = 2 AND cTipo_sol NOT IN ('C') THEN        
        IF Flag2credito = 1 THEN
            INSERT INTO bdisolic:"informix".ss_resumen_scoring (empresa, num_solicitud, seccion, evaluacion)
            VALUES (pEmpresa, pNumSol, 5, iValorICC);

            IF cNuevoStatus = "RT" THEN
                UPDATE bdisolic:"informix".ss_revision_determinacion
                SET flag2creditoicc = 1
                WHERE empresa = pEmpresa
                AND num_solicitud = pNumSol;
            END IF;
        END IF;		   
    END IF;

	----
    IF v_valor < iTotalParametrico THEN					  
        EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol (pEmpresa, 'sistema',pNumSol, cNuevoStatus,cCausaSolicitud, vMensajeStatus)
        INTO scod_ret;

        IF NVL(pNumSol,'') <> '' THEN	
            UPDATE bdisolic:"informix".ss_solicitudes_movil		
            SET status = '3',--finalizado
            descripcion_status = vMensajeStatus 
            WHERE empresa = pEmpresa 
            AND num_solicitud = pNumSol;
        END IF;

        IF scod_ret <> '00000' THEN
            LET scod_ret = '00004'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
            IF wbegin = 'S' THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            RETURN scod_ret;
        END IF;

        IF wbegin = 'S' THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            COMMIT WORK;
        END IF;
		UPDATE  bdisolic:"informix".ss_revision_determinacion 
		SET ingreso_mensual = v_ingreso_ant,
			ingreso_mensual_lc		= v_ingresomensual_lc,    
			pago_crnom				= v_comprobancoCRNOM, 
			pago_prest				= v_comprobancoPP, 
			pago_tdc				= v_comprobancoTDC, 
			compromiso_sic_lc       = vcompromisos,	        
			monto_coppel			= vcompromiso_coppel,		
			mto_pagos_bco			= v_comprobanco,		
			compromiso_mens        	= dCompromisosTotal,
			factor1         		= 0,
			factor2         		= 0,
			valor_cta            	= 0, 
			valor_cma            	= 0,
			valor_tab            	= 0,
			valor_rab            	= dCRA,
			valor_pres            	= v_factor_vp, -- se quita para que no la actualice en caso de que sea el producto 6400 tasa = v_tasasiniva ,
			tasa_iva        		= v_tasa,
			tasa_mens        		= v_tasaMens,
			cap_pag_min           	= v_min_flujo,
			tope_ingreso_tope		= v_tope_ingreso,
			linea_teorica        	= v_lineasinTopes,
			limiteInf				= v_limiteInf,
			limiteSup				= v_limiteSup,
			linea_credito			= v_lineaAnt,
			porc_incre           	= dPorcIncr,
			porc_decre           	= dPorcDecr, 
			monto_incre           	= dMontoIncr, 
			monto_decre           	= dMontoDecr,  
			linea_final				= v_linea,
			bandera_rr		        = cBanderaRR,
			linea_rest				= v_lineaRR,
			bandera_mc		      	= cRevisionMC,	
			porc_hipo	         	= dPorHipo,
			porc_buro           	= dPorSic,
			porc_otros          	= dPorOtros,
			perfil_riesgo           = iIdRiesgo,
			ingreso_sm 				= iISM,
			monto_hipoteca          = vlMontoHipoteca_ant,
			monto_hipoteca_lc       = vlMontoHipoteca ,
			otros_gastos        	= dOtrosComp,
			score_prop          	= v_valor_2s, -- v_score_prop
			comprob_ing_val_mc  	= cCompIngresos,
			monto_reportado_mc  	= dIngresoCac,
			salario_minimo      	= v_salariomin,
			linea_min_prod      	= dlinea_min_prod, 
			suma_gastos         	= suma_gastos
		WHERE  empresa  = pEmpresa
		AND num_solicitud = pNumSol;
		
		IF(cProducto <> '6400' )THEN 
		UPDATE  bdisolic:"informix".ss_revision_determinacion 
		SET tasa     	    		= v_tasasiniva
		WHERE  empresa  = pEmpresa
		AND num_solicitud = pNumSol;
		END IF;

        RETURN scod_ret;			         
    END IF; 

	----
    IF NVL(cTieneOstel,'') = 'V' THEN
        IF nvl(cResultadoOsTel,'') = '' THEN--JMAH RQM 18 056
            --IF (iProdMC = 1) AND (iEnviarMC = 1 OR cTipo_sol = 'C' ) AND iSolMc = 0 THEN--para que la solicitud aunque le falte la respuesta de OSTEL pase a MC a su revision
            IF (iProdMC <> 1) AND (iEnviarMC <> 1 OR cTipo_sol <> 'C' ) AND iSolMc <> 0 THEN--para que la solicitud aunque le falte la respuesta de OSTEL pase a MC a su revision
            --ELSE						  						
                EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol (pEmpresa, 'sistema',pNumSol, cNuevoStatus, cCausaSolicitud, vMensajeStatus)
                            INTO scod_ret;

                IF NVL(pNumSol,'') <> '' THEN	
                    UPDATE bdisolic:"informix".ss_solicitudes_movil		
                        SET status = '3',--finalizado
                        descripcion_status = vMensajeStatus 
                    WHERE 	empresa  = pEmpresa 
                    AND  num_solicitud = pNumSol;
                END IF;

                IF scod_ret <> '00000' THEN
                    LET scod_ret = '00002'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
                    IF wbegin = 'S' THEN
                        ROLLBACK WORK;
                        BEGIN WORK;
                    ELSE
                        ROLLBACK WORK;
                    END IF;
                    RETURN scod_ret;
                END IF;

                IF wbegin = 'S' THEN
                    COMMIT WORK;
                    BEGIN WORK;
                ELSE
                    COMMIT WORK;
                END IF;
                RETURN scod_ret;

            END IF;
        ELSE			
            INSERT INTO bdisolic:"informix".ss_detalle_scoring (empresa,seccion,grupo,elemento,tpo_persona,num_solicitud,valor)
            VALUES (pEmpresa, 2, 25,cElementOs, "01",pNumSol, dValorOs);
        END IF;	
    END IF;

	----
    IF cTieneOstel = 'V' AND iBanderaFaltaOSTEL =0 THEN        
        IF cNuevoStatusOstel = 'RT' THEN
            EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol (pEmpresa, 'sistema',pNumSol, cNuevoStatus, cCausaSolicitud, vMensajeStatus)
            INTO scod_ret;

            IF NVL(pNumSol,'') <> '' THEN	
                UPDATE bdisolic:"informix".ss_solicitudes_movil		
                SET status = '3',--finalizado
                descripcion_status = vMensajeStatus 
                WHERE 	empresa  = pEmpresa 
                AND  num_solicitud = pNumSol;
            END IF;

            IF scod_ret <> '00000' THEN
                LET scod_ret = '00003'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
                IF wbegin = 'S' THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                RETURN scod_ret;
            END IF;

            IF wbegin = 'S' THEN
                COMMIT WORK;
                BEGIN WORK;
            ELSE
                COMMIT WORK;
            END IF;

            RETURN scod_ret;
        END IF               
    END IF;			
		
	----
    IF cProducto <> '7800' THEN 	
        IF cTipo_sol NOT IN ('C')   THEN	
            --IF (v_compromisos_33 - vCompromisos) >= v_monto_cap_pago::DECIMAL(10,2) THEN

                IF NVL(sHist_meses,0) > 0 THEN                     
                    IF NVL(sHist_meses,0) > iMeses  THEN 
                        INSERT INTO bdisolic:"informix".ss_cambio_grupo (empresa ,num_solicitud ,grupo_anterior,grupo_nuevo ,user_insert ,fecha_insert)
                        VALUES (pEmpresa,pNumSol,ptipogrupoAux,ptipogrupo,USER,CURRENT);            
                    END IF;
                END IF;

                UPDATE bdisolic:"informix".ss_revision_determinacion 
                SET grupo = ptipogrupo 
                WHERE empresa = pEmpresa 
                AND num_solicitud = pNumSol;

                UPDATE bdisolic:"informix".ss_resum_scor_fin
                SET grupo = vGrupoSol
                WHERE empresa = pEmpresa
                AND num_solicitud = pNumSol;

                IF v_ingreso_valida > 0 THEN 
                    UPDATE bdisolic:"informix".ss_resum_scor_fin
                    SET salario_minimo = v_ingreso_salariomin
                    WHERE empresa = pEmpresa AND num_solicitud = pNumSol;
                END IF;

                UPDATE bdisolic:"informix".ss_resum_scor_fin 
                set compromisos_bco = v_comprobanco 
                where empresa = pEmpresa 
                and num_solicitud = pNumSol;

                IF iNewMPP > 0 THEN	
                    UPDATE bdisolic:"informix".ss_solicitudes 
                    SET tp_gen_planpago = cSegmento 
                    WHERE empresa = pEmpresa 
                    AND num_solicitud =pNumSol;
                END IF;

                IF vcompromiso_coppel_2 = 0 AND cTipoMovto = 'M' THEN
                    IF v_porcentaje_compromiso <> 0 OR v_porcentaje_compromiso IS NOT NULL THEN
                        UPDATE bdisolic:"informix".ss_revision_determinacion 
                        SET compromiso_coppel_simulado =  'SI',
                        porcentaje_compromiso =  v_porcentaje_compromiso||'% '
                        WHERE num_solicitud = pNumSol;
                    END IF;
                END IF;

                IF IAsignaCapSaturada = 0 THEN
                    UPDATE bdisolic:"informix".ss_resum_scor_fin
                    SET ingreso_lc = v_ingreso,
                    valor_cma = v_flujo_libre1,
                    valor_tab = v_flujo_libre2,
                    linea_teorica = v_lineasinTopes
                    WHERE empresa = pEmpresa AND num_solicitud = pNumSol;
                END IF;

                IF NVL(vflagoro,0) = 0 THEN
                    UPDATE bdisolic:"informix".ss_resum_scor_fin
                    SET ingreso_lc = v_ingreso,
                    valor_cma = v_flujo_libre1,
                    valor_tab = v_flujo_libre2,
                    linea_teorica = v_lineasinTopes
                    WHERE empresa = pEmpresa AND num_solicitud = pNumSol;
                END IF;

                update bdisolic:"informix".ss_solicitudes 
                set tasa_base_piso =  TO_CHAR(v_capacidad)
                where num_solicitud = pNumSol 
                and empresa = pEmpresa;   

                IF NVL(vflagoro,0) = 0  AND vAntiguedad = '' THEN
                    UPDATE bdisolic:"informix".ss_solicitudes_tdcoro
                    SET ingreso_lc = v_ingresomensual_lc,
                    valor_cma = v_flujo_libre1,
                    valor_tab = v_flujo_libre2,
                    linea_teorica = v_linea
                    WHERE empresa = pEmpresa
                    AND numero_solicitud = pNumSol;
                ELSE
                    UPDATE  bdisolic:"informix".ss_revision_determinacion 
                    SET ingreso_mensual = v_ingreso_ant,
                        ingreso_mensual_lc		= v_ingresomensual_lc,    
                        pago_crnom				= v_comprobancoCRNOM, 
                        pago_prest				= v_comprobancoPP, 
                        pago_tdc				= v_comprobancoTDC, 
                        compromiso_sic_lc       = vcompromisos,        
                        monto_coppel			= vcompromiso_coppel,		
                        mto_pagos_bco			= v_comprobanco,		
                        compromiso_mens        	= dCompromisosTotal,
                        factor1         		= 0,
                        factor2         		= 0,
                        valor_cta            	= 0, 
                        valor_cma            	= 0,
                        valor_tab            	= 0,
                        valor_rab            	= dCRA,
                        valor_pres            	= v_factor_vp, -- -- se quita para que no la actualice en caso de que sea el producto 6400  tasa     	    		= v_tasasiniva ,
                        tasa_iva        		= v_tasa,
                        tasa_mens        		= v_tasaMens,
                        cap_pag_min           	= v_min_flujo,
                        tope_ingreso_tope		= v_tope_ingreso,
                        linea_teorica        	= v_lineasinTopes,
                        limiteInf				= v_limiteInf,
                        limiteSup				= v_limiteSup,
                        linea_credito			= v_lineaAnt,
                        porc_incre           	= dPorcIncr,
                        porc_decre           	= dPorcDecr, 
                        monto_incre           	= dMontoIncr, 
                        monto_decre           	= dMontoDecr,  
                        linea_final				= v_linea,
                        bandera_rr		        = cBanderaRR,
                        linea_rest				= v_lineaRR,
                        bandera_mc		      	= cRevisionMC,	
                        porc_hipo	         	= dPorHipo,
                        porc_buro           	= dPorSic,
                        porc_otros          	= dPorOtros,
                        perfil_riesgo           = iIdRiesgo,
                        ingreso_sm 				= iISM,
                        monto_hipoteca          = vlMontoHipoteca_ant,
                        monto_hipoteca_lc       = vlMontoHipoteca ,
                        otros_gastos        	= dOtrosComp,
                        score_prop          	= v_valor_2s, -- v_score_prop
                        comprob_ing_val_mc  	= cCompIngresos,
                        monto_reportado_mc  	= dIngresoCac,
                        salario_minimo      	= v_salariomin,
                        linea_min_prod      	= dlinea_min_prod, 
                        suma_gastos         	= suma_gastos
                    WHERE  empresa  = pEmpresa
                    AND num_solicitud = pNumSol;
                END IF;

                SELECT NVL(plazo_max_cred,0)
                INTO iPlazo
                FROM bdicred:"informix".sd_definicion
                WHERE empresa = pEmpresa
                AND num_producto = cProducto;
                
                UPDATE bdisolic:"informix".ss_solicitudes
                SET monto_autorizado = pmonto_autorizado,-- se quita para que no la actualice en caso de que sea el producto 6400 capacidad_pres = Capacidad_pago,
                plazo = iPlazo
                WHERE empresa = pEmpresa
                AND num_solicitud = pNumSol; 
				
				IF(cProducto <> '6400' )THEN 
				
					UPDATE  bdisolic:"informix".ss_revision_determinacion 
					SET tasa = v_tasasiniva
					WHERE  empresa  = pEmpresa
					AND num_solicitud = pNumSol;
					
					UPDATE bdisolic:"informix".ss_solicitudes
					SET capacidad_pres = Capacidad_pago
					WHERE empresa = pEmpresa
					AND num_solicitud = pNumSol; 
				
				END IF;

           		
            --END IF;
        END IF;
    END IF

    --IF (cNuevoStatus = 'EE' OR  cNuevoStatus = 'AT') OR (cTipo_sol = 'C' AND iSolMc = 0 ) THEN 	

    IF bandera_grupo5 > 0 AND cCanalv1 <> 4 THEN				
        SELECT COUNT (*) INTO existe_gpo5
        FROM bdisolic:"informix".bitacora_os_gpo5 
        WHERE empresa = pEmpresa 
        AND num_solicitud = pNumSol;

        IF existe_gpo5 = 0 THEN
            INSERT INTO bdisolic:"informix".bitacora_os_gpo5 VALUES (pEmpresa,cProducto,pNumSol,
            (Case When (nvl(cRespSic,'X') = 'X')  Then 'No-Hit' Else 'Hit' end),
            v_hoy,'',vNuevoStatus_grupo5,cSucursal,vgrupo_sol,v_bs_score,v_valor_2s,v_valor_3s,v_valor_4s,pmonto_autorizado,'Excepcion de OS grupo 5',"");
        ELSE 
            UPDATE bdisolic:"informix".bitacora_os_gpo5 
            SET bc_score = v_bs_score,
                sc_propietario = v_valor_2s,
                fico_score = v_valor_3s, 
                fc_extended = v_valor_4s,
                linea_credito = pmonto_autorizado 
            WHERE num_solicitud = pNumSol;
        END IF;
    END IF;
                            
    IF (NVL(iFlagForzarEnvioMC,0) > 0 OR (iProdMC = 1 AND iSolMc = 0 AND iEnviarMC = 1 AND Flag2credito = 0) OR cProducto IN ('9100','9300','9200','9400')) AND  cStatusSolicitud <> 'MC'  THEN

        IF (cCanalv1 = 99) OR cProducto IN ('9100','9300','9200','9400') OR (cbanobligadosol = 1 AND ccapturaobligsol = 1) THEN

            IF iSolMc = 0  THEN
                INSERT INTO bdisolic:"informix".ss_solicitudes_mc (empresa,num_solicitud,numcte,sucursal,num_producto,monto_solicitado,status_ini,status_fin,ejecutivo_atiende,ejecutivo_autoriza,observaciones,fecha_insert,hora_insert,fecha_determinacion,revisado,motivo_os,ostel,tipo_alta,status_hereda,prioridad)																																										  
                VALUES (pEmpresa,pNumSol,pNumCteBanco,cSucursal,cProducto, pmonto_autorizado, cNuevoStatus,'','','','Cliente Nuevo',CURRENT,CURRENT,CURRENT,'N',iMotivoOs,iBanderaFaltaOSTEL,cTipoMovto,v_hereda_status,iFlagForzarEnvioMC);
            END IF;
        END IF;
        
    END IF;		

    IF NVL(cProducto,'') <> '' THEN 
        IF nvl(iSecuenciaOs,0) <> 0 THEN	
            IF(v_hoy  <= dFechaVencimiento) THEN
                IF(SELECT COUNT(*)  FROM bdisolic:"informix".ss_solicitud_os WHERE num_solicitud=pNumSol AND secuenciaos = iSecuenciaOs)=0 THEN 
                    IF NOT EXISTS (SELECT num_solicitud FROM bdisolic:"informix".ss_solic_rt WHERE num_solicitud = pNumSol) THEN
                        INSERT INTO bdisolic:"informix".ss_solicitud_os(empresa, num_solicitud, fecha_solicitud, fecha_respuesta, status, usuario_solicita, usuario_gestor, observacion1, observacion2, observacion3, situacionespecial, causasituacionespecial, situacionespecialrespuesta, causasituacionespecialrespuesta, secuenciaos, motivo_os)
                        VALUES(pEmpresa, pNumSol, v_hoy, TO_DATE(dFecha_Respuesta,'%d/%m/%Y'),cStatusRespOs, 'sistema', 'sistema', NULL, NULL, NULL, ' ', 0, NULL, NULL, iSecuenciaOs, 0);							
                    END IF;
                END IF; 
            END IF;

            IF ( NVL(cCteProsp,'') <>'' AND iBanderaProsNoTit = 0 ) THEN
                IF (SELECT COUNT(*)  FROM bdisolic:"informix".ss_solicitud_os WHERE num_solicitud=pNumSol AND secuenciaos=iSecuenciaOs) = 0 THEN 
                    IF NOT EXISTS (SELECT num_solicitud FROM bdisolic:"informix".ss_solic_rt WHERE num_solicitud = pNumSol) THEN
                        INSERT INTO bdisolic:"informix".ss_solicitud_os (empresa, num_solicitud, fecha_solicitud, fecha_respuesta, status,usuario_solicita,secuenciaos,motivo_os)
                        VALUES (pEmpresa, pNumSol, TODAY,TO_DATE(dFecha_Respuesta,'%d/%m/%Y'),cStatusPr, "sistema",iSecuenciaOs,iMotivoOs);
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;
    
    IF cNuevoStatus = 'EE' AND NVL(sBanAuto,0) = 0 AND cCanalv1 <> 0 THEN--de donde sale
     IF(SELECT COUNT(*)  FROM bdisolic:"informix".ss_solicitud_os WHERE num_solicitud=pNumSol AND secuenciaos = iSecuenciaOs)=0 THEN 
        INSERT INTO bdisolic:"informix".ss_solicitud_os
        (empresa, num_solicitud, fecha_solicitud, status,usuario_solicita, motivo_os)
        VALUES
        (pEmpresa, pNumSol, v_hoy, "S", "sistema", iMotivoOs);	
     END IF;			   
    END IF;	
    --END IF;

	----
    LET cProducto2 = cProducto;
    IF  cCanalv1 <> 4  THEN --revision para incrementos de lineasd e credito
        EXECUTE PROCEDURE bdisolic:"informix".sp_valida_comprobante(pEmpresa ,pNumCteBanco , pNumSol)
        INTO scod_ret,cMensajeRet,iValido;

        IF (scod_ret::INTEGER = 0 AND iValido = 1 AND cNuevoStatus = 'AT') THEN

            SELECT count(*) INTO isolcomp FROM bdisolic:"informix".ss_solicitudes_cac  WHERE num_solicitud = pNumSol;
            IF isolcomp = 0 THEN
                INSERT INTO bdisolic:"informix".ss_solicitudes_cac 
                (empresa, num_solicitud, numcte, sucursal, num_producto, status, ejecutivo_atiende, ejecutivo_autoriza, comprobante_valido, observaciones, os, linea_determinada_sistema, fecha_insert,hora_insert, fecha_determinacion, revisado) 
                VALUES (pEmpresa, pNumSol, pNumCteBanco,cSucursal, cProducto2, cNuevoStatus, "", "", "", "", "N", v_valor, CURRENT,CURRENT, DATE(1), 'N');	
            END IF;
        ELSE
            IF  cProducto2 IN ('9100','9300') THEN
                SELECT count(*) INTO isolcomp FROM bdisolic:"informix".ss_solicitudes_cac  WHERE num_solicitud = pNumSol;
                IF isolcomp = 0 THEN
                    INSERT INTO bdisolic:"informix".ss_solicitudes_cac 
                    (empresa, num_solicitud, numcte, sucursal, num_producto, status, ejecutivo_atiende, ejecutivo_autoriza, comprobante_valido, observaciones, os, linea_determinada_sistema, fecha_insert,hora_insert, fecha_determinacion, revisado) 
                    VALUES (pEmpresa, pNumSol, pNumCteBanco,cSucursal, cProducto2, cNuevoStatus, "", "", "", "", "N", v_valor, CURRENT,CURRENT, DATE(1), 'N');	
                END IF;			
            END IF;
        END IF;
    END IF;
		
    IF (cCanalv1 = 4)  THEN
        UPDATE bdisolic:"informix".ss_prospecteo_solicitudes 
        set sts_prev_pa 	    = cNuevoStatusProsecto, --revisar
        vvalor_junk         =  pmonto_autorizado,         
        imotivos_junk       = iMotivoOs,      
        iband_altaostel     = iBanderaFaltaOSTEL,
        ctipo_movto_junk    = cTipoMovto,         
        flagforenviomcjunk  = iFlagForzarEnvioMC,
        v_hereda_stat_junk  = v_hereda_status    
        WHERE num_solicitud = pNumSol;				

    END IF;
		
    IF cNuevoStatus = 'PA' AND  NVL(pNumSol,'') <> '' AND NVL(cStatusMovil,'') ='1' THEN			--para que cuando tenga completo el proceso lo deje en AT								

        UPDATE bdisolic:"informix".ss_solicitudes_movil		
        SET status_solicitud = cNuevoStatus		
        WHERE 	empresa  = pEmpresa 
        AND  num_solicitud = pNumSol;

    END IF;

    IF (cNuevoStatusProsecto <> 'RT' and cCanalv1 = 0) then
	
		UPDATE bdisolic:"informix".ss_prospecteo_solicitudes 
		set sts_prev_pa 	    = cNuevoStatusProsecto, 
			vvalor_junk         =  pmonto_autorizado,         
			imotivos_junk       = iMotivoOs,      
			iband_altaostel     = iBanderaFaltaOSTEL,
			ctipo_movto_junk    = cTipoMovto,         
			flagforenviomcjunk  = iFlagForzarEnvioMC,
			v_hereda_stat_junk  = v_hereda_status    
		where num_solicitud = pNumSol; 
	END IF;
    
    EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol (pEmpresa, 'sistema',pNumSol, cNuevoStatus, cCausaSolicitud, vMensajeStatus )
            INTO scod_ret;

    IF scod_ret <> '00000' THEN
        LET scod_ret = '00006'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
        IF wbegin = 'S' THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN scod_ret;
    END IF;
    IF wbegin = 'S' THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;
    RETURN scod_ret;	
END
RETURN scod_ret;
END PROCEDURE
DOCUMENT
	'AUTOR      : Andres Godinez Hernandez - Kairos DS',
	'DESCRIPCION: Procedimiento para registro de resultados del motor de evaluacion para prestamo personal',
	'------------------------------------------------------------------------------------',
	'Autor:  Erika Berenice Bautista Gil',
	'Modifica: Modificaciones parametros de entrada y tablas de certificacion para PDN (6400)',
	'Fecha: 10/03/2025',
	'Peticion:RQM 09 654 ',
	'------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_actualizasaldos_cred(pempresa CHAR(3),pNumcredito CHAR(20),pNumProd CHAR(4), pMontoEfec MONEY(14,2), pMontoCargo MONEY(14,2),pFolioMovto CHAR(20) DEFAULT "",pSucursal CHAR(4), pUsuario CHAR(20))
 RETURNING CHAR(6), CHAR(80);

DEFINE iSqlErr                       INTEGER;
DEFINE iIsamErr                      INTEGER;
DEFINE cErrorInfo                    CHAR(100);
DEFINE CodRet                        CHAR(6);
DEFINE codretRev					 CHAR(5);
DEFINE Mensaje                       CHAR(80);

DEFINE cCredito_promo                CHAR(20);
DEFINE cfolio_suc_promo              CHAR(16);
DEFINE cfolio_mov_promo              CHAR(16);
DEFINE dFecha	                     DATE;
DEFINE v_fecha_hoy                   DATE;
DEFINE dtFechaMesiversario           DATE;

DEFINE cNumTarjeta  		CHAR(20);
DEFINE cFolio               CHAR(16);
DEFINE cBegin               CHAR(1);
DEFINE  vlStatusCred        CHAR(2);
DEFINE g_Remanente						MONEY(14,2);
DEFINE g_IntMoraCob 					MONEY(14,2);
DEFINE g_IntVencCob 					MONEY(14,2);
DEFINE g_CapVencCob 					MONEY(14,2);
DEFINE g_IntVigCob 						MONEY(14,2);
DEFINE g_CapVigCob 						MONEY(14,2);
DEFINE g_Impuesto 						MONEY(14,2);
DEFINE g_Comision 						MONEY(14,2);
DEFINE g_Seguro							MONEY(14,2);
DEFINE g_SdoCapInsol					MONEY(14,2);

DEFINE v_tipocambio     DECIMAL(14,6);
DEFINE mMonto                         MONEY(14,2);
DEFINE cTrans           CHAR(4);

DEFINE mTasa		MONEY(14,2);

DEFINE iDiasMes		INTEGER;

DEFINE vmto_final_cs    MONEY(14,2);
DEFINE v_capital_cs     MONEY(14,2);
DEFINE v_interes_cs     MONEY(14,2);
DEFINE v_iva_cs         MONEY(14,2);
DEFINE GLOBAL g_Empresa        CHAR(3)     DEFAULT ' ';
DEFINE GLOBAL g_NumCredito     CHAR(20)    DEFAULT ' ';
DEFINE GLOBAL g_Folio      CHAR(16) DEFAULT ' ';
DEFINE g_Cuenta			CHAR(20);
DEFINE g_Trans 		CHAR(4);
DEFINE mSdoDisp money(14,2);
DEFINE mMontoRet money(14,2);
DEFINE cPasoCargo char(1);
DEFINE cTranPFSI_aux	CHAR(4);
DEFINE cTranCargoTdc	CHAR(4);

BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	   IF iSqlErr != 0 THEN
			  LET CodRet     = iSqlErr;
			  LET Mensaje = cErrorInfo;

		  IF cBegin = "S" THEN
			  ROLLBACK WORK;
		   END IF;

		   RETURN CodRet,Mensaje;
	   END IF;
	END EXCEPTION;

LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET CodRet              = "000000";
LET codretRev           = "00000";
LET Mensaje   = "Se realizÃÂÃÂ³ el proceso exitosamente";

LET cCredito_promo      = '';
LET cfolio_suc_promo    = '';
LET cfolio_mov_promo    = '';
LET dFecha             = DATE(1);
LET v_fecha_hoy = DATE(1);
LET dtFechaMesiversario = DATE(1);

LET cBegin           = "N";

LET v_tipocambio     = 0;
LET mMonto           =0;
LET cTrans           ="";

LET mTasa            = 0;

LET iDiasMes		 = 0;

LET vmto_final_cs    = 0;
LET v_capital_cs     = 0;
LET v_interes_cs     = 0;
LET v_iva_cs         = 0;
LET g_SdoCapInsol	 = 0;
LET g_Cuenta         = '';
LET g_Trans      	 = '';
LET mSdoDisp 	 	 = '';
LET mMontoRet 	 	 = 0;
LET cPasoCargo 		 = '';
LET vlStatusCred    = '';
LET cTranPFSI_aux	= '';
LET cTranCargoTdc	= '';



 --SET DEBUG FILE TO "/respaldosbd/Efrain/188-lib29/Saldos/sp_actualizasaldos_cred.out";
 --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    --SET PDQPRIORITY 10;
	SET LOCK MODE TO WAIT 3;
	
	 IF pNumProd = 'PFSI' THEN
		LET pNumProd = '6900';
		LET cTranPFSI_aux = '8654';
	 END IF;

	SELECT fecha_hoy INTO v_fecha_hoy
    FROM bdicred: "informix".sd_fechas a
    WHERE a.empresa = pEmpresa;


	--SE OBTIENE LA TRANSACCION PARA EL PAGO
	--ME 17/04/2018
	IF pMontoEfec > 0 THEN 			--PAGO ANTICIPADO EFECTIVO
		LET cTrans    = "8151";		--SU PAGO CREDISOLUCIONES EFECTIVO
		LET mMonto=pMontoEfec;
	ELIF pMontoCargo > 0 THEN		--PAGO ANTICIPADO CON CARGO A CUENTA
		LET cTrans    = "8150";		--SU PAGO CREDISOLUCIONES CARGO X CTA
		LET mMonto=pMontoCargo;
	END IF;
		
	--LET folio_suc=folio_suc;

	SELECT monto,mv_interes_cs,mv_iva_cs,mv_capital_cs
	INTO vmto_final_cs, v_interes_cs, v_iva_cs, v_capital_cs
	FROM bdicred: "informix".sd_montopagcrd where folio =  pFolioMovto;

	--FMV 21Jul14: Reasignacion de la variable global para generar los movimientos en la fecha correcta.

	--FOREACH WITH HOLD  --FMV 15JUL14: Se adiciona with hold, ya que solo cobraba 1 credisolucion en vencimiento.
		SELECT a.fecha, a.num_credito,a.folio_suc,a.folio_movto, c.prox_fecha_pago,a.num_tarjeta
		INTO dFecha,cCredito_promo,cfolio_suc_promo,cfolio_mov_promo,dtFechaMesiversario,cNumTarjeta
		FROM bdicred: "informix".sd_promocion_credito a, bdicred: "informix".sd_maecredcrd b, bdicred: "informix".sd_maecredanexocrd c
		WHERE a.empresa = pempresa
		AND a.empresa = b.empresa
		AND a.empresa = c.empresa
		and a.num_sol_prestamo = pNumcredito
		AND a.num_sol_prestamo = b.num_credito
		AND a.num_sol_prestamo = c.num_credito
		AND num_pro_prestamo = '6900';
		--AND a.status = 2
		--AND b.status_cred = 'AA';

		LET cCredito_promo = cCredito_promo;
		--- PROCESO GENERICO PARA GENERAR UN FOLIO PARA LA PROMOCION
		/*	EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina(pUsuario)
		INTO CodRet,g_Folio;
		IF CodRet::INTEGER <> 0 THEN
			SELECT descripcion
			INTO Mensaje
			FROM bdinteg:"informix".si_codret
			WHERE empresa        = pEmpresa
			AND codigo_retorno = CodRet;

			ROLLBACK WORK;
            IF cBegin = "S" THEN
				BEGIN WORK;
			END IF;

			RETURN CodRet,Mensaje;
		END IF;*/
		-- AAME 25102018 INC 27 108 Se actualiza la variable del folio con el que se generÃÂÃÂ³ de la credisolucion para guardar respaldo
        LET g_Folio =  pFolioMovto;
		--Inicia Respaldo de Tablas de Reversion
		LET g_NumCredito = cCredito_promo;
		CALL RespaldaCredito() RETURNING CodRet;
		IF (CodRet <> "000") THEN
			SELECT descripcion
			INTO Mensaje
			FROM bdinteg:"informix".si_codret
			WHERE empresa        = pEmpresa
			AND codigo_retorno = CodRet;

			ROLLBACK WORK;
			IF cBegin = "S" THEN
				BEGIN WORK;
			END IF;

			RETURN CodRet,Mensaje;
		END IF;
		IF ( cCredito_promo is not null ) THEN

			--8150 y 8151         RECUPERACION CREDISOLUCIONES ANTICIPADO
			--BEGIN WORK;
			LET cBegin = "S";

			IF pMontoEfec > 0 or pMontoCargo >0  THEN
			--4202         IVA CREDISOLUCIONES ANTICIPADO
				IF v_iva_cs <> 0 THEN
					
					IF cTranPFSI_aux = '8654' THEN LET cTranCargoTdc = '4202'; ELSE LET cTranCargoTdc = '8233'; END IF;
						
					CALL "informix".cargo_cred(pempresa,cCredito_promo,pSucursal,pUsuario,cTranCargoTdc, v_iva_cs,pFolioMovto, cNumTarjeta,0, v_tipocambio,v_fecha_hoy,pNumcredito, 'IVA CRED ANTICIPADO', dFecha)
					RETURNING CodRet;

					IF (CodRet <> "000") THEN
						LET CodRet      = "000016";
						LET Mensaje = "Ocurrio un error realizar el cargo de iva credisoluciones";
						IF cBegin = "S" THEN
							ROLLBACK WORK;
                           END IF;
                           RETURN CodRet,Mensaje;
					END IF;

					UPDATE bdicred: "informix".sd_maeretenido
					SET monto = monto - v_iva_cs
					WHERE empresa = '001'
					AND num_credito = cCredito_promo
					AND nvl(substr(referencia,1,16),'') = cfolio_mov_promo
					AND nvl(substr(referencia,18,3),'')= 'RET'
					AND estatus = 'R';
					
					--CAX se agrega validacion para que contemple las credisoluciones que esta ligada por el folio_suc 
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						UPDATE bdicred: "informix".sd_maeretenido
						SET monto = monto - v_iva_cs
						WHERE empresa = '001'
						AND num_credito = cCredito_promo
						AND nvl(substr(referencia,1,16),'') = cfolio_suc_promo
						AND nvl(substr(referencia,18,3),'')= 'RET'
						AND estatus = 'R';				
					END IF;	

					UPDATE bdicred: "informix".sd_maesdos
					SET sdo_retenido = sdo_retenido - v_iva_cs
					WHERE empresa = '001'
					AND num_credito = cCredito_promo;

					UPDATE bdicred: "informix".sd_promocion_credito
					SET monto_int_iva = monto_int_iva - v_iva_cs
					WHERE empresa = '001'
					AND num_sol_prestamo = pNumcredito;
				END IF;

				--4201         INTERES CREDISOLUCIONES ANTICIPADO
				IF v_interes_cs <> 0 THEN
				   
					IF cTranPFSI_aux = '8654' THEN LET cTranCargoTdc = '4201'; ELSE LET cTranCargoTdc = '8232'; END IF;
					   
					CALL "informix".cargo_cred(pempresa,cCredito_promo,pSucursal,pUsuario,cTranCargoTdc, v_interes_cs,pFolioMovto, cNumTarjeta,0, v_tipocambio,v_fecha_hoy,pNumcredito, 'INTERES CREDI ANTICI', dFecha)
					RETURNING CodRet;
					IF (CodRet <> "000") THEN
						LET CodRet      = "000016";
						LET Mensaje = "Ocurrio un error realizar el cargo de interes credisoluciones";
						IF cBegin = "S" THEN
							ROLLBACK WORK;
						END IF;
						RETURN CodRet,Mensaje;
					END IF;

					UPDATE bdicred: "informix".sd_maeretenido
					SET monto = monto - v_interes_cs
					WHERE empresa = '001'
					AND num_credito = cCredito_promo
					AND nvl(substr(referencia,1,16),'') = cfolio_mov_promo
					AND nvl(substr(referencia,18,3),'')= 'RET'
					AND estatus = 'R';					
						
					--CAX se agrega validacion para que contemple las credisoluciones que esta ligada por el folio_suc 
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						UPDATE bdicred: "informix".sd_maeretenido
						SET monto = monto - v_interes_cs
						WHERE empresa = '001'
						AND num_credito = cCredito_promo
						AND nvl(substr(referencia,1,16),'') = cfolio_suc_promo
						AND nvl(substr(referencia,18,3),'')= 'RET'
						AND estatus = 'R';				
					END IF;	

					UPDATE bdicred: "informix".sd_maesdos
					SET sdo_retenido = sdo_retenido - v_interes_cs
					WHERE empresa = '001'
					AND num_credito = cCredito_promo;

					UPDATE bdicred: "informix".sd_promocion_credito
					SET monto_int_iva = monto_int_iva - v_interes_cs
					WHERE empresa = '001'
					AND num_sol_prestamo = pNumcredito;
				END IF;

				--4200         CAPITAL CREDISOLUCIONES ANTICIPADO

				IF v_capital_cs <> 0 THEN
				   
					IF cTranPFSI_aux = '8654' THEN LET cTranCargoTdc = '4200'; ELSE LET cTranCargoTdc = '8231'; END IF;
				   
					CALL "informix".cargo_cred(pempresa,cCredito_promo,pSucursal,pUsuario,cTranCargoTdc, v_capital_cs,pFolioMovto, cNumTarjeta,0, v_tipocambio,v_fecha_hoy,pNumcredito, 'CAPITAL CRED ANTICI', dFecha)
					RETURNING CodRet;
					IF (CodRet <> "000") THEN
						LET CodRet      = "000016";
						LET Mensaje = "Ocurrio un error realizar el cargo de iva credisoluciones";
						IF cBegin = "S" THEN
							ROLLBACK WORK;
						END IF;
						RETURN CodRet,Mensaje;
					END IF;

					UPDATE bdicred: "informix".sd_maeretenido
					SET monto = monto - v_capital_cs
					WHERE empresa = '001'
					AND num_credito = cCredito_promo
					AND nvl(substr(referencia,1,16),'') = cfolio_suc_promo
					AND nvl(substr(referencia,18,3),'')= 'PAG'
					AND estatus = 'R';

					UPDATE bdicred: "informix".sd_maesdos
					SET sdo_retenido = sdo_retenido - v_capital_cs
					WHERE empresa = '001'
					AND num_credito = cCredito_promo;

					UPDATE bdicred: "informix".sd_promocion_credito
					SET monto_actual = monto_actual - v_capital_cs
					WHERE empresa = '001'
					AND num_sol_prestamo = pNumcredito;
				END IF;
				
				LET g_Folio = pFolioMovto;

				IF cTrans = '8151' AND cTranPFSI_aux != '8654' Then  -- No ejecute el pago a la TDC cuando venga desde cargo automatico de Sdo a Favor para PF Sdo Inmediato.
					COMMIT WORK;
					CALL "informix".principalrefer(pempresa,cCredito_promo,'01',cNumTarjeta,USER,pSucursal,pFolioMovto,cTrans,0,mMonto,pNumcredito)
					RETURNING CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
					
					IF (CodRet::integer <> 0  AND  CodRet::integer <> 1144) THEN
						LET CodRet      = "000016";
						LET Mensaje = "Ocurrio un error realizar la recuperacion del pago anticipado de credisoluciones";
						IF cBegin = "S" THEN
							ROLLBACK WORK;
						END IF;
					END IF;
				Elif cTrans    = "8150" THEN
					-- DSB TH 20161108
					SELECT a.numcta
					INTO g_Cuenta
					FROM  "informix".sd_verif_cuentas_crd a
					WHERE a.empresa      = pempresa 
					AND a.numcredisol  = pNumcredito;
						  
					--LET =  TRIM(cCredito_promo::char(12)) || ' CRG. CTA. MONTOS DIFERIDOS';
					
					CALL "informix".sp_cgoctefva_abontdc(pempresa,pSucursal,pUsuario,'0438',cTrans,'0618',pFolioMovto,g_Cuenta,cCredito_promo,01,mMonto,'01',TRIM(pNumcredito::char(12)) || ' CRG. CTA. MONTOS DIFERIDOS','',pUsuario,0)
					RETURNING CodRet, codretRev , iSqlErr, g_Trans, dFecha, mSdoDisp, mMontoRet, cPasoCargo, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
					--COMMIT WORK;	
					IF (CodRet::integer <> 0  AND  CodRet::integer <> 1144) THEN
						LET CodRet      = "000016";
						LET Mensaje = "Ocurrio un error realizar la recuperacion del pago anticipado de credisoluciones";
						IF cBegin = "S" THEN
							ROLLBACK WORK;
						END IF;
					END IF;							
				END IF
				LET CodRet = CodRet;
			END IF;
              --COMMIT WORK;
		END IF;

		--Seccion para Quitar Retenido Excedente
		SELECT status_cred INTO vlStatusCred
		FROM bdicred: "informix".sd_maecredcrd
		WHERE num_credito = pNumcredito;

		IF vlStatusCred = 'FF' THEN
			select  monto into  v_iva_cs
			FROM bdicred: "informix".sd_maeretenido
			WHERE empresa = '001'
			AND num_credito = cCredito_promo
			AND nvl(substr(referencia,1,16),'') = cfolio_mov_promo
			AND nvl(substr(referencia,18,3),'')= 'RET'
			AND estatus = 'R';

			--CAX se agrega validacion para que contemple las credisoluciones que esta ligada por el folio_suc 
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN		
				select  monto into  v_iva_cs
				FROM bdicred: "informix".sd_maeretenido
				WHERE empresa = '001'
				AND num_credito = cCredito_promo
				AND nvl(substr(referencia,1,16),'') = cfolio_suc_promo
				AND nvl(substr(referencia,18,3),'')= 'RET'
				AND estatus = 'R';				
			END IF;	
			
			select  monto into  v_capital_cs
			FROM bdicred: "informix".sd_maeretenido
			WHERE empresa = '001'
			AND num_credito = cCredito_promo
			AND nvl(substr(referencia,1,16),'') = cfolio_suc_promo
			AND nvl(substr(referencia,18,3),'')= 'PAG'
			AND estatus = 'R';
				 
			IF NVL(v_iva_cs,0) = 0 THEN
				LET v_iva_cs = 0;
			END IF;
			IF NVL(v_capital_cs,0) = 0 THEN
				LET v_capital_cs = 0;
			END IF;
				
			IF v_iva_cs > 0 or v_capital_cs >=0 THEN

				UPDATE bdicred: "informix".sd_maesdos
				SET sdo_retenido = sdo_retenido - (v_iva_cs+v_capital_cs)
				WHERE empresa = '001'
				AND num_credito = cCredito_promo;

				UPDATE bdicred: "informix".sd_promocion_credito
				SET monto_int_iva = 0, monto_actual = 0, status = 6
				WHERE empresa = '001'
				AND num_sol_prestamo = pNumcredito;

				UPDATE bdicred: "informix".sd_maeretenido
				SET monto = 0
				WHERE empresa = '001'
				AND num_credito = cCredito_promo
				AND nvl(substr(referencia,1,16),'') = cfolio_mov_promo
				AND nvl(substr(referencia,18,3),'')= 'RET'
				AND estatus = 'R';
				
				--CAX se agrega validacion para que contemple las credisoluciones que esta ligada por el folio_suc 
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN		
					UPDATE bdicred: "informix".sd_maeretenido
					SET monto = 0
					WHERE empresa = '001'
					AND num_credito = cCredito_promo
					AND nvl(substr(referencia,1,16),'') = cfolio_suc_promo
					AND nvl(substr(referencia,18,3),'')= 'RET'
					AND estatus = 'R';				
				END IF;	
			
				UPDATE bdicred: "informix".sd_maeretenido
				SET monto = 0
				WHERE empresa = '001'
				AND num_credito = cCredito_promo
				AND nvl(substr(referencia,1,16),'') = cfolio_suc_promo
				AND nvl(substr(referencia,18,3),'')= 'PAG'
				AND estatus = 'R';

			END IF;
		END IF;
		--END FOREACH;
		LET CodRet = "000000";
		LET Mensaje   = "Se realizo el proceso exitosamente";

    	RETURN CodRet,Mensaje;

	END;
END PROCEDURE
DOCUMENT
'Autor: 97468789 - Jesus Manuel Bustamante Lujano',
'Folio: 126',
'Descripcion: Se crea procedimiento para generar cargos a las credisoluciones',
'Fecha: 11/11/2016',
'BD: bdicred',
'----------------------------------------------------------------------------',
'Descripcion : Se modifica para que actualice el campo "monto" de la tabla "sd_maesdos" y se filtra por "referencia" ',
'Modifico    : 95451706 - Efrain Miranda',
'Fecha       : 30/03/2017',
'BD          : bdicred',
'----------------------------------------------------------------------------',
'Descripcion : Se agrega validacion para que contemple las credisoluciones que esta ligada por el folio_suc en el saldo retenido ',
'Modifico    : Cinthia Aguilar Xingu',
'Fecha       : Enero-2026',
'BD          : bdicred'
;

CREATE PROCEDURE "informix".sp_principal_suc_rr(pEmpresa                  CHAR(3),
												pNumCredito               CHAR(20),
												pProducto 				  CHAR(4),
												pMontoOperacionEfec       DECIMAL(18,2),
												pMontoOperacionCargCuenta DECIMAL(18,2),
												pUsuario 				  CHAR(8),
												pSucursal 				  CHAR(4),
												pFolio 					  CHAR(16),
												pTransaccion 			  CHAR(4))
RETURNING CHAR(5) AS Cod_Ret,
	CHAR(80)      AS mensaje_Retorno,
	CHAR(20) 	  AS Num_Credito,
	CHAR(20) 	  AS Cuenta_eje,
	CHAR(40) 	  AS Producto,
	CHAR(20) 	  AS Num_Cliente,
	CHAR(150) 	  AS Nom_Cliente,
	DECIMAL(18,2) AS Pago_Efectivo,
	DECIMAL(18,2) AS Pago_Cuenta,
	DECIMAL(18,2) AS Monto_Operacion,
	DECIMAL(18,2) AS Saldo_Actual,
	CHAR(60)      AS Status_Actual;

---DECLARACIONES
DEFINE iSqlErr                      INTEGER;
DEFINE iIsamErr                     INTEGER;
DEFINE cErrorInfo                   CHAR(80);
DEFINE cMensajeRet                  CHAR(80);
DEFINE cCodRet                      CHAR(6);
DEFINE cSucursal             	    CHAR(4);
DEFINE dMontoOperacion        		DECIMAL(18,2);
DEFINE cBanderarespaldo      	    CHAR(1);
DEFINE GLOBAL gRespaldoActivo 		CHAR(1) DEFAULT '1';
DEFINE cTransacc_rel          		CHAR(4);
DEFINE dMontoFinanciado      	    DECIMAL(18,2);
DEFINE dIvaSuc                		DECIMAL(5,3);
DEFINE dMontoInt              		DECIMAL(18,2);
DEFINE dPagoMensualidades     		DECIMAL(18,2);
DEFINE dMontoOperacionEfecAux   	DECIMAL(18,2);
DEFINE dMontoOperacionCargCuentaAux DECIMAL(18,2);
DEFINE GLOBAL g_Transacc    		CHAR(4)        DEFAULT '';
DEFINE GLOBAL g_TransaccSuc 		CHAR(4)        DEFAULT '';
DEFINE g_CodigoFun    				INTEGER;

---VARIABLES DEL PROCESO DE sp_principal_rr
DEFINE cCod_Ret		      CHAR(5);
DEFINE cMensaje_Ret       CHAR(125);
DEFINE dSdo_Ant		      DECIMAL(18,2);
DEFINE dComision	      DECIMAL(18,2);
DEFINE dIva_Com		      DECIMAL(18,2);
DEFINE dInt_Mora	      DECIMAL(18,2);
DEFINE dIva_Int_Mora      DECIMAL(18,2);
DEFINE dInt_Vdo		      DECIMAL(18,2);
DEFINE dIva_Int_Vdo       DECIMAL(18,2);
DEFINE dInt_Ordi          DECIMAL(18,2);
DEFINE dIva_Int_Ordi      DECIMAL(18,2);
DEFINE dCapital		      DECIMAL(18,2);
DEFINE dMonto_Pago        DECIMAL(18,2);
DEFINE cCuenta_Eje        CHAR(20);
DEFINE dSdo_Actual        DECIMAL(18,2);
DEFINE dPago_Min     	  DECIMAL(18,2);
DEFINE cFecha_Limite_Pago CHAR(17);

-- VARIABLES sp_principal_pp
DEFINE cCodigoRetorno_P    CHAR(5);
DEFINE cMensajeRetorno_P   CHAR(125);
DEFINE dSdo_Anterior_P     DECIMAL(18,2);
DEFINE dComision_P         DECIMAL(18,2);
DEFINE dIva_Com_P          DECIMAL(18,2);
DEFINE dInt_Mora_P         DECIMAL(18,2);
DEFINE dIva_Int_Mora_P     DECIMAL(18,2);
DEFINE dInt_Vdo_P          DECIMAL(18,2);
DEFINE dIva_Int_Vdo_P      DECIMAL(18,2);
DEFINE dInt_Ordi_P         DECIMAL(18,2);
DEFINE dIva_Int_Ordi_P     DECIMAL(18,2);
DEFINE dCapital_P          DECIMAL(18,2);
DEFINE dMonto_Pago_P       DECIMAL(18,2);
DEFINE cCuenta_Eje_P       CHAR(20);
DEFINE dSdoActual_P        DECIMAL(18,2);
DEFINE dPago_Min_P         DECIMAL(18,2);
DEFINE cFecha_LimitePago_P CHAR(17);

-- VARIABLES  sp_pago_anticipado_pp
DEFINE cCod_Retorno_Ap       CHAR(5);
DEFINE cMens_Ret          	 CHAR(125);
DEFINE dSdo_Anterior         DECIMAL(18,2);
DEFINE dComision_Ap          DECIMAL(18,2);
DEFINE dIva_Com_Ap           DECIMAL(18,2);
DEFINE dInt_Mora_Ap          DECIMAL(18,2);
DEFINE dIva_Int_Mora_Ap      DECIMAL(18,2);
DEFINE dInt_Vdo_Ap           DECIMAL(18,2);
DEFINE dIva_Int_Vdo_Ap       DECIMAL(18,2);
DEFINE dInt_Ordi_Ap          DECIMAL(18,2);
DEFINE dIva_Int_Ordi_Ap      DECIMAL(18,2);
DEFINE dCapital_Ap           DECIMAL(18,2);
DEFINE dMonto_Pago_Ap        DECIMAL(18,2);
DEFINE cCuenta_Eje_Ap        CHAR(20);
DEFINE dSdo_Act_Ap           DECIMAL(18,2);
DEFINE dPago_Min_Ap          DECIMAL(18,2);
DEFINE cFecha_Limite_Pago_Ap CHAR(17);

DEFINE cCodRetCD	  CHAR(6);
DEFINE cMensajeCD 	  CHAR(80);
DEFINE cNumCredCD 	  CHAR(20);
DEFINE cNumCteCD 	  CHAR(20);
DEFINE cNomProductoCD CHAR(40);
DEFINE cNumTarjetaCD  CHAR(20);
DEFINE cNomCteCD      CHAR(150);

--VARIABLES para sp_consulta_saldos_general
DEFINE cCodRetSP			 CHAR(6);
DEFINE cMensajeSP			 CHAR(80);
DEFINE cNumCredito      	 CHAR(20);
DEFINE cCodTipCred      	 CHAR(2);
DEFINE cDescStatusCred  	 CHAR(60);
DEFINE iIdUnidadProd     	 INTEGER;
DEFINE cCodCaract2       	 CHAR(3);
DEFINE dtFechaOrigen    	 DATE;
DEFINE dtFechaProxPago  	 DATE;
DEFINE dPagoMinimo      	 DECIMAL(18,2);
DEFINE dtFechaUltPago    	 DATE;
DEFINE iPlazo           	 INTEGER;
DEFINE iPagosRealizados 	 INTEGER;
DEFINE dLineaOtorgada    	 DECIMAL(18,2);
DEFINE dTasaInteres      	 DECIMAL(9,6);
DEFINE dTasaMoratorios  	 DECIMAL(9,6);
DEFINE dMontoSBC        	 DECIMAL(14,2);
DEFINE dCapVig           	 DECIMAL(18,2);
DEFINE dCapTrans         	 DECIMAL(18,2);
DEFINE dCapVdoExig       	 DECIMAL(18,2);
DEFINE dCapVdoNoExig    	 DECIMAL(18,2);
DEFINE dSdoActCap        	 DECIMAL(18,2);
DEFINE dIntVig           	 DECIMAL(18,2);
DEFINE dIntVdo           	 DECIMAL(18,2);
DEFINE dIntMoratorio     	 DECIMAL(18,2);
DEFINE dIntMes          	 DECIMAL(18,2);
DEFINE dSdoActInt        	 DECIMAL(18,2);
DEFINE dIvaIntVig        	 DECIMAL(18,2);
DEFINE dIvaIntVdo        	 DECIMAL(18,2);
DEFINE dIvaIntMoratorio  	 DECIMAL(18,2);
DEFINE dIvaIntMes        	 DECIMAL(18,2);
DEFINE dSdoActIvaInt     	 DECIMAL(18,2);
DEFINE dComPend          	 DECIMAL(18,2);
DEFINE dIvaCom            	 DECIMAL(18,2);
DEFINE dSdoRetenido     	 DECIMAL(18,2);
DEFINE dSdoTotalLiq     	 DECIMAL(18,2);
DEFINE dIntDevengado         DECIMAL(18,2);
DEFINE dIvaIntDevengado      DECIMAL(18,2);
DEFINE dLineaDisponible      DECIMAL(18,2);
DEFINE dPagosVdos            DECIMAL(18,2);
DEFINE cDescBloqueoCta       CHAR(60);
DEFINE cDescCausaBloqueoCta  CHAR(50);
DEFINE cSitCte               CHAR(1);
DEFINE iCausaCte             INTEGER;
DEFINE cDescSitEspCte        CHAR(75);
DEFINE cSitCred              CHAR(1);
DEFINE iCausaCred            INTEGER;
DEFINE cDescSitEspCred       CHAR(75);
DEFINE iAplicoPago           INTEGER;

-- DSB  - TH - EM -2017-03-16
DEFINE dMontoAux 			 DECIMAL(18,2);
DEFINE dtFechaActual	  	 DATE;
DEFINE dFechaAmortiza    	 DATE;
DEFINE mMensualidad          DECIMAL(18,2);
DEFINE iFlaPagoAnticipado    INTEGER;
DEFINE cCodigoFunth      	 CHAR(3);
DEFINE g_TransaccAnt		 CHAR(4);
DEFINE cCodRetAux		CHAR(6);
DEFINE dNumCredito      CHAR(20);
DEFINE mMontoEfec     MONEY(14,2);
DEFINE mMontoCargo    MONEY(14,2);
DEFINE mMonto		  MONEY(14,2);
DEFINE v_iva_cs       DECIMAL(14,2);
DEFINE cfolio_mov     CHAR(16);
DEFINE c_Folio_Suc		  CHAR(16);
--AAME Quita Validacion If exits select por variables 21052018
DEFINE cnumcredisol   CHAR(20);
DEFINE ccapital_status CHAR(1);
DEFINE vNumCte         CHAR(20); --RQM 10 915-4
DEFINE vNumCel         CHAR(13); --RQM 10 915-4
DEFINE vFecha          CHAR(10); --RQM 10 915-4
DEFINE vstcred         CHAR(2); --RQM 10 915-4
DEFINE vMontoPago      DECIMAL(18,2); --RQM 10 915-4
DEFINE banderaApoyo		SMALLINT;
---- CONDONACIONES Y QUITAS 
DEFINE indicaQuitaCondona	CHAR (1);
DEFINE montoQuita			DECIMAL(18,2);
DEFINE montoCondona			DECIMAL(18,2);
DEFINE bandera_quita_restante	SMALLINT;
DEFINE monto_condona			DECIMAL(18,2);
DEFINE monto_qc				DECIMAL(18,2);
DEFINE totalquitacapvenc    DECIMAL(18,2);
DEFINE status_cred_quita	CHAR(2);
DEFINE p_Divisa             CHAR(2);
DEFINE dFechaCuota			DATE;
DEFINE monto_balanza		DECIMAL(18,2);
DEFINE monto_orden			DECIMAL(18,2);
DEFINE condona_accesorios 	DECIMAL(18,2);
DEFINE GLOBAL gprocesa 		INT        DEFAULT 0;
DEFINE vFechaVencCred		DATE;
DEFINE cTranPFSI_aux		CHAR(4);
DEFINE cEnvioSMSRespMultic	CHAR(1);
DEFINE cbanfamilia			 CHAR(3); -- RQM 10 1177
DEFINE ATR_Cred    INTEGER;
DEFINE iPagosVencidos    INTEGER;

DEFINE vMesesVencidos		SMALLINT;
DEFINE vMesesHistoria		INTEGER;
DEFINE dMontoOtorgado   	DECIMAL(18,2);
DEFINE vIntVencido          MONEY(18,2);
DEFINE vIvaIntVigente		DECIMAL(14,2);
DEFINE vIvaIntVencido		DECIMAL(14,2); --RQM 09 459
DEFINE vCapitalMtoCuota		DECIMAL(14,2);
DEFINE vSdoCredito			DECIMAL(18,2);
DEFINE vIntMoratorio        MONEY(18,2); --RQM 09 459
DEFINE dSdoCapInsoluto      DECIMAL(14,2); 

DEFINE dFechapago   		DATE;  
DEFINE dFechaUltMov 		DATE; 
DEFINE dFechanegociacion    DATE;
DEFINE dPagorealizado       DECIMAL(14,2);
DEFINE dPagoParcial         DECIMAL(14,2);

DEFINE wBegin           CHAR(1);

--INICIALIZACIONES
LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = '';
LET cMensajeRet     = 'PROCESO EXITOSO';
LET cCodRet         = '00000';
LET cSucursal       = '';
LET dMontoOperacion = 0;
LET g_Transacc      = pTransaccion;
LET cTransacc_rel   = '';

LET dMontoFinanciado     		 = 0;
LET dIvaSuc              		 = 0;
LET dMontoInt            		 = 0;
LET dPagoMensualidades           = 0;
LET dMontoOperacionEfecAux       = pMontoOperacionEfec;
LET dMontoOperacionCargCuentaAux = pMontoOperacionCargCuenta;
LET g_CodigoFun					 = 0;

--VARIABLES DEL PROCESO DE sp_principal_rr
LET cCod_Ret		   = '';
LET cMensaje_Ret       = '';
LET dSdo_Ant		   = 0.0;
LET dComision		   = 0.0;
LET dIva_Com		   = 0.0;
LET dInt_Mora		   = 0.0;
LET dIva_Int_Mora      = 0.0;
LET dInt_Vdo		   = 0.0;
LET dIva_Int_Vdo       = 0.0;
LET dInt_Ordi          = 0.0;
LET dIva_Int_Ordi      = 0.0;
LET dCapital		   = 0.0;
LET dMonto_Pago        = 0.0;
LET cCuenta_Eje        = '';
LET dSdo_Actual        = 0.0;
LET dPago_Min          = 0.0;
LET cFecha_Limite_Pago = '';

--VARIABLES sp_principal_pp
LET cCodigoRetorno_P    = '00000';
LET cMensajeRetorno_P   = '';
LET dSdo_Anterior_P     = 0;
LET dComision_P         = 0;
LET dIva_Com_P          = 0;
LET dInt_Mora_P         = 0;
LET dIva_Int_Mora_P     = 0;
LET dInt_Vdo_P          = 0;
LET dIva_Int_Vdo_P      = 0;
LET dInt_Ordi_P         = 0;
LET dIva_Int_Ordi_P     = 0;
LET dCapital_P          = 0;
LET dMonto_Pago_P       = 0;
LET cCuenta_Eje_P       = 0;
LET dSdoActual_P        = 0;
LET dPago_Min_P         = 0;
LET cFecha_LimitePago_P = '';

-- VARIABLES sp_pago_anticipado_ppsr y sp_pago_anticipado_pp
LET cCod_Retorno_Ap          = '00000';
LET cMens_Ret             = '';
LET dSdo_Anterior         = 0;
LET dComision_Ap          = 0;
LET dIva_Com_Ap           = 0;
LET dInt_Mora_Ap          = 0;
LET dIva_Int_Mora_Ap      = 0;
LET dInt_Vdo_Ap           = 0;
LET dIva_Int_Vdo_Ap       = 0;
LET dInt_Ordi_Ap          = 0;
LET dIva_Int_Ordi_Ap      = 0;
LET dCapital_Ap           = 0;
LET dMonto_Pago_Ap        = 0;
LET cCuenta_Eje_Ap        = '';
LET dSdo_Act_Ap           = 0;
LET dPago_Min_Ap          = 0;
LET cFecha_Limite_Pago_Ap = '';

LET cCodRetCD			= '';
LET cMensajeCD 			= '';
LET cNumCredCD 			= '';
LET cNumCteCD 			= '';
LET cNomProductoCD		= '';
LET cNumTarjetaCD    	= '';
LET cNomCteCD     		= '';
LET gRespaldoActivo    	= '0';
LET cBanderarespaldo	= '1';

--INICIALIZACIONES PARA sp_consulta_saldos_general
LET cCodRetSP             = '';
LET cMensajeSP			  = '';
LET cNumCredito      	  = '';
LET cCodTipCred      	  = '';
LET cDescStatusCred  	  = '';
LET iIdUnidadProd     	  = 0;
LET cCodCaract2       	  = '';
LET dtFechaOrigen    	  = DATE(1);
LET dtFechaProxPago  	  = DATE(1);
LET dPagoMinimo      	  = 0;
LET dtFechaUltPago    	  = DATE(1);
LET iPlazo           	  = 0;
LET iPagosRealizados 	  = 0;
LET dLineaOtorgada    	  = 0;
LET dTasaInteres      	  = 0;
LET dTasaMoratorios  	  = 0;
LET dMontoSBC        	  = 0;
LET dCapVig           	  = 0;
LET dCapTrans         	  = 0;
LET dCapVdoExig       	  = 0;
LET dCapVdoNoExig    	  = 0;
LET dSdoActCap        	  = 0;
LET dIntVig           	  = 0;
LET dIntVdo           	  = 0;
LET dIntMoratorio     	  = 0;
LET dIntMes          	  = 0;
LET dSdoActInt        	  = 0;
LET dIvaIntVig        	  = 0;
LET dIvaIntVdo        	  = 0;
LET dIvaIntMoratorio  	  = 0;
LET dIvaIntMes        	  = 0;
LET dSdoActIvaInt     	  = 0;
LET dComPend          	  = 0;
LET dIvaCom            	  = 0;
LET dSdoRetenido     	  = 0;
LET dSdoTotalLiq     	  = 0;
LET dIntDevengado         = 0;
LET dIvaIntDevengado      = 0;
LET dLineaDisponible      = 0;
LET dPagosVdos            = 0;
LET cDescBloqueoCta       = '';
LET cDescCausaBloqueoCta  = '';
LET cSitCte               = '';
LET iCausaCte             = 0;
LET cDescSitEspCte        = '';
LET cSitCred              = '';
LET iCausaCred            = 0;
LET cDescSitEspCred       = '';
LET iAplicoPago           = 0;

-- DSB - TH - EM - 2017-03-16
LET dMontoAux 			= pMontoOperacionEfec + pMontoOperacionCargCuenta;
LET dtFechaActual  	 	= DATE(1);
LET dFechaAmortiza    	= DATE(1);
LET mMensualidad        = 0;
LET iFlaPagoAnticipado  = 0;
LET g_TransaccAnt       = '';
LET cCodRetAux			= '';
LET mMontoEfec          = 0;
LET mMontoCargo         = 0;
LET mMonto		        = 0;
LET v_iva_cs            = 0;
LET cfolio_mov          = "";
LET c_Folio_Suc     ='';
--AAME Quita Validacion If exits select por variables 21052018
LET cnumcredisol        = '';
LET ccapital_status 	= '';
LET vNumCte             = ''; --RQM 10 915-4
LET vNumCel             = ''; --RQM 10 915-4
LET vFecha              = ''; --RQM 10 915-4
LET vstcred             = ''; --RQM 10 915-4
LET vMontoPago          = 0; --RQM 10 915-4

LET banderaApoyo		= 0;
---- CONDONACIONES Y QUITAS 
LET indicaQuitaCondona	= '';
LET montoQuita			= 0;
LET montoCondona		= 0;
LET bandera_quita_restante = 0;
LET monto_condona			= 0;
LET monto_qc			= 0;
LET totalquitacapvenc   = 0;
LET status_cred_quita	= 0;
LET p_Divisa			= '';
LET dFechaCuota			= DATE(1);
LET monto_balanza		= 0;
LET monto_orden			= 0;
LET condona_accesorios	= 0;
LET vFechaVencCred		= DATE (1);
-- LET gprocesa				= 0;	--- variable global que valida si procesa capital para quitas
LET cTranPFSI_aux		= '';
LET cEnvioSMSRespMultic	= '';
LET cbanfamilia				= ''; -- RQM 10 1177
LET ATR_Cred  =0;
LET iPagosVencidos = 0;
--RQM 09 459
LET vMesesVencidos		= 0;
LET vMesesHistoria		= 0;
LET dMontoOtorgado  	= 0;
LET vIntVencido 		= 0;
LET vIvaIntVigente		= 0;
LET vIvaIntVencido		= 0;
LET vCapitalMtoCuota	= 0;
LET vSdoCredito			= 0;
LET vIntMoratorio 		= 0; --RQM 09 459
LET dSdoCapInsoluto     = 0;

LET dFechapago          = DATE (1);
LET dFechaUltMov        = DATE (1);
LET dFechanegociacion   = DATE (1);
LET dPagorealizado      = 0;
LET dPagoParcial        = 0;
BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
		  LET cMensajeRet  = cErrorInfo;
          RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
       END IF;
    END EXCEPTION;
  
    SELECT fecha_hoy
	INTO dtFechaActual
	FROM  bdicred:"informix".sd_fechas
	where empresa= '001';
		
	SELECT status_cred,divisa,fecha_vencim
	INTO status_cred_quita,p_Divisa,vFechaVencCred
	FROM bdicred:sd_maecredcrd
	WHERE num_credito = pNumCredito;	
	---- realiza consulta para validar si es quita, condonacion o quita por operaciones
	SELECT indicador_proceso,mto_quita,monto_condonado,fecha_negociacion --,NVL(saldo_tot_liquidar,0)
		INTO indicaQuitaCondona,montoQuita,montoCondona,dFechanegociacion --, totalquitacapvenc
	FROM bdicred:sd_bitacora_quitacondonacion
	WHERE num_credito = pNumCredito
	AND estatus_proceso = 'PR';	
	--AND fecha_negociacion >= dtFechaActual;

	IF indicaQuitaCondona IS NULL OR indicaQuitaCondona = '' THEN
		LET indicaQuitaCondona = '';
	END IF;
	
	IF montoQuita IS NULL OR montoQuita = '' THEN
		LET montoQuita = 0;
	END IF;
	
	IF montoCondona IS NULL OR montoCondona = '' THEN
		LET montoCondona = 0;
	END IF;
	IF dFechanegociacion IS NULL OR dFechanegociacion ='' THEN
		LET dFechanegociacion   = DATE (1);
	END IF;
	
    LET monto_qc = montoQuita + montoCondona;
	-- VALIDA LOS PARAMETROS DE ENTRADA
	--- se agrega validacion para que no mande error cuando es quita operativa, pueda mandar pago cero	
	IF NVL(pEmpresa,'') = '' OR NVL(pNumCredito,'') = '' OR NVL(pUsuario,'') = ''
	OR NVL(pSucursal,'') = ''   OR NVL(pFolio,'') = ''  OR NVL(g_Transacc,'') = ''
	OR (NVL(pMontoOperacionEfec,0) = 0 AND NVL(pMontoOperacionCargCuenta,0) = 0 AND indicaQuitaCondona NOT IN ('O','U')) THEN
		LET cCodRet = '00361';
		LET cMensajeRet  = 'PARAMETROS INVALIDOS';
		RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
	END IF;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF pTransaccion = '8654' THEN	-- Banderas para cargo sdo a favor en tdc para PG Sdo Inmediato
		LET cTranPFSI_aux = 'PFSI';
	END IF;

	LET g_TransaccSuc = LPAD(pTransaccion,4,'0');
    
	SELECT NVL(transacc,''),cod_fun --,NVL(transacc_rel,"")
	INTO g_Transacc,g_CodigoFun --, cTransacc_rel
	FROM bdicred:"informix".sd_conceptospagomanualcrd
	WHERE transacc_suc = g_TransaccSuc
	AND num_producto = pProducto;
	
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
	   LET cCodRet     = '00189';
	   LET cMensajeRet = 'Transaccion incorrecta';
	   RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
	END IF;
	
	-- --AAME RQM 10 1177 Se modifica para consultar por parametro los productos por familia en caso de ser mas de 1 SE OBTIENE LA FAMILIA DEL PRODUCTO
	SELECT familia
	INTO cbanfamilia
	FROM  "informix".sd_definicion 
	WHERE empresa = pEmpresa AND num_producto = pProducto;
	
	LET vMontoPago = pMontoOperacionEfec+pMontoOperacionCargCuenta; --RQM 10 915-4

	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
	   LET cCodRet     = '00189';
	   LET cMensajeRet = 'Transaccion incorrecta';
	   RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
	END IF;


	SELECT mensualidad INTO mMensualidad
	FROM bdicred:"informix".sd_promocion_credito
	WHERE num_sol_prestamo = pNumCredito
	AND empresa = pEmpresa;


	LET g_Transacc = g_Transacc;
	LET vMontoPago = vMontoPago;
	LET indicaQuitaCondona = indicaQuitaCondona;
	LET status_cred_quita = status_cred_quita;
	
	IF pProducto = '6800' THEN		-- Identifica el envio de sms o no
		IF g_Transacc = '7590' THEN
			--SELECT FIRST 1 trim(valor_alfabetico) INTO cEnvioSMSRespMultic 
			--FROM bdicred:sd_param_campania WHERE empresa = '001' AND tipo_campania = 6 AND grupo_parametro = 'PFLEX_MLTC' AND num_parametro = 2; -- atm
			LET cEnvioSMSRespMultic = '0';
			 
		ELIF g_Transacc = '8738' THEN
			--SELECT FIRST 1 trim(valor_alfabetico) INTO cEnvioSMSRespMultic 
			--FROM bdicred:sd_param_campania WHERE empresa = '001' AND tipo_campania = 6 AND grupo_parametro = 'PFLEX_MLTC' AND num_parametro = 3; -- whats
			LET cEnvioSMSRespMultic = '0';

		ELIF g_Transacc = '8317'	THEN
			--SELECT FIRST 1 trim(valor_alfabetico) INTO cEnvioSMSRespMultic 
			--FROM bdicred:sd_param_campania WHERE empresa = '001' AND tipo_campania = 6 AND grupo_parametro = 'PFLEX_MLTC' AND num_parametro = 1; -- sms
			LET cEnvioSMSRespMultic = '0';
		ELIF g_Transacc	= '5025' THEN
			--SELECT FIRST 1 trim(valor_alfabetico) INTO cEnvioSMSRespMultic 
			--FROM bdicred:sd_param_campania WHERE empresa = '001' AND tipo_campania = 6 AND grupo_parametro = 'PFLEX_MLTC' AND num_parametro = 4; -- app
			LET cEnvioSMSRespMultic = '0';
		ELIF g_Transacc	= '7506' THEN
			LET cEnvioSMSRespMultic = '0';		
		ELSE	   
			LET cEnvioSMSRespMultic = '1';
		END IF;
	END IF;

	SELECT NVL(atr,0),mto_fin_ven_trasp
	INTO ATR_Cred ,iPagosVencidos
	FROM bdicred:"informix".sd_maesdoscrd 
	WHERE num_credito = pNumCredito
	AND empresa       = pEmpresa;
			

	--- Validacion para Quita, Condonacion, O = Quita de Operaciones sin cancelcion de linea de PD, U = Quita Operacion con cancelacion si es PD
	IF g_Transacc NOT IN ('8671','8701') AND vMontoPago >= monto_qc  AND dFechanegociacion >= dtFechaActual
	--AND  ((indicaQuitaCondona = 'Q' AND status_cred_quita in ('BT')) OR (indicaQuitaCondona = 'C' AND status_cred_quita in ('BT','BA')))
	AND  ((indicaQuitaCondona = 'Q' AND (status_cred_quita in ('BT') OR status_cred_quita in ('E3')) ) 
	OR (indicaQuitaCondona = 'C' AND ((status_cred_quita in ('BT','BA')) OR (status_cred_quita in ('E1','E2','E3') and ATR_Cred>0))  )
	OR ((pProducto = '6011' AND indicaQuitaCondona = 'C' AND iPagosVencidos >= 1) 
	OR ( pProducto = '6011' AND indicaQuitaCondona = 'Q' AND iPagosVencidos >= 5) )) -- se agrega validacion por IFRS AEH
	OR (g_Transacc NOT IN ('8671','8701') AND (indicaQuitaCondona IN ('O','U') )) THEN 
	--	IF pProducto IN ('6300','7600','7700','6800','6011') THEN --PRESTAMO 12 18 y 24, PRESTAMO DIGITAL
		
		EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(pEmpresa,pNumCredito)
		INTO cCodRetSP,cMensajeSP,cNumCredito,cCodTipCred,dtFechaOrigen,dtFechaProxPago,dPagoMinimo,dtFechaUltPago,iPlazo,iPagosRealizados,dLineaOtorgada,dTasaInteres,
			dTasaMoratorios,dMontoSBC,dCapVig,dCapTrans,dCapVdoExig,dCapVdoNoExig,dSdoActCap,dIntVig,dIntVdo,dIntMoratorio,dIntMes,dSdoActInt,dIvaIntVig,dIvaIntVdo,dIvaIntMoratorio, dIvaIntMes,dSdoActIvaInt,
			dComPend,dIvaCom,dSdoRetenido,dSdoTotalLiq,dIntDevengado,dIvaIntDevengado,dLineaDisponible,dPagosVdos,cDescStatusCred,iIdUnidadProd,cDescBloqueoCta,cCodCaract2,cDescCausaBloqueoCta, cSitCte,
			iCausaCte,cDescSitEspCte,cSitCred,iCausaCred,cDescSitEspCred;
		IF cCodRetSP <> '000000' THEN
			LET cCodRet = cCodRetSP;
			LET cMensajeRet= cMensajeSP;
		END IF;

		UPDATE "informix".sd_bitacora_quitacondonacion 
		SET pago_realizado = vMontoPago,int_vencido = dIntVdo,iva_int_vencido = dIvaIntVdo, cap_vigente = dCapVig, iva_int_vigente = dIvaIntVig,
		cap_vigente_cq = NVL(dCapVig,0), iva_int_vigente_cq =  dIvaIntVig,
		int_moratorio = dIntMoratorio, iva_int_mora = dIvaIntMoratorio,int_vigente_cq =  dIntVig,
		int_vencido_cq = dIntVdo,iva_int_vencido_cq = dIvaIntVdo,
		int_moratorio_cq = dIntMoratorio, iva_int_mora_cq = dIvaIntMoratorio,
		cap_vencido = dCapVdoExig, int_vigente = dIntVig, cap_vencido_cq = dCapVdoExig,
         -----------------------------------------------------------------------	 		
		meses_vencidos = dPagosVdos, copete_moratorio = NVL(dIntMoratorio,0) + NVL(dIvaIntMoratorio,0), 
		saldo_tot_liquidar = dSdoTotalLiq WHERE num_credito = pNumCredito and estatus_proceso='PR';
		-----------------------------------------------------------------------	
		COMMIT;
		BEGIN;	
		IF pProducto NOT IN ('6011','8600') THEN

			---- total balanza
			SELECT SUM(interes_debe - interes_pagado + iva_debe - iva_pagado) 
			into monto_orden
			---into monto_balanza
			FROM  bdicred:sd_amortiza_creditocrd
			WHERE campo_trabajo3 = 'V'		---- V es Orden
			and capital_status = '2'
			AND num_credito = pNumCredito;
				
			---- total orden
			SELECT SUM(interes_debe - interes_pagado + iva_debe - iva_pagado) 
			into monto_balanza
			--- into monto_orden
			FROM  bdicred:sd_amortiza_creditocrd
			WHERE campo_trabajo3 <> 'V'		--- diferente de V es balanza
			and capital_status = '2'
			AND num_credito = pNumCredito;

			IF monto_balanza IS NULL THEN LET monto_balanza = 0; END IF;
			IF monto_orden IS NULL THEN LET monto_orden = 0; END IF;
							
			--			LET condona_accesorios = dIntMoratorio + dIvaIntMoratorio + monto_balanza;
			LET condona_accesorios = dIntMoratorio + dIvaIntMoratorio + monto_orden;
		
			IF vMontoPago < dSdoTotalLiq THEN
					--- si el monto efectivo es mayor a capital e interes de orden, solo se condonana moratorios y lo que alcance de vencidos.
				IF vMontoPago > dSdoActCap + monto_balanza THEN

					LET condona_accesorios = dSdoTotalLiq - vMontoPago;	 -- 	- (vMontoPago - (dSdoActCap + monto_balanza));
					IF condona_accesorios > 0 THEN	---- aplica pago de accesorios que logre pagar
						LET gprocesa = 1;
						EXECUTE PROCEDURE bdicred:"informix".sp_principal_pp (pEmpresa,pNumCredito,1,condona_accesorios,pUsuario,pSucursal,pFolio,'8671')
						INTO cCodigoRetorno_P,cMensajeRetorno_P,dSdo_Anterior_P,dComision_P,dIva_Com_P,dInt_Mora_P,dIva_Int_Mora_P,dInt_Vdo_P,dIva_Int_Vdo_P,dInt_Ordi_P,dIva_Int_Ordi_P,dCapital_P,dMonto_Pago_P, cCuenta_Eje_P,dSdoActual_P,dPago_Min_P,cFecha_LimitePago_P;

					END IF;
				ELSE	
					--- Cuando no cubre capitales e int balanza, entonces no alcanza.. se condona al 100%				
					IF condona_accesorios > 0 THEN
						LET gprocesa = 1;
						EXECUTE PROCEDURE bdicred:"informix".sp_principal_pp (pEmpresa,pNumCredito,1,condona_accesorios,pUsuario,pSucursal,pFolio,'8671')
						INTO cCodigoRetorno_P,cMensajeRetorno_P,dSdo_Anterior_P,dComision_P,dIva_Com_P,dInt_Mora_P,dIva_Int_Mora_P,dInt_Vdo_P,dIva_Int_Vdo_P,dInt_Ordi_P,dIva_Int_Ordi_P,dCapital_P,dMonto_Pago_P, cCuenta_Eje_P,dSdoActual_P,dPago_Min_P,cFecha_LimitePago_P;

					END IF;	
				END IF;
			END IF;
		ELSE

			LET condona_accesorios = dSdoTotalLiq - dSdoActCap;
			----- QUITA DE REESTRUCTURAS  
			IF vMontoPago < dSdoTotalLiq THEN
					--- si el monto efectivo es mayor a capital e interes de orden, solo se condonana moratorios y lo que alcance de vencidos.
				IF vMontoPago > dSdoActCap THEN
				
					LET condona_accesorios = dSdoTotalLiq - vMontoPago;
					
					IF condona_accesorios > 0 THEN	---- aplica pago de accesorios y capital que logre pagar
						LET gprocesa = 1;
						EXECUTE PROCEDURE bdicred:"informix".sp_principal_rr
						(pEmpresa,pNumCredito,1,condona_accesorios,pUsuario,pSucursal,pFolio,'8701')
						INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;

					END IF;
				ELSE	
					--- Cuando no cubre capitales e int balanza, entonces no alcanza.. se condona al 100%	
					IF condona_accesorios > 0 THEN
						LET gprocesa = 1;
						EXECUTE PROCEDURE bdicred:"informix".sp_principal_rr
						(pEmpresa,pNumCredito,1,condona_accesorios,pUsuario,pSucursal,pFolio,'8701')
						INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;

					END IF;	
				END IF;
			END IF;

		END IF;
			LET g_TransaccSuc = LPAD(pTransaccion,4,'0');
			SELECT NVL(transacc,''),cod_fun --,NVL(transacc_rel,"")
			INTO g_Transacc,g_CodigoFun --, cTransacc_rel
			FROM bdicred:"informix".sd_conceptospagomanualcrd
			WHERE transacc_suc = g_TransaccSuc
			AND num_producto = pProducto;
			--- Apaga respaldo
			IF condona_accesorios > 0  THEN
				LET gRespaldoActivo = '1';
				LET gprocesa = 2;
			END IF;
	     --Si el pago es menor al monto quita/condonado y la fecha de pago sea menor o igual a la fecha negociacion se actualiza el pago en la bitacora
	ELIF g_Transacc NOT IN ('8671','8701') AND vMontoPago < monto_qc  AND dFechanegociacion >= dtFechaActual
	AND  ((indicaQuitaCondona = 'Q' AND (status_cred_quita in ('BT') OR status_cred_quita in ('E3')) ) 
	OR (indicaQuitaCondona = 'C' AND ((status_cred_quita in ('BT','BA')) OR (status_cred_quita in ('E1','E2','E3')))  ) 
	OR ((pProducto = '6011' AND indicaQuitaCondona = 'C' AND iPagosVencidos >= 1) 
	OR (pProducto = '6011' AND indicaQuitaCondona = 'Q' AND iPagosVencidos >= 5) ))    THEN
		 
        UPDATE "informix".sd_bitacora_quitacondonacion 
		SET pago_realizado = vMontoPago
        WHERE num_credito = pNumCredito and estatus_proceso='PR';
COMMIT;	
	BEGIN; 
	LET indicaQuitaCondona = '';
		
	ELIF dFechanegociacion < dtFechaActual AND g_Transacc NOT IN ('8671','8701') AND ((indicaQuitaCondona = 'Q' AND (status_cred_quita in ('BT') OR status_cred_quita in ('E3')) ) 
	OR (indicaQuitaCondona = 'C' AND ((status_cred_quita in ('BT','BA')) OR (status_cred_quita in ('E1','E2','E3')))  ) 		
	OR ((pProducto = '6011' AND indicaQuitaCondona = 'C' AND iPagosVencidos >= 1) 
	OR (pProducto = '6011' AND indicaQuitaCondona = 'Q' AND iPagosVencidos >= 5))) THEN
		
			UPDATE "informix".sd_bitacora_quitacondonacion 
			SET estatus_proceso = 'CN',fecha_status = dtFechaActual
            WHERE num_credito = pNumCredito and estatus_proceso='PR';
	COMMIT;	
	
	BEGIN; 
		LET indicaQuitaCondona = '';
		   
	ELSE
		-- Si no pasa por el flujo y variable global esta activa no realiza respaldo, prepara el anticipo de quita
		LET indicaQuitaCondona = '';
		IF gprocesa = 2 THEN
			LET gRespaldoActivo = '1';
		END IF;
	END IF;

	--AAME Quita Validacion If exits select por variables 21052018
	SELECT limit 1 NVL(a.capital_status,'')
	INTO ccapital_status
	FROM bdicred:"informix".sd_amortiza_creditocrd a
	WHERE a.empresa = pEmpresa
	AND a.num_credito = pNumCredito
	AND a.capital_status IN ('1','2','7','6');
		
	IF NVL(ccapital_status,'') = '' THEN
		SELECT limit 1 NVL(a.capital_status,'')
		INTO ccapital_status
		FROM bdicred:"informix".sd_amortiza_creditocrd a
		WHERE a.empresa     = pEmpresa
		AND a.num_credito = pNumCredito
		AND a.capital_status IN ('3');
	END IF;

	 --se valida si se va realizar un pago normal.
	IF ccapital_status IN ('1','2','7','6') THEN --AAME Quita Validacion If exits select por variables 21052018

		--se obtiene la informacion del  cliente
		SELECT  a.sucursal, b.monto_financiado, round((today - a.fecha_apertura)/30.4)
		INTO  cSucursal, dMontoFinanciado, vMesesHistoria
		FROM bdicred:"informix".sd_maecredcrd a,
		bdicred:"informix".sd_maesdoscrd b,
		bdicred:"informix".sd_maecredanexocrd c
		WHERE a.num_credito = pNumCredito
		AND a.empresa       = pEmpresa
		AND b.empresa       = a.empresa
		AND b.num_credito   = a.num_credito
		AND c.num_credito   = b.num_credito
		AND c.empresa       = b.empresa;

		SELECT iva
		INTO dIvaSuc
		FROM bdinteg:"informix".si_sucursales
		WHERE empresa = pEmpresa
		AND sucursal  = cSucursal;

		-- 2011-11-30 Se cambia metodo de calculo de moratorio
		SELECT SUM(interes_debe - interes_pagado + iva_debe - iva_pagado + mora_sdo_ordi - mora_sdo_ordi_pag + mora_sdo_cope - mora_sdo_cope_pag) +	(SUM(round((mora_sdo_ordi - mora_sdo_ordi_pag + mora_sdo_cope - mora_sdo_cope_pag)*dIvaSuc,2)))
		INTO dMontoInt
		FROM bdicred:"informix".sd_amortiza_creditocrd
		WHERE empresa = pEmpresa
		AND num_credito = pNumCredito
		AND capital_status IN ('2','7','1','6');

		LET dMontoFinanciado = dMontoFinanciado + dMontoInt;
		---- se agrega transacciones de quitas solo para pago en efectivo
		IF g_Transacc IN ('7970','8205','8160','8286', '7990','8335','8671','8701','8654','4320')  THEN--pago en efectivo --DSB 20/11/2015 se Agrega la Transaccion 8160 --- 8335 SPEI

			IF pMontoOperacionEfec <= dMontoFinanciado THEN
				LET dPagoMensualidades = pMontoOperacionEfec;
				LET dMontoFinanciado = dMontoFinanciado - pMontoOperacionEfec;
				LET pMontoOperacionEfec = 0;
			ELSE
				LET dPagoMensualidades = dMontoFinanciado;
				LET pMontoOperacionEfec = pMontoOperacionEfec - dPagoMensualidades;
				LET dMontoFinanciado =0;
			END IF;

			IF pProducto IN ('6011','8600') THEN --REESTRUCTURAS
				EXECUTE PROCEDURE bdicred:"informix".sp_principal_rr
				(pEmpresa,pNumCredito,1,dPagoMensualidades,pUsuario,pSucursal,pFolio,g_Transacc)
				INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;

				IF cCod_Ret::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A')
					INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
					LET cCodRet      = cCod_Ret;
					LET cMensajeRet  = cMensaje_Ret;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
				END IF;
				LET dSdo_Actual = dSdo_Actual;
				LET cCuenta_Eje = cCuenta_Eje;
				LET gRespaldoActivo = '1';
				LET cBanderarespaldo = '0';
				LET dPagoMensualidades = 0;
			--AAME 2015-03-19 RQM 10 550 Se modifica para contemplar los dos nuevos productos de prestamo (7600,7700)
			--- Se agrega variable para indicar si el pago es mayor a cero de lo contrario mandara error el sp principal pp
			--ELIF pProducto IN ('6300','6400','7600','7700','6800','6900') AND dPagoMensualidades > 0 THEN --PRESTAMO,NOMINA,FLEXIBLE,MONTOS_DIFERIDOS
																								  
			ELIF (cbanfamilia IN ('002','003') OR pProducto='6900') AND dPagoMensualidades > 0 THEN --PRESTAMO,NOMINA,FLEXIBLE,MONTOS_DIFERIDOS			
				EXECUTE PROCEDURE bdicred:"informix".sp_principal_pp (pEmpresa,pNumCredito,1,dPagoMensualidades,pUsuario,pSucursal,pFolio,g_Transacc)
				INTO cCodigoRetorno_P,cMensajeRetorno_P,dSdo_Anterior_P,dComision_P,dIva_Com_P,dInt_Mora_P,dIva_Int_Mora_P,dInt_Vdo_P,dIva_Int_Vdo_P,dInt_Ordi_P,dIva_Int_Ordi_P,dCapital_P,dMonto_Pago_P, cCuenta_Eje_P,dSdoActual_P,dPago_Min_P,cFecha_LimitePago_P;

				IF cCodigoRetorno_P::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A')
					INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
					LET cCodRet      = cCodigoRetorno_P;
					LET cMensajeRet  = cMensajeRetorno_P;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
				END IF;

				LET dSdo_Actual = dSdoActual_P;
				LET cCuenta_Eje = cCuenta_Eje_P;
				LET gRespaldoActivo = '1';
				LET cBanderarespaldo = '0';
				LET dPagoMensualidades = 0;
			END IF;			
			--IF pProducto IN ('6900') THEN
			--	LET pMontoOperacionEfec = dPagoMensualidades;
			--END IF;
			
			IF pMontoOperacionEfec > 0 THEN
				IF pProducto IN ('6011','8600') THEN
					-- REALIZA EL PAGO ANTICIPADO
					EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_rr
					(pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionEfec,cBanderarespaldo)
					INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,
					dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;

					IF cCod_Ret::INTEGER <> 0 THEN
					   EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A')   INTO cCodRet;
						IF cCodRet::INTEGER NOT IN(0,1) THEN
							LET cCodRet      = '00368';
							LET cMensajeRet  = 'Error al realizar la reversion del pago';
							RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
						END IF;
						LET cCodRet      = cCod_Ret;
						LET cMensajeRet  = cMensaje_Ret;
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
					LET dSdo_Actual = dSdo_Actual;
					LET cCuenta_Eje = cCuenta_Eje;
				--ELIF pProducto IN ('6300','6400','7600','7700','6900','6800') THEN	
				--AAME 2015-03-19 RQM 10 550 Se modifica para contemplar los dos nuevos productos de prestamo (7600,7700)
																		
																								   
				ELIF (cbanfamilia IN ('002','003') OR pProducto='6900')  THEN
				-- REALIZA EL PAGO ANTICIPADO

					EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_pp
					(pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionEfec,cBanderarespaldo)
					INTO cCod_Retorno_Ap,cMens_Ret,dSdo_Anterior,dComision_Ap,dIva_Com_Ap,dInt_Mora_Ap,dIva_Int_Mora_Ap,dInt_Vdo_Ap,dIva_Int_Vdo_Ap,dInt_Ordi_Ap,dIva_Int_Ordi_Ap,dCapital_Ap,dMonto_Pago_Ap,cCuenta_Eje_Ap,dSdo_Act_Ap,dPago_Min_Ap,cFecha_Limite_Pago_Ap;

					IF cCod_Retorno_Ap::INTEGER <> 0 THEN
					   EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
						IF cCodRet::INTEGER NOT IN(0,1) THEN
							LET cCodRet      = '00368';
							LET cMensajeRet  = 'Error al realizar la reversion del pago';
							RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
						END IF;
						LET cCodRet      = cCod_Retorno_Ap;
						LET cMensajeRet  = cMens_Ret;
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;

					LET dSdo_Actual=dSdo_Act_Ap;
					LET cCuenta_Eje= cCuenta_Eje_Ap;

				END IF;
			END IF;
		END IF;
					
		--IF g_Transacc in ('7998') OR cTransacc_rel = '7998' OR g_Transacc = '8150' THEN -- pago  con cargo a cuenta --DSB 20/11/2015 se agrega transaccion 8150
		IF g_Transacc in ('7998','8317','7590','8738','5025','9888') OR cTransacc_rel IN ('7998','8317','7590','8738','5025') OR g_Transacc = '8150' THEN -- pago  con cargo a cuenta --DSB 20/11/2015 se agrega transaccion 8150
			IF cTransacc_rel <> '' THEN
				LET g_Transacc = cTransacc_rel;
			END IF;

			IF dMontoFinanciado > 0 THEN
				IF pMontoOperacionCargCuenta <= dMontoFinanciado THEN
				  LET dPagoMensualidades = pMontoOperacionCargCuenta;
				  LET dMontoFinanciado = dMontoFinanciado - pMontoOperacionCargCuenta;
				  LET pMontoOperacionCargCuenta = 0;
				ELSE
				  LET dPagoMensualidades = dMontoFinanciado;
				  LET pMontoOperacionCargCuenta = pMontoOperacionCargCuenta - dPagoMensualidades;
				  LET dMontoFinanciado =0;
				END IF;
			END IF;

			--pago con cargo a cuenta     
			IF pProducto IN ('6011','8600') AND dPagoMensualidades > 0 THEN
				EXECUTE PROCEDURE bdicred:"informix".sp_principal_rr
				(pEmpresa,pNumCredito,1,dPagoMensualidades,pUsuario,pSucursal,pFolio,g_Transacc)
				INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;

				IF cCod_Ret::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
					LET cCodRet      = cCod_Ret;
					LET cMensajeRet  = cMensaje_Ret;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
				END IF;
				LET dSdo_Actual=dSdo_Actual;
				LET cCuenta_Eje= cCuenta_Eje;
				LET gRespaldoActivo = '1';
				LET cBanderarespaldo = '0';
				LET dPagoMensualidades = 0;
			--AAME 2015-03-19 RQM 10 550 Se modifica para contemplar los dos nuevos productos de prestamo (7600,7700)
			--ELIF pProducto IN ('6300','6400','7600','7700','6800','6900') AND dPagoMensualidades > 0 THEN
			--AAME RQM 10 1177 Se valida la familia de productos Prestamos y Linea Credito a Plazo
			ELIF (cbanfamilia IN ('002','003') OR pProducto='6900') AND dPagoMensualidades > 0 THEN
				EXECUTE PROCEDURE bdicred:"informix".sp_principal_pp
				(pEmpresa,pNumCredito,1,dPagoMensualidades,pUsuario,pSucursal,pFolio,g_Transacc)
				INTO cCodigoRetorno_P,cMensajeRetorno_P,dSdo_Anterior_P,dComision_P,dIva_Com_P,dInt_Mora_P,dIva_Int_Mora_P,dInt_Vdo_P,dIva_Int_Vdo_P,dInt_Ordi_P,dIva_Int_Ordi_P,dCapital_P,dMonto_Pago_P, cCuenta_Eje_P,dSdoActual_P,dPago_Min_P,cFecha_LimitePago_P;

				IF cCodigoRetorno_P::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
					LET cCodRet      = cCodigoRetorno_P;
					LET cMensajeRet  = cMensajeRetorno_P;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
				END IF;

				LET dSdo_Actual=dSdoActual_P;
				LET cCuenta_Eje= cCuenta_Eje_P;
				LET gRespaldoActivo = '1';
				LET cBanderarespaldo = '0';
				LET dPagoMensualidades = 0;
			
			END IF;
			--IF pProducto IN ('6900') THEN
			--	LET pMontoOperacionCargCuenta = dPagoMensualidades;
			--END IF;
			
			IF pMontoOperacionCargCuenta > 0  THEN
				IF pProducto IN  ('6011','8600') THEN
					EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_rr
					(pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionCargCuenta,cBanderarespaldo)
					INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,
					dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;
						 
					IF cCod_Ret::INTEGER <> 0 THEN
						EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
						IF cCodRet::INTEGER NOT IN(0,1) THEN
							LET cCodRet      = '00368';
							LET cMensajeRet  = 'Error al realizar la reversion del pago';
							RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
						END IF;
						LET cCodRet      = cCod_Ret;
						LET cMensajeRet  = cMensaje_Ret;
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
					LET dSdo_Actual=dSdo_Actual;
					LET cCuenta_Eje= cCuenta_Eje;
				--AAME 2015-03-19 RQM 10 550 Se modifica para contemplar los dos nuevos productos de prestamo (7600,7700)
				--ELIF pProducto IN ('6300','6400','7600','7700','6900','6800') THEN
				--AAME RQM 10 1177 Se valida la familia de productos Prestamo y linea de credito a Plazo
				ELIF (cbanfamilia IN ('002','003') OR pProducto='6900')  THEN

					-- REALIZA EL PAGO ANTICIPADO (VIGENTE)
					EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_pp
					(pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionCargCuenta,cBanderarespaldo)
					INTO cCod_Retorno_Ap,cMens_Ret,dSdo_Anterior,dComision_Ap,dIva_Com_Ap,dInt_Mora_Ap,dIva_Int_Mora_Ap,dInt_Vdo_Ap,dIva_Int_Vdo_Ap,dInt_Ordi_Ap,dIva_Int_Ordi_Ap,dCapital_Ap,dMonto_Pago_Ap,cCuenta_Eje_Ap,dSdo_Act_Ap,dPago_Min_Ap,cFecha_Limite_Pago_Ap;
		 
					IF cCod_Retorno_Ap::INTEGER <> 0 THEN
						EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
						IF cCodRet::INTEGER NOT IN(0,1) THEN
							LET cCodRet      = '00368';
							LET cMensajeRet  = 'Error al realizar la reversion del pago';
							RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
						END IF;
						LET cCodRet      = cCod_Retorno_Ap;
						LET cMensajeRet  = cMens_Ret;
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
 					
					LET dSdo_Actual = dSdo_Act_Ap;
					LET cCuenta_Eje = cCuenta_Eje_Ap;
				END IF;
			END IF;
		END IF;

		--cuando entra por este flujo se realiza un pago anticipado
	ELIF ccapital_status IN ('3') THEN --AAME Quita Validacion If exits select por variables 21052018
	---- se agregan transacciones de quitas para pago anticipado solo en pago efectivo	
		IF g_Transacc IN ('7970','8205','8160','8286','7990','8335','8671','8701','8654','4320')  THEN --pago en efectivo --- 8335 SPEI

			IF pProducto IN  ('6011','8600') THEN
				EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_rr
				(pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionEfec,cBanderarespaldo)
				INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,
				dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;

				IF cCod_Ret::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
					LET cCodRet      = cCod_Ret;
					LET cMensajeRet  = cMensaje_Ret;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
				END IF;
				LET dSdo_Actual = dSdo_Actual;
				LET cCuenta_Eje = cCuenta_Eje;
				LET gRespaldoActivo = '1';
				LET cBanderarespaldo = '0';
			--AAME 2015-03-19 RQM 10 550 Se modifica para contemplar los dos nuevos productos de prestamo (7600,7700)
			--ELIF pProducto IN ('6300','6400','7600','7700','6900','6800') THEN
			--AAME RQM 10 1177 Se valida la familia de productos prestamos y linea credito a Plazo
			ELIF (cbanfamilia IN ('002','003') OR pProducto='6900') THEN
				-- REALIZA EL PAGO ANTICIPADO (VIGENTE)
				EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_pp
				(pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionEfec,cBanderarespaldo)
				INTO cCod_Retorno_Ap,cMens_Ret,dSdo_Anterior,dComision_Ap,dIva_Com_Ap,dInt_Mora_Ap,dIva_Int_Mora_Ap,dInt_Vdo_Ap,dIva_Int_Vdo_Ap,dInt_Ordi_Ap,dIva_Int_Ordi_Ap,dCapital_Ap,dMonto_Pago_Ap,cCuenta_Eje_Ap,dSdo_Act_Ap,dPago_Min_Ap,cFecha_Limite_Pago_Ap;

				IF cCod_Retorno_Ap::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
					LET cCodRet      = cCod_Retorno_Ap;
					LET cMensajeRet  = cMens_Ret;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
				END IF;
				
				LET dSdo_Actual=dSdo_Act_Ap;
				LET cCuenta_Eje= cCuenta_Eje_Ap;
				LET gRespaldoActivo = '1';
				LET cBanderarespaldo = '0';
								
			END IF;
		END IF;

		--IF g_Transacc ='7998' OR cTransacc_rel = '7998' OR g_Transacc = '8150' THEN  -- pago  con cargo a cuenta  --EM-17/03/2017'
		IF g_Transacc IN ('7998','8317','7590','8738','5025','9888') OR cTransacc_rel IN ('7998','8317','7590','8738','5025') OR g_Transacc = '8150' THEN  -- pago  con cargo a cuenta  --EM-17/03/2017'

			IF cTransacc_rel <> '' THEN
				LET g_Transacc = cTransacc_rel;
			END IF;

			IF pProducto IN  ('6011','8600') THEN
				EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_rr
				(pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionCargCuenta,cBanderarespaldo)
				INTO cCod_Ret,cMensaje_Ret,dSdo_Ant,dComision,dIva_Com,dInt_Mora,dIva_Int_Mora,dInt_Vdo,
				dIva_Int_Vdo,dInt_Ordi,dIva_Int_Ordi,dCapital,dMonto_Pago,cCuenta_Eje,dSdo_Actual,dPago_Min,cFecha_Limite_Pago;

				IF cCod_Ret::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
					LET cCodRet      = cCod_Ret;
					LET cMensajeRet  = cMensaje_Ret;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
				END IF;
				LET dSdo_Actual=dSdo_Actual;
				LET cCuenta_Eje= cCuenta_Eje;
				LET gRespaldoActivo = '1';
			--AAME 2015-03-19 RQM 10 550 Se modifica para contemplar los dos nuevos productos de prestamo (7600,7700)
			--ELIF pProducto IN ('6300','6400','7600','7700','6900','6800') THEN
			--AAME RQM 10 1177 Se valida la familia de productos prestamo y linea credito a Plazo
			ELIF (cbanfamilia IN ('002','003') OR pProducto='6900') THEN

				-- REALIZA EL PAGO ANTICIPADO (VIGENTE)
				EXECUTE PROCEDURE bdicred:"informix".sp_pago_anticipado_pp (pEmpresa,pNumCredito,pUsuario,pSucursal,pFolio,g_Transacc,pMontoOperacionCargCuenta,cBanderarespaldo)
				INTO cCod_Retorno_Ap,cMens_Ret,dSdo_Anterior,dComision_Ap,dIva_Com_Ap,dInt_Mora_Ap,dIva_Int_Mora_Ap,dInt_Vdo_Ap,dIva_Int_Vdo_Ap,dInt_Ordi_Ap,dIva_Int_Ordi_Ap,dCapital_Ap,dMonto_Pago_Ap,cCuenta_Eje_Ap,dSdo_Act_Ap,dPago_Min_Ap,cFecha_Limite_Pago_Ap;

				IF cCod_Retorno_Ap::INTEGER <> 0 THEN
					EXECUTE PROCEDURE bdicred:"informix".reversioncrd(pEmpresa,pSucursal,pUsuario,pFolio,'A') INTO cCodRet;
					IF cCodRet::INTEGER NOT IN(0,1) THEN
						LET cCodRet      = '00368';
						LET cMensajeRet  = 'Error al realizar la reversion del pago';
						RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
					END IF;
					LET cCodRet      = cCod_Retorno_Ap;
					LET cMensajeRet  = cMens_Ret;
					RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
				END IF;
				LET dSdo_Actual=dSdo_Act_Ap;
				LET cCuenta_Eje= cCuenta_Eje_Ap;
				LET gRespaldoActivo = '1';
			END IF;
		END IF;
	ELSE
		-- Cuando el credito ya esta saldado... y no es posible aplicar el pago
		LET cCodRet = '00374';
		LET cMensajeRet= 'El credito ya esta saldado';
		RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
	END IF;
	
	IF pProducto = '6900' AND g_Transacc IN ("8150","8160","8654") THEN	
		IF g_Transacc ="8150" THEN
			LET mMontoCargo = dMontoAux;
		END IF;

		IF g_Transacc in ("8160","8654") THEN
			LET mMontoEfec = dMontoAux;
			--AAME Quita Validacion If exits select por variables 21052018
			Select limit 1 numcredisol 
			INTO cnumcredisol
			from  bdicred: "informix".sd_verif_cuentas_crd  
			where empresa = pempresa AND numcredisol = pNumCredito;
			
			IF cnumcredisol <> '' Then
				DELETE FROM bdicred: "informix".sd_verif_cuentas_crd WHERE empresa = pempresa AND numcredisol=pNumCredito;
			END IF
		END IF;

		IF cTranPFSI_aux = 'PFSI' THEN
			CALL "informix".sp_actualizasaldos_cred(pempresa,pNumCredito,'PFSI',mMontoEfec,mMontoCargo,pFolio,pSucursal, pUsuario) RETURNING cCodRetAux, cMensajeRet;
		ELSE
			CALL "informix".sp_actualizasaldos_cred(pempresa,pNumCredito,pProducto,mMontoEfec,mMontoCargo,pFolio,pSucursal, pUsuario) RETURNING cCodRetAux, cMensajeRet;
		END IF;

	   IF (cCodRetAux <> "000000") THEN
		   LET cCodRet      = "00053";
		   LET cMensajeRet  = "Ocurrio un error al registrar el movimiento de Pago del credisolucion";

			/*IF (wBegin = "S") THEN
			   BEGIN WORK;
			END IF;*/
			RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
		END IF;	
	END IF;
	-- OBTIENE LOS DATOS DEL PRESTAMO/REESTRUCTURA/CREDINOMINA
	EXECUTE PROCEDURE bdicred:"informix".sp_consulta_datos_general(pEmpresa, '',pNumCredito,'','','','')
	INTO cCodRetCD,cMensajeCD,cNumCredCD,cNumCteCD,cNomProductoCD,cNumTarjetaCD,cNomCteCD;
	IF cCodRetCD::INTEGER <> 0 THEN
		LET cCodRet = cCodRetCD;
		LET cMensajeRet= cMensajeCD;
		RETURN cCodRet,cMensajeRet,'','','','','',0,0,0,0,cDescStatusCred;
	END IF;

	LET dMontoOperacion = dMontoOperacionEfecAux + dMontoOperacionCargCuentaAux;
	
	--Se ejecuta sp para poder obtener el status del credito
	EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(pEmpresa,pNumCredito)
	INTO cCodRetSP,cMensajeSP,cNumCredito,cCodTipCred,dtFechaOrigen,dtFechaProxPago,dPagoMinimo,dtFechaUltPago,iPlazo,iPagosRealizados,dLineaOtorgada,dTasaInteres,dTasaMoratorios,dMontoSBC,dCapVig,dCapTrans,dCapVdoExig,dCapVdoNoExig,dSdoActCap,dIntVig,dIntVdo,dIntMoratorio,dIntMes,dSdoActInt,dIvaIntVig,dIvaIntVdo,dIvaIntMoratorio, dIvaIntMes,dSdoActIvaInt,dComPend,dIvaCom,dSdoRetenido,dSdoTotalLiq,dIntDevengado,dIvaIntDevengado,dLineaDisponible,dPagosVdos,cDescStatusCred,iIdUnidadProd,cDescBloqueoCta,cCodCaract2,cDescCausaBloqueoCta, cSitCte,iCausaCte,cDescSitEspCte,cSitCred,iCausaCred,cDescSitEspCred;
	IF cCodRetSP <> '000000' THEN
		LET cCodRet = cCodRetSP;
		LET cMensajeRet= cMensajeSP;
	END IF;
	
	IF dSdoActCap <= 0 THEN
		IF pProducto = '6900' AND g_Transacc IN("8150","8160","8654") THEN
			--Seccion para Quitar Retenido Excedente
			SELECT monto_actual,monto_int_iva,folio_movto,num_credito INTO mMonto,v_iva_cs,cfolio_mov,dNumCredito
			FROM "informix".sd_promocion_credito
			WHERE empresa = '001'
			AND num_sol_prestamo = pNumCredito;

			UPDATE bdicred: "informix".sd_maesdos
			SET sdo_retenido = sdo_retenido - (mMonto + v_iva_cs)
			WHERE empresa = '001'
			AND num_credito = dNumCredito;

			UPDATE bdicred: "informix".sd_promocion_credito
			SET monto_actual=0,monto_int_iva = 0, status = 6
			WHERE empresa = '001'
			AND num_sol_prestamo = pNumCredito;

			UPDATE bdicred: "informix".sd_maeretenido
			SET monto = 0
			WHERE empresa = '001'
			AND num_credito = dNumCredito
			AND nvl(substr(referencia,1,16),'') = cfolio_mov
			AND nvl(substr(referencia,18,3),'')= 'RET'
			AND estatus = 'R';
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN		
				UPDATE bdicred: "informix".sd_maeretenido
				SET monto = 0
				WHERE empresa = '001'
				AND num_credito = dNumCredito
				AND nvl(substr(referencia,1,16),'') = c_Folio_Suc
				AND nvl(substr(referencia,18,3),'')= 'RET'
				AND estatus = 'R';
			END IF;	

			UPDATE bdicred: "informix".sd_maeretenido
			SET monto = 0
			WHERE empresa = '001'
			AND num_credito = dNumCredito
			AND nvl(substr(referencia,1,16),'') = c_Folio_Suc
			AND nvl(substr(referencia,18,3),'')= 'PAG'
			AND estatus = 'R';	
		END IF;
	END IF;
	
	-- RQM 09 473: TRIAD INI
	EXECUTE PROCEDURE "informix".sp_graba_indicador_cnr(pEmpresa,pNumCredito,dMontoAux,g_Transacc,g_CodigoFun,1,dtFechaActual,pFolio,0,0,2)
	INTO cCodRet;
	
	--IF pProducto = '6800' and pTransaccion not in ('611','620') THEN  -- RQM 10 915-4 
	--AAME RQM 10 1177 Se valida la familia de Linea Credito a Plazo
	IF (cbanfamilia IN ('003') AND pProducto NOT IN('6400')) and pTransaccion not in ('611','620')  THEN	 -- RQM 10 915-4
		SELECT NVL(a.telefono,''), b.status_cred INTO vNumCel,vstcred								
		FROM bdinteg:si_telefonos a
		JOIN bdicred:sd_maecredcrd b on a.numcte = b.numcte
		WHERE a.tipo_tel = 2 AND a.verificado = 'V' AND a.status_tel = 'A' AND b.num_credito = pNumCredito; 
		
		SELECT COUNT (*)
			INTO banderaApoyo
		FROM bdicred:sd_diferir
		WHERE numcte = cNumCteCD
		AND canal_baja = 21;
		
		IF banderaApoyo = 0 THEN
			IF vNumCel <> '' OR vNumCel IS NOT NULL THEN
				LET vFecha = DAY(dtFechaActual) || '/' || MONTH(dtFechaActual) || '/' || YEAR(dtFechaActual);						
					IF vstcred = 'FF'  THEN
						----Envio de mensaje de Liquidacion del prestamo						 								 
						IF cEnvioSMSRespMultic = '1' THEN
							EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento ('2','CRED_SMS','PPF_SMS_FF','000000000','', '','1', vFecha, '', '', '', '', '', '', '', '', '', '',TRIM(vNumCel), vMontoPago, 0, 0, 0, 0, current, current) INTO cCodRetSP;						
						END IF;
					ELSE
						IF cEnvioSMSRespMultic = '1' THEN  
							EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento ('2','CRED_SMS','PPF_SMS_CAUT','000000000','', '','1', vFecha, '', '', '', '', '', '', '', '', '', '',TRIM(vNumCel), vMontoPago, 0, 0, 0, 0, current, current) INTO cCodRetSP;						
						END IF;
					END IF;
			END IF;
		END IF;
	END IF; 
	
	IF  (indicaQuitaCondona IN ('Q','C','O','U') AND  g_Transacc NOT IN ('8671','8701'))   THEN	
		
		SELECT 
		SUM(NVL(interes_debe,0) - NVL(interes_pagado,0)),
        SUM((mora_provi_ordi + mora_provi_cope + mora_sdo_ordi) - (mora_sdo_ordi_pag + mora_sdo_cope - mora_sdo_cope_pag)),
        NVL(SUM(interes_debe - interes_pagado),0),
		SUM(NVL(iva_debe,0) - NVL(iva_pagado,0))
		INTO vIntVencido,
			vIntMoratorio,
			vIvaIntVigente, 
			vIvaIntVencido
		FROM "informix".sd_amortiza_creditocrd WHERE empresa = '001' AND num_credito = pNumCredito;
		
		SELECT capital_mto_cuota INTO vCapitalMtoCuota
		FROM sd_amortiza_creditocrd WHERE num_credito = pNumCredito
		AND fecha_cuota = dtFechaActual;
		
		IF  indicaQuitaCondona IN ('Q','O','U') AND dSdoTotalLiq > 0 THEN
			
			LET gprocesa = 2;
			
			IF pProducto NOT IN ('6011','8600') THEN
				---- se manda a llamar el principal_suc_rr por el total a liquidar, con la nueva transaccion de PP
				execute procedure bdicred:sp_principal_suc_rr (pEmpresa,pNumCredito,pProducto,dSdoTotalLiq,0,pUsuario,pSucursal,pFolio,'8671')
					INTO cCodRet,cMensajeRet,pNumCredito,cCuenta_Eje,cNomProductoCD,cNumCteCD,cNomCteCD,dMontoOperacionEfecAux,
					dMontoOperacionCargCuentaAux,dMontoOperacion,dSdo_Actual,cDescStatusCred;
			ELSE 
				---- se manda a llamar el principal_suc_rr por el total a liquidar, con la nueva transaccion de Rees
				execute procedure bdicred:sp_principal_suc_rr (pEmpresa,pNumCredito,pProducto,dSdoTotalLiq,0,pUsuario,pSucursal,pFolio,'8701')
					INTO cCodRet,cMensajeRet,pNumCredito,cCuenta_Eje,cNomProductoCD,cNumCteCD,cNomCteCD,dMontoOperacionEfecAux,
					dMontoOperacionCargCuentaAux,dMontoOperacion,dSdo_Actual,cDescStatusCred;			
			END IF;
		END IF;
		----- Se omite la O Quita de operaciones ya que no requieren se cancele
		IF  pProducto = '6800' AND indicaQuitaCondona IN ('Q','U') THEN
			--Se genera movimiento de cancelacion de linea solo para Prestamo Digital, cuando el capital se salda con el pago y se debe cancelar el credito
			CALL "informix".genmovcrd(pEmpresa,pNumCredito, '6800', 2, '002', dtFechaActual,dLineaOtorgada,pFolio,pSucursal, '01', '7480', 'Cancelacion Linea Prestamo Digital' , '' ) 
			RETURNING cCodigoRetorno_P, cMensajeRetorno_P;

			UPDATE bdicred:"informix".sd_linea_prestamo SET fecha_cancela = dtFechaActual, cancel_pf = '1', fecha_ult_pf = vFechaVencCred WHERE num_credito = pNumCredito;
			
		END IF;
		
		--Se consulta el saldo capital insoluto y la fecha pago
		SELECT A.sdo_cap_insoluto,B.fecha_proceso,A.monto_otorgado,A.fecha_ult_mov
		INTO dSdoCapInsoluto, dFechapago, dMontoOtorgado,dFechaUltMov
		FROM bdicred:"informix".sd_maesdoscrd A
		INNER JOIN bdicred:"informix".sd_maecredanexocrd B ON B.num_credito = A.num_credito
		WHERE A.num_credito = pNumCredito
		AND A.empresa = pEmpresa;
		
		EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(pEmpresa,pNumCredito)
		INTO cCodRetSP,cMensajeSP,cNumCredito,cCodTipCred,dtFechaOrigen,dtFechaProxPago,dPagoMinimo,dtFechaUltPago,iPlazo,iPagosRealizados,dLineaOtorgada,dTasaInteres,
			dTasaMoratorios,dMontoSBC,dCapVig,dCapTrans,dCapVdoExig,dCapVdoNoExig,dSdoActCap,dIntVig,dIntVdo,dIntMoratorio,dIntMes,dSdoActInt,dIvaIntVig,dIvaIntVdo,dIvaIntMoratorio, dIvaIntMes,dSdoActIvaInt,
			dComPend,dIvaCom,dSdoRetenido,dSdoTotalLiq,dIntDevengado,dIvaIntDevengado,dLineaDisponible,dPagosVdos,cDescStatusCred,iIdUnidadProd,cDescBloqueoCta,cCodCaract2,cDescCausaBloqueoCta, cSitCte,
			iCausaCte,cDescSitEspCte,cSitCred,iCausaCred,cDescSitEspCred;
		IF cCodRetSP <> '000000' THEN
			LET cCodRet = cCodRetSP;
			LET cMensajeRet= cMensajeSP;
		END IF;
		
		LET vSdoCredito = dMontoOtorgado-dSdoCapInsoluto-dSdoRetenido;


		----------------------------------------------------------------------------
		UPDATE "informix".sd_bitacora_quitacondonacion 
			SET meses_historia = vMesesHistoria, sdo_credito = vSdoCredito, 
			fecha_pago = today, abono_mensual_al_quita = NVL(vCapitalMtoCuota,0),
			fecha_ult_mov = dFechaUltMov, fecha_liquidacion = today,
			fecha_status = today, estatus_proceso = 'FI',saldo_tot_liquidar = dSdoTotalLiq,
			copete_moratorio = NVL(dIntMoratorio,0) + NVL(dIvaIntMoratorio,0),
			int_moratorio = dIntMoratorio,
        ----------------------------------------------------------------------------
			cap_vigente_dq = NVL(dCapVig,0), 
			cap_vencido_dq = dCapVdoExig, 
			int_vigente_dq = dIntVig, 
			int_vencido_dq = dIntVdo,
			int_moratorio_dq = dIntMoratorio,		
			iva_int_vigente_dq = dIvaIntVig, 
			iva_int_vencido_dq = dIvaIntVdo,
			iva_int_mora_dq = dIvaIntMoratorio
			WHERE num_credito = pNumCredito and estatus_proceso='PR';
		----------------------------------------------------------------------------
		--COMMIT;
		LET gprocesa = 0;
	END IF;
	
	RETURN cCodRet,cMensajeRet,pNumCredito,cCuenta_Eje,cNomProductoCD,cNumCteCD,cNomCteCD,dMontoOperacionEfecAux,
	dMontoOperacionCargCuentaAux,dMontoOperacion,dSdo_Actual,cDescStatusCred;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento para realizar pagos normales y anticipados de prestamos a plazo, en efectivo, con cargo a cuenta o mixto',
'AUTOR: Mohamed Carreon, Jesus Aguilar ',
'FECHA: 22 de Junio 2011',
'BD: BDICRED',
'VERSION: 20110624.1808',
'DESCRIPCION: Se Modifica codigo de mensaje para cuando el credito ya este saldado.',
'AUTOR: Mohamed Carreon, Jesus Aguilar ',
'FECHA: 18 de Agosto 2011',
'BD: BDICRED',
'VERSION: 20110818.1808',
'DESCRIPCION: Se modifica metodo de calculo del IVA moratorio.',
'AUTOR: Diego Guerra Atienzo ',
'FECHA: 30 de Noviembre 2011',
'Folio: 1580',
'AUTOR : 95594213',
'FECHA : 29/01/2014',
'MODIFICACION: Se modifica sp_principal_suc_rr agregandole la ejecucion del sp_consulta_saldos_general para Retornar el status actual del credito ',
'SUSTENTO: RQM_09-338_Deposito_personal_cobranzav3.1.pdf',
'SOLICITA: Rodolfo Gomez',
'BD: bdicred',
'DESCRIPCION: Se Agregan las Transacciones 8150 y 8160 Para los Producto 6900 ',
'FECHA: 28/11/2015',
'Modifico: 92597688 - Yadira Morales Zazueta',
'----------------------------------------------------------------------------',
'Descripcion : Se modifica para filtrar dtFechaProxPago >= dtFechaActual ademasagregan las transacciones 8160 y 81150. ',
'Modifico    : 95451706 - Efrain Miranda',
'Fecha       : 17/03/2017',
'BD          : bdicred',
'-------------------------------------------------------------------------',
'Modifico: 95992243 - Trinidad Hernadez',
'Folio: 188',
'Modificacion: Se quitan movimientos a la sd_movdia',
'BD: bdicred',
'Fecha: 25/04/2017',
'-------------------------------------------------------------------------',
'Modifico: Cinthia Aguilar',
'Modificacion: se agrega la validacion para liberar saldo retenido para las credisoluciones',
'BD: bdicred',
'Fecha: Enero.2026';

CREATE PROCEDURE "informix".sp_genera_archivo_carteralinea_solo(pEmpresa char(3))

RETURNING  CHAR(6) AS Cod_Ret,  CHAR(80) AS Mens_Ret;

--Creado por: Abrham Lopez L. 05/08/2011. Proceso para la generacion del archivo de Cartera en Linea
-- Modificado por: MAHR Octubre 2011. Se agregan al proceso productos de colocacion ademas de la Tarjeta de Credito Prestamo Personal y Reestructura.
--      Servicios: 1.- Tarjeta de Credito, 2.- Prestamo Personal y Reestructura 3.- AMBOS.
-- Modificado por MAHR. Mayo 2012. Se crea sp sp_genera_carteraenlinea_tab, que genera los saldos de la cartera vencida y la almacena en la tabla:
--		sd_sdos_cartera_linea y desde dicha tabla se genera el archivo de Cartera en linea.


--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cEmpresa             CHAR(3);
DEFINE cCod_ret				CHAR(6);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivoAuxRPp    CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnomarchivoNvo		CHAR(100);
DEFINE cSQL                 CHAR(8204);
DEFINE cSQL1                CHAR(6204);
DEFINE cSQL2                CHAR(6204);
DEFINE cSQL3                CHAR(100);
DEFINE pFecha               DATE;
DEFINE vnomProceso			CHAR(20);
DEFINE cMensajeRet          CHAR(125);
--DEFINE credcontproc 	    char(1);
--DEFINE intecontproc 	    char(1);
DEFINE cProceso             CHAR(4);
DEFINE cCod_retBit          CHAR(6);

--SET DEBUG FILE TO "/ifxsif01/PEDRO/carteralinea/sp_cartera_total_ppyr_finmes.out";
--TRACE ON;	


--Inicializacion de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cEmpresa                = "";
LET cCod_Ret                = "000000";
LET cruta                   = "";
LET cnombre					= "";
LET cnomarchivo             = "";
LET cnomarchivoAuxRPp       = "";
LET cnomarchivo1			= "";
LET cnomarchivoNvo			= "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cMensajeRet				= 'PROCESO EXITOSO';
LET vnomProceso             = "";
--LET credcontproc            = "";
--LET intecontproc            = "";
LET cProceso                = '0203';
LET cCod_retBit             = '00000';


BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensajeRet = error_info;            
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') RETURNING cCod_retBit;       

        /*UPDATE bdicred:"informix".sd_contproc SET status_proc = "C",  hora_fin = CURRENT, cod_ret = cCod_ret, mensaje = "Cobranza en Linea Sin Generar"
            WHERE empresa = pEmpresa AND proceso = vnomProceso AND fecha   = pFecha; 
        UPDATE bdinteg:"informix".sx_contproc SET status_proc = "C", hora_fin = CURRENT, codret  = cCod_ret
            WHERE empresa = pEmpresa AND proceso   = vnomProceso  AND fecha   = pFecha; */
        RETURN cCod_ret,cMensajeRet;
    END EXCEPTION;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '01') RETURNING cCod_retBit;       
	
    --Directiva para lectura de tablas bloqueadas.
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;


    LET pfecha = date(1);

    -- Obtener la fecha del dia de ayer
    SELECT fecha_ant INTO pFecha
        FROM bdicred:"informix".sd_fechas WHERE empresa = pEmpresa;
		
	--LET pFecha= mdy('02','28','2022'); -- fecha de prueba 
		

    IF pFecha IS NULL THEN
        LET cCod_Ret=  '20013';
        SELECT descripcion INTO cMensajeRet
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 2 AND codigo_error = cCod_Ret;
        IF cMensajeRet IS NULL THEN
            LET cMensajeRet = "";
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') RETURNING cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
    END IF

    -- *******************************************************
    --  INSERTA BITACORA PARA EJECUCION DE PROCESO           *
    -- *******************************************************
    /* Se elimina la bitacora ya que cuando por error se ejecuta la cartera en linea despues del cambio de fecha, al dia posterior no permite
       la ejecucion del proceso por que indica que ya fue ejecuta, cuando no se ha ejecutado ese dia. Se agrega la bitacora en cobranza para su registro.

    SELECT status_proc INTO intecontproc FROM bdinteg:"informix".sx_contproc WHERE empresa = pEmpresa AND proceso = vnomProceso AND fecha = pfecha;
    IF (intecontproc = 'F') THEN
        LET cMensajeRet="YA EJECUTADO ANTERIORMENTE";
        RETURN cCod_Ret,cMensajeRet;
    END IF;
    SELECT status_proc INTO credcontproc FROM bdicred:"informix".sd_contproc WHERE empresa = pEmpresa  AND proceso = vnomProceso AND fecha = pFecha;
    IF (credcontproc = 'F') THEN
        LET cMensajeRet="YA EJECUTADO ANTERIORMENTE";
        RETURN cCod_Ret,cMensajeRet;
    END IF;

    IF (intecontproc IS NULL) THEN
        INSERT INTO bdinteg:"informix".sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret) 
            VALUES ('001',vnomProceso,pFecha,'06','I','informix',CURRENT,CURRENT,'000');
    END IF;
    IF (credcontproc IS NULL) THEN
        INSERT INTO bdicred:"informix".sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
            VALUES ('001',vnomProceso,pFecha,'I','informix',CURRENT,CURRENT,'000','Iniciamos');
    END IF;
    UPDATE bdinteg:"informix".sx_contproc SET status_proc = 'I' WHERE empresa = pEmpresa AND proceso = vnomProceso AND fecha = pFecha;
    UPDATE bdicred:"informix".sd_contproc SET status_proc = 'I', mensaje = 'Iniciamos' WHERE empresa = pEmpresa AND proceso = vnomProceso AND fecha = pFecha;
    */

    -- *******************************************************
    --  FIN BITACORA                                         *
    -- *******************************************************

	-- Validacion de parametros de entrada
    IF NVL(pEmpresa,"") = "" THEN
        LET cCod_Ret= '104001';
        SELECT descripcion INTO cMensajeRet
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3  AND codigo_error = cCod_Ret;
        IF cMensajeRet IS NULL THEN
            LET cMensajeRet = "";
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') RETURNING cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
	END IF;

	--Validacion de la empresa
    SELECT empresa INTO cEmpresa
        FROM bdinteg:"informix".si_empresas WHERE empresa = pEmpresa;
    IF NVL (cEmpresa, '') = '' OR cEmpresa IS NULL THEN
        LET cCod_Ret= '104002';
        SELECT descripcion INTO cMensajeRet
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensajeRet IS NULL THEN
            LET cMensajeRet = "";
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') RETURNING cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
    END IF;

	--Obtener ruta del archivo
    SELECT TRIM(valor_alfabetico) INTO cruta
        FROM bdicobranza:"informix".cb_param_campania
        WHERE empresa = pEmpresa
            AND tipo_campania = 1
            AND grupo_parametro = 'ARCHIVOS'
            AND num_parametro = 34;  
            
                --Valida que exista la carpeta
    IF NVL (cruta,'') = '' THEN
        LET cCod_Ret= '104005';
        SELECT descripcion INTO cMensajeRet
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3
                AND codigo_error = cCod_Ret;

        IF cMensajeRet IS NULL THEN
            LET cMensajeRet = "";
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') RETURNING cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
    END IF;

	--let cruta = '/ifxsif01/PEDRO/carteralinea/'; -- Ruta de pruebas

    --Obtener el nombre del archivo
	SELECT TRIM(valor_alfabetico) INTO cnombre
        FROM bdicobranza:"informix".cb_param_campania
        WHERE empresa = pEmpresa
            AND tipo_campania = 1
            AND grupo_parametro = 'ARCHIVOS'
            AND num_parametro = 35;
    IF NVL (cnombre,'') = '' THEN
        SELECT descripcion INTO cMensajeRet
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3 AND codigo_error = '104006';
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') RETURNING cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
    END IF;


                        --Validar que existe el archivo
    LET cnomarchivo		=  trim(cnombre)||'Aux'||to_char(pFecha,'%d%m%Y')||'.txt';
    LET cnomarchivo1	=  trim(cnombre)||to_char(pFecha,'%d%m%Y')||'.txt';
	LET cnomarchivoNvo	=  trim(cnombre)||to_char(pFecha,'%d%m%Y')||'_nuevo'||'.txt';

        --              Obtiene la consulta de la Cartera de Tarjeta de Credito                                     -
        --------------------------------------------------------------------------------------------------------------
        -- Cliente |Credito | Tarjeta | Int Moratorio | Sdo Tot Liquidacion | Sdo Vencido Tot | Mens Actual |       - 
        -- No Vencidos | Status Cred | Fech Ult Pago | Pago 1 Mora | Tipo Prod | Cuenta Eje( N/A TDC) |             -

   -- IF pServicio = '1' OR pServicio = '3' THEN

        LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo); 

        LET cSQL2 = " SELECT numcte, num_credito, num_tarjeta, moratorio, " 
            || " (sdo_capital +  monto_vencido + mto_venc_trasp + cap_tras_no_venci + moratorio + interes_iva ) sdo_tot_liquid, "
            || " (monto_vencido + mto_venc_trasp + moratorio + interes_iva) sdo_venc_tot, mensualidad_actual, "
            || " mto_fin_ven_trasp::INTEGER no_vencidos, dias_vencido,atr, act, to_char( fecha_vencido,'%d/%m/%Y') fecha_vencido, fecha_ult_dispo, status_cred, fecha_ult_pago, pago_una_mora, num_producto, num_cta cuenta_eje, "
			|| " to_char(fecha_apertura,'%d/%m/%Y') fecha_apertura, antiguedad, monto_otorgado, mto_fin_ven_trasp::INTEGER vencidos_ant, novencidos1, novencidos2, novencidos3, novencidos4, "
			|| " novencidos5, novencidos6, bcscore::INTEGER bc_score, scoreprop::INTEGER score_prop, ficoscore::INTEGER fico_score, bhscore::INTEGER bhscore, "
			|| " grupo, sucursal, SUBSTR(lpad(nvl(trim(celular),''),13,'0'),-10),ejecutivo "
            || " FROM bdicred:sd_sdos_cartera_linea "
            || " WHERE num_producto IN ('6001','8100','8500') "; 

        LET cSQL3 = '">'||TRIM(cRuta)||'Ejecuta_GenArchCARTERAlinea.sql';

        LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
        SYSTEM cSQL;

        LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejecuta_GenArchCARTERAlinea.sql';
        SYSTEM cSQL;

        LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || 'Ejecuta_GenArchCARTERAlinea.sql';
        SYSTEM cSQL;

        LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || cnomarchivo || " >> " || TRIM(cRuta) || cnomarchivoNvo; --cnomarchivo1;
        SYSTEM cSql;

        --Borra el archivo de control.
        LET cSQL = '' ;
        LET cSQL = 'rm ' || TRIM(cruta) || 'Ejecuta_GenArchCARTERAlinea.sql';
        SYSTEM cSQL;

        LET cSQL = '' ;
        LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo;
        SYSTEM cSQL;

   -- END IF;

	  -- ADLM: SE AGREGA ARCHIVO CON CAMPOS NUEVOS SOLICITADOS EN EL RQM 09 463
		LET cSQL = "cut -f 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18 -d '|' " || TRIM(cruta) || trim(cnomarchivoNvo) || ' >' || TRIM(cruta) || trim(cnomarchivo1);
		System cSQL;                                          --Nota se quito el parametro de la fecha de apertura 
	
		LET cSQL='chmod 777 '|| TRIM(cRuta) || cnomarchivoNvo;
		LET cSQL='chmod 777 '|| TRIM(cRuta) || cnomarchivo1;
		System cSQL;
		
	
    --IF pServicio = '2' OR pServicio = '3' THEN
            
        LET cnomarchivoAuxRPp =  trim(cnombre)||'R_PP_Aux'||to_char(pFecha,'%d%m%Y')||'.txt';
        -- cnomarchivo1 Contiene la consulta de Tarjeta de Credito...

        LET cSQL  = ""; 
        LET cSQL1 = "";
        LET cSQL2 = "";
        LET cSQL3 = "";

        --              Obtiene la consulta de la Cartera de Reestructura y Prestamo Personal                       -
        -- -------------------------------------------------------------------------------------------------------- -
        -- Cliente |Credito | Tarjeta | Int Moratorio | Sdo Tot Liquidacion | Sdo Vencido Tot | Mens Actual |       -
        -- No Vencidos | Status Cred | Fech Ult Pago | Pago 1 Mora | Tipo Prod | Cuenta Eje( N/A TDC) |             -

        LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivoAuxRPp); 
        --AAME RQM 10 393 20150624 Se solicita contemplar los dos nuevos productos de prestamo personal (7600,7700)
        LET cSQL2 = " SELECT numcte, num_credito, num_tarjeta, moratorio, "
            || " (sdo_cap_insoluto + sdo_intereses + interes_iva + moratorio + sdo_retenido ) sdo_tot_liquid, "
            || " (monto_vencido + mto_venc_trasp + interes_iva + moratorio - iva_int_trasp) sdo_venc_tot, mensualidad_actual, " 
            || " mto_fin_ven_trasp::INTEGER no_vencidos, dias_vencido,atr, act, to_char( fecha_vencido,'%d/%m/%Y') fecha_vencido, fecha_ult_dispo, status_cred, fecha_ult_pago, pago_una_mora, num_producto, num_cta cuenta_eje, "
			|| " to_char(fecha_apertura,'%d/%m/%Y') fecha_apertura, antiguedad, monto_otorgado, mto_fin_ven_trasp::INTEGER vencidos_ant, novencidos1, novencidos2, novencidos3, novencidos4, "
			|| " novencidos5, novencidos6, bcscore::INTEGER bc_score, scoreprop::INTEGER score_prop, ficoscore::INTEGER fico_score, bhscore::INTEGER bhscore, "
			|| " grupo, sucursal, SUBSTR(lpad(nvl(trim(celular),''),13,'0'),-10), ejecutivo "
            || " from bdicred:sd_sdos_cartera_linea "
            || " WHERE num_producto IN ('6011','6300','6400','6800','7600','7700') ";
            
        LET cSQL3 = '">'||TRIM(cRuta)||'Ejec_GenCARTLinea_Reest_PP.sql';

        LET cSQL = trim(cSQL1) ||cSQL2 || trim(cSQL3);
        SYSTEM cSQL;

        LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejec_GenCARTLinea_Reest_PP.sql';
        SYSTEM cSQL;

        LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || 'Ejec_GenCARTLinea_Reest_PP.sql';
        SYSTEM cSQL;

        LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || cnomarchivoAuxRPp || " >> " || TRIM(cRuta) || cnomarchivoNvo;		SYSTEM cSql;

        --Borra el archivo de control.
    	LET cSQL = '' ;
        LET cSQL = 'rm ' || TRIM(cruta) || 'Ejec_GenCARTLinea_Reest_PP.sql';
        SYSTEM cSQL;

        LET cSQL = '' ;
    	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivoAuxRPp;
        SYSTEM cSQL;

   -- END IF;          
   
   -- ADLM: SE AGREGA ARCHIVO CON CAMPOS NUEVOS SOLICITADOS EN EL RQM 09 463
	LET cSQL = "cut -f 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18 -d '|' " || TRIM(cruta) || trim(cnomarchivoNvo) || ' >' || TRIM(cruta) || trim(cnomarchivo1);
    System cSQL;												--Nota se quito el parametro de la fecha de apertura 
	
	LET cSQL='chmod 777 '|| TRIM(cRuta) || cnomarchivoNvo;
	LET cSQL='chmod 777 '|| TRIM(cRuta) || cnomarchivo1;
    System cSQL;
	
	
    --                  Fin consultas | & | Concluye datos en bitacora                                          -
  
    LET cCod_Ret = "00000";
    LET cMensajeRet = "PROCESO CONCLUIDO";

    /*UPDATE bdicred:"informix".sd_contproc SET status_proc = 'F', hora_fin = CURRENT, cod_ret = cCod_ret, mensaje = cMensajeRet
     WHERE empresa = pEmpresa AND proceso = vnomProceso AND fecha = pFecha;
    UPDATE bdinteg:"informix".sx_contproc SET status_proc = 'F', hora_fin = CURRENT, codret = cCod_ret
     WHERE empresa = pEmpresa AND proceso = vnomProceso AND fecha  = pFecha; */

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '03') RETURNING cCod_retBit;
    RETURN cCod_ret,cMensajeRet;

END;

END PROCEDURE;
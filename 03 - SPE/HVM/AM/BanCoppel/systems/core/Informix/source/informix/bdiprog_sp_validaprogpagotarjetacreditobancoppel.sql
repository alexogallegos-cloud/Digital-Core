CREATE PROCEDURE "informix".sp_validaprogpagotarjetacreditobancoppel(p_sCve_PagoProg CHAR(10),p_sNum_Cte CHAR(20),
				p_sDescripcion CHAR(20),p_sCvePago CHAR(2),p_sCve_Cuenta_Ori CHAR(2),p_sCuentaOrigen CHAR(20),p_sCve_Cuenta_Dest CHAR(2),
				p_sCuentaDestino CHAR(20),p_sBancoDestino CHAR (3),p_sReferencia1 CHAR(40),p_sReferencia2 CHAR(20),p_sConvenio CHAR(5),
				p_mImporte MONEY(16,2),p_sRefCobranza CHAR(40),p_mImporteIva MONEY(16,2),p_iTipoSpei INTEGER,p_sConcepto CHAR(60),
				p_dFechaInicio DATE,p_sCveFinal CHAR(2),p_iNumRepeticiones INTEGER,p_dFechaFin DATE,p_sCvePrograma CHAR(2),p_sTipoDiaria CHAR(2),
				p_iCadaXdias INTEGER,p_iCadaXsemanas INTEGER,p_sDiasSemana CHAR(7),p_sTipoMensual CHAR(2),p_iDiaXdelMes INTEGER,
				p_iCadaXmeses INTEGER,p_sCveOcurre CHAR(2),p_sCveDia CHAR(2),p_sCveCanal CHAR(2),p_sCveNotifica CHAR(2),p_sBenEmail CHAR(100),
				p_sBenCveCompania CHAR(2),p_sBenCelular CHAR(10),p_sCveNotificaEmi CHAR(2),p_sEmiEmail CHAR(100),p_sEmiCveCompania CHAR(2),
				p_sEmiCelular CHAR(10),p_sMensaje CHAR(100),p_sCveEstado CHAR(2),p_sUserInsert CHAR(8),p_dFechaInsert DATE,p_sUserCancela CHAR(8),
				p_dFechaCancela DATE,p_sCanalCancela CHAR(2), p_dFechaMax DATE)
	RETURNING CHAR(5), CHAR(80);

--Declaracion de variables
DEFINE SQL_ERROR INTEGER;
DEFINE v_sValorBancoppel CHAR(3);
DEFINE v_sNumCredito CHAR(20);
DEFINE v_iCve_PagoProg INTEGER;
DEFINE v_sCodigo CHAR(10);
DEFINE v_iMaxConcecutivo INTEGER;
DEFINE v_iMaxConcecutivo2 INTEGER;
DEFINE v_sCodRet CHAR(5);
DEFINE v_sMensajeRet CHAR(80);
DEFINE vc_ciclo_fec CHAR(1);
DEFINE vdFechaProgramada DATE;
DEFINE v_sCodSpFecha CHAR(5);
DEFINE vcNumAplica INTEGER;
DEFINE viPasoPrimerMes CHAR(1);
DEFINE vdFechaMovil DATE;
DEFINE vcCodFechas CHAR(5);
DEFINE vdFechaValida DATE;
DEFINE vdFechaDisponible DATE;
DEFINE viDiaMes INTEGER;
DEFINE vdFechaMovil2 DATE;
DEFINE vdFechaMaximaPermitida DATE;
DEFINE vtransaccion INTEGER;
DEFINE vdFechaProx DATE;
DEFINE  iDia INTEGER;
DEFINE  iMes INTEGER;

-- *************************************************
-- Realizo: Marcos Cuevas                        --*
-- Actividad: Validar el pago de la tarjeta de credito bancoppel             --*
-- Solicito:Aymme Osuna                          --*
--Fecha: 11/NOV/2008                             --*
-- Modifico: Marcos Cuevas
-- Fecha: Enero 2009
-- Razon: Se  incluyo el pago a tarjeta de credito propia
-- *************************************************
--* Modifico: JosÃÂ© de JesÃÂºs Nevarez.              *
--* Fecha: 22/Septiembre/2010                     *
--* ModificaciÃÂ³n: Se agrega pago mensual de TDCB. *
--*****************************************************
--* Modifico: FRG.                                    *
--* Fecha: 2012.05.04                                 *
--* ModificaciÃÂ³n: Se elimina la validaciÃÂ³n de feriado *
--*		porque pago de TDC BCP aplica todos los dÃÂ­as. *
--*****************************************************

	--	SET DEBUG FILE TO "/informix/frg/sp_validaprogpagotarjetacreditobancoppel.out";
	--	TRACE ON;

LET SQL_ERROR = 0;
LET v_sValorBancoppel = '';
LET v_sNumCredito = '';
LET v_iCve_PagoProg = 0;
LET v_iMaxConcecutivo = 0;
LET v_sCodigo = '';
LET v_iMaxConcecutivo2 = 0;
LET v_sCodRet = '';
LET v_sMensajeRet = '';
LET v_sCodSpFecha='';
LET vcNumAplica = 0;
LET viPasoPrimerMes = 'N';
LET vcCodFechas = '';
LET viDiaMes   = -1;
LET vtransaccion = 0;
LET vdFechaValida='';
LET vc_ciclo_fec = 'N';
LET vdFechaMaximaPermitida= p_dFechaMax;
LET vdFechaProgramada = '';
LET vdFechaDisponible='';
LET vdFechaProx = '';
LET vdFechaMovil ='';
LET vdFechaMovil2 ='';
LET iDia = 0;
LET iMes = 0;

BEGIN
	ON EXCEPTION SET SQL_ERROR
		LET v_sCodRet= SQL_ERROR;
		IF vtransaccion = 1 THEN ROLLBACK WORK; BEGIN WORK; ELSE ROLLBACK WORK; END IF
		RETURN v_sCodRet,'';
	END EXCEPTION;

	ON EXCEPTION IN (-271)
	IF vtransaccion = 1 THEN ROLLBACK WORK; BEGIN WORK; ELSE ROLLBACK WORK; END IF
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '230';
		RETURN v_sCodRet, v_sMensajeRet;
	END EXCEPTION;

	ON EXCEPTION IN (-535)
		LET vtransaccion = 1;
	END EXCEPTION with RESUME;

	IF vtransaccion = 1 THEN
		COMMIT WORK;
		BEGIN WORK;
	ELSE
		BEGIN WORK;
	END IF;

	--Se valida que la clave de pago exista

	IF NOT EXISTS(SELECT cve_pago FROM bdiprog:pp_tppago WHERE cve_pago = p_sCvePago AND cve_pago = '05') THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '24';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;



	--Se valida que la clave de cuenta destino  exista

	IF NOT EXISTS(SELECT cve_cuenta FROM bdiprog:pp_tpcuenta WHERE cve_cuenta = p_sCve_Cuenta_Dest AND cve_cuenta = '04') THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '93';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;

	--Se toma el valor del bancoppel

	SELECT valor INTO v_sValorBancoppel FROM bdiprog:pp_parametros WHERE cve_param = '01';

	IF (NVL(v_sValorBancoppel,'') = '')THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '137';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;

	--Se valida que la clave de banco sea igual ala de bancoppel

	IF p_sBancoDestino <> v_sValorBancoppel THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '74';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;

	--Se obtiene el numero de credito

	SELECT num_credito INTO v_sNumCredito FROM bdicred:sd_tarjeta WHERE num_tarjeta = p_sCuentaDestino;
	IF NOT EXISTS(SELECT DISTINCT status_tar  FROM bdicred:sd_tarjeta WHERE num_tarjeta = p_sCuentaDestino and status_tar <> 'C' ) THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '17';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;

	--Se valida que exista el numero de credito

	IF NOT EXISTS (SELECT DISTINCT num_credito FROM bdicred:sd_maecred WHERE num_credito = v_sNumCredito AND status_cred <> 'CV') THEN

		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '227';
		RETURN v_sCodRet, v_sMensajeRet;

	END IF;

	--Se valida que exista la cuenta destino y que sea de un tercero

	IF EXISTS(SELECT num_credito,numcte FROM bdicred:sd_maecred WHERE num_credito = v_sNumCredito AND numcte <> p_sNum_Cte) THEN
		--Se valida que exista la cuenta destino exista dentro del catalago de terceros

		IF NOT EXISTS(SELECT cuenta,num_cte FROM bdiprog:pp_ctasterceros WHERE cuenta = p_sCuentaDestino) THEN
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '71';
			RETURN v_sCodRet, v_sMensajeRet;
		END IF;

		IF NOT EXISTS(SELECT cuenta,num_cte FROM bdiprog:pp_ctasterceros WHERE cuenta = p_sCuentaDestino AND  cve_banco = p_sBancoDestino) THEN
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '204';
			RETURN v_sCodRet, v_sMensajeRet;
		END IF;

		IF EXISTS(SELECT cuenta,num_cte FROM bdiprog:pp_ctasterceros WHERE cuenta = p_sCuentaDestino AND cve_estado = '02') THEN
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '146';
			RETURN v_sCodRet, v_sMensajeRet;
		END IF;

	END IF;


	--Se genera la clave de pago programado

	LET v_iCve_PagoProg = LENGTH(p_sCve_PagoProg);

	IF (v_iCve_PagoProg <> 10) THEN
		LET p_sCve_PagoProg = '';
	END IF;

	IF (NVL(p_sReferencia1,'') = '') THEN
		LET p_sReferencia1 = '';
	END IF;

	IF (NVL(p_sReferencia2,'') = '') THEN
		LET p_sReferencia2 = '';
	END IF;

	IF (NVL(p_sCve_PagoProg,'') = '') THEN

		IF EXISTS(SELECT num_cte FROM bdiprog:pp_pagoprog WHERE cve_pagoprog LIKE '05%') THEN
            SELECT MAX(cve_pagoprog) INTO v_iMaxConcecutivo2 FROM bdiprog:pp_pagoprog  WHERE cve_pagoprog LIKE '05%';
            LET v_iMaxConcecutivo2 = v_iMaxConcecutivo2 + 1;
			LET v_sCodigo  = '0' || v_iMaxConcecutivo2;
            LET p_sCve_PagoProg = v_sCodigo;
		ELSE
			LET v_sCodigo = '0500000001';
			LET p_sCve_PagoProg = v_sCodigo;
		END IF;
	END IF;

	--SE INSERTA LA PROGRAMACION EN ACTIVO.
	IF p_sCvePrograma='04' THEN---PAGO UNICO

	--IF NOT EXISTS(SELECT cve_pagoprog FROM bdiprog:pp_pagoprog WHERE cve_pagoprog = p_sCve_PagoProg) THEN

		INSERT INTO bdiprog:pp_pagoprog(cve_pagoprog,num_cte,descripcion,cve_pago,cve_cuenta_ori,cuenta_origen,cve_cuenta_dest,cuenta_destino,
				banco_destino,referencia1,referencia2,convenio,importe,ref_cobranza,importe_iva,tipo_spei,concepto,fecha_inicio,cve_final,
				no_repeticiones,fecha_fin,cve_programa,tipo_diaria,cada_x_dias,cada_x_semanas,dias_semana,tipo_mensual,dia_x_del_mes,cada_x_meses,
				cve_ocurre,cve_dia,cve_canal,cve_notifica,ben_email,ben_cve_compania,ben_celular,cve_notifica_emi,emi_email,emi_cve_compania,
				emi_celular,mensaje,cve_estado,user_insert,fecha_insert,user_cancela,fecha_cancela,canal_cancela)
		VALUES (p_sCve_PagoProg,p_sNum_Cte,p_sDescripcion,p_sCvePago,p_sCve_Cuenta_Ori,p_sCuentaOrigen,p_sCve_Cuenta_Dest,p_sCuentaDestino,
			p_sBancoDestino,p_sReferencia1,p_sReferencia2,'',p_mImporte,'',0,p_iTipoSpei,p_sConcepto,p_dFechaInicio,'02',0,p_dFechaFin,p_sCvePrograma,'00',0,0,'',
			'00',0,0,'00','00',p_sCveCanal,p_sCveNotifica,p_sBenEmail,p_sBenCveCompania,p_sBenCelular,p_sCveNotificaEmi,p_sEmiEmail,
			p_sEmiCveCompania,p_sEmiCelular,p_sMensaje,'01',p_sUserInsert,CURRENT::DATE,'','','');
		--Valida que fecha de pago programada sea fecha habil.
		LET vdFechaMovil = p_dFechaInicio;
		SET LOCK MODE TO WAIT 10;
--	2012.05.04 -frg-I
		--WHILE (vc_ciclo_fec = 'N')
			--EXECUTE FUNCTION bdinteg:splvalfecha('001', vdFechaMovil, 0 ) INTO v_sCodSpFecha,vdFechaDisponible;
			--SELECT fecha_prox INTO vdFechaProx FROM bdinteg:si_feriado_banca WHERE empresa = '001' AND fecha = vdFechaDisponible;
			--IF (vdFechaProx IS NULL) OR (vdFechaProx = "") THEN
				--LET ps k  = vdFechaDisponible;
				--LET vc_ciclo_fec = 'S';
			--ELSE
				--LET vdFechaMovil = vdFechaProx;
			--END IF;
		--END WHILE;
		LET vdFechaProgramada = p_dFechaInicio;
--	2012.05.04 -frg-F
	SELECT MAX(consecutivo) INTO v_iMaxConcecutivo FROM bdiprog:pp_pagospend WHERE cve_pagoprog = p_sCve_PagoProg AND estado = '03';

	IF (NVL(v_iMaxConcecutivo,0) = 0) THEN
		LET v_iMaxConcecutivo = 0;
	END IF;
	LET v_iMaxConcecutivo = v_iMaxConcecutivo + 1;
	INSERT INTO bdiprog:pp_pagospend(cve_pagoprog,consecutivo,fecha_prog,estado,fecha_aplic,folio_suc,user_insert,fecha_insert,user_cancela,
				fecha_cancela,canal_cancela,cve_rechazo)
		VALUES(p_sCve_PagoProg,v_iMaxConcecutivo,vdFechaProgramada,'03','','',p_sUserInsert,p_dFechaInsert,'','','','00');

		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '00';
		RETURN v_sCodRet, v_sMensajeRet;

	ELIF p_sCvePrograma='03' THEN--- PAGO MENSUAL
			SET LOCK MODE TO WAIT 10;
			INSERT INTO bdiprog:pp_pagoprog(cve_pagoprog,num_cte,descripcion,cve_pago,cve_cuenta_ori,cuenta_origen,cve_cuenta_dest,cuenta_destino,
				banco_destino,referencia1,referencia2,convenio,importe,ref_cobranza,importe_iva,tipo_spei,concepto,fecha_inicio,cve_final,
				no_repeticiones,fecha_fin,cve_programa,tipo_diaria,cada_x_dias,cada_x_semanas,dias_semana,tipo_mensual,dia_x_del_mes,cada_x_meses,
				cve_ocurre,cve_dia,cve_canal,cve_notifica,ben_email,ben_cve_compania,ben_celular,cve_notifica_emi,emi_email,emi_cve_compania,
				emi_celular,mensaje,cve_estado,user_insert,fecha_insert,user_cancela,fecha_cancela,canal_cancela)
			VALUES (p_sCve_PagoProg,p_sNum_Cte,p_sDescripcion,p_sCvePago,p_sCve_Cuenta_Ori,p_sCuentaOrigen,p_sCve_Cuenta_Dest,p_sCuentaDestino,
				p_sBancoDestino,p_sReferencia1,p_sReferencia2,'',p_mImporte,'',0,p_iTipoSpei,p_sConcepto,p_dFechaInicio,p_sCveFinal,p_iNumRepeticiones,p_dFechaFin,p_sCvePrograma,
				'00',0,0,'',p_sTipoMensual,p_iDiaXdelMes,p_iCadaXmeses,p_sCveOcurre, p_sCveDia,p_sCveCanal,p_sCveNotifica,p_sBenEmail,p_sBenCveCompania,p_sBenCelular,p_sCveNotificaEmi,
				p_sEmiEmail,p_sEmiCveCompania,p_sEmiCelular,p_sMensaje,'01',p_sUserInsert,CURRENT::DATE,'','','');

		IF p_sCveFinal='01' THEN ---PROGRAMACION POR REPETICIONES

			LET vdFechaMovil = p_dFechaInicio;
			--LET viDiaMes   = DAY(vdFechaMovil);

			WHILE vcNumAplica < p_iNumRepeticiones
				IF viPasoPrimerMes = 'S' THEN
					LET vdFechaMovil = MONTH (vdFechaMovil) || '/01/' || YEAR(vdFechaMovil);
				END IF;

				IF p_sTipoMensual='01' THEN --MENSUAL POR DIA ESPECIFICO
					EXECUTE FUNCTION bdiprog:sp_obtenerFechaValida(YEAR(vdFechaMovil),MONTH(vdFechaMovil),p_iDiaXdelMes) INTO vcCodFechas,vdFechaValida;
				ELIF p_sTipoMensual='02' THEN --MENSUAL POR DIA X
					EXECUTE FUNCTION bdiprog:sp_obtenerOcurrenciaDia(p_sCveOcurre,p_sCveDia,vdFechaMovil) INTO vcCodFechas,vdFechaValida;
				END IF;
				
				LET vdFechaProgramada = vdFechaValida;
--	2012.05.04 -frg-I
				--WHILE (vc_ciclo_fec = 'N')
					--EXECUTE FUNCTION bdinteg:splvalfecha('001', vdFechaValida, 0 ) INTO v_sCodSpFecha,vdFechaDisponible;
					--SELECT fecha_prox INTO vdFechaProx FROM bdinteg:si_feriado_banca WHERE empresa = '001' AND fecha = vdFechaDisponible;
					--IF (vdFechaProx IS NULL) OR (vdFechaProx = "") THEN
						--LET vdFechaProgramada = vdFechaDisponible;
						--LET vc_ciclo_fec = 'S';
					--ELSE
						--LET vdFechaValida = vdFechaProx;
					--END IF;
				--END WHILE;
				--LET vc_ciclo_fec = 'N';
				IF vdFechaProgramada >= vdFechaMovil THEN
					IF vcCodFechas = '00000' THEN
						LET vcNumAplica = vcNumAplica + 1;						
-- 2012.05.04 -frg-i Se elimina la validaciÃÂ³n de fecha dado que el pago de TDC Bancoppel aplica todos los dÃÂ­as (excepto 01/Ene y 25/dic que no opera el banco).
						--LET vdFechaProgramada = vdFechaValida;						yuri
						LET iDia = DAY(vdFechaValida);
						LET iMes = MONTH (vdFechaValida);
						IF (iDia=25 AND iMes=12) OR (iDia=1 AND iMes=1) THEN
							LET vdFechaProgramada = vdFechaValida + 1;
						ELSE 
							LET vdFechaProgramada = vdFechaValida;
						END IF;
						
						SET LOCK MODE TO WAIT 10;
						INSERT INTO bdiprog:pp_pagospend(cve_pagoprog, consecutivo, fecha_prog, estado, fecha_aplic, folio_suc, user_insert, fecha_insert, user_cancela, fecha_cancela, canal_cancela, cve_rechazo)
						VALUES(p_sCve_PagoProg, vcNumAplica, vdFechaProgramada, '03', '', '',p_sUserInsert , CURRENT::DATE, '', '', '', '00');
					END IF;
				END IF;
-- 2012.05.04 -frg-f
				LET viPasoPrimerMes = 'S';
				LET viDiaMes = DAY(vdFechaValida);

				IF p_iNumRepeticiones <> vcNumAplica THEN
					IF viDiaMes > 28 THEN
						LET vdFechaMovil2 = MONTH (vdFechaMovil) || '/01/' || YEAR(vdFechaMovil);
						LET vdFechaMovil  = vdFechaMovil2 + p_iCadaXmeses UNITS MONTH;
						EXECUTE FUNCTION bdiprog:sp_obtenerFechaValida(YEAR(vdFechaMovil), MONTH (vdFechaMovil) ,viDiaMes) INTO vcCodFechas,vdFechaValida;
						IF vcCodFechas = '00000' THEN
							IF DAY(vdFechaValida) = 1 THEN
								LET vdFechaMovil = vdFechaValida -1 UNITS MONTH;
							ELSE
								LET vdFechaMovil = vdFechaValida;
							END IF;
						END IF;
					ELSE
						IF p_sTipoMensual= '01' THEN
							LET vdFechaMovil  = vdFechaMovil + p_iCadaXmeses UNITS MONTH;
						ELIF p_sTipoMensual='02' THEN
							LET vdFechaMovil =  vdFechaValida + p_iCadaXmeses UNITS MONTH;
						END IF;
					END IF;
				END IF;
			END WHILE;

			IF vdFechaProgramada > vdFechaMaximaPermitida THEN
				--IF vtransaccion = 1 THEN   ROLLBACK WORK;  BEGIN WORK;  ELSE ROLLBACK WORK;	END IF
				DELETE pp_pagospend WHERE cve_pagoprog = p_sCve_PagoProg AND user_insert = p_sUserInsert;
				DELETE pp_pagoprog WHERE cve_pago= p_sCvePago AND cve_pagoprog= p_sCve_PagoProg AND user_insert = p_sUserInsert;
				SELECT cod_ret, desc_mensaje INTO v_sCodRet,v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '66';
				RETURN v_sCodRet,v_sMensajeRet;
			END IF;

			IF vcNumAplica = 0 THEN
				--IF vtransaccion = 1 THEN   ROLLBACK WORK;  BEGIN WORK;  ELSE ROLLBACK WORK;	END IF
				DELETE pp_pagospend WHERE cve_pagoprog = p_sCve_PagoProg AND user_insert = p_sUserInsert;
				DELETE pp_pagoprog WHERE cve_pago= p_sCvePago AND cve_pagoprog= p_sCve_PagoProg AND user_insert = p_sUserInsert;
				SELECT cod_ret, desc_mensaje INTO v_sCodRet,v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '65';
				RETURN v_sCodRet,v_sMensajeRet;
			END IF;

		ELIF p_sCveFinal='02' THEN -- PROGRAMACION POR FECHA.

			LET vdFechaMovil = p_dFechaInicio;

			WHILE vdFechaMovil <= p_dFechaFin
				IF viPasoPrimerMes = 'S' THEN
					LET vdFechaMovil = MONTH (vdFechaMovil) || '/01/' || YEAR(vdFechaMovil);
				END IF;

				IF p_sTipoMensual='01' THEN --MENSUAL POR DIA ESPECIFICO
					EXECUTE FUNCTION bdiprog:sp_obtenerFechaValida(YEAR(vdFechaMovil),MONTH(vdFechaMovil),p_iDiaXdelMes) INTO vcCodFechas,vdFechaValida;
				ELIF p_sTipoMensual='02' THEN --MENSUAL POR DIA X
					EXECUTE FUNCTION bdiprog:sp_obtenerOcurrenciaDia(p_sCveOcurre,p_sCveDia,vdFechaMovil) INTO vcCodFechas,vdFechaValida;
				END IF;
-- 2012.05.04 -i
				--WHILE (vc_ciclo_fec = 'N')
					--EXECUTE FUNCTION bdinteg:splvalfecha('001', vdFechaValida, 0 ) INTO v_sCodSpFecha,vdFechaDisponible;
					--SELECT fecha_prox INTO vdFechaProx FROM bdinteg:si_feriado_banca WHERE empresa = '001' AND fecha = vdFechaDisponible;
					--IF (vdFechaProx IS NULL) OR (vdFechaProx = "") THEN
						--LET vdFechaProgramada = vdFechaDisponible;
						--LET vc_ciclo_fec = 'S';
					--ELSE
						--LET vdFechaValida = vdFechaProx;
					--END IF;
				--END WHILE;
				--LET vdFechaProgramada = vdFechaValida;
-- 2012.05.04 -f
				LET vc_ciclo_fec = 'N';
				LET viDiaMes   = DAY(vdFechaValida);

				IF vdFechaValida >= vdFechaMovil AND vdFechaValida <= p_dFechaFin THEN
					IF vcCodFechas = '00000' THEN
						LET vcNumAplica = vcNumAplica + 1;
						LET iDia = DAY(vdFechaValida);
						LET iMes = MONTH (vdFechaValida);
						IF (iDia=25 AND iMes=12) OR (iDia=1 AND iMes=1) THEN
							LET vdFechaProgramada = vdFechaValida + 1;
						ELSE 
							LET vdFechaProgramada = vdFechaValida;
						END IF;
						
						SET LOCK MODE TO WAIT 10;
						INSERT INTO bdiprog:pp_pagospend(cve_pagoprog, consecutivo, fecha_prog, estado, fecha_aplic, folio_suc, user_insert, fecha_insert, user_cancela, fecha_cancela, canal_cancela, cve_rechazo)
						VALUES(p_sCve_PagoProg, vcNumAplica, vdFechaProgramada, '03', '', '',p_sUserInsert , CURRENT::DATE, '', '', '', '00');
					END IF;
				END IF;

				LET viPasoPrimerMes = 'S';
				LET viDiaMes = DAY(vdFechaValida);

				IF viDiaMes > 28 THEN
					LET vdFechaMovil2 = MONTH (vdFechaMovil) || '/01/' || YEAR(vdFechaMovil);
					LET vdFechaMovil  = vdFechaMovil2 + p_iCadaXmeses UNITS MONTH;
					EXECUTE FUNCTION bdiprog:sp_obtenerFechaValida(YEAR(vdFechaMovil), MONTH (vdFechaMovil) ,viDiaMes) INTO vcCodFechas,vdFechaValida;
					IF vcCodFechas = '00000' THEN
						IF DAY(vdFechaValida) = 1 THEN
							LET vdFechaMovil = vdFechaValida -1 UNITS MONTH;
						ELSE
							LET vdFechaMovil = vdFechaValida;
						END IF;
					END IF;
				ELSE
					IF p_sTipoMensual= '01' THEN
						LET vdFechaMovil  = vdFechaMovil + p_iCadaXmeses UNITS MONTH;
					ELIF p_sTipoMensual= '02' THEN
						LET vdFechaMovil  = vdFechaValida + p_iCadaXmeses UNITS MONTH;
					END IF;
				END IF;
			END WHILE;

			IF vcNumAplica = 0 THEN
				--IF vtransaccion = 1 THEN   ROLLBACK WORK;  BEGIN WORK; ELSE ROLLBACK WORK; END IF
				DELETE pp_pagospend WHERE cve_pagoprog = p_sCve_PagoProg AND user_insert = p_sUserInsert;
				DELETE pp_pagoprog WHERE cve_pago= p_sCvePago AND cve_pagoprog= p_sCve_PagoProg AND user_insert = p_sUserInsert;
				SELECT cod_ret, desc_mensaje INTO v_sCodRet,v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '65';
				RETURN v_sCodRet,v_sMensajeRet;
			END IF;
		END IF;
	END IF;

	SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '00';
	RETURN v_sCodRet, v_sMensajeRet;
END;
END PROCEDURE;
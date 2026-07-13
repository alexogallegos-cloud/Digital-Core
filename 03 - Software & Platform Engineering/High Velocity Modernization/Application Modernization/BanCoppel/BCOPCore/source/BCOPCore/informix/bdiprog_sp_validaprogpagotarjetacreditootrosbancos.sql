CREATE PROCEDURE "informix".sp_validaprogpagotarjetacreditootrosbancos(p_sCve_PagoProg CHAR(10),p_sNum_Cte CHAR(20),
				p_sDescripcion CHAR(20),p_sCvePago CHAR(2),p_sCve_Cuenta_Ori CHAR(2),p_sCuentaOrigen CHAR(20),p_sCve_Cuenta_Dest CHAR(2),
				p_sCuentaDestino CHAR(20),p_sBancoDestino CHAR (3),p_sReferencia1 CHAR(40),p_sReferencia2 CHAR(20),p_sConvenio CHAR(5),
				p_mImporte MONEY(16,2),p_sRefCobranza CHAR(40),p_mImporteIva MONEY(16,2),p_iTipoSpei INTEGER,p_sConcepto CHAR(60),
				p_dFechaInicio DATE,p_sCveFinal CHAR(2),p_iNumRepeticiones INTEGER,p_dFechaFin DATE,p_sCvePrograma CHAR(2),p_sTipoDiaria CHAR(2),
				p_iCadaXdias INTEGER,p_iCadaXsemanas INTEGER,p_sDiasSemana CHAR(7),p_sTipoMensual CHAR(2),p_iDiaXdelMes INTEGER,
				p_iCadaXmeses INTEGER,p_sCveOcurre CHAR(2),p_sCveDia CHAR(2),p_sCveCanal CHAR(2),p_sCveNotifica CHAR(2),p_sBenEmail CHAR(40),
				p_sBenCveCompania CHAR(2),p_sBenCelular CHAR(10),p_sCveNotificaEmi CHAR(2),p_sEmiEmail CHAR(40),p_sEmiCveCompania CHAR(2),
				p_sEmiCelular CHAR(10),p_sMensaje CHAR(100),p_sCveEstado CHAR(2),p_sUserInsert CHAR(8),p_dFechaInsert DATE,p_sUserCancela CHAR(8),
				p_dFechaCancela DATE,p_sCanalCancela CHAR(2), p_dFechaMaxima DATE)
	RETURNING CHAR(5), CHAR(80);

-- *************************************************
--* Valida la programaciÃ³n de pago de tarjeta de   *
--* credito de otros bancos.                       *
--* Programo: JosÃ© de JesÃºs Nevarez.               *
--* BD: bdiprog						               *				
--* Fecha: 21/Septiembre/2010                      *
--*Solicito: Mauricio LeÃ³n.						   *
--**************************************************


--Declaracion de variables
DEFINE SQL_ERROR INTEGER;
DEFINE v_sValorBancoppel CHAR(3);
DEFINE v_iCve_PagoProg INTEGER;
DEFINE v_sCodigo CHAR(10);
DEFINE v_iMaxConcecutivo INTEGER;
DEFINE v_iMaxConcecutivo2 INTEGER;
DEFINE v_sCodRet CHAR(5);
DEFINE v_sMensajeRet CHAR(80);
DEFINE vcNumAplica INTEGER;
DEFINE viPasoPrimerMes CHAR(1);
DEFINE vdFechaInicial DATE;
DEFINE vcCodFuncion CHAR(5);
DEFINE vdFechaValida DATE;
DEFINE vdFechaProgramada DATE;
DEFINE viDiaMes INTEGER;
DEFINE vdFechaDisponible DATE;
DEFINE vdFechaMaximaPermitida DATE;
DEFINE vtransaccion INTEGER;
DEFINE vdFechaProx DATE;
DEFINE vc_ciclo_fec CHAR(1);
DEFINE vdFechaDisponible2 DATE;
DEFINE v_sCodSpFecha CHAR(5);
DEFINE v_sLoCueDes CHAR(18);

--InicializaciÃ³n de variables.
LET SQL_ERROR =0;
LET v_sValorBancoppel = '';
LET v_iCve_PagoProg = 0;
LET v_iMaxConcecutivo = 0;
LET v_sCodigo = '';
LET v_iMaxConcecutivo2 = 0;
LET v_sCodRet = '';
LET v_sMensajeRet = '';
LET v_sCodSpFecha = '';
LET vcNumAplica = 0;
LET viPasoPrimerMes = 'N';
LET vcCodFuncion = '';
LET viDiaMes   = -1;
LET vtransaccion = 0;
LET vc_ciclo_fec= 'N';
LET vdFechaDisponible2='';
LET vdFechaMaximaPermitida= p_dFechaMaxima;
LET vdFechaProgramada='';
LET v_sLoCueDes = '';
LET vdFechaValida='';
LET vdFechaProx = '';
LET vdFechaInicial ='';
LET vdFechaDisponible ='';

BEGIN
	ON EXCEPTION SET SQL_ERROR
		LET v_sCodRet= SQL_ERROR;
		LET v_sMensajeRet='PROGRAMACION DE PAGO TARJETA DE CREDITO DE OTROS BANCOS NO FUE REALIZADA';
		--IF vtransaccion = 1 THEN ROLLBACK WORK; BEGIN WORK; ELSE ROLLBACK WORK; END IF
		RETURN v_sCodRet,'';
	END EXCEPTION;

	ON EXCEPTION IN (-271)
	IF vtransaccion = 1 THEN ROLLBACK WORK; BEGIN WORK; ELSE ROLLBACK WORK; END IF
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '230';
		RETURN v_sCodRet, v_sMensajeRet;
	END EXCEPTION;

	ON EXCEPTION IN (-535)
		LET vtransaccion = 1;
	END EXCEPTION WITH RESUME;

	IF vtransaccion = 1 THEN
		COMMIT WORK;
		BEGIN WORK;
	ELSE
		BEGIN WORK;
	END IF;

	--Valida que la clave de cuenta destino no venga sea nulo o vacÃ­o.
	IF (NVL(p_sCve_Cuenta_Dest,'')='') THEN
		IF vtransaccion = 1 THEN ROLLBACK;  BEGIN WORK; ELSE ROLLBACK; END IF;
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes where cve_mensaje = '109';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;

	--Valida que la longitud de la cuenta destino y que no venga nula.
	IF (NVL (p_sCuentaDestino, '') <> '') THEN
		LET v_sLoCueDes = LENGTH(p_sCuentaDestino);
        if p_sBancoDestino<>'103' then
            IF (v_sLoCueDes <>'16') THEN			
                SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes where cve_mensaje = '219';
                RETURN v_sCodRet, v_sMensajeRet;
            END IF;
        end if;    
	ELSE
		IF vtransaccion = 1 THEN ROLLBACK;  BEGIN WORK; ELSE ROLLBACK; END IF;
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes where cve_mensaje = '110';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
	
	--Se valida que la clave de pago exista
	IF NOT EXISTS(SELECT cve_pago FROM bdiprog:pp_tppago WHERE cve_pago = p_sCvePago AND cve_pago = '06') THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '24';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
	
	--Se toma el valor de bancoppel
	SELECT valor INTO v_sValorBancoppel FROM bdiprog:pp_parametros WHERE cve_param = '01';
	IF (NVL(v_sValorBancoppel,'') = '')THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '137';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;

	--Se valida que la clave de banco sea diferente  ala de bancoppel
	IF p_sBancoDestino = v_sValorBancoppel THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '74';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
	
	--Se Valida que importe no venga nulo o vacÃ­o.
	IF(NVL(p_mImporte,'') = '') THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '115';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
	
	--Se valida que el monto sea > 0
	IF p_mImporte < 0 THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '28';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
	
	--Valida que el numero de repeticiones no sea menor a 0 para pago mensual por numero de repeticiones.
	IF p_sCvePrograma='03' THEN
		IF p_sCveFinal='01'THEN
			IF p_iNumRepeticiones <=0 THEN
				SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '174';
				RETURN v_sCodRet, v_sMensajeRet;
			END IF;
		END IF;
	END IF;
	
	--Se realizan validaciones a: cuenta destino, clave de cuenta destino y clave de banco.
	SET ISOLATION TO DIRTY READ;
	IF exists (SELECT user_insert FROM bdiprog:pp_ctasterceros  WHERE  cuenta = p_sCuentaDestino) THEN
		SET ISOLATION TO DIRTY READ;
		IF EXISTS(SELECT user_insert  FROM bdiprog:pp_ctasterceros WHERE num_cte = p_snum_cte AND cuenta = p_sCuentaDestino) THEN
			SET ISOLATION TO DIRTY READ;
			IF EXISTS(SELECT user_insert  FROM bdiprog:pp_ctasterceros WHERE num_cte = p_snum_cte AND cuenta = p_sCuentaDestino AND cve_banco  = p_sBancoDestino) THEN
				SET ISOLATION TO DIRTY READ;
				IF EXISTS (SELECT user_insert  FROM bdiprog:pp_ctasterceros WHERE num_cte = p_snum_cte AND cuenta = p_sCuentaDestino AND cve_banco  = p_sBancoDestino AND  cve_cuenta = p_scve_cuenta_dest) THEN
					SET ISOLATION TO DIRTY READ;
					IF EXISTS(SELECT user_insert  FROM bdiprog:pp_ctasterceros WHERE num_cte = p_snum_cte AND cuenta = p_sCuentaDestino AND cve_banco  = p_sBancoDestino AND cve_estado = '01' AND cve_cuenta = p_scve_cuenta_dest) THEN
					ELSE
						IF vtransaccion = 1 THEN ROLLBACK; BEGIN WORK; ELSE ROLLBACK; END IF;
						SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '189';
						RETURN v_sCodRet, v_sMensajeRet;
					END IF;
				ELSE
					IF vtransaccion = 1 THEN ROLLBACK; BEGIN WORK; ELSE ROLLBACK; END IF;
						SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '205';
						RETURN v_sCodRet, v_sMensajeRet;
				END IF;
			ELSE
				IF vtransaccion = 1 THEN ROLLBACK; BEGIN WORK; ELSE ROLLBACK; END IF;
				SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '204';
				RETURN v_sCodRet, v_sMensajeRet;
			END IF;
		ELSE
			IF vtransaccion = 1 THEN ROLLBACK; BEGIN WORK; ELSE ROLLBACK; END IF;
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '190';
			RETURN v_sCodRet, v_sMensajeRet;
		END IF;
	ELSE
		IF vtransaccion = 1 THEN ROLLBACK; BEGIN WORK; ELSE ROLLBACK; END IF;
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '188';
		RETURN v_sCodRet, v_sMensajeRet;
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

		IF EXISTS(SELECT num_cte FROM bdiprog:pp_pagoprog WHERE cve_pagoprog LIKE '06%') THEN
            SELECT MAX(cve_pagoprog) INTO v_iMaxConcecutivo2 FROM bdiprog:pp_pagoprog  WHERE cve_pagoprog LIKE '06%';
            LET v_iMaxConcecutivo2 = v_iMaxConcecutivo2 + 1;
			LET v_sCodigo  = '0' || v_iMaxConcecutivo2;
            LET p_sCve_PagoProg = v_sCodigo;
		ELSE
			LET v_sCodigo = '0600000001';
			LET p_sCve_PagoProg = v_sCodigo;
		END IF;
	END IF;

	--SE INSERTA LA PROGRAMACION EN ACTIVO.
	IF p_sCvePrograma='04' THEN---PAGO UNICO
		INSERT INTO bdiprog:pp_pagoprog(cve_pagoprog,num_cte,descripcion,cve_pago,cve_cuenta_ori,cuenta_origen,cve_cuenta_dest,cuenta_destino,
				banco_destino,referencia1,referencia2,convenio,importe,ref_cobranza,importe_iva,tipo_spei,concepto,fecha_inicio,cve_final,
				no_repeticiones,fecha_fin,cve_programa,tipo_diaria,cada_x_dias,cada_x_semanas,dias_semana,tipo_mensual,dia_x_del_mes,cada_x_meses,
				cve_ocurre,cve_dia,cve_canal,cve_notifica,ben_email,ben_cve_compania,ben_celular,cve_notifica_emi,emi_email,emi_cve_compania,
				emi_celular,mensaje,cve_estado,user_insert,fecha_insert,user_cancela,fecha_cancela,canal_cancela)
		VALUES (p_sCve_PagoProg,p_sNum_Cte,p_sDescripcion,p_sCvePago,p_sCve_Cuenta_Ori,p_sCuentaOrigen,p_sCve_Cuenta_Dest,p_sCuentaDestino,
			p_sBancoDestino,p_sReferencia1,p_sReferencia2,'',p_mImporte,'',0,p_iTipoSpei,p_sConcepto,p_dFechaInicio,'02',0,p_dFechaFin,p_sCvePrograma,'00',0,0,'',
			'00',0,0,'00','00',p_sCveCanal,p_sCveNotifica,p_sBenEmail,p_sBenCveCompania,p_sBenCelular,p_sCveNotificaEmi,p_sEmiEmail,
			p_sEmiCveCompania,p_sEmiCelular,p_sMensaje,'01',p_sUserInsert,CURRENT::DATE,'','','');
		
		LET vdFechaInicial = p_dFechaInicio;
		LET v_iMaxConcecutivo = 1;
		
		SET LOCK MODE TO WAIT 10;
		--VALIDA LA FECHA PROGRAMADA EN CASO DE QUE EL DIA SEA INHABIL O FERIADO.
		WHILE (viPasoPrimerMes = 'N')
			EXECUTE FUNCTION bdinteg:splvalfecha('001', vdFechaInicial, 0 ) INTO v_sCodSpFecha,vdFechaDisponible;
			SELECT fecha_prox INTO vdFechaProx FROM bdinteg:si_feriado_banca WHERE empresa = '001' AND fecha = vdFechaDisponible;
			IF (vdFechaProx IS NULL) OR (vdFechaProx = "") THEN
				LET vdFechaProgramada = vdFechaDisponible;
				LET viPasoPrimerMes = 'S';
			ELSE
				LET vdFechaInicial = vdFechaProx;
			END IF;
		END WHILE;
		
		INSERT INTO bdiprog:pp_pagospend(cve_pagoprog,consecutivo,fecha_prog,estado,fecha_aplic,folio_suc,user_insert,fecha_insert,user_cancela,
				fecha_cancela,canal_cancela,cve_rechazo)
		VALUES(p_sCve_PagoProg,v_iMaxConcecutivo,vdFechaProgramada,'03','','',p_sUserInsert,CURRENT::DATE,'','','','00');
		
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
			'00',0,0,'',p_sTipoMensual,p_iDiaXdelMes,p_iCadaXmeses,p_sCveOcurre,p_sCveDia,p_sCveCanal,p_sCveNotifica,p_sBenEmail,p_sBenCveCompania,p_sBenCelular,p_sCveNotificaEmi,
			p_sEmiEmail,p_sEmiCveCompania,p_sEmiCelular,p_sMensaje,'01',p_sUserInsert,CURRENT::DATE,'','','');
			
		IF p_sCveFinal='01' THEN ---PROGRAMACION POR REPETICIONES
			
			LET vdFechaInicial = p_dFechaInicio;
			
			WHILE vcNumAplica < p_iNumRepeticiones 
				IF viPasoPrimerMes = 'S' THEN
					LET vdFechaInicial = MONTH (vdFechaInicial) || '/01/' || YEAR(vdFechaInicial);
				END IF;	
					
				IF p_sTipoMensual='01' THEN --MENSUAL POR DIA ESPECIFICO
					EXECUTE FUNCTION bdiprog:sp_obtenerFechaValida(YEAR(vdFechaInicial),MONTH(vdFechaInicial),p_iDiaXdelMes) INTO vcCodFuncion,vdFechaValida;
				ELIF p_sTipoMensual='02' THEN --MENSUAL POR DIA X 
					EXECUTE FUNCTION bdiprog:sp_obtenerOcurrenciaDia(p_sCveOcurre,p_sCveDia,vdFechaInicial) INTO vcCodFuncion,vdFechaValida;
				END IF;
				
				WHILE (vc_ciclo_fec = 'N')
					EXECUTE FUNCTION bdinteg:splvalfecha('001', vdFechaValida, 0 ) INTO v_sCodSpFecha,vdFechaDisponible;
					SELECT fecha_prox INTO vdFechaProx FROM bdinteg:si_feriado_banca WHERE empresa = '001' AND fecha = vdFechaDisponible;
					IF (vdFechaProx IS NULL) OR (vdFechaProx = "") THEN
						LET vdFechaProgramada = vdFechaDisponible;
						LET vc_ciclo_fec = 'S';
					ELSE
						LET vdFechaValida = vdFechaProx;
					END IF;
				END WHILE;
				
				LET vc_ciclo_fec = 'N';
				
				IF vdFechaProgramada >= vdFechaInicial THEN
					IF vcCodFuncion = '00000' THEN
						LET vcNumAplica = vcNumAplica + 1;
						SET LOCK MODE TO WAIT 10;
						INSERT INTO bdiprog:pp_pagospend(cve_pagoprog, consecutivo, fecha_prog, estado, fecha_aplic, folio_suc, user_insert, fecha_insert, user_cancela, fecha_cancela, canal_cancela, cve_rechazo) 
						VALUES(p_sCve_PagoProg, vcNumAplica, vdFechaProgramada, '03', '', '',p_sUserInsert , CURRENT::DATE, '', '', '', '00');
					END IF;
				END IF;
					
				LET viPasoPrimerMes = 'S';
				LET viDiaMes   = DAY(vdFechaValida);
				
				IF vcNumAplica <> p_iNumRepeticiones THEN
					IF viDiaMes > 28 THEN
						LET vdFechaDisponible2 = MONTH (vdFechaInicial) || '/01/' || YEAR(vdFechaInicial);
						LET vdFechaInicial  = vdFechaDisponible2 + p_iCadaXmeses UNITS MONTH;
						EXECUTE FUNCTION bdiprog:sp_obtenerFechaValida(YEAR(vdFechaInicial), MONTH (vdFechaInicial) ,viDiaMes) INTO vcCodFuncion,vdFechaValida;
						IF vcCodFuncion = '00000' THEN
							IF DAY(vdFechaValida) = 1 THEN
								LET vdFechaInicial = vdFechaValida -1 UNITS MONTH;
							ELSE
								LET vdFechaInicial = vdFechaValida;
							END IF;
						END IF;
					ELSE
						IF  p_sTipoMensual='01' THEN
							LET vdFechaInicial  = vdFechaInicial + p_iCadaXmeses UNITS MONTH;
						ELIF  p_sTipoMensual='02' THEN
							LET vdFechaInicial  = vdFechaValida + p_iCadaXmeses UNITS MONTH;
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
			
			IF p_sTipoMensual='02' THEN			
				IF vcNumAplica = 0 THEN
					--IF vtransaccion = 1 THEN   ROLLBACK WORK;  BEGIN WORK;  ELSE ROLLBACK WORK;	END IF
					DELETE pp_pagospend WHERE cve_pagoprog = p_sCve_PagoProg AND user_insert = p_sUserInsert;
					DELETE pp_pagoprog WHERE cve_pago= p_sCvePago AND cve_pagoprog= p_sCve_PagoProg AND user_insert = p_sUserInsert;
					SELECT cod_ret, desc_mensaje INTO v_sCodRet,v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '65';
					RETURN v_sCodRet,v_sMensajeRet;
				END IF;
			END IF;
		
		ELIF p_sCveFinal='02' THEN -- PROGRAMACION POR FECHA.
		
			LET vdFechaInicial = p_dFechaInicio; 
		
			WHILE vdFechaInicial <= p_dFechaFin 
				IF viPasoPrimerMes = 'S' THEN
					LET vdFechaInicial = MONTH (vdFechaInicial) || '/01/' || YEAR(vdFechaInicial);
				END IF;

				IF p_sTipoMensual='01' THEN --MENSUAL POR DIA ESPECIFICO
					EXECUTE FUNCTION bdiprog:sp_obtenerFechaValida(YEAR(vdFechaInicial),MONTH(vdFechaInicial),p_iDiaXdelMes) INTO vcCodFuncion,vdFechaValida;
				ELIF p_sTipoMensual='02' THEN --MENSUAL POR DIA X 
					EXECUTE FUNCTION bdiprog:sp_obtenerOcurrenciaDia(p_sCveOcurre,p_sCveDia,vdFechaInicial) INTO vcCodFuncion,vdFechaValida;
				END IF;
				
				WHILE (vc_ciclo_fec = 'N')
					EXECUTE FUNCTION bdinteg:splvalfecha('001', vdFechaValida, 0 ) INTO v_sCodSpFecha,vdFechaDisponible;
					SELECT fecha_prox INTO vdFechaProx FROM bdinteg:si_feriado_banca WHERE empresa = '001' AND fecha = vdFechaDisponible;
					IF (vdFechaProx IS NULL) OR (vdFechaProx = "") THEN
						LET vdFechaProgramada = vdFechaDisponible;
						LET vc_ciclo_fec = 'S';
					ELSE
						LET vdFechaValida = vdFechaProx;
					END IF;
				END WHILE;
				
				LET vc_ciclo_fec = 'N';
				IF vdFechaProgramada >= p_dFechaInicio AND vdFechaProgramada <= p_dFechaFin THEN
					IF vcCodFuncion = '00000' THEN
						LET vcNumAplica = vcNumAplica + 1;
						SET LOCK MODE TO WAIT 10;
						INSERT INTO bdiprog:pp_pagospend(cve_pagoprog, consecutivo, fecha_prog, estado, fecha_aplic, folio_suc, user_insert, fecha_insert, user_cancela, fecha_cancela, canal_cancela, cve_rechazo) 
						VALUES(p_sCve_PagoProg, vcNumAplica, vdFechaProgramada, '03', '', '',p_sUserInsert , CURRENT::DATE, '', '', '', '00');
					END IF;
				END IF;
				
				LET viPasoPrimerMes = 'S';
				LET viDiaMes   = DAY(vdFechaValida);
				
				IF viDiaMes > 28 THEN
					LET vdFechaDisponible2 = MONTH (vdFechaInicial) || '/01/' || YEAR(vdFechaInicial);
					LET vdFechaInicial  = vdFechaDisponible2 + p_iCadaXmeses UNITS MONTH;
					EXECUTE FUNCTION bdiprog:sp_obtenerFechaValida(YEAR(vdFechaInicial), MONTH (vdFechaInicial) ,viDiaMes) INTO vcCodFuncion,vdFechaValida;
					IF vcCodFuncion = '00000' THEN
						IF DAY(vdFechaValida) = 1 THEN
							LET vdFechaInicial = vdFechaValida -1 UNITS MONTH;
						ELSE
							LET vdFechaInicial = vdFechaValida;
						END IF;
					END IF;
				ELSE
					IF  p_sTipoMensual='01' THEN
						LET vdFechaInicial  = vdFechaInicial + p_iCadaXmeses UNITS MONTH;
					ELIF  p_sTipoMensual='02' THEN
						LET vdFechaInicial  = vdFechaValida + p_iCadaXmeses UNITS MONTH;
					END IF;
				END IF;
			END WHILE;
			
			IF vcNumAplica = 0 THEN
				--IF vtransaccion = 1 THEN   ROLLBACK WORK;  BEGIN WORK;  ELSE ROLLBACK WORK;	END IF
				DELETE pp_pagospend WHERE cve_pagoprog = p_sCve_PagoProg AND user_insert = p_sUserInsert;
				DELETE pp_pagoprog WHERE cve_pago= p_sCvePago AND cve_pagoprog= p_sCve_PagoProg AND user_insert = p_sUserInsert;
				SELECT cod_ret, desc_mensaje INTO v_sCodRet,v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '65';
				RETURN v_sCodRet,v_sMensajeRet;
			END IF;
		END IF;
	END IF;
	
	SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '00';
	RETURN v_sCodRet, v_sMensajeRet;
	
END
END PROCEDURE;
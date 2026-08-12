CREATE PROCEDURE "informix".sp_validaprogtrasctasefecpropias(pNumCte CHAR(20), pDescricion CHAR(20), pCvePago CHAR(2), pCveCtaOri CHAR(2), pNumCtaOri CHAR(20), pCveCtaDest CHAR(2), pNumCtaDest CHAR(20), pBancoDest CHAR(3), pRef1 CHAR(40), pRef2 CHAR(20),pcConvenio CHAR(5),pcRefCobranza CHAR(40),pmImporteIva MONEY(16,2),piTipoSpei INTEGER,
pImporte MONEY(16,2), pConcepto CHAR(60), pFechaInicio DATE, pCveFinal CHAR(2), pNumRepeteciones INTEGER, pFechaFin DATE,pCvePrograma CHAR(2), pTipoDiaria CHAR(2), pCadaXDias INTEGER,pCveCanal CHAR(2),pDiasSemana CHAR(7),pCadaXSemanas INTEGER,pTipoMensual CHAR(2),pDiaXMes INTEGER,pCadaXMes INTEGER,pCveOcurre CHAR(2),pCveDia CHAR(2),
pCveNotifica CHAR(2),pBenEmail CHAR(100), pBenCveCompania CHAR(2),pBenCelular CHAR(10),pCveNotificaEmi CHAR(2),pEmiEmail CHAR(100),pEmiCveCompania CHAR(2),pEmiCelular CHAR(10),pMensaje CHAR(100), pUserInsert CHAR(8),pFechaMaxima DATE)
RETURNING CHAR(5),CHAR(100);
--*************************************************
--Creado por: Anselmo Verdugo                   			--*
-- Actividad: Valida programación para el traspaso de cuentas efectivas propias.
--  Solicitó: Aymme Osuna                       			--*
--     Fecha: 08/NOV/2008   
-- Modifico: Anselmo Verdugo
-- Fecha: Enero 2009
--Se valida la clave final, se valida la clave de compañia sea <> 00 que el numero de cel no acepte letras, si es programacion unica que la fecha in y fecha fin sean iguales, se validan las cu entas en la tabla pp_ctasterceros                    			--*
--Fecha : 05 de marzo 2009
--Modifico: Alejandro Osuna
--se quitaron los datos de insercion inecesarios
--Fecha : 14 de Octubre 2010
--Modifico: José de Jesús Nevarez.
--Se Valida la programacion de pago para los dias 25-Diciembre y 1-Enero.
--*************************************************
DEFINE sql_err INTEGER;
DEFINE vcCodRet CHAR(6);
DEFINE vcCodFechas CHAR(5);
DEFINE vcAplicaPago CHAR(5);
DEFINE vcMensaje CHAR(100);
DEFINE vcCvePagoProg CHAR(10);
DEFINE vcFormaCvePagoProg CHAR(10);
DEFINE I        INTEGER;
DEFINE vdFechaInicio DATE;
DEFINE vcCodPais CHAR(3);
DEFINE vdDiaHabil DATE;
DEFINE vdFechaMovil DATE;
DEFINE vdFechaMovil2 DATE;
DEFINE viEsDiaSemana INTEGER;
DEFINE viCadaXSem INTEGER;
DEFINE vdFechaDisponible1 DATE;
DEFINE vcNumAplica INTEGER;
DEFINE viDiaMes INTEGER;
DEFINE viPasoPrimerMes CHAR(1);
DEFINE vdFechaMaximaPermitida DATE;
DEFINE vdFechaEstimada DATE;
DEFINE vcCveBancoppel CHAR(3);
DEFINE vtransaccion integer;
DEFINE vcCuentaTemp	CHAR(20);
DEFINE vcStatusCta  CHAR(1);
DEFINE  vdFechaProgramada DATE;
DEFINE  iDia INTEGER;
DEFINE  iMes INTEGER;

ON EXCEPTION SET sql_err
	LET vcCodRet = sql_err;
	--IF sql_err = -271 THEN
		if vtransaccion = 1 then ROLLBACK WORK; BEGIN WORK; else ROLLBACK WORK; end if
		--SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '230';  
		RETURN vcCodRet,''; 
END EXCEPTION; 

on exception in (-271)
	if vtransaccion = 1 then ROLLBACK WORK; BEGIN WORK; else ROLLBACK WORK; end if
		SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '230';  
		RETURN vcCodRet,vcMensaje;
 end exception;		
 
on exception in (-535)
         let vtransaccion = 1;
end exception with resume;

LET I = 0;
LET vcCodRet ='';
LET vcNumAplica = 0;
LET vdFechaInicio = pFechaInicio;
LET vcFormaCvePagoProg = '';
LET vcCvePagoProg       = '';
LET vcCodPais = '001';
LET viEsDiaSemana = -1;
LET viCadaXSem = -1;
LET vcCodFechas = '';
LET viDiaMes   = -1;
LET viPasoPrimerMes = 'N';
LET vtransaccion = 0;
LET vdFechaProgramada= '';
LET iDia = 0;
LET iMes = 0;
LET vcAplicaPago ='';
LET vcMensaje ='';
LET vdDiaHabil = '';
LET vdFechaMovil ='';
LET vdFechaMovil2 ='';
LET vdFechaDisponible1 ='';
LET vdFechaMaximaPermitida = pFechaMaxima;
LET vdFechaEstimada = '';
LET vcCveBancoppel ='';
LEt vcCuentaTemp ='';
LEt vcStatusCta ='';


	if vtransaccion = 1 then
	   COMMIT WORK;
	   BEGIN WORK;
	else
	   BEGIN WORK;
	end if;



	
	
   	IF pCveCtaDest <> '01' THEN
		if vtransaccion = 1 then   ROLLBACK WORK;  BEGIN WORK;  else ROLLBACK WORK;	end if
		SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '196';  
		RETURN vcCodRet,vcMensaje; 
	END IF;		

	SELECT valor INTO vcCveBancoppel FROM bdiprog:pp_parametros WHERE cve_param = '01';
							
	IF NVL(vcCveBancoppel,'') = '' THEN
		if vtransaccion = 1 then   ROLLBACK WORK;  BEGIN WORK;  else ROLLBACK WORK;	end if
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '137';
		RETURN vcCodRet, vcMensaje;
	END IF;
							
	IF TRIM(vcCveBancoppel) <>  pBancoDest THEN
		if vtransaccion = 1 then   ROLLBACK WORK;  BEGIN WORK;  else ROLLBACK WORK;	end if
		SELECT cod_ret,desc_mensaje INTO vcCodRet, vcMensaje FROM bdiprog:pp_mensajes where cve_mensaje = '74';
		RETURN vcCodRet, vcMensaje;
	END IF;
	
	--se valida la cuenta destino
	SET ISOLATION TO DIRTY READ;
	SELECT cuenta,status_cta INTO vcCuentaTemp, vcStatusCta FROM bdicheq:sc_maechq WHERE cuenta = TRIM(pNumCtaDest);

	IF vcCuentaTemp IS NULL THEN 
		if vtransaccion = 1 then   ROLLBACK WORK;  BEGIN WORK;  else ROLLBACK WORK;	end if
		SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '188';  
		RETURN vcCodRet,vcMensaje; 
	END IF;

--	IF vcStatusCta <> '1' THEN 
	IF vcStatusCta = '2' THEN 
		if vtransaccion = 1 then   ROLLBACK WORK;  BEGIN WORK;  else ROLLBACK WORK;	end if
		SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '189';  
		RETURN vcCodRet,vcMensaje; 
	END IF;	
	SET ISOLATION TO DIRTY READ;
	IF NOT EXISTS(SELECT num_cte FROM bdicheq:sc_maechq WHERE cuenta = TRIM(pNumCtaDest) and num_cte = TRIM(pNumCte) ) THEN
		if vtransaccion = 1 then   ROLLBACK WORK;  BEGIN WORK;  else ROLLBACK WORK;	end if
		SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '190';  
		RETURN vcCodRet,vcMensaje; 
	END IF;
	SET ISOLATION TO DIRTY READ;
	IF NOT EXISTS ( select cuenta  FROM bdicheq:sc_maechq maechq inner join bdiprog:pp_producperm  producperm ON maechq.producto = producperm.producto and producperm.cve_pago = '01' and producperm.permite_prog = 'S' 
							where maechq.cuenta = TRIM(pNumCtaDest) ) THEN
		if vtransaccion = 1 then   ROLLBACK WORK;  BEGIN WORK;  else ROLLBACK WORK;	end if
		SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '34';  
		RETURN vcCodRet,vcMensaje; 
	END IF;
	SET ISOLATION TO DIRTY READ;
	-- SE OBTIENE LA CLAVE DE PAGO PROGRAMADO.
	SELECT max(cve_pagoprog)+1  INTO vcFormaCvePagoProg FROM bdiprog:pp_pagoprog  WHERE substr(cve_pagoprog,1,2) = '01';
	
	IF EXISTS ( SELECT descripcion  FROM  bdiprog:pp_pagoprog WHERE num_cte = TRIM(pNumCte) and descripcion = TRIM(pDescricion) ) THEN
		if vtransaccion = 1 then   ROLLBACK WORK;  BEGIN WORK;  else ROLLBACK WORK;	end if
		SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '131';  
		RETURN vcCodRet,vcMensaje; 
	END IF;
								
	IF NVL(vcFormaCvePagoProg,'') = '' THEN
		LET vcCvePagoProg = '01' || lpad('1',8,'0');
	ELSE
		LET vcCvePagoProg = '01' || SUBSTR(vcFormaCvePagoProg,2,8);
	END IF;

	IF pCvePrograma = '04' THEN -- PAGO UNICO.
		
		LET vdFechaProgramada = pFechaInicio;
		LET iDia = DAY(vdFechaProgramada);
		LET iMes = MONTH (vdFechaProgramada);
		
		SET LOCK MODE TO WAIT 10;
		INSERT INTO bdiprog:pp_pagoprog (cve_pagoprog,num_cte,descripcion,cve_pago,cve_cuenta_ori,cuenta_origen,cve_cuenta_dest,cuenta_destino,banco_destino,referencia1,
										 referencia2,convenio,importe,ref_cobranza,importe_iva,tipo_spei,concepto,fecha_inicio,cve_final,no_repeticiones,
										 fecha_fin,cve_programa,tipo_diaria,cada_x_dias,cada_x_semanas,dias_semana,tipo_mensual,dia_x_del_mes,cada_x_meses,cve_ocurre,
										 cve_dia,cve_canal,cve_notifica,ben_email,ben_cve_compania,ben_celular,cve_notifica_emi,emi_email,emi_cve_compania,emi_celular,
										 mensaje,cve_estado,user_insert,fecha_insert,user_cancela,fecha_cancela,canal_cancela )
								 VALUES(vcCvePagoProg,pNumCte,pDescricion,pCvePago,pCveCtaOri,pNumCtaOri,pCveCtaDest,pNumCtaDest,pBancoDest,pRef1,
										 pRef2,pcConvenio,pImporte,pcRefCobranza,pmImporteIva,piTipoSpei,pConcepto,pFechaInicio,pCveFinal,0,
										 pFechaFin,pCvePrograma,'00',0,0,'','00',0,0,'00',
										 '00',pCveCanal,pCveNotifica,pBenEmail,pBenCveCompania,pBenCelular,pCveNotificaEmi,pEmiEmail,pEmiCveCompania,pEmiCelular,
										 pMensaje,'01',pUserInsert,CURRENT::DATE,'','','');
										
		--Valida que la fecha programada sea 25-DIC o 1-ENE.
		IF (iDia=25 AND iMes=12) OR (iDia=1 AND iMes=1) THEN
			LET vdFechaProgramada = vdFechaProgramada + 1;
		END IF;
		SET LOCK MODE TO WAIT 10;
		INSERT INTO bdiprog:pp_pagospend(cve_pagoprog, consecutivo, fecha_prog, estado, fecha_aplic, folio_suc, user_insert, fecha_insert, user_cancela, fecha_cancela, canal_cancela, cve_rechazo) 
		VALUES(vcCvePagoProg, 1, vdFechaProgramada, '03', '', '',pUserInsert , CURRENT::DATE, '', '', '', '00');
	
	END IF;
	
	-- PROGRAMACION POR REPETICIONES.
	IF pCveFinal = '01' THEN
		-- DIARIO - REPETICIONES.
		IF pCvePrograma = '01' THEN
			SET LOCK MODE TO WAIT 10;
			INSERT INTO bdiprog:pp_pagoprog (cve_pagoprog,num_cte,descripcion,cve_pago,cve_cuenta_ori,cuenta_origen,cve_cuenta_dest,cuenta_destino,banco_destino,referencia1,
											referencia2,convenio,importe,ref_cobranza,importe_iva,tipo_spei,concepto,fecha_inicio,cve_final,no_repeticiones,
											fecha_fin,cve_programa,tipo_diaria,cada_x_dias,cada_x_semanas,dias_semana,tipo_mensual,dia_x_del_mes,cada_x_meses,cve_ocurre,
											cve_dia,cve_canal,cve_notifica,ben_email,ben_cve_compania,ben_celular,cve_notifica_emi,emi_email,emi_cve_compania,emi_celular,
											mensaje,cve_estado,user_insert,fecha_insert,user_cancela,fecha_cancela,canal_cancela )
			VALUES(vcCvePagoProg,pNumCte,pDescricion,pCvePago,pCveCtaOri,pNumCtaOri,pCveCtaDest,pNumCtaDest,pBancoDest,pRef1,
											pRef2,pcConvenio,pImporte,pcRefCobranza,pmImporteIva,piTipoSpei,pConcepto,pFechaInicio,pCveFinal,pNumRepeteciones,
											pFechaFin,pCvePrograma,pTipoDiaria,pCadaXDias,0,'','00',0,0,'00',
											'00',pCveCanal,pCveNotifica,pBenEmail,pBenCveCompania,pBenCelular,pCveNotificaEmi,pEmiEmail,pEmiCveCompania,pEmiCelular,
											pMensaje,'01',pUserInsert,CURRENT::DATE,'','','');
			LET I = 0;
			IF pTipoDiaria = '01' THEN 
				-- and vdFechaInicio <= vdTiempoAnticipacion  
				LET vdFechaEstimada = vdFechaInicio + ( (pNumRepeteciones - 1) * pCadaXDias);
				IF vdFechaEstimada > vdFechaMaximaPermitida THEN
					if vtransaccion = 1 then   ROLLBACK WORK;  BEGIN WORK;  else ROLLBACK WORK;	end if
					SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '66';  
					RETURN vcCodRet,vcMensaje; 
				END IF;
				WHILE  (I < pNumRepeteciones )
					LET I = I + 1;
					LET iDia = DAY(vdFechaInicio);
					LET iMes = MONTH (vdFechaInicio);
					IF (iDia=25 AND iMes=12) OR (iDia=1 AND iMes=1) THEN
						LET vdFechaProgramada = vdFechaInicio + 1;
						IF pCadaXDias = 1 THEN
							LET vdFechaInicio = vdFechaInicio + 1;
						END IF;
					ELSE 
						LET vdFechaProgramada = vdFechaInicio;
					END IF;
					SET LOCK MODE TO WAIT 10;
					INSERT INTO bdiprog:pp_pagospend(cve_pagoprog, consecutivo, fecha_prog, estado, fecha_aplic, folio_suc, user_insert, fecha_insert, user_cancela, fecha_cancela, canal_cancela, cve_rechazo) 
					VALUES(vcCvePagoProg, I, vdFechaProgramada, '03', '', '',pUserInsert , CURRENT::DATE, '', '', '', '00');
					IF pNumRepeteciones = I THEN
					ELSE
						LET vdFechaInicio = vdFechaInicio + pCadaXDias;
					END IF;
				END WHILE;

				IF I = 0 THEN
					if vtransaccion = 1 then   ROLLBACK WORK;  BEGIN WORK;  else ROLLBACK WORK;	end if
					SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '65';  
					RETURN vcCodRet,vcMensaje;
				END IF;
			END IF;	
			IF pTipoDiaria = '02' THEN
				LET vdFechaMovil = pFechaInicio;  
				WHILE I < pNumRepeteciones
					LET vdFechaMovil2 = vdFechaMovil;
					EXECUTE FUNCTION bdinteg:splvalfecha('001', vdFechaMovil, 0 ) INTO vcCodPais,vdDiaHabil;
					LET I = I + 1;
					LET iDia = DAY(vdDiaHabil);
					LET iMes = MONTH (vdDiaHabil);
					IF (iDia=25 AND iMes=12) OR (iDia=1 AND iMes=1) THEN
						LET vdFechaProgramada = vdDiaHabil + 1;
					ELSE 
						LET vdFechaProgramada = vdDiaHabil;
					END IF;
					SET LOCK MODE TO WAIT 10;
					INSERT INTO bdiprog:pp_pagospend(cve_pagoprog, consecutivo, fecha_prog, estado, fecha_aplic, folio_suc, user_insert, fecha_insert, user_cancela, fecha_cancela, canal_cancela, cve_rechazo) 
					VALUES(vcCvePagoProg, I, vdFechaProgramada, '03', '', '',pUserInsert , CURRENT::DATE, '', '', '', '00');
					IF pNumRepeteciones = I THEN
					ELSE
						IF vdFechaMovil2 = vdDiaHabil THEN
							LET vdFechaMovil = vdFechaMovil + 1;
						ELSE
							LET vdFechaMovil = vdDiaHabil + 1;
						END IF;
					END IF;
				END WHILE;
					 
				IF vdDiaHabil > vdFechaMaximaPermitida THEN
					if vtransaccion = 1 then   ROLLBACK WORK;  BEGIN WORK;  else ROLLBACK WORK;	end if
					SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '66';  
					RETURN vcCodRet,vcMensaje; 
				END IF;
				IF I = 0 THEN
					if vtransaccion = 1 then   ROLLBACK WORK;  BEGIN WORK;  else ROLLBACK WORK;	end if
					SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '65';
					RETURN vcCodRet,vcMensaje;
				END IF;
			END IF;
		-- SEMANAL - REPETICIONES.
		ELIF pCvePrograma = '02' THEN
			SET LOCK MODE TO WAIT 10;
			-- Se realiza registro del pago programado.
			INSERT INTO bdiprog:pp_pagoprog (cve_pagoprog,num_cte,descripcion,cve_pago,cve_cuenta_ori,cuenta_origen,cve_cuenta_dest,cuenta_destino,banco_destino,referencia1,
											referencia2,convenio,importe,ref_cobranza,importe_iva,tipo_spei,concepto,fecha_inicio,cve_final,no_repeticiones,
											fecha_fin,cve_programa,tipo_diaria,cada_x_dias,cada_x_semanas,dias_semana,tipo_mensual,dia_x_del_mes,cada_x_meses,cve_ocurre,
											cve_dia,cve_canal,cve_notifica,ben_email,ben_cve_compania,ben_celular,cve_notifica_emi,emi_email,emi_cve_compania,emi_celular,
											mensaje,cve_estado,user_insert,fecha_insert,user_cancela,fecha_cancela,canal_cancela )

			VALUES(vcCvePagoProg,pNumCte,pDescricion,pCvePago,pCveCtaOri,pNumCtaOri,pCveCtaDest,pNumCtaDest,pBancoDest,pRef1,
											pRef2,pcConvenio,pImporte,pcRefCobranza,pmImporteIva,piTipoSpei,pConcepto,pFechaInicio,pCveFinal,pNumRepeteciones,
											pFechaFin,pCvePrograma,'00',0,pCadaXSemanas,pDiasSemana,'00',0,0,'00',
											'00',pCveCanal,pCveNotifica,pBenEmail,pBenCveCompania,pBenCelular,pCveNotificaEmi,pEmiEmail,pEmiCveCompania,pEmiCelular,
											pMensaje,'01',pUserInsert,CURRENT::DATE,'','','');
			-- Generar registros para pagos pendientes.
			LET I = 0;
			LET vdFechaMovil = pFechaInicio;
			WHILE ( I < pNumRepeteciones )
				EXECUTE FUNCTION bdiprog:sp_EsPosibleAplicarPagoEnDiaSemana(vdFechaMovil, pDiasSemana ) INTO vcAplicaPago;
				LET viEsDiaSemana = WEEKDAY(vdFechaMovil);
				IF vcAplicaPago = '00000' THEN
					LET I = I + 1;
					LET iDia = DAY(vdFechaMovil);
					LET iMes = MONTH (vdFechaMovil);
					IF (iDia=25 AND iMes=12) OR (iDia=1 AND iMes=1) THEN
						LET vdFechaProgramada = vdFechaMovil + 1;
						LET vdFechaMovil = vdFechaMovil + 1;
					ELSE 
						LET vdFechaProgramada = vdFechaMovil;
					END IF;
					SET LOCK MODE TO WAIT 10;
					INSERT INTO bdiprog:pp_pagospend(cve_pagoprog, consecutivo, fecha_prog, estado, fecha_aplic, folio_suc, user_insert, fecha_insert, user_cancela, fecha_cancela, canal_cancela, cve_rechazo) 
					VALUES(vcCvePagoProg, I, vdFechaProgramada, '03', '', '',pUserInsert , CURRENT::DATE, '', '', '', '00');
				END IF;
				IF pNumRepeteciones = I THEN
				ELSE
					-- CALCULAR EL CADA X SEMANAS CUANDO ES DOMINGO
					IF viEsDiaSemana = 0 and I < pNumRepeteciones THEN
						LET vdFechaMovil = vdFechaMovil + (7* (pCadaXSemanas - 1));
					END IF; 
					--CALCULAR EL SIGUIENTE DIA.
					LET vdFechaMovil = vdFechaMovil + 1;
				END IF;	
			END WHILE;
			IF vdFechaMovil > vdFechaMaximaPermitida THEN
				if vtransaccion = 1 then   ROLLBACK WORK;  BEGIN WORK;  else ROLLBACK WORK;	end if
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '66';  
				RETURN vcCodRet,vcMensaje; 
			END IF;
			IF I = 0 THEN
				if vtransaccion = 1 then   ROLLBACK WORK;  BEGIN WORK;  else ROLLBACK WORK;	end if
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '65';  
				RETURN vcCodRet,vcMensaje;
			END IF;

		-- MENSUAL - REPETICIONES.
		ELIF pCvePrograma = '03' THEN
			IF pTipoMensual = '01' THEN
				SET LOCK MODE TO WAIT 10;
				INSERT INTO bdiprog:pp_pagoprog (cve_pagoprog,num_cte,descripcion,cve_pago,cve_cuenta_ori,cuenta_origen,cve_cuenta_dest,cuenta_destino,banco_destino,referencia1,
													 referencia2,convenio,importe,ref_cobranza,importe_iva,tipo_spei,concepto,fecha_inicio,cve_final,no_repeticiones,
													 fecha_fin,cve_programa,tipo_diaria,cada_x_dias,cada_x_semanas,dias_semana,tipo_mensual,dia_x_del_mes,cada_x_meses,cve_ocurre,
													 cve_dia,cve_canal,cve_notifica,ben_email,ben_cve_compania,ben_celular,cve_notifica_emi,emi_email,emi_cve_compania,emi_celular,
													 mensaje,cve_estado,user_insert,fecha_insert,user_cancela,fecha_cancela,canal_cancela )
				VALUES(vcCvePagoProg,pNumCte,pDescricion,pCvePago,pCveCtaOri,pNumCtaOri,pCveCtaDest,pNumCtaDest,pBancoDest,pRef1,
													 pRef2,pcConvenio,pImporte,pcRefCobranza,pmImporteIva,piTipoSpei,pConcepto,pFechaInicio,pCveFinal,pNumRepeteciones,
													 pFechaFin,pCvePrograma,'00',0,0,'',pTipoMensual,pDiaXMes,pCadaXMes,'00',
													 '00',pCveCanal,pCveNotifica,pBenEmail,pBenCveCompania,pBenCelular,pCveNotificaEmi,pEmiEmail,pEmiCveCompania,pEmiCelular,
													 pMensaje,'01',pUserInsert,CURRENT::DATE,'','','');
													 
				LET I = 0;
				LET vdFechaMovil = pFechaInicio; 
				LET viDiaMes   = DAY(vdFechaMovil);
				WHILE I < pNumRepeteciones 
					IF viPasoPrimerMes = 'S' THEN
						LET vdFechaMovil = month (vdFechaMovil) || '/01/' || year(vdFechaMovil);
					END IF;						
					EXECUTE FUNCTION bdiprog:sp_obtenerFechaValida(year(vdFechaMovil),month(vdFechaMovil),pDiaXMes) INTO vcCodFechas,vdFechaDisponible1;
					IF vdFechaDisponible1 >= vdFechaMovil THEN
						IF vcCodFechas = '00000' THEN
							LET I = I + 1;
							LET iDia = DAY(vdFechaDisponible1);
							LET iMes = MONTH (vdFechaDisponible1);
							IF (iDia=25 AND iMes=12) OR (iDia=1 AND iMes=1) THEN
								LET vdFechaProgramada = vdFechaDisponible1 + 1;
							ELSE 
								LET vdFechaProgramada = vdFechaDisponible1;
							END IF;
							
							SET LOCK MODE TO WAIT 10;
							INSERT INTO bdiprog:pp_pagospend(cve_pagoprog, consecutivo, fecha_prog, estado, fecha_aplic, folio_suc, user_insert, fecha_insert, user_cancela, fecha_cancela, canal_cancela, cve_rechazo) 
							VALUES(vcCvePagoProg, I, vdFechaProgramada, '03', '', '',pUserInsert , CURRENT::DATE, '', '', '', '00');
						END IF;
					END IF;
					LET viPasoPrimerMes = 'S';
					IF pNumRepeteciones = I THEN
					ELSE
						IF viDiaMes > 28 THEN
							LET vdFechaMovil2 = month (vdFechaMovil) || '/01/' || year(vdFechaMovil);
							LET vdFechaMovil  = vdFechaMovil2 + pCadaXMes UNITS MONTH;
							EXECUTE FUNCTION bdiprog:sp_obtenerFechaValida(year(vdFechaMovil), month (vdFechaMovil) ,viDiaMes) INTO vcCodFechas,vdFechaDisponible1;
							IF vcCodFechas = '00000' THEN
								IF DAY(vdFechaDisponible1) = 1 THEN
									LET vdFechaMovil = vdFechaDisponible1 -1;
								ELSE
									LET vdFechaMovil = vdFechaDisponible1;
								END IF;
							END IF;
						ELSE
							LET vdFechaMovil  = vdFechaMovil + pCadaXMes UNITS MONTH;
						END IF;
					END IF;
				END WHILE;
				IF vdFechaDisponible1 > vdFechaMaximaPermitida THEN
					if vtransaccion = 1 then   ROLLBACK WORK;  BEGIN WORK;  else ROLLBACK WORK;	end if
					SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '66';  
					RETURN vcCodRet,vcMensaje; 
				END IF;
				IF I = 0 THEN
					if vtransaccion = 1 then   ROLLBACK WORK;  BEGIN WORK;  else ROLLBACK WORK;	end if
					SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '65';
					RETURN vcCodRet,vcMensaje;
				END IF;
			END IF;
			IF pTipoMensual = '02' THEN
				SET LOCK MODE TO WAIT 10;
				INSERT INTO bdiprog:pp_pagoprog (cve_pagoprog,num_cte,descripcion,cve_pago,cve_cuenta_ori,cuenta_origen,cve_cuenta_dest,cuenta_destino,banco_destino,referencia1,
												 referencia2,convenio,importe,ref_cobranza,importe_iva,tipo_spei,concepto,fecha_inicio,cve_final,no_repeticiones,
												 fecha_fin,cve_programa,tipo_diaria,cada_x_dias,cada_x_semanas,dias_semana,tipo_mensual,dia_x_del_mes,cada_x_meses,cve_ocurre,
												 cve_dia,cve_canal,cve_notifica,ben_email,ben_cve_compania,ben_celular,cve_notifica_emi,emi_email,emi_cve_compania,emi_celular,
												 mensaje,cve_estado,user_insert,fecha_insert,user_cancela,fecha_cancela,canal_cancela )
				VALUES(vcCvePagoProg,pNumCte,pDescricion,pCvePago,pCveCtaOri,pNumCtaOri,pCveCtaDest,pNumCtaDest,pBancoDest,pRef1,
												 pRef2,pcConvenio,pImporte,pcRefCobranza,pmImporteIva,piTipoSpei,pConcepto,pFechaInicio,pCveFinal,pNumRepeteciones,
												 pFechaFin,pCvePrograma,'00',0,0,'',pTipoMensual,0,pCadaXMes,pCveOcurre,
												 pCveDia,pCveCanal,pCveNotifica,pBenEmail,pBenCveCompania,pBenCelular,pCveNotificaEmi,pEmiEmail,pEmiCveCompania,pEmiCelular,
												 pMensaje,'01',pUserInsert,CURRENT::DATE,'','','');
				LET vdFechaMovil = pFechaInicio;
				LET vdFechaDisponible1 = vdFechaMovil;
				LET vcNumAplica = 0;
				LET viDiaMes   = DAY(vdFechaMovil);
				WHILE vcNumAplica < pNumRepeteciones 
					IF viPasoPrimerMes = 'S' THEN
						LET vdFechaMovil = month (vdFechaMovil) || '/01/' || year(vdFechaMovil);
					END IF;
					EXECUTE FUNCTION bdiprog:sp_obtenerOcurrenciaDia(pCveOcurre,pCveDia,vdFechaMovil) INTO vcCodFechas,vdFechaDisponible1;
					IF vdFechaDisponible1 >= vdFechaMovil  THEN
						IF vcCodFechas = '00000' THEN
							LET vcNumAplica = vcNumAplica +1;
							LET iDia = DAY(vdFechaDisponible1);
							LET iMes = MONTH (vdFechaDisponible1);
							IF (iDia=25 AND iMes=12) OR (iDia=1 AND iMes=1) THEN
								LET vdFechaProgramada = vdFechaDisponible1 + 1;
							ELSE 
								LET vdFechaProgramada = vdFechaDisponible1;
							END IF;
							SET LOCK MODE TO WAIT 10;
							INSERT INTO bdiprog:pp_pagospend(cve_pagoprog, consecutivo, fecha_prog, estado, fecha_aplic, folio_suc, user_insert, fecha_insert, user_cancela, fecha_cancela, canal_cancela, cve_rechazo) 
							VALUES(vcCvePagoProg, vcNumAplica, vdFechaProgramada, '03', '', '',pUserInsert , CURRENT::DATE, '', '', '', '00');
						END IF;
					END IF;  
					LET viPasoPrimerMes = 'S';
					IF pNumRepeteciones = vcNumAplica THEN
					ELSE
						IF viDiaMes > 28 THEN
							LET vdFechaMovil2 = month (vdFechaMovil) || '/01/' || year(vdFechaMovil);
							LET vdFechaMovil  = vdFechaMovil2 + pCadaXMes UNITS MONTH;
							EXECUTE FUNCTION bdiprog:sp_obtenerFechaValida(year(vdFechaMovil), month (vdFechaMovil) ,viDiaMes) INTO vcCodFechas,vdFechaDisponible1;
							IF vcCodFechas = '00000' THEN
								IF DAY(vdFechaDisponible1) = 1 THEN
									LET vdFechaMovil = vdFechaDisponible1 -1;
								ELSE
									LET vdFechaMovil = vdFechaDisponible1;
								END IF;
							END IF;
						ELSE
							LET vdFechaMovil  = vdFechaMovil + pCadaXMes UNITS MONTH;
						END IF;
					END IF;	

				END WHILE;
				IF vdFechaDisponible1 > vdFechaMaximaPermitida THEN
					if vtransaccion = 1 then   ROLLBACK WORK;  BEGIN WORK;  else ROLLBACK WORK;	end if
					SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '66';  
					RETURN vcCodRet,vcMensaje; 																 
				END IF;
				IF vcNumAplica = 0 THEN
					if vtransaccion = 1 then   ROLLBACK WORK;  BEGIN WORK;  else ROLLBACK WORK;	end if
					SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '65';  
					RETURN vcCodRet,vcMensaje;
				END IF;
			END IF;
		END IF;
	END IF
		-- PROGRAMACION POR FECHA.
	IF pCveFinal = '02' THEN
		-- TIPO DIARIA - POR FECHA.
		IF 	pCvePrograma = '01' THEN
			--IF pTipoDiaria = '01' THEN
				SET LOCK MODE TO WAIT 10;
				INSERT INTO bdiprog:pp_pagoprog (cve_pagoprog,num_cte,descripcion,cve_pago,cve_cuenta_ori,cuenta_origen,cve_cuenta_dest,cuenta_destino,banco_destino,referencia1,
										 referencia2,convenio,importe,ref_cobranza,importe_iva,tipo_spei,concepto,fecha_inicio,cve_final,no_repeticiones,
										 fecha_fin,cve_programa,tipo_diaria,cada_x_dias,cada_x_semanas,dias_semana,tipo_mensual,dia_x_del_mes,cada_x_meses,cve_ocurre,
										 cve_dia,cve_canal,cve_notifica,ben_email,ben_cve_compania,ben_celular,cve_notifica_emi,emi_email,emi_cve_compania,emi_celular,
										 mensaje,cve_estado,user_insert,fecha_insert,user_cancela,fecha_cancela,canal_cancela )
				VALUES(vcCvePagoProg,pNumCte,pDescricion,pCvePago,pCveCtaOri,pNumCtaOri,pCveCtaDest,pNumCtaDest,pBancoDest,pRef1,
										 pRef2,pcConvenio,pImporte,pcRefCobranza,pmImporteIva,piTipoSpei,pConcepto,pFechaInicio,pCveFinal,0,
										 pFechaFin,pCvePrograma,pTipoDiaria,pCadaXDias,0,'','00',0,0,'00',
										 '00',pCveCanal,pCveNotifica,pBenEmail,pBenCveCompania,pBenCelular,pCveNotificaEmi,pEmiEmail,pEmiCveCompania,pEmiCelular,
										 pMensaje,'01',pUserInsert,CURRENT::DATE,'','','');

				LET I = 0;
				IF pTipoDiaria = '01' THEN 
			
					WHILE  (vdFechaInicio <= pFechaFin  )
						LET I = I + 1;
						LET iDia = DAY(vdFechaInicio);
						LET iMes = MONTH (vdFechaInicio);
						IF (iDia=25 AND iMes=12) OR (iDia=1 AND iMes=1) THEN
							LET vdFechaProgramada = vdFechaInicio + 1;
							IF pCadaXDias= 1 THEN
								LET vdFechaInicio = vdFechaInicio + 1;
							END IF;
						ELSE 
							LET vdFechaProgramada = vdFechaInicio;
						END IF;
						
						SET LOCK MODE TO WAIT 10;
						INSERT INTO bdiprog:pp_pagospend(cve_pagoprog, consecutivo, fecha_prog, estado, fecha_aplic, folio_suc, user_insert, fecha_insert, user_cancela, fecha_cancela, canal_cancela, cve_rechazo) 
						VALUES(vcCvePagoProg, I, vdFechaProgramada, '03', '', '',pUserInsert , CURRENT::DATE, '', '', '', '00');
						LET vdFechaInicio = vdFechaInicio + pCadaXDias;
					END WHILE;
				
					IF I = 0 THEN
						if vtransaccion = 1 then   ROLLBACK WORK;  BEGIN WORK;  else ROLLBACK WORK;	end if
						SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '65';  
						RETURN vcCodRet,vcMensaje;
					END IF;
				END IF;
				IF pTipoDiaria = '02' THEN 
					LET vdFechaMovil = pFechaInicio;
					WHILE vdFechaMovil <= pFechaFin
						LET vdFechaMovil2 = vdFechaMovil;
						EXECUTE FUNCTION bdinteg:splvalfecha('001', vdFechaMovil, 0 ) INTO vcCodPais,vdDiaHabil;
						IF vdDiaHabil <= pFechaFin THEN
							LET I = I + 1;
							LET iDia = DAY(vdDiaHabil);
							LET iMes = MONTH (vdDiaHabil);
							IF (iDia=25 AND iMes=12) OR (iDia=1 AND iMes=1) THEN
								LET vdFechaProgramada = vdDiaHabil + 1;
							ELSE 
								LET vdFechaProgramada = vdDiaHabil;
							END IF;
							
							SET LOCK MODE TO WAIT 10;
							INSERT INTO bdiprog:pp_pagospend(cve_pagoprog, consecutivo, fecha_prog, estado, fecha_aplic, folio_suc, user_insert, fecha_insert, user_cancela, fecha_cancela, canal_cancela, cve_rechazo) 
							VALUES(vcCvePagoProg, I, vdFechaProgramada, '03', '', '',pUserInsert , CURRENT::DATE, '', '', '', '00');
						END IF;
						IF vdFechaMovil2 = vdDiaHabil THEN
							LET vdFechaMovil = vdFechaMovil + 1;
						ELSE
							LET vdFechaMovil = vdDiaHabil + 1;
						END IF;
					END WHILE;
					IF I = 0 THEN
						if vtransaccion = 1 then   ROLLBACK WORK;  BEGIN WORK;  else ROLLBACK WORK;	end if
						SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '65';
						RETURN vcCodRet,vcMensaje;
					END IF;
				END IF;
			--END IF;
		END IF;		
		-- TIPO SEMANAL -  POR FECHA.
		IF pCvePrograma = '02' THEN
			-- Se realiza registro del pago programado.
			SET LOCK MODE TO WAIT 10;
			INSERT INTO bdiprog:pp_pagoprog (cve_pagoprog,num_cte,descripcion,cve_pago,cve_cuenta_ori,cuenta_origen,cve_cuenta_dest,cuenta_destino,banco_destino,referencia1,
												 referencia2,convenio,importe,ref_cobranza,importe_iva,tipo_spei,concepto,fecha_inicio,cve_final,no_repeticiones,
												 fecha_fin,cve_programa,tipo_diaria,cada_x_dias,cada_x_semanas,dias_semana,tipo_mensual,dia_x_del_mes,cada_x_meses,cve_ocurre,
												 cve_dia,cve_canal,cve_notifica,ben_email,ben_cve_compania,ben_celular,cve_notifica_emi,emi_email,emi_cve_compania,emi_celular,
												 mensaje,cve_estado,user_insert,fecha_insert,user_cancela,fecha_cancela,canal_cancela )
			VALUES(vcCvePagoProg,pNumCte,pDescricion,pCvePago,pCveCtaOri,pNumCtaOri,pCveCtaDest,pNumCtaDest,pBancoDest,pRef1,
												 pRef2,pcConvenio,pImporte,pcRefCobranza,pmImporteIva,piTipoSpei,pConcepto,pFechaInicio,pCveFinal,0,
												 pFechaFin,pCvePrograma,'00',0,pCadaXSemanas,pDiasSemana,'00',0,0,'00',
												 '00',pCveCanal,pCveNotifica,pBenEmail,pBenCveCompania,pBenCelular,pCveNotificaEmi,pEmiEmail,pEmiCveCompania,pEmiCelular,
												 pMensaje,'01',pUserInsert,CURRENT::DATE,'','','');
			   
			-- Generar registros para pagos pendientes.
			LET I = 0;
			LET vdFechaMovil = pFechaInicio;
			WHILE ( vdFechaMovil <= pFechaFin )
				EXECUTE FUNCTION bdiprog:sp_EsPosibleAplicarPagoEnDiaSemana(vdFechaMovil, pDiasSemana ) INTO vcAplicaPago;
				LET viEsDiaSemana = WEEKDAY(vdFechaMovil);
				IF vcAplicaPago = '00000' THEN
					LET I = I + 1;
					LET iDia = DAY(vdFechaMovil);
					LET iMes = MONTH (vdFechaMovil);
					IF (iDia=25 AND iMes=12) OR (iDia=1 AND iMes=1) THEN
						LET vdFechaProgramada = vdFechaMovil + 1;
						LET vdFechaMovil= vdFechaMovil + 1;
					ELSE 
						LET vdFechaProgramada = vdFechaMovil;
					END IF;
					SET LOCK MODE TO WAIT 10;
					INSERT INTO bdiprog:pp_pagospend(cve_pagoprog, consecutivo, fecha_prog, estado, fecha_aplic, folio_suc, user_insert, fecha_insert, user_cancela, fecha_cancela, canal_cancela, cve_rechazo) 
					VALUES(vcCvePagoProg, I, vdFechaProgramada, '03', '', '',pUserInsert , CURRENT::DATE, '', '', '', '00');
				END IF;
				-- CALCULAR EL CADA X SEMANAS CUANDO ES DOMINGO
				IF viEsDiaSemana = 0 and vdFechaMovil < pFechaFin THEN
					LET vdFechaMovil = vdFechaMovil + (7* (pCadaXSemanas - 1));

				END IF; 
				--CALCULAR EL SIGUIENTE DIA.
				LET vdFechaMovil = vdFechaMovil + 1;
			END WHILE;
			IF I = 0 THEN
				if vtransaccion = 1 then   ROLLBACK WORK;  BEGIN WORK;  else ROLLBACK WORK;	end if
				SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '65';  
				RETURN vcCodRet,vcMensaje;
			END IF;
		--TIPO MESUAL -  POR FECHA.
		ELIF pCvePrograma = '03' THEN
			IF pTipoMensual = '01' THEN
				SET LOCK MODE TO WAIT 10;
				INSERT INTO bdiprog:pp_pagoprog (cve_pagoprog,num_cte,descripcion,cve_pago,cve_cuenta_ori,cuenta_origen,cve_cuenta_dest,cuenta_destino,banco_destino,referencia1,
												 referencia2,convenio,importe,ref_cobranza,importe_iva,tipo_spei,concepto,fecha_inicio,cve_final,no_repeticiones,
												 fecha_fin,cve_programa,tipo_diaria,cada_x_dias,cada_x_semanas,dias_semana,tipo_mensual,dia_x_del_mes,cada_x_meses,cve_ocurre,
												 cve_dia,cve_canal,cve_notifica,ben_email,ben_cve_compania,ben_celular,cve_notifica_emi,emi_email,emi_cve_compania,emi_celular,
												 mensaje,cve_estado,user_insert,fecha_insert,user_cancela,fecha_cancela,canal_cancela )
				VALUES(vcCvePagoProg,pNumCte,pDescricion,pCvePago,pCveCtaOri,pNumCtaOri,pCveCtaDest,pNumCtaDest,pBancoDest,pRef1,
												 pRef2,pcConvenio,pImporte,pcRefCobranza,pmImporteIva,piTipoSpei,pConcepto,pFechaInicio,pCveFinal,0,
												 pFechaFin,pCvePrograma,'00',0,0,'',pTipoMensual,pDiaXMes,pCadaXMes,'00',
												 '00',pCveCanal,pCveNotifica,pBenEmail,pBenCveCompania,pBenCelular,pCveNotificaEmi,pEmiEmail,pEmiCveCompania,pEmiCelular,
												 pMensaje,'01',pUserInsert,CURRENT::DATE,'','','');
				LET I = 0;
				LET vdFechaMovil = pFechaInicio; 
				LET viDiaMes   = DAY(vdFechaMovil);
				WHILE vdFechaMovil <= pFechaFin 
					IF viPasoPrimerMes = 'S' THEN
						LET vdFechaMovil = month (vdFechaMovil) || '/01/' || year(vdFechaMovil);
					END IF;						
					EXECUTE FUNCTION bdiprog:sp_obtenerFechaValida(year(vdFechaMovil),month(vdFechaMovil),pDiaXMes) INTO vcCodFechas,vdFechaDisponible1;
					IF vdFechaDisponible1 >= vdFechaMovil and vdFechaDisponible1 <= pFechaFin THEN
						IF vcCodFechas = '00000' THEN
							LET I = I + 1;
							LET iDia = DAY(vdFechaDisponible1);
							LET iMes = MONTH (vdFechaDisponible1);
							IF (iDia=25 AND iMes=12) OR (iDia=1 AND iMes=1) THEN
								LET vdFechaProgramada = vdFechaDisponible1 + 1;
							ELSE 
								LET vdFechaProgramada = vdFechaDisponible1;
							END IF;
							SET LOCK MODE TO WAIT 10;
							INSERT INTO bdiprog:pp_pagospend(cve_pagoprog, consecutivo, fecha_prog, estado, fecha_aplic, folio_suc, user_insert, fecha_insert, user_cancela, fecha_cancela, canal_cancela, cve_rechazo) 
							VALUES(vcCvePagoProg, I, vdFechaProgramada, '03', '', '',pUserInsert , CURRENT::DATE, '', '', '', '00');
						END IF;
					END IF;

					LET viPasoPrimerMes = 'S';
					IF viDiaMes > 28 THEN
						LET vdFechaMovil2 = month (vdFechaMovil) || '/01/' || year(vdFechaMovil);
						LET vdFechaMovil  = vdFechaMovil2 + pCadaXMes UNITS MONTH;
					EXECUTE FUNCTION bdiprog:sp_obtenerFechaValida(year(vdFechaMovil), month (vdFechaMovil) ,viDiaMes) INTO vcCodFechas,vdFechaDisponible1;
					IF vcCodFechas = '00000' THEN
							IF DAY(vdFechaDisponible1) = 1 THEN
								LET vdFechaMovil = vdFechaDisponible1 -1;
							ELSE
								LET vdFechaMovil = vdFechaDisponible1;
							END IF;
						END IF;
					ELSE
						LET vdFechaMovil  = vdFechaMovil + pCadaXMes UNITS MONTH;
					END IF;
				END WHILE;
				IF I = 0 THEN
					if vtransaccion = 1 then   ROLLBACK WORK;  BEGIN WORK;  else ROLLBACK WORK;	end if
					SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '65';
					RETURN vcCodRet,vcMensaje;
				END IF;
			END IF;
			IF pTipoMensual = '02' THEN
				SET LOCK MODE TO WAIT 10;
				INSERT INTO bdiprog:pp_pagoprog (cve_pagoprog,num_cte,descripcion,cve_pago,cve_cuenta_ori,cuenta_origen,cve_cuenta_dest,cuenta_destino,banco_destino,referencia1,
												 referencia2,convenio,importe,ref_cobranza,importe_iva,tipo_spei,concepto,fecha_inicio,cve_final,no_repeticiones,
												 fecha_fin,cve_programa,tipo_diaria,cada_x_dias,cada_x_semanas,dias_semana,tipo_mensual,dia_x_del_mes,cada_x_meses,cve_ocurre,
												 cve_dia,cve_canal,cve_notifica,ben_email,ben_cve_compania,ben_celular,cve_notifica_emi,emi_email,emi_cve_compania,emi_celular,
												 mensaje,cve_estado,user_insert,fecha_insert,user_cancela,fecha_cancela,canal_cancela )
				VALUES(vcCvePagoProg,pNumCte,pDescricion,pCvePago,pCveCtaOri,pNumCtaOri,pCveCtaDest,pNumCtaDest,pBancoDest,pRef1,
												 pRef2,pcConvenio,pImporte,pcRefCobranza,pmImporteIva,piTipoSpei,pConcepto,pFechaInicio,pCveFinal,0,
												 pFechaFin,pCvePrograma,'00',0,0,'',pTipoMensual,0,pCadaXMes,pCveOcurre,
												 pCveDia,pCveCanal,pCveNotifica,pBenEmail,pBenCveCompania,pBenCelular,pCveNotificaEmi,pEmiEmail,pEmiCveCompania,pEmiCelular,
												 pMensaje,'01',pUserInsert,CURRENT::DATE,'','','');


				LET vdFechaMovil = pFechaInicio;
				LET vdFechaDisponible1 = vdFechaMovil;
				LET vcNumAplica = 0;
				LET viDiaMes   = DAY(vdFechaMovil);
				WHILE vdFechaMovil <= pFechaFin 
					IF viPasoPrimerMes = 'S' THEN
						LET vdFechaMovil = month (vdFechaMovil) || '/01/' || year(vdFechaMovil);
					END IF;
						EXECUTE FUNCTION bdiprog:sp_obtenerOcurrenciaDia(pCveOcurre,pCveDia,vdFechaMovil) INTO vcCodFechas,vdFechaDisponible1;
						IF vdFechaDisponible1 >= vdFechaMovil and vdFechaDisponible1 <= pFechaFin THEN
							IF vcCodFechas = '00000' THEN
								LET vcNumAplica = vcNumAplica +1;
								LET iDia = DAY(vdFechaDisponible1);
								LET iMes = MONTH (vdFechaDisponible1);
								IF (iDia=25 AND iMes=12) OR (iDia=1 AND iMes=1) THEN
									LET vdFechaProgramada = vdFechaDisponible1 + 1;
								ELSE 
									LET vdFechaProgramada = vdFechaDisponible1;
								END IF;
								SET LOCK MODE TO WAIT 10;
								INSERT INTO bdiprog:pp_pagospend(cve_pagoprog, consecutivo, fecha_prog, estado, fecha_aplic, folio_suc, user_insert, fecha_insert, user_cancela, fecha_cancela, canal_cancela, cve_rechazo) 
								VALUES(vcCvePagoProg, vcNumAplica, vdFechaProgramada, '03', '', '',pUserInsert , CURRENT::DATE, '', '', '', '00');
							END IF;
						END IF;  
					LET viPasoPrimerMes = 'S';
					IF viDiaMes > 28 THEN
						LET vdFechaMovil2 = month (vdFechaMovil) || '/01/' || year(vdFechaMovil);
						LET vdFechaMovil  = vdFechaMovil2 + pCadaXMes UNITS MONTH;	
						EXECUTE FUNCTION bdiprog:sp_obtenerFechaValida(year(vdFechaMovil), month (vdFechaMovil) ,viDiaMes) INTO vcCodFechas,vdFechaDisponible1;
						IF vcCodFechas = '00000' THEN
							IF DAY(vdFechaDisponible1) = 1 THEN
								LET vdFechaMovil = vdFechaDisponible1 -1;
							ELSE
								LET vdFechaMovil = vdFechaDisponible1;
							END IF;
						END IF;
					ELSE
						LET vdFechaMovil  = vdFechaMovil + pCadaXMes UNITS MONTH;
					END IF;
				 
				END WHILE;
				IF vcNumAplica = 0 THEN
					if vtransaccion = 1 then   ROLLBACK WORK;  BEGIN WORK;  else ROLLBACK WORK;	end if
					SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '65';  
					RETURN vcCodRet,vcMensaje;
				END IF;
			END IF;
		END IF;
	END IF; -- fin if pCveFinal = '01'.
	if vtransaccion = 1 then   COMMIT WORK;  BEGIN WORK;   else   COMMIT WORK;   end if;
	SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '00';  
	RETURN vcCodRet,vcMensaje; 
	
END PROCEDURE;
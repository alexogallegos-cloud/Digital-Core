CREATE PROCEDURE "informix".sp_validaprogtraspasosctasinterbancariosdos(p_sCve_pagoprog char(10), p_snum_cte Char(20), p_sDescripcion Char(20), p_scve_pago Char(2), p_scve_cuenta_ori Char(2), p_scuenta_origen Char(20), p_scve_cuenta_dest Char(2), p_scuenta_destino Char(20), p_sbanco_destino Char(3),
	p_sreferencia1 Char(40), p_sreferencia2 Char(40), p_sconvenio Char(5), p_mimporte money(16,2), p_sref_cobranza Char(40), p_mimporte_iva money(16,2), p_itipo_spei integer, p_sconcepto Char(60), p_dfecha_inicio date, p_scve_final Char(2),
	p_ino_repeticiones integer, p_dfecha_fin date, p_scve_programa Char(2), p_stipo_diaria Char(2), p_icada_x_dias integer,  p_icada_x_semanas integer, p_sdias_semana Char(7), p_stipo_mensual Char(2), p_idia_x_del_mes integer, p_icada_x_meses integer,
	p_scve_ocurre Char(2), p_scve_dia Char(2), p_scve_canal Char(2), p_scve_notifica Char(2), p_sben_email Char(100), p_sben_cve_compania Char(2), p_sben_celular Char(10), p_scve_notifica_emi Char(2), p_semi_email Char(100), p_semi_cve_compania Char(2),
	p_semi_celular Char(10), p_smensaje Char(100), p_scve_estado Char(2), p_suser_insert Char(8), p_dfecha_insert date, p_suser_cancela Char(8), p_dfecha_cancela date,p_scanal_cancela Char(2),pFechaMaxima DATE)
	RETURNING CHAR(5), CHAR(250);
	---**********************************************************
-- Realizo   :Alejandro Osuna
--Solicito : Aymme Osuna
 -- Proyecto :  Pagos Programados
-- Actividad : Validar los datos necesarios que se necesitan para dar de alta una programaciÃ³n de Traspasos a Cuentas Interbancarios(SPEI).
 -- Fecha     :06 de  Novimebre  de 2008
 --Modifico: Alejandro Osuna Fecha: Enero 2009 Razon: se parte el sp en dos partes debido a que excedio el numero de caracteres, se valida la clave final, la clave de compaÃ±ia <> 00, el numero de celular acepte solo numeros
-- Se valida que el campo tipo diario exita en la tabla pp_tpdiaria, se validan el tipo de pago mensual
--Fecha : 05 de marzo 2009
--Modifico: Alejandro Osuna
--se quitaron los datos de insercion inecesarios
--Fecha : 07 de diciembre 2009
--Modifico: Alejandro Osuna
--Se modifico para realizar la validacion de fecha con la tabla de si_feriado_banca despues de realizar la validacion de si_feriado
DEFINE v_sCodRet CHAR(5);
DEFINE v_sMensajeRet CHAR(250);
DEFINE sql_err  SMALLINT;
DEFINE inicio integer;
DEFINE v_spagoprog CHAR(10);
DEFINE v_sMaxClave integer;
DEFINE v_sCodSpFecha CHAR(5);
DEFINE v_sCodSpOcurren CHAR(5);
DEFINE v_dFechaHabil DATE;
DEFINE v_dFechaActiva date;
DEFINE v_dFechaActiva2 date;
DEFINE v_dFechaLimite DATE;
DEFINE v_dFechaActivaMes DATE;
DEFINE v_iAplicaDia integer;
DEFINE v_sMesPrimero CHAR(1);
DEFINE v_iActNum INTEGER;
DEFINE v_iDiaMes INTEGER;
DEFINE v_sError CHAR(1);
DEFINE vtransaccion integer;
DEFINE v_d_Fech_prox DATE;
DEFINE v_ciclo_fec char(1);
DEFINE v_valida INTEGER;

LET v_sCodRet = '';
LET v_sMensajeRet = '';
LET v_spagoprog = '';
LET v_sCodSpFecha = '';
LET v_dFechaActiva = p_dfecha_inicio;
LET v_sMesPrimero = 'N';
LET v_sCodSpOcurren = '';
LET v_sError = '0';
LET vtransaccion = 0;
LET v_iAplicaDia= 0;
LET v_iActNum = 0;
LET v_ciclo_fec = 'N';
LET v_iDiaMes =0;
LET v_sMaxClave = 0;
LEt v_dFechaHabil ='';
LET v_dFechaActiva2 ='';
LET v_dFechaLimite ='';
LET v_dFechaActivaMes = '';
LET v_d_Fech_prox = '';
LET v_valida = 0;

--SET DEBUG FILE TO "/tmp/SP_ValidaProgTraspasosCtasInterbancariosdos.out";
--TRACE ON;

BEGIN
	ON EXCEPTION SET  sql_err
		IF sql_err <> 0 THEN
			--if vtransaccion = 1 then ROLLBACK WORK; BEGIN WORK; else ROLLBACK WORK;
		--nd if
			let v_sCodRet =  sql_err;
			let v_sMensajeRet  =  "Programacion Interbancaria no Realizada";
			RETURN v_sCodRet, v_sMensajeRet;
		END IF
	END EXCEPTION

on exception in (-271)
	--if vtransaccion = 1 then ROLLBACK WORK; BEGIN WORK; else ROLLBACK WORK; end if
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '230';
		RETURN v_sCodRet, v_sMensajeRet;
end exception;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 10;



	LET v_dFechaLimite = pFechaMaxima;
	--SET ISOLATION TO DIRTY READ;
        IF p_scve_pago = '03' THEN
		/*
        IF EXISTS(SELECT num_cte FROM bdiprog:pp_pagoprog WHERE cve_pagoprog LIKE '03%') THEN
            SELECT MAX(cve_pagoprog) INTO v_sMaxClave FROM bdiprog:pp_pagoprog  WHERE cve_pagoprog LIKE '03%';
            LET v_sMaxClave = v_sMaxClave + 1;
            LET v_spagoprog  = '0' || v_sMaxClave;
		*/
        LET v_valida = 0;
	   -- SET ISOLATION TO DIRTY READ;
	    /*
        SELECT COUNT(*) 
	    INTO   v_valida
		FROM bdiprog:pp_pagoprog 
		WHERE cve_pagoprog LIKE '03%';
		
		IF v_valida > 0 THEN 
		   SELECT MAX(cve_pagoprog) INTO v_sMaxClave FROM bdiprog:pp_pagoprog  WHERE cve_pagoprog LIKE '03%';
           LET v_sMaxClave = v_sMaxClave + 1;
           LET v_spagoprog  = '0' || v_sMaxClave;
        ELSE
            LET v_spagoprog = p_scve_pago || '00000001';
        END IF;
        */
        SELECT NVL(MAX(cve_pagoprog),'0') INTO v_sMaxClave FROM bdiprog:pp_pagoprog  WHERE cve_pagoprog LIKE '03%';
        IF v_sMaxClave <> '0' THEN 
            LET v_sMaxClave = v_sMaxClave + 1;
            LET v_spagoprog  = '0' || v_sMaxClave;
        ELSE
            LET v_spagoprog = p_scve_pago || '00000001';
        END IF;
        ELSE
        IF p_scve_pago = '07' THEN
		    /*
            IF EXISTS(SELECT num_cte FROM bdiprog:pp_pagoprog WHERE cve_pagoprog LIKE '07%') THEN
                SET ISOLATION TO DIRTY READ;
                SELECT MAX(cve_pagoprog) INTO v_sMaxClave FROM bdiprog:pp_pagoprog  WHERE cve_pagoprog LIKE '07%';
                LET v_sMaxClave = v_sMaxClave + 1;
                LET v_spagoprog  = '0' || v_sMaxClave;
			*/
			LET v_valida = 0;
	        -- SET ISOLATION TO DIRTY READ;
            /*
	        SELECT COUNT(*) 
	        INTO   v_valida
			FROM bdiprog:pp_pagoprog 
			WHERE cve_pagoprog LIKE '07%'; 
			
			IF v_valida > 0 THEN 
                --  SET ISOLATION TO DIRTY READ;
                SELECT MAX(cve_pagoprog) INTO v_sMaxClave FROM bdiprog:pp_pagoprog  WHERE cve_pagoprog LIKE '07%';
                ---SELECT MAX(cve_pagoprog) INTO v_sMaxClave FROM bdiprog:pp_pagoprog  WHERE cve_pago = '07'; 
                LET v_sMaxClave = v_sMaxClave + 1;
                LET v_spagoprog  = '0' || v_sMaxClave;
            ELSE
                LET v_spagoprog = p_scve_pago || '00000001';
            END IF;
            */
            SELECT NVL(MAX(cve_pagoprog),'0') INTO v_sMaxClave FROM bdiprog:pp_pagoprog  WHERE cve_pagoprog LIKE '07%';
            IF v_sMaxClave <> '0' THEN
                LET v_sMaxClave = v_sMaxClave + 1;
                LET v_spagoprog  = '0' || v_sMaxClave;
            ELSE
                LET v_spagoprog = p_scve_pago || '00000001';
            END IF;
         END IF;
    END IF;
	LET p_sCve_pagoprog = v_spagoprog;

	IF p_scve_programa = '03' THEN
		LET inicio = 0;
		IF p_scve_final = '01' THEN
			IF p_ino_repeticiones <= 0 THEN
			--	if vtransaccion = 1 then   rollback;  BEGIN WORK; 	else   rollback; end if;
				SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '174';
				RETURN v_sCodRet, v_sMensajeRet;
			END IF;

			IF p_stipo_mensual = '01' THEN

				LET p_icada_x_dias = 0;
				LET p_stipo_diaria = '00';
				LET p_icada_x_semanas = 0;
				LET p_sdias_semana = '';
				LET p_scve_ocurre = '00';
				LET p_scve_dia = '00';
				--EXECUTE FUNCTION bdinteg:splvalfecha('001', p_dfecha_inicio, 0 ) INTO v_sCodSpFecha,p_dfecha_inicio;
				--SET LOCK MODE TO WAIT 10;
				INSERT INTO bdiprog:pp_pagoprog(cve_pagoprog,num_cte,descripcion,cve_pago,cve_cuenta_ori,cuenta_origen,cve_cuenta_dest,cuenta_destino,banco_destino,
					referencia1,referencia2,convenio,importe,ref_cobranza,importe_iva,tipo_spei,concepto,fecha_inicio,cve_final,no_repeticiones,
					fecha_fin,cve_programa,tipo_diaria,cada_x_dias,cada_x_semanas,dias_semana,tipo_mensual,dia_x_del_mes,cada_x_meses,cve_ocurre,
					cve_dia,cve_canal,cve_notifica,ben_email,ben_cve_compania,ben_celular,cve_notifica_emi,emi_email,emi_cve_compania,emi_celular,
					mensaje,cve_estado,user_insert,fecha_insert,user_cancela,fecha_cancela,canal_cancela)
				VALUES(p_sCve_pagoprog,p_snum_cte, p_sdescripcion,p_scve_pago,p_scve_cuenta_ori,p_scuenta_origen,p_scve_cuenta_dest,p_scuenta_destino,
					p_sbanco_destino,p_sreferencia1,p_sreferencia2,p_sconvenio,p_mimporte,p_sref_cobranza,p_mimporte_iva,p_itipo_spei,p_sconcepto,
					p_dfecha_inicio,p_scve_final,p_ino_repeticiones,p_dfecha_fin,p_scve_programa,p_stipo_diaria,p_icada_x_dias,p_icada_x_semanas,
					p_sdias_semana,p_stipo_mensual,p_idia_x_del_mes,p_icada_x_meses,p_scve_ocurre,p_scve_dia,p_scve_canal,p_scve_notifica,p_sben_email ,
					p_sben_cve_compania,p_sben_celular,p_scve_notifica_emi,p_semi_email,p_semi_cve_compania,p_semi_celular,p_smensaje, "01",
					p_suser_insert,current year to fraction(3)::DATE, "", "", "");

				LET v_dFechaHabil = p_dfecha_inicio;
				LET v_iDiaMes = DAY(v_dFechaHabil);

				--EXECUTE FUNCTION bdinteg:splvalfecha('001', v_dFechaActiva, 0 ) INTO v_sCodSpFecha,v_dFechaHabil;
				WHILE ( inicio < p_ino_repeticiones)
					IF v_sMesPrimero = 'S' THEN
							LET v_dFechaHabil = MONTH(v_dFechaHabil) || '/01/' || YEAR(v_dFechaHabil);
					END IF;
					EXECUTE FUNCTION bdiprog:sp_obtenerFechaValida(year(v_dFechaHabil),month(v_dFechaHabil),p_idia_x_del_mes) INTO v_sCodSpFecha,v_dFechaActivaMes;
					--EXECUTE FUNCTION bdinteg:splvalfecha('001', v_dFechaActivaMes, 0 ) INTO v_sCodSpFecha,v_dFechaActivaMes;
					WHILE (v_ciclo_fec = 'N')
						EXECUTE FUNCTION bdinteg:splvalfecha('001', v_dFechaActivaMes, 0 ) INTO v_sCodSpFecha,v_dFechaActivaMes;
						SELECT fecha_prox INTO v_d_Fech_prox FROM bdinteg:si_feriado_banca WHERE empresa = '001' AND fecha = v_dFechaActivaMes;
						IF (v_d_Fech_prox IS NULL) OR (v_d_Fech_prox = "") THEN
							LET v_dFechaActivaMes = v_dFechaActivaMes;
							LET v_ciclo_fec = 'S';
						ELSE
							LET v_dFechaActivaMes = v_d_Fech_prox;
							--LET v_dFechaActivaMes = v_d_Fech_prox + 1;
							
						END IF;
					END WHILE;
					LET v_ciclo_fec = 'N';
					IF v_dFechaActivaMes >= v_dFechaHabil THEN
						LET inicio = inicio + 1;
						LET v_iActNum = v_iActNum +1;
						LET v_sError = '1';
						--SET LOCK MODE TO WAIT 10;
						INSERT INTO bdiprog:pp_pagospend(cve_pagoprog, consecutivo, fecha_prog, estado, fecha_aplic, folio_suc, user_insert, fecha_insert, user_cancela, fecha_cancela, canal_cancela, cve_rechazo)
						VALUES(p_sCve_pagoprog, inicio, v_dFechaActivaMes, '03', '', '',p_suser_insert , CURRENT::DATE, '', '', '', '00');
					END IF;
					LET v_sMesPrimero = 'S';
					LET v_iDiaMes = DAY(v_dFechaHabil);
					IF ( inicio = p_ino_repeticiones) THEN
					ELSE
						IF v_iDiaMes >= '28' THEN
							LET v_dFechaActiva2 = MONTH(v_dFechaHabil) || '/01/' || YEAR(v_dFechaHabil);
							LET v_dFechaHabil = v_dFechaActiva2 + p_icada_x_meses UNITS MONTH;
							EXECUTE FUNCTION bdiprog:sp_obtenerFechaValida(year(v_dFechaHabil),month(v_dFechaHabil),v_iDiaMes) INTO v_sCodSpFecha,v_dFechaActivaMes;
							IF v_sCodSpFecha = '00000' THEN
								IF DAY(v_dFechaActivaMes) = 1 THEN
									LET v_dFechaHabil = v_dFechaActivaMes -1;
								ELSE
									LET v_dFechaHabil = v_dFechaActivaMes;
								END IF;
							END IF;
						ELSE
							LET v_dFechaHabil = v_dFechaHabil + p_icada_x_meses UNITS MONTH;
						END IF;
					END IF;
				END WHILE;
				IF  (v_dFechaActivaMes > v_dFechaLimite  ) THEN
					--	if vtransaccion = 1 then   rollback;  BEGIN WORK; 	else   rollback; end if;
					SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '66';
					RETURN v_sCodRet, v_sMensajeRet;
				END IF;
				LET v_sError = '1';
			END IF;
			IF p_stipo_mensual = '02' THEN

					LET p_icada_x_dias = 0;
					LET p_icada_x_semanas = 0;
					LET p_sdias_semana = '';
					LET p_stipo_diaria = '00';
					LET p_idia_x_del_mes = 0;

					--EXECUTE FUNCTION bdinteg:splvalfecha('001', p_dfecha_inicio, 0 ) INTO v_sCodSpFecha,p_dfecha_inicio;
					--SET LOCK MODE TO WAIT 10;
					INSERT INTO bdiprog:pp_pagoprog(cve_pagoprog,num_cte,descripcion,cve_pago,cve_cuenta_ori,cuenta_origen,cve_cuenta_dest,cuenta_destino,banco_destino,
						referencia1,referencia2,convenio,importe,ref_cobranza,importe_iva,tipo_spei,concepto,fecha_inicio,cve_final,no_repeticiones,
						fecha_fin,cve_programa,tipo_diaria,cada_x_dias,cada_x_semanas,dias_semana,tipo_mensual,dia_x_del_mes,cada_x_meses,cve_ocurre,
						cve_dia,cve_canal,cve_notifica,ben_email,ben_cve_compania,ben_celular,cve_notifica_emi,emi_email,emi_cve_compania,emi_celular,
						mensaje,cve_estado,user_insert,fecha_insert,user_cancela,fecha_cancela,canal_cancela)
					VALUES(p_sCve_pagoprog,p_snum_cte, p_sdescripcion,p_scve_pago,p_scve_cuenta_ori,p_scuenta_origen,p_scve_cuenta_dest,p_scuenta_destino,
						p_sbanco_destino,p_sreferencia1,p_sreferencia2,p_sconvenio,p_mimporte,p_sref_cobranza,p_mimporte_iva,p_itipo_spei,p_sconcepto,
						p_dfecha_inicio,p_scve_final,p_ino_repeticiones,p_dfecha_fin,p_scve_programa,p_stipo_diaria,p_icada_x_dias,p_icada_x_semanas,
						p_sdias_semana,p_stipo_mensual,p_idia_x_del_mes,p_icada_x_meses,p_scve_ocurre,p_scve_dia,p_scve_canal,p_scve_notifica,p_sben_email ,
						p_sben_cve_compania,p_sben_celular,p_scve_notifica_emi,p_semi_email,p_semi_cve_compania,p_semi_celular,p_smensaje, "01",
						p_suser_insert,current year to fraction(3)::DATE, "", "", "");
					LET inicio = 0;
					LET v_dFechaActiva = p_dfecha_inicio;
					--EXECUTE FUNCTION bdinteg:splvalfecha('001', v_dFechaActiva, 0 ) INTO v_sCodSpFecha,v_dFechaHabil;
					LET v_dFechaHabil = v_dFechaActiva;
					LET v_dFechaActivaMes = v_dFechaHabil;
					LET v_iActNum = 0;
					LET v_iDiaMes = DAY(v_dFechaHabil);
					WHILE  inicio < p_ino_repeticiones
						IF v_sMesPrimero = 'S' THEN
							LET v_dFechaHabil = MONTH(v_dFechaHabil) || '/01/' || YEAR(v_dFechaHabil);
						END IF;
						EXECUTE FUNCTION bdiprog:sp_obtenerOcurrenciaDia(p_scve_ocurre,p_scve_dia,v_dFechaHabil) INTO v_sCodSpOcurren,v_dFechaActivaMes;
						--EXECUTE FUNCTION bdinteg:splvalfecha('001', v_dFechaActivaMes, 0 ) INTO v_sCodSpFecha,v_dFechaHabil;
						WHILE (v_ciclo_fec = 'N')
							EXECUTE FUNCTION bdinteg:splvalfecha('001', v_dFechaActivaMes, 0 ) INTO v_sCodSpFecha,v_dFechaHabil;
							SELECT fecha_prox INTO v_d_Fech_prox FROM bdinteg:si_feriado_banca WHERE empresa = '001' AND fecha = v_dFechaHabil;
							IF (v_d_Fech_prox IS NULL) OR (v_d_Fech_prox = "") THEN
								LET v_dFechaHabil = v_dFechaHabil;
								LET v_ciclo_fec = 'S';

							ELSE
								--LET v_dFechaHabil = v_d_Fech_prox + 1;
								LET v_dFechaHabil = v_d_Fech_prox;
								LET v_dFechaActivaMes = v_dFechaHabil;
							END IF;
						END WHILE;
						LET v_ciclo_fec = 'N';
						IF v_sCodSpOcurren = '00000' THEN
							IF v_dFechaActivaMes >= p_dfecha_inicio THEN
								LET v_iActNum = v_iActNum +1;
								LET inicio = inicio + 1;
								LET v_sError = '1';
								--SET LOCK MODE TO WAIT 10;
								INSERT INTO bdiprog:pp_pagospend(cve_pagoprog, consecutivo, fecha_prog, estado, fecha_aplic, folio_suc, user_insert, fecha_insert, user_cancela, fecha_cancela, canal_cancela, cve_rechazo)
								VALUES(p_sCve_pagoprog, v_iActNum, v_dFechaHabil, '03', '', '',p_suser_insert , CURRENT::DATE, '', '', '', '00');
							END IF;
						END IF;
						IF ( inicio = p_ino_repeticiones) THEN
						ELSE
							LET v_sMesPrimero = 'S';
							LET v_iDiaMes = DAY(v_dFechaActivaMes);
							IF ( inicio = p_ino_repeticiones) THEN
							ELSE
								IF v_iDiaMes >= '28' THEN
									LET v_dFechaActiva2 = MONTH(v_dFechaActivaMes) || '/01/' || YEAR(v_dFechaActivaMes);
									LET v_dFechaHabil = v_dFechaActiva2 + p_icada_x_meses UNITS MONTH;
									EXECUTE FUNCTION bdiprog:sp_obtenerFechaValida(year(v_dFechaHabil),month(v_dFechaHabil),v_iDiaMes) INTO v_sCodSpFecha,v_dFechaActivaMes;
									IF v_sCodSpFecha = '00000' THEN
										IF DAY(v_dFechaActivaMes) = 1 THEN
											LET v_dFechaHabil = v_dFechaActivaMes -1;
										ELSE
											LET v_dFechaHabil = v_dFechaActivaMes;
										END IF;
									END IF;
								ELSE
									LET v_dFechaHabil = v_dFechaActivaMes + p_icada_x_meses UNITS MONTH;
								END IF;
							END IF;
						end if;
						--EXECUTE FUNCTION bdinteg:splvalfecha('001', v_dFechaHabil, 0 ) INTO v_sCodSpFecha,v_dFechaHabil;
					END WHILE;
					IF  (v_dFechaLimite < v_dFechaActivaMes) THEN
						--if vtransaccion = 1 then   rollback;  BEGIN WORK; 	else   rollback; end if;
						SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '66';
						RETURN v_sCodRet, v_sMensajeRet;
					END IF;
					LET v_sError = '1';
					IF v_iActNum = 0 THEN
						--if vtransaccion = 1 then   rollback;  BEGIN WORK; 	else  rollback; end if;
						SELECT cod_ret, desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '65';
						RETURN v_sCodRet, v_sMensajeRet;
					END IF;
			END IF;
		END IF;
		IF p_scve_final = '02' THEN

			IF p_stipo_mensual = '01' THEN

				LET p_icada_x_dias = 0;
				LET p_icada_x_semanas = 0;
				LET p_sdias_semana = '';
				LET p_scve_ocurre = '00';
				LET p_scve_dia = '00';
				LET p_stipo_diaria = '00';
				--EXECUTE FUNCTION bdinteg:splvalfecha('001', p_dfecha_inicio, 0 ) INTO v_sCodSpFecha,p_dfecha_inicio;
				--SET LOCK MODE TO WAIT 10;
				INSERT INTO bdiprog:pp_pagoprog(cve_pagoprog,num_cte,descripcion,cve_pago,cve_cuenta_ori,cuenta_origen,cve_cuenta_dest,cuenta_destino,banco_destino,
					referencia1,referencia2,convenio,importe,ref_cobranza,importe_iva,tipo_spei,concepto,fecha_inicio,cve_final,no_repeticiones,
					fecha_fin,cve_programa,tipo_diaria,cada_x_dias,cada_x_semanas,dias_semana,tipo_mensual,dia_x_del_mes,cada_x_meses,cve_ocurre,
					cve_dia,cve_canal,cve_notifica,ben_email,ben_cve_compania,ben_celular,cve_notifica_emi,emi_email,emi_cve_compania,emi_celular,
					mensaje,cve_estado,user_insert,fecha_insert,user_cancela,fecha_cancela,canal_cancela)
				VALUES(p_sCve_pagoprog,p_snum_cte, p_sdescripcion,p_scve_pago,p_scve_cuenta_ori,p_scuenta_origen,p_scve_cuenta_dest,p_scuenta_destino,
					p_sbanco_destino,p_sreferencia1,p_sreferencia2,p_sconvenio,p_mimporte,p_sref_cobranza,p_mimporte_iva,p_itipo_spei,p_sconcepto,
					p_dfecha_inicio,p_scve_final,p_ino_repeticiones,p_dfecha_fin,p_scve_programa,p_stipo_diaria,p_icada_x_dias,p_icada_x_semanas,
					p_sdias_semana,p_stipo_mensual,p_idia_x_del_mes,p_icada_x_meses,p_scve_ocurre,p_scve_dia,p_scve_canal,p_scve_notifica,p_sben_email ,
					p_sben_cve_compania,p_sben_celular,p_scve_notifica_emi,p_semi_email,p_semi_cve_compania,p_semi_celular,p_smensaje, "01",
					p_suser_insert,current year to fraction(3)::DATE, "", "", "");
				LET inicio = 0;
				LET v_dFechaHabil = p_dfecha_inicio;
				LET v_iDiaMes = DAY(v_dFechaHabil);
				--EXECUTE FUNCTION bdinteg:splvalfecha('001', v_dFechaActiva, 0 ) INTO v_sCodSpFecha,v_dFechaHabil;
				WHILE (v_dFechaHabil <= p_dfecha_fin)
					IF v_sMesPrimero = 'S' THEN
							LET v_dFechaHabil = MONTH(v_dFechaHabil) || '/01/' || YEAR(v_dFechaHabil);
					END IF;
					EXECUTE FUNCTION bdiprog:sp_obtenerFechaValida(year(v_dFechaHabil),month(v_dFechaHabil),p_idia_x_del_mes) INTO v_sCodSpFecha,v_dFechaActivaMes;
					--EXECUTE FUNCTION bdinteg:splvalfecha('001', v_dFechaActivaMes, 0 ) INTO v_sCodSpFecha,v_dFechaActivaMes;
					WHILE (v_ciclo_fec = 'N')
						EXECUTE FUNCTION bdinteg:splvalfecha('001', v_dFechaActivaMes, 0 ) INTO v_sCodSpFecha,v_dFechaActivaMes;
						SELECT fecha_prox INTO v_d_Fech_prox FROM bdinteg:si_feriado_banca WHERE empresa = '001' AND fecha = v_dFechaActivaMes;
						IF (v_d_Fech_prox IS NULL) OR (v_d_Fech_prox = "") THEN
							LET v_dFechaActivaMes = v_dFechaActivaMes;
							LET v_ciclo_fec = 'S';
						ELSE
							LET v_dFechaActivaMes = v_d_Fech_prox;
							--LET v_dFechaActivaMes = v_d_Fech_prox + 1;
						END IF;
					END WHILE;
					LET v_ciclo_fec = 'N';
					IF v_dFechaActivaMes >= p_dfecha_inicio AND v_dFechaActivaMes <=  p_dfecha_fin  THEN
						LET inicio = inicio + 1;
						LET v_sError = '1';
						LET v_iAplicaDia = v_iAplicaDia +1;
						--SET LOCK MODE TO WAIT 10;
						INSERT INTO bdiprog:pp_pagospend(cve_pagoprog, consecutivo, fecha_prog, estado, fecha_aplic, folio_suc, user_insert, fecha_insert, user_cancela, fecha_cancela, canal_cancela, cve_rechazo)
						VALUES(p_sCve_pagoprog, inicio, v_dFechaActivaMes, '03', '', '',p_suser_insert , CURRENT::DATE, '', '', '', '00');
					END IF;
					LET v_sMesPrimero = 'S';
					--IF ( inicio = p_ino_repeticiones) THEN
					--ELSE
						LET v_iDiaMes = DAY(v_dFechaHabil);
						IF v_iDiaMes >= '28' THEN
							LET v_dFechaActiva2 = MONTH(v_dFechaHabil) || '/01/' || YEAR(v_dFechaHabil);
							LET v_dFechaHabil = v_dFechaActiva2 + p_icada_x_meses UNITS MONTH;
							EXECUTE FUNCTION bdiprog:sp_obtenerFechaValida(year(v_dFechaHabil),month(v_dFechaHabil),v_iDiaMes) INTO v_sCodSpFecha,v_dFechaActivaMes;
							IF v_sCodSpFecha = '00000' THEN
								IF DAY(v_dFechaActivaMes) = 1 THEN
									LET v_dFechaHabil = v_dFechaActivaMes -1;
								ELSE
									LET v_dFechaHabil = v_dFechaActivaMes;
								END IF;
							END IF;
						ELSE
							LET v_dFechaHabil = v_dFechaHabil + p_icada_x_meses UNITS MONTH;
						END IF;
					--END IF;
				END WHILE;
				LET v_sError = '1';
				IF v_iAplicaDia = 0 THEN
					--if vtransaccion = 1 then   rollback;  BEGIN WORK; 	else  rollback; end if;
					SELECT cod_ret, desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '65';
					RETURN v_sCodRet, v_sMensajeRet;
				END IF;
			END IF;
			IF p_stipo_mensual = '02' THEN

				--ECUTE FUNCTION bdinteg:splvalfecha('001', p_dfecha_inicio, 0 ) INTO v_sCodSpFecha,p_dfecha_inicio;
				LET p_icada_x_dias = 0;
				LET p_icada_x_semanas = 0;
				LET p_sdias_semana = '';
				LET p_stipo_diaria = '00';
				LET p_idia_x_del_mes = 0;
				--SET LOCK MODE TO WAIT 10;
				INSERT INTO bdiprog:pp_pagoprog(cve_pagoprog,num_cte,descripcion,cve_pago,cve_cuenta_ori,cuenta_origen,cve_cuenta_dest,cuenta_destino,banco_destino,
					referencia1,referencia2,convenio,importe,ref_cobranza,importe_iva,tipo_spei,concepto,fecha_inicio,cve_final,no_repeticiones,
					fecha_fin,cve_programa,tipo_diaria,cada_x_dias,cada_x_semanas,dias_semana,tipo_mensual,dia_x_del_mes,cada_x_meses,cve_ocurre,
					cve_dia,cve_canal,cve_notifica,ben_email,ben_cve_compania,ben_celular,cve_notifica_emi,emi_email,emi_cve_compania,emi_celular,
					mensaje,cve_estado,user_insert,fecha_insert,user_cancela,fecha_cancela,canal_cancela)
				VALUES(p_sCve_pagoprog,p_snum_cte, p_sdescripcion,p_scve_pago,p_scve_cuenta_ori,p_scuenta_origen,p_scve_cuenta_dest,p_scuenta_destino,
					p_sbanco_destino,p_sreferencia1,p_sreferencia2,p_sconvenio,p_mimporte,p_sref_cobranza,p_mimporte_iva,p_itipo_spei,p_sconcepto,
					p_dfecha_inicio,p_scve_final,p_ino_repeticiones,p_dfecha_fin,p_scve_programa,p_stipo_diaria,p_icada_x_dias,p_icada_x_semanas,
					p_sdias_semana,p_stipo_mensual,p_idia_x_del_mes,p_icada_x_meses,p_scve_ocurre,p_scve_dia,p_scve_canal,p_scve_notifica,p_sben_email ,
					p_sben_cve_compania,p_sben_celular,p_scve_notifica_emi,p_semi_email,p_semi_cve_compania,p_semi_celular,p_smensaje, "01",
					p_suser_insert,current year to fraction(3)::DATE, "", "", "");
				LET inicio = 0;
				LET v_iActNum = 0;
				LET v_dFechaHabil = p_dfecha_inicio;
				LET v_iDiaMes = DAY(v_dFechaHabil);
				--EXECUTE FUNCTION bdinteg:splvalfecha('001', v_dFechaActiva, 0 ) INTO v_sCodSpFecha,v_dFechaHabil;
				WHILE (v_dFechaHabil <= p_dfecha_fin)
					IF v_sMesPrimero = 'S' THEN
						LET v_dFechaHabil = MONTH(v_dFechaHabil) || '/01/' || YEAR(v_dFechaHabil);
					END IF;
					EXECUTE FUNCTION bdiprog:sp_obtenerOcurrenciaDia(p_scve_ocurre,p_scve_dia,v_dFechaHabil) INTO v_sCodSpOcurren,v_dFechaActivaMes;
					IF v_dFechaActivaMes >= p_dfecha_inicio AND v_dFechaActivaMes <=  p_dfecha_fin  THEN
						IF v_sCodSpOcurren = '00000' THEN
							LET v_iActNum = v_iActNum +1;
							LET inicio = inicio + 1;
							LET v_sError = '1';
							--SET LOCK MODE TO WAIT 10;
							--EXECUTE FUNCTION bdinteg:splvalfecha('001', v_dFechaActivaMes, 0 ) INTO v_sCodSpFecha,v_dFechaHabil;
							WHILE (v_ciclo_fec = 'N')
								EXECUTE FUNCTION bdinteg:splvalfecha('001', v_dFechaActivaMes, 0 ) INTO v_sCodSpFecha,v_dFechaActivaMes;
								SELECT fecha_prox INTO v_d_Fech_prox FROM bdinteg:si_feriado_banca WHERE empresa = '001' AND fecha = v_dFechaActivaMes;
								IF (v_d_Fech_prox IS NULL) OR (v_d_Fech_prox = "") THEN
									LET v_dFechaHabil = v_dFechaActivaMes;
									LET v_ciclo_fec = 'S';
								ELSE
									--LET v_dFechaActivaMes = v_d_Fech_prox + 1;
									LET v_dFechaActivaMes = v_d_Fech_prox;
								END IF;
							END WHILE;
							LET v_ciclo_fec = 'N';
							INSERT INTO bdiprog:pp_pagospend(cve_pagoprog, consecutivo, fecha_prog, estado, fecha_aplic, folio_suc, user_insert, fecha_insert, user_cancela, fecha_cancela, canal_cancela, cve_rechazo)
							VALUES(p_sCve_pagoprog, v_iActNum, v_dFechaHabil, '03', '', '',p_suser_insert , CURRENT::DATE, '', '', '', '00');
						END IF;
					END IF;
					LET v_sMesPrimero = 'S';
					LET v_iDiaMes = DAY(v_dFechaActivaMes);
					IF v_iDiaMes >= '28' THEN
						LET v_dFechaActiva2 = MONTH(v_dFechaActivaMes) || '/01/' || YEAR(v_dFechaActivaMes);
						LET v_dFechaHabil = v_dFechaActiva2 + p_icada_x_meses UNITS MONTH;
						EXECUTE FUNCTION bdiprog:sp_obtenerFechaValida(year(v_dFechaHabil),month(v_dFechaHabil),v_iDiaMes) INTO v_sCodSpFecha,v_dFechaActivaMes;
						IF v_sCodSpFecha = '00000' THEN
							IF DAY(v_dFechaActivaMes) = 1 THEN
								LET v_dFechaHabil = v_dFechaActivaMes -1;
							ELSE
								LET v_dFechaHabil = v_dFechaActivaMes;
							END IF;
						END IF;
					ELSE
						LET v_dFechaHabil = v_dFechaActivaMes + p_icada_x_meses UNITS MONTH;
					END IF;
					EXECUTE FUNCTION bdinteg:splvalfecha('001', v_dFechaHabil, 0 ) INTO v_sCodSpFecha,v_dFechaHabil;
				END WHILE;
				LET v_sError = '1';
				IF v_iActNum = 0 THEN
					--if vtransaccion = 1 then   rollback;  BEGIN WORK; 	else   rollback; end if;
					SELECT cod_ret, desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '65';
					RETURN v_sCodRet, v_sMensajeRet;
				END IF;
			END IF;
		END IF;
		IF v_sError = '0' THEN
			--if vtransaccion = 1 then   rollback;  BEGIN WORK; 	else   rollback; end if;
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '65';
			RETURN v_sCodRet, v_sMensajeRet;
		END IF;
		--if vtransaccion = 1 then   COMMIT WORK;  BEGIN WORK; 	else   COMMIT WORK; end if;
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes where cve_mensaje = '00';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
	IF p_scve_programa = '04' THEN

		LET p_ino_repeticiones = 0;
		LET p_stipo_diaria = '00';
		LET p_icada_x_dias = 0;
		LET p_icada_x_semanas = 0;
		LET p_sdias_semana = '';
		LET p_stipo_mensual = '00';
		LET p_idia_x_del_mes = 0;
		LET p_icada_x_meses = 0;
		LET p_scve_ocurre = '00';
		LET p_scve_dia = '00';
		--EXECUTE FUNCTION bdinteg:splvalfecha('001', p_dfecha_inicio, 0 ) INTO v_sCodSpFecha,p_dfecha_inicio;
		--SET LOCK MODE TO WAIT 10;
		INSERT INTO bdiprog:pp_pagoprog(cve_pagoprog,num_cte,descripcion,cve_pago,cve_cuenta_ori,cuenta_origen,cve_cuenta_dest,cuenta_destino,banco_destino,
			referencia1,referencia2,convenio,importe,ref_cobranza,importe_iva,tipo_spei,concepto,fecha_inicio,cve_final,no_repeticiones,
			fecha_fin,cve_programa,tipo_diaria,cada_x_dias,cada_x_semanas,dias_semana,tipo_mensual,dia_x_del_mes,cada_x_meses,cve_ocurre,
			cve_dia,cve_canal,cve_notifica,ben_email,ben_cve_compania,ben_celular,cve_notifica_emi,emi_email,emi_cve_compania,emi_celular,
			mensaje,cve_estado,user_insert,fecha_insert,user_cancela,fecha_cancela,canal_cancela)
		VALUES(p_sCve_pagoprog,p_snum_cte, p_sdescripcion,p_scve_pago,p_scve_cuenta_ori,p_scuenta_origen,p_scve_cuenta_dest,p_scuenta_destino,
			p_sbanco_destino,p_sreferencia1,p_sreferencia2,p_sconvenio,p_mimporte,p_sref_cobranza,p_mimporte_iva,p_itipo_spei,p_sconcepto,
			p_dfecha_inicio,p_scve_final,p_ino_repeticiones,p_dfecha_fin,p_scve_programa,p_stipo_diaria,p_icada_x_dias,p_icada_x_semanas,
			p_sdias_semana,p_stipo_mensual,p_idia_x_del_mes,p_icada_x_meses,p_scve_ocurre,p_scve_dia,p_scve_canal,p_scve_notifica,p_sben_email ,
			p_sben_cve_compania,p_sben_celular,p_scve_notifica_emi,p_semi_email,p_semi_cve_compania,p_semi_celular,p_smensaje, "01",
			p_suser_insert,current year to fraction(3)::DATE, "", "", "");
		--SET LOCK MODE TO WAIT 10;
		--EXECUTE FUNCTION bdinteg:splvalfecha('001', p_dfecha_inicio, 0 ) INTO v_sCodSpFecha,v_dFechaHabil;
		WHILE (v_ciclo_fec = 'N')
			EXECUTE FUNCTION bdinteg:splvalfecha('001', v_dFechaActiva, 0 ) INTO v_sCodSpFecha,v_dFechaHabil;
			SELECT fecha_prox INTO v_d_Fech_prox FROM bdinteg:si_feriado_banca WHERE empresa = '001' AND fecha = v_dFechaHabil;
			IF (v_d_Fech_prox IS NULL) OR (v_d_Fech_prox = "") THEN
				LET v_dFechaHabil = v_dFechaHabil;
				LET v_ciclo_fec = 'S';
			ELSE
				--LET v_dFechaActiva = v_d_Fech_prox + 1;
				LET v_dFechaActiva = v_d_Fech_prox;
			END IF;
		END WHILE;
		LET v_ciclo_fec = 'N';
		INSERT INTO bdiprog:pp_pagospend(cve_pagoprog, consecutivo, fecha_prog, estado, fecha_aplic, folio_suc, user_insert, fecha_insert, user_cancela, fecha_cancela, canal_cancela, cve_rechazo)
		VALUES(p_sCve_pagoprog, '1', v_dFechaHabil, '03', '', '',p_suser_insert , CURRENT::DATE, '', '', '', '00');
		--if vtransaccion = 1 then   COMMIT WORK;  BEGIN WORK; 	else   COMMIT WORK; end if;
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes where cve_mensaje = '00';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
	--if vtransaccion = 1 then COMMIT WORK; BEGIN WORK; else COMMIT WORK; end if;
END;
END PROCEDURE;
CREATE PROCEDURE "informix".sp_validapagodeservicios
(
	p_sCve_pagoprog CHAR(10), p_snum_cte CHAR(20), p_sDescripcion CHAR(20), p_scve_pago CHAR(2), p_scve_cuenta_ori CHAR(2), p_scuenta_origen CHAR(20), p_scve_cuenta_dest CHAR(2), 
	p_scuenta_destino CHAR(20), p_sbanco_destino CHAR(3), p_sreferencia1 CHAR(40), p_sreferencia2 CHAR(40), p_sconvenio CHAR(5), p_mimporte MONEY(16,2), p_sref_cobranza CHAR(40), 
	p_mimporte_iva MONEY(16,2), p_itipo_spei INTEGER, p_sconcepto CHAR(60), p_dfecha_inicio DATE, p_scve_final CHAR(2), p_ino_repeticiones INTEGER, p_dfecha_fin DATE, 
	p_scve_programa CHAR(2), p_stipo_diaria CHAR(2), p_icada_x_dias INTEGER, p_icada_x_semanas INTEGER,	p_sdias_semana CHAR(7), p_stipo_mensual CHAR(2), p_idia_x_del_mes INTEGER, 
	p_icada_x_meses INTEGER, p_scve_ocurre CHAR(2), p_scve_dia CHAR(2), p_scve_canal CHAR(2), p_scve_notifica CHAR(2), p_sben_email CHAR(100), p_sben_cve_compania CHAR(2), 
	p_sben_celular CHAR(10), p_scve_notifica_emi CHAR(2), p_semi_email CHAR(100), p_semi_cve_compania CHAR(2), p_semi_celular CHAR(10), p_smensaje CHAR(100), p_scve_estado CHAR(2), 
	p_suser_insert CHAR(8), p_dfecha_insert DATE, p_suser_cancela CHAR(8), p_dfecha_cancela DATE, p_scanal_cancela CHAR(2)
)
RETURNING CHAR(5), CHAR(250);
						
---**********************************************************
-- Realizo : Josè de Jesùs Nevarez.						    *
-- Solicito : Mauricio Leon.  								*
-- Proyecto :  Pagos Programados							*
-- Actividad : Tener un procedimieto que permita la         *
-- programacion de pago de servicios.						*
-- sustituye a sp_pagoserviciostelmex 					    *
-- para un pago de servicios.								*
-- Fecha     :21 de Septiembre  de 2008						*
--20110826 : Se agrega validación para registrar el valor   *
--          'referencia2' = digito verificador para los     *
--           Servicios:                                     *
--			 SKY (06001), DISH (06002) y MASTV (06003)      *
--***********************************************************

DEFINE v_sCodRet CHAR(5);
DEFINE v_sMensajeRet CHAR(250);
DEFINE v_sNumCategoria	CHAR(2);
DEFINE sql_err  SMALLINT;
DEFINE v_sNumConvenio CHAR(3);
DEFINE v_iCadena INTEGER;
DEFINE v_iflg_ref1 INTEGER;
DEFINE v_iLongitudRef1Tabla INTEGER;
DEFINE v_iLongitudRef1 INTEGER;
DEFINE v_iflgcalculodv_ref1 INTEGER;
DEFINE v_snomrutinadv_ref1 CHAR(30);
DEFINE v_iflg_ref2 INTEGER;
DEFINE v_iLongitudRef2Tabla INTEGER;
DEFINE v_iLongitudRef2 INTEGER;
DEFINE v_sCodRetorno CHAR(5);
DEFINE v_svalor CHAR(100);
DEFINE v_ilongitud INTEGER;
DEFINE v_iinicio INTEGER;
DEFINE v_sfinciclo CHAR(1);
DEFINE v_scadena CHAR(20);
DEFINE v_scadenados CHAR(20);
DEFINE v_spagoprog CHAR(10);
DEFINE v_sMaxClave INTEGER;
DEFINE v_sDigitoVerificador CHAR(40);
DEFINE vtransaccion INTEGER;
DEFINE v_mRound MONEY(16,2);
DEFINE v_mResta MONEY(16,2);
DEFINE vdFechaDisponible DATE;
DEFINE vdFechaMovil DATE;
DEFINE v_sCodSpFecha CHAR(5);
DEFINE v_d_Fech_prox DATE;
DEFINE vdFechaProgramada DATE;
DEFINE v_ciclo_fec CHAR (1);

--20110826-I
DEFINE v_longreferps INTEGER;
--DEFINE v_ref2ps CHAR (1);

--20110826-F

LET v_sCodRet = '';
LET v_sMensajeRet = '';
LET v_sNumCategoria = '';
LET sql_err = 0;
LET v_sNumConvenio = '';
LET v_iCadena = 0;
LET v_iflg_ref1 = 0;
LET v_iLongitudRef1Tabla = 0;
LET v_iLongitudRef1 = 0;
LET v_iflgcalculodv_ref1 = 0;
LET v_snomrutinadv_ref1 = '';
LET v_iflg_ref2 = 0;
LET v_iLongitudRef2Tabla = 0;
LET v_iLongitudRef2 = 0;
LET v_sCodRetorno = '';
LET v_svalor = '';
LET v_ilongitud = '';
LET v_iinicio = 1;
LET v_sFinCiclo = '';
LET v_scadena = '';
LET v_scadenados = '';
LET v_spagoprog = '';
LET v_sMaxClave = 0;
LET v_sDigitoVerificador = '';
LET vtransaccion = 0;
LET v_mRound = 0.00;
LET v_mResta = 0.00;
LET vdFechaDisponible = '';
LET vdFechaMovil = '';
LET v_sCodSpFecha = '';
LET v_d_Fech_prox = '';
LET vdFechaProgramada = '';
LET v_ciclo_fec = 'N';
LET v_longreferps = 0;


    --SET DEBUG FILE TO "/respaldosbd/antoniocebreros/153/sp_validapagodeservicios.out";
    --TRACE ON;
	
BEGIN
	ON EXCEPTION SET  sql_err
	IF sql_err <> 0 THEN
		IF vtransaccion = 1 THEN ROLLBACK WORK; BEGIN WORK; ELSE ROLLBACK WORK; END IF;
		LET v_sCodRet =  sql_err;
		LET v_sMensajeRet  =  "PROGRAMACIÓN DE PAGO DE SERVICIOS NO REALIZADA";
		RETURN v_sCodRet, v_sMensajeRet;
	END IF
	END EXCEPTION
		ON EXCEPTION IN (-535)
		 LET vtransaccion = 1;
	  END EXCEPTION WITH RESUME;
	ON EXCEPTION IN (-271)
		IF vtransaccion = 1 THEN   ROLLBACK WORK;  BEGIN WORK;  ELSE ROLLBACK WORK;	END IF
		SELECT cod_ret,desc_mensaje INTO  v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '230';  
		RETURN  v_sCodRet, v_sMensajeRet;
	END EXCEPTION; 
	IF vtransaccion = 1 THEN
		COMMIT WORK;   
		BEGIN WORK; 	
	ELSE
		BEGIN WORK;
	END IF;
	
	IF (NVL(p_sconvenio,'') = '')  THEN
		SELECT cod_ret,desc_mensaje INTO  v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '129';
		RETURN  v_sCodRet, v_sMensajeRet;
	END IF;
	
	--Se valida la cuenta destino
	SET ISOLATION TO DIRTY READ;
	IF EXISTS (SELECT user_insert FROM bdiprog:pp_ctasterceros  WHERE  cuenta = p_scuenta_destino) THEN
		SET ISOLATION TO DIRTY READ;
		IF EXISTS(SELECT user_insert  FROM bdiprog:pp_ctasterceros WHERE num_cte = p_snum_cte AND cuenta = p_scuenta_destino) THEN
			SET ISOLATION TO DIRTY READ;	
			IF EXISTS(SELECT user_insert  FROM bdiprog:pp_ctasterceros WHERE num_cte = p_snum_cte AND cuenta = p_scuenta_destino AND cve_banco  = p_sbanco_destino) THEN
				SET ISOLATION TO DIRTY READ;
				IF EXISTS (SELECT user_insert  FROM bdiprog:pp_ctasterceros WHERE num_cte = p_snum_cte AND cuenta = p_scuenta_destino AND cve_banco  = p_sbanco_destino AND  cve_cuenta = p_scve_cuenta_dest) THEN
					IF EXISTS(SELECT user_insert  FROM bdiprog:pp_ctasterceros WHERE num_cte = p_snum_cte AND cuenta = p_scuenta_destino AND cve_banco  = p_sbanco_destino AND cve_estado = '01' AND cve_cuenta = p_scve_cuenta_dest) THEN
					ELSE
						IF vtransaccion = 1 THEN   ROLLBACK;  BEGIN WORK; 	ELSE  ROLLBACK; END IF;
						SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '189';
						RETURN v_sCodRet, v_sMensajeRet;
					END IF;
				ELSE
					IF vtransaccion = 1 THEN   ROLLBACK;  BEGIN WORK; 	ELSE  ROLLBACK; END IF;
						SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '205';
						RETURN v_sCodRet, v_sMensajeRet;
				END IF;
			ELSE
				IF vtransaccion = 1 THEN   ROLLBACK;  BEGIN WORK; 	ELSE  ROLLBACK; END IF;
				SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '204';
				RETURN v_sCodRet, v_sMensajeRet;
			END IF;
		ELSE
			IF vtransaccion = 1 THEN   ROLLBACK;  BEGIN WORK; 	ELSE  ROLLBACK; END IF;
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '190';
			RETURN v_sCodRet, v_sMensajeRet;
		END IF;
	ELSE
		IF vtransaccion = 1 THEN   ROLLBACK;  BEGIN WORK; 	ELSE  ROLLBACK; END IF;
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '188';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
	
	--Se verifica que la clave cuenta destino sea igual es '05'
	IF p_scve_cuenta_dest = '05' THEN
		--Se verfica que la clave destino se encuetre en la tabla de cuentas
		IF EXISTS(SELECT descripcion FROM bdiprog:pp_tpcuenta WHERE cve_cuenta = p_scve_cuenta_dest)THEN
		ELSE
			IF vtransaccion = 1 THEN   ROLLBACK;  BEGIN WORK; 	ELSE   ROLLBACK; END IF;
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '03';
			RETURN v_sCodRet, v_sMensajeRet;
		END IF;
	ELSE
		IF vtransaccion = 1 THEN   ROLLBACK;  BEGIN WORK; 	ELSE   ROLLBACK; END IF;
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '80';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
	
	--SE valida que exista el convenio
	LET v_sNumCategoria = SUBSTR(p_sconvenio,1,2); 
	LET v_sNumConvenio = SUBSTR(p_sconvenio,3,5);
	IF EXISTS(SELECT nomconvenio  FROM bdisac:sac_convenios WHERE numcategoria = v_sNumCategoria AND numconvenio = v_sNumConvenio) THEN
		IF NOT EXISTS(SELECT nomconvenio  FROM bdisac:sac_convenios WHERE numcategoria = v_sNumCategoria AND numconvenio = v_sNumConvenio AND statusconvenio = 'A') THEN
			IF vtransaccion = 1 THEN   ROLLBACK;  BEGIN WORK; 	ELSE   ROLLBACK; END IF;
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '229';
			RETURN v_sCodRet, v_sMensajeRet;
		END IF;
	ELSE
		IF vtransaccion = 1 THEN   ROLLBACK;  BEGIN WORK; 	ELSE   ROLLBACK; END IF;
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '76';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
	
	--Se valida la longitud de el parametro convenio que sea igual
	LET v_iCadena  = LENGTH(p_sconvenio);
	IF v_iCadena = 5 THEN
	ELSE
		IF vtransaccion = 1 THEN   ROLLBACK;  BEGIN WORK; 	ELSE   ROLLBACK; END IF;
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '75';
        RETURN v_sCodRet, v_sMensajeRet;
	END IF;
	
	--se toma el valor de flg_ref1 y se valida la referencia uno
	SET ISOLATION TO DIRTY READ;
	SELECT flg_ref1 INTO v_iflg_ref1 FROM bdisac:sac_convenios WHERE numcategoria = v_sNumCategoria AND numconvenio = v_sNumConvenio AND statusconvenio = 'A';
	IF v_iflg_ref1 = 1 THEN
		IF (NVL(p_sreferencia1,'') <> '') THEN
			--LET v_scadena = '';
			--LET v_ilongitud = '';
			--LET v_scadenados = '';
			--LET v_svalor = '';
			LET v_scadena = p_sreferencia1;
			LET v_ilongitud = LENGTH(v_scadena);
			--LET v_iinicio = 1;
			LET v_sfinciclo = 'F';
			WHILE (v_iinicio <= v_ilongitud) and (v_sfinciclo = 'F')
				LET v_scadenados = substr(v_scadena,v_iinicio,1);
				IF ((v_scadenados >= '0')  and (v_scadenados <= '9')) THEN
					LET v_svalor = 'A';
				ELSE
					LET v_svalor = 'B';
					LET v_sfinciclo = 'T';
				END IF;
				LET v_iinicio = (v_iinicio + 1);
			END WHILE;
			IF v_svalor = 'B' THEN
				IF vtransaccion = 1 THEN   ROLLBACK;  BEGIN WORK; 	ELSE   ROLLBACK; END IF;
				SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '40';
				RETURN v_sCodRet, v_sMensajeRet;
			END IF;
			SET ISOLATION TO DIRTY READ;
			IF EXISTS(SELECT nomconvenio FROM bdisac:sac_convenios WHERE numcategoria = v_sNumCategoria AND numconvenio = v_sNumConvenio AND statusconvenio = 'A') THEN
				LET v_iLongitudRef1 = LENGTH(p_sreferencia1);
				SET ISOLATION TO DIRTY READ;
				SELECT longitud_ref1 INTO v_iLongitudRef1Tabla FROM bdisac:sac_convenios WHERE numcategoria = v_sNumCategoria AND numconvenio = v_sNumConvenio AND statusconvenio = 'A';
				IF v_iLongitudRef1Tabla = v_iLongitudRef1 THEN
					SET ISOLATION TO DIRTY READ;
					SELECT flgcalculodv_ref1 INTO v_iflgcalculodv_ref1 FROM bdisac:sac_convenios WHERE numcategoria = v_sNumCategoria AND numconvenio = v_sNumConvenio AND statusconvenio = 'A';
					IF v_iflgcalculodv_ref1 = 1 THEN
						SET ISOLATION TO DIRTY READ;
						SELECT nomrutinadv_ref1 INTO v_snomrutinadv_ref1 FROM bdisac:sac_convenios WHERE numcategoria = v_sNumCategoria AND numconvenio = v_sNumConvenio AND statusconvenio = 'A';
						LET v_snomrutinadv_ref1 =TRIM(v_snomrutinadv_ref1);
						EXECUTE PROCEDURE v_snomrutinadv_ref1(p_sreferencia1) INTO v_sCodRetorno,v_sDigitoVerificador;
						LET v_sDigitoVerificador = TRIM(v_sDigitoVerificador);
						IF v_sCodRetorno = '000' THEN
							IF v_sNumCategoria='02' AND v_sNumConvenio='001' THEN 
								IF p_sreferencia2 <> v_sDigitoVerificador THEN
									IF vtransaccion = 1 THEN   ROLLBACK;  BEGIN WORK; 	ELSE   ROLLBACK; END IF;
									SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '144';
									RETURN v_sCodRet, v_sMensajeRet;
								END IF;
							END IF;
						ELSE
							IF vtransaccion = 1 THEN   ROLLBACK;  BEGIN WORK; 	ELSE   ROLLBACK; END IF;
							SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '144';
							RETURN v_sCodRet, v_sMensajeRet;
						END IF;
					ELSE
					END IF;
				ELSE
					IF vtransaccion = 1 THEN   ROLLBACK;  BEGIN WORK; 	ELSE   ROLLBACK; END IF;
					SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '81';
					RETURN v_sCodRet, v_sMensajeRet;
				END IF;
			ELSE
				IF vtransaccion = 1 THEN   ROLLBACK;  BEGIN WORK; 	ELSE   ROLLBACK; END IF;
				SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '76';
				RETURN v_sCodRet, v_sMensajeRet;
			END IF;
		ELSE
			IF vtransaccion = 1 THEN   ROLLBACK;  BEGIN WORK; 	ELSE   ROLLBACK; END IF;
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '40';
			RETURN v_sCodRet, v_sMensajeRet;
		END IF;
	END IF;
		
	--se toma el valor de flg_ref2 y se valida la referencia DOS (solo para telefonia).
	IF v_sNumCategoria= '02' AND v_sNumConvenio='001' THEN
		SELECT flg_ref2 INTO v_iflg_ref2 FROM bdisac:sac_convenios WHERE numcategoria = v_sNumCategoria AND numconvenio = v_sNumConvenio AND statusconvenio = 'A';
		IF v_iflg_ref2 = 1 THEN
			IF (NVL(p_sreferencia2,'') <> '') THEN
				--LET v_scadena = '';
				--LET v_ilongitud = '';
				--LET v_scadenados = '';
				--LET v_svalor = '';
				LET v_scadena = p_sreferencia2;
				LET v_ilongitud = LENGTH(v_scadena);
				--LET v_iinicio = 1;
				LET v_sfinciclo = 'F';
				WHILE (v_iinicio <= v_ilongitud) AND (v_sfinciclo = 'F')
					LET v_scadenados = SUBSTR(v_scadena,v_iinicio,1);
					IF ((v_scadenados >= '0')  AND (v_scadenados <= '9'))THEN
						LET v_svalor = 'A';
					ELSE
						LET v_svalor = 'B';
						LET v_sfinciclo = 'T';
					END IF;
						LET v_iinicio = (v_iinicio + 1);
				END WHILE;
				IF v_svalor = 'B' THEN
					IF vtransaccion = 1 THEN   ROLLBACK;  BEGIN WORK; 	ELSE   ROLLBACK; END IF;
					SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '41';
					RETURN v_sCodRet, v_sMensajeRet;
				END IF;
				
				LET v_iLongitudRef2 = LENGTH(p_sreferencia2);
				SELECT longitud_ref2 INTO v_iLongitudRef2Tabla FROM bdisac:sac_convenios WHERE numcategoria = v_sNumCategoria AND numconvenio = v_sNumConvenio AND statusconvenio = 'A';
				IF v_iLongitudRef2Tabla = v_iLongitudRef2 THEN
				ELSE
					IF vtransaccion = 1 THEN   ROLLBACK;  BEGIN WORK; 	ELSE   ROLLBACK; END IF;
					SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '82';
					RETURN v_sCodRet, v_sMensajeRet;
				END IF;
			ELSE
				IF vtransaccion = 1 THEN   ROLLBACK;  BEGIN WORK; 	ELSE   ROLLBACK; END IF;
				SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '40';
				RETURN v_sCodRet, v_sMensajeRet;
			END IF;
		END IF;
		
		--Valida que importe no tenga decimales (solo telmex)
		LET v_mRound = ROUND(p_mimporte);
		LET v_mResta = v_mRound - p_mimporte;
		IF v_mResta <> 0 THEN
			IF vtransaccion = 1 THEN   ROLLBACK;  BEGIN WORK; 	ELSE   ROLLBACK; END IF;
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '226';
			RETURN v_sCodRet, v_sMensajeRet;
		END IF;
		
	END IF;
	
	--Se genera la clave de pago
	IF EXISTS(SELECT num_cte FROM bdiprog:pp_pagoprog WHERE cve_pagoprog LIKE '04%') THEN
        SELECT MAX(cve_pagoprog) INTO v_sMaxClave FROM bdiprog:pp_pagoprog  WHERE cve_pagoprog LIKE '04%';
        LET v_sMaxClave = v_sMaxClave + 1;
		LET v_spagoprog  = '0' || v_sMaxClave;
    ELSE
		LET v_spagoprog = p_scve_pago || '00000001';
    END IF;
	
	SET LOCK MODE TO WAIT 10;

--20110826-I
--	Se graba el campo referencia2 en tablas para Servicios TV (SKY-Dish-Mastv):
	LET v_longreferps = LENGTH (TRIM (p_sreferencia1));
	IF
		v_sNumCategoria = '06'
		THEN
			LET p_sreferencia2 = SUBSTR(p_sreferencia1, v_longreferps, 1);
		ELSE
	END IF;
/*
--SKY:
IF v_sNumCategoria = '06' and v_sNumConvenio = '001' THEN
	LET v_ref2ps = SUBSTR(p_sreferencia1, 12,1);
	LET p_sreferencia2 = v_ref2ps;
	ELSE
--DISH:
	IF v_sNumCategoria = '06' and v_sNumConvenio = '002' THEN
		LET v_ref2ps = SUBSTR(p_sreferencia1, 13,1);
	LET p_sreferencia2 = v_ref2ps;
    ELSE
--MASTV:
		IF v_sNumCategoria = '06' and v_sNumConvenio = '003' THEN
			LET v_ref2ps = SUBSTR(p_sreferencia1, 13,1);
			LET p_sreferencia2 = v_ref2ps;
		END IF;
	END IF;
END IF;	
*/
--20110826-f

	INSERT INTO bdiprog:pp_pagoprog(cve_pagoprog,num_cte,descripcion,cve_pago,cve_cuenta_ori,cuenta_origen,cve_cuenta_dest,cuenta_destino,banco_destino,
			referencia1,referencia2,convenio,importe,ref_cobranza,importe_iva,tipo_spei,concepto,fecha_inicio,cve_final,no_repeticiones,
			fecha_fin,cve_programa,tipo_diaria,cada_x_dias,cada_x_semanas,dias_semana,tipo_mensual,dia_x_del_mes,cada_x_meses,cve_ocurre,
			cve_dia,cve_canal,cve_notifica,ben_email,ben_cve_compania,ben_celular,cve_notifica_emi,emi_email,emi_cve_compania,emi_celular,
			mensaje,cve_estado,user_insert,fecha_insert,user_cancela,fecha_cancela,canal_cancela)
	VALUES(v_spagoprog,p_snum_cte,p_sDescripcion,p_scve_pago,p_scve_cuenta_ori,p_scuenta_origen,p_scve_cuenta_dest,p_scuenta_destino,p_sbanco_destino,p_sreferencia1,
			p_sreferencia2,p_sconvenio,p_mimporte,'00',0,0,p_sconcepto,p_dfecha_inicio, p_scve_final,0,
			p_dfecha_fin,p_scve_programa,'00',0,0,'','00',0, 0,'00','00',p_scve_canal,p_scve_notifica,p_sben_email,p_sben_cve_compania,
			p_sben_celular,p_scve_notifica_emi,p_semi_email,p_semi_cve_compania,p_semi_celular,p_smensaje,'01',p_suser_insert,CURRENT::DATE,'','','');	
	
	LET vdFechaMovil = p_dfecha_inicio;
	SET LOCK MODE TO WAIT 10;
	WHILE (v_ciclo_fec = 'N')
		EXECUTE FUNCTION bdinteg:splvalfecha('001', vdFechaMovil, 0 ) INTO v_sCodSpFecha,vdFechaDisponible;
		SELECT fecha_prox INTO v_d_Fech_prox FROM bdinteg:si_feriado_banca WHERE empresa = '001' AND fecha = vdFechaDisponible;
		IF (v_d_Fech_prox IS NULL) OR (v_d_Fech_prox = "") THEN
			LET vdFechaProgramada = vdFechaDisponible;
			LET v_ciclo_fec = 'S';
		ELSE
			LET vdFechaMovil = v_d_Fech_prox;
		END IF;
	END WHILE;
	
	INSERT INTO bdiprog:pp_pagospend(cve_pagoprog, consecutivo, fecha_prog, estado, fecha_aplic, folio_suc, user_insert, fecha_insert, user_cancela, fecha_cancela, canal_cancela, cve_rechazo)
	VALUES(v_spagoprog, '1', vdFechaProgramada, '03', '', '',p_suser_insert , CURRENT::DATE, '', '', '', '00');
	IF vtransaccion = 1 THEN
		COMMIT WORK;
		BEGIN WORK;
	ELSE
		COMMIT WORK;
	END IF;	
	SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '00';
	RETURN v_sCodRet, v_sMensajeRet;
END;
END PROCEDURE
DOCUMENT
'AUTOR: 96273763 - Antonio Cebreros Perez',
'FOLIO: 230142 - 153 - Validacion_CorreoTel_PagosProg',
'DESCRIPCION: Se modifica rango de campos relativos al e-mail tanto del emisor como del receptor ampliando su rango a 100 caracteres (parámetros de entrada p_sben_email y p_semi_email)',
'FECHA: 22/11/2016',
'BD: bdiprog';

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
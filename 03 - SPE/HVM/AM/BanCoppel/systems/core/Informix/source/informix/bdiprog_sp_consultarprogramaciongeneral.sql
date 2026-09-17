CREATE PROCEDURE "informix".sp_consultarprogramaciongeneral(p_snum_cte Char(20),p_sestado Char(2))
	RETURNING CHAR(5), CHAR(250),CHAR(10),CHAR(20),CHAR(20),CHAR(2),CHAR(2),CHAR(20),CHAR(2),CHAR(20),CHAR(3),CHAR(40),CHAR(20),CHAR(5),MONEY(16,2),CHAR(40),MONEY(16,2),
		INTEGER,CHAR(60),DATE,CHAR(2),INTEGER,DATE,CHAR(2),CHAR(2),INTEGER,INTEGER,CHAR(7),CHAR(2),INTEGER,INTEGER,CHAR(2),CHAR(2),CHAR(2),CHAR(2),
		CHAR(100),CHAR(2),CHAR(10),CHAR(2),CHAR(100),CHAR(2),CHAR(40),CHAR(100),CHAR(2),CHAR(8), DATE,CHAR(8),DATE,CHAR(2);
	---**********************************************************
	-- Realizo   :Alejandro Osuna    
	--Solicito : Aymme Osuna
	-- Proyecto :  Pagos Programados
	-- Actividad : Tener un procedimiento que permitirá consultar las transacciones programadas
    --   		        para un cliente determinado
	-- Fecha     :18 de  Novimebre  de 2008
	--******************************************************
	--Definicion de Variables
	DEFINE v_sCodRet CHAR(5);
	DEFINE v_sMensajeRet CHAR(250);
	DEFINE v_scve_pagoprog CHAR(10);
	DEFINE v_snum_cte CHAR(20);
	DEFINE v_sdescripcion CHAR(20);
	DEFINE v_scve_pago CHAR(2);
	DEFINE v_scve_cuenta_ori CHAR(2);
	DEFINE v_scuenta_origen CHAR(20);
	DEFINE v_scve_cuenta_dest CHAR(2);
	DEFINE v_scuenta_destino CHAR(20);
	DEFINE v_sbanco_destino CHAR(3);
	DEFINE v_sreferencia1 CHAR(40);
	DEFINE v_sreferencia2 CHAR(20);
	DEFINE v_sconvenio CHAR(5);
	DEFINE v_mimporte MONEY(16,2);
	DEFINE v_sref_cobranza CHAR(40);
	DEFINE v_mimporte_iva MONEY(16,2);
	DEFINE v_itipo_spei INTEGER;
	DEFINE v_sconcepto CHAR(60);
	DEFINE v_dfecha_inicio DATE;
	DEFINE v_scve_final CHAR(2);
	DEFINE v_ino_repeticiones INTEGER;
	DEFINE v_dfecha_fin DATE;
	DEFINE v_scve_programa CHAR(2);
	DEFINE v_stipo_diaria CHAR(2);
	DEFINE v_icada_x_dias INTEGER;
	DEFINE v_icada_x_semanas INTEGER;
	DEFINE v_sdias_semana CHAR(7);
	DEFINE v_stipo_mensual CHAR(2);
	DEFINE v_idia_x_del_mes INTEGER;
	DEFINE v_icada_x_meses INTEGER;
	DEFINE v_scve_ocurre CHAR(2);
	DEFINE v_scve_dia CHAR(2);
	DEFINE v_scve_canal CHAR(2);
	DEFINE v_scve_notifica CHAR(2);
	DEFINE v_sben_email CHAR(100);
	DEFINE v_sben_cve_compania CHAR(2);
	DEFINE v_sben_celular CHAR(10);
	DEFINE v_scve_notifica_emi CHAR(2);
	DEFINE v_semi_email CHAR(100);
	DEFINE v_semi_cve_compania CHAR(2);
	DEFINE v_semi_celular CHAR(40);
	DEFINE v_smensaje CHAR(100);
	DEFINE v_scve_estado CHAR(2);
	DEFINE v_suser_insert CHAR(8); 
	DEFINE v_dfecha_insert DATE;
	DEFINE v_suser_cancela CHAR(8);
	DEFINE v_dfecha_cancela DATE;
	DEFINE v_scanal_cancela CHAR(2);
		
	--Inicializacion de Variables
	LET v_sCodRet = '';
	LET v_sMensajeRet = '';
	LET v_scve_pagoprog = '';
	LET v_snum_cte = '';
	LET v_sdescripcion = '';
	LET v_scve_pago = '';
	LET v_scve_cuenta_ori = '';
	LET v_scuenta_origen = '';
	LET v_scve_cuenta_dest = '';
	LET v_scuenta_destino = '';
	LET v_sbanco_destino = '';
	LET v_sreferencia1 = '';
	LET v_sreferencia2 = '';
	LET v_sconvenio = '';
	LET v_mimporte = 0.00;
	LET v_sref_cobranza = '';
	LET v_mimporte_iva = 0.00;
	LET v_itipo_spei = 0;
	LET v_sconcepto = '';
	LET v_dfecha_inicio = '';
	LET v_scve_final = '';
	LET v_ino_repeticiones = 0;
	LET v_dfecha_fin = '';
	LET v_scve_programa = '';
	LET v_stipo_diaria = '';
	LET v_icada_x_dias = 0;
	LET v_icada_x_semanas = 0;
	LET v_sdias_semana = '';
	LET v_stipo_mensual = '';
	LET v_idia_x_del_mes = 0;
	LET v_icada_x_meses = 0;
	LET v_scve_ocurre = '';
	LET v_scve_dia = '';
	LET v_scve_canal = '';
	LET v_scve_notifica = '';
	LET v_sben_email = '';
	LET v_sben_cve_compania = '';
	LET v_sben_celular = '';
	LET v_scve_notifica_emi = '';
	LET v_semi_email = '';
	LET v_semi_cve_compania = '';
	LET v_semi_celular = '';
	LET v_smensaje = '';
	LET v_scve_estado = '';
	LET v_suser_insert = ''; 
	LET v_dfecha_insert = '';
	LET v_suser_cancela = '';
	LET v_dfecha_cancela = '';
	LET v_scanal_cancela = '';
	
	--debug
	--SET DEBUG FILE TO "/tmp/sp_ConsultarProgramacionGeneral.out";
    --	TRACE ON;
	
	--Cuerpo del procedimiento.
	BEGIN
		--Valida que los parametros de entrada sean diferentes a nulos o blancos
		IF (NVL(p_snum_cte,'') <> '')  THEN
		ELSE
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes where cve_mensaje = '104';
			RETURN v_sCodRet, v_sMensajeRet,v_scve_pagoprog,v_snum_cte,v_sdescripcion,v_scve_pago,v_scve_cuenta_ori,v_scuenta_origen,v_scve_cuenta_dest,
								v_scuenta_destino,v_sbanco_destino,v_sreferencia1,v_sreferencia2,v_sconvenio,v_mimporte,v_sref_cobranza,
								v_mimporte_iva,v_itipo_spei,v_sconcepto,v_dfecha_inicio,v_scve_final,v_ino_repeticiones,v_dfecha_fin,
								v_scve_programa,v_stipo_diaria,v_icada_x_dias,v_icada_x_semanas,v_sdias_semana,v_stipo_mensual,v_idia_x_del_mes,
								v_icada_x_meses,v_scve_ocurre,v_scve_dia,v_scve_canal,v_scve_notifica,v_sben_email,v_sben_cve_compania,
								v_sben_celular,v_scve_notifica_emi,v_semi_email,v_semi_cve_compania,v_semi_celular,v_smensaje,v_scve_estado,
								v_suser_insert,v_dfecha_insert,v_suser_cancela,v_dfecha_cancela,v_scanal_cancela;
		END IF;
		IF (NVL(p_sestado,'') <> '')  THEN
		ELSE
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes where cve_mensaje = '126';
			RETURN v_sCodRet, v_sMensajeRet,v_scve_pagoprog,v_snum_cte,v_sdescripcion,v_scve_pago,v_scve_cuenta_ori,v_scuenta_origen,v_scve_cuenta_dest,
								v_scuenta_destino,v_sbanco_destino,v_sreferencia1,v_sreferencia2,v_sconvenio,v_mimporte,v_sref_cobranza,
								v_mimporte_iva,v_itipo_spei,v_sconcepto,v_dfecha_inicio,v_scve_final,v_ino_repeticiones,v_dfecha_fin,
								v_scve_programa,v_stipo_diaria,v_icada_x_dias,v_icada_x_semanas,v_sdias_semana,v_stipo_mensual,v_idia_x_del_mes,
								v_icada_x_meses,v_scve_ocurre,v_scve_dia,v_scve_canal,v_scve_notifica,v_sben_email,v_sben_cve_compania,
								v_sben_celular,v_scve_notifica_emi,v_semi_email,v_semi_cve_compania,v_semi_celular,v_smensaje,v_scve_estado,
								v_suser_insert,v_dfecha_insert,v_suser_cancela,v_dfecha_cancela,v_scanal_cancela;
		END IF;
			--se valida que el cliente exista
			IF EXISTS(SELECT empresa  FROM bdinteg:si_cliente WHERE numcte =  p_snum_cte) THEN
				--SE EXCLUYEN LOS ESTADOS QUE NO APLICAN PARA CONSULTA DE PROGRAMACION GENERAL
				IF (p_sestado = '03') or (p_sestado = '05') or (p_sestado = '06') THEN
					SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes where cve_mensaje = '86';
					RETURN v_sCodRet, v_sMensajeRet,v_scve_pagoprog,v_snum_cte,v_sdescripcion,v_scve_pago,v_scve_cuenta_ori,v_scuenta_origen,v_scve_cuenta_dest,
							v_scuenta_destino,v_sbanco_destino,v_sreferencia1,v_sreferencia2,v_sconvenio,v_mimporte,v_sref_cobranza,
							v_mimporte_iva,v_itipo_spei,v_sconcepto,v_dfecha_inicio,v_scve_final,v_ino_repeticiones,v_dfecha_fin,
							v_scve_programa,v_stipo_diaria,v_icada_x_dias,v_icada_x_semanas,v_sdias_semana,v_stipo_mensual,v_idia_x_del_mes,
							v_icada_x_meses,v_scve_ocurre,v_scve_dia,v_scve_canal,v_scve_notifica,v_sben_email,v_sben_cve_compania,
							v_sben_celular,v_scve_notifica_emi,v_semi_email,v_semi_cve_compania,v_semi_celular,v_smensaje,v_scve_estado,
							v_suser_insert,v_dfecha_insert,v_suser_cancela,v_dfecha_cancela,v_scanal_cancela;
				END IF;
				--SE VALIDA EL VALOR DE ESTADO PERMITIDO
				IF p_sestado = '99' THEN
					--SE validaq que existan pagos programados para ese cliente
						IF EXISTS(SELECT descripcion FROM bdiprog:pp_pagoprog WHERE num_cte = p_snum_cte) THEN
							--Se seleccionan todos los pagos programados de ese cliente.
							FOREACH	
								SELECT cve_pagoprog,num_cte,descripcion,cve_pago,cve_cuenta_ori,cuenta_origen,cve_cuenta_dest,cuenta_destino,
										banco_destino,referencia1,referencia2,convenio,importe,ref_cobranza,importe_iva,tipo_spei,concepto,
										fecha_inicio,cve_final,no_repeticiones,fecha_fin,cve_programa,tipo_diaria,cada_x_dias,cada_x_semanas,
										dias_semana,tipo_mensual,dia_x_del_mes,cada_x_meses,cve_ocurre,cve_dia,cve_canal,cve_notifica,
										ben_email,ben_cve_compania,ben_celular,cve_notifica_emi,emi_email,emi_cve_compania,emi_celular,
										mensaje,cve_estado,user_insert,fecha_insert,user_cancela,fecha_cancela,canal_cancela 
								INTO   v_scve_pagoprog,v_snum_cte,v_sdescripcion,v_scve_pago,v_scve_cuenta_ori,v_scuenta_origen,v_scve_cuenta_dest,
										v_scuenta_destino,v_sbanco_destino,v_sreferencia1,v_sreferencia2,v_sconvenio,v_mimporte,v_sref_cobranza,
										v_mimporte_iva,v_itipo_spei,v_sconcepto,v_dfecha_inicio,v_scve_final,v_ino_repeticiones,v_dfecha_fin,
										v_scve_programa,v_stipo_diaria,v_icada_x_dias,v_icada_x_semanas,v_sdias_semana,v_stipo_mensual,v_idia_x_del_mes,
										v_icada_x_meses,v_scve_ocurre,v_scve_dia,v_scve_canal,v_scve_notifica,v_sben_email,v_sben_cve_compania,
										v_sben_celular,v_scve_notifica_emi,v_semi_email,v_semi_cve_compania,v_semi_celular,v_smensaje,v_scve_estado,
										v_suser_insert,v_dfecha_insert,v_suser_cancela,v_dfecha_cancela,v_scanal_cancela 		
								FROM bdiprog:pp_pagoprog 
								WHERE num_cte = p_snum_cte
								SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes where cve_mensaje = '00';
								RETURN v_sCodRet, v_sMensajeRet,v_scve_pagoprog,v_snum_cte,v_sdescripcion,v_scve_pago,v_scve_cuenta_ori,v_scuenta_origen,v_scve_cuenta_dest,
								v_scuenta_destino,v_sbanco_destino,v_sreferencia1,v_sreferencia2,v_sconvenio,v_mimporte,v_sref_cobranza,
								v_mimporte_iva,v_itipo_spei,v_sconcepto,v_dfecha_inicio,v_scve_final,v_ino_repeticiones,v_dfecha_fin,
								v_scve_programa,v_stipo_diaria,v_icada_x_dias,v_icada_x_semanas,v_sdias_semana,v_stipo_mensual,v_idia_x_del_mes,
								v_icada_x_meses,v_scve_ocurre,v_scve_dia,v_scve_canal,v_scve_notifica,v_sben_email,v_sben_cve_compania,
								v_sben_celular,v_scve_notifica_emi,v_semi_email,v_semi_cve_compania,v_semi_celular,v_smensaje,v_scve_estado,
								v_suser_insert,v_dfecha_insert,v_suser_cancela,v_dfecha_cancela,v_scanal_cancela WITH RESUME;
							END FOREACH;
						ELSE
						--Se informa que no existen pagos programados para ese cliente
							SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes where cve_mensaje = '88';
							RETURN v_sCodRet, v_sMensajeRet,v_scve_pagoprog,v_snum_cte,v_sdescripcion,v_scve_pago,v_scve_cuenta_ori,v_scuenta_origen,v_scve_cuenta_dest,
							v_scuenta_destino,v_sbanco_destino,v_sreferencia1,v_sreferencia2,v_sconvenio,v_mimporte,v_sref_cobranza,
							v_mimporte_iva,v_itipo_spei,v_sconcepto,v_dfecha_inicio,v_scve_final,v_ino_repeticiones,v_dfecha_fin,
							v_scve_programa,v_stipo_diaria,v_icada_x_dias,v_icada_x_semanas,v_sdias_semana,v_stipo_mensual,v_idia_x_del_mes,
							v_icada_x_meses,v_scve_ocurre,v_scve_dia,v_scve_canal,v_scve_notifica,v_sben_email,v_sben_cve_compania,
							v_sben_celular,v_scve_notifica_emi,v_semi_email,v_semi_cve_compania,v_semi_celular,v_smensaje,v_scve_estado,
							v_suser_insert,v_dfecha_insert,v_suser_cancela,v_dfecha_cancela,v_scanal_cancela;
						END IF;
				ELSE
					--se valida que exista en la tabla de estados
					IF EXISTS(SELECT descripcion FROM bdiprog:pp_estados WHERE cve_estado = p_sestado) THEN
						--SE validaq que existan pagos programados para ese cliente y ese estado
						IF EXISTS(SELECT descripcion FROM bdiprog:pp_pagoprog WHERE num_cte = p_snum_cte AND cve_estado = p_sestado) THEN
							--Se seleccionan todos los pagos programados de ese cliente y ese estado
							 FOREACH
								SELECT cve_pagoprog,num_cte,descripcion,cve_pago,cve_cuenta_ori,cuenta_origen,cve_cuenta_dest,cuenta_destino,
										banco_destino,referencia1,referencia2,convenio,importe,ref_cobranza,importe_iva,tipo_spei,concepto,
										fecha_inicio,cve_final,no_repeticiones,fecha_fin,cve_programa,tipo_diaria,cada_x_dias,cada_x_semanas,
										dias_semana,tipo_mensual,dia_x_del_mes,cada_x_meses,cve_ocurre,cve_dia,cve_canal,cve_notifica,
										ben_email,ben_cve_compania,ben_celular,cve_notifica_emi,emi_email,emi_cve_compania,emi_celular,
										mensaje,cve_estado,user_insert,fecha_insert,user_cancela,fecha_cancela,canal_cancela 
								INTO   v_scve_pagoprog,v_snum_cte,v_sdescripcion,v_scve_pago,v_scve_cuenta_ori,v_scuenta_origen,v_scve_cuenta_dest,
										v_scuenta_destino,v_sbanco_destino,v_sreferencia1,v_sreferencia2,v_sconvenio,v_mimporte,v_sref_cobranza,
										v_mimporte_iva,v_itipo_spei,v_sconcepto,v_dfecha_inicio,v_scve_final,v_ino_repeticiones,v_dfecha_fin,
										v_scve_programa,v_stipo_diaria,v_icada_x_dias,v_icada_x_semanas,v_sdias_semana,v_stipo_mensual,v_idia_x_del_mes,
										v_icada_x_meses,v_scve_ocurre,v_scve_dia,v_scve_canal,v_scve_notifica,v_sben_email,v_sben_cve_compania,
										v_sben_celular,v_scve_notifica_emi,v_semi_email,v_semi_cve_compania,v_semi_celular,v_smensaje,v_scve_estado,
										v_suser_insert,v_dfecha_insert,v_suser_cancela,v_dfecha_cancela,v_scanal_cancela 		
								FROM bdiprog:pp_pagoprog 
								WHERE num_cte = p_snum_cte
								AND cve_estado = p_sestado
								
								SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes where cve_mensaje = '00';
								RETURN v_sCodRet, v_sMensajeRet,v_scve_pagoprog,v_snum_cte,v_sdescripcion,v_scve_pago,v_scve_cuenta_ori,v_scuenta_origen,v_scve_cuenta_dest,
								v_scuenta_destino,v_sbanco_destino,v_sreferencia1,v_sreferencia2,v_sconvenio,v_mimporte,v_sref_cobranza,
								v_mimporte_iva,v_itipo_spei,v_sconcepto,v_dfecha_inicio,v_scve_final,v_ino_repeticiones,v_dfecha_fin,
								v_scve_programa,v_stipo_diaria,v_icada_x_dias,v_icada_x_semanas,v_sdias_semana,v_stipo_mensual,v_idia_x_del_mes,
								v_icada_x_meses,v_scve_ocurre,v_scve_dia,v_scve_canal,v_scve_notifica,v_sben_email,v_sben_cve_compania,
								v_sben_celular,v_scve_notifica_emi,v_semi_email,v_semi_cve_compania,v_semi_celular,v_smensaje,v_scve_estado,
								v_suser_insert,v_dfecha_insert,v_suser_cancela,v_dfecha_cancela,v_scanal_cancela WITH RESUME;
							END FOREACH;	
						ELSE
						--Se informa que no existen pagos programados para ese cliente y ese estado
							SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes where cve_mensaje = '88';
							RETURN v_sCodRet, v_sMensajeRet,v_scve_pagoprog,v_snum_cte,v_sdescripcion,v_scve_pago,v_scve_cuenta_ori,v_scuenta_origen,v_scve_cuenta_dest,
								v_scuenta_destino,v_sbanco_destino,v_sreferencia1,v_sreferencia2,v_sconvenio,v_mimporte,v_sref_cobranza,
								v_mimporte_iva,v_itipo_spei,v_sconcepto,v_dfecha_inicio,v_scve_final,v_ino_repeticiones,v_dfecha_fin,
								v_scve_programa,v_stipo_diaria,v_icada_x_dias,v_icada_x_semanas,v_sdias_semana,v_stipo_mensual,v_idia_x_del_mes,
								v_icada_x_meses,v_scve_ocurre,v_scve_dia,v_scve_canal,v_scve_notifica,v_sben_email,v_sben_cve_compania,
								v_sben_celular,v_scve_notifica_emi,v_semi_email,v_semi_cve_compania,v_semi_celular,v_smensaje,v_scve_estado,
								v_suser_insert,v_dfecha_insert,v_suser_cancela,v_dfecha_cancela,v_scanal_cancela;
						END IF;
					--se informa que el estado no existe
					ELSE
						SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes where cve_mensaje = '87';
						RETURN v_sCodRet, v_sMensajeRet,v_scve_pagoprog,v_snum_cte,v_sdescripcion,v_scve_pago,v_scve_cuenta_ori,v_scuenta_origen,v_scve_cuenta_dest,
								v_scuenta_destino,v_sbanco_destino,v_sreferencia1,v_sreferencia2,v_sconvenio,v_mimporte,v_sref_cobranza,
								v_mimporte_iva,v_itipo_spei,v_sconcepto,v_dfecha_inicio,v_scve_final,v_ino_repeticiones,v_dfecha_fin,
								v_scve_programa,v_stipo_diaria,v_icada_x_dias,v_icada_x_semanas,v_sdias_semana,v_stipo_mensual,v_idia_x_del_mes,
								v_icada_x_meses,v_scve_ocurre,v_scve_dia,v_scve_canal,v_scve_notifica,v_sben_email,v_sben_cve_compania,
								v_sben_celular,v_scve_notifica_emi,v_semi_email,v_semi_cve_compania,v_semi_celular,v_smensaje,v_scve_estado,
								v_suser_insert,v_dfecha_insert,v_suser_cancela,v_dfecha_cancela,v_scanal_cancela;
					END IF;
				END IF;			
			--Se informa que el cliente exista
			ELSE
				SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes where cve_mensaje = '04';
				RETURN v_sCodRet, v_sMensajeRet,v_scve_pagoprog,v_snum_cte,v_sdescripcion,v_scve_pago,v_scve_cuenta_ori,v_scuenta_origen,v_scve_cuenta_dest,
								v_scuenta_destino,v_sbanco_destino,v_sreferencia1,v_sreferencia2,v_sconvenio,v_mimporte,v_sref_cobranza,
								v_mimporte_iva,v_itipo_spei,v_sconcepto,v_dfecha_inicio,v_scve_final,v_ino_repeticiones,v_dfecha_fin,
								v_scve_programa,v_stipo_diaria,v_icada_x_dias,v_icada_x_semanas,v_sdias_semana,v_stipo_mensual,v_idia_x_del_mes,
								v_icada_x_meses,v_scve_ocurre,v_scve_dia,v_scve_canal,v_scve_notifica,v_sben_email,v_sben_cve_compania,
								v_sben_celular,v_scve_notifica_emi,v_semi_email,v_semi_cve_compania,v_semi_celular,v_smensaje,v_scve_estado,
								v_suser_insert,v_dfecha_insert,v_suser_cancela,v_dfecha_cancela,v_scanal_cancela;
			END IF;
	END;
END PROCEDURE;
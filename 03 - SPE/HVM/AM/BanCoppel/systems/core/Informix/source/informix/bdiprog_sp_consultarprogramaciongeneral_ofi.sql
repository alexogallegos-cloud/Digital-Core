CREATE PROCEDURE "informix".sp_consultarprogramaciongeneral_ofi(p_snum_cte Char(20),p_cve_pagoprog Char(10))
    RETURNING CHAR(5), CHAR(10),CHAR(20),CHAR(20),CHAR(2),CHAR(2),CHAR(20),CHAR(2),CHAR(20),CHAR(3),CHAR(40),CHAR(20),CHAR(5),MONEY(16,2),CHAR(40),MONEY(16,2),
		INTEGER,CHAR(60),DATE,CHAR(2),INTEGER,DATE,CHAR(2),CHAR(2),INTEGER,INTEGER,CHAR(7),CHAR(2),INTEGER,INTEGER,CHAR(2),CHAR(2),CHAR(2),CHAR(2),
        CHAR(40),CHAR(2),CHAR(10),CHAR(2),CHAR(40),CHAR(2),CHAR(10),CHAR(100),CHAR(2),CHAR(8), DATE,CHAR(8),DATE,CHAR(2), CHAR(60);

	--Definicion de Variables
	DEFINE v_sCodRet CHAR(5);
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
	DEFINE v_sben_email CHAR(40);
	DEFINE v_sben_cve_compania CHAR(2);
	DEFINE v_sben_celular CHAR(10);
	DEFINE v_scve_notifica_emi CHAR(2);
	DEFINE v_semi_email CHAR(40);
	DEFINE v_semi_cve_compania CHAR(2);
    DEFINE v_semi_celular CHAR(10);
	DEFINE v_smensaje CHAR(100);
	DEFINE v_scve_estado CHAR(2);
	DEFINE v_suser_insert CHAR(8);
	DEFINE v_dfecha_insert DATE;
	DEFINE v_suser_cancela CHAR(8);
	DEFINE v_dfecha_cancela DATE;
	DEFINE v_scanal_cancela CHAR(2);
    DEFINE v_nombre CHAR(60);

	--Inicializacion de Variables
	LET v_sCodRet = '';
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
	LET v_dfecha_insert = '';
	LET v_suser_cancela = '';
	LET v_dfecha_cancela = '';
	LET v_scanal_cancela = '';
    LET v_nombre = "";
	LET v_suser_insert = "";

	--SET DEBUG FILE TO "/tmp/sp_ConsultarProgramacionGeneral_ofi.out";
    ---TRACE ON;

	--Cuerpo del procedimiento.
	BEGIN
		--Valida que los parametros de entrada sean diferentes a nulos o blancos
		IF (NVL(p_snum_cte,'') <> '')  THEN
		ELSE
            SELECT cod_ret INTO v_sCodRet FROM bdiprog:pp_mensajes where cve_mensaje = '104';
            RETURN v_sCodRet, v_scve_pagoprog,v_snum_cte,v_sdescripcion,v_scve_pago,v_scve_cuenta_ori,v_scuenta_origen,v_scve_cuenta_dest,
								v_scuenta_destino,v_sbanco_destino,v_sreferencia1,v_sreferencia2,v_sconvenio,v_mimporte,v_sref_cobranza,
								v_mimporte_iva,v_itipo_spei,v_sconcepto,v_dfecha_inicio,v_scve_final,v_ino_repeticiones,v_dfecha_fin,
								v_scve_programa,v_stipo_diaria,v_icada_x_dias,v_icada_x_semanas,v_sdias_semana,v_stipo_mensual,v_idia_x_del_mes,
								v_icada_x_meses,v_scve_ocurre,v_scve_dia,v_scve_canal,v_scve_notifica,v_sben_email,v_sben_cve_compania,
								v_sben_celular,v_scve_notifica_emi,v_semi_email,v_semi_cve_compania,v_semi_celular,v_smensaje,v_scve_estado,
                                v_suser_insert,v_dfecha_insert,v_suser_cancela,v_dfecha_cancela,v_scanal_cancela,v_nombre;
		END IF;

			--se valida que el cliente exista
			IF EXISTS(SELECT empresa  FROM bdinteg:si_cliente WHERE numcte =  p_snum_cte) THEN
				--SE VALIDA EL VALOR DE CLAVE DE PROGRAMACION
				IF (p_cve_pagoprog <> "") AND (p_cve_pagoprog IS NOT NULL) THEN
					--SE validaq que existan pagos programados para ese cliente
						IF EXISTS(SELECT descripcion FROM bdiprog:pp_pagoprog WHERE num_cte = p_snum_cte AND cve_pagoprog = p_cve_pagoprog) THEN
							--Se seleccionan todos los pagos programados de ese cliente.
							IF EXISTS(SELECT cve_pago FROM bdiprog:pp_pagoprog WHERE num_cte = p_snum_cte AND cve_pagoprog = p_cve_pagoprog AND cve_pago = '01') THEN
								SELECT pp.cve_pagoprog,pp.num_cte,descripcion,pp.cve_pago,pp.cve_cuenta_ori,pp.cuenta_origen,pp.cve_cuenta_dest,pp.cuenta_destino,
									pp.banco_destino,pp.referencia1,pp.referencia2,pp.convenio,pp.importe,pp.ref_cobranza,pp.importe_iva,pp.tipo_spei,pp.concepto,
									pp.fecha_inicio,pp.cve_final,pp.no_repeticiones,pp.fecha_fin,pp.cve_programa,pp.tipo_diaria,pp.cada_x_dias,pp.cada_x_semanas,
									pp.dias_semana,pp.tipo_mensual,pp.dia_x_del_mes,pp.cada_x_meses,pp.cve_ocurre,pp.cve_dia,pp.cve_canal,pp.cve_notifica,
									pp.ben_email,pp.ben_cve_compania,pp.ben_celular,pp.cve_notifica_emi,pp.emi_email,pp.emi_cve_compania,pp.emi_celular,
									pp.mensaje,pp.cve_estado,pp.user_insert,pp.fecha_insert,pp.user_cancela,pp.fecha_cancela,pp.canal_cancela
								INTO   v_scve_pagoprog,v_snum_cte,v_sdescripcion,v_scve_pago,v_scve_cuenta_ori,v_scuenta_origen,v_scve_cuenta_dest,
									v_scuenta_destino,v_sbanco_destino,v_sreferencia1,v_sreferencia2,v_sconvenio,v_mimporte,v_sref_cobranza,
									v_mimporte_iva,v_itipo_spei,v_sconcepto,v_dfecha_inicio,v_scve_final,v_ino_repeticiones,v_dfecha_fin,
									v_scve_programa,v_stipo_diaria,v_icada_x_dias,v_icada_x_semanas,v_sdias_semana,v_stipo_mensual,v_idia_x_del_mes,
									v_icada_x_meses,v_scve_ocurre,v_scve_dia,v_scve_canal,v_scve_notifica,v_sben_email,v_sben_cve_compania,
									v_sben_celular,v_scve_notifica_emi,v_semi_email,v_semi_cve_compania,v_semi_celular,v_smensaje,v_scve_estado,
									v_suser_insert,v_dfecha_insert,v_suser_cancela,v_dfecha_cancela,v_scanal_cancela
								FROM bdiprog:pp_pagoprog pp
								WHERE pp.num_cte = p_snum_cte AND cve_pagoprog = p_cve_pagoprog;
							ELse
							    IF EXISTS(SELECT cve_pago FROM bdiprog:pp_pagoprog pp, bdiprog: pp_ctasterceros ct WHERE pp.num_cte = p_snum_cte AND cve_pagoprog = p_cve_pagoprog AND pp.num_cte = ct.num_cte AND pp.cuenta_destino = ct.cuenta) THEN 
										SELECT pp.cve_pagoprog,pp.num_cte,descripcion,pp.cve_pago,pp.cve_cuenta_ori,pp.cuenta_origen,pp.cve_cuenta_dest,pp.cuenta_destino,
												pp.banco_destino,pp.referencia1,pp.referencia2,pp.convenio,pp.importe,pp.ref_cobranza,pp.importe_iva,pp.tipo_spei,pp.concepto,
												pp.fecha_inicio,pp.cve_final,pp.no_repeticiones,pp.fecha_fin,pp.cve_programa,pp.tipo_diaria,pp.cada_x_dias,pp.cada_x_semanas,
												pp.dias_semana,pp.tipo_mensual,pp.dia_x_del_mes,pp.cada_x_meses,pp.cve_ocurre,pp.cve_dia,pp.cve_canal,pp.cve_notifica,
												pp.ben_email,pp.ben_cve_compania,pp.ben_celular,pp.cve_notifica_emi,pp.emi_email,pp.emi_cve_compania,pp.emi_celular,
												pp.mensaje,pp.cve_estado,pp.user_insert,pp.fecha_insert,pp.user_cancela,pp.fecha_cancela,pp.canal_cancela, ct.nombre
										INTO   v_scve_pagoprog,v_snum_cte,v_sdescripcion,v_scve_pago,v_scve_cuenta_ori,v_scuenta_origen,v_scve_cuenta_dest,
												v_scuenta_destino,v_sbanco_destino,v_sreferencia1,v_sreferencia2,v_sconvenio,v_mimporte,v_sref_cobranza,
												v_mimporte_iva,v_itipo_spei,v_sconcepto,v_dfecha_inicio,v_scve_final,v_ino_repeticiones,v_dfecha_fin,
												v_scve_programa,v_stipo_diaria,v_icada_x_dias,v_icada_x_semanas,v_sdias_semana,v_stipo_mensual,v_idia_x_del_mes,
												v_icada_x_meses,v_scve_ocurre,v_scve_dia,v_scve_canal,v_scve_notifica,v_sben_email,v_sben_cve_compania,
												v_sben_celular,v_scve_notifica_emi,v_semi_email,v_semi_cve_compania,v_semi_celular,v_smensaje,v_scve_estado,
												v_suser_insert,v_dfecha_insert,v_suser_cancela,v_dfecha_cancela,v_scanal_cancela, v_nombre
										FROM bdiprog:pp_pagoprog pp, bdiprog: pp_ctasterceros ct
										WHERE pp.num_cte = p_snum_cte AND cve_pagoprog = p_cve_pagoprog AND pp.num_cte = ct.num_cte AND pp.cuenta_destino = ct.cuenta AND pp.banco_destino = ct.cve_banco;
								ELSE
								    SELECT pp.cve_pagoprog,pp.num_cte,descripcion,pp.cve_pago,pp.cve_cuenta_ori,pp.cuenta_origen,pp.cve_cuenta_dest,pp.cuenta_destino,
											pp.banco_destino,pp.referencia1,pp.referencia2,pp.convenio,pp.importe,pp.ref_cobranza,pp.importe_iva,pp.tipo_spei,pp.concepto,
											pp.fecha_inicio,pp.cve_final,pp.no_repeticiones,pp.fecha_fin,pp.cve_programa,pp.tipo_diaria,pp.cada_x_dias,pp.cada_x_semanas,
											pp.dias_semana,pp.tipo_mensual,pp.dia_x_del_mes,pp.cada_x_meses,pp.cve_ocurre,pp.cve_dia,pp.cve_canal,pp.cve_notifica,
											pp.ben_email,pp.ben_cve_compania,pp.ben_celular,pp.cve_notifica_emi,pp.emi_email,pp.emi_cve_compania,pp.emi_celular,
											pp.mensaje,pp.cve_estado,pp.user_insert,pp.fecha_insert,pp.user_cancela,pp.fecha_cancela,pp.canal_cancela, ta.nombre
									INTO   v_scve_pagoprog,v_snum_cte,v_sdescripcion,v_scve_pago,v_scve_cuenta_ori,v_scuenta_origen,v_scve_cuenta_dest,
												v_scuenta_destino,v_sbanco_destino,v_sreferencia1,v_sreferencia2,v_sconvenio,v_mimporte,v_sref_cobranza,
												v_mimporte_iva,v_itipo_spei,v_sconcepto,v_dfecha_inicio,v_scve_final,v_ino_repeticiones,v_dfecha_fin,
												v_scve_programa,v_stipo_diaria,v_icada_x_dias,v_icada_x_semanas,v_sdias_semana,v_stipo_mensual,v_idia_x_del_mes,
												v_icada_x_meses,v_scve_ocurre,v_scve_dia,v_scve_canal,v_scve_notifica,v_sben_email,v_sben_cve_compania,
												v_sben_celular,v_scve_notifica_emi,v_semi_email,v_semi_cve_compania,v_semi_celular,v_smensaje,v_scve_estado,
												v_suser_insert,v_dfecha_insert,v_suser_cancela,v_dfecha_cancela,v_scanal_cancela, v_nombre		
									FROM bdiprog:pp_pagoprog pp, bdicred:sd_tarjeta ta
									WHERE pp.num_cte = p_snum_cte AND cve_pagoprog = p_cve_pagoprog AND pp.num_cte = ta.numcte AND pp.cuenta_destino = ta.num_tarjeta; 
                                END IF								
							END IF
                                SELECT cod_ret INTO v_sCodRet FROM bdiprog:pp_mensajes where cve_mensaje = '00';

                                RETURN v_sCodRet, v_scve_pagoprog,v_snum_cte,v_sdescripcion,v_scve_pago,v_scve_cuenta_ori,v_scuenta_origen,v_scve_cuenta_dest,
								v_scuenta_destino,v_sbanco_destino,v_sreferencia1,v_sreferencia2,v_sconvenio,v_mimporte,v_sref_cobranza,
								v_mimporte_iva,v_itipo_spei,v_sconcepto,v_dfecha_inicio,v_scve_final,v_ino_repeticiones,v_dfecha_fin,
								v_scve_programa,v_stipo_diaria,v_icada_x_dias,v_icada_x_semanas,v_sdias_semana,v_stipo_mensual,v_idia_x_del_mes,
								v_icada_x_meses,v_scve_ocurre,v_scve_dia,v_scve_canal,v_scve_notifica,v_sben_email,v_sben_cve_compania,
								v_sben_celular,v_scve_notifica_emi,v_semi_email,v_semi_cve_compania,v_semi_celular,v_smensaje,v_scve_estado,
                                v_suser_insert,v_dfecha_insert,v_suser_cancela,v_dfecha_cancela,v_scanal_cancela, v_nombre;

						ELSE
						--Se informa que no existen pagos programados para ese cliente
                            SELECT cod_ret INTO v_sCodRet FROM bdiprog:pp_mensajes where cve_mensaje = '88';
                            RETURN v_sCodRet, v_scve_pagoprog,v_snum_cte,v_sdescripcion,v_scve_pago,v_scve_cuenta_ori,v_scuenta_origen,v_scve_cuenta_dest,
							v_scuenta_destino,v_sbanco_destino,v_sreferencia1,v_sreferencia2,v_sconvenio,v_mimporte,v_sref_cobranza,
							v_mimporte_iva,v_itipo_spei,v_sconcepto,v_dfecha_inicio,v_scve_final,v_ino_repeticiones,v_dfecha_fin,
							v_scve_programa,v_stipo_diaria,v_icada_x_dias,v_icada_x_semanas,v_sdias_semana,v_stipo_mensual,v_idia_x_del_mes,
							v_icada_x_meses,v_scve_ocurre,v_scve_dia,v_scve_canal,v_scve_notifica,v_sben_email,v_sben_cve_compania,
							v_sben_celular,v_scve_notifica_emi,v_semi_email,v_semi_cve_compania,v_semi_celular,v_smensaje,v_scve_estado,
                            v_suser_insert,v_dfecha_insert,v_suser_cancela,v_dfecha_cancela,v_scanal_cancela, v_nombre;
						END IF;

				END IF;
			--Se informa que el cliente exista
			ELSE
                SELECT cod_ret INTO v_sCodRet FROM bdiprog:pp_mensajes where cve_mensaje = '04';
                RETURN v_sCodRet, v_scve_pagoprog,v_snum_cte,v_sdescripcion,v_scve_pago,v_scve_cuenta_ori,v_scuenta_origen,v_scve_cuenta_dest,
								v_scuenta_destino,v_sbanco_destino,v_sreferencia1,v_sreferencia2,v_sconvenio,v_mimporte,v_sref_cobranza,
								v_mimporte_iva,v_itipo_spei,v_sconcepto,v_dfecha_inicio,v_scve_final,v_ino_repeticiones,v_dfecha_fin,
								v_scve_programa,v_stipo_diaria,v_icada_x_dias,v_icada_x_semanas,v_sdias_semana,v_stipo_mensual,v_idia_x_del_mes,
								v_icada_x_meses,v_scve_ocurre,v_scve_dia,v_scve_canal,v_scve_notifica,v_sben_email,v_sben_cve_compania,
								v_sben_celular,v_scve_notifica_emi,v_semi_email,v_semi_cve_compania,v_semi_celular,v_smensaje,v_scve_estado,
                                v_suser_insert,v_dfecha_insert,v_suser_cancela,v_dfecha_cancela,v_scanal_cancela, v_nombre;
			END IF;
	END;
--##############################################################################
--## Procedimiento   : sp_ConsultarProgramacionGeneral_ofi
--## Version         : 1.0
--## Creado por      : Mohamed Carreón
--## Fecha creacion  : Diciembre de 2008
--##Descripcion      : Consulta la programacion general de un cliente y clave de programacion
--##Modifico         : Saul Ivanhoe
--##Fecha Modificacion : 25-Feb-2009
--##Descripcion      : Consulta las cuentas propias de credito de un cliente
--##############################################################################
END PROCEDURE;
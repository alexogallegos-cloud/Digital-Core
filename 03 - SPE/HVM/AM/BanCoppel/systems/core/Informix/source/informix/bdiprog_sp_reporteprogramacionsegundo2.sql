CREATE PROCEDURE "informix".sp_reporteprogramacionsegundo2(p_tiporeporte CHAR(2),p_numcte CHAR(20),p_cve_pago CHAR(2),p_fecha_inicio DATE,p_fecha_fin DATE,pRegistros INTEGER, pRecuperacion INTEGER)
			RETURNING CHAR(5) as CodRet,CHAR(60) as MensajeRet,DATE as FechaSolicitud,DATE as FechaAplicacion,CHAR(100) as Sucursal, CHAR(10) as PeriodoPago,CHAR(10) as MedioSolicitud,
			CHAR(20) as CuentaOrigen,CHAR(20) as CuentaDestino,MONEY(16,2) as Monto,CHAR(60) as TipoPago,CHAR(16) as Aviso,CHAR(10) as Estatus,CHAR(10) as NumeroPago,
			CHAR(50) as CausaRechazo,DATE as FechaCancela;

			---**********************************************************
	-- Realizo   :Alejandro Osuna
	--Solicito : Jorge NuÃ±ez
	-- Proyecto :  Pagos Programados
	-- Actividad : Obtiene lso datos necesarios para los reportes.
	-- Fecha     :25 de  Novimebre  de 2008
    -- Modifico Alejandro Osuna
	--Fecha: Enero 2009
	--Se valida el campo clave de pago para que solo acepte numeros
	-- Modifico Alejandro Osuna
	--Fecha: 01-junio-2009
	--La validacion  de la descripcion de la causa de rechazo de elimino
	--Fecha: 15/09/2010
	--Se agrega parÃ¡metro de salida sucursal el cual se compone del numero de sucursal mas la descripciÃ³n de la sucursal.
	--******************************************************
	--DEFINICION DE VARIABLES
	DEFINE v_sCodRet CHAR(5);
	DEFINE v_sMensajeRet CHAR(60);
	DEFINE v_dFechaSoli DATE;
	DEFINE v_dFechaApli DATE;
	DEFINE v_sPerioPago CHAR(2);
	DEFINE v_sMedioSoli CHAR(2);
	DEFINE v_sCuentaO CHAR(20);
	DEFINE v_sCuentaD CHAR(20);
	DEFINE v_mMonto MONEY(16,2);
	DEFINE v_sTipoPago CHAR(2);
	DEFINE v_scve_notifica CHAR(8);
	DEFINE v_scve_notifica_emi CHAR(8);
	DEFINE v_sAviso CHAR(16);
	DEFINE v_sEstatus CHAR(2);
	DEFINE v_sNumPago CHAR(10);
	DEFINE v_sNumaviso CHAR(10);
	DEFINE v_sCausaRe CHAR (5);
	DEFINE v_dFechaCan DATE;
	DEFINE sql_err  SMALLINT;
	DEFINE v_sBandera CHAR (5);
	DEFINE v_dFechaBandera date;
	DEFINE v_sCiclo CHAR (1);
	DEFINE v_sEstado CHAR(2);
	DEFINE v_sPeridoDesc CHAR(10);
	DEFINE v_sMedioDesc CHAR(10);
	DEFINE v_sPagoDesc CHAR (60);
	DEFINE v_sEstadoDesc CHAR(10);
	DEFINE v_sRechaDesc CHAR(50);	
	DEFINE v_sSucursal CHAR(100);
	DEFINE v_sNumSucursal CHAR(4);
	DEFINE v_sDescSucursal CHAR(40);
	DEFINE v_sUser CHAR(30);
	--Inicializacion de las variables
	LET v_sCodRet = '';
	LET v_sMensajeRet = '';
	LET v_sPerioPago = '';
	LET v_sMedioSoli = '';
	LET v_sCuentaO = '';
	LET v_sCuentaD = '';
	LET v_mMonto = 0.00;
	LET v_sTipoPago = '';
	LET v_scve_notifica_emi = '';
	LET v_scve_notifica = '';
	LET v_sAviso = '';
	LET v_sEstatus = '';
	LET v_sNumPago = '';
	LET v_sCausaRe = '';
	LET v_dFechaSoli = '01/01/1900';
	LET v_dFechaApli = '01/01/1900';
	LET v_dFechaCan = '01/01/1900';
	LET v_sBandera = '';
	LET v_sCiclo = '';
	LET v_sEstado  = '';
	LET v_sNumaviso = '';
	LET v_sPeridoDesc = '';
	LET v_sMedioDesc = '';
	LET v_sPagoDesc = '';
	LET v_sRechaDesc = '';
	LET v_sEstadoDesc = '';	
	LET v_sUser = '';
	LET v_sSucursal = '';
	LET v_sNumSucursal = '';
	LET v_sDescSucursal = '';
	
	--SET DEBUG FILE TO '/tmp/mfinis/sp_reporteprogramacionsegundo2.out';
    --TRACE ON;
        
	BEGIN
		ON EXCEPTION SET  sql_err
			IF sql_err <> 0 THEN
				let v_sCodRet =  sql_err;
				let v_sMensajeRet  =  "Reporte de Programacion no Realizado";
				RETURN v_sCodRet,v_sMensajeRet,v_dFechaSoli,v_dFechaApli,v_sSucursal,v_sPeridoDesc,v_sMedioDesc,v_sCuentaO,v_sCuentaD,v_mMonto,v_sPagoDesc,
					v_sAviso,v_sEstadoDesc,v_sNumPago,v_sRechaDesc,v_dFechaCan;
			END IF;
		END EXCEPTION;

		--Se valida que el tipo de reporte sea diferente a blanco o nulo
		IF(NVL(p_tiporeporte,'') <> '') THEN
			--Se valida que el tipo de reporte exista en la tabla de parametros
			IF EXISTS(SELECT desc_valor  FROM bdiprog:pp_parametros WHERE cve_param = '15' AND valor = p_tiporeporte) THEN
				EXECUTE PROCEDURE sp_ClaveReporte(p_tiporeporte,p_numcte,p_cve_pago,p_fecha_inicio,p_fecha_fin) INTO v_sBandera;
				LET v_sBandera = TRIM(v_sBandera);
                IF (v_sBandera = '1000') OR (v_sBandera = '2000') OR (v_sBandera = '3000') OR (v_sBandera = '4000') THEN
					IF v_sBandera = '1000' THEN
                        FOREACH
							SELECT SKIP pRegistros FIRST pRecuperacion b.fecha_insert,b.fecha_prog,a.cve_programa,a.cve_canal,a.cuenta_origen,a.cuenta_destino,a.importe,a.cve_pago,b.estado,b.consecutivo,a.cve_pagoprog,a.user_insert
							INTO v_dFechaSoli, v_dFechaApli,v_sPerioPago,v_sMedioSoli,v_sCuentaO,v_sCuentaD,v_mMonto,v_sTipoPago,v_sEstatus,v_sNumPago,v_sNumaviso,v_sUser
							FROM bdiprog:pp_pagoprog AS a INNER JOIN bdiprog:pp_pagospend AS b ON a.cve_pagoprog = b.cve_pagoprog
							ORDER BY b.fecha_prog,a.cve_pago,a.cuenta_origen,a.cuenta_destino
							
							IF v_sUser = 'transBPI' THEN
								LET v_sSucursal = '5003-Internet';
							ELSE											
								SELECT a.sucursal,b.nombre
								INTO v_sNumSucursal,v_sDescSucursal
								FROM bdinteg:si_ejecut as a 
								LEFT JOIN bdinteg:si_sucursales as b ON (a.sucursal=b.sucursal)
								WHERE a.ejecutivo = v_sUser;											
								LET v_sSucursal = NVL(v_sNumSucursal,'') || '-' || NVL(v_sDescSucursal,'');
							END IF;

							SELECT  TRIM(descripcion)
							INTO v_sPeridoDesc
							FROM  bdiprog:pp_tpprograma
							WHERE cve_programa = v_sPerioPago;

							SELECT  TRIM(descripcion)
							INTO v_sMedioDesc
							FROM  bdiprog:pp_tpcanal
							WHERE cve_canal = v_sMedioSoli;

							IF v_sTipoPago = '01' THEN
								LET v_sPagoDesc = 'Tras.Propio';
							END IF;
							IF v_sTipoPago = '02' THEN
								LET v_sPagoDesc = 'Tras.Tercero';
							END IF;
							IF v_sTipoPago = '03' THEN
								LET v_sPagoDesc = 'SPEI';
							END IF;
							IF v_sTipoPago = '04' THEN
								LET v_sPagoDesc = 'Pago Telmex';
							END IF;
							IF v_sTipoPago = '05' THEN
								LET v_sPagoDesc = 'Pago T.Cred.';
							END IF;

							SELECT TRIM(descripcion)
							INTO v_sEstadoDesc
							FROM bdiprog:pp_estados
							WHERE cve_estado = v_sEstatus;

							SELECT cve_notifica,cve_notifica_emi
							INTO v_scve_notifica,v_scve_notifica_emi
							FROM bdiprog:pp_pagoprog
							WHERE cve_pagoprog = v_sNumaviso;
							IF v_scve_notifica = '00'  THEN
							LET v_scve_notifica = '---';
							END IF;
							IF v_scve_notifica = '01'THEN
	                                                    LET v_scve_notifica = 'E-Mail';
							END IF;
							IF v_scve_notifica = '02'THEN
	                            LET v_scve_notifica = 'SMS';
							END IF;
							IF v_scve_notifica = '03'THEN
								LET v_scve_notifica = 'AMBAS';
							END IF;
							IF v_scve_notifica_emi = '00'  THEN
								LET v_scve_notifica_emi = '---';
							END IF;
							IF v_scve_notifica_emi = '01'THEN
								LET v_scve_notifica_emi = 'E-Mail';
							END IF;
							IF v_scve_notifica_emi = '02'THEN
								LET v_scve_notifica_emi = 'SMS';
							END IF;
							IF v_scve_notifica_emi = '03'THEN
								LET v_scve_notifica_emi = 'AMBAS';
							END IF;
							LET v_sAviso = TRIM(v_scve_notifica) || '/' || TRIM(v_scve_notifica_emi);

							SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '00';
							RETURN v_sCodRet,v_sMensajeRet,v_dFechaSoli,v_dFechaApli,v_sSucursal,v_sPeridoDesc,v_sMedioDesc,v_sCuentaO,v_sCuentaD,v_mMonto,v_sPagoDesc,
									v_sAviso,v_sEstadoDesc,v_sNumPago,v_sRechaDesc,v_dFechaCan WITH RESUME;
						END FOREACH;
					END IF;
					--Reporte de pagos realizados
					IF v_sBandera = '2000' THEN
						FOREACH
							SELECT SKIP pRegistros FIRST pRecuperacion b.fecha_insert,b.fecha_aplic,a.cuenta_origen,a.cuenta_destino,a.importe,a.cve_pago,b.consecutivo,a.cve_pagoprog
							INTO v_dFechaSoli, v_dFechaApli,v_sCuentaO,v_sCuentaD,v_mMonto,v_sTipoPago,v_sNumPago,v_sNumaviso
							FROM bdiprog:pp_pagoprog AS a INNER JOIN bdiprog:pp_pagospend AS b ON a.cve_pagoprog = b.cve_pagoprog
							WHERE  b.estado = '05'
							ORDER BY b.fecha_aplic,a.cve_pago,a.cuenta_origen,a.cuenta_destino

							IF v_sTipoPago = '01' THEN
								LET v_sPagoDesc = 'Tras.Propio';
							END IF;
							IF v_sTipoPago = '02' THEN
								LET v_sPagoDesc = 'Tras.Tercero';
							END IF;
							IF v_sTipoPago = '03' THEN
								LET v_sPagoDesc = 'SPEI';
							END IF;
							IF v_sTipoPago = '04' THEN
								LET v_sPagoDesc = 'Pago Telmex';
							END IF;
							IF v_sTipoPago = '05' THEN
								LET v_sPagoDesc = 'Pago T.Cred.';
							END IF;

							SELECT cve_notifica,cve_notifica_emi
							INTO v_scve_notifica,v_scve_notifica_emi
							FROM bdiprog:pp_pagoprog
							WHERE cve_pagoprog = v_sNumaviso;

							IF v_scve_notifica = '00'  THEN
								LET v_scve_notifica = '---';
							END IF;
							IF v_scve_notifica = '01'THEN
								LET v_scve_notifica = 'E-Mail';
							END IF;
							IF v_scve_notifica = '02'THEN
								LET v_scve_notifica = 'SMS';
							END IF;
							IF v_scve_notifica = '03'THEN
								LET v_scve_notifica = 'AMBAS';
							END IF;
							IF v_scve_notifica_emi = '00'  THEN
								LET v_scve_notifica_emi = '---';
							END IF;
							IF v_scve_notifica_emi = '01'THEN
								LET v_scve_notifica_emi = 'E-Mail';
							END IF;
							IF v_scve_notifica_emi = '02'THEN
								LET v_scve_notifica_emi = 'SMS';
							END IF;
							IF v_scve_notifica_emi = '03'THEN
								LET v_scve_notifica_emi = 'AMBAS';
							END IF;
							LET v_sAviso = TRIM(v_scve_notifica) || '/' || TRIM(v_scve_notifica_emi);
							SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '00';
							RETURN v_sCodRet,v_sMensajeRet,v_dFechaSoli,v_dFechaApli,v_sSucursal,v_sPeridoDesc,v_sMedioDesc,v_sCuentaO,v_sCuentaD,v_mMonto,v_sPagoDesc,
									v_sAviso,v_sEstadoDesc,v_sNumPago,v_sRechaDesc,v_dFechaCan WITH RESUME;
						END FOREACH;
					END IF;
					--Reporte depagos rechazados por busqueda rango de fechas
					IF v_sBandera = '3000' THEN
						FOREACH
							SELECT SKIP pRegistros FIRST pRecuperacion b.fecha_insert,b.fecha_prog,a.cuenta_origen,a.cuenta_destino,a.importe,a.cve_pago,b.consecutivo,b.cve_rechazo,a.cve_pagoprog
							INTO v_dFechaSoli, v_dFechaApli,v_sCuentaO,v_sCuentaD,v_mMonto,v_sTipoPago,v_sNumPago,v_sCausaRe,v_sNumaviso
							FROM bdiprog:pp_pagoprog AS a INNER JOIN bdiprog:pp_pagospend AS b ON a.cve_pagoprog = b.cve_pagoprog
							WHERE  b.estado = '06'
							ORDER BY b.fecha_prog,a.cve_pago,a.cuenta_origen,a.cuenta_destino

							IF v_sTipoPago = '01' THEN
								LET v_sPagoDesc = 'Tras.Propio';
							END IF;
							IF v_sTipoPago = '02' THEN
								LET v_sPagoDesc = 'Tras.Tercero';
							END IF;
							IF v_sTipoPago = '03' THEN
								LET v_sPagoDesc = 'SPEI';
							END IF;
							IF v_sTipoPago = '04' THEN
								LET v_sPagoDesc = 'Pago Telmex';
							END IF;
							IF v_sTipoPago = '05' THEN
								LET v_sPagoDesc = 'Pago T.Cred.';
							END IF;

							SELECT  TRIM(descripcion)
							INTO v_sRechaDesc
							FROM  bdiprog:pp_tprechazo
							WHERE cve_rechazo = v_sCausaRe;

							SELECT cve_notifica,cve_notifica_emi
							INTO v_scve_notifica,v_scve_notifica_emi
							FROM bdiprog:pp_pagoprog
							WHERE cve_pagoprog = v_sNumaviso;
							IF v_scve_notifica = '00'  THEN
								LET v_scve_notifica = '---';
							END IF;
							IF v_scve_notifica = '01'THEN
								LET v_scve_notifica = 'E-Mail';
							END IF;
							IF v_scve_notifica = '02'THEN
								LET v_scve_notifica = 'SMS';
							END IF;
							IF v_scve_notifica = '03'THEN
								LET v_scve_notifica = 'AMBAS';
							END IF;
							IF v_scve_notifica_emi = '00'  THEN
								LET v_scve_notifica_emi = '---';
							END IF;
							IF v_scve_notifica_emi = '01'THEN
								LET v_scve_notifica_emi = 'E-Mail';
							END IF;
							IF v_scve_notifica_emi = '02'THEN
								LET v_scve_notifica_emi = 'SMS';
							END IF;
							IF v_scve_notifica_emi = '03'THEN
								LET v_scve_notifica_emi = 'AMBAS';
							END IF;
							LET v_sAviso = TRIM(v_scve_notifica) || '/' || TRIM(v_scve_notifica_emi);
							SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '00';
							RETURN v_sCodRet,v_sMensajeRet,v_dFechaSoli,v_dFechaApli,v_sSucursal,v_sPeridoDesc,v_sMedioDesc,v_sCuentaO,v_sCuentaD,v_mMonto,v_sPagoDesc,
									v_sAviso,v_sEstadoDesc,v_sNumPago,v_sRechaDesc,v_dFechaCan WITH RESUME;
						END FOREACH;
					END IF;
					--Reporte depagos cancelados por busqueda rango de fechas
					IF v_sBandera = '4000' THEN
						FOREACH
							SELECT SKIP pRegistros FIRST pRecuperacion b.fecha_insert,b.fecha_cancela,a.cuenta_origen,a.cuenta_destino,a.importe,a.cve_pago,b.consecutivo,a.cve_pagoprog
							INTO v_dFechaSoli, v_dFechaCan,v_sCuentaO,v_sCuentaD,v_mMonto,v_sTipoPago,v_sNumPago,v_sNumaviso
							FROM bdiprog:pp_pagoprog AS a INNER JOIN bdiprog:pp_pagospend AS b ON a.cve_pagoprog = b.cve_pagoprog
							WHERE  b.estado = '02'
							ORDER BY b.fecha_cancela,a.cve_pago,a.cuenta_origen,a.cuenta_destino

							IF v_sTipoPago = '01' THEN
								LET v_sPagoDesc = 'Tras.Propio';
							END IF;
							IF v_sTipoPago = '02' THEN
								LET v_sPagoDesc = 'Tras.Tercero';
							END IF;
							IF v_sTipoPago = '03' THEN
								LET v_sPagoDesc = 'SPEI';
							END IF;
							IF v_sTipoPago = '04' THEN
								LET v_sPagoDesc = 'Pago Telmex';
							END IF;
							IF v_sTipoPago = '05' THEN
								LET v_sPagoDesc = 'Pago T.Cred.';
							END IF;

							SELECT cve_notifica,cve_notifica_emi
							INTO v_scve_notifica,v_scve_notifica_emi
							FROM bdiprog:pp_pagoprog
							WHERE cve_pagoprog = v_sNumaviso;
							IF v_scve_notifica = '00'  THEN
								LET v_scve_notifica = '---';
							END IF;
							IF v_scve_notifica = '01'THEN
								LET v_scve_notifica = 'E-Mail';
							END IF;
							IF v_scve_notifica = '02'THEN
								LET v_scve_notifica = 'SMS';
							END IF;
							IF v_scve_notifica = '03'THEN
								LET v_scve_notifica = 'AMBAS';
							END IF;
							IF v_scve_notifica_emi = '00'  THEN
								LET v_scve_notifica_emi = '---';
							END IF;
							IF v_scve_notifica_emi = '01'THEN
								LET v_scve_notifica_emi = 'E-Mail';
							END IF;
							IF v_scve_notifica_emi = '02'THEN
								LET v_scve_notifica_emi = 'SMS';
							END IF;
							IF v_scve_notifica_emi = '03'THEN
								LET v_scve_notifica_emi = 'AMBAS';
							END IF;
							LET v_dFechaApli = '';
							LET v_sAviso = TRIM(v_scve_notifica) || '/' || TRIM(v_scve_notifica_emi);
							SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '00';
							RETURN v_sCodRet,v_sMensajeRet,v_dFechaSoli,v_dFechaApli,v_sSucursal,v_sPeridoDesc,v_sMedioDesc,v_sCuentaO,v_sCuentaD,v_mMonto,v_sPagoDesc,
									v_sAviso,v_sEstadoDesc,v_sNumPago,v_sRechaDesc,v_dFechaCan WITH RESUME;
						END FOREACH;
					END IF;
				END IF;
				--Busqueda por rango de fecha
				IF (v_sBandera = '1001') OR (v_sBandera = '2001') OR (v_sBandera = '3001') OR (v_sBandera = '4001') THEN
					--Se valida que la fecha inicial es menor que la fecha fin
					IF p_fecha_inicio <= p_fecha_fin THEN
						--Se valida que existan pagos para ese rango de fechas para ese cliente y para esa clave de pago
						IF EXISTS (SELECT estado  FROM bdiprog:pp_pagospend  WHERE fecha_prog between p_fecha_inicio and p_fecha_fin) THEN
							--Reporte de pagos programados por busqueda  rango de fechas
							IF v_sBandera = '1001' THEN
								FOREACH
									SELECT SKIP pRegistros FIRST pRecuperacion b.fecha_insert,b.fecha_prog,a.cve_programa,a.cve_canal,a.cuenta_origen,a.cuenta_destino,a.importe,a.cve_pago,b.estado,b.consecutivo,a.cve_pagoprog,a.user_insert
									INTO v_dFechaSoli, v_dFechaApli,v_sPerioPago,v_sMedioSoli,v_sCuentaO,v_sCuentaD,v_mMonto,v_sTipoPago,v_sEstatus,v_sNumPago,v_sNumaviso,v_sUser
									FROM bdiprog:pp_pagoprog AS a INNER JOIN bdiprog:pp_pagospend AS b ON a.cve_pagoprog = b.cve_pagoprog
									WHERE b.fecha_prog between p_fecha_inicio and p_fecha_fin
									ORDER BY b.fecha_prog,a.cve_pago,a.cuenta_origen,a.cuenta_destino
									
									IF v_sUser = 'transBPI' THEN
										LET v_sSucursal = '5003-Internet';
									ELSE											
										SELECT a.sucursal,b.nombre
										INTO v_sNumSucursal,v_sDescSucursal
										FROM bdinteg:si_ejecut as a 
										LEFT JOIN bdinteg:si_sucursales as b ON (a.sucursal=b.sucursal)
										WHERE a.ejecutivo = v_sUser;											
										LET v_sSucursal = NVL(v_sNumSucursal,'') || '-' || NVL(v_sDescSucursal,'');
									END IF;

									SELECT  TRIM(descripcion)
									INTO v_sPeridoDesc
									FROM  bdiprog:pp_tpprograma
									WHERE cve_programa = v_sPerioPago;

									SELECT  TRIM(descripcion)
									INTO v_sMedioDesc
									FROM  bdiprog:pp_tpcanal
									WHERE cve_canal = v_sMedioSoli;

									IF v_sTipoPago = '01' THEN
										LET v_sPagoDesc = 'Tras.Propio';
									END IF;
									IF v_sTipoPago = '02' THEN
										LET v_sPagoDesc = 'Tras.Tercero';
									END IF;
									IF v_sTipoPago = '03' THEN
										LET v_sPagoDesc = 'SPEI';
									END IF;
									IF v_sTipoPago = '04' THEN
										LET v_sPagoDesc = 'Pago Telmex';
									END IF;
									IF v_sTipoPago = '05' THEN
										LET v_sPagoDesc = 'Pago T.Cred.';
									END IF;

									SELECT TRIM(descripcion)
									INTO v_sEstadoDesc
									FROM bdiprog:pp_estados
									WHERE cve_estado = v_sEstatus;

									SELECT cve_notifica,cve_notifica_emi
									INTO v_scve_notifica,v_scve_notifica_emi
									FROM bdiprog:pp_pagoprog
									WHERE cve_pagoprog = v_sNumaviso;
									IF v_scve_notifica = '00'  THEN
										LET v_scve_notifica = '---';
									END IF;
									IF v_scve_notifica = '01'THEN
										LET v_scve_notifica = 'E-Mail';
									END IF;
									IF v_scve_notifica = '02'THEN
										LET v_scve_notifica = 'SMS';
									END IF;
									IF v_scve_notifica = '03'THEN
										LET v_scve_notifica = 'AMBAS';
									END IF;
									IF v_scve_notifica_emi = '00'  THEN
										LET v_scve_notifica_emi = '---';
									END IF;
									IF v_scve_notifica_emi = '01'THEN
										LET v_scve_notifica_emi = 'E-Mail';
									END IF;
									IF v_scve_notifica_emi = '02'THEN
										LET v_scve_notifica_emi = 'SMS';
									END IF;
									IF v_scve_notifica_emi = '03'THEN
										LET v_scve_notifica_emi = 'AMBAS';
									END IF;
									LET v_sAviso = TRIM(v_scve_notifica) || '/' || TRIM(v_scve_notifica_emi);


									SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '00';
									RETURN v_sCodRet,v_sMensajeRet,v_dFechaSoli,v_dFechaApli,v_sSucursal,v_sPeridoDesc,v_sMedioDesc,v_sCuentaO,v_sCuentaD,v_mMonto,v_sPagoDesc,
											v_sAviso,v_sEstadoDesc,v_sNumPago,v_sRechaDesc,v_dFechaCan WITH RESUME;
								END FOREACH;
							END IF;
							--Reporte de pagos realizados por busqueda rango de fechas
							IF v_sBandera = '2001' THEN
								FOREACH
									SELECT SKIP pRegistros FIRST pRecuperacion b.fecha_insert,b.fecha_aplic,a.cuenta_origen,a.cuenta_destino,a.importe,a.cve_pago,b.consecutivo,a.cve_pagoprog
									INTO v_dFechaSoli, v_dFechaApli,v_sCuentaO,v_sCuentaD,v_mMonto,v_sTipoPago,v_sNumPago,v_sNumaviso
									FROM bdiprog:pp_pagoprog AS a INNER JOIN bdiprog:pp_pagospend AS b ON a.cve_pagoprog = b.cve_pagoprog
									WHERE b.fecha_aplic between p_fecha_inicio and p_fecha_fin
									AND  b.estado = '05'
									ORDER BY b.fecha_aplic,a.cve_pago,a.cuenta_origen,a.cuenta_destino
									
									IF v_sTipoPago = '01' THEN
										LET v_sPagoDesc = 'Tras.Propio';
									END IF;
									IF v_sTipoPago = '02' THEN
										LET v_sPagoDesc = 'Tras.Tercero';
									END IF;
									IF v_sTipoPago = '03' THEN
										LET v_sPagoDesc = 'SPEI';
									END IF;
									IF v_sTipoPago = '04' THEN
										LET v_sPagoDesc = 'Pago Telmex';
									END IF;
									IF v_sTipoPago = '05' THEN
										LET v_sPagoDesc = 'Pago T.Cred.';
									END IF;

									SELECT cve_notifica,cve_notifica_emi
									INTO v_scve_notifica,v_scve_notifica_emi
									FROM bdiprog:pp_pagoprog
									WHERE cve_pagoprog = v_sNumaviso;

									IF v_scve_notifica = '00'  THEN
										LET v_scve_notifica = '---';
									END IF;
									IF v_scve_notifica = '01'THEN
										LET v_scve_notifica = 'E-Mail';
									END IF;
									IF v_scve_notifica = '02'THEN
										LET v_scve_notifica = 'SMS';
									END IF;
									IF v_scve_notifica = '03'THEN
										LET v_scve_notifica = 'AMBAS';
									END IF;
									IF v_scve_notifica_emi = '00'  THEN
										LET v_scve_notifica_emi = '---';
									END IF;
									IF v_scve_notifica_emi = '01'THEN
										LET v_scve_notifica_emi = 'E-Mail';
									END IF;
									IF v_scve_notifica_emi = '02'THEN
										LET v_scve_notifica_emi = 'SMS';
									END IF;
									IF v_scve_notifica_emi = '03'THEN
										LET v_scve_notifica_emi = 'AMBAS';
									END IF;
									LET v_sAviso = TRIM(v_scve_notifica) || '/' || TRIM(v_scve_notifica_emi);
									SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '00';
									RETURN v_sCodRet,v_sMensajeRet,v_dFechaSoli,v_dFechaApli,v_sSucursal,v_sPeridoDesc,v_sMedioDesc,v_sCuentaO,v_sCuentaD,v_mMonto,v_sPagoDesc,
											v_sAviso,v_sEstadoDesc,v_sNumPago,v_sRechaDesc,v_dFechaCan WITH RESUME;
								END FOREACH;
							END IF;
							--Reporte depagos rechazados por busqueda rango de fechas
							IF v_sBandera = '3001' THEN
								FOREACH
									SELECT SKIP pRegistros FIRST pRecuperacion b.fecha_insert,b.fecha_prog,a.cuenta_origen,a.cuenta_destino,a.importe,a.cve_pago,b.consecutivo,b.cve_rechazo,a.cve_pagoprog
									INTO v_dFechaSoli, v_dFechaApli,v_sCuentaO,v_sCuentaD,v_mMonto,v_sTipoPago,v_sNumPago,v_sCausaRe,v_sNumaviso
									FROM bdiprog:pp_pagoprog AS a INNER JOIN bdiprog:pp_pagospend AS b ON a.cve_pagoprog = b.cve_pagoprog
									WHERE b.fecha_prog between p_fecha_inicio and p_fecha_fin
									AND  b.estado = '06'
									ORDER BY b.fecha_prog,a.cve_pago,a.cuenta_origen,a.cuenta_destino

									IF v_sTipoPago = '01' THEN
										LET v_sPagoDesc = 'Tras.Propio';
									END IF;
									IF v_sTipoPago = '02' THEN
										LET v_sPagoDesc = 'Tras.Tercero';
									END IF;
									IF v_sTipoPago = '03' THEN
										LET v_sPagoDesc = 'SPEI';
									END IF;
									IF v_sTipoPago = '04' THEN
										LET v_sPagoDesc = 'Pago Telmex';
									END IF;
									IF v_sTipoPago = '05' THEN
										LET v_sPagoDesc = 'Pago T.Cred.';
									END IF;

									SELECT  TRIM(descripcion)
									INTO v_sRechaDesc
									FROM  bdiprog:pp_tprechazo
									WHERE cve_rechazo = v_sCausaRe;

									SELECT cve_notifica,cve_notifica_emi
									INTO v_scve_notifica,v_scve_notifica_emi
									FROM bdiprog:pp_pagoprog
									WHERE cve_pagoprog = v_sNumaviso;
									IF v_scve_notifica = '00'  THEN
										LET v_scve_notifica = '---';
									END IF;
									IF v_scve_notifica = '01'THEN
										LET v_scve_notifica = 'E-Mail';
									END IF;
									IF v_scve_notifica = '02'THEN
										LET v_scve_notifica = 'SMS';
									END IF;
									IF v_scve_notifica = '03'THEN
										LET v_scve_notifica = 'AMBAS';
									END IF;
									IF v_scve_notifica_emi = '00'  THEN
										LET v_scve_notifica_emi = '---';
									END IF;
									IF v_scve_notifica_emi = '01'THEN
										LET v_scve_notifica_emi = 'E-Mail';
									END IF;
									IF v_scve_notifica_emi = '02'THEN
										LET v_scve_notifica_emi = 'SMS';
									END IF;
									IF v_scve_notifica_emi = '03'THEN
										LET v_scve_notifica_emi = 'AMBAS';
									END IF;
									LET v_sAviso = TRIM(v_scve_notifica) || '/' || TRIM(v_scve_notifica_emi);
									SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '00';
									RETURN v_sCodRet,v_sMensajeRet,v_dFechaSoli,v_dFechaApli,v_sSucursal,v_sPeridoDesc,v_sMedioDesc,v_sCuentaO,v_sCuentaD,v_mMonto,v_sPagoDesc,
											v_sAviso,v_sEstadoDesc,v_sNumPago,v_sRechaDesc,v_dFechaCan WITH RESUME;
								END FOREACH;
							END IF;
							--Reporte depagos cancelados por busqueda rango de fechas
							IF v_sBandera = '4001' THEN
								FOREACH
									SELECT SKIP pRegistros FIRST pRecuperacion b.fecha_insert,b.fecha_cancela,a.cuenta_origen,a.cuenta_destino,a.importe,a.cve_pago,b.consecutivo,a.cve_pagoprog
									INTO v_dFechaSoli, v_dFechaCan,v_sCuentaO,v_sCuentaD,v_mMonto,v_sTipoPago,v_sNumPago,v_sNumaviso
									FROM bdiprog:pp_pagoprog AS a INNER JOIN bdiprog:pp_pagospend AS b ON a.cve_pagoprog = b.cve_pagoprog
									WHERE b.fecha_cancela between p_fecha_inicio and p_fecha_fin
									AND  b.estado = '02'
									ORDER BY b.fecha_cancela,a.cve_pago,a.cuenta_origen,a.cuenta_destino

									IF v_sTipoPago = '01' THEN
										LET v_sPagoDesc = 'Tras.Propio';
									END IF;
									IF v_sTipoPago = '02' THEN
										LET v_sPagoDesc = 'Tras.Tercero';
									END IF;
									IF v_sTipoPago = '03' THEN
										LET v_sPagoDesc = 'SPEI';
									END IF;
									IF v_sTipoPago = '04' THEN
										LET v_sPagoDesc = 'Pago Telmex';
									END IF;
									IF v_sTipoPago = '05' THEN
										LET v_sPagoDesc = 'Pago T.Cred.';
									END IF;

									SELECT cve_notifica,cve_notifica_emi
									INTO v_scve_notifica,v_scve_notifica_emi
									FROM bdiprog:pp_pagoprog
									WHERE cve_pagoprog = v_sNumaviso;
									IF v_scve_notifica = '00'  THEN
										LET v_scve_notifica = '---';
									END IF;
									IF v_scve_notifica = '01'THEN
										LET v_scve_notifica = 'E-Mail';
									END IF;
									IF v_scve_notifica = '02'THEN
										LET v_scve_notifica = 'SMS';
									END IF;
									IF v_scve_notifica = '03'THEN
										LET v_scve_notifica = 'AMBAS';
									END IF;
									IF v_scve_notifica_emi = '00'  THEN
										LET v_scve_notifica_emi = '---';
									END IF;
									IF v_scve_notifica_emi = '01'THEN
										LET v_scve_notifica_emi = 'E-Mail';
									END IF;
									IF v_scve_notifica_emi = '02'THEN
										LET v_scve_notifica_emi = 'SMS';
									END IF;
									IF v_scve_notifica_emi = '03'THEN
										LET v_scve_notifica_emi = 'AMBAS';
									END IF;
									LET v_dFechaApli = '';
									LET v_sAviso = TRIM(v_scve_notifica) || '/' || TRIM(v_scve_notifica_emi);
									SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '00';
									RETURN v_sCodRet,v_sMensajeRet,v_dFechaSoli,v_dFechaApli,v_sSucursal,v_sPeridoDesc,v_sMedioDesc,v_sCuentaO,v_sCuentaD,v_mMonto,v_sPagoDesc,
											v_sAviso,v_sEstadoDesc,v_sNumPago,v_sRechaDesc,v_dFechaCan WITH RESUME;
								END FOREACH;
							END IF;
						ELSE
							SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '94';
							RETURN v_sCodRet,v_sMensajeRet,v_dFechaSoli,v_dFechaApli,v_sSucursal,v_sPeridoDesc,v_sMedioDesc,v_sCuentaO,v_sCuentaD,v_mMonto,v_sPagoDesc,
									v_sAviso,v_sEstadoDesc,v_sNumPago,v_sRechaDesc,v_dFechaCan;
						END IF;
					ELSE
						--se informa que la fecha inicio es mayor que la fecha fin
						SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '62';
						RETURN v_sCodRet,v_sMensajeRet,v_dFechaSoli,v_dFechaApli,v_sSucursal,v_sPeridoDesc,v_sMedioDesc,v_sCuentaO,v_sCuentaD,v_mMonto,v_sPagoDesc,
								v_sAviso,v_sEstadoDesc,v_sNumPago,v_sRechaDesc,v_dFechaCan;
					END IF;
				END IF;
				IF (v_sBandera = '1010') OR (v_sBandera = '2010') OR (v_sBandera = '3010') OR (v_sBandera = '4010') THEN
					IF EXISTS(SELECT descripcion FROM bdiprog:pp_pagoprog WHERE cve_pago = p_cve_pago ) THEN
						--Reporte de pagos programados por busqueda de clave de programacion
						IF v_sBandera = '1010' THEN
							FOREACH
								SELECT SKIP pRegistros FIRST pRecuperacion b.fecha_insert,b.fecha_prog,a.cve_programa,a.cve_canal,a.cuenta_origen,a.cuenta_destino,a.importe,a.cve_pago,b.estado,b.consecutivo,a.cve_pagoprog,a.user_insert
								INTO v_dFechaSoli, v_dFechaApli,v_sPerioPago,v_sMedioSoli,v_sCuentaO,v_sCuentaD,v_mMonto,v_sTipoPago,v_sEstatus,v_sNumPago,v_sNumaviso,v_sUser
								FROM bdiprog:pp_pagoprog AS a INNER JOIN bdiprog:pp_pagospend AS b ON a.cve_pagoprog = b.cve_pagoprog
								WHERE a.cve_pago = p_cve_pago
								ORDER BY b.fecha_prog,a.cve_pago,a.cuenta_origen,a.cuenta_destino
								
								IF v_sUser = 'transBPI' THEN
									LET v_sSucursal = '5003-Internet';
								ELSE											
									SELECT a.sucursal,b.nombre
									INTO v_sNumSucursal,v_sDescSucursal
									FROM bdinteg:si_ejecut as a 
									LEFT JOIN bdinteg:si_sucursales as b ON (a.sucursal=b.sucursal)
									WHERE a.ejecutivo = v_sUser;											
									LET v_sSucursal = NVL(v_sNumSucursal,'') || '-' || NVL(v_sDescSucursal,'');
								END IF;

								SELECT  TRIM(descripcion)
								INTO v_sPeridoDesc
								FROM  bdiprog:pp_tpprograma
								WHERE cve_programa = v_sPerioPago;

								SELECT  TRIM(descripcion)
								INTO v_sMedioDesc
								FROM  bdiprog:pp_tpcanal
								WHERE cve_canal = v_sMedioSoli;

								IF v_sTipoPago = '01' THEN
									LET v_sPagoDesc = 'Tras.Propio';
								END IF;
								IF v_sTipoPago = '02' THEN
									LET v_sPagoDesc = 'Tras.Tercero';
								END IF;
								IF v_sTipoPago = '03' THEN
									LET v_sPagoDesc = 'SPEI';
								END IF;
								IF v_sTipoPago = '04' THEN
									LET v_sPagoDesc = 'Pago Telmex';
								END IF;
								IF v_sTipoPago = '05' THEN
									LET v_sPagoDesc = 'Pago T.Cred.';
								END IF;

								SELECT TRIM(descripcion)
								INTO v_sEstadoDesc
								FROM bdiprog:pp_estados
								WHERE cve_estado = v_sEstatus;

								SELECT cve_notifica,cve_notifica_emi
								INTO v_scve_notifica,v_scve_notifica_emi
								FROM bdiprog:pp_pagoprog
								WHERE cve_pagoprog = v_sNumaviso
								AND cve_pago = p_cve_pago;

								IF v_scve_notifica = '00'  THEN
									LET v_scve_notifica = '---';
								END IF;
								IF v_scve_notifica = '01'THEN
									LET v_scve_notifica = 'E-Mail';
								END IF;
								IF v_scve_notifica = '02'THEN
									LET v_scve_notifica = 'SMS';
								END IF;
								IF v_scve_notifica = '03'THEN
									LET v_scve_notifica = 'AMBAS';
								END IF;
								IF v_scve_notifica_emi = '00'  THEN
									LET v_scve_notifica_emi = '---';
								END IF;
								IF v_scve_notifica_emi = '01'THEN
									LET v_scve_notifica_emi = 'E-Mail';
								END IF;
								IF v_scve_notifica_emi = '02'THEN
									LET v_scve_notifica_emi = 'SMS';
								END IF;
								IF v_scve_notifica_emi = '03'THEN
									LET v_scve_notifica_emi = 'AMBAS';
								END IF;
								LET v_sAviso = TRIM(v_scve_notifica) || '/' || TRIM(v_scve_notifica_emi);

								SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '00';
								RETURN v_sCodRet,v_sMensajeRet,v_dFechaSoli,v_dFechaApli,v_sSucursal,v_sPeridoDesc,v_sMedioDesc,v_sCuentaO,v_sCuentaD,v_mMonto,v_sPagoDesc,
									v_sAviso,v_sEstadoDesc,v_sNumPago,v_sRechaDesc,v_dFechaCan WITH RESUME;
							END FOREACH;
						END IF;
						--Reporte depagos realizados por busqueda de clave de programacion
						IF v_sBandera = '2010' THEN
							FOREACH
								SELECT SKIP pRegistros FIRST pRecuperacion b.fecha_insert,b.fecha_aplic,a.cuenta_origen,a.cuenta_destino,a.importe,a.cve_pago,b.consecutivo,a.cve_pagoprog
								INTO v_dFechaSoli, v_dFechaApli,v_sCuentaO,v_sCuentaD,v_mMonto,v_sTipoPago,v_sNumPago,v_sNumaviso
								FROM bdiprog:pp_pagoprog AS a INNER JOIN bdiprog:pp_pagospend AS b ON a.cve_pagoprog = b.cve_pagoprog
								WHERE a.cve_pago = p_cve_pago
								AND  b.estado = '05'
								ORDER BY b.fecha_aplic,a.cve_pago,a.cuenta_origen,a.cuenta_destino

								IF v_sTipoPago = '01' THEN
									LET v_sPagoDesc = 'Tras.Propio';
								END IF;
								IF v_sTipoPago = '02' THEN
									LET v_sPagoDesc = 'Tras.Tercero';
								END IF;
								IF v_sTipoPago = '03' THEN
									LET v_sPagoDesc = 'SPEI';
								END IF;
								IF v_sTipoPago = '04' THEN
									LET v_sPagoDesc = 'Pago Telmex';
								END IF;
								IF v_sTipoPago = '05' THEN
									LET v_sPagoDesc = 'Pago T.Cred.';
								END IF;

								SELECT cve_notifica,cve_notifica_emi
								INTO v_scve_notifica,v_scve_notifica_emi
								FROM bdiprog:pp_pagoprog
								WHERE cve_pagoprog = v_sNumaviso
								AND cve_pago = p_cve_pago;
								IF v_scve_notifica = '00'  THEN
								LET v_scve_notifica = '---';
								END IF;
								IF v_scve_notifica = '01'THEN
									LET v_scve_notifica = 'E-Mail';
								END IF;
								IF v_scve_notifica = '02'THEN
									LET v_scve_notifica = 'SMS';
								END IF;
								IF v_scve_notifica = '03'THEN
									LET v_scve_notifica = 'AMBAS';
								END IF;
								IF v_scve_notifica_emi = '00'  THEN
									LET v_scve_notifica_emi = '---';
								END IF;
								IF v_scve_notifica_emi = '01'THEN
									LET v_scve_notifica_emi = 'E-Mail';
								END IF;
								IF v_scve_notifica_emi = '02'THEN
									LET v_scve_notifica_emi = 'SMS';
								END IF;
								IF v_scve_notifica_emi = '03'THEN
									LET v_scve_notifica_emi = 'AMBAS';
								END IF;
								LET v_sAviso = TRIM(v_scve_notifica) || '/' || TRIM(v_scve_notifica_emi);
								SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '00';
								RETURN v_sCodRet,v_sMensajeRet,v_dFechaSoli,v_dFechaApli,v_sSucursal,v_sPeridoDesc,v_sMedioDesc,v_sCuentaO,v_sCuentaD,v_mMonto,v_sPagoDesc,
									v_sAviso,v_sEstadoDesc,v_sNumPago,v_sRechaDesc,v_dFechaCan WITH RESUME;
							END FOREACH;
						END IF;
						--Reporte depagos rechazados por busqueda de  clave de programacion
						IF v_sBandera = '3010' THEN
							FOREACH
								SELECT SKIP pRegistros FIRST pRecuperacion b.fecha_insert,b.fecha_prog,a.cuenta_origen,a.cuenta_destino,a.importe,a.cve_pago,b.consecutivo,b.cve_rechazo,a.cve_pagoprog
								INTO v_dFechaSoli, v_dFechaApli,v_sCuentaO,v_sCuentaD,v_mMonto,v_sTipoPago,v_sNumPago,v_sCausaRe,v_sNumaviso
								FROM bdiprog:pp_pagoprog AS a INNER JOIN bdiprog:pp_pagospend AS b ON a.cve_pagoprog = b.cve_pagoprog
								WHERE a.cve_pago = p_cve_pago
								AND  b.estado = '06'
								ORDER BY b.fecha_prog,a.cve_pago,a.cuenta_origen,a.cuenta_destino								

								IF v_sTipoPago = '01' THEN
									LET v_sPagoDesc = 'Tras.Propio';
								END IF;
								IF v_sTipoPago = '02' THEN
									LET v_sPagoDesc = 'Tras.Tercero';
								END IF;
								IF v_sTipoPago = '03' THEN
									LET v_sPagoDesc = 'SPEI';
								END IF;
								IF v_sTipoPago = '04' THEN
									LET v_sPagoDesc = 'Pago Telmex';
								END IF;
								IF v_sTipoPago = '05' THEN
									LET v_sPagoDesc = 'Pago T.Cred.';
								END IF;

								SELECT  TRIM(descripcion)
								INTO v_sRechaDesc
								FROM  bdiprog:pp_tprechazo
								WHERE cve_rechazo = v_sCausaRe;

								SELECT cve_notifica,cve_notifica_emi
								INTO v_scve_notifica,v_scve_notifica_emi
								FROM bdiprog:pp_pagoprog
								WHERE cve_pagoprog = v_sNumaviso
								AND cve_pago = p_cve_pago;
								IF v_scve_notifica = '00'  THEN
									LET v_scve_notifica = '---';
								END IF;
								IF v_scve_notifica = '01'THEN
									LET v_scve_notifica = 'E-Mail';
								END IF;
								IF v_scve_notifica = '02'THEN
									LET v_scve_notifica = 'SMS';
								END IF;
								IF v_scve_notifica = '03'THEN
									LET v_scve_notifica = 'AMBAS';
								END IF;
								IF v_scve_notifica_emi = '00'  THEN
									LET v_scve_notifica_emi = '---';
								END IF;
								IF v_scve_notifica_emi = '01'THEN
									LET v_scve_notifica_emi = 'E-Mail';
								END IF;
								IF v_scve_notifica_emi = '02'THEN
									LET v_scve_notifica_emi = 'SMS';
								END IF;
								IF v_scve_notifica_emi = '03'THEN
									LET v_scve_notifica_emi = 'AMBAS';
								END IF;
								LET v_sAviso = TRIM(v_scve_notifica) || '/' || TRIM(v_scve_notifica_emi);
								SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '00';
								RETURN v_sCodRet,v_sMensajeRet,v_dFechaSoli,v_dFechaApli,v_sSucursal,v_sPeridoDesc,v_sMedioDesc,v_sCuentaO,v_sCuentaD,v_mMonto,v_sPagoDesc,
									v_sAviso,v_sEstadoDesc,v_sNumPago,v_sRechaDesc,v_dFechaCan WITH RESUME;
							END FOREACH;
						END IF;
						--Reporte depagos cancelados por busqueda de clave de programacion
						IF v_sBandera = '4010' THEN
							FOREACH
								SELECT SKIP pRegistros FIRST pRecuperacion b.fecha_insert,b.fecha_cancela,a.cuenta_origen,a.cuenta_destino,a.importe,a.cve_pago,b.consecutivo,a.cve_pagoprog
								INTO v_dFechaSoli, v_dFechaCan,v_sCuentaO,v_sCuentaD,v_mMonto,v_sTipoPago,v_sNumPago,v_sNumaviso
								FROM bdiprog:pp_pagoprog AS a INNER JOIN bdiprog:pp_pagospend AS b ON a.cve_pagoprog = b.cve_pagoprog
								WHERE a.cve_pago = p_cve_pago
								AND  b.estado = '02'
								ORDER BY b.fecha_cancela,a.cve_pago,a.cuenta_origen,a.cuenta_destino

								IF v_sTipoPago = '01' THEN
									LET v_sPagoDesc = 'Tras.Propio';
								END IF;
								IF v_sTipoPago = '02' THEN
									LET v_sPagoDesc = 'Tras.Tercero';
								END IF;
								IF v_sTipoPago = '03' THEN
									LET v_sPagoDesc = 'SPEI';
								END IF;
								IF v_sTipoPago = '04' THEN
									LET v_sPagoDesc = 'Pago Telmex';
								END IF;
								IF v_sTipoPago = '05' THEN
									LET v_sPagoDesc = 'Pago T.Cred.';
								END IF;

								SELECT cve_notifica,cve_notifica_emi
								INTO v_scve_notifica,v_scve_notifica_emi
								FROM bdiprog:pp_pagoprog
								WHERE cve_pagoprog = v_sNumaviso
								AND cve_pago = p_cve_pago;

								IF v_scve_notifica = '00'  THEN
									LET v_scve_notifica = '---';
								END IF;
								IF v_scve_notifica = '01'THEN
									LET v_scve_notifica = 'E-Mail';
								END IF;
								IF v_scve_notifica = '02'THEN
									LET v_scve_notifica = 'SMS';
								END IF;
								IF v_scve_notifica = '03'THEN
									LET v_scve_notifica = 'AMBAS';
								END IF;
								IF v_scve_notifica_emi = '00'  THEN
									LET v_scve_notifica_emi = '---';
								END IF;
								IF v_scve_notifica_emi = '01'THEN
									LET v_scve_notifica_emi = 'E-Mail';
								END IF;
								IF v_scve_notifica_emi = '02'THEN
									LET v_scve_notifica_emi = 'SMS';
								END IF;
								IF v_scve_notifica_emi = '03'THEN
									LET v_scve_notifica_emi = 'AMBAS';
								END IF;
								LET v_dFechaApli = '';
								LET v_sAviso = TRIM(v_scve_notifica) || '/' || TRIM(v_scve_notifica_emi);
								SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '00';
								RETURN v_sCodRet,v_sMensajeRet,v_dFechaSoli,v_dFechaApli,v_sSucursal,v_sPeridoDesc,v_sMedioDesc,v_sCuentaO,v_sCuentaD,v_mMonto,v_sPagoDesc,
									v_sAviso,v_sEstadoDesc,v_sNumPago,v_sRechaDesc,v_dFechaCan WITH RESUME;
							END FOREACH;
						END IF;
					ELSE
						--se informa que la clave de progrma no existe
						SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '24';
						RETURN v_sCodRet,v_sMensajeRet,v_dFechaSoli,v_dFechaApli,v_sSucursal,v_sPeridoDesc,v_sMedioDesc,v_sCuentaO,v_sCuentaD,v_mMonto,v_sPagoDesc,
								v_sAviso,v_sEstadoDesc,v_sNumPago,v_sRechaDesc,v_dFechaCan;
					END IF;
				END IF;
				--REPORTE POR CLAVE DE PAGO Y RANGO DE FECHAS
				IF (v_sBandera = '1011') OR (v_sBandera = '2011') OR (v_sBandera = '3011') OR (v_sBandera = '4011') THEN
					--Se valida que la clave de programa existe
					IF EXISTS(SELECT descripcion FROM bdiprog:pp_pagoprog WHERE cve_pago = p_cve_pago ) THEN
						--Se valida que la fecha inicial es menor que la fecha fin
						IF p_fecha_inicio <= p_fecha_fin THEN
							--Se valida que existan pagos para ese rango de fechas para ese cliente y para esa clave de pago
							IF EXISTS (SELECT estado  FROM bdiprog:pp_pagospend  WHERE fecha_prog between p_fecha_inicio and p_fecha_fin) THEN
							ELSE
								SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '94';
								RETURN v_sCodRet,v_sMensajeRet,v_dFechaSoli,v_dFechaApli,v_sSucursal,v_sPeridoDesc,v_sMedioDesc,v_sCuentaO,v_sCuentaD,v_mMonto,v_sPagoDesc,
										v_sAviso,v_sEstadoDesc,v_sNumPago,v_sRechaDesc,v_dFechaCan;
							END IF;
							--Reporte de pagos programados por busqueda por clave de programacion y rango de fechas
							IF v_sBandera = '1011' THEN
								FOREACH
									SELECT SKIP pRegistros FIRST pRecuperacion b.fecha_insert,b.fecha_prog,a.cve_programa,a.cve_canal,a.cuenta_origen,a.cuenta_destino,a.importe,a.cve_pago,b.estado,b.consecutivo,a.cve_pagoprog,a.user_insert
									INTO v_dFechaSoli, v_dFechaApli,v_sPerioPago,v_sMedioSoli,v_sCuentaO,v_sCuentaD,v_mMonto,v_sTipoPago,v_sEstatus,v_sNumPago,v_sNumaviso,v_sUser
									FROM bdiprog:pp_pagoprog AS a INNER JOIN bdiprog:pp_pagospend AS b ON a.cve_pagoprog = b.cve_pagoprog
									WHERE b.fecha_prog between p_fecha_inicio and p_fecha_fin
									AND a.cve_pago = p_cve_pago
									ORDER BY b.fecha_prog,a.cve_pago,a.cuenta_origen,a.cuenta_destino
									
									IF v_sUser = 'transBPI' THEN
										LET v_sSucursal = '5003-Internet';
									ELSE											
										SELECT a.sucursal,b.nombre
										INTO v_sNumSucursal,v_sDescSucursal
										FROM bdinteg:si_ejecut as a 
										LEFT JOIN bdinteg:si_sucursales as b ON (a.sucursal=b.sucursal)
										WHERE a.ejecutivo = v_sUser;											
										LET v_sSucursal = NVL(v_sNumSucursal,'') || '-' || NVL(v_sDescSucursal,'');
									END IF;

									SELECT  TRIM(descripcion)
									INTO v_sPeridoDesc
									FROM  bdiprog:pp_tpprograma
									WHERE cve_programa = v_sPerioPago;

									SELECT  TRIM(descripcion)
									INTO v_sMedioDesc
									FROM  bdiprog:pp_tpcanal
									WHERE cve_canal = v_sMedioSoli;

									IF v_sTipoPago = '01' THEN
										LET v_sPagoDesc = 'Tras.Propio';
									END IF;
									IF v_sTipoPago = '02' THEN
										LET v_sPagoDesc = 'Tras.Tercero';
									END IF;
									IF v_sTipoPago = '03' THEN
										LET v_sPagoDesc = 'SPEI';
									END IF;
									IF v_sTipoPago = '04' THEN
										LET v_sPagoDesc = 'Pago Telmex';
									END IF;
									IF v_sTipoPago = '05' THEN
										LET v_sPagoDesc = 'Pago T.Cred.';
									END IF;

									SELECT TRIM(descripcion)
									INTO v_sEstadoDesc
									FROM bdiprog:pp_estados
									WHERE cve_estado = v_sEstatus;

									SELECT cve_notifica,cve_notifica_emi
									INTO v_scve_notifica,v_scve_notifica_emi
									FROM bdiprog:pp_pagoprog
									WHERE cve_pagoprog = v_sNumaviso
									AND cve_pago = p_cve_pago;

									IF v_scve_notifica = '00'  THEN
										LET v_scve_notifica = '---';
									END IF;
									IF v_scve_notifica = '01'THEN
										LET v_scve_notifica = 'E-Mail';
									END IF;
									IF v_scve_notifica = '02'THEN
										LET v_scve_notifica = 'SMS';
									END IF;
									IF v_scve_notifica = '03'THEN
										LET v_scve_notifica = 'AMBAS';
									END IF;
									IF v_scve_notifica_emi = '00'  THEN
										LET v_scve_notifica_emi = '---';
									END IF;
									IF v_scve_notifica_emi = '01'THEN
										LET v_scve_notifica_emi = 'E-Mail';
									END IF;
									IF v_scve_notifica_emi = '02'THEN
										LET v_scve_notifica_emi = 'SMS';
									END IF;
									IF v_scve_notifica_emi = '03'THEN
										LET v_scve_notifica_emi = 'AMBAS';
									END IF;
									LET v_sAviso = TRIM(v_scve_notifica) || '/' || TRIM(v_scve_notifica_emi);

									SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '00';
									RETURN v_sCodRet,v_sMensajeRet,v_dFechaSoli,v_dFechaApli,v_sSucursal,v_sPeridoDesc,v_sMedioDesc,v_sCuentaO,v_sCuentaD,v_mMonto,v_sPagoDesc,
										v_sAviso,v_sEstadoDesc,v_sNumPago,v_sRechaDesc,v_dFechaCan WITH RESUME;
								END FOREACH;
							END IF;
							--Reporte depagos realizados por  clave de programacion y rango de fechas
							IF v_sBandera = '2011' THEN
								FOREACH
									SELECT SKIP pRegistros FIRST pRecuperacion b.fecha_insert,b.fecha_aplic,a.cuenta_origen,a.cuenta_destino,a.importe,a.cve_pago,b.consecutivo,a.cve_pagoprog
									INTO v_dFechaSoli, v_dFechaApli,v_sCuentaO,v_sCuentaD,v_mMonto,v_sTipoPago,v_sNumPago,v_sNumaviso
									FROM bdiprog:pp_pagoprog AS a INNER JOIN bdiprog:pp_pagospend AS b ON a.cve_pagoprog = b.cve_pagoprog
									WHERE b.fecha_aplic between p_fecha_inicio and p_fecha_fin
									AND a.cve_pago = p_cve_pago
									AND  b.estado = '05'
									ORDER BY b.fecha_aplic,a.cve_pago,a.cuenta_origen,a.cuenta_destino

									IF v_sTipoPago = '01' THEN
										LET v_sPagoDesc = 'Tras.Propio';
									END IF;
									IF v_sTipoPago = '02' THEN
										LET v_sPagoDesc = 'Tras.Tercero';
									END IF;
									IF v_sTipoPago = '03' THEN
										LET v_sPagoDesc = 'SPEI';
									END IF;
									IF v_sTipoPago = '04' THEN
										LET v_sPagoDesc = 'Pago Telmex';
									END IF;
									IF v_sTipoPago = '05' THEN
										LET v_sPagoDesc = 'Pago T.Cred.';
									END IF;

									SELECT cve_notifica,cve_notifica_emi
									INTO v_scve_notifica,v_scve_notifica_emi
									FROM bdiprog:pp_pagoprog
									WHERE cve_pagoprog = v_sNumaviso
									AND cve_pago = p_cve_pago;
									IF v_scve_notifica = '00'  THEN
										LET v_scve_notifica = '---';
									END IF;
									IF v_scve_notifica = '01'THEN
										LET v_scve_notifica = 'E-Mail';
									END IF;
									IF v_scve_notifica = '02'THEN
										LET v_scve_notifica = 'SMS';
									END IF;
									IF v_scve_notifica = '03'THEN
										LET v_scve_notifica = 'AMBAS';
									END IF;
									IF v_scve_notifica_emi = '00'  THEN
										LET v_scve_notifica_emi = '---';
									END IF;
									IF v_scve_notifica_emi = '01'THEN
										LET v_scve_notifica_emi = 'E-Mail';
									END IF;
									IF v_scve_notifica_emi = '02'THEN
										LET v_scve_notifica_emi = 'SMS';
									END IF;
									IF v_scve_notifica_emi = '03'THEN
										LET v_scve_notifica_emi = 'AMBAS';
									END IF;
									LET v_sAviso = TRIM(v_scve_notifica) || '/' || TRIM(v_scve_notifica_emi);
									SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '00';
									RETURN v_sCodRet,v_sMensajeRet,v_dFechaSoli,v_dFechaApli,v_sSucursal,v_sPeridoDesc,v_sMedioDesc,v_sCuentaO,v_sCuentaD,v_mMonto,v_sPagoDesc,
										v_sAviso,v_sEstadoDesc,v_sNumPago,v_sRechaDesc,v_dFechaCan WITH RESUME;
								END FOREACH;
							END IF;
							--Reporte depagos rechazados por busqueda   clave de programacion y rango de fechas
							IF v_sBandera = '3011' THEN
								FOREACH
									SELECT SKIP pRegistros FIRST pRecuperacion b.fecha_insert,b.fecha_prog,a.cuenta_origen,a.cuenta_destino,a.importe,a.cve_pago,b.consecutivo,b.cve_rechazo,a.cve_pagoprog
									INTO v_dFechaSoli, v_dFechaApli,v_sCuentaO,v_sCuentaD,v_mMonto,v_sTipoPago,v_sNumPago,v_sCausaRe,v_sNumaviso
									FROM bdiprog:pp_pagoprog AS a INNER JOIN bdiprog:pp_pagospend AS b ON a.cve_pagoprog = b.cve_pagoprog
									WHERE b.fecha_prog between p_fecha_inicio and p_fecha_fin
									AND a.cve_pago = p_cve_pago
									AND  b.estado = '06'
									ORDER BY b.fecha_prog,a.cve_pago,a.cuenta_origen,a.cuenta_destino

									IF v_sTipoPago = '01' THEN
										LET v_sPagoDesc = 'Tras.Propio';
									END IF;
									IF v_sTipoPago = '02' THEN
										LET v_sPagoDesc = 'Tras.Tercero';
									END IF;
									IF v_sTipoPago = '03' THEN
										LET v_sPagoDesc = 'SPEI';
									END IF;
									IF v_sTipoPago = '04' THEN
										LET v_sPagoDesc = 'Pago Telmex';
									END IF;
									IF v_sTipoPago = '05' THEN
										LET v_sPagoDesc = 'Pago T.Cred.';
									END IF;

									SELECT  TRIM(descripcion)
									INTO v_sRechaDesc
									FROM  bdiprog:pp_tprechazo
									WHERE cve_rechazo = v_sCausaRe;

									SELECT cve_notifica,cve_notifica_emi
									INTO v_scve_notifica,v_scve_notifica_emi
									FROM bdiprog:pp_pagoprog
									WHERE cve_pagoprog = v_sNumaviso
									AND cve_pago = p_cve_pago;
									IF v_scve_notifica = '00'  THEN
										LET v_scve_notifica = '---';
									END IF;
									IF v_scve_notifica = '01'THEN
										LET v_scve_notifica = 'E-Mail';
									END IF;
									IF v_scve_notifica = '02'THEN
										LET v_scve_notifica = 'SMS';
									END IF;
									IF v_scve_notifica = '03'THEN
										LET v_scve_notifica = 'AMBAS';
									END IF;
									IF v_scve_notifica_emi = '00'  THEN
										LET v_scve_notifica_emi = '---';
									END IF;
									IF v_scve_notifica_emi = '01'THEN
										LET v_scve_notifica_emi = 'E-Mail';
									END IF;
									IF v_scve_notifica_emi = '02'THEN
										LET v_scve_notifica_emi = 'SMS';
									END IF;
									IF v_scve_notifica_emi = '03'THEN
										LET v_scve_notifica_emi = 'AMBAS';
									END IF;
									LET v_sAviso = TRIM(v_scve_notifica) || '/' || TRIM(v_scve_notifica_emi);
									SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '00';
									RETURN v_sCodRet,v_sMensajeRet,v_dFechaSoli,v_dFechaApli,v_sSucursal,v_sPeridoDesc,v_sMedioDesc,v_sCuentaO,v_sCuentaD,v_mMonto,v_sPagoDesc,
										v_sAviso,v_sEstadoDesc,v_sNumPago,v_sRechaDesc,v_dFechaCan WITH RESUME;
								END FOREACH;
							END IF;
							--Reporte depagos cancelados por busqueda de clave de programacion y rango de fechas
							IF v_sBandera = '4011' THEN
								FOREACH
									SELECT SKIP pRegistros FIRST pRecuperacion b.fecha_insert,b.fecha_cancela,a.cuenta_origen,a.cuenta_destino,a.importe,a.cve_pago,b.consecutivo,a.cve_pagoprog
									INTO v_dFechaSoli, v_dFechaCan,v_sCuentaO,v_sCuentaD,v_mMonto,v_sTipoPago,v_sNumPago,v_sNumaviso
									FROM bdiprog:pp_pagoprog AS a INNER JOIN bdiprog:pp_pagospend AS b ON a.cve_pagoprog = b.cve_pagoprog
									WHERE b.fecha_cancela between p_fecha_inicio and p_fecha_fin
									AND a.cve_pago = p_cve_pago
									AND  b.estado = '02'
									ORDER BY b.fecha_cancela,a.cve_pago,a.cuenta_origen,a.cuenta_destino
									
									IF v_sTipoPago = '01' THEN
										LET v_sPagoDesc = 'Tras.Propio';
									END IF;
									IF v_sTipoPago = '02' THEN
										LET v_sPagoDesc = 'Tras.Tercero';
									END IF;
									IF v_sTipoPago = '03' THEN
										LET v_sPagoDesc = 'SPEI';
									END IF;
									IF v_sTipoPago = '04' THEN
										LET v_sPagoDesc = 'Pago Telmex';
									END IF;
									IF v_sTipoPago = '05' THEN
										LET v_sPagoDesc = 'Pago T.Cred.';
									END IF;

									SELECT cve_notifica,cve_notifica_emi
									INTO v_scve_notifica,v_scve_notifica_emi
									FROM bdiprog:pp_pagoprog
									WHERE cve_pagoprog = v_sNumaviso
									AND cve_pago = p_cve_pago;

									IF v_scve_notifica = '00'  THEN
										LET v_scve_notifica = '---';
									END IF;
									IF v_scve_notifica = '01'THEN
										LET v_scve_notifica = 'E-Mail';
									END IF;
									IF v_scve_notifica = '02'THEN
										LET v_scve_notifica = 'SMS';
									END IF;
									IF v_scve_notifica = '03'THEN
										LET v_scve_notifica = 'AMBAS';
									END IF;
									IF v_scve_notifica_emi = '00'  THEN
										LET v_scve_notifica_emi = '---';
									END IF;
									IF v_scve_notifica_emi = '01'THEN
										LET v_scve_notifica_emi = 'E-Mail';
									END IF;
									IF v_scve_notifica_emi = '02'THEN
										LET v_scve_notifica_emi = 'SMS';
									END IF;
									IF v_scve_notifica_emi = '03'THEN
										LET v_scve_notifica_emi = 'AMBAS';
									END IF;
									LET v_dFechaApli = '';
									LET v_sAviso = TRIM(v_scve_notifica) || '/' || TRIM(v_scve_notifica_emi);

									SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '00';
									RETURN v_sCodRet,v_sMensajeRet,v_dFechaSoli,v_dFechaApli,v_sSucursal,v_sPeridoDesc,v_sMedioDesc,v_sCuentaO,v_sCuentaD,v_mMonto,v_sPagoDesc,
										v_sAviso,v_sEstadoDesc,v_sNumPago,v_sRechaDesc,v_dFechaCan WITH RESUME;
								END FOREACH;
							END IF;
						ELSE
							--se informa que la fecha inicio es mayor que la fecha fin
							SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '62';
							RETURN v_sCodRet,v_sMensajeRet,v_dFechaSoli,v_dFechaApli,v_sSucursal,v_sPeridoDesc,v_sMedioDesc,v_sCuentaO,v_sCuentaD,v_mMonto,v_sPagoDesc,
								v_sAviso,v_sEstadoDesc,v_sNumPago,v_sRechaDesc,v_dFechaCan;
						END IF;
					ELSE
						--se informa que la clave de progrma no existe
						SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '24';
						RETURN v_sCodRet,v_sMensajeRet,v_dFechaSoli,v_dFechaApli,v_sSucursal,v_sPeridoDesc,v_sMedioDesc,v_sCuentaO,v_sCuentaD,v_mMonto,v_sPagoDesc,
							v_sAviso,v_sEstadoDesc,v_sNumPago,v_sRechaDesc,v_dFechaCan;
					END IF;
				END IF;
			ELSE
				--Se le informa que el numero de reporte no existe
				SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '95';
				RETURN v_sCodRet,v_sMensajeRet,v_dFechaSoli,v_dFechaApli,v_sSucursal,v_sPeridoDesc,v_sMedioDesc,v_sCuentaO,v_sCuentaD,v_mMonto,v_sPagoDesc,
					v_sAviso,v_sEstadoDesc,v_sNumPago,v_sRechaDesc,v_dFechaCan;
			END IF;
		-- Se informa que el tipo de reporte viende blanco o nulo
		ELSE
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '01';
			RETURN v_sCodRet,v_sMensajeRet,v_dFechaSoli,v_dFechaApli,v_sSucursal,v_sPeridoDesc,v_sMedioDesc,v_sCuentaO,v_sCuentaD,v_mMonto,v_sPagoDesc,
					v_sAviso,v_sEstadoDesc,v_sNumPago,v_sRechaDesc,v_dFechaCan;
		END IF;
		IF v_sAviso = '' THEN
			SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet  FROM bdiprog:pp_mensajes WHERE cve_mensaje = '103';
			RETURN v_sCodRet,v_sMensajeRet,v_dFechaSoli,v_dFechaApli,v_sSucursal,v_sPeridoDesc,v_sMedioDesc,v_sCuentaO,v_sCuentaD,v_mMonto,v_sPagoDesc,
					v_sAviso,v_sEstadoDesc,v_sNumPago,v_sRechaDesc,v_dFechaCan;
		END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 19/04/2017',
'MODULO: OPERACIONES ',
'FUNCIONALIDAD: REPORTE DE PAGOS PROGRAMADOS',
'DESCRIPCION: Se agrega paginado a clon de SP',
'BD: bdiprog';

CREATE PROCEDURE "informix".sp_altatelefonoctasftes_bpi(pNumCliente  CHAR(10),
										pNumTelefono VARCHAR(15),
										pAlias VARCHAR(30),
										pDigito CHAR(1),
										p_sUser CHAR(8), p_CveCaducidad CHAR(1))
RETURNING
    CHAR(5),
	CHAR(60);

--Se clona el sp sp_altatelefonoctasftes para incluir el manejo de caducidad de las cuentas frecuentes
--Modifico: Berenice Noriega
--Fecha:    2013-01-17
------------------------------------------------------------------------------------------------------------------------------
-- Se agrega la condiciÃ?Â³n para que tambiÃ?Â©n se ejecute el SP sp_altabajaterceros_bpi cuando el telÃ?Â©fono frecuente se encuentra
-- todavÃ?Â­a activo pero no tiene dÃ?Â­gito verificador
-- Bibiana Gaxiola Verdugo.
-- 06/03/2014

-------------------------------------------------------------------------------------------------------------------------------
-- Se modifica el cÃ³digo de retorno a '90000', 'la cuenta ya existe'.
-- Modifico: Jorge Bibriesca
-- Fecha: 03/08/2017

-------------------------------------------------------------------------------------------------------------------------------

DEFINE vCodRet          CHAR(5);
DEFINE vMensaje         CHAR(60);
DEFINE iSqlErr			INTEGER;
DEFINE vDigito			CHAR(1);
DEFINE vFechaCaducidad DATE; --
LET vCodRet = '000';
LET vMensaje = '';
LET vDigito = '';
LET vFechaCaducidad = ''; --

SET LOCK MODE TO WAIT 10;
--SET DEBUG FILE TO "/home/informix/bibiana/sp_altatelefonoctasftes_bpi.out";
--TRACE ON;

BEGIN
    ON EXCEPTION
        SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET vCodRet = iSqlErr;
            RETURN vCodRet, vMensaje;
        END IF;
    END EXCEPTION;

	--- Validar que el tÃ?Â©lefono frecuente no exista en la tabla pp_ctasterceros
	IF (SELECT count(user_insert) FROM bdiprog:"informix".pp_ctasterceros WHERE num_cte = pNumCliente AND cuenta = pNumTelefono AND cve_estado = '01') = 0 THEN
		EXECUTE PROCEDURE bdiprog:"informix".sp_altabajaterceros_bpi('01',
											  '05',
											  pNumCliente,
											  pNumTelefono,
											  '201',
											  pAlias,
											  'Telmex',
											  ' TME840315KT6',
											  '',
											  '00',
											  '',
											  '03',
											  '00',
											  p_sUser,p_CveCaducidad) INTO vCodRet, vMensaje;

		IF vCodRet = '00000' THEN
			EXECUTE PROCEDURE bdiprog:"informix".sp_altaconsultadigito(pNumCliente,pNumTelefono,'201',pDigito,'1') INTO vCodRet, vMensaje, vDigito;
		END IF;
	ELIF   ---- Valida que el TelÃ?Â©fono frecuente que fue dado de alta en sucursal y no tienen digito verificador para permitir su registro
		(SELECT count(user_insert) FROM bdiprog:"informix".pp_ctasterceros WHERE num_cte = pNumCliente AND cuenta = pNumTelefono AND cve_estado = '01' AND digito_ver = '') = 1 THEN
			EXECUTE PROCEDURE bdiprog:"informix".sp_altabajaterceros_bpi('01',
											  '05',
											  pNumCliente,
											  pNumTelefono,
											  '201',
											  pAlias,
											  'Telmex',
											  ' TME840315KT6',
											  '',
											  '00',
											  '',
											  '03',
											  '00',
											  p_sUser,p_CveCaducidad) INTO vCodRet, vMensaje;

		IF vCodRet = '00000' THEN
			EXECUTE PROCEDURE bdiprog:"informix".sp_altaconsultadigito(pNumCliente,pNumTelefono,'201',pDigito,'1') INTO vCodRet, vMensaje, vDigito;
		END IF;

	ELSE
		LET vCodRet = '90000';
		LET vMensaje = 'La cuenta ya existe';
	END IF;

	RETURN vCodRet, vMensaje;
END;
END PROCEDURE;
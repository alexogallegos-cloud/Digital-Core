CREATE PROCEDURE "informix".sp_migra_tablas_cobranza_peticion(pfecha DATE)
       RETURNING CHAR(6), CHAR(80);

-- execute procedure "informix".sp_migra_tablas_cobranza();

--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			    INTEGER;
DEFINE isam_err 		    INTEGER;
DEFINE error_info		    CHAR(80);
DEFINE cMensaje 		    CHAR(200);
define P_MENSAJE			CHAR(80);
DEFINE cCod_ret             CHAR(6);

----------------------------------------------------------------------
DEFINE vproceso				CHAR(4);
DEFINE Vempresa				CHAR(3);
DEFINE Vnum_campana			SMALLINT;
DEFINE vcliente             CHAR(20);
DEFINE vcredito             CHAR(20);
DEFINE Vproducto			CHAR(4);
DEFINE VfechaEnvio			DATE;
DEFINE vciudad              CHAR(10);
DEFINE vestado              CHAR(10);
DEFINE vt_celular           CHAR(13);
DEFINE cNombre1				CHAR(26);
DEFINE cNombre2				CHAR(26);
DEFINE cApellPat			CHAR(26);
DEFINE cApellMat			CHAR(26);
DEFINE vMora				SMALLINT;
DEFINE vsdo_venc_int_mora   DEC(18,2);
DEFINE vpago_min            DEC(18,2);
DEFINE vpago_min_sin_vdo    DEC(18,2); 
DEFINE vpago_venc           DEC(18,2); 
DEFINE vpago_req_sms		DEC(18,2);
DEFINE vCosto				DEC(18,2);
DEFINE vResultadoEntrega	CHAR(15);
DEFINE vPagoDia1			DEC(18,2);
DEFINE vPagoDia2			DEC(18,2);
DEFINE vPagoDia3			DEC(18,2);
DEFINE vPagoDia4			DEC(18,2);
DEFINE vPagoDia5			DEC(18,2);
DEFINE vPagoNdias			DEC(18,2);
DEFINE vEstatusResultado	CHAR(02);
DEFINE vFechaCambioEstatus  DATE;
DEFINE vResultadoMora		SMALLINT;
DEFINE vFechaApertura		DATE;
DEFINE vFechaPrimerConsumo  DATE;
DEFINE vLineaCredito		DEC(18,2);
DEFINE vTipoTransaccion		CHAR(30);
DEFINE vMontoTransaccion	DEC(18,2);
DEFINE vPorcentaje_uso      DEC(18,2);
DEFINE vCorreoElec			CHAR(100);
DEFINE vPagoReqEmail		DEC(18,2);
DEFINE vCount				CHAR(1);

DEFINE iCuentasProcesadas   INTEGER; 
DEFINE iCuentasInsertadas   INTEGER; 
DEFINE iCuentasEliminadas   INTEGER; 

DEFINE c_sucursal			CHAR(4);
DEFINE d_fecha_insert		DATE;
DEFINE c_usuario			CHAR(8);
DEFINE d_pago_min			DECIMAL(14,2);
DEFINE d_saldo_vencido		DECIMAL(14,2);
DEFINE d_pago_realizado		DECIMAL(14,2);
DEFINE d_pct_cump_pm		DECIMAL(5,2);
DEFINE d_pct_cump_sv		DECIMAL(5,2);
DEFINE c_folio_suc			CHAR(16);
DEFINE c_reversado			CHAR(1);
DEFINE dt_hora_mov			DATETIME YEAR to SECOND;
DEFINE c_transacc_suc		CHAR(4);
DEFINE c_codigo_fun			CHAR(3);

DEFINE v_transaccion		CHAR(7);
DEFINE v_ip					CHAR(20);
DEFINE v_fecha				DATE;
DEFINE v_hora				DATETIME HOUR to FRACTION(3);
DEFINE v_numcte				CHAR(20);
DEFINE v_ejecutivo			CHAR(8);
DEFINE v_apellido_pat		CHAR(26);
DEFINE v_apellido_mat		CHAR(26);
DEFINE v_pri_nombre			CHAR(26);
DEFINE v_seg_nombre			CHAR(26);
DEFINE v_codigo_retorno		CHAR(6);
--DEFINE vtoday				DATE;

--------------------------------------------
LET Vempresa 			= '';
LET Vnum_campana 		= 0;
LET vcliente         	= '';
LET vcredito        	= '';
LET Vproducto 			= '';
LET VfechaEnvio 		= DATE(1);
LET vciudad          = '';
LET vestado          = '';
LET cNombre1			= '';
LET cNombre2			= '';
LET cApellPat			= '';
LET cApellMat			= '';
LET vMora				= 0;
LET vCosto				= 0;
LET vResultadoEntrega	= '';
LET vPagoDia1			= 0;
LET vPagoDia2			= 0;
LET vPagoDia3			= 0;
LET vPagoDia4			= 0;
LET vPagoDia5			= 0;
LET vPagoNdias			= 0;
LET vEstatusResultado	= '';
LET vFechaCambioEstatus = DATE(1);
LET vResultadoMora		= 0;
LET vFechaApertura		= DATE(1);
LET vFechaPrimerConsumo = DATE(1);
LET vLineaCredito		= 0;
LET vTipoTransaccion	= '';
LET vMontoTransaccion	= 0;
LET vPorcentaje_uso		= 0;
LET vCorreoElec			= '';
LET vPagoReqEmail		= 0;
LET vpago_req_sms		= 0;
LET vCount 				= '1';

LET iCuentasProcesadas  = 0;
LET iCuentasInsertadas  = 0;
LET iCuentasEliminadas  = 0;

LET c_sucursal			= '';
LET d_fecha_insert		= DATE(1);
LET c_usuario			= '';
LET d_pago_min			= 0;
LET d_saldo_vencido		= 0;
LET d_pago_realizado	= 0;
LET d_pct_cump_pm		= 0;
LET d_pct_cump_sv		= 0;
LET c_folio_suc			= '';
LET c_reversado			= '';
LET dt_hora_mov			= DATE(1);
LET c_transacc_suc		= '';
LET c_codigo_fun		= '';

LET v_transaccion		= '';
LET v_ip				= '';
LET v_fecha				= DATE(1);
LET v_hora				= DATE(1);
LET v_numcte			= '';
LET v_ejecutivo			= '';
LET v_apellido_pat		= '';
LET v_apellido_mat		= '';
LET v_pri_nombre		= '';
LET v_seg_nombre		= '';
LET v_codigo_retorno	= '';
--LET vtoday				= today;
---------------------------------------

--SET DEBUG FILE TO '/aplicacion/Carlos/sp_migra_tablas_cobranza.out';
--TRACE ON;

	LET cCod_ret      = '000000';
	LET sql_err       = 0;
	LET isam_err      = 0;
	LET error_info    = '';
	LET cMensaje      = '';
	LET P_MENSAJE     = 'El proceso de migracion de tablas de cobranza se realizo correctamente.';
	LET vproceso	  = '0315';
 

	BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret = sql_err;
		LET P_MENSAJE = error_info;
		CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, P_MENSAJE, '02')RETURNING cCod_ret; 
		LET cCod_ret = sql_err;
		RETURN cCod_ret, P_MENSAJE;
	END EXCEPTION;

--------------------------------------------------------------------------

	CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, cMensaje, '01')RETURNING cCod_ret; 

	--se obtiene la informacion
	SET ISOLATION TO dirty READ;
	SET LOCK MODE TO WAIT 3;
	
-----------------------------------SE OBTIENE EL NUMERO DE LA TABLA A TRABAJAR----------------------------------------
	SELECT TRIM(valor) 
	INTO vCount 
	FROM "informix".cb_param 
	WHERE empresa = '001'
	AND cod_param = '86';

	IF vCount IS NULL OR vCount = '' THEN	
		LET cCod_ret = '000010';
		LET P_MENSAJE = 'NO SE ENCUENTRA EL VALOR DEL NUMERO DE LA TABLA A TRABAJAR';
		CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, P_MENSAJE, '02')RETURNING cCod_ret;
		LET cCod_ret = '000010';
		RETURN cCod_ret, P_MENSAJE;	
	ELIF vCount < '1' or vCount > '4' THEN
		LET cCod_ret = '000020';
		LET P_MENSAJE = 'EL VALOR DEL NUMERO DE LA TABLA A TRABAJAR NO ES VALIDO';
		CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, P_MENSAJE, '02')RETURNING cCod_ret;
		LET cCod_ret = '000020';
		RETURN cCod_ret, P_MENSAJE;	
	end if;

	IF vCount = '1' THEN
-----------------------------------Se obtienen DATOS del CLIENTE y SALDOS--------------------------------------------
		SELECT empresa, num_campana, num_credito, numcte, num_producto, fecha_envio, ciudad, estado, num_celular, nombre1,
			nombre2, apell_paterno, apell_materno, mora, sdo_venc_int_mora, pago_min, pago_min_sin_vdo, pago_ven, pago_req_sms, costo,
			resultado_entrega, pago_dia1, pago_dia2, pago_dia3, pago_dia4, pago_dia5, pago_ndias, estatus_resultado, fecha_cambio_estatus, resultado_mora,
			fecha_apertura, fecha_primer_consumo, linea_credito, tipo_transaccion, monto_transaccion, porcentaje_uso 
		FROM "informix".cb_rep_resultado_sms
		WHERE empresa = '001'
		AND fecha_envio = pfecha
		INTO TEMP cb_sms WITH NO LOG;
		
		CREATE INDEX idx_cb_sms ON cb_sms(empresa);
		UPDATE STATISTICS MEDIUM FOR TABLE cb_sms; 

		FOREACH WITH HOLD
		
			SELECT empresa, num_campana, num_credito, numcte, num_producto, fecha_envio, ciudad, estado, num_celular, nombre1,
				nombre2, apell_paterno, apell_materno, mora, sdo_venc_int_mora, pago_min, pago_min_sin_vdo, pago_ven, pago_req_sms, costo,
				resultado_entrega, pago_dia1, pago_dia2, pago_dia3, pago_dia4, pago_dia5, pago_ndias, estatus_resultado, fecha_cambio_estatus, resultado_mora,
				fecha_apertura, fecha_primer_consumo, linea_credito, tipo_transaccion, monto_transaccion, porcentaje_uso 
			INTO Vempresa, Vnum_campana, vcredito, vcliente, Vproducto, VfechaEnvio, vciudad, vestado, vt_celular, cNombre1,
				cNombre2, cApellPat, cApellMat, vMora, vsdo_venc_int_mora, vpago_min, vpago_min_sin_vdo, vpago_venc, vpago_req_sms, vCosto,
				vResultadoEntrega, vPagoDia1,vPagoDia2, vPagoDia3, vPagoDia4, vPagoDia5, vPagoNdias, vEstatusResultado, vFechaCambioEstatus, vResultadoMora,
				vFechaApertura, vFechaPrimerConsumo, vLineaCredito, vTipoTransaccion, vMontoTransaccion, vPorcentaje_uso
			FROM "informix".cb_sms
			WHERE empresa = '001'

-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS PROCESADAS--------------------------------------
			LET iCuentasProcesadas = iCuentasProcesadas + 1;
			
-----------------------------------SE INCERTAN DATOS GENERADOS--------------------------------------------------------
			BEGIN WORK;
				INSERT INTO "informix".cb_rep_resultado_sms_hist (
					empresa, num_campana, num_credito, numcte, num_producto, fecha_envio, ciudad, estado, num_celular, nombre1,
					nombre2, apell_paterno, apell_materno, mora, sdo_venc_int_mora, pago_min, pago_min_sin_vdo, pago_ven, pago_req_sms, costo,
					resultado_entrega, pago_dia1, pago_dia2, pago_dia3, pago_dia4, pago_dia5, pago_ndias, estatus_resultado, fecha_cambio_estatus, resultado_mora,
					fecha_apertura, fecha_primer_consumo, linea_credito, tipo_transaccion, monto_transaccion, porcentaje_uso)
				VALUES(Vempresa, Vnum_campana, vcredito, vcliente, Vproducto, VfechaEnvio, vciudad, vestado, vt_celular, cNombre1,
					cNombre2, cApellPat, cApellMat, vMora, vsdo_venc_int_mora, vpago_min, vpago_min_sin_vdo, vpago_venc, vpago_req_sms, vCosto,
					vResultadoEntrega, vPagoDia1, vPagoDia2, vPagoDia3, vPagoDia4, vPagoDia5, vPagoNdias, vEstatusResultado, vFechaCambioEstatus, vResultadoMora,
					vFechaApertura, vFechaPrimerConsumo, vLineaCredito, vTipoTransaccion, vMontoTransaccion, vPorcentaje_uso);

-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS INSERTADAS--------------------------------------
				LET iCuentasInsertadas = iCuentasInsertadas + 1;

-----------------------------------Borramos los clientes de la tabla cb_rep_resultado_sms----------------------	
				DELETE 
				FROM "informix".cb_rep_resultado_sms 
				WHERE empresa = Vempresa 
				AND num_campana = Vnum_campana 
				AND num_credito = vcredito 
				AND fecha_envio = VfechaEnvio;

-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS ELIMINADAS--------------------------------------
				LET iCuentasEliminadas = iCuentasEliminadas +1;
				
			COMMIT WORK;
			
		LET Vempresa, Vnum_campana, vcredito, vcliente, Vproducto, VfechaEnvio, vciudad, vestado, vt_celular, cNombre1 = '', 0, '', '', '', DATE(1), '', '', '', '';
		LET cNombre2, cApellPat, cApellMat, vMora, vsdo_venc_int_mora, vpago_min, vpago_min_sin_vdo, vpago_venc, vpago_req_sms, vCosto = '', '', '', 0, 0, 0, 0, 0, 0, 0;
		LET vResultadoEntrega, vPagoDia1, vPagoDia2, vPagoDia3, vPagoDia4, vPagoDia5, vPagoNdias, vEstatusResultado, vFechaCambioEstatus, vResultadoMora = '', 0, 0, 0, 0, 0, 0, '', DATE(1), 0;
		LET vFechaApertura, vFechaPrimerConsumo, vLineaCredito, vTipoTransaccion, vMontoTransaccion, vPorcentaje_uso = DATE(1), DATE(1), 0, '', 0, 0;
			
		END FOREACH;
		
	DROP TABLE cb_sms;
	
-----------------------------------Genera cifras de control-----------------------------------------------------------
	    IF iCuentasProcesadas > 0 THEN
	       LET cMensaje = 'TOTAL cuentas PROCESADAS SMSs : ' || iCuentasProcesadas;
	       LET cMensaje = TRIM(cMensaje) ||'   TOTAL cuentas INSERTADAS SMSs a histórica : ' || iCuentasInsertadas;
	       CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, TRIM(cMensaje), '02') RETURNING cCod_ret;
		   LET cMensaje = '';
	       LET cMensaje = 'TOTAL cuentas ELIMINADAS SMSs : ' || iCuentasEliminadas;
	       CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, TRIM(cMensaje), '02') RETURNING cCod_ret;
	    END IF;
		
-----------------------------------INICIALIZACION DE VARIABLES DE CONTEO----------------------------------------------
		LET cMensaje = '';
		LET iCuentasProcesadas = 0;
		LET iCuentasInsertadas = 0;
		LET iCuentasEliminadas = 0;
		LET vCount = '2';
		
		UPDATE "informix".cb_param 
        SET valor = vCount
		WHERE empresa = '001'
		AND cod_param = '86';

	END IF;
	
	IF vCount = '2' THEN
-----------------------------------Se obtienen DATOS del CLIENTE y SALDOS---------------------------------------------
		SELECT empresa, num_campana, num_credito, numcte, num_producto, fecha_envio, ciudad, estado, correo_elec, nombre1,
			nombre2, apell_paterno, apell_materno, mora, sdo_venc_int_mora, pago_min, pago_min_sin_vdo, pago_ven, pago_req_email, costo,
			resultado_entrega, pago_dia1, pago_dia2, pago_dia3, pago_dia4, pago_dia5, pago_ndias, estatus_resultado, fecha_cambio_estatus, resultado_mora,
			fecha_apertura, fecha_primer_consumo, linea_credito, tipo_transaccion, monto_transaccion, porcentaje_uso
		FROM "informix".cb_rep_resultado_mail
		WHERE empresa = '001'
		AND fecha_envio = pfecha
		INTO TEMP cb_mail WITH NO LOG;
		
		CREATE INDEX idx_cb_mail ON cb_mail(empresa);
		UPDATE STATISTICS MEDIUM FOR TABLE cb_mail;

		FOREACH WITH HOLD
		
			SELECT empresa, num_campana, num_credito, numcte, num_producto, fecha_envio, ciudad, estado, correo_elec, nombre1,
				nombre2, apell_paterno, apell_materno, mora, sdo_venc_int_mora, pago_min, pago_min_sin_vdo, pago_ven, pago_req_email, costo,
				resultado_entrega, pago_dia1, pago_dia2, pago_dia3, pago_dia4, pago_dia5, pago_ndias, estatus_resultado, fecha_cambio_estatus, resultado_mora,
				fecha_apertura, fecha_primer_consumo, linea_credito, tipo_transaccion, monto_transaccion, porcentaje_uso
			INTO Vempresa, Vnum_campana, vcredito, vcliente, Vproducto, VfechaEnvio, vciudad, vestado, vCorreoElec, cNombre1,
				cNombre2, cApellPat, cApellMat, vMora, vsdo_venc_int_mora, vpago_min, vpago_min_sin_vdo, vpago_venc, vPagoReqEmail, vCosto,
				vResultadoEntrega, vPagoDia1, vPagoDia2, vPagoDia3, vPagoDia4, vPagoDia5, vPagoNdias, vEstatusResultado, vFechaCambioEstatus, vResultadoMora,
				vFechaApertura,	vFechaPrimerConsumo, vLineaCredito, vTipoTransaccion, vMontoTransaccion, vPorcentaje_uso
			FROM "informix".cb_mail
			WHERE empresa = '001'
			
-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS PROCESADAS--------------------------------------
			LET iCuentasProcesadas = iCuentasProcesadas + 1;

-----------------------------------SE INCERTAN DATOS GENERADOS--------------------------------------------------------
			BEGIN WORK;
			
				INSERT INTO "informix".cb_rep_resultado_mail_hist(
					empresa, num_campana, num_credito, numcte, num_producto, fecha_envio, ciudad, estado, correo_elec, nombre1,
					nombre2, apell_paterno, apell_materno, mora, sdo_venc_int_mora, pago_min, pago_min_sin_vdo, pago_ven, pago_req_email, costo,
					resultado_entrega, pago_dia1, pago_dia2, pago_dia3, pago_dia4, pago_dia5, pago_ndias, estatus_resultado, fecha_cambio_estatus, resultado_mora,
					fecha_apertura, fecha_primer_consumo, linea_credito, tipo_transaccion, monto_transaccion, porcentaje_uso)
				VALUES(Vempresa, Vnum_campana, vcredito, vcliente, Vproducto, VfechaEnvio, vciudad, vestado, vCorreoElec, cNombre1,
					cNombre2, cApellPat, cApellMat, vMora, vsdo_venc_int_mora, vpago_min, vpago_min_sin_vdo, vpago_venc, vPagoReqEmail, vCosto,
					vResultadoEntrega, vPagoDia1, vPagoDia2, vPagoDia3, vPagoDia4, vPagoDia5, vPagoNdias, vEstatusResultado, vFechaCambioEstatus, vResultadoMora,
					vFechaApertura, vFechaPrimerConsumo, vLineaCredito, vTipoTransaccion, vMontoTransaccion, vPorcentaje_uso);

-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS INSERTADAS--------------------------------------
				LET iCuentasInsertadas = iCuentasInsertadas + 1;
			
-----------------------------------Borramos los clientes de la tabla cb_rep_resultado_mail----------------------	
				DELETE 
				FROM "informix".cb_rep_resultado_mail 
				WHERE empresa = Vempresa 
				AND num_campana = Vnum_campana 
				AND num_credito = vcredito
				AND fecha_envio = VfechaEnvio;

-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS ELIMINADAS--------------------------------------
				LET iCuentasEliminadas = iCuentasEliminadas + 1;

			COMMIT WORK;
			
		LET Vempresa, Vnum_campana, vcredito, vcliente, Vproducto, VfechaEnvio, vciudad, vestado, vCorreoElec, cNombre1 = '', 0, '', '', '', DATE(1), '', '', '', '';
		LET cNombre2, cApellPat, cApellMat, vMora, vsdo_venc_int_mora, vpago_min, vpago_min_sin_vdo, vpago_venc, vpago_req_sms, vCosto = '', '', '', 0, 0, 0, 0, 0, 0, 0;
		LET vResultadoEntrega, vPagoDia1, vPagoDia2, vPagoDia3, vPagoDia4, vPagoDia5, vPagoNdias, vEstatusResultado, vFechaCambioEstatus, vResultadoMora = '', 0, 0, 0, 0, 0, 0, '', DATE(1), 0;
		LET vFechaApertura, vFechaPrimerConsumo, vLineaCredito, vTipoTransaccion, vMontoTransaccion, vPorcentaje_uso = DATE(1), DATE(1), 0, '', 0, 0;
			
		END FOREACH;

	DROP TABLE cb_mail;

-----------------------------------Genera cifras de control-----------------------------------------------------------
	    IF iCuentasProcesadas > 0 THEN
	       let cMensaje = 'TOTAL cuentas PROCESADAS MAILs : ' || iCuentasProcesadas;
	       let cMensaje = TRIM(cMensaje) ||'   TOTAL cuentas INSERTADAS MAILs a histórica : ' || iCuentasInsertadas;
	       CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, TRIM(cMensaje), '02') RETURNING cCod_ret;
		   LET cMensaje = '';
	       let cMensaje = 'TOTAL cuentas ELIMINADAS MAILs : ' || iCuentasEliminadas;
	       CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, TRIM(cMensaje), '02') RETURNING cCod_ret;
	    END IF;

-----------------------------------INICIALIZACION DE VARIABLES DE CONTEO----------------------------------------------
		LET cMensaje = '';
		LET iCuentasProcesadas = 0;
		LET iCuentasInsertadas = 0;
		LET iCuentasEliminadas = 0;
		LET vCount = '3';
		
		UPDATE "informix".cb_param 
        SET valor = vCount
		WHERE empresa = '001'
		AND cod_param = '86';
		
	END IF;
	
	IF vCount = '3' THEN
-----------------------------------Se obtienen DATOS del CLIENTE y SALDOS---------------------------------------------
		SELECT empresa, sucursal, fecha_insert, usuario, num_credito,
			pago_min, saldo_vencido, pago_realizado, pct_cump_pm, pct_cump_sv,
			folio_suc, reversado, hora_mov, transacc_suc, codigo_fun 
		FROM "informix".cb_evaluacion_objetiva
		WHERE empresa = '001'
		AND fecha_insert = pfecha
		INTO TEMP cb_objetiva WITH NO LOG;
		
		CREATE INDEX idx_cb_objetiva ON cb_objetiva(empresa);
		UPDATE STATISTICS MEDIUM FOR TABLE cb_objetiva;

		FOREACH WITH HOLD
			
			SELECT empresa, sucursal, fecha_insert, usuario, num_credito,
				pago_min, saldo_vencido, pago_realizado, pct_cump_pm, pct_cump_sv,
				folio_suc, reversado, hora_mov, transacc_suc, codigo_fun 
			INTO Vempresa, c_sucursal, d_fecha_insert, c_usuario, vcredito,
				d_pago_min, d_saldo_vencido, d_pago_realizado, d_pct_cump_pm, d_pct_cump_sv,   
				c_folio_suc, c_reversado, dt_hora_mov, c_transacc_suc, c_codigo_fun    
			FROM "informix".cb_objetiva
			WHERE empresa = '001'
		
-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS PROCESADAS--------------------------------------
			LET iCuentasProcesadas = iCuentasProcesadas + 1;
			
-----------------------------------SE INCERTAN DATOS GENERADOS--------------------------------------------------------
			BEGIN WORK;

				INSERT INTO "informix".cb_evaluacion_objetiva_his(
					empresa, sucursal, fecha_insert, usuario, num_credito,
					pago_min, saldo_vencido, pago_realizado, pct_cump_pm, pct_cump_sv,
					folio_suc, reversado, hora_mov, transacc_suc, codigo_fun) 
				VALUES(Vempresa, c_sucursal, d_fecha_insert, c_usuario, vcredito,
					d_pago_min, d_saldo_vencido, d_pago_realizado, d_pct_cump_pm, d_pct_cump_sv,
					c_folio_suc, c_reversado, dt_hora_mov, c_transacc_suc, c_codigo_fun);

-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS INSERTADAS--------------------------------------
				LET iCuentasInsertadas = iCuentasInsertadas + 1;
				
-----------------------------------Borramos los clientes de la tabla cb_evaluacion_objetiva----------------------	
				DELETE 
				FROM "informix".cb_evaluacion_objetiva 
				WHERE empresa = Vempresa 
				AND sucursal = c_sucursal
				AND fecha_insert = d_fecha_insert
				AND num_credito = vcredito
				AND folio_suc = c_folio_suc;

-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS ELIMINADAS--------------------------------------
				LET iCuentasEliminadas = iCuentasEliminadas + 1;

			COMMIT WORK;
			
		LET Vempresa, c_sucursal, d_fecha_insert, c_usuario, vcredito = '', '', DATE(1), '', '';
		LET d_pago_min, d_saldo_vencido, d_pago_realizado, d_pct_cump_pm, d_pct_cump_sv = 0, 0, 0, 0, 0;
		LET c_folio_suc, c_reversado, dt_hora_mov, c_transacc_suc, c_codigo_fun = '', '', DATE(1), '', '';
			
		END FOREACH;
		
	DROP TABLE cb_objetiva;

-----------------------------------Genera cifras de control-----------------------------------------------------------
	    IF iCuentasProcesadas > 0 THEN
	       let cMensaje = 'TOTAL cuentas PROCESADAS OBJETIVAS : ' || iCuentasProcesadas;
	       let cMensaje = TRIM(cMensaje) ||'   TOTAL cuentas INSERTADAS OBJETIVAS a histórica : ' || iCuentasInsertadas;
	       CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, TRIM(cMensaje), '02') RETURNING cCod_ret;
		   LET cMensaje = '';
	       let cMensaje = 'TOTAL cuentas ELIMINADAS OBJETIVAS : ' || iCuentasEliminadas;
	       CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, TRIM(cMensaje), '02') RETURNING cCod_ret;
	    END IF;

-----------------------------------INICIALIZACION DE VARIABLES DE CONTEO----------------------------------------------
		LET cMensaje = '';
		LET iCuentasProcesadas = 0;
		LET iCuentasInsertadas = 0;
		LET iCuentasEliminadas = 0;
		LET vCount = '4';
		
		UPDATE "informix".cb_param 
        SET valor = vCount
		WHERE empresa = '001'
		AND cod_param = '86';
		
	END IF;
	
	IF vCount = '4' THEN
-----------------------------------Se obtienen DATOS del CLIENTE y SALDOS---------------------------------------------
		SELECT '001' empresa, transaccion, ip, fecha, hora, num_credito,
			numcte, ejecutivo, apellido_pat, apellido_mat, pri_nombre,
			seg_nombre, codigo_retorno 
		FROM "informix".cb_bitacora_predictivo
		WHERE fecha = pfecha
		INTO TEMP cb_predictivo WITH NO LOG;
		
		CREATE INDEX idx_cb_predictivo ON cb_predictivo(empresa);
		UPDATE STATISTICS MEDIUM FOR TABLE cb_predictivo;

		FOREACH WITH HOLD 
		
			SELECT transaccion, ip, fecha, hora, num_credito,
				numcte, ejecutivo, apellido_pat, apellido_mat, pri_nombre,
				seg_nombre, codigo_retorno 
			INTO v_transaccion, v_ip, v_fecha, v_hora, vcredito,
				v_numcte, v_ejecutivo, v_apellido_pat, v_apellido_mat, v_pri_nombre,
				v_seg_nombre, v_codigo_retorno
			FROM "informix".cb_predictivo
			WHERE empresa = '001'
		
-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS PROCESADAS--------------------------------------
			LET iCuentasProcesadas = iCuentasProcesadas + 1;
			
-----------------------------------SE INCERTAN DATOS GENERADOS--------------------------------------------------------
			BEGIN WORK;

				INSERT INTO "informix".cb_bitacora_predictivo_his(
					transaccion, ip, fecha, hora, num_credito,
					numcte, ejecutivo, apellido_pat, apellido_mat, pri_nombre,
					seg_nombre, codigo_retorno) 
				VALUES(v_transaccion, v_ip, v_fecha, v_hora, vcredito,
					v_numcte, v_ejecutivo, v_apellido_pat, v_apellido_mat, v_pri_nombre,
					v_seg_nombre, v_codigo_retorno);

-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS INSERTADAS--------------------------------------
				LET iCuentasInsertadas = iCuentasInsertadas + 1;
				
-----------------------------------Borramos los clientes de la tabla cb_bitacora_predictivo----------------------	
				DELETE 
				FROM "informix".cb_bitacora_predictivo 
				WHERE transaccion = v_transaccion 
				AND fecha = v_fecha
				AND hora = v_hora
				AND num_credito = vcredito;
				--AND numcte = v_numcte;

-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS ELIMINADAS--------------------------------------
				LET iCuentasEliminadas = iCuentasEliminadas + 1;

			COMMIT WORK;
			
		LET v_transaccion, v_ip, v_fecha, v_hora, vcredito = '', '', DATE(1), DATE(1), '';
		LET v_numcte, v_ejecutivo, v_apellido_pat, v_apellido_mat, v_pri_nombre = '', '', '', '', '';
		LET v_seg_nombre, v_codigo_retorno = '', '';
				
		END FOREACH;
		
	DROP TABLE cb_predictivo;

-----------------------------------Genera cifras de control-----------------------------------------------------------
	    IF iCuentasProcesadas > 0 THEN
	       let cMensaje = 'TOTAL cuentas PROCESADAS BITACORA PREDICTIVO : ' || iCuentasProcesadas;
	       let cMensaje = TRIM(cMensaje) ||'   TOTAL cuentas INSERTADAS BITACORA PREDICTIVO a histórica : ' || iCuentasInsertadas;
	       CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, TRIM(cMensaje), '02') RETURNING cCod_ret;		   
		   LET cMensaje = '';
	       let cMensaje = 'TOTAL cuentas ELIMINADAS BITACORA PREDICTIVO : ' || iCuentasEliminadas;
	       CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, TRIM(cMensaje), '02') RETURNING cCod_ret;
	    END IF;

-----------------------------------INICIALIZACION DE VARIABLES DE CONTEO----------------------------------------------
		LET cMensaje = '';
		LET iCuentasProcesadas = 0;
		LET iCuentasInsertadas = 0;
		LET iCuentasEliminadas = 0;
		LET vCount = '1';
		
		UPDATE "informix".cb_param 
        SET valor = vCount
		WHERE empresa = '001'
		AND cod_param = '86';
		
	END IF;
	
	UPDATE STATISTICS MEDIUM FOR TABLE "informix".cb_rep_resultado_sms;
	UPDATE STATISTICS MEDIUM FOR TABLE "informix".cb_rep_resultado_sms_hist;
	
	UPDATE STATISTICS MEDIUM FOR TABLE "informix".cb_rep_resultado_mail;
	UPDATE STATISTICS MEDIUM FOR TABLE "informix".cb_rep_resultado_mail_hist;
	
	UPDATE STATISTICS MEDIUM FOR TABLE "informix".cb_evaluacion_objetiva;
	UPDATE STATISTICS MEDIUM FOR TABLE "informix".cb_evaluacion_objetiva_his;
	
	UPDATE STATISTICS MEDIUM FOR TABLE "informix".cb_bitacora_predictivo;
	UPDATE STATISTICS MEDIUM FOR TABLE "informix".cb_bitacora_predictivo_his;
	
-------INICIALIZACION DEL VALOR PARA LA PROXIMA EJECUCION DE LA MIGRACION DE LAS TABLAS DE COBRANZA-------------------
/*	IF cCod_ret = '000000' THEN
		UPDATE "informix".cb_param 
		SET valor = '1'
		WHERE empresa = '001'
		AND cod_param = '86';
	END IF;*/

	CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, cMensaje, '03') RETURNING cCod_ret; 
	
	RETURN cCod_ret, P_MENSAJE;

	END
END PROCEDURE
DOCUMENT
'MODIFICACION: CARLOS VALENZUELA',
'FECHA: 2015/08/21',
'DESCRIPCION: PROCESO QUE HACE LA MIGRACION ',
'DE LAS TABLAS DE COBRANZA - DE LA DIARIO A LA HISTORICA',
'BD: BDICOBRANZA';

CREATE PROCEDURE "informix".sp_actualiza_saldos_admin() 
RETURNING char(6), char(80);

--  execute PROCEDURE "informix".sp_actualiza_saldos_admin();
DEFINE cCod_ret             CHAR(6);
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(150);
DEFINE vhora				CHAR(8);
DEFINE max_fch_eje          DATE;
DEFINE vlNumInsert          INTEGER;
DEFINE vnumcte              CHAR(20);
DEFINE vnum_credito         CHAR(20);
DEFINE vpagos_vencidos      INTEGER;
DEFINE vciudad              CHAR(20);
DEFINE vestado              CHAR(20);
DEFINE vtelefono_celular    CHAR(13);
DEFINE vnumcampania         SMALLINT;
DEFINE vproducto            CHAR(4);
DEFINE vNombre1				CHAR(26);
DEFINE vNombre2				CHAR(26);
DEFINE vApellidoP			CHAR(26);
DEFINE vApellidoM			CHAR(26);
DEFINE v_mto_venc_trasp     DECIMAL(18,2);
DEFINE v_monto_financiado   DECIMAL(18,2);
DEFINE v_sdo_retenido       DECIMAL(18,2);
DEFINE v_sdo_cap_insoluto   DECIMAL(18,2);
DEFINE vinteres             DECIMAL(18,2);
DEFINE viva_interes         DECIMAL(18,2);
DEFINE vmoratorio           DECIMAL(18,2);
DEFINE viva_moratorio       DECIMAL(18,2);
DEFINE vpago_minimo_total   DECIMAL(18,2);
DEFINE vsaldo_total         DECIMAL(18,2);
DEFINE v_sdo_venc_int_mora  DECIMAL(18,2);
DEFINE v_pago_min_sin_vdo   DECIMAL(18,2);
DEFINE cCodRet              CHAR(6);
DEFINE P_COD_RET            CHAR(06);
DEFINE vempresa             CHAR(3);
DEFINE cproceso             CHAR(4);
DEFINE vsituacion           CHAR(1);
DEFINE vcausa               SMALLINT;
DEFINE vinstruccion         CHAR(1);

DEFINE	vSdoTotal1			DECIMAL(18,2);
DEFINE	vMtoVencido1		DECIMAL(18,2);
DEFINE	vSdoTotal2			DECIMAL(18,2);
DEFINE	vMtoVencido2		DECIMAL(18,2);
DEFINE	vMensualidad		DECIMAL(18,2);
DEFINE dtFechaHoy           DATE;
DEFINE sNumCampania         SMALLINT;
DEFINE cNumProducto         CHAR(4);
DEFINE dtfecha_ant          DATE;
DEFINE iCel                 SMALLINT;
DEFINE vpago_vencido		DECIMAL(18,2);
DEFINE vmora                SMALLINT;
DEFINE vvalor_numerico      INTEGER;
DEFINE vcontador            INTEGER;
DEFINE vlimit               INTEGER;
DEFINE vnum                 INTEGER;
DEFINE vnum1                INTEGER;
--define vcount	integer;
DEFINE iCount_TC_MORA1S     INTEGER; --A.L.L.
DEFINE iCount_TC_MORA2S     INTEGER; 
DEFINE vvalor               SMALLINT;
DEFINE i                    INTEGER;
DEFINE num                  SMALLINT;
DEFINE vCampoBaja           CHAR(10);
DEFINE P_MENSAJE            CHAR(80);
DEFINE iCuentasProcesadas               INTEGER;
DEFINE iCuentasExcluidasXSdosVencidos   INTEGER;
DEFINE iCuentasExcluidasXCel            INTEGER;
DEFINE iCuentasExcluidasXSitEspecial    INTEGER;
DEFINE dFechaCarLinea       DATE;
DEFINE iCuentasProcesadas_TC_MORA1S     INTEGER;
DEFINE iCuentasProcesadas_TC_MORA2S     INTEGER;
DEFINE iCuentasExcluidasXCel_TC_MORA1S  INTEGER;
DEFINE iCuentasExcluidasXCel_TC_MORA2S  INTEGER;

--SET DEBUG FILE TO 'sp_actualiza_saldos_admin.out';
--TRACE ON;

LET cCod_ret        = '000000';
LET P_COD_RET       = "000000";
LET sql_err         = 0;
LET isam_err        = 0;
LET error_info      = '';
LET cMensaje        = 'PROCESO EXITOSO';
let P_MENSAJE       = 'El proceso de las campañas SMS MORAS TDC se realizó correctamente.';
LET vempresa        = '001';
LET cproceso        = '2080';
LET dtFechaHoy      = '';
LET dtfecha_ant     = '';
LET vmora           = 0;
LET vvalor_numerico = 0;
LET vcontador       = 0;
LET vlimit          = 0;
LET vnum            = 0;
LET vnum1           = 0;
--	let vcount = 0;
LET iCount_TC_MORA1S = 0;
LET iCount_TC_MORA2S = 0;
LET i           = 0;
LET num         = 0;
LET vCampoBaja  = '';
LET iCuentasProcesadas               = 0;
LET iCuentasExcluidasXSdosVencidos   = 0;
LET iCuentasExcluidasXCel            = 0;
LET iCuentasExcluidasXSitEspecial    = 0;
LET dFechaCarLinea = date(1); 
LET cNumProducto	= '';
LET iCuentasExcluidasXCel_TC_MORA1S = 0;
LET iCuentasExcluidasXCel_TC_MORA2S = 0;
LET iCuentasProcesadas_TC_MORA1S    = 0;
LET iCuentasProcesadas_TC_MORA2S    = 0;


    BEGIN        
        ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET P_COD_RET= sql_err;
        LET P_MENSAJE = error_info;
        LET cMensaje = vnum_credito||'  '||error_info;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '02')
        RETURNING cCodRet;
        RETURN P_COD_RET,P_MENSAJE;
    END EXCEPTION;

 	 CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '01') RETURNING cCodRet;

     if cCodRet != '000000' then
        let P_COD_RET = cCodRet;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO dirty READ;

    LET vlNumInsert =0;
	LET vSdoTotal1			=0;
	LET vMtoVencido1		=0;
	LET vSdoTotal2			=0;
	LET vMtoVencido2		=0;
	LET vMensualidad		=0;
	LET iCel =0;
	LET vpago_vencido 		=0;

    SELECT NVL(fecha_hoy ,today), fecha_ant
    INTO dtFechaHoy, dtfecha_ant
    FROM bdicred:"informix".sd_fechas
    WHERE empresa = '001';	

--let dtFechaHoy = mdy('02','26','2015');
--let dtfecha_ant = mdy('02','25','2015');

/*    SELECT num_campania,num_producto
	INTO sNumCampania,cNumProducto
	FROM bdicobranza:"informix".cb_cat_campania
	WHERE num_campania = 5;*/

/*    delete from bdicobranza:"informix".cb_info_administrativa 
    where empresa ='001' and num_campania =sNumCampania and fecha_ejecucion <= dtFechaHoy;*/
	
	select length(valor) into vvalor
	from bdicobranza:cb_param where cod_param = 57;
	LET vvalor = vvalor / 9;

 -- LET dtFechaHoy = '12-26-2012';  --- PARA PRUEBA SOLAMENTE
			
FOREACH
	select valor_numerico into vvalor_numerico
	from bdicobranza:cb_param_campania
	where tipo_campania = 51
		and grupo_parametro = 'LATINIA'
		and num_parametro in (2,3)
	let vmora = vmora + 1 ;	
	
	--busca total de enviados y limir por tipo de mora
	select cuenta from bdimnsj:mnsjr_trx_batch where id_mensaje = 'TC_MORA'||vmora||'S' into temp cuentas;
	if (vmora = 1) then
	select valor_numerico into vlimit from bdicobranza:cb_param_campania
		where tipo_campania = 51 and grupo_parametro = 'LATINIA' and num_parametro = 13; end if;
	if (vmora = 2) then
	select valor_numerico into vlimit from bdicobranza:cb_param_campania
		where tipo_campania = 51 and grupo_parametro = 'LATINIA' and num_parametro = 14; end if;

	select count(*) into vnum1 from bdimnsj:mnsjr_trx_batch where id_mensaje = 'TC_MORA'||vmora||'S';
	let vnum = vvalor_numerico - vnum1;
	if(vnum1 < vvalor_numerico ) then	
		if (vnum > vlimit) then
			let vlimit = vlimit;
		else
			let vlimit = vvalor_numerico - vnum1;
		end if;	
	end if;

{            SELECT  cl.numcte                                                        --- pagos
                ,cl.num_credito                                                     --- Numero de Credito
                ,cl.mto_fin_ven_trasp                                                         --- pagos vencidos
                ,b.numerociudad || '-' || TRIM(j.inicialciudad) Ciudad            --- ciudad
                ,j.numeroestado || '-' || TRIM(j.inicialestado) Estado            --- estado        
                ,(cl.sdo_capital +  cl.monto_vencido + cl.mto_venc_trasp + cl.cap_tras_no_venci + cl.moratorio + cl.interes_iva ) SdoTotal1
                ,(cl.monto_vencido + cl.mto_venc_trasp + cl.moratorio + cl.interes_iva) MtoVencido1,
                cl.mensualidad_actual,
                cl.monto_vencido + cl.mto_venc_trasp     	
            INTO vnumcte, vnum_credito, vpagos_vencidos, vciudad, vestado, 
                 vsaldo_total, 
                 v_sdo_venc_int_mora,
                 vMensualidad,
                 vpago_vencido  
            FROM bdicred:"informix".sd_sdos_cartera_linea cl ,
                 bdinteg:"informix".si_direcciones_actual b , 
                 bdinteg:"informix".si_catciudades j
            WHERE cl.fecha = dtfecha_ant    
                AND cl.num_producto = '6001' 
                AND cl.mto_fin_ven_trasp = vmora  
                AND b.numcte = cl.numcte
                AND b.tipo_dir = '1'
                AND b.numerociudad = j.numerociudad
                AND cl.numcte NOT IN (SELECT numcliente FROM bdicobranza:"informix".cb_compac) -- que no tengan compromiso
                and cl.num_credito not in (select nvl(cuenta,'') from cuentas) }
	
    if (vmora <= 2 )then 
        FOREACH
            SELECT mae.numcte,mae.num_credito,mas.mto_fin_ven_trasp, mae.num_producto    
            INTO vnumcte, vnum_credito, vpagos_vencidos, cNumProducto
            FROM bdicred:sd_maecred mae
            INNER JOIN bdicred:sd_maesdos mas ON mas.empresa=mae.empresa AND mas.num_credito=mae.num_credito AND mas.mto_fin_ven_trasp = vmora 
            WHERE mae.empresa = vempresa
                AND mae.num_credito >= ''
                AND mae.num_producto = '6001' 
                AND mae.numcte NOT IN (SELECT numcliente FROM bdicobranza:"informix".cb_compac) -- que no tengan compromiso
                AND mae.num_credito NOT IN (select nvl(cuenta,'') FROM cuentas)
                AND campo_trab3 <> 'BAJA'


            LET iCuentasProcesadas = iCuentasProcesadas + 1;

            SELECT cl.fecha  
                ,cl.mto_fin_ven_trasp                                                         --- pagos vencidos
                ,(cl.sdo_capital +  cl.monto_vencido + cl.mto_venc_trasp + cl.cap_tras_no_venci + cl.moratorio + cl.interes_iva ) SdoTotal1
                ,(cl.monto_vencido + cl.mto_venc_trasp + cl.moratorio + cl.interes_iva) MtoVencido1,
                cl.mensualidad_actual,
                cl.monto_vencido + cl.mto_venc_trasp     	
            INTO dFechaCarLinea,
                 vpagos_vencidos, 
                 vsaldo_total, 
                 v_sdo_venc_int_mora,
                 vMensualidad,
                 vpago_vencido  
            FROM bdicred:"informix".sd_sdos_cartera_linea cl
            WHERE cl.num_credito = vnum_credito;

			IF dFechaCarLinea IS NULL OR dFechaCarLinea = '' THEN
               LET iCuentasExcluidasXSdosVencidos = iCuentasExcluidasXSdosVencidos + 1;
    		   CONTINUE foreach;
			END IF;

            let vtelefono_celular ='';	

            SELECT limit 1 d.telefono
                    INTO vtelefono_celular
                    FROM bdinteg:"informix".si_telefonos_actual d
                   WHERE d.numcte= vnumcte
                     AND d.tipo_tel= '2' and status_tel = 'A' and cofetel ='V' ;

			IF vtelefono_celular IS NULL OR vtelefono_celular = '' THEN	LET vtelefono_celular =''; END IF;
					 
					 
/*            IF vtelefono_celular IS NULL OR vtelefono_celular = '' THEN 
               LET iCuentasExcluidasXCel = iCuentasExcluidasXCel + 1;
               CONTINUE foreach; 
            END IF;*/

            SELECT  
                 b.numerociudad || '-' || TRIM(j.inicialciudad) Ciudad            --- ciudad
                ,j.numeroestado || '-' || TRIM(j.inicialestado) Estado            --- estado        
            INTO vciudad, vestado
            FROM bdinteg:"informix".si_direcciones_actual b , 
                 bdinteg:"informix".si_catciudades j
            WHERE b.numcte = vnumcte
                AND b.numerociudad = j.numerociudad
                AND b.tipo_dir = '1';

            SELECT nombre1,nombre2, apell_paterno,apell_materno
            INTO vNombre1,vNombre2,vApellidoP,vApellidoM
            FROM bdinteg:"informix".si_cliente
            WHERE numcte=vnumcte;

            LET vlNumInsert = vlNumInsert +1;

--            if (vtelefono_celular <> '') then
                LET iCel = LENGTH(vtelefono_celular) + 1 - 10;

--                IF vtelefono_celular <> '' then
                    IF ( LENGTH(vtelefono_celular) > 10 ) THEN
                       LET vtelefono_celular = SUBSTR(vtelefono_celular,iCel,10);
                    ELIF ( LENGTH(vtelefono_celular) < 10 ) THEN
                        LET vtelefono_celular =''; 
                    END IF;
--                END IF;
              /* select (sum(interes_debe - interes_pagado) + sum(iva_debe - iva_pagado)) Saldo_Total ,               
                   (sum(interes_debe - interes_pagado) +sum(iva_debe - iva_pagado)) Monto_Vencido
              into vSdoTotal2, vMtoVencido2
              from bdicred:sd_amortiza_credito am,  bdicred:sd_maecred cr,  bdinteg:si_sucursales suc
             where am.empresa = cr.empresa
               and cr.empresa = suc.empresa
               and am.num_credito = cr.num_credito
               and am.num_credito = vnum_credito
               and cr.sucursal = suc.sucursal
               and am.capital_status in ('2','7');  */	
            --LET vsaldo_total=  nvl(vSdoTotal1,0)+nvl(vSdoTotal2,0);  --Saldo Total
            --LET v_sdo_venc_int_mora = nvl(vMtoVencido1,0) + nvl(vMtoVencido2,0); --Vencido
                LET v_pago_min_sin_vdo =  nvl(vMensualidad,0);   --Mensualidad
            --LET vpago_minimo_total = nvl(v_pago_min_sin_vdo,0)+nvl(v_sdo_venc_int_mora,0);  --- Pago minimo

                LET vpago_minimo_total = v_sdo_venc_int_mora  +  vMensualidad;  --- Pago minimo  
                LET vsituacion = NULL;
                LET vcausa     = NULL;

                SELECT {+INDEX(bdisitesp:"informix".se_ctessitespcte "informix".se_ctessitespcte_idx1)} FIRST 1 NVL(situacion, ''),  NVL(causa, 0)
                  INTO   vsituacion, vcausa
                FROM bdisitesp:"informix".se_ctessitespcte
                WHERE numcte = vnumcte;

                LET vinstruccion = 1;
            --IF ((vsituacion IS NOT NULL) AND (vcausa IS NOT NULL)) THEN
                IF ( vsituacion <> '' AND vcausa <> 0 ) THEN   
                    SELECT FIRST 1 instruccion
                    INTO vinstruccion
                    FROM bdisitesp:"informix".se_situacionaccion
                    WHERE situacion= vsituacion
                        AND causa= vcausa
                        AND idaccion = 9
                        AND empresa = vempresa;
                END IF;

--                IF (vinstruccion = 1) and (nvl(vtelefono_celular,'') <> '') THEN				
                IF (vinstruccion = 1) THEN				
/*                    INSERT INTO bdicobranza:"informix".cb_info_administrativa(
                                empresa,num_campania,producto,fecha_ejecucion,cliente, credito, cuenta,tarjeta,ciudad, 
                                estado, apell_paterno,apell_materno,nombre1,nombre2, t_celular, sdo_total, pago_min,
                                fecha_pago,sdo_venc_int_mora,pago_venc,pago_min_sin_vdo,situacion,causa,pago_vencido,pago_req_sms) 
                    VALUES(vempresa,sNumCampania,cNumProducto,dtFechaHoy,vnumcte, vnum_credito,'', '',vciudad, 
                            vestado, vApellidoP,vApellidoM, vNombre1,vNombre2, vtelefono_celular, vsaldo_total,vpago_minimo_total,
                            --'',v_sdo_venc_int_mora,vpagos_vencidos,v_pago_min_sin_vdo, '',0);   --MACF                                          
                            '',v_sdo_venc_int_mora,vpagos_vencidos,v_pago_min_sin_vdo, vsituacion, vcausa,vpago_vencido,vpago_minimo_total);*/

                    --A.L.L.
                    if (vmora = 1) then
                        LET iCuentasProcesadas_TC_MORA1S = iCuentasProcesadas_TC_MORA1S + 1;

                        IF vtelefono_celular IS NULL OR vtelefono_celular = '' THEN 
                           LET iCuentasExcluidasXCel_TC_MORA1S = iCuentasExcluidasXCel_TC_MORA1S + 1;
                           CONTINUE foreach; 
                        END IF;

                        let iCount_TC_MORA1S	= iCount_TC_MORA1S +1;		
						call "informix".sp_inserta_info_rep_envios (vempresa,'SMS',5, vnum_credito, vnumcte, cNumProducto, today, vtelefono_celular, '','',vpago_minimo_total) returning P_COD_RET;
                    end if;
                    if (vmora = 2) then
                        LET iCuentasProcesadas_TC_MORA2S = iCuentasProcesadas_TC_MORA2S + 1;

                        IF vtelefono_celular IS NULL OR vtelefono_celular = '' THEN 
                           LET iCuentasExcluidasXCel_TC_MORA2S = iCuentasExcluidasXCel_TC_MORA2S + 1;
                           CONTINUE foreach; 
                        END IF;

                        let iCount_TC_MORA2S	= iCount_TC_MORA2S +1;		
						call "informix".sp_inserta_info_rep_envios (vempresa,'SMS',6, vnum_credito, vnumcte, cNumProducto, today, vtelefono_celular, '','',vpago_minimo_total) returning P_COD_RET;
                    end if;

                    call bdimnsj:"informix".sp_registra_evento (2, 'TC_MORA'||vmora||'S' , vnumcte, vnum_credito,'', 2,
                                        '','','','','',vpago_minimo_total,0,0,0,0, '', '')RETURNING P_COD_RET;


                    let vcontador = vcontador + 1;
                ELSE
                    LET iCuentasExcluidasXSitEspecial = iCuentasExcluidasXSitEspecial + 1;
                END IF;                    

                LET vSdoTotal1			=0;
                LET vMtoVencido1		=0;
                LET vSdoTotal2			=0;
                LET vMtoVencido2		=0;
                LET vMensualidad		=0;					

                IF vlNumInsert = 5000 then 
                   LET vlNumInsert = 1;
                   update statistics medium for table bdicobranza:"informix".cb_info_administrativa;
                END IF;
--            END IF;

            if (vcontador = vlimit) then exit FOREACH; end if;
            --if (vcontador = vvalor_numerico) then	exit FOREACH; end if;
        END FOREACH;
    end if;

/*
if (day(dtFechaHoy) = 26 and vcontador >= 1) then
		CALL bdicobranza:"informix".sp_sms_reporte(5,vmora,51,vmora + 1) RETURNING cCodRet;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCodRet, 'Archivo TC Mora '||vmora, '02')
          RETURNING cCodRet; 
end if;*/

	if (vcontador >= 1) then 
        let i = 0;
        LET num = 0;
        FOR i in (1 to vvalor)
            insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1,importe1)
            select  2, 'TC_MORA'||vmora||'S',numcte,current,apell_paterno,100
            from bdinteg:si_cliente
            where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param in (57));
			let num = num + 10;
		end for
	end if;
		
		let vvalor_numerico	= 0; let vcontador = 0;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCodRet, 'Proceso TC Mora '||vmora, '02')
        RETURNING cCodRet; 
	drop table cuentas;
END FOREACH;

     --A.L.L.
--     IF iCount_TC_MORA1S > 0 THEN
--         CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TC_MORA1S',iCount_TC_MORA1S) RETURNING cCodRet;
         CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TC_MORA1S',iCuentasProcesadas_TC_MORA1S,iCuentasExcluidasXCel_TC_MORA1S) RETURNING cCodRet;
--     END IF;
--     IF iCount_TC_MORA2S > 0 THEN
--         CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TC_MORA2S',iCount_TC_MORA2S) RETURNING cCodRet;
         CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TC_MORA2S',iCuentasProcesadas_TC_MORA2S,iCuentasExcluidasXCel_TC_MORA2S) RETURNING cCodRet;
--     END IF;

--Genera cifras de control
    if iCuentasProcesadas > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campañas TC_MORA1S y 2S : ' ||iCuentasProcesadas;
       let cMensaje = trim(cMensaje) ||'    SMSs enviados MORA 1 : ' ||iCount_TC_MORA1S;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'SMSs enviados MORA 2 : ' ||iCount_TC_MORA2S;
       let cMensaje = trim(cMensaje) ||'    Cuentas excluidas por error saldos vencidos : ' ||iCuentasExcluidasXSdosVencidos;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
--       let cMensaje = 'Cuentas excluidas por error celular : ' ||iCuentasExcluidasXCel;
       let cMensaje = 'Cuentas excluidas por error celular : ' ||iCuentasExcluidasXCel_TC_MORA1S + iCuentasExcluidasXCel_TC_MORA2S;
       let cMensaje = trim(cMensaje) ||'    Cuentas excluidas por situación especial : ' ||iCuentasExcluidasXSitEspecial;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
    end if;
--Genera cifras de control

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '03')
    RETURNING cCodRet;

     if cCodRet != '000000' then
        let P_COD_RET = cCodRet;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;

	RETURN P_COD_RET,P_MENSAJE;  --Se ejecuto Exitosamente.
END
END PROCEDURE
DOCUMENT 
'DESCRIPCION: Se actualiza procedimiento debido a un cambio en la estructura de la tabla cb_info_administrativa y si elimina el borrado de la ',
'tabla antes de la inserccion debido a que se encuentran implicadas otras campañas en la tabla.',
'AUTOR : Maria Elena Angulo Aispuro ',
'FECHA : 25/05/2011',
'BD    : BDICOBRANZA',
'Version: 20110525.1330',
'20110922 Optimización y conjuntar queries usados en sp_targetphone. Autor: Faviola Martínez J.',
'20120504 Cambio de fuente de obtención de saldos. Autor: Marco A. Campos',
'20120516 Que en la condición de fecha de sd_sdos_cartera_linea se compare con la fecha dia anterior. Autor: Marco A. Campos';

create procedure "informix".sp_latinia_contador_cobranza(pcampania char(10),pcontador integer,ptotalsintelosinmail integer)
returning VARCHAR(6);

--execute procedure "informix".sp_latinia_contador_cobranza('001',9000,8999)
DEFINE cCod_ret  	smallint;
DEFINE cMensaje  	char (100);
DEFINE SQL_ERR         INTEGER;
DEFINE ISAM_ERR        INTEGER;
DEFINE ERROR_INFO      VARCHAR(80);
DEFINE P_COD_RET      	VARCHAR(6);
DEFINE P_MENSAJE       	VARCHAR(80);
define vmaxfecha 		date;
define vfecha			date;

	let P_COD_RET = '000000';
	let cCod_ret = '';
    let cMensaje = '';
	let SQL_ERR            = 0;
	let ISAM_ERR           = 0;
	let ERROR_INFO         = '';
	let P_MENSAJE          = '';
	let vmaxfecha = date(1);
	let vfecha = date(1);


BEGIN 
  
    ON exception SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
     RETURN P_COD_RET;
     END exception;
--SET DEBUG FILE TO 'sp_latinia_contador_cobranza.out';
--TRACE ON;

    insert into  "informix".cb_totalcte_campania2 (empresa,fecha_insert,id_campania,total,total_sintel_o_sinmail)  
	values('001',today,pcampania,pcontador,ptotalsintelosinmail);

end
RETURN P_COD_RET;
END PROCEDURE;
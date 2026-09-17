CREATE PROCEDURE "informix".sp_guarda_cancelaciones(
	cNumCliente           CHAR(20),
	cNumeroCuenta         CHAR(20),
	cNumeroTarjeta        CHAR(20),
	cTipoDomiciliacion    CHAR(1),
	cCuentaClabe          CHAR(20),
	cStatusCancelacion    CHAR(1),
	cRefLeyenda           CHAR(40),
	cFolioSuc    		  CHAR(17),
	cSucursal             CHAR(4),
	cTransaccion          CHAR(4),
	cMonto                CHAR(15),
	cFechaMov             CHAR(12),
	cRefCliente           CHAR(15),
	cUsuarioInsert        CHAR(10),
	cFechaInsert          DATE)
	
	RETURNING 

	CHAR(5)   AS sCodigoRetorno, 
	CHAR(100) AS sCodigoDescripcion;
	
	/*  DEFINICION DE VARIABLES */

	-- DATOS SALIDA
	DEFINE sCodigoRetorno     CHAR(5);
	DEFINE sCodigoDescripcion CHAR(100);
	DEFINE iSqlErr            INTEGER;
	DEFINE sTipoNomDomi       CHAR(50);
	DEFINE sTipoNomMovimiento CHAR(2);
	DEFINE sRfcServicio       CHAR(20);
	DEFINE refServicio        CHAR(40);
	DEFINE cNumCteCoppel      CHAR(20);
	DEFINE cRfcCoppel         CHAR(18);
	
		
		/* INICIALIZACION DE VARIABLES */
	
	LET sCodigoRetorno = '00000';
	LET sCodigoDescripcion = 'Proceso Exitoso.';
	LET sTipoNomDomi = '';
	LET sTipoNomMovimiento = '';
	LET sRfcServicio = '';
	LET refServicio = '';
	LET cNumCteCoppel = '';
	LET cRfcCoppel = '';
	
	
BEGIN

	--Manejo de excepciones (errores)
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET sCodigoRetorno = iSqlErr;
			LET sCodigoDescripcion = 'ERROR NO CONTROLADO(' || iSqlErr || ')';
			
			INSERT INTO bdidomi:"informix".dom_errores(fecha_error, hora_error, cod_error, nombre_arch, sp_llamado, mensaje_error, user_insert, fecha_insert)
            VALUES(EXTEND(CURRENT::DATE, YEAR to SECOND), EXTEND(CURRENT::DATE, YEAR to SECOND)+10 UNITS HOUR+42 UNITS MINUTE+29 UNITS SECOND,sCodigoRetorno,'', 'bdidomi:sp_guarda_cancelaciones', 'OBTENER MENSAJES CODIGO DE ERROR DESCONOCIDO', 'sysdomi ', EXTEND(CURRENT::DATE, YEAR to SECOND));
			
			RETURN sCodigoRetorno,sCodigoDescripcion;
		END IF;
	END EXCEPTION; 

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	IF cNumeroTarjeta = '' OR LENGTH(cNumeroTarjeta) <= 15 OR LENGTH(cNumeroTarjeta) >= 17 THEN
		
		LET sCodigoRetorno = '00006';
	    LET sCodigoDescripcion = 'Tarjeta Invalida.';
		RETURN sCodigoRetorno,sCodigoDescripcion;
	
	END IF;
		
		IF EXISTS(SELECT count(*) FROM bdicheq:sc_tarjeta WHERE cuenta = TRIM(cNumeroCuenta) OR numcte = TRIM(cNumCliente) OR num_tarjeta = TRIM(cNumeroTarjeta))THEN  --Domiciliacion bancoppel
			
			FOREACH
				SELECT a.rfc
				INTO  sRfcServicio
				FROM bdidomi:dom_autorizaciones a
				INNER JOIN bdidomi:dom_cat_servicios b ON a.rfc = b.rfc
				WHERE a.num_cte = TRIM(cNumCliente)
				
				SELECT LPAD(TRIM(cuenta_clabe),20,'0') INTO cCuentaClabe FROM bdicheq:sc_maechq WHERE cuenta = TRIM(cNumeroCuenta);
				
				SELECT TRIM(valor) INTO cNumCteCoppel FROM bdidomi:dom_parametros WHERE cod_param = '45';
				
				SELECT rfc INTO cRfcCoppel FROM bdidomi:dom_cat_servicios WHERE num_cte=TRIM(cNumCteCoppel);
				                         
				IF sRfcServicio = TRIM(cRfcCoppel) THEN
					
					LET sTipoNomMovimiento = 'BA';
					
					SELECT imp_operacion, user_insert,ref_servicio
					INTO cMonto, cUsuarioInsert, refServicio
					FROM bdidomi:dom_cte_detalle a
					WHERE a.folio_suc = TRIM(cFolioSuc)
					AND a.ref_leyenda = TRIM(cRefLeyenda)
					AND a.nombre_arch LIKE '%E%'
					AND a.estatus = '01'
					AND (a.cuenta_cargo IN (SELECT LPAD(TRIM(num_tarjeta),20,'0') FROM bdicheq:sc_tarjeta WHERE cuenta = TRIM(cNumeroCuenta) AND numcte = TRIM(cNumCliente))
					OR a.cuenta_cargo = cCuentaClabe);
					
					IF NOT refServicio IS NULL OR NOT refServicio = "" THEN
					
						IF cTipoDomiciliacion = '1' THEN
							LET sTipoNomDomi = 'Domiciliacion por tarjeta'; ---Cancelacion de domiciliaciones por tarjeta
							
							INSERT INTO bdidomi:dom_cte_cancelaciones(cuenta,num_tarjeta,cuenta_clabe,status_cancelacion,ref_leyenda,rfc_servicio,ref_servicio,folio_suc,sucursal,transaccion,monto,fecha_movimiento,tipo_movimiento,id_tipo_domi,tipo_domi,usuario_insert,fecha_insert)
							VALUES (cNumeroCuenta,LPAD(TRIM(cNumeroTarjeta),20,'0'),cCuentaClabe,'0',cRefLeyenda,sRfcServicio,refServicio,cFolioSuc,cSucursal,cTransaccion,cMonto,cFechaMov,sTipoNomMovimiento,cTipoDomiciliacion,sTipoNomDomi,cUsuarioInsert, CURRENT);
							
							UPDATE bdidomi:dom_autorizaciones SET cve_estatus = '02' WHERE cuenta = cNumeroCuenta AND num_cte = cNumCliente; --Inhabilita la cuenta para poder hacer domiciliaciones
							LET sCodigoRetorno = '00000';
							LET sCodigoDescripcion = 'Proceso Exitoso.';
							RETURN sCodigoRetorno,sCodigoDescripcion;
						ELIF (cTipoDomiciliacion = '2') THEN
							LET sTipoNomDomi = 'Domiciliacion en especifico'; --Cancelacion de domiciliaciones en especifico
							
							INSERT INTO bdidomi:dom_cte_cancelaciones(cuenta,num_tarjeta,cuenta_clabe,status_cancelacion,ref_leyenda,rfc_servicio,ref_servicio,folio_suc,sucursal,transaccion,monto,fecha_movimiento,tipo_movimiento,id_tipo_domi,tipo_domi,usuario_insert,fecha_insert)
							VALUES (cNumeroCuenta,LPAD(TRIM(cNumeroTarjeta),20,'0'),cCuentaClabe,'0',cRefLeyenda,sRfcServicio,refServicio,cFolioSuc,cSucursal,cTransaccion,cMonto,cFechaMov,sTipoNomMovimiento,cTipoDomiciliacion,sTipoNomDomi,cUsuarioInsert, CURRENT);
							LET sCodigoRetorno = '00000';
							LET sCodigoDescripcion = 'Proceso Exitoso.';
							RETURN sCodigoRetorno,sCodigoDescripcion;
						END IF;		
						LET sCodigoRetorno = '00001';
						LET sCodigoDescripcion = 'La DomiciliaciÃ³n No Se Pudo Cancelar.';
						RETURN sCodigoRetorno,sCodigoDescripcion;
					ELSE 
						LET sCodigoRetorno = '00001';
						LET sCodigoDescripcion = 'La DomiciliaciÃ³n No Se Pudo Cancelar.';
						RETURN sCodigoRetorno,sCodigoDescripcion;
					END IF;		
				ELSE
				
					LET sTipoNomMovimiento = 'OB';
					
					SELECT a.importe,a.user_insert,ref_servicio
					INTO cMonto,cUsuarioInsert,refServicio
					FROM bdidomi:dom_cce_detalle a
					INNER JOIN bdidomi:dom_status_pago b ON a.cve_estatus = b.cve_status
					WHERE a.cve_estatus = '01' --Clave de Aplicado
					AND a.folio_suc = TRIM(cFolioSuc)
					AND a.rfc_ord = TRIM(sRfcServicio)
					AND (a.num_cta_rec IN (SELECT LPAD(TRIM(num_tarjeta),20,'0') FROM bdicheq:sc_tarjeta WHERE cuenta = TRIM(cNumeroCuenta) AND numcte = TRIM(cNumCliente))
					OR a.num_cta_rec =  TRIM(cCuentaClabe))
					AND a.cod_operacion = "30"
					AND a.nombre_arch LIKE "%S%";
					
					IF NOT refServicio IS NULL OR NOT refServicio = "" THEN
					
						IF cTipoDomiciliacion = '1' THEN
							LET sTipoNomDomi = 'Domiciliacion por tarjeta'; ---Cancelacion de domiciliaciones por tarjeta
							
							INSERT INTO bdidomi:dom_cte_cancelaciones(cuenta,num_tarjeta,cuenta_clabe,status_cancelacion,ref_leyenda,rfc_servicio,ref_servicio,folio_suc,sucursal,transaccion,monto,fecha_movimiento,tipo_movimiento,id_tipo_domi,tipo_domi,usuario_insert,fecha_insert)
							VALUES (cNumeroCuenta,LPAD(TRIM(cNumeroTarjeta),20,'0'),cCuentaClabe,'0',cRefLeyenda,sRfcServicio,refServicio,cFolioSuc,cSucursal,cTransaccion,cMonto,cFechaMov,sTipoNomMovimiento,cTipoDomiciliacion,sTipoNomDomi,cUsuarioInsert, CURRENT);
							
							UPDATE bdidomi:dom_autorizaciones SET cve_estatus = '02' WHERE cuenta = cNumeroCuenta AND num_cte = cNumCliente; --Inhabilita la cuenta para poder hacer domiciliaciones
							LET sCodigoRetorno = '00000';
							LET sCodigoDescripcion = 'Proceso Exitoso.';
							RETURN sCodigoRetorno,sCodigoDescripcion;
						ELIF (cTipoDomiciliacion = '2') THEN
							LET sTipoNomDomi = 'Domiciliacion en especifico'; --Cancelacion de domiciliaciones en especifico
							
							INSERT INTO bdidomi:dom_cte_cancelaciones(cuenta,num_tarjeta,cuenta_clabe,status_cancelacion,ref_leyenda,rfc_servicio,ref_servicio,folio_suc,sucursal,transaccion,monto,fecha_movimiento,tipo_movimiento,id_tipo_domi,tipo_domi,usuario_insert,fecha_insert)
							VALUES (cNumeroCuenta,LPAD(TRIM(cNumeroTarjeta),20,'0'),cCuentaClabe,'0',cRefLeyenda,sRfcServicio,refServicio,cFolioSuc,cSucursal,cTransaccion,cMonto,cFechaMov,sTipoNomMovimiento,cTipoDomiciliacion,sTipoNomDomi,cUsuarioInsert, CURRENT);
							LET sCodigoRetorno = '00000';
							LET sCodigoDescripcion = 'Proceso Exitoso.';
							RETURN sCodigoRetorno,sCodigoDescripcion;
						END IF;		
						LET sCodigoRetorno = '00001';
						LET sCodigoDescripcion = 'La DomiciliaciÃ³n No Se Pudo Cancelar.';
						RETURN sCodigoRetorno,sCodigoDescripcion;
					ELSE 
						LET sCodigoRetorno = '00001';
						LET sCodigoDescripcion = 'La DomiciliaciÃ³n No Se Pudo Cancelar.';
						RETURN sCodigoRetorno,sCodigoDescripcion;
					END IF;	
				END IF;
			END FOREACH;
			LET sCodigoRetorno = '00001';
			LET sCodigoDescripcion = 'La DomiciliaciÃ³n No Se Pudo Cancelar.';
			RETURN sCodigoRetorno,sCodigoDescripcion;
		ELSE
			LET sCodigoRetorno = '00005';
			LET sCodigoDescripcion = 'Cliente Inexistente.';
			RETURN sCodigoRetorno,sCodigoDescripcion;
		END IF;

END
END PROCEDURE;
CREATE PROCEDURE "informix".sp_guarda_obj_domi(
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

	DEFINE sCodigoRetorno     CHAR(5);
	DEFINE sCodigoDescripcion CHAR(100);
	DEFINE iSqlErr            INTEGER;
	DEFINE sTipoNomDomi       CHAR(50);
	DEFINE sTipoNomMovimiento CHAR(2);
	DEFINE sRfcServicio       CHAR(20);
	DEFINE cNombreArch        CHAR(20);
	DEFINE cFechaPresentacion CHAR(12);
	DEFINE cTipoReg           CHAR(2);
	DEFINE cSecuencia         CHAR(7);
	DEFINE cRef_Servicio      CHAR(50);
	DEFINE cReferencia        VARCHAR(40);
	DEFINE cDia               CHAR(2);
	DEFINE cMes               CHAR(2);
	DEFINE cAnio              CHAR(4);
	
		
		/* INICIALIZACION DE VARIABLES */
	
	LET sCodigoRetorno = '00000';
	LET sCodigoDescripcion = 'Proceso Exitoso.';
	LET sTipoNomDomi = '';
	LET sTipoNomMovimiento = '';
	LET sRfcServicio = '';
	LET cNombreArch = '';
	LET cFechaPresentacion = '';
	LET cTipoReg = '';
	LET cSecuencia = '';
	LET cRef_Servicio = '';
	LET cReferencia = '';
	LET cDia = '';
	LET cStatusCancelacion = '0';
	
	
BEGIN

	--Manejo de excepciones (errores)
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET sCodigoRetorno = iSqlErr;
			LET sCodigoDescripcion = 'ERROR NO CONTROLADO(' || iSqlErr || ')';
			
			INSERT INTO bdidomi:"informix".dom_errores(fecha_error, hora_error, cod_error, nombre_arch, sp_llamado, mensaje_error, user_insert, fecha_insert)
            VALUES(EXTEND(CURRENT::DATE, YEAR to SECOND), EXTEND(CURRENT::DATE, YEAR to SECOND)+10 UNITS HOUR+42 UNITS MINUTE+29 UNITS SECOND,sCodigoRetorno, cFolioSuc, 'sp_guarda_obj_domi' || ' | ' || cNumeroCuenta, 'OBTENER MENSAJES CODIGO DE ERROR DESCONOCIDO', 'sysdomi ', EXTEND(CURRENT::DATE, YEAR to SECOND));
			
			RETURN sCodigoRetorno,sCodigoDescripcion;
		END IF;
	END EXCEPTION; 
	
	--SET DEBUG FILE TO "/RESPALDOSNEW/depuraremesas/sp_guarda_obj_domi.out";
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	LET cDia = SUBSTR(TRIM(cFechaMov) ,0,2);
	LET cMes = SUBSTR(TRIM(cFechaMov) ,4,2);
	LET cAnio = SUBSTR(TRIM(cFechaMov) ,7,5);
	
	DROP TABLE IF EXISTS act_det_paso_arch30;
	
	SELECT mov.cuenta, mov.folio_suc, TRIM (SUBSTRING (mov.referencia FROM 13 FOR 30)) as REF, cheques.cuenta_clabe, tarjeta.num_tarjeta, mov.monto_tot
    FROM bdicheq:sc_movhis as mov
    INNER JOIN bdicheq:sc_maechq  as cheques on (cheques.cuenta = mov.cuenta)
    LEFT JOIN bdicheq:sc_tarjeta as tarjeta on (tarjeta.cuenta = mov.cuenta)
    WHERE mov.cuenta=TRIM(cNumeroCuenta)
	AND mov.folio_suc=TRIM(cFolioSuc)
	AND mov.transacc='1141' 
	AND mov.fech_oper=MDY(cMes,cDia,cAnio)
    AND monto_tot = cMonto 
	UNION
	SELECT mov.cuenta, mov.folio_suc, TRIM (SUBSTRING (mov.referencia FROM 13 FOR 30)) as REF, cheques.cuenta_clabe, tarjeta.num_tarjeta, mov.monto_tot
    FROM bdicheq:sc_movhis_old as mov
    INNER JOIN bdicheq:sc_maechq  as cheques on (cheques.cuenta = mov.cuenta)
    LEFT JOIN bdicheq:sc_tarjeta as tarjeta on (tarjeta.cuenta = mov.cuenta)
    WHERE mov.cuenta=TRIM(cNumeroCuenta)
	AND mov.folio_suc=TRIM(cFolioSuc)
	AND mov.transacc='1141' 
	AND mov.fech_oper=MDY(cMes,cDia,cAnio)
    AND monto_tot = cMonto
	INTO TEMP act_det_paso_arch30 WITH NO LOG;
	
	SELECT FIRST 1 nombre_arch,num_secuencia,fecha_presentacion,tipo_registro,user_insert,ref_servicio,ref_leyenda,rfc_ord
	INTO cNombreArch, cSecuencia,cFechaPresentacion, cTipoReg, cUsuarioInsert, cRef_Servicio,cRefLeyenda, sRfcServicio
	FROM bdidomi:dom_cce_detalle 
    WHERE folio_suc in(select folio_suc from  act_det_paso_arch30) 
    AND fecha_insert=MDY(cMes,cDia,cAnio)
    AND cod_operacion='30'
	AND nombre_arch like '%S%'
    AND cve_estatus = '01'	
	AND tipo_registro = '02'
    AND substring(ref_leyenda from 1 for 28) in (select ref from  act_det_paso_arch30)
    AND(substring (num_cta_rec from 3 for 18) in (select cuenta_clabe from  act_det_paso_arch30) 
    OR substring (num_cta_rec from 5 for 16) in (select num_tarjeta  from  act_det_paso_arch30))
    AND importe IN (select REPLACE(LPAD(REPLACE(monto_tot, '.', ''),16,0),'$','') from act_det_paso_arch30);
		
	SELECT LPAD(TRIM(cuenta_clabe),20,'0') INTO cCuentaClabe FROM bdicheq:sc_maechq 
	WHERE cuenta = TRIM(cNumeroCuenta);
	
	EXECUTE PROCEDURE bdidomi:sp_grabarreversodomi('1',cNumeroCuenta,cNumCliente,cSucursal,cNombreArch,cFechaPresentacion,cTipoReg,cSecuencia,cUsuarioInsert,DATE(cFechaInsert),'01') INTO sCodigoRetorno;
	
	IF sCodigoRetorno =  "00000" THEN
		LET sCodigoRetorno = '00000';
		LET sCodigoDescripcion = 'Proceso Exitoso.';
		LET cStatusCancelacion = '1';
		--RETURN sCodigoRetorno,sCodigoDescripcion;
	ELIF (sCodigoRetorno = "00040") THEN
		LET sCodigoRetorno = '00040';
		LET sCodigoDescripcion = 'La Informacion Ya Esta Almacenada.';
		LET cStatusCancelacion = '0';
		--RETURN sCodigoRetorno,sCodigoDescripcion;
	ELIF (sCodigoRetorno = "00050") THEN
		LET sCodigoRetorno = '00050';
		LET sCodigoDescripcion = 'No Existe Informacion Con Los Parametros Proporcionados.';
		LET cStatusCancelacion = '0';
		--RETURN sCodigoRetorno,sCodigoDescripcion;
	ELIF (sCodigoRetorno = "00060") THEN
		LET sCodigoRetorno = '00060';
		LET sCodigoDescripcion = 'No Se Puede Reversar Porque Excede Los 90 Dias Naturales.';
		LET cStatusCancelacion = '0';
		--RETURN sCodigoRetorno,sCodigoDescripcion;
	ELIF (sCodigoRetorno = "00020") THEN
		LET sCodigoRetorno = '00020';
		LET sCodigoDescripcion = 'Faltan Parametros De Entrada.';
		LET cStatusCancelacion = '0';	
	END IF;	
	
	LET sTipoNomMovimiento = 'OB';
	LET sTipoNomDomi = 'OTROS BANCOS COD_RET ' || sCodigoRetorno;
	LET cRefCliente = cRefCliente;
	
	INSERT INTO bdidomi:dom_cte_obj_domi(cuenta,num_tarjeta,cuenta_clabe,status_cancelacion,ref_leyenda,rfc_servicio,ref_servicio,folio_suc,sucursal,transaccion,monto,fecha_movimiento,tipo_movimiento,tipo_domi,usuario_insert,fecha_insert)
	VALUES (cNumeroCuenta,LPAD(TRIM(cNumeroTarjeta),20,'0'),LPAD(TRIM(cCuentaClabe),20,'0'),cStatusCancelacion,cRefLeyenda,sRfcServicio,cRef_Servicio,cFolioSuc,cSucursal,cTransaccion,cMonto,cFechaMov,sTipoNomMovimiento,sTipoNomDomi,cUsuarioInsert,CURRENT);
	
	RETURN sCodigoRetorno,sCodigoDescripcion;	
	
END
END PROCEDURE;
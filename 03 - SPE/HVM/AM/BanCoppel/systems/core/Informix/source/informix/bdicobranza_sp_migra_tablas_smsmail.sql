CREATE PROCEDURE "informix".sp_migra_tablas_smsmail()
       RETURNING CHAR(6), CHAR(80);

--DEClaracion de variables
-- execute procedure "informix".sp_migra_reporte_smsmail();
------------------------------------------------------------
DEFINE sql_err 			    INTEGER;
DEFINE isam_err 		    INTEGER;
DEFINE error_info		    CHAR(80);
DEFINE cMensaje 		    CHAR(100);
define P_MENSAJE			CHAR(80);
DEFINE cCod_ret             CHAR(6);
define v_fecha_hoy			DATE;

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
DEFINE vCount				INTEGER;
DEFINE vCount1				INTEGER;
DEFINE iCuentasProcesadas     integer; 
DEFINE iCuentasInsertadas     integer; 
DEFINE iCuentasEliminadas     integer; 
DEFINE iCuentasExcluidasXMail integer;
DEFINE iOtrasExclusiones 	  integer;
DEFINE iCuentasExcluidasXCel  INTEGER;
  

--------------------------------------------
LET Vempresa 			= '';
LET Vnum_campana 		= 0;
LET vcliente         	= '';
LET vcredito        	= '';
LET Vproducto 			= '';
LET VfechaEnvio 		= '';
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
LET vFechaCambioEstatus = '';
LET vResultadoMora		= 0;
LET vFechaApertura		= '';
LET vFechaPrimerConsumo = '';
LET vLineaCredito		= 0;
LET vTipoTransaccion	= '';
LET vMontoTransaccion	= 0;
LET vPorcentaje_uso		= 0;
LET vCorreoElec			= '';
LET vPagoReqEmail		= 0;
LET vpago_req_sms		= 0;
let vCount1 			= 0;
let iCuentasProcesadas     = 0;
let iCuentasInsertadas     = 0;
let iCuentasEliminadas     = 0; 

let iCuentasExcluidasXMail  = 0;
let iCuentasExcluidasXCel = 0;
---------------------------------------

--SET DEBUG FILE TO 'sp_migra_reporte_smsmail.out';
--TRACE ON;

      LET cCod_ret      = '000000';
	  LET sql_err       = 0;
	  LET isam_err      = 0;
	  LET error_info    = '';
	  LET cMensaje      = 'PROCESO EXITOSO';
	  LET P_MENSAJE      = 'El proceso de MIGRACION DE TABLAS SMSs MAILs se realizó correctamente.';
	  LET vproceso		= '0119';
      --LET pUsuario      = user;
	  let v_fecha_hoy = DATE(1);
 

	BEGIN

        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
	        LET P_MENSAJE = error_info;
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, P_MENSAJE, '02')RETURNING cCod_ret; 
	        LET cCod_ret = sql_err;
    		RETURN cCod_ret, P_MENSAJE;
		END EXCEPTION;
     
--------------------------------------------------------------------------
--    SELECT fecha_hoy INTO v_fecha_hoy FROM bdinteg:si_fechas;
--------------------------------------------------------------------------

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, cMensaje, '01')RETURNING cCod_ret; 


        --se obtiene la informacion
		SET ISOLATION TO dirty READ;
        SET LOCK MODE TO WAIT 3;

----------------------------------- Se obtienen DATOS del CLIENTE y SALDOS--------------------------------------------
FOREACH with hold
            SELECT empresa,num_campana,num_credito,numcte,num_producto,fecha_envio,ciudad,estado,num_celular,
				nombre1,nombre2,apell_paterno,apell_materno,mora,sdo_venc_int_mora,pago_min,pago_min_sin_vdo, 
				pago_ven,pago_req_sms,costo,resultado_entrega,pago_dia1,pago_dia2,pago_dia3,pago_dia4,pago_dia5, 
				pago_ndias,estatus_resultado,fecha_cambio_estatus,resultado_mora, fecha_apertura, 
				fecha_primer_consumo,linea_credito,tipo_transaccion,monto_transaccion,porcentaje_uso 
			INTO Vempresa,Vnum_campana,vcredito,vcliente,Vproducto,VfechaEnvio,vciudad,vestado,vt_celular,
				cNombre1,cNombre2,cApellPat,cApellMat,vMora,vsdo_venc_int_mora,vpago_min,vpago_min_sin_vdo,
				vpago_venc,vpago_req_sms,vCosto,vResultadoEntrega,vPagoDia1,vPagoDia2,vPagoDia3,vPagoDia4,vPagoDia5,
				vPagoNdias,vEstatusResultado,vFechaCambioEstatus,vResultadoMora,vFechaApertura,
				vFechaPrimerConsumo,vLineaCredito,vTipoTransaccion,vMontoTransaccion,vPorcentaje_uso
            FROM bdicobranza:cb_rep_resultado_sms
			
			--A.L.L.	
			let iCuentasProcesadas = iCuentasProcesadas + 1;
			
---------------SE INCERTAN DATOS GENERADOS----------------------------------------------------------

             BEGIN WORK;
			 INSERT INTO cb_rep_resultado_sms_hist (
                empresa,num_campana,num_credito,numcte,num_producto,fecha_envio,ciudad,estado,num_celular,
				nombre1,nombre2,apell_paterno,apell_materno,mora,sdo_venc_int_mora,pago_min,pago_min_sin_vdo, 
				pago_ven,pago_req_sms,costo,resultado_entrega,pago_dia1,pago_dia2,pago_dia3,pago_dia4,pago_dia5, 
				pago_ndias,estatus_resultado,fecha_cambio_estatus,resultado_mora, fecha_apertura, 
				fecha_primer_consumo,linea_credito,tipo_transaccion,monto_transaccion,porcentaje_uso)
			  VALUES(Vempresa,Vnum_campana,vcredito,vcliente,Vproducto,VfechaEnvio,vciudad,vestado,vt_celular,
				cNombre1,cNombre2,cApellPat,cApellMat,vMora,vsdo_venc_int_mora,vpago_min,vpago_min_sin_vdo,
				vpago_venc,vpago_req_sms,vCosto,vResultadoEntrega,vPagoDia1,vPagoDia2,vPagoDia3,vPagoDia4,vPagoDia5,
				vPagoNdias,vEstatusResultado,vFechaCambioEstatus,vResultadoMora,vFechaApertura,
				vFechaPrimerConsumo,vLineaCredito,vTipoTransaccion,vMontoTransaccion,vPorcentaje_uso);

            let iCuentasInsertadas = iCuentasInsertadas + 1;

			--A.L.L. Borramos los clientes de la tabla cb_rep_resultado_sms 	
			delete bdicobranza:cb_rep_resultado_sms where empresa = Vempresa and num_campana = Vnum_campana and num_credito = vcredito and fecha_envio = VfechaEnvio;

			let iCuentasEliminadas = iCuentasEliminadas +1;
			
			COMMIT WORK;
END FOREACH;

--Genera cifras de control
	    if iCuentasProcesadas > 0 then
	       let cMensaje = 'TOTAL cuentas PROCESADAS SMSs : ' || iCuentasProcesadas;
	       let cMensaje = trim(cMensaje) ||'    TOTAL cuentas INSERTADAS SMSs a histórica : ' || iCuentasInsertadas;
	       CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, trim(cMensaje), '02') RETURNING cCod_ret;
	       let cMensaje = 'TOTAL cuentas ELIMINADAS SMSs : ' || iCuentasEliminadas;
	       CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, trim(cMensaje), '02') RETURNING cCod_ret;
	    end if;
--Genera cifras de control
		let iCuentasProcesadas = 0;
		let iCuentasInsertadas = 0;
		let iCuentasEliminadas = 0;
--begin work;
-----------------------------------------------INSERTAR----CB_MAIL_CLIENTE_HIS------------------------------------
	FOREACH with hold
	
		select  empresa,num_campana,num_credito,numcte,num_producto,fecha_envio,ciudad,estado,correo_elec,
				nombre1,nombre2,apell_paterno,apell_materno,mora,sdo_venc_int_mora,pago_min,pago_min_sin_vdo, 
				pago_ven,pago_req_email,costo,resultado_entrega,pago_dia1,pago_dia2,pago_dia3,pago_dia4,pago_dia5, 
				pago_ndias,estatus_resultado,fecha_cambio_estatus,resultado_mora, fecha_apertura, 
				fecha_primer_consumo,linea_credito,tipo_transaccion,monto_transaccion,porcentaje_uso
		into 	Vempresa,Vnum_campana,vcredito,vcliente,Vproducto,VfechaEnvio,vciudad,vestado,vCorreoElec,
				cNombre1,cNombre2,cApellPat,cApellMat,vMora,vsdo_venc_int_mora,vpago_min,vpago_min_sin_vdo,
				vpago_venc,vPagoReqEmail,vCosto,vResultadoEntrega,vPagoDia1,vPagoDia2,vPagoDia3,vPagoDia4,vPagoDia5,
				vPagoNdias,vEstatusResultado,vFechaCambioEstatus,vResultadoMora,vFechaApertura,
				vFechaPrimerConsumo,vLineaCredito,vTipoTransaccion,vMontoTransaccion,vPorcentaje_uso
		from bdicobranza:cb_rep_resultado_mail
		
		let vCount = vCount1 +1;
		--A.L.L.	
		let iCuentasProcesadas = iCuentasProcesadas + 1;
		
        BEGIN WORK;
		insert into bdicobranza:"informix".cb_rep_resultado_mail_hist(
	        empresa,num_campana,num_credito,numcte,num_producto,fecha_envio,ciudad,estado,correo_elec,
				nombre1,nombre2,apell_paterno,apell_materno,mora,sdo_venc_int_mora,pago_min,pago_min_sin_vdo, 
				pago_ven,pago_req_email,costo,resultado_entrega,pago_dia1,pago_dia2,pago_dia3,pago_dia4,pago_dia5, 
				pago_ndias,estatus_resultado,fecha_cambio_estatus,resultado_mora, fecha_apertura, 
				fecha_primer_consumo,linea_credito,tipo_transaccion,monto_transaccion,porcentaje_uso)
		values(Vempresa,Vnum_campana,vcredito,vcliente,Vproducto,VfechaEnvio,vciudad,vestado,vCorreoElec,
				cNombre1,cNombre2,cApellPat,cApellMat,vMora,vsdo_venc_int_mora,vpago_min,vpago_min_sin_vdo,
				vpago_venc,vPagoReqEmail,vCosto,vResultadoEntrega,vPagoDia1,vPagoDia2,vPagoDia3,vPagoDia4,vPagoDia5,
				vPagoNdias,vEstatusResultado,vFechaCambioEstatus,vResultadoMora,vFechaApertura,
				vFechaPrimerConsumo,vLineaCredito,vTipoTransaccion,vMontoTransaccion,vPorcentaje_uso);

		let iCuentasInsertadas = iCuentasInsertadas + 1;
				
		--A.L.L. Borramos los clientes de la tabla cb_mail_cliente 
		delete bdicobranza:cb_rep_resultado_mail where empresa = Vempresa and num_campana = Vnum_campana and num_credito = vcredito and fecha_envio = VfechaEnvio;

		let iCuentasEliminadas = iCuentasEliminadas + 1;

        COMMIT WORK;
	end FOREACH;

	--Genera cifras de control
	    if iCuentasProcesadas > 0 then
	       let cMensaje = 'TOTAL cuentas PROCESADAS MAILs : ' || iCuentasProcesadas;
	       let cMensaje = trim(cMensaje) ||'    TOTAL cuentas INSERTADAS MAILs a histórica : ' || iCuentasInsertadas;
	       CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, trim(cMensaje), '02') RETURNING cCod_ret;
	       let cMensaje = 'TOTAL cuentas ELIMINADAS MAILs : ' || iCuentasEliminadas;
	       CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, trim(cMensaje), '02') RETURNING cCod_ret;
	    end if;
--Genera cifras de control

    UPDATE STATISTICS MEDIUM FOR TABLE bdicobranza:cb_rep_resultado_sms;
    UPDATE STATISTICS MEDIUM FOR TABLE bdicobranza:cb_rep_resultado_sms_hist;
    UPDATE STATISTICS MEDIUM FOR TABLE bdicobranza:cb_rep_resultado_mail;
    UPDATE STATISTICS MEDIUM FOR TABLE bdicobranza:cb_rep_resultado_mail_hist;
	

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, cMensaje, '03')RETURNING cCod_ret; 
	RETURN cCod_ret, P_MENSAJE;

END;
END PROCEDURE;
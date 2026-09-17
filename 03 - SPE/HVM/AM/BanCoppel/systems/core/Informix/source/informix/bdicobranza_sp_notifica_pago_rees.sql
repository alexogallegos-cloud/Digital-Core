CREATE PROCEDURE "informix".sp_notifica_pago_rees()
returning
CHAR (06),
VARCHAR(80);

------------------------------------------------------------------------------------
---- DECLARACION DE VARIABLES
DEFINE vEmpresa 				char(3);
DEFINE vNumCredito				char(20);
DEFINE vNumCte                  char(20);
DEFINE cNombre1         		char(20);
DEFINE cNombre2         		char(20);
DEFINE cCelular					char(13);
DEFINE cCorreoElec					char(100);
DEFINE vFecha 					date;
DEFINE vFechaProxima 			date;
DEFINE dFechaHoy 					date;
DEFINE vFechaCorte      		date;
DEFINE vNumProducto				char(4);
DEFINE vValor 					smallint;
DEFINE iCuentasProcesadasTotal	INTEGER;
DEFINE iCuentasExcluidasEmail	INTEGER;
DEFINE iCuentasExcluidasSms 	INTEGER;
DEFINE iCount_REST_CERO			INTEGER;
DEFINE SQL_ERR					INTEGER;
DEFINE ISAM_ERR					INTEGER;
DEFINE ERROR_INFO				VARCHAR(80);
DEFINE P_COD_RET				VARCHAR(6);
DEFINE COD_RET					VARCHAR(6);
DEFINE P_MENSAJE				VARCHAR(80);
DEFINE vproceso					CHAR (4);
DEFINE cMensaje					CHAR(500);
DEFINE cSql						CHAR(1000);
DEFINE cCampania				VARCHAR(05);
DEFINE cHora              		CHAR(08);
DEFINE sDiaCorte				SMALLINT;

DEFINE cMensajeRetorno			CHAR(80);
DEFINE dPagoMinimo				DECIMAL(18,2);
DEFINE dIntvdo					DECIMAL(18,2);
DEFINE dIntmoratorio			DECIMAL(18,2);
DEFINE dIvaintvdo				DECIMAL(18,2);
DEFINE dPagosvdos				DECIMAL(18,2);
DEFINE dIvaintmoratorio			DECIMAL(18,2);
DEFINE dIntmes					DECIMAL(18,2);
DEFINE dIvaintmes				DECIMAL(18,2);
DEFINE dIntvig					DECIMAL(18,2);
DEFINE dIvaintvig				DECIMAL(18,2);

DEFINE cFechaReporte			CHAR(08);

---INICIALIZACIONES DE VARIABLES
LET vEmpresa					= '';
LET vNumCredito					= '';
LET vNumCte						= '';
LET cNombre1            		= '';
LET cNombre2            		= '';
LET cCelular					= '';
LET cCorreoElec						= '';
LET vFecha						= '';
LET vFechaProxima				= '';
LET vFechaCorte         		= '';
LET dFechaHoy						= '';
LET vNumProducto				= '';
LET vValor						= 0;
LET iCuentasProcesadasTotal 	= 0;
LET iCuentasExcluidasEmail		= 0;
LET iCuentasExcluidasSms		= 0;
LET iCount_REST_CERO			= 0;
LET iCount_REST_CERO			= 0;
LET SQL_ERR						= 0;
LET ISAM_ERR					= 0;
LET ERROR_INFO					= '';
LET P_COD_RET					= '000000';
LET COD_RET						= '000000';
LET P_MENSAJE					= 'El proceso de la campana NOTIF_PR se realizo correctamente.';
LET vproceso					= '2017';
LET cMensaje					= '';
LET cSql						= '';
LET cCampania					= '';
LET cHora              			= '';
LET sDiaCorte					= 0;

LET cMensajeRetorno			= '';
LET dPagoMinimo				= 0;
LET dIntvdo					= 0;
LET dIntmoratorio			= 0;
LET dIvaintvdo				= 0;
LET dPagosvdos				= 0;
LET dIvaintmoratorio		= 0;
LET dIntmes					= 0;
LET dIvaintmes				= 0;
LET dIntvig					= 0;
LET dIvaintvig				= 0;

LET cFechaReporte			= '';


---------------------------------- CONTROL DE ERRORES EN BITACORA AL EJECUTAR EL PROCESO -------------------------------------------------------
BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = 'Error al ejecutar el proceso. '||vNumCredito;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '02') RETURNING COD_RET;
		RETURN P_COD_RET,P_MENSAJE;
	END EXCEPTION;

--SET DEBUG FILE TO  "/RESPALDOS/aacano/restructuras_cero/sp_notifica_pago_rees.out"; 
--TRACE ON;

 -------------------------------- CONTROL DE ERRORES EN BITACORA --------------------------------------------------------
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '01') RETURNING COD_RET;

     IF COD_RET != '000000' THEN
        LET P_COD_RET = COD_RET;
        LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     END IF;
--------------------------------- FECHA ACTUAL ---------------------------------------------------------------------------
--	SELECT fecha_hoy INTO dFechaHoy FROM bdicred:sd_fechas WHERE empresa = '001';
	
	LET dFechaHoy = today;
    SET ISOLATION TO dirty READ;
	
	IF DAY(TODAY) > 17 THEN
		LET sDiaCorte = 2;
	ELSE
		LET sDiaCorte = 17;
	END IF;

--temporal solo para pruebas
--LET sDiaCorte = 17;
--temporal solo para pruebas	

	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND 
	  INTO cHora 
	  FROM sysmaster:sysshmvals;

--temporal solo para pruebas
--LET cHora = '09:36:04';
--temporal solo para pruebas
	  
	IF SUBSTR(cHora,1,2) >= '01' AND SUBSTR(cHora,1,2) <= '06' THEN
		LET cCampania = 'EMAIL';
	ELSE
		LET cCampania = 'SMS';
	END IF;
	
---------------------------------------Correo-------------------------------------------------------------------------------------------------
--Crea tablas temporales y las alimenta con los datos correspondientes (query principal)
SELECT a.empresa, a.numcte, b.num_credito, a.num_producto, d.nombre1, d.nombre2, b.prox_fecha_pago
	FROM bdicred:sd_maecredcrd a
		INNER JOIN bdicred:sd_maecredanexocrd b ON b.empresa = a.empresa AND b.num_credito = a.num_credito and b.dia_corte = sDiaCorte
		INNER JOIN bdinteg:si_cliente d ON d.numcte = a.numcte
		WHERE a.empresa = '001'
		AND a.num_credito >= '610000000000'
		AND a.num_credito <= '619999999999'
		AND a.num_producto = '6011'
		AND status_cred in ('AA','BA','BT','VP','E1','E2','E3')
	INTO temp notificarees WITH NO LOG;

--	CREATE INDEX ind_numctocr_tmp ON notificarees(numcte,num_credito);

	UPDATE STATISTICS HIGH FOR TABLE notificarees;

-----------------------------------Asigna valores a variables y las validaciones para correo----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

DELETE FROM notificarees a WHERE a.numcte IN(SELECT b.cliente FROM bdimnsj:mnsjr_trx_batch b WHERE a.numcte = b.cliente
				  AND b.id_plantilla IN('REST_CERO','REST_CEROS') AND DATE(fecha_hora_registro) = dFechaHoy);

FOREACH WITH HOLD
	SELECT empresa, num_credito, numcte, num_producto, nombre1, nombre2, prox_fecha_pago
		INTO vEmpresa, vNumCredito, vNumCte, vNumProducto, cNombre1, cNombre2, vFechaProxima
		FROM notificarees

	LET iCuentasProcesadasTotal = iCuentasProcesadasTotal + 1;

	IF cCampania = 'EMAIL' THEN
		SELECT FIRST 1 correo_elec
			INTO cCorreoElec
			FROM  bdinteg:si_correos
			WHERE  empresa = '001'
			AND numcte = vNumCte
			AND status_correo ='A';

		IF cCorreoElec IS NULL OR cCorreoElec = '' THEN
			LET iCuentasExcluidasEmail = iCuentasExcluidasEmail + 1;
			CONTINUE FOREACH;
		ELSE
			CALL bdicred:"informix".sp_obtener_pagomin(vEmpresa,vNumCredito) RETURNING COD_RET,cMensajeRetorno,dPagoMinimo,dIntvdo,dIntmoratorio,
																				dIvaintvdo,dPagosvdos,dIvaintmoratorio,dIntmes,dIvaintmes,dIntvig,dIvaintvig;
			IF dPagoMinimo IS NULL OR dPagoMinimo = '' OR dPagoMinimo <= 0 THEN
				LET dPagoMinimo = 0;
				LET iCuentasExcluidasEmail = iCuentasExcluidasEmail + 1;
				CONTINUE FOREACH;
			END IF;
			CALL bdimnsj:"informix".sp_registra_evento(1,'PROD_EMAIL','REST_CERO',vNumcte,vNumCredito,'',2,
														trim(cNombre1),trim(cNombre2),'','','','','',
														'','','',trim(cCorreoElec),'',dPagoMinimo,0,0,0,0,vFechaProxima,'') RETURNING COD_RET;
			LET iCount_REST_CERO = iCount_REST_CERO + 1;
		END IF;
	ELSE
		SELECT FIRST 1 d.telefono
		INTO cCelular
		FROM bdinteg:"informix".si_telefonos_actual d
		WHERE d.numcte = vNumCte
		    AND d.tipo_tel = '2'
			and status_tel = 'A';

		IF cCelular IS NULL or cCelular = '' THEN
			LET iCuentasExcluidasSms = iCuentasExcluidasSms + 1;
			CONTINUE FOREACH;
		ELSE
			CALL bdicred:"informix".sp_obtener_pagomin(vEmpresa,vNumCredito) RETURNING COD_RET,cMensajeRetorno,dPagoMinimo,dIntvdo,dIntmoratorio,
																				dIvaintvdo,dPagosvdos,dIvaintmoratorio,dIntmes,dIvaintmes,dIntvig,dIvaintvig;
			IF dPagoMinimo IS NULL or dPagoMinimo = '' OR dPagoMinimo <= 0 THEN
				LET dPagoMinimo = 0;
				LET iCuentasExcluidasSms = iCuentasExcluidasSms + 1;
				CONTINUE FOREACH;
			END IF;

			CALL bdimnsj:"informix".sp_registra_evento(2,'PROD_SMS','REST_CEROS',vNumcte,vNumCredito,'',2,
														trim(cNombre1),trim(cNombre2),'','','','','',
														'','','','',trim(cCelular),dPagoMinimo,0,0,0,0,vFechaProxima,'') RETURNING COD_RET;

			LET iCount_REST_CERO = iCount_REST_CERO + 1;
		END IF;
	END IF;
END FOREACH;

DROP TABLE notificarees;

LET cFechaReporte = TO_CHAR(TODAY,'%d%m%Y');

--Genera cifras de control y reporte
	IF cCampania = 'EMAIL' THEN
       let cMensaje = 'Total cuentas procesadas campaÃ±a EMAIL: '||iCuentasProcesadasTotal;
       let cMensaje = trim(cMensaje) ||'          EMAILs enviados a campaÃ±a: ' ||iCount_REST_CERO;
	   CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001',vproceso, P_COD_RET,trim(cMensaje),'02') RETURNING COD_RET;
       let cMensaje = 'Cuentas excluidas en campaÃ±a EMAIL: ' ||iCuentasExcluidasEmail;
	   CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001',vproceso, P_COD_RET,trim(cMensaje),'02') RETURNING COD_RET;

		IF COD_RET != '000000' THEN
			let P_COD_RET = COD_RET;
			let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
			RETURN P_COD_RET,P_MENSAJE;
		END IF;
   
	  let cSql = 'echo "Total cuentas procesadas campaÃ±a EMAIL: '||iCuentasProcesadasTotal|| '" > /resplogifx/archivoscartera/notificacion_rest_email_'||cFechaReporte||'.txt';
	  system cSql;
	  let cSql = 'echo "EMAILs enviados a campaÃ±a: '||iCount_REST_CERO|| '" >> /resplogifx/archivoscartera/notificacion_rest_email_'||cFechaReporte||'.txt';
	  system cSql;
	  let cSql = 'echo "Cuentas excluidas en campaÃ±a EMAIL: '||iCuentasExcluidasEmail|| '" >> /resplogifx/archivoscartera/notificacion_rest_email_'||cFechaReporte||'.txt';
	  system cSql;
	  
	ELIF cCampania = 'SMS' THEN
       let cMensaje = 'Total cuentas procesadas campaÃ±a SMS: '||iCuentasProcesadasTotal;
       let cMensaje = trim(cMensaje) ||'          SMSs enviados a campaÃ±a: ' ||iCount_REST_CERO;
	   CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001',vproceso, P_COD_RET,trim(cMensaje),'02') RETURNING COD_RET;
	   let cMensaje = 'Cuentas excluidas en campaÃ±a SMS: ' ||iCuentasExcluidasSms;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001',vproceso, P_COD_RET,trim(cMensaje),'02') RETURNING COD_RET;

		IF COD_RET != '000000' THEN
			let P_COD_RET = COD_RET;
			let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
			RETURN P_COD_RET,P_MENSAJE;
		END IF;
	   
	  let cSql = 'echo "Total cuentas procesadas campaÃ±a SMS: '||iCuentasProcesadasTotal|| '" > /resplogifx/archivoscartera/notificacion_rest_sms_'||cFechaReporte||'.txt';
	  system cSql;
	  let cSql = 'echo "SMSs enviados a campaÃ±a: '||iCount_REST_CERO|| '" >> /resplogifx/archivoscartera/notificacion_rest_sms_'||cFechaReporte||'.txt';
	  system cSql;
	  let cSql = 'echo "Cuentas excluidas en campaÃ±a SMS: '||iCuentasExcluidasEmail|| '" >> /resplogifx/archivoscartera/notificacion_rest_sms_'||cFechaReporte||'.txt';
	  system cSql;
   END IF;

----------------------------------------------------------------------------------------------------------------------------------------

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '03') RETURNING COD_RET;

    IF COD_RET != '000000' then
        let P_COD_RET = COD_RET;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
    END IF;

    RETURN P_COD_RET,P_MENSAJE;

END;
END PROCEDURE;
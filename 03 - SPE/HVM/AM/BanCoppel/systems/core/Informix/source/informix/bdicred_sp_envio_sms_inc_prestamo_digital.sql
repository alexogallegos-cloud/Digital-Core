CREATE PROCEDURE "informix".sp_envio_sms_inc_prestamo_digital(p_empresa CHAR(3))
RETURNING CHAR(6); 


-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************

DEFINE cCodRet					    CHAR(6);
DEFINE cCodRetSms				    CHAR(5);
DEFINE sErrorCont					SMALLINT;
DEFINE iSqlErr						INTEGER;
DEFINE dFechaInteg				    DATE;
DEFINE dFechaSistema				DATE;
DEFINE cNumCte					    CHAR(20);
DEFINE cNumCredito					CHAR(20);
DEFINE cTelefono					CHAR(20);
DEFINE cRespIncremento		        CHAR(9);
DEFINE cCodRetBit					CHAR(6);
DEFINE cErrorInfo                   CHAR(80);
DEFINE iSamErr						INTEGER;
DEFINE cProceso 					CHAR(4);
DEFINE cMensajeRet					CHAR(125);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************


LET cCodRet					    = "000000";
LET cCodRetSms			        = "";
LET sErrorCont 					= 0;
LET iSqlErr						= 0;
LET dFechaInteg					= DATE(1);
LET dFechaSistema               = DATE(1);  
LET cNumCte					    = '';
LET cNumCredito					= '';
LET cTelefono					= '';
LET cRespIncremento				= '';
LET cCodRetBit					= '';	
LET cErrorInfo                  = '';
LET iSamErr 					= 0;
LET cProceso 					= '0117';
LET cMensajeRet 				= '';



-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************


BEGIN
	ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
	   IF iSqlErr != 0 THEN
		  LET cCodRet=iSqlErr;
		  LET cMensajeRet = cErrorInfo||' '||iSamErr;
		  EXECUTE PROCEDURE bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, cCodRet, cMensajeRet, '02') INTO cCodRetBit;
		  RETURN cCodRet;
	   END IF;
	END EXCEPTION;
	
 	 --SET DEBUG FILE TO "/informix/sp_envio_sms_inc_prestamo_digital.out";
	 --TRACE ON; 
	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	

	EXECUTE PROCEDURE bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, cCodRet, "INICIA EL PROCESO DE ENVIO SMS PARA INCREMENTO EN EL PRESTAMO DIGITAL", '02') INTO cCodRetBit;

	--Obtenemos el dÃ­a actual, el primero y Ãºltimo dÃ­a del mes
	SELECT fecha_hoy INTO dFechaInteg FROM bdicred:"informix".sd_fechas WHERE empresa = p_empresa;
	LET dFechaSistema= CURRENT::DATE;
	
	IF  dFechaInteg = dFechaSistema THEN
			
        FOREACH	WITH HOLD
			-- Validamos prÃ©stamos digitales que esten dentro del parÃ¡metro del mob	
            SELECT {+INDEX(bdicred:"informix".sd_incrementos_prestamos_digitales idx_incrmto_pd2)} 
			numcte, num_credito, telefono, respuesta_incremento
			INTO cNumCte, cNumCredito, cTelefono, cRespIncremento	
            FROM bdicred:"informix".sd_incrementos_prestamos_digitales 
            WHERE estatus_sms = 'Pendiente'   
								
				IF cTelefono IS NOT NULL OR cTelefono != '' THEN					
					
					IF UPPER(TRIM(cRespIncremento)) = "ACEPTA" THEN
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','SMS_97000','CONF_INC_SMS',cNumCte,'','','2','','','','','','','','','','','',cTelefono,0,0,0,0,0,'','') INTO cCodRetSms;
						--PLANTILLA: El incremento de tu linea ha sido aplicado exitosamente, puedes disponer a traves de nuestros canales mandando un SMS al 97000, ATM, App BanCoppel y WhatsApp.
						IF (cCodRetSms = '00000') THEN
							UPDATE bdicred:"informix".sd_incrementos_prestamos_digitales
							SET estatus_sms = 'Enviado', cod_ret_sms = cCodRetSms WHERE numcte = cNumCte AND num_credito = cNumCredito; 
						ELSE
							LET sErrorCont = sErrorCont + 1;
							UPDATE bdicred:"informix".sd_incrementos_prestamos_digitales
							SET cod_ret_sms = cCodRetSms WHERE numcte = cNumCte AND num_credito = cNumCredito; 
						END IF;
					END IF;
					
					IF UPPER(TRIM(cRespIncremento)) = "NO ACEPTA" THEN
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','SMS_97000','OFER_INC_SMS',cNumCte,'','','2','','','','','','','','','','','',cTelefono,0,0,0,0,0,'','') INTO cCodRetSms; 
						--PLANTILLA: En BanCoppel queremos que sigas cumpliendo tus metas con tu Prestamo Digital, por eso tenemos un incremento para ti. Responde S Aceptar N Cancelar	
						IF (cCodRetSms = '00000') THEN
							UPDATE bdicred:"informix".sd_incrementos_prestamos_digitales
							SET estatus_sms = 'Enviado', cod_ret_sms = cCodRetSms WHERE numcte = cNumCte AND num_credito = cNumCredito; 
						ELSE
							LET sErrorCont = sErrorCont + 1;
							UPDATE bdicred:"informix".sd_incrementos_prestamos_digitales
							SET cod_ret_sms = cCodRetSms WHERE numcte = cNumCte AND num_credito = cNumCredito; 
						END IF;
					END IF;
					
					IF UPPER(TRIM(cRespIncremento)) = "PENDIENTE" THEN
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','SMS_97000','OFER_INC_SMS',cNumCte,'','','2','','','','','','','','','','','',cTelefono,0,0,0,0,0,'','') INTO cCodRetSms;	
						--PLANTILLA: En BanCoppel queremos que sigas cumpliendo tus metas con tu Prestamo Digital, por eso tenemos un incremento para ti. Responde S Aceptar N Cancelar	
						IF (cCodRetSms = '00000') THEN
							UPDATE bdicred:"informix".sd_incrementos_prestamos_digitales
							SET estatus_sms = 'Enviado', cod_ret_sms = cCodRetSms WHERE numcte = cNumCte AND num_credito = cNumCredito; 
						ELSE
							LET sErrorCont = sErrorCont + 1;
							UPDATE bdicred:"informix".sd_incrementos_prestamos_digitales
							SET cod_ret_sms = cCodRetSms WHERE numcte = cNumCte AND num_credito = cNumCredito; 
						END IF;
					END IF;
					
				END IF;	

		END FOREACH;
		
		IF sErrorCont > 0 THEN
			LET cCodRet = '000002';
		ELSE
			LET cCodRet = '000000';
		END IF;
		
		
		EXECUTE PROCEDURE bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, cCodRet, "TERMINA EL PROCESO DE ENVIO DE SMS PARA INCREMENTO EN EL PRESTAMO DIGITAL", '02') INTO cCodRetBit;
	ELSE
		LET cCodRet= '000001';
		EXECUTE PROCEDURE bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, cCodRet, "LA FECHA ACTUAL NO CORRESPONDE CON LA FECHA EN EL SERVIDOR CENTRAL - SP_ENVIO_SMS_INC_PRESTAMO_DIGITAL", '02') INTO cCodRetBit;
	END IF;
	
END
RETURN cCodRet;

END PROCEDURE	

DOCUMENT
'REALIZA EL ENVIO DE NOTIFICACIONES POR SMS DEL AUMENTO DE CREDITO DE CLIENTES DE PRESTAMO DIGITAL, PRODUCTO 6800 - RQM 10 1543',
'AUTOR : ALAN CASTRO PAREDES',
'FECHA : ENE/2024',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_actualiza_linea_pdigital(pNumCredito CHAR(20), pRespuestaIncremento CHAR(9), pCanalRespuesta CHAR(10), pIdAtm CHAR(14), pNumCel CHAR(10))
RETURNING CHAR(6) AS cCodRet;

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
NOMBRE:		Carlos Abraham Velasco NuÃ±ez
Num EMPLEADO:	97267953
PROYECTO:		INCREMENTO EN LA LINEA DE CREDITO PRESTAMO DIGITAL
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

-- Definicion de Variables --

DEFINE v_Suc CHAR(4);
DEFINE sql_err INTEGER;
DEFINE cCodRet CHAR(6); -- Variable de retorno
DEFINE vOferta CHAR(8);
DEFINE v_Divisa	CHAR(2);
DEFINE pEmpresa CHAR(3);
DEFINE cCod_ret CHAR(6);
DEFINE cProceso CHAR(4);
DEFINE vNumcte CHAR(20);
DEFINE isam_err	INTEGER;
DEFINE error_info CHAR(80);
DEFINE cCod_retBit CHAR(6);
DEFINE cMensajeRet CHAR(125);
DEFINE vClienteAcepta CHAR(100);
DEFINE dLineaDisp DECIMAL(18,2);
DEFINE vClienteNoAcepta CHAR(100);
DEFINE dLineaActual DECIMAL(18,2);
DEFINE vFrecRecordatorio CHAR(100);
DEFINE dLineaAnterior DECIMAL(18,2);

-- Asignacion de Variables -- 

LET v_Suc = '';
LET sql_err = 0;
LET cCodRet = '000000';
LET vOferta = '';
LET isam_err = 0;
LET vNumcte = '';
LET v_Divisa = '';
LET error_info = "";
LET pEmpresa = '001';
LET cMensajeRet = '';
LET dLineaDisp = 0.00;
LET cProceso = '0117';
LET cCod_ret = '000000';
LET vClienteAcepta = '';
LET dLineaActual = 0.00;
LET dLineaAnterior = 0.00;
LET vClienteNoAcepta = '';
LET cCod_retBit = '000000';
LET vFrecRecordatorio = '';

BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCodRet = sql_err;
        LET cMensajeRet = error_info||' '||isam_err;		

        EXECUTE PROCEDURE bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, cMensajeRet, '02') INTO cCod_ret;
        RETURN cCodRet;
    END EXCEPTION;

	-- SET DEBUG FILE TO "/informix/CarlosV/incremento.out";
	-- TRACE ON;

	SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;

	-- Parametros que se utilizaran para actualizar la tabla bitacora incrementos mas adelante --
	SELECT valor INTO vClienteAcepta FROM bdicred:"informix".sd_param WHERE cod_param = '204';
	SELECT valor INTO vFrecRecordatorio FROM bdicred:"informix".sd_param WHERE cod_param = '203';
	SELECT valor INTO vClienteNoAcepta 	FROM bdicred:"informix".sd_param WHERE cod_param = '205';

	-- ValidaciÃ³n del canal de respuesta, este parametro es el mas importante en el proceso. --
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	IF pCanalRespuesta IS NULL OR pCanalRespuesta = '' THEN
		LET cCodRet = '000001';
		
		RETURN cCodRet;
	END IF;
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------
																		-- CANAL DE RESPUESTA SMS --
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	-- Validar si pCanalRespuesta es dIFerente de nulo o vacÃ­o, validar que valor cONtiene: --
	-- Si la respuesta viene por el canal SMS, validar que pRespuestaIncremento y pNumCel sean dIFerente de nulo o vacÃ­o, de ser NULL o '' caso se retorna el codigo '000001' --

	IF pCanalRespuesta = '1' THEN

		IF pRespuestaIncremento IS NULL OR pRespuestaIncremento = '' OR pNumCel IS NULL OR pNumCel = '' THEN

			LET cCodRet = '000001';

			RETURN cCodRet;
		END IF;

		IF pRespuestaIncremento = 'S' THEN
			LET pRespuestaIncremento = 'Acepta';
		END IF;

		IF pRespuestaIncremento = 'N' THEN
			LET pRespuestaIncremento = 'No Acepta';
		END IF;

		SELECT numcte INTO vNumcte
		FROM bdinteg:"informix".si_telefonos_actual
		WHERE telefono = pNumCel
		AND tipo_tel = 2
		AND status_tel = 'A';		

		SELECT num_credito INTO pNumCredito
		FROM bdicred:"informix".sd_incrementos_prestamos_digitales
		WHERE numcte = vNumcte
		AND secuencia = (SELECT MAX(secuencia) AS Secuencia_maxima
						 FROM bdicred:"informix".sd_incrementos_prestamos_digitales
						 WHERE numcte = vNumcte);

		IF pCanalRespuesta = '1' THEN
			LET pCanalRespuesta = 'SMS';
		END IF;
	END IF;

	------------------------------------------------------------------------------------------------------------------------------------------------------------------------																		-- CANAL DE RESPUESTA APP --
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	/* Validar si pCanalRespuesta es igual a 'APP', validar que pNumCredito y pRespuestaIncremento no venga vacio o nulo, de ser el caso se retorna el codigo '000001' */

	IF pCanalRespuesta = 'APP' THEN

		IF pNumCredito IS NULL OR pNumCredito = '' OR pRespuestaIncremento IS NULL OR pRespuestaIncremento = '' THEN

			LET cCodRet = '000001';

			RETURN cCodRet;
		END IF;
	END IF;

	------------------------------------------------------------------------------------------------------------------------------------------------------------------------
																		-- CANAL DE RESPUESTA ATM --
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------	

	/* Se valida el parametro pIdAtm, en el caso que pCanalRespuesta sea igual a 'ATM' validar que pIdAtm no venga vacio o nulo, de ser el caso se debera retornar el codigo '000001' */
	IF  pCanalRespuesta = 'ATM' THEN

		IF pNumCredito IS NULL OR pNumCredito = '' OR pIdAtm IS NULL OR pIdAtm = '' THEN

			LET cCodRet = '000001';

			RETURN cCodRet;
		END IF;
	END IF;

	--------------------------------------------------------------------------------------------------------------------------------------------------------------
	/* ACTUALIZAR LOS MONTOS DE LINEA DE PRESTAMO UNA VEZ QUE EL CLIENTE ACEPTE LA OFERTA DE INCREMENTO DE LINEA POR CUALQUIERA DE LOS CANALES (App, ATM, SMS). */
	--------------------------------------------------------------------------------------------------------------------------------------------------------------

	/* Se valida el valor del parametro pRespuestaIncremento, Si es igual a 'Acepta', entONces se debe validar que la oferta del credito este Activa en la tabla
	   bitacora de incrementos en el campo 'oferta_incremento_linea' */

	SELECT oferta_incremento_linea INTO vOferta
	FROM bdicred:"informix".sd_incrementos_prestamos_digitales
	WHERE num_credito = pNumCredito
	AND secuencia = (SELECT MAX(secuencia) AS Secuencia_maxima
					 FROM bdicred:"informix".sd_incrementos_prestamos_digitales
					 WHERE num_credito = pNumCredito);

	IF vOferta IS NULL OR vOferta = '' OR vOferta = 'N/A' THEN

		LET cCodRet = '000004';

		RETURN cCodRet;
	END IF;

	IF UPPER(pRespuestaIncremento) = 'ACEPTA' AND UPPER(vOferta) = 'ACTIVA' THEN
	/*
	Para actualizar la tabla sd_linea_prestamo es necesario consultar primero la tabla bitacora de incrementos(sd_incrementos_prestamos_digitales), obtener el campo
	'linea_prestamo_actual' y 'linea_prestamo_anterior' (Se deben guardar en variables dLineaActual y dLineaAnterior ), filtrando por numero de credito y maxima secuencia
	*/
		SELECT
		linea_prestamo_actual,
		linea_prestamo_anterior
		INTO dLineaActual, dLineaAnterior
		FROM bdicred:"informix".sd_incrementos_prestamos_digitales
		WHERE num_credito = pNumCredito
		AND secuencia = (SELECT
						 MAX(secuencia) AS Secuencia_maxima
						 FROM bdicred:"informix".sd_incrementos_prestamos_digitales
						 WHERE num_credito = pNumCredito);

		LET dLineaDisp = (dLineaActual - dLineaAnterior);

	/* Una vez obtenida la linea nueva y anterior se procede a actualizar la tabla (sd_linea_prestamo) en los campos:
	   Para actualizar esta tabla se debera filtrar por numero de credito. */
		UPDATE bdicred:"informix".sd_linea_prestamo
		SET monto_linea = dLineaActual,
		 	linea_disponible = (SELECT linea_disponible
								FROM bdicred:"informix".sd_linea_prestamo
								WHERE num_credito = pNumCredito) + dLineaDisp,
		 	acepto_incremento = pRespuestaIncremento,
		 	fecha_ult_mod = CURRENT
		WHERE num_credito = pNumCredito;

	--	Para actualizar esta tabla se debera filtrar por numero de credito y MAXima secuencia.
		UPDATE bdicred:"informix".sd_incrementos_prestamos_digitales
		SET numero_incrementos = (SELECT numero_incrementos + 1
								  FROM bdicred:"informix".sd_incrementos_prestamos_digitales
								  WHERE num_credito = pNumCredito
								  AND secuencia = (SELECT
												   MAX(secuencia) AS Secuencia_maxima
												   FROM bdicred:"informix".sd_incrementos_prestamos_digitales
												   WHERE num_credito = pNumCredito)),
			fecha_incremento = CURRENT,
		 	canal_notificacion_invitacion = pCanalRespuesta,
		 	id_atm = pIdAtm,
		 	respuesta_incremento = pRespuestaIncremento,
		 	fecha_autorizo_o_rechazo = CURRENT,
		 	oferta_incremento_linea = 'Inactiva',
		 	observacion_oferta = vClienteAcepta,
			fecha_prox_recordatorio = NULL
		WHERE num_credito = pNumCredito
		AND secuencia = (SELECT
						 MAX(secuencia) AS Secuencia_maxima
						 FROM bdicred:"informix".sd_incrementos_prestamos_digitales
						 WHERE num_credito = pNumCredito);

		--El incremento de tu linea ha sido aplicado exitosamente, puedes disponer a traves de nuestros canales mandando un SMS al 97000, ATM, App BanCoppel y WhatsApp.
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','SMS_97000','CONF_INC_SMS',vNumcte,'','','1','','','','','','','','','','','',pNumCel,0,0,0,0,0,'','')
		INTO cCod_ret;

		SELECT sucursal, divisa
		INTO v_Suc, v_Divisa
		FROM bdicred:"informix".sd_maecredcrd
		WHERE num_credito = pNumCredito;

		EXECUTE PROCEDURE bdicred:"informix".genmovcrd(pEmpresa, pNumCredito, '6800', 1, '008', current, dLineaActual - dLineaAnterior, 'Inc LineaCredito', v_Suc,
													   v_Divisa, '6696', 'INCREMENTO DE LINEA PRESTAMO DIGITAL', '')
		INTO cCod_ret, cMensajeRet;

		LET cCodRet = '000000';

		RETURN cCodRet;
	ELSE
		IF UPPER(pRespuestaIncremento) = 'ACEPTA' AND UPPER(vOferta) = 'INACTIVA' THEN

			-- Â¡Gracias en breve recibiras mas ofertas y promociones, esperamos poder ayudarte en otro momento a seguir cumpliendo tus metas con Prestamo Digital!
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','SMS_97000','RECH_INC_SMS',vNumcte,'','','1','','','','','','','','','','','',pNumCel,0,0,0,0,0,'','')
			INTO cCod_ret;

			LET cCodRet = '000003';

			RETURN cCodRet;
		END IF;
	END IF;

	--	Si es igual a 'No Acepta', se valida en la tabla bitacora de incrementos en el campo 'oferta_incremento_linea' que la oferta del credito este 'Activa'

	--	si esta activa entONces se procede a actualizar la informaciÃ³n de las siguientes tablas: --

	IF UPPER(pRespuestaIncremento) = 'NO ACEPTA' AND UPPER(vOferta) = 'ACTIVA' THEN

	--	Para actualizar esta tabla se debera filtrar por numero de credito y MAXima secuencia.
	    UPDATE bdicred:"informix".sd_incrementos_prestamos_digitales
	    SET canal_notificacion_invitacion = pCanalRespuesta,
		    id_atm = pIdAtm,
		    respuesta_incremento = pRespuestaIncremento,
		    fecha_autorizo_o_rechazo = CURRENT,
		    observacion_oferta = vClienteNoAcepta,
		    frec_recordatorio_oferta = vFrecRecordatorio,
		    fecha_prox_recordatorio = CURRENT + vFrecRecordatorio units DAY
	    WHERE num_credito = pNumCredito
	    AND secuencia = (SELECT
					     MAX(secuencia) AS Secuencia_maxima
					     FROM bdicred:"informix".sd_incrementos_prestamos_digitales
					     WHERE num_credito = pNumCredito);

	--	Para actualizar esta tabla se debera filtrar por numero de credito.
	    UPDATE bdicred:"informix".sd_linea_prestamo
	    SET acepto_incremento = pRespuestaIncremento
	    WHERE num_credito = pNumCredito;

		-- Â¡Gracias en breve recibiras mas ofertas y promociones, esperamos poder ayudarte en otro momento a seguir cumpliendo tus metas con Prestamo Digital!
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','SMS_97000','RECH_INC_SMS',vNumcte,'','','1','','','','','','','','','','','',pNumCel,0,0,0,0,0,'','')
		INTO cCod_ret;

		LET cCodRet = '000002';

		RETURN cCodRet;
	ELSE
		IF UPPER(pRespuestaIncremento) = 'NO ACEPTA' AND UPPER(vOferta) = 'INACTIVA' THEN

			LET cCodRet = '000003';

			RETURN cCodRet;
		END IF;
	END IF;
END
	RETURN cCodRet;
END PROCEDURE;
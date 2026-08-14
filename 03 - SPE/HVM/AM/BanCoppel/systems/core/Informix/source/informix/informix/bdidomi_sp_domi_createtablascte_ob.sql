CREATE PROCEDURE "informix".sp_domi_createtablascte_ob(pFolio CHAR(20),
	pCliente CHAR(20), pUser CHAR(8), pFechaProxPago DATE, pTipoDomi CHAR(2)
)
	RETURNING CHAR(5) AS cCodret

-- DECLARACION DE VARIABLES.
DEFINE iSqlerr       				INTEGER;
DEFINE cCodret    					CHAR(5);
DEFINE cCodRet3    					CHAR(5);
DEFINE cInTransaction	 			CHAR(1);
DEFINE cNombre_arch_manual 			CHAR(20);
DEFINE cTipoRegistro  				CHAR(1);
DEFINE cConsecutivo  				CHAR(6);
DEFINE dFecha_envio  				DATE;
DEFINE cFecha_cargo  				CHAR(8);
DEFINE cFecha_abono  				CHAR(8);
DEFINE cTipoCtaCargo 				CHAR(2);
DEFINE cCveBancoCargo 				CHAR(3);
DEFINE cCtaCargo 					CHAR(20);
DEFINE cRfcCargo 					CHAR(13);
DEFINE cNombreCargo 				CHAR(50);
DEFINE cCtaAbono 					CHAR(20);
DEFINE cImpOperacion 				CHAR(18);
DEFINE cImpIva 						CHAR(15);
DEFINE cRefNumerica 				CHAR(7);
DEFINE cRefLeyenda 					CHAR(40);
DEFINE cRefServicio 				CHAR(40);
DEFINE cRefTitularServicio 			CHAR(40);
DEFINE cAccion						CHAR(1);
DEFINE cReintentarCta 				CHAR(1);
DEFINE cEstatus						CHAR(2);
DEFINE cCausaRechazo 				CHAR(50);
DEFINE cComisionCobrada		 		CHAR(16);
DEFINE cIvaCobrado					CHAR(16);
DEFINE cUserInsert	 				CHAR(8);
DEFINE dFechaInsert	 				DATE;
DEFINE cTipoCtaAbono 				CHAR(2);
DEFINE dFecha_pago   				DATE;
DEFINE dFecha_prox_pago 			DATE;
DEFINE dFecha_inicio 				CHAR(8);
DEFINE dFecha_fin    				CHAR(8);
DEFINE cCodret2						CHAR(5);
DEFINE cMensajeRespuesta 			CHAR(110);
DEFINE cTipoDomi		 			CHAR(2);
DEFINE cTipoPago		 			CHAR(1);
DEFINE cNumeroCredito			 	CHAR(20);
DEFINE cMonto			 			DECIMAL(18,2);
DEFINE cFolioActivacion				CHAR(20);

DEFINE cNombreArchivoCce 			CHAR(20);
DEFINE cFechaPresentacionCCe 		CHAR(8);
DEFINE cTipoRegistroCce	 			CHAR(20);
DEFINE cNumeroSecuenciaCce 			CHAR(7);

--VALIDACION FECHA OTROS BANCOS
DEFINE dFechaProceso 				DATE;
DEFINE dFechaLimitesCargo			CHAR(8);

-- VALORES INICIALES.
LET iSqlerr    				=  0;
LET cCodret   				= '00000';
LET cCodret2				= '';
LET cMensajeRespuesta		= '';
LET cInTransaction      	= 'N';
LET cFechaPresentacionCce 	= '';
LET cFolioActivacion		= '';
LET dFecha_envio 			= '';

LET cConsecutivo  		    = '000001';

--*********************************************************************************************
    --SET DEBUG FILE TO "/home/sysdomi/createtablascte_ob.out";
    --TRACE ON;
--*********************************************************************************************

BEGIN
	--Manejo de excepciones (errores)
	ON EXCEPTION SET iSqlerr
		IF iSqlerr <> 0 then
			IF cInTransaction = 'S' THEN
				ROLLBACK WORK;
			END IF;

			LET cCodret = iSqlerr;

			-- Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
			INSERT INTO bdidomi:"informix".dom_errores(Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_createtablascte_ob', TRIM(pFolio), pUser, CURRENT);

			RETURN cCodret;
		END IF;
	END EXCEPTION;

	-- Valida parametros de entrada
	IF NVL(pFolio,'') = '' OR NVL(pCliente,'') = '' OR NVL(pUser,'') = '' OR NVL(pFechaProxPago, '') = '' THEN
		LET cCodret = '99958'; --Problema con los parametros

		--Obtenemos los datos del error ocurrido.
		EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;

		--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
		INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
		VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_createtablascte_ob', TRIM(pFolio) || '-' || TRIM(cMensajeRespuesta), pUser, CURRENT);

		RETURN cCodret;
	END IF;

	-- Validamos si el cliente existe.
	IF NOT EXISTS(SELECT 1 FROM bdinteg:"informix".si_cliente WHERE numcte = pCliente) THEN
		LET cCodret = '99950'; --Cliente no existe.

		--Obtenemos los datos del error ocurrido.
		EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;

		--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
		INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
		VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_createtablascte_ob', TRIM(pFolio) || '-' || TRIM(cMensajeRespuesta), pUser, CURRENT);

		RETURN cCodret;
	END IF;
 
 	SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;

	-- Verificamos que se haya obtenido informacion adicional.
	IF EXISTS
		(SELECT 1 FROM bdidomi:"informix".dom_archivomanual a
		INNER JOIN bdidomi:"informix".dom_fecha_pago b
		ON a.folio_activacion = b.folio_activacion
		WHERE a.folio_activacion = pFolio
		AND a.estatus = 'EP')
	THEN

		SELECT nombre_arch, a.fecha_envio, a.tipo_registro, a.fecha_cargo, a.fecha_abono,
		a.tipo_cta_cargo, a.cve_banco_cargo, a.cuenta_cargo, a.rfc_cargo, a.nombre_cargo,
		a.cuenta_abono, a.imp_iva, a.ref_numerica, a.ref_leyenda,a.ref_servicio,
		a.ref_titular_serv, a.accion, a.reintentar_cuenta,a.estatus, a.causa_rechazo,
		a.nombre_arch_cce, a.tipo_registro_cce,a.numero_secuencia_cce, a.comision_cobrada,
		a.iva_cobrado, a.tipo_cta_abono,b.fecha_pago, b.fecha_prox_pago,
		TO_CHAR(b.fecha_inicio,'%Y%m%d') , TO_CHAR(b.fecha_fin,'%Y%m%d'), c.cve_domiciliar_tc,
		a.tipo_domi, c.cuenta, a.imp_operacion, d.monto_proximo_pago
		INTO  cNombre_arch_manual, dFecha_envio, cTipoRegistro, cFecha_cargo, cFecha_abono,
		cTipoCtaCargo, cCveBancoCargo, cCtaCargo, cRfcCargo, cNombreCargo, cCtaAbono, cImpIva,
		cRefNumerica, cRefLeyenda, cRefServicio, cRefTitularServicio, cAccion, cReintentarCta,
		cEstatus, cCausaRechazo, cNombreArchivoCce, cTipoRegistroCce, cNumeroSecuenciaCce,
		cComisionCobrada, cIvaCobrado, cTipoCtaAbono, dFecha_pago, dFecha_prox_pago, dFecha_inicio,
		dFecha_fin, cTipoPago, cTipoDomi, cNumeroCredito, cImpOperacion, cMonto
		FROM bdidomi:"informix".dom_archivomanual a
		INNER JOIN bdidomi:"informix".dom_fecha_pago b ON a.folio_activacion = b.folio_activacion
		INNER JOIN bdidomi:"informix".dom_autorizaciones c ON a.folio_activacion = c.folio_activacion
		INNER JOIN bdidomi:"informix".dom_pago d ON a.folio_activacion = d.folio_activacion
		WHERE a.folio_activacion = pFolio
		AND a.estatus = 'EP'
		AND a.tipo_domi = '02';

		LET cNombreCargo = REPLACE(REPLACE(cNombreCargo, 'ï¿½', '#'), 'ï¿½', '#');
		LET cRefTitularServicio = REPLACE(REPLACE(cRefTitularServicio, 'ï¿½', '#'), 'ï¿½', '#');

		LET dFechaLimitesCargo = dFecha_inicio ;
		--TO_CHAR(dFecha_inicio,'%y/%m/%d')
		--TO_DATE(dtFecha_Respuesta,'%d/%m/%Y')

        LET cImpOperacion = LPAD(TRIM((cMonto*100)::INTEGER::CHAR(15)),15,'0');

		LET dFechaProceso = dFecha_envio ;

		-- Validando el folio_suc para ptros bancos ya que este campo se llena cuando se hace la ejecucion de pago
		LET cFolioActivacion = NULL;

		IF NOT EXISTS
			(SELECT 1 FROM bdidomi:"informix".dom_cte_archivos
			 WHERE nombre_arch = cNombre_arch_manual
			 AND fecha_envio = dFechaProceso)
		THEN

			IF EXISTS (
				SELECT consecutivo FROM bdidomi:"informix".dom_cte_detalle
				WHERE fecha_envio = dFecha_prox_pago AND nombre_arch = cNombre_arch_manual
			) THEN
				--Obtenemos el valor del ultimo consecutivo de nombre de archivo y lo incrementamos en 1.
				SELECT LPAD(TO_CHAR(MAX(consecutivo::INTEGER)+1),6,'0')
				INTO cConsecutivo
				FROM bdidomi:"informix".dom_cte_detalle
				WHERE fecha_envio = dFecha_prox_pago AND nombre_arch = cNombre_arch_manual;

			END IF;

			BEGIN WORK;
				LET cInTransaction = 'S';

				-- insertar tablas cte
				INSERT INTO bdidomi:"informix".dom_cte_archivos(nombre_arch,fecha_envio,num_cte,fecha_carga,cve_status,user_insert,fecha_insert)
				VALUES(cNombre_arch_manual, EXTEND(MDY(MONTH(dFecha_envio), DAY(dFecha_envio), YEAR(dFecha_envio)), YEAR TO SECOND),TRIM(pCliente), EXTEND(MDY(MONTH(dFecha_envio), DAY(dFecha_envio), YEAR(dFecha_envio)), YEAR TO SECOND),'01',pUser, today);

				INSERT INTO bdidomi:"informix".dom_cte_encabezado(nombre_arch,fecha_envio,tipo_registro,num_cte,cuenta_abono,
				num_operaciones,fecha_inicial,fecha_final,user_insert,fecha_insert)
				VALUES(cNombre_arch_manual, EXTEND(MDY(MONTH(dFecha_envio), DAY(dFecha_envio), YEAR(dFecha_envio)), YEAR TO SECOND),'E',LPAD(TRIM(pCliente),20,'0'), LPAD('',20,'0'),LPAD('1',8,'0'),dFechaLimitesCargo, dFechaLimitesCargo,pUser,today);

				INSERT INTO bdidomi:"informix".dom_cte_detalle(nombre_arch, fecha_envio, tipo_registro, consecutivo, fecha_cargo,
					fecha_abono, tipo_cta_cargo, cve_banco_cargo, cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion,
					imp_iva, ref_numerica, ref_leyenda, ref_servicio, ref_titular_serv, accion, reintentar_cuenta, estatus,
					causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada,
					iva_cobrado, user_insert, fecha_insert, tipo_cta_abono, folio_suc)
				VALUES(cNombre_arch_manual, EXTEND(MDY(MONTH(dFecha_envio), DAY(dFecha_envio), YEAR(dFecha_envio)), YEAR TO SECOND),
					cTipoRegistro, cConsecutivo, cFecha_cargo, cFecha_abono, cTipoCtaCargo, cCveBancoCargo, cCtaCargo, cRfcCargo,
					cNombreCargo, cCtaAbono, cImpOperacion, cImpIva, cRefNumerica, cRefLeyenda, cRefServicio, cRefTitularServicio,
					cAccion, cReintentarCta, cEstatus, cCausaRechazo, cNombreArchivoCce, cFechaPresentacionCce, cTipoRegistroCce,
					cNumeroSecuenciaCce, cComisionCobrada, cIvaCobrado, pUser, today, cTipoCtaAbono, cFolioActivacion);

				INSERT INTO bdidomi:"informix".dom_cte_sumario(nombre_arch,fecha_envio,tipo_registro,num_operaciones,
				imp_operaciones,num_oper_pend,imp_oper_pend,num_oper_apli,imp_oper_apli,num_oper_rech,imp_oper_rech,user_insert,
				fecha_insert)
				VALUES(cNombre_arch_manual, EXTEND(MDY(MONTH(dFecha_envio), DAY(dFecha_envio), YEAR(dFecha_envio)), YEAR TO SECOND),'S', LPAD('1',8,'0'), LPAD(TRIM(cImpOperacion),18,'0'),LPAD('',8,'0'),LPAD('',18,'0'), LPAD('',8,'0'), LPAD('',18,'0'),LPAD('',8,'0'),LPAD('',18,'0'), pUser, today);
		   	COMMIT WORK;

			LET cInTransaction = 'N';

		--Verificar que no exista registro con misma ctaCargo, ctaAbono y fecha de proximo pago.
		ELIF NOT EXISTS
			(SELECT 1 FROM bdidomi:"informix".dom_cte_detalle
			 WHERE cuenta_cargo = cCtaCargo
			 AND cuenta_abono = cCtaAbono
			 AND fecha_envio = dFechaProceso)
		THEN

			BEGIN WORK;
				LET cInTransaction = 'S';
				UPDATE bdidomi:"informix".dom_cte_encabezado
				SET num_operaciones = LPAD(TO_CHAR(num_operaciones::INTEGER + 1),8,'0')
				WHERE nombre_arch = cNombre_arch_manual;

				--Obtenemos el valor del ultimo consecutivo de nombre de archivo y lo incrementamos en 1.
				SELECT LPAD(TO_CHAR(NVL(MAX(consecutivo::INTEGER),0)+1),6,'0')
				INTO cConsecutivo 
				FROM bdidomi:"informix".dom_cte_detalle 
				WHERE nombre_arch = cNombre_arch_manual;

				INSERT INTO bdidomi:"informix".dom_cte_detalle(nombre_arch, fecha_envio, tipo_registro, consecutivo, fecha_cargo,
					fecha_abono, tipo_cta_cargo, cve_banco_cargo, cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion,
					imp_iva, ref_numerica, ref_leyenda, ref_servicio, ref_titular_serv, accion, reintentar_cuenta, estatus,
					causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada,
					iva_cobrado, user_insert, fecha_insert, tipo_cta_abono, folio_suc)
				VALUES(cNombre_arch_manual, extend(MDY(MONTH(dFecha_envio), DAY(dFecha_envio), YEAR(dFecha_envio)), year to second),
					cTipoRegistro, cConsecutivo, cFecha_cargo, cFecha_abono, cTipoCtaCargo, cCveBancoCargo, cCtaCargo, cRfcCargo,
					cNombreCargo, cCtaAbono, cImpOperacion, cImpIva, cRefNumerica, cRefLeyenda, cRefServicio,
					cRefTitularServicio, cAccion, cReintentarCta, cEstatus, cCausaRechazo, cNombreArchivoCce,
					cFechaPresentacionCce, cTipoRegistroCce, cNumeroSecuenciaCce, cComisionCobrada, cIvaCobrado,
					pUser, today, cTipoCtaAbono, cFolioActivacion);

				UPDATE bdidomi:"informix".dom_cte_sumario
				SET num_operaciones = LPAD(TO_CHAR(num_operaciones::INTEGER + 1),8,'0'),
					imp_operaciones = LPAD(TO_CHAR(imp_operaciones::INTEGER + cImpOperacion::INTEGER),18,'0')
				WHERE nombre_arch = cNombre_arch_manual;
			COMMIT WORK;

			LET cInTransaction = 'N';
		ELSE
			UPDATE bdidomi:"informix".dom_cte_detalle
			SET accion = 'A'
			WHERE cuenta_abono = cCtaAbono
			AND cuenta_cargo = cCtaCargo
			AND fecha_envio = dFechaProceso;
		END IF;

	ELSE
		LET cCodret = '99957'; --No se obtuvo informacion adicional.
		--Obtenemos los datos del error ocurrido.
		EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;

		--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
		INSERT INTO bdidomi:"informix".dom_errores(Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
		VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_createtablascte_ob', TRIM(pFolio) || '-' || TRIM(cMensajeRespuesta), pUser, CURRENT);

	END IF;

END;
RETURN cCodret;
END PROCEDURE;
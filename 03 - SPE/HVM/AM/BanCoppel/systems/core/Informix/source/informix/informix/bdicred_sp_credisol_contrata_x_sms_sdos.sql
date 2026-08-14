CREATE PROCEDURE "informix".sp_credisol_contrata_x_sms_sdos(pEmpresa CHAR(3), pOpcion SMALLINT, pNumCel CHAR(20), pPlazo CHAR(2), pFolio CHAR(16) DEFAULT '')

RETURNING CHAR(5);       -- Codigo de Retorno

	-- pOpcion
		-- 1.- Envia SMS de invitacion de contratacion de Pagos Fijos Saldo a clientes prospectos.
		-- 2.- Recibe respuesta de cliente con palabra "PAGOSFIJOS + SALDO + Plazo".
		-- 3.- Envia SMS de error en proceso de contratacion
		-- 4.- Envia SMS de contratacion correcta a Pagos Fijos Saldo (PF_SMSDO_OK)
		-- 5.- Realiza Cancelacion inmediata de Credisoluciones Saldo Inmediato (Apoyo 2020) (Invitacion SMS y Credito 6900)

		
	---DECLARACIONES
    DEFINE iSqlErr				INTEGER;
    DEFINE iIsamErr				INTEGER;
    DEFINE cErrorInfo			CHAR(80);
    DEFINE cCodRet				CHAR(5);
	DEFINE cCod_retIB			CHAR(6);
    DEFINE cMensajeRet			CHAR(80);
    DEFINE cMensajeRetAux		CHAR(80);
	DEFINE cProceso             CHAR(4);
	DEFINE dtFechaHoy			DATE;
	DEFINE cNumCredito          CHAR(20);
	DEFINE cNumCredisolucion	CHAR(20);
	DEFINE cNumCte				CHAR(20);
	DEFINE cSucursal			CHAR(4);
	DEFINE dMontoSaldo			DECIMAL(18,6);
	DEFINE cNumTarjeta			CHAR(16);
	DEFINE sValido 				SMALLINT;
	DEFINE sNumPromocion		SMALLINT;
	DEFINE sMensualidad			SMALLINT;
	DEFINE sTipoSms				CHAR(1);
	DEFINE cRepCte				CHAR(1);
	DEFINE cNumCel				CHAR(20);
	DEFINE sContador			SMALLINT;
	DEFINE cSmsRespInmEsp		CHAR(1);
	DEFINE sSecuenciaTdc		SMALLINT;
	DEFINE dMensualidad2_proy 	DECIMAL(18,6);				-- Variables proyecta 
	DEFINE dIvaInt_proy			DECIMAL(18,6);
	DEFINE sPlazo_proy 			SMALLINT;
	DEFINE dTotPagar_proy		DECIMAL(18,2);
	DEFINE dSdoTdc_proy			DECIMAL(18,2);
	DEFINE cFolProm_proy		CHAR(16);
	DEFINE cNumProm_proy		SMALLINT;
	DEFINE dcmCsg_cap_vig 		DECIMAL(18,2);				--	Ini Saldos General
	DEFINE dcmCsg_tot_liquidacion	DECIMAL(18,2);
	DEFINE dcmCsg_linea_disp		DECIMAL(18,2);			--	Fin Saldos General
	DEFINE dtotal_pagar_crds		DECIMAL(18,2);			-- 	Ini Creacion credisolucion
	DEFINE dnum_plazo_crds			SMALLINT;
	DEFINE dpago_mensual_crds		DECIMAL(18,2);
	DEFINE dinteres_iva_crds		DECIMAL(18,2);
	DEFINE saldo_tdc_crds			DECIMAL(18,2);
	DEFINE dfolio_promo_crds		CHAR(16);				-- 	Ini Creacion credisolucion
	DEFINE sPlazo					SMALLINT;
	DEFINE cPlazoSMS				CHAR(2);
	DEFINE cPlazoSMS_Inv			CHAR(20);
	DEFINE cPlazoSMS_Inv_Aux		CHAR(20);
	DEFINE cPlazoSMS_Inv_Reverse	CHAR(20);
	DEFINE sTasa					DECIMAL(9,6);
	DEFINE cPlazosInvitacion		CHAR(11);
	DEFINE cTasasInvitacion			CHAR(25);
	DEFINE cTasaSMS_Aux				CHAR(5);
	DEFINE cPlazoSMS_Aux			CHAR(2);
	DEFINE cPlazosIndexsms			SMALLINT;
	DEFINE cTasa1					CHAR(5);
	DEFINE cTasa2					CHAR(5);
	DEFINE cTasa3					CHAR(5);
	DEFINE cTasa4					CHAR(5);
	DEFINE cPlazo1					CHAR(2);
	DEFINE cPlazo2					CHAR(2);
	DEFINE cPlazo3					CHAR(2);
	DEFINE cPlazo4					CHAR(2);	
	DEFINE cStatusCred        		CHAR(2);
	DEFINE cMtoVen					DECIMAL(18,2);
	DEFINE cFolioSucGF				CHAR(16);	
	DEFINE sYield					INTEGER;
	DEFINE cHoraIni 				CHAR(8);
	DEFINE cHoraFin 				CHAR(8);
	DEFINE sSmsBatchOnline			SMALLINT;
	DEFINE dTasaSdo        			DECIMAL(10,2);
	DEFINE iPlazoSdo		       	INTEGER;
	DEFINE dNum_Moras  				DECIMAL(18,2);
	DEFINE cValidaNumero			CHAR(1);
	DEFINE dIntMora           		DECIMAL(18,2);
	DEFINE dIvaIntMora        		DECIMAL(18,2);
	DEFINE dMntoVencido				DECIMAL(18,2);
	DEFINE dIvaSuc           		DECIMAL(5,3);
	DEFINE dFechaInvita				DATE;
	DEFINE cNum_Credisol			CHAR(20);
	DEFINE cFolio_Credisol       	CHAR(16);
	DEFINE cNum_Producto 			CHAR(4);
	DEFINE cDivisa					CHAR(2);
	DEFINE cFolioSuc				CHAR(16);	
	DEFINE sSatusCredisol			SMALLINT;
	DEFINE dFecha_Apertura			DATE;
	DEFINE dSdoRetenidoApoyo		DECIMAL(18,2);
	DEFINE Id_Bloqueo				INTEGER;
	DEFINE dcmCsg_linea_Orig		DECIMAL(18,2);
	DEFINE dcmCsg_linea_Increm		DECIMAL(18,2);
	DEFINE dMonto_Increm			DECIMAL(18,2);
	DEFINE dValorMinDiferir			DECIMAL(18,6);
	DEFINE dMonto_RetDiferido		DECIMAL(18,2);
	DEFINE dfolio_movto_crds		CHAR(16);
	DEFINE sFecha_ProcesoTdc		DATE;
	
	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= '';
	LET cCodRet				= '00000';
	LET cCod_retIB			= '';
	LET cMensajeRet			= 'PROCESO EXITOSO';
	LET cMensajeRetAux		= '';
	LET cProceso			= '0095';
	LET dtFechaHoy			= DATE(1);
	LET cNumCredito			= '';
	LET cNumCredisolucion	= '';
	LET cNumCte				= '';
	LET	cSucursal			= '';
	LET dMontoSaldo			= 0;
	LET cNumTarjeta			= '';
	LET sValido				= 0;
	LET sNumPromocion		= 0;
	LET sMensualidad		= 0;
	LET sTipoSms			= '0';
	LET cRepCte				= '';
	LET cNumCel				= '';
	LET sContador			= 0;
	LET cSmsRespInmEsp		= 0;
	LET sSecuenciaTdc		= 0;
	LET dMensualidad2_proy	= 0;					-- Variables proyecta 
	LET dIvaInt_proy		= 0;
	LET sPlazo_proy			= 0;
	LET dTotPagar_proy		= 0;
	LET dSdoTdc_proy		= 0;
	LET cFolProm_proy		= '';
	LET cNumProm_proy		= 0;
	LET dcmCsg_cap_vig 		= 0;					-- Inicio Variables saldo general
	LET dcmCsg_tot_liquidacion	= 0;
	LET dcmCsg_linea_disp		= 0;			-- Fin Variables saldo general
	LET dtotal_pagar_crds		= 0; 			-- 	Ini Creacion credisolucion
	LET dnum_plazo_crds			= 0;
	LET dpago_mensual_crds		= 0;
	LET dinteres_iva_crds		= 0;
	LET saldo_tdc_crds			= 0;
	LET dfolio_promo_crds		= 0;			-- 	Ini Creacion credisolucion
	LET sPlazo					= 0;
	LET cPlazoSMS				= '';
	LET cPlazoSMS_Inv			= '';
	LET cPlazoSMS_Inv_Aux		= '';
	LET cPlazoSMS_Inv_Reverse	= '';
	LET sTasa					= 0;
	LET cPlazosInvitacion		= '';
	LET cTasasInvitacion		= '';
	LET cTasaSMS_Aux			= '';
	LET cPlazoSMS_Aux			= '';
	LET cPlazosIndexsms			= 0;
	LET cTasa1					= '';
	LET cTasa2					= '';
	LET cTasa3					= '';
	LET cTasa4					= '';
	LET cPlazo1					= '';
	LET cPlazo2					= '';
	LET cPlazo3					= '';
	LET cPlazo4					= '';
	LET cStatusCred				= '';
	LET cMtoVen					= 0;	
	LET cFolioSucGF				= '';
	LET sYield					= 0;
	LET cHoraIni 				= '';
	LET cHoraFin 				= '';
	LET sSmsBatchOnline			= 0;
	LET dTasaSdo        		= 0;
	LET iPlazoSdo		       	= 0;
	LET dNum_Moras				= 0;
	LET cValidaNumero			= '';
	LET dIntMora   				= 0;
	LET dIvaIntMora				= 0;
	LET dMntoVencido			= 0;
	LET dIvaSuc					= 0;
	LET dFechaInvita			= DATE(1);
	LET cNum_Credisol			= '';
	LET cFolio_Credisol			= '';
	LET cNum_Producto			= '';
	LET cDivisa					= '';
	LET cFolioSuc				= '';
	LET sSatusCredisol			= 0;
	LET dFecha_Apertura			= DATE(1);
	LET dSdoRetenidoApoyo		= 0;
	LET Id_Bloqueo				= 0;
	LET dcmCsg_linea_Orig		= 0;
	LET dcmCsg_linea_Increm		= 0;
	LET dMonto_Increm			= 0;
	LET dValorMinDiferir		= 0;
	LET dMonto_RetDiferido		= 0;
	LET dfolio_movto_crds		= '';
	LET sFecha_ProcesoTdc		= DATE(1);


BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||iIsamErr::CHAR||'-'||cNumCredito, '02') Returning cCod_retIB;
			RETURN cCodRet;
       END IF;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    --SET DEBUG FILE TO '/informix/IvanZazueta/sp_credisol_contrata_x_sms_sdos.out';
	--TRACE ON;

	--Obtiene la fecha de hoy.
	SELECT fecha_hoy INTO dtFechaHoy FROM "informix".sd_fechas WHERE empresa = pEmpresa;

	--Obtiene horario correcto de envio de sms
	SELECT valor_alfabetico INTO cHoraIni FROM bdicred:sd_param_campania WHERE empresa = '001' AND tipo_campania = 2 AND grupo_parametro = 'PAGOSFIJOS' AND num_parametro = 17;
	SELECT valor_alfabetico INTO cHoraFin FROM bdicred:sd_param_campania WHERE empresa = '001' AND tipo_campania = 2 AND grupo_parametro = 'PAGOSFIJOS' AND num_parametro = 18;
	IF (current hour to second < cHoraIni OR current hour to second > cHoraFin) THEN		-- Valida horario para envio de SMS invitacion modo BATCH u ON LINE
		LET sSmsBatchOnline = 2;	-- BATCH
	ELSE
		LET sSmsBatchOnline = 1;	-- On line
	END IF;
	IF pOpcion != 2 THEN 			-- Por el momento se envian en BATCH invitaciones de SMS Saldos para no saturar el envio masivo por latinia,
		LET sSmsBatchOnline = 2;
	END IF;

	-- Obtiene el valor minimo a diferir
	SELECT TRIM(valor)::DECIMAL(18,2) INTO dValorMinDiferir FROM "informix".sd_param WHERE cod_param  = '029';	
	IF dValorMinDiferir IS NULL THEN LET dValorMinDiferir = 1000; END IF;
	
	IF pOpcion <> 1 THEN 		-- Obtiene datos para opciones diferentes de 1 (no hacer dobles consultas)
	
		LET sContador = 0;
		SELECT count(a.numcte) INTO sContador											-- Telefono asignado a mas de un credito
		  FROM bdinteg:si_telefonos a
		 INNER JOIN bdicred:sd_maecred b ON ( a.numcte = b.numcte )
		 INNER JOIN bdicred:sd_definicion d ON (b.num_producto = d.num_producto and d.edocta_param = 'tdc')
		 --WHERE telefono = pNumCel AND tipo_tel = 2 AND verificado = 'V' AND status_tel = 'A';
		 WHERE telefono = pNumCel AND tipo_tel = 2 AND status_tel = 'A';
		IF sContador > 1 AND pOpcion = 2 THEN		-- Solamente mande este mensaje cuando venga del cliente
			LET cMensajeRet = 'Telefono erroneo, asignado a mas de un credito. ';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||pNumCel, '02') Returning cCod_retIB;
			-- Envia mensaje sms de error
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SMSERR1','000000000','','',1,'','','','','','','','','','','',pNumCel,0,0,0,0,0,current, current) INTO cCod_retIB;
			RETURN cCodRet;	
		END IF;
		 
		IF pOpcion in (3,4)  THEN 
			SELECT a.numcte, b.num_credito, b.sucursal, b.status_cred, NVL(e.monto_vencido + e.mto_venc_trasp,0)		-- Obtiene el numero de credito ligado al telefono.
			  INTO cNumCte,  cNumCredito  , cSucursal,  cStatusCred, cMtoVen
			  FROM bdinteg:si_telefonos a
			 INNER JOIN bdicred:sd_maecred b ON ( a.numcte = b.numcte )
			 INNER JOIN bdicred:sd_definicion d ON (b.num_producto = d.num_producto and d.edocta_param = 'tdc')
			 INNER JOIN bdicred:sd_promocion_credito_sms p ON (b.num_credito = p.num_credito and folio_compra_sms = pFolio)
			 INNER JOIN bdicred:sd_maesdos e ON (b.num_credito = e.num_credito)
			 WHERE telefono = pNumCel
			   AND tipo_tel = 2
			   --AND verificado = 'V'
			   AND status_tel = 'A';
		ELSE
			SELECT a.numcte, b.num_credito, b.sucursal, b.status_cred, NVL(e.monto_vencido + e.mto_venc_trasp,0)		-- Obtiene el numero de credito ligado al telefono.
			  INTO cNumCte,  cNumCredito  , cSucursal,  cStatusCred, cMtoVen
			  FROM bdinteg:si_telefonos a
			 INNER JOIN bdicred:sd_maecred b ON ( a.numcte = b.numcte and (b.status_cred IN ('AA','E1')))
			 INNER JOIN bdicred:sd_maesdos e ON (b.num_credito = e.num_credito AND (e.monto_vencido + e.mto_venc_trasp) = 0)
			 INNER JOIN bdicred:sd_definicion d ON (b.num_producto = d.num_producto and d.edocta_param = 'tdc')
			 WHERE telefono = pNumCel
			   AND tipo_tel = 2
			   --AND verificado = 'V'
			   AND status_tel = 'A';
		END IF;
		IF nvl(cNumCredito, '') = '' OR nvl(cNumCte, '') = '' THEN
			LET cMensajeRet = 'Telefono erroneo, no esta asignado a un credito. ';		---  Credito no tiene asignado numero de celular valido.
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||pNumCel, '02') Returning cCod_retIB;
			-- Envia mensaje sms de error
			IF pNumCel != '' THEN
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SMSERR1','000000000','','',sSmsBatchOnline,'','','','','','','','','','','',pNumCel,0,0,0,0,0,current,current) INTO cCod_retIB;
				RETURN cCodRet;
			END IF;	
		END IF;
	END IF;	
		

	-- 1.- Envia SMS de invitacion para Pagos Fijos Saldo a clientes prospectos.
	IF pOpcion = 1 THEN			

		FOREACH	WITH HOLD													-- Identifica las campaniaas de saldos activas
		   SELECT num_promo INTO sNumPromocion
		     FROM bdicred:sd_promocion 
			 WHERE num_promo = 9 AND fechaini_promo <= dtFechaHoy and fechafin_promo >= dtFechaHoy 
			--WHERE num_promo in (3,6,9) AND fechaini_promo <= dtFechaHoy and fechafin_promo >= dtFechaHoy 
			ORDER BY num_promo DESC

		    -- GENERA INVITACION PARA FLUJO: PAGOS FIJOS SALDO (Espera respuesta del cliente)
			FOREACH	WITH HOLD												-- Identifica los clientes marcados dentro de prospectos
			   SELECT num_credito, numcte INTO cNumCredito, cNumCte
				 FROM bdicred:sd_prospectos WHERE num_promo = sNumPromocion AND fecha_ini <= dtFechaHoy AND fecha_fin >= dtFechaHoy
				  AND envio_inv_sms = '1' AND revis_invit_sms = 1				-- Cte autorizado para invitacion sms y no ha sido revisada dicha invitacion (no analice todos ctes en cada carga)
				  
				-- Valida que el credito no tenga una invitacion vigente. Campania de saldo no convive con otras campanias
				LET sContador = 0;
				--SELECT count(num_credito) INTO sContador FROM bdicred:sd_promocion_credito_sms WHERE num_credito = cNumCredito AND num_promo = sNumPromocion AND tipo_sms in ('0','1','2','3');
				SELECT count(num_credito) INTO sContador FROM bdicred:sd_promocion_credito_sms WHERE num_credito = cNumCredito AND tipo_sms in ('0','1','2','3');
				IF sContador > 0 THEN
				
					UPDATE bdicred:sd_prospectos SET revis_invit_sms = 0 WHERE num_promo = sNumPromocion AND num_credito = cNumCredito;
					LET cMensajeRet = 'Credito con invitacion sms vigente. ';
					CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito||'-'||sNumPromocion, '02') Returning cCod_retIB;					
					CONTINUE FOREACH; 		-- Credito existe con invitacion vigente y lo ignora, no envia invitacion.
				END IF;

				/*-- Valida que el cliente no tenga una credisolucion (pagos fijos) vigente.  	-- OJO ,, revisar si puede contratar saldos si ya tiene una de efectivo o compras vigente OJO
				LET sContador = 0;
				SELECT count(num_credito) INTO sContador FROM bdicred:sd_promocion_credito WHERE num_credito = cNumCredito AND status IN (0,2);
				--SELECT count(num_credito) INTO sContador FROM bdicred:sd_promocion_credito WHERE num_promo = sNumPromocion AND num_credito = cNumCredito AND status IN (0,2);
				IF sContador > 0 THEN
				
					UPDATE bdicred:sd_prospectos SET revis_invit_sms = 0 WHERE num_promo = sNumPromocion AND num_credito = cNumCredito;
					LET cMensajeRet = 'Credito con pagos fijos (credisolucion) vigente. ';
					CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito||'-'||sNumPromocion, '02') Returning cCod_retIB;									
					CONTINUE FOREACH; 		-- Credito ya tiene una credisolucion o pagos fijos existente.
				END IF;*/
				
				-- Valida el numero de celular valido ligado al credito 
				SELECT first 1 a.telefono, b.status_cred, b.sucursal INTO cNumCel, cStatusCred, cSucursal
				  FROM bdinteg:si_telefonos a INNER JOIN bdicred:sd_maecred b ON ( a.numcte = b.numcte ) 
				 WHERE tipo_tel = 2 AND verificado = 'V' AND status_tel = 'A' AND b.num_credito = cNumCredito;
				IF NVL(cNumCel, '') = '' THEN
				
					UPDATE bdicred:sd_prospectos SET revis_invit_sms = 0 WHERE num_promo = sNumPromocion AND num_credito = cNumCredito;
					LET cMensajeRet = 'Credito no tiene asignado numero de celular valido. ';
					CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito||'-'||cNumCel, '02') Returning cCod_retIB;					
					CONTINUE FOREACH;		
				END IF;			

				IF cStatusCred NOT IN ('AA','E1') AND cMtoVen > 0 THEN		-- Verifica el estatus del credito. Solo AA tiene derecho a invitacion para contratar Pagos Fijos.

					UPDATE bdicred:sd_prospectos SET revis_invit_sms = 0 WHERE num_promo = sNumPromocion AND num_credito = cNumCredito;
					LET cMensajeRet = 'Credito en estatus diferente a vigente. ';
					CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito||'-'||cStatusCred, '02') Returning cCod_retIB;					
					CONTINUE FOREACH;
				END IF;
					
				-- Obtiene numero de tarjeta
				SELECT max(secuencia) INTO sSecuenciaTdc FROM bdicred:"informix".sd_tarjeta WHERE empresa = '001' AND num_credito = cNumCredito AND tipo_tarjeta = 'T' AND status_tar = 'A';
				SELECT first 1 num_tarjeta INTO cNumTarjeta FROM bdicred:"informix".sd_tarjeta WHERE empresa = '001' AND num_credito = cNumCredito AND tipo_tarjeta = 'T' AND status_tar = 'A' AND secuencia = sSecuenciaTdc;		
		
				-- Obtiene saldos del credito.
				SELECT sdo_capital,    (monto_otorgado - (sdo_cap_insoluto + sdo_retenido)), (sdo_cap_insoluto + sdo_retenido) 
				  INTO dcmCsg_cap_vig, dcmCsg_linea_disp,									 dcmCsg_tot_liquidacion
				  FROM bdicred:sd_maesdos WHERE num_credito = cNumCredito;			
				LET dMontoSaldo	= dcmCsg_cap_vig;

				-- Identifica los plazos y tasas disponibles para el cliente segun su saldo disponible.
				LET cPlazosInvitacion = '';	LET cTasasInvitacion  = '';	LET cTasaSMS_Aux  = '';	LET cPlazoSMS_Aux = '';	LET sContador = 0;	LET cPlazoSMS_Inv = '';	LET sValido = 0;	LET cPlazoSMS = '';
				FOREACH
				  SELECT plazo, tasa  INTO sPlazo, sTasa
			        FROM bdicred:sd_tasa_plazo_sms WHERE num_promo = sNumPromocion 
				   ORDER BY plazo ASC
				 
					LET cPlazoSMS = to_char(sPlazo);
					LET cTasaSMS_Aux  = lpad(to_char(sTasa),5,'0');
					LET cPlazoSMS_Aux = lpad(to_char(sPlazo),2,'0');
					
					-- Proyecta para la promocion y plazo especificado.
					--EXECUTE PROCEDURE bdicred:sp_proyecta_pfsms(1, cSucursal, USER, sNumPromocion, cNumCredito, cNumTarjeta, dMontoCompra, sPlazo, sTasa, pfolio_suc) INTO
					EXECUTE PROCEDURE bdicred:sp_proyecta_pfsms(1, cSucursal, USER, sNumPromocion, cNumCredito, cNumTarjeta, dMontoSaldo, sPlazo, sTasa, '') INTO
									  cCod_retIB, cMensajeRetAux, dTotPagar_proy, sPlazo_proy, dMensualidad2_proy, dIvaInt_proy, dSdoTdc_proy, cFolProm_proy, cNumProm_proy;				
		
					IF cCod_retIB = '00000' THEN
					
						IF dcmCsg_linea_disp < dIvaInt_proy THEN	--	 Si saldo disponible NO cubre proyeccion de credisolucion (monto int e iva).
							CONTINUE FOREACH;
						END IF;
					
						LET sMensualidad = dMensualidad2_proy;
						LET sValido = 1;			-- Proyeccion correcta. No termina, proyecta todos los plazos - tasas disponibles para el cliente.
						IF sContador = 0 THEN
							LET cPlazosInvitacion = TRIM(cPlazoSMS_Aux);
							LET cTasasInvitacion  = TRIM(cTasaSMS_Aux);
							LET cPlazoSMS_Inv = TRIM(cPlazoSMS);
						ELSE
							LET cPlazosInvitacion = TRIM(cPlazosInvitacion) || '-' || TRIM(cPlazoSMS_Aux);		-- Almacena plazos disponibles al cliente
							LET cTasasInvitacion  = TRIM(cTasasInvitacion) || '-' || TRIM(cTasaSMS_Aux);
							LET cPlazoSMS_Inv = TRIM(cPlazoSMS_Inv) || ', ' || TRIM(cPlazoSMS);		  		-- Arma cadena de plazos disponibles para mensaje invitacion
						END IF;						
						LET sContador = sContador + 1;					
					END IF;
				END FOREACH;
				IF sContador >= 2 THEN
					LET cPlazoSMS_Inv_Reverse = reverse(trim(cPlazoSMS_Inv));
					LET cPlazosIndexsms = CHARINDEX(',',cPlazoSMS_Inv_Reverse);
					LET cPlazoSMS_Inv_Aux = cPlazoSMS_Inv;
					LET cPlazoSMS_Inv = reverse(SUBSTR(cPlazoSMS_Inv_Reverse, 1,(cPlazosIndexsms - 2))||' o '||SUBSTR(cPlazoSMS_Inv_Reverse,(cPlazosIndexsms + 1),(length(trim(cPlazoSMS_Inv_Reverse)) - cPlazosIndexsms )));
				END IF;	
			
				IF sValido = 1 THEN

					-- Inserta registro de la invitacion
					LET sContador = 0;
					SELECT --USER 
						year(current) || lpad(month(current),2,0) || lpad(day(current),2,0)
						|| substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,1,2) || substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,4,2)
						|| substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,7,2) || lpad(bdicheq:sp_random(),2,'0')
					INTO cFolioSucGF 
					FROM sysmaster:sysshmvals;
					-- Valida que folio no exista
					   SELECT COUNT(folio_compra_sms) INTO sContador FROM bdicred:sd_promocion_credito_sms 
						WHERE num_credito = cNumCredito AND folio_compra_sms = cFolioSucGF;
					   IF sContador > 0 THEN
					      SELECT --USER 
								year(current) || lpad(month(current),2,0) || lpad(day(current),2,0)
								|| substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,1,2)	||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,4,2)
							 	||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,7,2)	||lpad(bdicheq:sp_random(),2,'0'), sysmaster:yieldn( 1 )
						    INTO cFolioSucGF, sYield FROM sysmaster:sysshmvals;
					   END IF;
					-------

					INSERT INTO bdicred:sd_promocion_credito_sms(empresa, num_credito, num_cte, mnto_compra, folio_compra_sms, fecha_invitacion, tipo_sms, num_promo, fecha_env_sms_inv, plazos_invita, tasas_invita, fecha_insert )
					VALUES('001', cNumCredito, cNumCte, dMontoSaldo, cFolioSucGF, dtFechaHoy, '1', sNumPromocion, CURRENT, cPlazosInvitacion, cTasasInvitacion, CURRENT);
	
					UPDATE bdicred:sd_prospectos SET revis_invit_sms = 0 WHERE num_promo = sNumPromocion AND num_credito = cNumCredito;
					
					LET cCod_retIB = '';
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_INVSDO1','000000000','', '',sSmsBatchOnline,'',cPlazoSMS_Inv,'','','','','','','','','',cNumCel,dMontoSaldo,0,0,0,0,
									  current, current) INTO cCod_retIB;
					IF cCod_retIB <> '00000' THEN
						LET cCodRet = '00000';
						LET cMensajeRet = 'Error en el envio de mensaje SMS de invitacion PF Saldo.';
						CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito||'-'||sNumPromocion, '02') Returning cCod_retIB;
					END IF;	
					
				ELSE			--- Proyeccion de cliente no es valido en ningun plazo.
					UPDATE bdicred:sd_prospectos SET revis_invit_sms = 0 WHERE num_promo = sNumPromocion AND num_credito = cNumCredito;
					LET cMensajeRet = 'Credito no es candidato para ningun plazo. ';
					CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito||'-'||sNumPromocion, '02') Returning cCod_retIB;					
				END IF;
				
			END FOREACH;
			
			
		    -- GENERA INVITACION PARA FLUJO: PAGOS FIJOS SALDO INMEDIATO (Genera Invitacion sin respuesta del cliente) - PARA APOYO 2020
			FOREACH	WITH HOLD														-- Identifica los clientes marcados dentro de prospectos
			   SELECT num_credito, numcte, tasa, plazo INTO cNumCredito, cNumCte, dTasaSdo, iPlazoSdo
				 FROM bdicred:sd_prospectos WHERE num_promo = sNumPromocion AND fecha_ini <= dtFechaHoy AND fecha_fin >= dtFechaHoy
				  AND envio_inv_sms = '3' AND revis_invit_sms = 1				-- Cte autorizado para invitacion sms y no ha sido revisada dicha invitacion (no analice todos ctes en cada carga)
				  
				LET dSdoRetenidoApoyo = 0;	  

			   -- Valida Plazo sera correcto.
				EXECUTE PROCEDURE bdinteg:sp_esnumerico(iPlazoSdo)INTO cValidaNumero;
				IF cValidaNumero = 'F' OR iPlazoSdo <= 0 THEN 
					UPDATE bdicred:sd_prospectos SET revis_invit_sms = 0 WHERE num_promo = sNumPromocion AND num_credito = cNumCredito;
					INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',cNumCredito,'sp_credisol_contrata_x_sms_sdos',TODAY,CURRENT,'','','00001'); -- Plazo incorrecto
					CONTINUE FOREACH; 
				END IF;
				
				-- Valida numero de credito y numero de cliente
				SELECT count(num_credito) INTO sContador FROM bdicred:sd_maecred WHERE num_credito = cNumCredito and numcte = cNumCte and status_cred in ('AA','BA','E1');

				IF sContador != 1 THEN
					UPDATE bdicred:sd_prospectos SET revis_invit_sms = 0 WHERE num_promo = sNumPromocion AND num_credito = cNumCredito;
					INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',cNumCredito,'sp_credisol_contrata_x_sms_sdos',TODAY,CURRENT,'','','00002'); -- Num Credito & Num Cte incorrectos
					CONTINUE FOREACH;
				END IF;
				
				-- Valida el numero de celular valido ligado al credito.  -- Unicamente validar celular activo.
				SELECT first 1 a.telefono, b.status_cred, b.sucursal, b.num_producto, b.divisa INTO cNumCel, cStatusCred, cSucursal, cNum_Producto, cDivisa
				  FROM bdinteg:si_telefonos a INNER JOIN bdicred:sd_maecred b ON ( a.numcte = b.numcte) 
				  WHERE tipo_tel = 2 AND status_tel = 'A' AND b.num_credito = cNumCredito;				 -- AND verificado = 'V' 
				IF cNumCel IS NULL THEN LET cNumCel = ''; END IF;
				/*IF NVL(cNumCel, '') = '' THEN
					UPDATE bdicred:sd_prospectos SET revis_invit_sms = 0 WHERE num_promo = sNumPromocion AND num_credito = cNumCredito;
					INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',cNumCredito,'sp_credisol_contrata_x_sms_sdos',TODAY,CURRENT,'','','00003');  -- Credito con telefono no valido
					CONTINUE FOREACH;
				END IF;		--- No descarta creditos sin telefono.
				*/
				IF NVL(cNumCel, '') = '' THEN
					SELECT status_cred, sucursal, num_producto, divisa INTO cStatusCred, cSucursal, cNum_Producto, cDivisa
					  FROM bdicred:sd_maecred WHERE num_credito = cNumCredito;
				END IF;

				-- Valida que el cliente no tenga una credisolucion de saldos pendientes de procesar.
				LET sContador = 0;
				SELECT count(num_credito) INTO sContador FROM bdicred:sd_promocion_credito WHERE num_credito = cNumCredito AND num_promo = sNumPromocion AND status IN (0);
				IF sContador > 0 THEN
					UPDATE bdicred:sd_prospectos SET revis_invit_sms = 0 WHERE num_promo = sNumPromocion AND num_credito = cNumCredito;
					INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',cNumCredito,'sp_credisol_contrata_x_sms_sdos',TODAY,CURRENT,'','','00004');  -- Ya tiene una crediso Saldos pendiente
					CONTINUE FOREACH;
				END IF;

				-- Valida que solo sea credito con 0 o 1 mora
				SELECT mto_fin_ven_trasp, monto_vencido INTO dNum_Moras, dMntoVencido FROM bdicred:sd_maesdos WHERE num_credito = cNumCredito;
				--IF dNum_Moras NOT IN (0,1) THEN  -- Se elimina mora 1 (fin de programa apoyo) y por inicio de IFRS
				IF dNum_Moras != 0 THEN
					UPDATE bdicred:sd_prospectos SET revis_invit_sms = 0 WHERE num_promo = sNumPromocion AND num_credito = cNumCredito;
					INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',cNumCredito,'sp_credisol_contrata_x_sms_sdos',TODAY,CURRENT,dNum_Moras,'','00005');  -- Credito con mas de 1 mora
					CONTINUE FOREACH;						
				END IF;
				
				-- Obtiene saldos del credito
				SELECT sdo_cap_insoluto, (monto_otorgado - (sdo_cap_insoluto + sdo_retenido)), (sdo_cap_insoluto)    , monto_otorgado		 -- Sin retenido
				  INTO dcmCsg_cap_vig  , dcmCsg_linea_disp                                   , dcmCsg_tot_liquidacion, dcmCsg_linea_Orig 
				  FROM bdicred:sd_maesdos WHERE num_credito = cNumCredito;			
				  
				LET dIntMora = 0; LET dIvaIntMora = 0;
				IF dNum_Moras != 0 THEN	-- Obtiene moratorio para clientes con status BA
				
					SELECT iva INTO dIvaSuc FROM bdinteg:"informix".si_sucursales WHERE sucursal = cSucursal AND empresa  = '001';
			
					SELECT SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)),
						   ROUND(sum(NVL(mora_iva_debe,0) - NVL(mora_iva_pagado,0) +( NVL(mora_provi_ordi + mora_provi_cope,0)* dIvaSuc )),2)
					  INTO dIntMora,											 dIvaIntMora
					  FROM "informix".sd_amortiza_credito WHERE empresa = '001' AND num_credito = cNumCredito AND capital_status IN ('2','7','6');
					  IF dIntMora IS NULL THEN LET dIntMora = 0; END IF 
					  IF dIvaIntMora IS NULL THEN LET dIvaIntMora = 0; END IF;
				ELSE
					SELECT sum(monto) INTO dSdoRetenidoApoyo					-- Obtiene saldos retenidos para programa apoyo, Se tome en cuenta como parte del saldo
					  FROM bdicred:sd_maeretenido WHERE num_credito = cNumCredito
					   AND transacc in ('8369', '8370') AND estatus = "R";					  
					IF dSdoRetenidoApoyo IS NULL THEN LET dSdoRetenidoApoyo = 0; END IF;   
				END IF	
				
				LET dcmCsg_cap_vig = dcmCsg_cap_vig + dSdoRetenidoApoyo;
				LET dMontoSaldo	= dcmCsg_cap_vig;
					
				-- Realiza proyectos para verificar Plazo & Tasa
				LET cPlazosInvitacion = '';	LET cTasasInvitacion  = '';	LET cTasaSMS_Aux  = '';	LET cPlazoSMS_Aux = '';	LET sContador = 0;	LET cPlazoSMS_Inv = '';	LET sValido = 0;	LET cPlazoSMS = '';

				-- Obtiene numero de tarjeta
				SELECT max(secuencia) INTO sSecuenciaTdc FROM bdicred:"informix".sd_tarjeta WHERE empresa = '001' AND num_credito = cNumCredito AND tipo_tarjeta = 'T' AND status_tar = 'A';
				SELECT first 1 num_tarjeta INTO cNumTarjeta FROM bdicred:"informix".sd_tarjeta WHERE empresa = '001' AND num_credito = cNumCredito AND tipo_tarjeta = 'T' AND status_tar = 'A' AND secuencia = sSecuenciaTdc;		
				IF cNumTarjeta IS NULL THEN LET cNumTarjeta = 'X'; END IF; -- Se asigna una X, para que sp_proyecta_pfsms no valide status del credito
						
				-- Realiza la proyecion de Pagos Fijos para el plazo y tasa especificados. Si es correcta, se registra la compra.
				IF dMontoSaldo >= dValorMinDiferir THEN
				
					EXECUTE PROCEDURE bdicred:sp_proyecta_pfsms(1, cSucursal, USER, sNumPromocion, cNumCredito, cNumTarjeta, dMontoSaldo, iPlazoSdo, dTasaSdo, '') INTO
										cCod_retIB, cMensajeRetAux, dTotPagar_proy, sPlazo_proy, dMensualidad2_proy, dIvaInt_proy, dSdoTdc_proy, cFolProm_proy, cNumProm_proy;
										
				ELSE
					UPDATE bdicred:sd_prospectos SET revis_invit_sms = 0 WHERE num_promo = sNumPromocion AND num_credito = cNumCredito;
					INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',cNumCredito,'sp_credisol_contrata_x_sms_sdos',TODAY,CURRENT,'','','00006'); -- No cumple minimo a diferir
					CONTINUE FOREACH;				
				END IF;
										
				/*IF cCod_retIB != '00000' THEN		-- Error en la proyeccion
					UPDATE bdicred:sd_prospectos SET revis_invit_sms = 0 WHERE num_promo = sNumPromocion AND num_credito = cNumCredito;
					INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',cNumCredito,'sp_credisol_contrata_x_sms_sdos',TODAY,CURRENT,'','','00006'); 
					CONTINUE FOREACH;	
				END IF;
					
				IF dcmCsg_linea_disp < dIvaInt_proy THEN	--	 Si saldo disponible NO cubre proyeccion de credisolucion (monto int e iva).
					UPDATE bdicred:sd_prospectos SET revis_invit_sms = 0 WHERE num_promo = sNumPromocion AND num_credito = cNumCredito;
					 -- Credito no tiene linea disponible suficiente
					INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',cNumCredito,'sp_credisol_contrata_x_sms_sdos',TODAY,CURRENT,'','','00007'); 
					CONTINUE FOREACH;	
				END IF;			--	No descarte por no tener linea disponible y realice incremento de linea */

				LET dMonto_Increm = 0;
				LET dcmCsg_linea_Increm = 0;
				IF dcmCsg_linea_disp < dIvaInt_proy THEN			-- Si no alcanza a cubrir el interes diferido, que realice el incremento de linea
				
					LET dMonto_Increm = dIvaInt_proy - dcmCsg_linea_disp; 	-- Obtiene el monto el cual no cubre el monto diferido
					LET dcmCsg_linea_Increm = dcmCsg_linea_Orig + dMonto_Increm;
					
					EXECUTE PROCEDURE bdicred:sp_actualiza_lincred_central_masivo('001', cNumCredito, dcmCsg_linea_Increm, 'A','1', user) INTO cCod_retIB, cMensajeRetAux;
					
					IF cCod_retIB <> "000000" THEN
						UPDATE bdicred:sd_prospectos SET revis_invit_sms = 0 WHERE num_promo = sNumPromocion AND num_credito = cNumCredito;
						INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',cNumCredito,'sp_credisol_contrata_x_sms_sdos',TODAY,CURRENT,'','','00009'); 
						CONTINUE FOREACH;									-- Error en proceso de increment de linea
					END IF
				END IF;
				
				-- Inserta registro de la invitacion
				LET sContador = 0;
				SELECT --USER 
					year(current) || lpad(month(current),2,0) || lpad(day(current),2,0)
					|| substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,1,2) || substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,4,2)
					|| substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,7,2) || lpad(bdicheq:sp_random(),2,'0')
				INTO cFolioSucGF 
				FROM sysmaster:sysshmvals;
				-- Valida que folio no exista
				   SELECT COUNT(folio_compra_sms) INTO sContador FROM bdicred:sd_promocion_credito_sms 
					WHERE num_credito = cNumCredito AND folio_compra_sms = cFolioSucGF;
				   IF sContador > 0 THEN
					  SELECT --USER 
							year(current) || lpad(month(current),2,0) || lpad(day(current),2,0)
							|| substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,1,2)	||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,4,2)
							||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,7,2)	||lpad(bdicheq:sp_random(),2,'0'), sysmaster:yieldn( 1 )
						INTO cFolioSucGF, sYield FROM sysmaster:sysshmvals;
				   END IF;
				-------

				INSERT INTO bdicred:sd_promocion_credito_sms(empresa, num_credito, num_cte, mnto_compra, folio_compra_sms, fecha_invitacion, tipo_sms, num_promo    , fecha_env_sms_inv, plazos_invita, tasas_invita, fecha_insert,
														     respuesta_cte_sms, fecha_resp_cte_sms, envio_result_sms, status_envio_r_sms, plazo, tasa  , num_credisolucion, fecha_cancela, compra_inmd, sms_resp_inmd, tipo_contrato)
											          VALUES('001'  , cNumCredito, cNumCte, dMontoSaldo, cFolioSucGF     , dtFechaHoy      , '2'     , sNumPromocion, CURRENT          , iPlazoSdo    , dTasaSdo    , CURRENT, 
															 'S'              , CURRENT           , NULL            , NULL              , iPlazoSdo, dTasaSdo, NULL             , NULL         , '1'        , '1'          , NULL);
												  
				UPDATE bdicred:sd_prospectos SET revis_invit_sms = 0 WHERE num_promo = sNumPromocion AND num_credito = cNumCredito;
									

				-- INI.- Se elimina mora 1 (limpieza de saldos) por inicio de IFRS y fin de programa apoyo (ya no se procesan PFSI)
				-- Limpia saldos de credito con MORA 1
				/*IF dNum_Moras = 1 THEN 
					BEGIN WORK;
					
					SELECT valor INTO cIFRS FROM bdicred:sd_param WHERE cod_param = '700';
					
					IF cIFRS = 'A' THEN
						UPDATE bdicred:sd_maecred SET status_cred = 'E1' WHERE num_credito = cNumCredito;
						UPDATE bdicred:sd_maesdos SET monto_financiado = monto_financiado - monto_vencido,  monto_vencido  = 0, sdo_contab_mora = 0, sdo_moratorio = 0, 
							   sdo_capital = sdo_cap_insoluto, mto_fin_ven_trasp = 0, dias_acum_mora = 0 act = 0 WHERE num_credito = cNumCredito;
					ELSE
						UPDATE bdicred:sd_maecred SET status_cred = 'AA' WHERE num_credito = cNumCredito;
						UPDATE bdicred:sd_maesdos SET monto_financiado = monto_financiado - monto_vencido,  monto_vencido  = 0, sdo_contab_mora = 0, sdo_moratorio = 0, 
						   sdo_capital = sdo_cap_insoluto, mto_fin_ven_trasp = 0, dias_acum_mora = 0 WHERE num_credito = cNumCredito;
					END IF;

					UPDATE bdicred:sd_maecredanexo SET fecha_vencto = NULL WHERE num_credito = cNumCredito;
					 
 					UPDATE bdicred:sd_amortiza_credito SET capital_status_ant = capital_status, capital_status = '5', mora_provi_ordi = 0, mora_provi_cope = 0, 
							mora_sdo_ordi = mora_sdo_ordi_pag, mora_sdo_cope = mora_sdo_cope_pag, mora_iva_debe = mora_iva_pagado 
                     WHERE num_credito = cNumCredito AND capital_status = '7';

						   
					-- Genera registros para condonar interes moratorio, iva de interes moratorio (limpieza de mora) y monto vencido.
					EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina(TRIM("informix")) INTO cCod_retIB, cFolioSuc;										
					
					IF dIntMora > 0 THEN
						EXECUTE PROCEDURE GENMOV('001', cNumCredito, cNum_Producto, 11, '060', dtFechaHoy, dIntMora, cFolioSuc, cSucursal, cDivisa, '7596')
									 INTO cCod_retIB, cMensajeRetAux;
					END IF;				 
								 
					IF dIvaIntMora > 0 THEN	
						EXECUTE PROCEDURE GENMOV('001', cNumCredito, cNum_Producto, 12, '060', dtFechaHoy, dIvaIntMora, cFolioSuc, cSucursal, cDivisa, '7597')
									 INTO cCod_retIB, cMensajeRetAux;								 
					END IF;
					
					IF dMntoVencido > 0 THEN
						EXECUTE PROCEDURE GENMOV('001', cNumCredito, cNum_Producto, 4, '602', dtFechaHoy, dMntoVencido, cFolioSuc, cSucursal, cDivisa, '7598')
									 INTO cCod_retIB, cMensajeRetAux;						
					END IF;
				END IF;
				--FIN
				*/  
				  
				-- Genera registro de la Credisolucion con status 0
				EXECUTE PROCEDURE sp_proyecta_pfsms(3, cSucursal, USER, sNumPromocion, cNumCredito, '', dcmCsg_cap_vig, iPlazoSdo, dTasaSdo, cFolioSucGF)
				   INTO cCod_retIB, cMensajeRet, dtotal_pagar_crds, dnum_plazo_crds, dpago_mensual_crds, dinteres_iva_crds, saldo_tdc_crds, dfolio_promo_crds, cNumProm_proy;
				IF cCod_retIB <> '00000' THEN
					UPDATE bdicred:sd_prospectos SET revis_invit_sms = 0 WHERE num_promo = sNumPromocion AND num_credito = cNumCredito;
					UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '6' WHERE num_credito = cNumCredito AND folio_compra_sms = cFolioSucGF;
					INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',cNumCredito,'sp_credisol_contrata_x_sms_sdos',TODAY,CURRENT,'','','00008');  -- Error al insertar en promocion_credito
					--	Reversa limpieza de saldos cuando credito se encuentra con mora = 1
					IF dNum_Moras = 1 THEN ROLLBACK WORK; END IF;
					CONTINUE FOREACH;	
				END IF;

				IF dNum_Moras = 1 THEN  COMMIT WORK; END IF;	-- Confirma limpieza de saldos.
					
				-- Credisolucion en este punto es de status = 0, no se ha generado credito 6900. 
				UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '7' WHERE num_credito = cNumCredito AND folio_compra_sms = cFolioSucGF;
				
				-- Actualiza informacion del incremento realizado
				UPDATE bdicred:sd_promocion_credito SET monto_linea_orig = dcmCsg_linea_Orig, sdo_incremento = dMonto_Increm
				 WHERE num_credito = cNumCredito AND fecha = dtFechaHoy AND folio_movto = dfolio_promo_crds;
				
				-- Bloquea credito para que cliente no pueda disponer de su credito de TDC hasta formalizar el credito 6900
				UPDATE bdicred:sd_maecred SET id_unidad_prod = 2 WHERE num_credito = cNumCredito;
				
				-- Envia mensaje al cliente indicando de la contratacion y que envie cancelar + saldo si asi lo desea.
				IF cNumCel != '' THEN
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SDO_INME','000000000','', '',sSmsBatchOnline, iPlazoSdo, round(dTasaSdo,2), '', '', '', '', '',
								'', '', '', '',cNumCel, dMontoSaldo, 0, 0, 0, 0, current, current) INTO cCod_retIB;							
				END IF;
			END FOREACH;
			
		END FOREACH;
	
	-- 2.- Recibe respuesta de cliente con palabra PAGOSFIJOS + SALDO + plazo
	ELIF pOpcion = 2 THEN

	
		IF cStatusCred NOT IN ('AA','E1') AND cMtoVen > 0 THEN
			LET cMensajeRet = 'Credito en estatus diferente a vigente. ';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito||'-'||cStatusCred||'-'||pNumCel, '02') Returning cCod_retIB;
			-- Envia mensaje sms de error generico.
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SDOSTAER','000000000','','',1,'','','','','','','','','','','',pNumCel,0,0,0,0,0,current, current) INTO cCod_retIB;
			RETURN cCodRet;		
		END IF;
		
		-- Valida que el cliente no tenga una credisolucion (pagos fijos) vigente.
		LET sContador = 0;
		SELECT count(num_credito) INTO sContador FROM bdicred:sd_promocion_credito WHERE num_credito = cNumCredito AND status IN (0,2);
		IF sContador > 0 THEN
			LET cMensajeRet = 'Credito con pagos fijos (credisolucion) vigente. ';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito, '02') Returning cCod_retIB;
			-- Envia mensaje sms de error generico.
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SDOVIGEN','000000000','','',1,'','','','','','','','','','','',pNumCel,0,0,0,0,0,current, current) INTO cCod_retIB;
			RETURN cCodRet;		
		END IF;

		-- Valida invitacion del cliente
		LET sContador = 0;
		SELECT count(num_credito) INTO sContador FROM bdicred:sd_promocion_credito_sms WHERE num_credito = cNumCredito AND num_promo in (3,6,9) AND tipo_sms in ('0','1','2','3');
		IF sContador > 1 THEN		-- Solo debe de contar con 1, que es la que esta respondiendo.
			LET cMensajeRet = 'Credito cuenta con mas de una invitacion de saldos. ';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito, '02') Returning cCod_retIB;
			-- Envia mensaje sms de error generico.
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SMSERR1','000000000','','',1,'','','','','','','','','','','',pNumCel,0,0,0,0,0,current, current) INTO cCod_retIB;
			-- Cancela invitaciones duplicadas de saldos.
			UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '9' WHERE num_credito = cNumCredito AND num_promo in (3,6,9) AND tipo_sms in ('0','1','2','3');
			RETURN cCodRet;		
		END IF;
		
		-- Obtiene folio de la invitacion.
		SELECT folio_compra_sms, mnto_compra, tipo_sms, num_promo,     plazo,  tasa,  plazos_invita,     tasas_invita,	   respuesta_cte_sms, sms_resp_inmd,  num_credisolucion
		  INTO cFolioSucGF,      dMontoSaldo, sTipoSms, sNumPromocion, sPlazo, sTasa, cPlazosInvitacion, cTasasInvitacion, cRepCte,		      cSmsRespInmEsp, cNumCredisolucion
		  FROM bdicred:sd_promocion_credito_sms WHERE num_credito = cNumCredito AND num_promo in (3,6,9) AND tipo_sms = '1';
		IF NVL(cFolioSucGF,'')= '' THEN		-- No tiene invitacion
			LET cMensajeRet = 'Credito no cuenta con invitacion de saldos. ';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito, '02') Returning cCod_retIB;
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SDONOINV','000000000','','',1,'','','','','','','','','','','',pNumCel,0,0,0,0,0,current, current) INTO cCod_retIB;
			RETURN cCodRet;		
		END IF;
		
		-- Obtiene el numero de tarjeta
		SELECT max(secuencia) INTO sSecuenciaTdc FROM bdicred:"informix".sd_tarjeta 
		 WHERE empresa = '001' AND num_credito = cNumCredito AND tipo_tarjeta = 'T' AND status_tar = 'A';
		SELECT first 1 num_tarjeta INTO cNumTarjeta FROM bdicred:"informix".sd_tarjeta 
		 WHERE empresa = '001' AND num_credito = cNumCredito AND tipo_tarjeta = 'T' AND status_tar = 'A' AND secuencia = sSecuenciaTdc;
		IF NVL(cNumTarjeta,'') = '' THEN
			LET cCodRet = '00000';
			LET cMensajeRet = 'Numero de Tarjeta invalido. ';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito||'-'||cFolioSucGF, '02') Returning cCod_retIB;
		END IF;
		
		IF sTipoSms = '1' THEN 				-- Procesa recepcion de invitacion ya que tipo_sms = '1' es invitacion enviada.
		
			-- Obtiene saldos del credito.
			SELECT sdo_capital,    (monto_otorgado - (sdo_cap_insoluto + sdo_retenido)), (sdo_cap_insoluto + sdo_retenido) 
			  INTO dcmCsg_cap_vig, dcmCsg_linea_disp,									 dcmCsg_tot_liquidacion
			  FROM bdicred:sd_maesdos WHERE num_credito = cNumCredito;			

			IF dMontoSaldo <> dcmCsg_cap_vig THEN 	-- Saldo de invitacion es diferente al saldo actual del credito. Se actualiza saldo deuda del credito.
				UPDATE bdicred:sd_promocion_credito_sms SET mnto_compra = dcmCsg_cap_vig WHERE num_credito = cNumCredito AND folio_compra_sms = cFolioSucGF;
				LET dMontoSaldo = dcmCsg_cap_vig;
			END IF;
		  
			IF NVL(sPlazo, 0) = 0 THEN		-- El campo plazo esta vacio, por lo tanto se obtiene plazo de respuesta del cliente.

				-- Valida que el plazo aceptado se encuentre dentro de las opciones enviadas dentro de la invitacion
				LET cTasa1 = substr(cTasasInvitacion,1,5);		LET cTasa2 = substr(cTasasInvitacion,7,5);		LET cTasa3 = substr(cTasasInvitacion, 13,5);	LET cTasa4 = substr(cTasasInvitacion, 19,5);
				LET cPlazo1 = substr(cPlazosInvitacion,1,2);	LET cPlazo2 = substr(cPlazosInvitacion,4,2);	LET cPlazo3 = substr(cPlazosInvitacion,7,2);	LET cPlazo4 = substr(cPlazosInvitacion,10,2);
				LET pplazo = pplazo;

				IF to_number(pPlazo) = to_number(cPlazo1) AND to_number(pPlazo) > 0 THEN
					LET sPlazo = cPlazo1::smallint;
					LET sTasa  = cTasa1::smallint;
				ELIF to_number(pPlazo) = to_number(cPlazo2) AND to_number(pPlazo) > 0 THEN
					LET sPlazo = cPlazo2::smallint;
					LET sTasa  = cTasa2::smallint;	
				ELIF to_number(pPlazo) = to_number(cPlazo3) AND to_number(pPlazo) > 0 THEN
					LET sPlazo = cPlazo3::smallint;
					LET sTasa  = cTasa3::smallint;		
				ELIF to_number(pPlazo) = to_number(cPlazo4) AND to_number(pPlazo) > 0 THEN
					LET sPlazo = cPlazo4::smallint;
					LET sTasa  = cTasa4::smallint;		
				ELSE		-- Manda mensaje de error, ya que envio un plazo no valido

					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_PLAZOER','000000000','', '',1, '', '', '', '', '', '', '','', '', '', '',pNumCel, 0, 0,0, 0, 0,current, current) INTO cCod_retIB;
					LET cCodRet = '00000';
					LET cMensajeRet = 'Plazo no valido';
					CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito||'-'||cFolioSucGF||'-'||pPlazo, '02') Returning cCod_retIB;
					RETURN cCodRet;
				END IF;		
			END IF;
			
			-- Proyecta para la promocion y plazo especificado a fin de validar que el saldo disponible lo cubra.
			--EXECUTE PROCEDURE bdicred:sp_proyecta_pfsms(1, cSucursal, USER, sNumPromocion, cNumCredito, cNumTarjeta, dMontoSaldo, sPlazo, sTasa, pfolio_suc) INTO
			EXECUTE PROCEDURE bdicred:sp_proyecta_pfsms(1, cSucursal, USER, sNumPromocion, cNumCredito, cNumTarjeta, dMontoSaldo, sPlazo, sTasa, '') INTO
					cCod_retIB, cMensajeRetAux, dTotPagar_proy, sPlazo_proy, dMensualidad2_proy, dIvaInt_proy, dSdoTdc_proy, cFolProm_proy, cNumProm_proy;

			IF cCod_retIB <> '00000' THEN	-- Rechazo de proyeccion para el plazo seleccionado.

				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SDOINSF','000000000','','',1,'','','','','','','','','','','',pNumCel,0,0,0,0,0,current, current) INTO cCod_retIB;
				LET cCodRet = '00000';
				LET cMensajeRet = 'Saldo no disponible para el plazo seleccionado.';
				CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCod_retIB, trim(cMensajeRet)||'-'||cNumCredito||'-'||cFolioSucGF||'-'||pPlazo, '02') Returning cCod_retIB;
				RETURN cCodRet;
			END IF

			-- Valida que el saldo disponible 
			IF dcmCsg_linea_disp < dIvaInt_proy THEN	--	 Si saldo disponible NO cubre proyeccion de credisolucion (monto int e iva).

				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SDOINSF','000000000','','',1,'','','','','','','','','','','',pNumCel,0,0,0,0,0,current, current) INTO cCod_retIB;
				LET cCodRet = '00000';
				LET cMensajeRet = 'Saldo no disponible para cubrir monto e iva';
				CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCod_retIB, trim(cMensajeRet)||'-'||cNumCredito||'-'||cFolioSucGF||'-'||pPlazo, '02') Returning cCod_retIB;
				RETURN cCodRet;
			END IF;

			-- Es viable para el plazo. Genera credisolucion con estatus 0.
			--EXECUTE PROCEDURE sp_proyecta_promo(3, cSucursal, 'informix', sNumPromocion, cNumCredito, '', dMontoSaldo, sPlazo, '')
			EXECUTE PROCEDURE sp_proyecta_pfsms(3, cSucursal, 'informix', sNumPromocion, cNumCredito, '', dMontoSaldo, sPlazo, sTasa, cFolioSucGF)
			   INTO cCod_retIB, cMensajeRet, dtotal_pagar_crds, dnum_plazo_crds, dpago_mensual_crds, dinteres_iva_crds, saldo_tdc_crds, dfolio_promo_crds, cNumProm_proy;

			IF cCod_retIB <> '00000' THEN

				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SMSERR1','000000000','','',1,'','','','','','','','','','','',pNumCel,0,0,0,0,0,current, current) INTO cCod_retIB;
				LET cCodRet = '00000';
				LET cMensajeRet = 'Error durante creacion de credisolucion: sp_proyecta_promo ';
				CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCod_retIB, trim(cMensajeRet)||'-'||cNumCredito||'-'||cFolioSucGF||'-'||cCod_retIB, '02') Returning cCod_retIB;
				
				UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '6', envio_result_sms = '0', status_envio_r_sms = '1', plazo = sPlazo, tasa = sTasa, 
															respuesta_cte_sms = 'S', fecha_resp_cte_sms = CURRENT, sms_resp_inmd = '1'
					 WHERE num_credito = cNumCredito AND folio_compra_sms = cFolioSucGF;

			END IF;	
			
			
			-- Credisolucion en este punto es de status = 0, no se ha generado credito 6900.
			UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '7', envio_result_sms = NULL, status_envio_r_sms = NULL, plazo = sPlazo, tasa = sTasa, 
														respuesta_cte_sms = 'S', fecha_resp_cte_sms = CURRENT, sms_resp_inmd = '1'
			 WHERE num_credito = cNumCredito AND folio_compra_sms = cFolioSucGF;
	
			 -- Envia sms de "en espera de confirmacion del estatus" al usuario (mensaje de respuesta inmediata)
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SMSESP','000000000','','',1,'','','','','','','','','','','',pNumCel,0,0,0,0,0,current,current) INTO cCod_retIB;			 


		ELIF NVL(sTipoSms,'') = '7' THEN -- Si esta en 7, no actualice y solo envie sms de respuesta inmediata

			IF NVL(cNumCredisolucion, '') = '' THEN 			-- Envia sms de respuesta inmediata.
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SMSESP','000000000','','',1,'','','','','','','','','','','',pNumCel,0,0,0,0,0,current,current) INTO cCod_retIB;
			ELSE
				SELECT monto_actual, mensualidad, plazo,  num_sol_prestamo 
				  INTO dMontoSaldo, sMensualidad, sPlazo, cNumCredisolucion
				  FROM bdicred:sd_promocion_credito WHERE status = 2 AND num_credito = cNumCredito AND folio_movto = cFolioSucGF;
				SELECT tasa_interes INTO sTasa FROM bdicred:sd_maecredcrd WHERE num_credito = cNumCredisolucion;
				LET cPlazoSMS = to_char(sPlazo);

				-- Existe credisolucion, envie sms de confirmacion
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SMSDO_OK','000000000','','',1,'',cPlazoSMS,'','','','','','','','','',pNumCel,dMontoSaldo,sMensualidad,0,sTasa,0,
																		current,current) INTO cCod_retIB;
																		
			END IF;
			
		ELIF NVL(sTipoSms,'') = '5' THEN -- Si esta en 5, ya fue cancelada por termino de vigencia.

			-- Envia sms de rechazo por vencimiento de vigencia de la invitacion.
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_INVNVIG','000000000','','',1,'','','','','','','','','','','',pNumCel,0,0,0,0,0,current,current) INTO cCod_retIB;

		ELSE		-- Cualquier otro tipo_sms, envie respuesta de error, ya que el cliente envio sms. No se actualiza: tipo_sms

			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SMSERR1','000000000','','',1,'','','','','','','','','','','',pNumCel,0,0,0,0,0,current,current) INTO cCod_retIB;

		END IF 
				
		
	ELIF pOpcion = 3 THEN	-- 3.- Envia SMS de error. (PF_SMSERR1)
	
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SMSERR1','000000000','','',sSmsBatchOnline,'','','','','','','','','','','',pNumCel,0,0,0,0,0,current,current) INTO cCod_retIB;
		UPDATE bdicred:sd_promocion_credito_sms SET envio_result_sms = '0', status_envio_r_sms = '1' WHERE num_credito = cNumCredito AND folio_compra_sms = pFolio;


	ELIF pOpcion = 4 THEN	-- 4.- Envia SMS de contratacion correcta a pagos fijos (PF_SMSDO_OK)

		SELECT num_credisolucion INTO cNumCredisolucion FROM bdicred:sd_promocion_credito_sms WHERE num_credito = cNumCredito AND folio_compra_sms = pFolio;
	
		SELECT monto_actual, mensualidad, plazo INTO dMontoSaldo, sMensualidad, sPlazo
		  FROM bdicred:sd_promocion_credito WHERE status = 2 AND num_credito = cNumCredito AND num_sol_prestamo = cNumCredisolucion;		  
		SELECT tasa_interes INTO sTasa FROM bdicred:sd_maecredcrd WHERE num_credito = cNumCredisolucion;
		LET cPlazoSMS = to_char(sPlazo);

		IF nvl(cNumCredisolucion,'') <> '' THEN
		
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SMSDO_OK','000000000','','',sSmsBatchOnline,'',cPlazoSMS,'','','','','','','','','',pNumCel,dMontoSaldo,sMensualidad,0,sTasa,0,
																		current,current) INTO cCod_retIB;

			UPDATE bdicred:sd_promocion_credito_sms SET envio_result_sms = '1', status_envio_r_sms = '1', num_credisolucion = cNumCredisolucion	WHERE num_credito = cNumCredito AND folio_compra_sms = pFolio;		

		END IF;
		
	ELIF pOpcion = 5 THEN	-- 5.- Realiza Cancelacion de Pagos Fijos Saldo Inmediato ("CANCELAR SALDO"). Cancela invitacion sms o Credito 6900 dependiendo.

		SELECT first 1 nvl(telefono,'0'), nvl(numcte, '') INTO cNumCel, cNumCte FROM bdinteg:si_telefonos WHERE telefono = pNumCel;
		IF cNumCel = '0' OR cNumCte = '' THEN
			LET cCodRet = '00000';
			LET cMensajeRet = 'Telefono no registrado.';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito||'-'||pNumCel, '02') Returning cCod_retIB;
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1,'SMS_RECI','PF_CINTELER','000000000','', '',1, '', '', '', '', '', '', '','', '', '', '',pNumCel, 0, 0, 0, 0, 0, current, current) INTO cCod_retIB;
			RETURN cCodRet;			
		END IF;	
		
		-- Obtiene el numero de credito ligado al telefono.
		SELECT nvl(b.num_credito,''), b.fecha_apertura, b.sucursal, b.status_cred
		  INTO cNumCredito          , dFecha_Apertura , cSucursal ,  cStatusCred
		  FROM bdicred:sd_maecred b
          INNER JOIN bdicred:sd_maesdos e ON (b.num_credito = e.num_credito AND (e.monto_vencido + e.mto_venc_trasp) = 0)
          INNER JOIN bdicred:sd_definicion d ON (b.num_producto = d.num_producto and d.edocta_param = 'tdc' )
		 WHERE b.numcte = cNumCte
		 AND b.status_cred IN ('AA','E1');
		 
		IF cNumCredito = '' THEN
			LET cCodRet = '00000';
			LET cMensajeRet = 'Telefono no registrado a un credito TDC.';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito||'-'||pNumCel, '02') Returning cCod_retIB;
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1,'SMS_RECI','PF_CINTELER','000000000','', '',1, '', '', '', '', '', '', '',
						'', '', '', '',pNumCel, 0, 0, 0, 0, 0, current, current) INTO cCod_retIB;
			RETURN cCodRet;
		END IF;
		
		-- Identifica contratacion inmediata a cancelar
		SELECT MAX(fecha_invitacion) INTO dFechaInvita 
		  FROM bdicred:sd_promocion_credito_sms WHERE num_credito = cNumCredito AND num_promo IN (3,6,9) AND tipo_contrato = '3';
		IF dFechaInvita IS NULL THEN LET dFechaInvita = date(1); END IF;
		IF dFechaInvita = date(1) THEN
			-- Cliente no cuenta con contrataciones inmediatas realizadas para saldo.
			LET cCodRet = '00000';
			LET cMensajeRet = 'Cliente no cuenta con invitaciones.';			
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito||'-'||pNumCel, '02') Returning cCod_retIB;
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1,'SMS_RECI','PF_SINNOCAN','000000000','', '',1, '', '', '', '', '', '', '','', '', '', '',pNumCel, 0, 0, 0, 0, 0, current, current) INTO cCod_retIB;
			RETURN cCodRet;
		END IF;
		
		-- Verifica cambio de fechas vs fecha proceso de tdc. Si son diferentes = esta corriendo cierre, aun no cambia fecha y solicita cancelacion
		Select fecha_proceso INTO sFecha_ProcesoTdc FROM bdicred:sd_maecredanexo WHERE num_credito = cNumCredito;
		IF sFecha_ProcesoTdc != dtFechaHoy THEN	-- No cancele si no ha habido cambio de fecha
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1,'SMS_RECI','PPF_SMS_APHR','000000000','', '',1, '', '', '', '', '', '', '', '', '', '', '',pNumCel, 0, 0,0, 0, 0, current, current) INTO cCod_retIB;			
			LET cCodRet = '00000';
			RETURN cCodRet;
		END IF;
		
		-- Obtiene status de invitacion
		SELECT tipo_sms, folio_compra_sms, num_credisolucion INTO sTipoSms, dfolio_promo_crds, cNum_Credisol
		  FROM bdicred:sd_promocion_credito_sms WHERE num_credito = cNumCredito AND num_promo IN (3,6,9) AND tipo_contrato = '3' AND fecha_invitacion = dFechaInvita;
		 
		-- Identifica el tipo de bloqueo del credito
		SELECT id_unidad_prod INTO Id_Bloqueo FROM bdicred:sd_maecred WHERE num_credito = cNumCredito;		

		-- Cancela credisoluciones. Registro y credito si existe
		IF cNum_Credisol IS NULL THEN LET cNum_Credisol = ''; END IF;	

		-- Cancela el status de la credisolucion. Detiene proceso de crear credito 6900
		IF sTipoSms = '7' AND cNum_Credisol = '' THEN	

			SELECT status, monto_int_iva, folio_movto INTO sSatusCredisol, dMonto_RetDiferido, dfolio_movto_crds
 			  FROM bdicred:sd_promocion_credito WHERE num_credito = cNumCredito AND status = 0 AND num_promo IN (3,6,9);		

			IF sSatusCredisol = 0 THEN
				
				UPDATE bdicred:sd_promocion_credito SET status = 7 
				WHERE num_credito = cNumCredito AND status = 0 AND num_promo IN (3,6,9) AND folio_movto = dfolio_movto_crds;		
				
				-- Libera el saldo retenido del monto int e iva diferido
				UPDATE bdicred:"informix".sd_maeretenido SET estatus = "S"
				 WHERE empresa = '001' AND num_credito = cNumCredito AND folio_suc = dfolio_movto_crds AND estatus = "R";
				
				UPDATE bdicred:"informix".sd_maesdos SET sdo_retenido = sdo_retenido - dMonto_RetDiferido
				 WHERE num_credito = cNumCredito;
				
				UPDATE bdicred:"informix".sd_movdia SET reversado = "S"
				 WHERE empresa = '001' AND num_credito = cNumCredito AND folio_suc = dfolio_movto_crds AND codigo_fun = '002' AND codigo_ref = 45;  				
				
			END IF;
		END IF;

		-- Se cancela credito 6900
		IF sTipoSms = '7' AND cNum_Credisol != '' THEN	
		
			SELECT folio_movto, sucursal INTO cFolio_Credisol, cSucursal FROM bdicred:sd_promocion_credito WHERE num_sol_prestamo = cNum_Credisol;
		
			EXECUTE PROCEDURE "informix".sp_credisoluciones_revol('001', cFolio_Credisol, cSucursal, "informix") INTO cCod_retIB, cMensajeRetAux;
			IF cCod_retIB::INTEGER != 0 THEN
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1,'SMS_RECI','PF_CINCANOK','000000000','', '',1, '', '', '', '', '', '', '','', '', '', '',pNumCel, 0, 0, 0, 0, 0, current, current) INTO cCod_retIB;
			RETURN cCodRet;	
			END IF;
			
		END IF;
		
		-- Invitaciones pendientes de procesar. Se cancela la invitacion.
		IF sTipoSms IN ('0','1','2','3','7') THEN		
			UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '5', respuesta_cte_sms = 'N', fecha_resp_cte_sms = CURRENT, fecha_cancela = dtFechaHoy, compra_inmd = '1'
			 WHERE num_credito = cNumCredito AND folio_compra_sms = dfolio_promo_crds AND fecha_invitacion = dFechaInvita AND tipo_contrato = '3';
		END IF;	
		
		-- Elimina el bloqueo del credito en caso de tenerlo
		IF Id_Bloqueo = 2 THEN
			UPDATE bdicred:sd_maecred SET id_unidad_prod = NULL WHERE num_credito = cNumCredito;		
		END IF;	
		
		-- Envia mensaje de cancelacion exitosa
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1,'SMS_RECI','PF_SINMCNOK','000000000','', '',1, '', '', '', '', '', '', '','', '', '', '',pNumCel, 0, 0, 0, 0, 0, current, current) INTO cCod_retIB;		
		
	ELIF pOpcion = 6 THEN	-- 6.- Realiza Cancelacion de Pagos Fijos Saldo Inmediato ("CANCELAR INVITACION SALDO"). Cancela invitacion sms
	
		SELECT first 1 nvl(telefono,'0'), nvl(numcte, '') INTO cNumCel, cNumCte FROM bdinteg:si_telefonos WHERE telefono = pNumCel;
		IF cNumCel = '0' OR cNumCte = '' THEN
			LET cCodRet = '00000';
			LET cMensajeRet = 'Telefono no registrado.';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito||'-'||pNumCel, '02') Returning cCod_retIB;
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1,'SMS_RECI','PF_CINTELER','000000000','', '',1, '', '', '', '', '', '', '','', '', '', '',pNumCel, 0, 0, 0, 0, 0, current, current) INTO cCod_retIB;
			RETURN cCodRet;			
		END IF;
		
		IF cNumCredito = '' THEN
			LET cCodRet = '00000';
			LET cMensajeRet = 'Telefono no registrado a un credito TDC.';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito||'-'||pNumCel, '02') Returning cCod_retIB;
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1,'SMS_RECI','PF_CINTELER','000000000','', '',1, '', '', '', '', '', '', '',
						'', '', '', '',pNumCel, 0, 0, 0, 0, 0, current, current) INTO cCod_retIB;
			RETURN cCodRet;
		END IF;
		
		-- Identifica contratacion inmediata a cancelar
		SELECT MAX(fecha_invitacion) INTO dFechaInvita 
		  FROM bdicred:sd_promocion_credito_sms WHERE num_credito = cNumCredito AND num_promo IN (3,6,9) AND NVL(tipo_contrato, '') != '3';
		IF dFechaInvita IS NULL THEN LET dFechaInvita = date(1); END IF;
		IF dFechaInvita = date(1) THEN
			-- Cliente no cuenta con contrataciones inmediatas realizadas para saldo.
			LET cCodRet = '00000';
			LET cMensajeRet = 'Cliente no cuenta con invitaciones.';			
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito||'-'||pNumCel, '02') Returning cCod_retIB;
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1,'SMS_RECI','PF_SINNOCAN','000000000','', '',1, '', '', '', '', '', '', '','', '', '', '',pNumCel, 0, 0, 0, 0, 0, current, current) INTO cCod_retIB;
			RETURN cCodRet;
		END IF;
		
		-- Verifica cambio de fechas vs fecha proceso de tdc. Si son diferentes = esta corriendo cierre, aun no cambia fecha y solicita cancelacion
		Select fecha_proceso INTO sFecha_ProcesoTdc FROM bdicred:sd_maecredanexo WHERE num_credito = cNumCredito;
		IF sFecha_ProcesoTdc != dtFechaHoy THEN	-- No cancele si no ha habido cambio de fecha
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1,'SMS_RECI','PPF_SMS_APHR','000000000','', '',1, '', '', '', '', '', '', '', '', '', '', '',pNumCel, 0, 0,0, 0, 0, current, current) INTO cCod_retIB;			
			LET cCodRet = '00000';
			RETURN cCodRet;
		END IF;
		
		-- Obtiene status de invitacion
		SELECT tipo_sms, folio_compra_sms, num_credisolucion INTO sTipoSms, dfolio_promo_crds, cNum_Credisol
		  FROM bdicred:sd_promocion_credito_sms WHERE num_credito = cNumCredito AND num_promo IN (3,6,9) AND NVL(tipo_contrato, '') != '3' AND fecha_invitacion = dFechaInvita;
		  
		-- Cancela el status de Pagos Fijos. Detiene proceso de crear credito 6900
		IF sTipoSms = '7' AND cNum_Credisol = '' THEN	

			SELECT status, monto_int_iva, folio_movto INTO sSatusCredisol, dMonto_RetDiferido, dfolio_movto_crds
 			  FROM bdicred:sd_promocion_credito WHERE num_credito = cNumCredito AND status = 0 AND num_promo IN (3,6,9);		

			IF sSatusCredisol = 0 THEN
				
				UPDATE bdicred:sd_promocion_credito SET status = 7 
				WHERE num_credito = cNumCredito AND status = 0 AND num_promo IN (3,6,9) AND folio_movto = dfolio_movto_crds;		
				
				-- Libera el saldo retenido del monto int e iva diferido
				UPDATE bdicred:"informix".sd_maeretenido SET estatus = "S"
				 WHERE empresa = '001' AND num_credito = cNumCredito AND folio_suc = dfolio_movto_crds AND estatus = "R";
				
				UPDATE bdicred:"informix".sd_maesdos SET sdo_retenido = sdo_retenido - dMonto_RetDiferido
				 WHERE num_credito = cNumCredito;
				
				UPDATE bdicred:"informix".sd_movdia SET reversado = "S"
				 WHERE empresa = '001' AND num_credito = cNumCredito AND folio_suc = dfolio_movto_crds AND codigo_fun = '002' AND codigo_ref = 45;  				
				
			END IF;
		END IF;
		
		-- Invitaciones pendientes de procesar. Se cancela la invitacion.
		IF sTipoSms IN ('0','1','2','3','7') THEN		
			UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '5', respuesta_cte_sms = 'N', fecha_resp_cte_sms = CURRENT, fecha_cancela = dtFechaHoy, compra_inmd = '1'
			 WHERE num_credito = cNumCredito AND folio_compra_sms = dfolio_promo_crds AND fecha_invitacion = dFechaInvita AND NVL(tipo_contrato, '') != '3';
		END IF;
		
		-- Envia mensaje de cancelacion exitosa
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (1,'SMS_RECI','PF_SINMCNOK','000000000','', '',1, '', '', '', '', '', '', '','', '', '', '',pNumCel, 0, 0, 0, 0, 0, current, current) INTO cCod_retIB;
		
	ELIF pOpcion = 7 THEN -- Recibe respuesta de cliente con palabra PAGOSFIJOS + SALDO + plazo
	
		IF cStatusCred NOT IN ('AA','E1') AND cMtoVen > 0 THEN
			LET cMensajeRet = 'Credito en estatus diferente a vigente. ';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito||'-'||cStatusCred||'-'||pNumCel, '02') Returning cCod_retIB;
			-- Envia mensaje sms de error generico.
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SDOSTAER','000000000','','',1,'','','','','','','','','','','',pNumCel,0,0,0,0,0,current, current) INTO cCod_retIB;
			RETURN cCodRet;		
		END IF;
		
		-- Valida que el cliente no tenga una credisolucion (pagos fijos) vigente.
		LET sContador = 0;
		SELECT count(num_credito) INTO sContador FROM bdicred:sd_promocion_credito WHERE num_credito = cNumCredito AND status IN (0,2);
		IF sContador > 0 THEN
			LET cMensajeRet = 'Credito con pagos fijos (credisolucion) vigente. ';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito, '02') Returning cCod_retIB;
			-- Envia mensaje sms de error generico.
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SDOVIGEN','000000000','','',1,'','','','','','','','','','','',pNumCel,0,0,0,0,0,current, current) INTO cCod_retIB;
			RETURN cCodRet;		
		END IF;

		-- Valida invitacion del cliente
		LET sContador = 0;
		SELECT count(num_credito) INTO sContador FROM bdicred:sd_promocion_credito_sms WHERE num_credito = cNumCredito AND num_promo in (3,6,9) AND tipo_sms in ('0','1','2','3');
		IF sContador > 1 THEN		-- Solo debe de contar con 1, que es la que esta respondiendo.
			LET cMensajeRet = 'Credito cuenta con mas de una invitacion de saldos. ';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito, '02') Returning cCod_retIB;
			-- Envia mensaje sms de error generico.
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SMSERR1','000000000','','',1,'','','','','','','','','','','',pNumCel,0,0,0,0,0,current, current) INTO cCod_retIB;
			-- Cancela invitaciones duplicadas de saldos.
			UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '9' WHERE num_credito = cNumCredito AND num_promo in (3,6,9) AND tipo_sms in ('0','1','2','3');
			RETURN cCodRet;		
		END IF;
		
		-- Obtiene folio de la invitacion.
		SELECT folio_compra_sms, mnto_compra, tipo_sms, num_promo,     plazo,  tasa,  plazos_invita,     tasas_invita,	   respuesta_cte_sms, sms_resp_inmd,  num_credisolucion
		  INTO cFolioSucGF,      dMontoSaldo, sTipoSms, sNumPromocion, sPlazo, sTasa, cPlazosInvitacion, cTasasInvitacion, cRepCte,		      cSmsRespInmEsp, cNumCredisolucion
		  FROM bdicred:sd_promocion_credito_sms WHERE num_credito = cNumCredito AND num_promo in (3,6,9) AND tipo_sms = '1';
		IF NVL(cFolioSucGF,'')= '' THEN		-- No tiene invitacion
			LET cMensajeRet = 'Credito no cuenta con invitacion de saldos. ';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito, '02') Returning cCod_retIB;
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SDONOINV','000000000','','',1,'','','','','','','','','','','',pNumCel,0,0,0,0,0,current, current) INTO cCod_retIB;
			RETURN cCodRet;		
		END IF;
		
		-- Obtiene el numero de tarjeta
		SELECT max(secuencia) INTO sSecuenciaTdc FROM bdicred:"informix".sd_tarjeta 
		 WHERE empresa = '001' AND num_credito = cNumCredito AND tipo_tarjeta = 'T' AND status_tar = 'A';
		SELECT first 1 num_tarjeta INTO cNumTarjeta FROM bdicred:"informix".sd_tarjeta 
		 WHERE empresa = '001' AND num_credito = cNumCredito AND tipo_tarjeta = 'T' AND status_tar = 'A' AND secuencia = sSecuenciaTdc;
		IF NVL(cNumTarjeta,'') = '' THEN
			LET cCodRet = '00000';
			LET cMensajeRet = 'Numero de Tarjeta invalido. ';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito||'-'||cFolioSucGF, '02') Returning cCod_retIB;
		END IF;
		
		IF sTipoSms = '1' THEN 				-- Procesa recepcion de invitacion ya que tipo_sms = '1' es invitacion enviada.
		
			-- Obtiene saldos del credito.
			SELECT sdo_capital,    (monto_otorgado - (sdo_cap_insoluto + sdo_retenido)), (sdo_cap_insoluto + sdo_retenido) 
			  INTO dcmCsg_cap_vig, dcmCsg_linea_disp,									 dcmCsg_tot_liquidacion
			  FROM bdicred:sd_maesdos WHERE num_credito = cNumCredito;			

			IF dMontoSaldo <> dcmCsg_cap_vig THEN 	-- Saldo de invitacion es diferente al saldo actual del credito. Se actualiza saldo deuda del credito.
				UPDATE bdicred:sd_promocion_credito_sms SET mnto_compra = dcmCsg_cap_vig WHERE num_credito = cNumCredito AND folio_compra_sms = cFolioSucGF;
				LET dMontoSaldo = dcmCsg_cap_vig;
			END IF;
		  
			IF NVL(sPlazo, 0) = 0 THEN		-- El campo plazo esta vacio, por lo tanto se obtiene plazo de respuesta del cliente.

				-- Valida que el plazo aceptado se encuentre dentro de las opciones enviadas dentro de la invitacion
				LET cTasa1 = substr(cTasasInvitacion,1,5);		LET cTasa2 = substr(cTasasInvitacion,7,5);		LET cTasa3 = substr(cTasasInvitacion, 13,5);	LET cTasa4 = substr(cTasasInvitacion, 19,5);
				LET cPlazo1 = substr(cPlazosInvitacion,1,2);	LET cPlazo2 = substr(cPlazosInvitacion,4,2);	LET cPlazo3 = substr(cPlazosInvitacion,7,2);	LET cPlazo4 = substr(cPlazosInvitacion,10,2);
				LET pplazo = pplazo;

				IF to_number(pPlazo) = to_number(cPlazo1) AND to_number(pPlazo) > 0 THEN
					LET sPlazo = cPlazo1::smallint;
					LET sTasa  = cTasa1::smallint;
				ELIF to_number(pPlazo) = to_number(cPlazo2) AND to_number(pPlazo) > 0 THEN
					LET sPlazo = cPlazo2::smallint;
					LET sTasa  = cTasa2::smallint;	
				ELIF to_number(pPlazo) = to_number(cPlazo3) AND to_number(pPlazo) > 0 THEN
					LET sPlazo = cPlazo3::smallint;
					LET sTasa  = cTasa3::smallint;		
				ELIF to_number(pPlazo) = to_number(cPlazo4) AND to_number(pPlazo) > 0 THEN
					LET sPlazo = cPlazo4::smallint;
					LET sTasa  = cTasa4::smallint;		
				ELSE		-- Manda mensaje de error, ya que envio un plazo no valido

					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_PLAZOER','000000000','', '',1, '', '', '', '', '', '', '','', '', '', '',pNumCel, 0, 0,0, 0, 0,current, current) INTO cCod_retIB;
					LET cCodRet = '00000';
					LET cMensajeRet = 'Plazo no valido';
					CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito||'-'||cFolioSucGF||'-'||pPlazo, '02') Returning cCod_retIB;
					RETURN cCodRet;
				END IF;		
			END IF;
			
			-- Proyecta para la promocion y plazo especificado a fin de validar que el saldo disponible lo cubra.
			--EXECUTE PROCEDURE bdicred:sp_proyecta_pfsms(1, cSucursal, USER, sNumPromocion, cNumCredito, cNumTarjeta, dMontoSaldo, sPlazo, sTasa, pfolio_suc) INTO
			EXECUTE PROCEDURE bdicred:sp_proyecta_pfsms(1, cSucursal, USER, sNumPromocion, cNumCredito, cNumTarjeta, dMontoSaldo, sPlazo, sTasa, '') INTO
					cCod_retIB, cMensajeRetAux, dTotPagar_proy, sPlazo_proy, dMensualidad2_proy, dIvaInt_proy, dSdoTdc_proy, cFolProm_proy, cNumProm_proy;

			IF cCod_retIB <> '00000' THEN	-- Rechazo de proyeccion para el plazo seleccionado.

				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SDOINSF','000000000','','',1,'','','','','','','','','','','',pNumCel,0,0,0,0,0,current, current) INTO cCod_retIB;
				LET cCodRet = '00000';
				LET cMensajeRet = 'Saldo no disponible para el plazo seleccionado.';
				CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCod_retIB, trim(cMensajeRet)||'-'||cNumCredito||'-'||cFolioSucGF||'-'||pPlazo, '02') Returning cCod_retIB;
				RETURN cCodRet;
			END IF

			-- Valida que el saldo disponible 
			IF dcmCsg_linea_disp < dIvaInt_proy THEN	--	 Si saldo disponible NO cubre proyeccion de credisolucion (monto int e iva).

				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SDOINSF','000000000','','',1,'','','','','','','','','','','',pNumCel,0,0,0,0,0,current, current) INTO cCod_retIB;
				LET cCodRet = '00000';
				LET cMensajeRet = 'Saldo no disponible para cubrir monto e iva';
				CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCod_retIB, trim(cMensajeRet)||'-'||cNumCredito||'-'||cFolioSucGF||'-'||pPlazo, '02') Returning cCod_retIB;
				RETURN cCodRet;
			END IF;

			-- Es viable para el plazo. Genera credisolucion con estatus 0.
			--EXECUTE PROCEDURE sp_proyecta_promo(3, cSucursal, 'informix', sNumPromocion, cNumCredito, '', dMontoSaldo, sPlazo, '')
			EXECUTE PROCEDURE sp_proyecta_pfsms(3, cSucursal, 'informix', sNumPromocion, cNumCredito, '', dMontoSaldo, sPlazo, sTasa, cFolioSucGF)
			   INTO cCod_retIB, cMensajeRet, dtotal_pagar_crds, dnum_plazo_crds, dpago_mensual_crds, dinteres_iva_crds, saldo_tdc_crds, dfolio_promo_crds, cNumProm_proy;

			IF cCod_retIB <> '00000' THEN

				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SMSERR1','000000000','','',1,'','','','','','','','','','','',pNumCel,0,0,0,0,0,current, current) INTO cCod_retIB;
				LET cCodRet = '00000';
				LET cMensajeRet = 'Error durante creacion de credisolucion: sp_proyecta_promo ';
				CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCod_retIB, trim(cMensajeRet)||'-'||cNumCredito||'-'||cFolioSucGF||'-'||cCod_retIB, '02') Returning cCod_retIB;
				
				UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '6', envio_result_sms = '0', status_envio_r_sms = '1', plazo = sPlazo, tasa = sTasa, 
															respuesta_cte_sms = 'S', fecha_resp_cte_sms = CURRENT, sms_resp_inmd = '1'
					 WHERE num_credito = cNumCredito AND folio_compra_sms = cFolioSucGF;

			END IF;	
			
			
			-- Credisolucion en este punto es de status = 0, no se ha generado credito 6900.
			UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '7', envio_result_sms = NULL, status_envio_r_sms = NULL, plazo = sPlazo, tasa = sTasa, 
														respuesta_cte_sms = 'S', fecha_resp_cte_sms = CURRENT, sms_resp_inmd = '1'
			 WHERE num_credito = cNumCredito AND folio_compra_sms = cFolioSucGF;
	
			 -- Envia sms de "en espera de confirmacion del estatus" al usuario (mensaje de respuesta inmediata)
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SMSESP','000000000','','',1,'','','','','','','','','','','',pNumCel,0,0,0,0,0,current,current) INTO cCod_retIB;			 


		ELIF NVL(sTipoSms,'') = '7' THEN -- Si esta en 7, no actualice y solo envie sms de respuesta inmediata

			IF NVL(cNumCredisolucion, '') = '' THEN 			-- Envia sms de respuesta inmediata.
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SMSESP','000000000','','',1,'','','','','','','','','','','',pNumCel,0,0,0,0,0,current,current) INTO cCod_retIB;
			ELSE
				SELECT monto_actual, mensualidad, plazo,  num_sol_prestamo 
				  INTO dMontoSaldo, sMensualidad, sPlazo, cNumCredisolucion
				  FROM bdicred:sd_promocion_credito WHERE status = 2 AND num_credito = cNumCredito AND folio_movto = cFolioSucGF;
				SELECT tasa_interes INTO sTasa FROM bdicred:sd_maecredcrd WHERE num_credito = cNumCredisolucion;
				LET cPlazoSMS = to_char(sPlazo);

				-- Existe credisolucion, envie sms de confirmacion
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SMSDO_OK','000000000','','',1,'',cPlazoSMS,'','','','','','','','','',pNumCel,dMontoSaldo,sMensualidad,0,sTasa,0,
																		current,current) INTO cCod_retIB;
																		
			END IF;
			
		ELIF NVL(sTipoSms,'') = '5' THEN -- Si esta en 5, ya fue cancelada por termino de vigencia.

			-- Envia sms de rechazo por vencimiento de vigencia de la invitacion.
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_INVNVIG','000000000','','',1,'','','','','','','','','','','',pNumCel,0,0,0,0,0,current,current) INTO cCod_retIB;

		ELSE		-- Cualquier otro tipo_sms, envie respuesta de error, ya que el cliente envio sms. No se actualiza: tipo_sms

			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SMSERR1','000000000','','',1,'','','','','','','','','','','',pNumCel,0,0,0,0,0,current,current) INTO cCod_retIB;

		END IF 
	END IF;

	RETURN cCodRet;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso que realiza el envio y recepciÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ³n de SMS para la contratacion de Pagos Fijos Saldo. ',
'AUTOR: MAHR ',
'FECHA DE CREACION:  Enero 2019 ',
'BD: bdicred',
' tipo_sms: 0 Invitacion pendiente por enviar, 1 Invitacion realizada, 2 Espera conciliacion, 3 Conciliacion recibida, 4 Invit cancelada ERROR Dato Erroneo, ',
'		    5 Invitacion Cancelada X vigencia, 6 Err en credisolucion, 7 SMS con credisolucion, 8 Invitacion no enviada (0 cancelado), 9 Cancelado invitaciones de saldo duplicadas	';

CREATE PROCEDURE "informix".sp_rep_regulatorios_irb(pEmpresa char(03))
returning 
          char(06) as resultado,
          char(80) as mensaje;
		  
--EXECUTE PROCEDURE "informix".sp_rep_regulatorios_irb('001');

--************************ Definicion de variables *****************************
DEFINE cMensajeRet, cMensajeRet2     CHAR(80);

define iCodRet,isam_err    	integer;
define error_info			char(80);
define SCodRet              char(06);
define cSql                 char(5000);
define vfecha_hoy           DATE;
define cont                 integer;
define vFecha_proceso       DATE;
define vhora_inicio         char(8);
define vhora_fin            char(8);
define vstatus_proceso      char(2);
define NombreArchivo        char(50);
define NombreArchivoCifras  char(50);
define pFechaReporte         date;
define PrimerDiaMes         date;
define UltimoDiaMes         date;
define vDia,v_mes_corte     char(2);
define vMes,v_mes_appdate   char(2);
define vAnio                char(4);

define cNumCliente          char(20);
define cNumCredito          char(20);
define dFechaApertura       date;
define sMesesVencidos       smallint;
define cStatusCredito       char(02);
define dPagoMinimo          dec(18,2);
define dSaldoCorte          dec(18,2);
define dSdoDisponible       dec(18,2);
define dFechaLimitePago     date;
define dFechaCorte          date;
define dPagosPAYMENTS       dec(18,2);
define dComprasPURCHASES    dec(18,2);
define dDispWITHDRAWALS     dec(18,2);
define dIntereses           dec(18,2);
define dMOB                 dec(18,2);
define dLimiteCredito       dec(18,2);
define dTasa                dec(9,6);
define v_tasa               dec(5,2);
define dFecha               date;
define dSdoCorteAnt         dec(18,2);
define dIva                 dec(18,2);
define iNumDispCASHATM      dec(18,2);
define iNumPagosPAYMENTS    dec(18,2);
define iNumCompPURCHASES    dec(18,2);
define iImpComisiones       dec(18,2);
define dFechaIni            date;

define cApplicationId      char(20);
define cApplicationDate    char(08);
define cApplicationStatus  char(02);
define dRequestedAmount    decimal(18,2);
define cTerm               char(01);
define cDownPayment        char(10);
define cPostalCode         char(05);
define cPostalCode4        char(05);
define cLastName           char(50);
define cFirstName          char(50);
define cMiddleName         char(50);
define cNameSuffix         char(01);
define cCharacterBlanks    char(01);
define cHouseNumber        char(10);
define cNombreZona         char(50);
define cThoroughfareName   char(50);
define cThoroughfareType   char(01);
define cApartmentNumber    char(10);
define cCityName           char(50);
define cGender             char(06);
define cAge                char(03);
define cJobType            char(50);
define cTelephone          char(15);
define cPresenceCknSvn     char(01);
define cTimeResidence      char(03);
define cTimeJob            char(03);
define dMonthlyIncome      decimal(18,2);
define dMonthlyExpense     char(12);   
define cNumberDependents   char(03);
define cNumberPeopleHouse  char(03);
define cYearlyHouseIncome  char(10);
define cNumberDebtObli     char(03);
define cNumberPrevLoansBank char(02);
define cState               char(50);
define cTypeResidence	   char(15);
define sYearsCreditExp	   smallint;
define cnumerociudad	   smallint;

define v_term, v_name_suffix, v_character_blanks, v_presence_ckn_svn, v_thoroughfare_type                char(01);
define v_application_status, v_number_prev_loans_bank                                                    char(02);
define v_age, v_time_residence,v_time_job,v_number_dependents,v_number_people_house, v_number_debt_obli  char(03);
define v_postal_code, v_postal_code4                                                                     char(05);
define v_gender                                                                                          char(06);
define v_application_date                                                                                char(08);
define v_down_payment, v_apartment_number, v_house_number, v_yearly_house_income                         char(10);
define v_monthly_expense                                                                                 char(12);
define v_type_residence, v_telephone                                                                     char(15);
define v_application_id                                                                                  char(20);
define v_last_name, v_first_name, v_middle_name, v_nombrezona, v_thoroughfare_name, v_city_name, v_state char(50);
define v_job_type                                                                                        char(50);
define v_monthly_income, v_requested_amount                                                              decimal(18,2);
define v_years_credit_exp                                                                                smallint;

define v_status_credito                                                                                  char(15);
define v_numcte, v_num_credito                                                                           char(20);
define v_fecha_apertura, v_fecha_limite_pago, v_fecha_corte                                              date;
define v_meses_vencidos, v_pago_minimo, v_saldo_corte, v_sdo_disponible, v_sdo_corte_anterior, v_pagos_PAYMENTS, v_compras_PURCHASES  decimal(18,2);
define v_disposiciones_WITHDRAWALS, v_intereses, v_iva, v_rendimientos, v_comisiones, v_MOB, v_limite_credito                         decimal(18,2);
define v_numero_disposiciones_CASH_ATM, v_numero_pagos_PAYMENTS, v_numero_compras_PURCHASES              integer;

define vNumproceso            char(4);                  
define vCurrent               char(25);
define vdia2                  date; 
define vHora,vHora_2          char(8);
define v_fecha_emision        date;  
define v_num_solicitud        char(20);
define v_fecha_insert, v_fecha_nac, v_fechacorte_actual, v_fecha_finmesant         date;
define cNumCte          char(20);
define dMesesVencidos   decimal(18,2);
define dDisposicionesWithdrawals decimal(18,2);
define dFechaEmision      date;
define dSdoCorteAnterior decimal(18,2);
define iNumeroDisposicionesCashATM integer;
define iNumeroPagosPayments integer;
define iNumeroComprasPurchases integer;
define dComisiones      decimal(18,2);
define dRendimientos    decimal(18,2);
define vFechaappdate    date;
define vfechareporte  date;
define cFechaappdate  char(8);   

-----------------------------------------------------------------------------
DEFINE bandera1 					CHAR(20);
DEFINE bandera2 					CHAR(20);
DEFINE v1_num_solicitud 			CHAR(20);
DEFINE v1_numcte 					CHAR(20);
DEFINE v1_sdo_actual 				DECIMAL(14,2);
DEFINE v1_sdo_vencido 				DECIMAL(14,2);
DEFINE v1_int_vencido 				DECIMAL(14,2);
DEFINE v1_iva_int_vencido 			DECIMAL(14,2);
DEFINE v1_int_mora_ordi 			DECIMAL(14,2);
DEFINE v1_iva_int_mora_ordi 		DECIMAL(14,2);
DEFINE v1_int_mora_cope 			DECIMAL(14,2);
DEFINE v1_iva_int_mora_cope 		DECIMAL(14,2);
DEFINE v1_meses_vencidos 			INTEGER;
DEFINE v1_fecha 					DATE;
DEFINE v1_situacion 				CHAR(06);
-----------------------------------------------------------------------------

let vNumproceso    = '0053';
let v_term         = '';   let v_name_suffix       = '';  let v_character_blanks    = '';   let v_presence_ckn_svn = '';   let v_thoroughfare_type = '';
let v_mes_corte    = '';   let v_age               = '';  let v_time_residence      = '';   let v_number_debt_obli = '';   let v_postal_code       = '';
let v_time_job     = '';   let v_number_dependents = '';  let v_number_people_house = '';   let v_telephone        = '';   let v_nombrezona        = '';  
let v_gender       = '';   let v_application_date  = '';  let v_down_payment        = '';   let v_apartment_number = '';   let v_type_residence    = '';
let v_house_number = '';   let v_monthly_expense   = '';  let v_first_name          = '';   let v_middle_name      = '';   let v_last_name         =  '';                  
let v_city_name    = '';   let v_state             = '';  let v_job_type            = '';   let v_status_credito   = '';   let v_years_credit_exp  = 0;              
let v_postal_code4 = '';   let v_application_id    = '';  let v_compras_PURCHASES   = 0;    let v_intereses        = 0;    let v_saldo_corte       = 0;
let v_numcte       = '';   let v_num_credito       = '';  let v_meses_vencidos      = 0;    let v_pago_minimo      = 0;    let v_iva               = 0;                           
let v_rendimientos = 0;    let v_comisiones        = 0;   let v_MOB                 = 0;    let v_limite_credito   = 0;     
let vCurrent       = '';   let vHora               = '';  let cMensajeRet2          = '';   let cNumCte            = '';   let vHora_2             = '';
let dMesesVencidos = 0;    let v_sdo_disponible    = 0;   let v_monthly_income      = 0;    let dComisiones        = 0; 
let dRendimientos  = 0;    let v_mes_appdate       = '';  let dSdoCorteAnterior     = 0;    
let v_yearly_house_income           = '';   let dDisposicionesWithdrawals = 0;    let v_application_status        = '';  
let v_sdo_corte_anterior            = 0;    let v_pagos_PAYMENTS          = 0;    let v_disposiciones_WITHDRAWALS = 0;
let v_numero_disposiciones_CASH_ATM = 0;    let v_numero_pagos_PAYMENTS   = 0;    let v_numero_compras_PURCHASES  = 0;
let v_requested_amount              = 0;    let iNumeroPagosPayments      = 0;    let iNumeroDisposicionesCashATM = 0;
let v_number_prev_loans_bank        = '';   let iNumeroComprasPurchases   = 0;    let v_thoroughfare_name         = '';                                                                                    
let v_fecha_apertura  = date(1);  let v_fecha_limite_pago = date(1);  let v_fechacorte_actual = date(1);
let v_fecha_finmesant = date(1);  let dFechaEmision       = date(0);  let vdia2               = date(1); 
let v_fecha_emision   = date(1);  let v_fecha_nac         = date(1);  let v_fecha_insert      = date(1);
let v_fecha_corte     = date(1);  let cFechaappdate       = '';
let vFechaappdate     = date(1);
  


--********************** Inicializacion de variables ***************************
let cMensajeRet = 'El proceso de REPORTES IRB se realizó correctamente';
let iCodRet                 = 0;
let isam_err				= 0;
let SCodRet                 = '000000';
let cont                    = 1;
let cSql                    = '';
let vFecha_proceso          = date(0);
let vhora_inicio            = '';
let vhora_fin               = '';
let vstatus_proceso         = '';
let NombreArchivo           = '';
let NombreArchivoCifras     = '';
let vDia                    = '';
let vMes                    = '';
let vAnio                   = '';

let cNumCliente          = '';
let cNumCredito          = '';
let dFechaApertura       = date(0);
let sMesesVencidos       = 0;
let cStatusCredito       = '';
let dPagoMinimo          = 0;
let dSaldoCorte          = 0;
let dSdoDisponible       = 0;
let dFechaLimitePago     = date(0);
let dFechaCorte          = date(0);
let dPagosPAYMENTS       = 0;
let dComprasPURCHASES    = 0;
let dDispWITHDRAWALS     = 0;
let dIntereses           = 0;
let dMOB                 = 0;
let dLimiteCredito       = 0;
let dTasa                = 0;
let dFecha               = date(0);
let dSdoCorteAnt         = 0;
let dIva                 = 0;
let iNumDispCASHATM      = 0;
let iNumPagosPAYMENTS    = 0;
let iNumCompPURCHASES    = 0;
let iImpComisiones       = 0;
let dFechaIni            = date(0);

let cApplicationId      = '';
let cApplicationDate    = '';
let cApplicationStatus  = '';
let dRequestedAmount    = 0;
let cTerm               = '';
let cDownPayment        = '';
let cPostalCode         = '';
let cPostalCode4        = '';
let cLastName           = '';
let cFirstName          = '';
let cMiddleName         = '';
let cNameSuffix         = '';
let cCharacterBlanks    = '';
let cHouseNumber        = '';
let cNombreZona         = '';
let cThoroughfareName   = '';
let cThoroughfareType   = '';
let cApartmentNumber    = '';
let cCityName           = '';
let cGender             = '';
let cAge                = '';
let cJobType            = '';
let cTelephone          = '';
let cPresenceCknSvn     = '';
let cTimeResidence      = '';
let cTimeJob            = '';
let dMonthlyIncome      = '';
let dMonthlyExpense     = '';
let cNumberDependents   = '';
let cNumberPeopleHouse  = '';
let cYearlyHouseIncome  = '';
let cNumberDebtObli     = '';
let cNumberPrevLoansBank = '';
let cState		= '';
let cTypeResidence	= '';
let sYearsCreditExp	= 0;
let cnumerociudad = 0;
let v_tasa = 0;
let vfechareporte = date(1);
-----------------------------------------------------------------------------
LET bandera1 					= "";
LET bandera2 					= "";
LET v1_num_solicitud 			= "";
LET v1_numcte 					= "";
LET v1_sdo_actual 				= 0;
LET v1_sdo_vencido 				= 0;
LET v1_int_vencido 				= 0;
LET v1_iva_int_vencido 			= 0;
LET v1_int_mora_ordi 			= 0;
LET v1_iva_int_mora_ordi 		= 0;
LET v1_int_mora_cope 			= 0;
LET v1_iva_int_mora_cope 		= 0;
LET v1_meses_vencidos 			= 0;
LET v1_fecha 					= DATE(1);
LET v1_situacion 				= "";
-----------------------------------------------------------------------------


--**************************** Control de errores ******************************
begin
    on exception set iCodRet, isam_err, error_info
	if iCodRet <> 0 then
--            execute procedure sp_obtener_hora() into vhora_fin;
        	let SCodRet = iCodRet;
        	  --   let cMensajeRet ='Error al generar los REPORTES IRB >> '||NombreArchivo;
            let cMensajeRet ='Error REPORTES IRB >> '||trim(NombreArchivo)|| ' - ' || trim(error_info) || ' - ' ||trim(v_num_solicitud)||' - '||trim(v1_num_solicitud);
--  		      let cMensajeRet ='Error>>'||trim(NombreArchivo)|| ' - ' ||trim(v_num_solicitud)||' - '||trim(v1_num_solicitud);
			      
            update bdicred:sd_param
               set valor = cont
             where empresa = pEmpresa and cod_param = '038';
             
              	
			return SCodRet,cMensajeRet ;
        end if;
    end exception;

  -- Set debug file to "/tmp/sp_rep_regulatorios_irb.out";
  -- trace on;

--*******************a******** Programa principal *******************************
    -- obtener la hora que inicio la ejecucion el proceso
    --execute procedure sp_obtener_hora() into vhora_inicio;

    -- obtener la fecha de hoy
    select fecha_hoy,pri_dia_mes into vfecha_hoy,pFechaReporte from bdicred:sd_fechas where empresa = pEmpresa;


/*
    --obtener la fecha en la que se realizara la ejecucucion.
    select fecha_proceso, status_proceso
      into vFecha_proceso, vstatus_proceso
      from bdicred:sd_control_procesos where empresa = pEmpresa and
           cod_proceso = 'CrearReportesIBR';

    if (vFecha_prox_proceso != vfecha_hoy) then
        return 'Hoy no se ejecuta el proceso "sp_crear_reportes_IBR()"';
    end if;
 
    -- checar si hoy ya se ejecuto y si finalizo correctamente
    if (vFecha_proceso=vfecha_hoy) then
        if(vstatus_proceso='F') then
            return 'El proceso "sp_crear_reportes_IBR()" ' ||
                   ' ya fue ejecutado hoy y finalizado con exito';
        end if;
        -- checar si se esta esjecutando el proceso
        if(vstatus_proceso='I') then
            return 'El proceso "sp_crear_reportes_IBR()" esta en ejecucion';
        end if;
    end if;

    -- checar si hoy se ejecuta
    --IF vFecha_prox_proceso=vfecha_hoy then

    -- actualizar el control proceso
        UPDATE bdicred:sd_control_procesos
               SET hora_inicio = vhora_inicio,
                   status_proceso = 'I',
                   fecha_proceso = vfecha_hoy,
                   mensaje = 'Proceso "sp_crear_reportes_IBR" en ejecusion'
             where cod_proceso = 'CrearReportesIBR';

    -- obtiene el numero de reporte con el que inicializara
    select parametros into cont
    from bdicred:sd_control_procesos where empresa = pEmpresa and
         cod_proceso = 'CrearReportesIBR';
*/

-- obtener el ultimo reporte generado.
  select trim(valor) into cont from bdicred:sd_param where cod_param = '038';

    if cont is null or cont = '' then
       let SCodRet = '000010';
       let cMensajeRet = 'No se encuentra el valor del número de reporte a ejecutar para IRB.';
       return SCodRet,cMensajeRet ;
    elif cont < 1 or cont >=6 then
       let SCodRet = '000020';
       let cMensajeRet = 'El valor del número de reporte a ejecutar para IRB no es válido.';
    end if;

--obtener los rangos de fechas para el mes del reporte en cuestion
    let PrimerDiaMes = pFechaReporte - 1 units month;
    let UltimoDiaMes = pFechaReporte - 1 units day;
    
--******Variable para pruebas******	
	--LET PrimerDiaMes = mdy('05','01','2015');
	--LET UltimoDiaMes = mdy('05','31','2015');
--------------------------------------------------
	
-- obtener por separado el dia, mes y año de la fecha en cuestion para el nombre del archivo
    let vDia = lpad(day(UltimoDiaMes),2,'0');
    let vMes = lpad(month(UltimoDiaMes),2,'0');
    let vAnio = lpad(year(UltimoDiaMes),4,'0');

    LET v_fecha_finmesant = pFechaReporte -1 UNITS day;
    LET v_fechacorte_actual = mdy(month(v_fecha_finmesant),20,year(v_fecha_finmesant));
         
	--LET cont = 2;
    
    if(cont = 1) then
    --crea el reporte ss_solicitudes del RQM 07 044 Generacion de informacion para el proyecto IRB
    -- Tarda menos de 1 minuto aprox.

        let NombreArchivo = trim('Solicitudes_' || trim(vdia) || trim(vMes) || trim(vAnio) || '.txt');
        let cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/archivoscartera/' || trim(NombreArchivo) ||
            ' DELIMITER ' || '''|'''  ||
            ' select' ||
            ' num_solicitud,' ||
            ' numcte,' ||
            ' sucursal,' ||
            ' status_solicitud,' ||
            ' monto_solicitado,' ||
            ' user_insert,' ||
            ' fecha_insert' ||
            ' from bdisolic:ss_solicitudes' ||
            ' where empresa=''001'' and num_solicitud>'''' and fecha_insert >= ''' || PrimerDiaMes || ''' ' ||
            ' and fecha_insert <= ''' || UltimoDiaMes || '''; "' ||
            ' > /resplogifx/archivoscartera/QuerySolicitudes.sql';
        system cSql;

        let cSql='';
        let cSql = 'dbaccess bdisolic /resplogifx/archivoscartera/QuerySolicitudes.sql';
        system cSql;
        let cSql = 'rm /resplogifx/archivoscartera/QuerySolicitudes.sql';
        system cSql;

--ss_solicitudes

        let NombreArchivoCifras = trim('SolicitudesCifrasControl_' || trim(vdia) || trim(vMes) || trim(vAnio) || '.txt');
        let cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/archivoscartera/' || trim(NombreArchivoCifras) ||
            ' DELIMITER ' || '''|'''  || 
            ' select count(*)::integer' ||
            ' from bdisolic:ss_solicitudes' ||
            ' where empresa=''001'' and num_solicitud>'''' and fecha_insert >= ''' || PrimerDiaMes || ''' ' ||
            ' and fecha_insert <= ''' || UltimoDiaMes || '''; "' ||
            ' > /resplogifx/archivoscartera/QuerySolicitudesCifrasControl.sql';
        system cSql;

        let cSql='';
        let cSql = 'dbaccess bdisolic /resplogifx/archivoscartera/QuerySolicitudesCifrasControl.sql';
        system cSql;
        let cSql = 'rm /resplogifx/archivoscartera/QuerySolicitudesCifrasControl.sql';
        system cSql;

        let cont = cont + 1;

        update bdicred:sd_param
        set valor = cont
        where empresa = pEmpresa and cod_param = '038';
		 
    end if;

    if(cont = 2) then
    -- crea el reporte cartera_vendida de RQM 07 044
    -- Tarda 3 min. aprox.
	
	select max(fechareporte) into vfechareporte 
	from bdicobranza:cb_rep_cart_quebrantar;
	
--******Variable para prueba******	
	--let vfechareporte = mdy('05','27','2015');
---------------------------------------------------

		IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'sd_cartera_temp' ) THEN
		
			TRUNCATE TABLE "informix".sd_cartera_temp drop storage;
		
		ELSE
			CREATE TABLE "informix".sd_cartera_temp(num_solicitud CHAR(20) NOT NULL, numcte CHAR(20), sdo_actual DECIMAL(14,2),
													sdo_vencido DECIMAL(14,2), int_vencido DECIMAL(14,2),
													iva_int_vencido DECIMAL(14,2), int_mora_ordi DECIMAL(14,2),
													iva_int_mora_ordi DECIMAL(14,2), int_mora_cope DECIMAL(14,2), 
													iva_int_mora_cope DECIMAL(14,2), meses_vencidos INTEGER, fecha DATE,
													situacion CHAR(06));
		END IF;
		
		
		SELECT LIMIT 1 a.num_solicitud
		INTO bandera1
		FROM bdisolic:"informix".ss_solicitudes a, 
			bdicred:"informix".sd_maecred c, 
			bdicobranza:"informix".cb_rep_cart_quebrantar e 
		WHERE a.empresa = pEmpresa
		AND a.empresa = c.empresa 
		AND a.num_solicitud = c.num_credito 
		AND a.num_solicitud = e.num_credito 
		AND e.excluido = 'B' 
		AND e.fechareporte = vfechareporte;
		
		SELECT LIMIT 1 a.num_solicitud
		INTO bandera2
		FROM bdisolic:"informix".ss_solicitudes a, 
			bdicred:"informix".sd_maecred c, 
			bdicobranza:"informix".cb_rep_cart_quebrantar e, 
			bdicred:"informix".sd_maecred_vendida f 
		WHERE a.empresa = pEmpresa
		AND a.empresa = c.empresa
		AND a.num_solicitud = c.num_credito
		AND c.status_cred = 'CV'
		AND a.empresa = f.empresa
		AND a.num_solicitud = f.num_credito
		AND a.num_solicitud = e.num_credito
		AND f.fecha >= PrimerDiaMes
		AND f.fecha <= UltimoDiaMes
		AND e.fechareporte = vfechareporte;
		
		IF bandera1 IS NULL THEN
			LET bandera1 = '';
		END IF;
		
		IF bandera2 IS NULL THEN
			LET bandera2 = '';
		END IF;
		
		IF bandera1 <> '' THEN
			FOREACH WITH HOLD
				SELECT a.num_solicitud, a.numcte, sdo_actual, sdo_vencido, int_vencido, iva_int_vencido, int_mora_ordi, iva_int_mora_ordi, 
						int_mora_cope, iva_int_mora_cope, meses_vencidos, e.fecha_baja, 'BAJA' as situacion
				INTO v1_num_solicitud, v1_numcte, v1_sdo_actual, v1_sdo_vencido, v1_int_vencido, v1_iva_int_vencido, 
					v1_int_mora_ordi, v1_iva_int_mora_ordi, v1_int_mora_cope, v1_iva_int_mora_cope, v1_meses_vencidos, v1_fecha, v1_situacion
				FROM bdisolic:"informix".ss_solicitudes a, 
					bdicred:"informix".sd_maecred c, 
					bdicobranza:"informix".cb_rep_cart_quebrantar e 
				WHERE a.empresa = pEmpresa
				AND a.empresa = c.empresa 
				AND a.num_solicitud = c.num_credito 
				AND a.num_solicitud = e.num_credito 
				AND e.excluido = 'B' 
				AND e.fechareporte = vfechareporte
				
				BEGIN;
					INSERT INTO "informix".sd_cartera_temp 
						(num_solicitud, numcte, sdo_actual,	sdo_vencido, int_vencido, iva_int_vencido, int_mora_ordi, iva_int_mora_ordi,
						int_mora_cope, iva_int_mora_cope, meses_vencidos, fecha, situacion)
					VALUES 
						(v1_num_solicitud, v1_numcte, v1_sdo_actual, v1_sdo_vencido, v1_int_vencido, v1_iva_int_vencido, v1_int_mora_ordi,
						v1_iva_int_mora_ordi, v1_int_mora_cope, v1_iva_int_mora_cope, v1_meses_vencidos, v1_fecha, v1_situacion);
				COMMIT;
				
				LET v1_num_solicitud = ""; LET v1_numcte = ""; LET v1_sdo_actual = 0; LET v1_sdo_vencido = 0; LET v1_int_vencido = 0; 
				LET v1_iva_int_vencido = 0; LET v1_int_mora_ordi = 0; LET v1_iva_int_mora_ordi = 0; LET v1_int_mora_cope = 0;
				LET v1_iva_int_mora_cope = 0; LET v1_meses_vencidos = 0; LET v1_fecha = DATE(1); LET v1_situacion = "";
			END FOREACH;
		END IF;
		
		IF bandera2 <> '' THEN
			FOREACH WITH HOLD
				SELECT a.num_solicitud, a.numcte, sdo_actual, sdo_vencido, int_vencido, iva_int_vencido, int_mora_ordi, iva_int_mora_ordi, 
						int_mora_cope, iva_int_mora_cope, meses_vencidos, f.fecha, 'VENTA' as situacion 
				INTO v1_num_solicitud, v1_numcte, v1_sdo_actual, v1_sdo_vencido, v1_int_vencido, v1_iva_int_vencido, 
					v1_int_mora_ordi, v1_iva_int_mora_ordi, v1_int_mora_cope, v1_iva_int_mora_cope, v1_meses_vencidos, v1_fecha, v1_situacion
				FROM bdisolic:"informix".ss_solicitudes a, 
					bdicred:"informix".sd_maecred c, 
					bdicobranza:"informix".cb_rep_cart_quebrantar e, 
					bdicred:"informix".sd_maecred_vendida f 
				WHERE a.empresa = pEmpresa
				AND a.empresa = c.empresa
				AND a.num_solicitud = c.num_credito
				AND c.status_cred = 'CV'
				AND a.empresa = f.empresa
				AND a.num_solicitud = f.num_credito
				AND a.num_solicitud = e.num_credito
				AND f.fecha >= PrimerDiaMes
				AND f.fecha <= UltimoDiaMes
				AND e.fechareporte = vfechareporte
					
				BEGIN;
					INSERT INTO "informix".sd_cartera_temp 
						(num_solicitud, numcte, sdo_actual,	sdo_vencido, int_vencido, iva_int_vencido, int_mora_ordi, iva_int_mora_ordi,
						int_mora_cope, iva_int_mora_cope, meses_vencidos, fecha, situacion)
					VALUES 
						(v1_num_solicitud, v1_numcte, v1_sdo_actual, v1_sdo_vencido, v1_int_vencido, v1_iva_int_vencido, v1_int_mora_ordi,
						v1_iva_int_mora_ordi, v1_int_mora_cope, v1_iva_int_mora_cope, v1_meses_vencidos, v1_fecha, v1_situacion);
				COMMIT;
				
				LET v1_num_solicitud = ""; LET v1_numcte = ""; LET v1_sdo_actual = 0; LET v1_sdo_vencido = 0; LET v1_int_vencido = 0;
				LET v1_iva_int_vencido = 0; LET v1_int_mora_ordi = 0; LET v1_iva_int_mora_ordi = 0; LET v1_int_mora_cope = 0;
				LET v1_iva_int_mora_cope = 0; LET v1_meses_vencidos = 0; LET v1_fecha = DATE(1); LET v1_situacion = "";			
			END FOREACH;
			
			UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_cartera_temp;
		END IF;

        let NombreArchivo = trim('CarteraVendida_' || trim(vdia) || trim(vMes) || trim(vAnio) || '.txt');
        let cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/archivoscartera/' || trim(NombreArchivo) ||
			' DELIMITER ' || '''|'''  || 
			' select' ||
			' *' ||
		' from "informix".sd_cartera_temp; "' || 
		' > /resplogifx/archivoscartera/QueryCarteraVendida.sql';
        system cSql;


        let cSql='';
        let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/QueryCarteraVendida.sql';
        system cSql;
        let cSql = 'rm /resplogifx/archivoscartera/QueryCarteraVendida.sql';
        system cSql;
	
        let NombreArchivoCifras = trim('CarteraVendidaCifrasControl_' || trim(vdia) || trim(vMes) || trim(vAnio) || '.txt');
        let cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/archivoscartera/' || trim(NombreArchivoCifras) ||
            ' DELIMITER ' || '''|'''  || 
            ' select count(*)::integer,' ||
            ' sum(sdo_actual),' ||
            ' sum(sdo_vencido),' ||
            ' sum(int_vencido),' ||
            ' sum(iva_int_vencido),' ||
            ' sum(int_mora_ordi),' ||
            ' sum(iva_int_mora_ordi),' ||
            ' sum(int_mora_cope),' ||
            ' sum(iva_int_mora_cope)' ||
        ' from "informix".sd_cartera_temp; "' || 
        ' > /resplogifx/archivoscartera/QueryCarteraVendidaCifrasControl.sql';
        system cSql;

        let cSql='';
        let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/QueryCarteraVendidaCifrasControl.sql';
        system cSql;
        let cSql = 'rm /resplogifx/archivoscartera/QueryCarteraVendidaCifrasControl.sql';
        system cSql;

        let cont=cont + 1;

        update bdicred:sd_param
           set valor = cont
         where empresa = pEmpresa and cod_param = '038';

    end if;

    if(cont=3) then
    -- crea el reporte originations del RQM 07 044 Generacion para el proyecto IRB
    -- Tarda 1:15 aprox. (una hora quince minutos)
    	let NombreArchivo = trim('Originations_' || trim(vdia) || trim(vMes) || trim(vAnio) || '.txt');
  
      select limit 1 application_date into v_application_date
        from bdicred:originations
       where application_id >= '';
	
	    IF v_application_date IS NULL or v_application_date = '' THEN LET v_application_date = '01011900'; END IF; 
	
	    --LET vFechaappdate = substr(to_char(v_application_date),1,2) || '/' || substr(to_char(v_application_date),3,2) || '/' || substr(to_char(v_application_date),5,4);  
	    LET cFechaappdate = substr(to_char(v_application_date),1,2) || '/' || substr(to_char(v_application_date),3,2) || '/' || substr(to_char(v_application_date),5,4);
	    LET vFechaappdate = cFechaappdate; 

      
      IF (month(vFechaappdate) <> month(v_fechacorte_actual)) THEN
	       truncate bdicred:originations drop storage;
	    END IF;
            
 	    SELECT {+INDEX(bdisolic:ss_solicitudes idx_fecins_numsol)} a.num_solicitud ApplicationId,
 	           a.numcte numcte,
          	 substr(a.fecha_insert, 1, 2)||substr(a.fecha_insert, 4, 2)||substr(a.fecha_insert, 7, 4) ApplicationDate, 
          	 (case when a.status_solicitud = 'AN' then 'C' 
          	       when a.status_solicitud = 'AP' then 'A'   
          	       when a.status_solicitud = 'AT' then 'A'   
          	       when a.status_solicitud = 'BC' then 'P'   
          	       when a.status_solicitud = 'CC' then 'P'   
          	       when a.status_solicitud = 'CE' then 'P'   
          	       when a.status_solicitud = 'EE' then 'P'   
          	       when a.status_solicitud = 'OA' then 'P'   
          	       when a.status_solicitud = 'OS' then 'P'   
          	       when a.status_solicitud = 'PC' then 'P'   
          	       when a.status_solicitud = 'RT' then 'R'   
          	       when a.status_solicitud = 'CV' then 'R'   
          	       when a.status_solicitud = 'CR' then 'R'   
          	 end) Application_Status,    
          	 a.monto_solicitado  Requested_Amount, 
             a.fecha_insert  fecha_insert    
 	      FROM bdisolic:ss_solicitudes a
 	       WHERE a.fecha_insert BETWEEN PrimerDiaMes AND UltimoDiaMes
 	         AND a.num_solicitud not in (select application_id from bdicred:originations)
        INTO temp base_solicitudes WITH no log;
        
             
        --CREATE INDEX idx_base_solicitudes ON base_solicitudes(ApplicationId);
        --UPDATE STATISTICS MEDIUM FOR TABLE base_solicitudes;
 	   
 	    LET v_term = ' '; 
      LET v_down_payment = '9999999999'; 
      LET v_presence_ckn_svn = '0';
      LET v_time_residence = '998';
      LET v_time_job = '998';
      LET v_monthly_expense = '999999999999';
      LET v_number_dependents = '999';
      LET v_number_people_house = '999'; 
      LET v_yearly_house_income = '9999999999';
      LET v_number_prev_loans_bank = '99';
      LET v_name_suffix = ' ';
      LET v_character_blanks = ' ';
      LET v_thoroughfare_type = ' ';
        
     	FOREACH WITH HOLD
          SELECT ApplicationId, numcte, ApplicationDate, Application_Status, Requested_Amount, fecha_insert
            INTO v_num_solicitud, v_numcte, v_application_date, v_application_status, v_requested_amount, v_fecha_insert 
            FROM base_solicitudes
         
   	      SELECT b.apell_paterno, b.nombre1, b.nombre2, c.sexo, f.descripcion, c.fecha_nac
   	        INTO v_last_name, v_first_name, v_middle_name, v_gender, v_job_type, v_fecha_nac 
   	        FROM bdinteg:si_cliente b join bdinteg:si_ctepf c on b.numcte = c.numcte  
            	                   left outer join bdinteg:si_profesion f on f.profesion = c.profesion
           WHERE b.numcte = v_numcte;   
  	      
 	      
          SELECT LIMIT 1 d.cod_postal, d.cod_postal, d.numeroextcalle, e.nombrezona, e.nombrezona, d.departamento, e.poblacionzona, h.nombre
            INTO v_postal_code, v_postal_code4, v_house_number, v_nombrezona, v_thoroughfare_name, v_apartment_number, v_city_name, v_state 
   	       FROM bdinteg:si_direcciones_actual d  
            	                join bdinteg:si_catzonas e on e.numerociudad = d.numerociudad and e.numerocolonia = d.numerocolonia
            	                join bdinteg:si_ciudades i on i.ciudad_coppel = d.numerociudad join bdinteg:si_estados h on h.estado = i.estado 
   	       WHERE d.numcte = v_numcte
             AND d.tipo_dir = '1';
          
   	      
   	      SELECT LIMIT 1 tel.telefono INTO v_telephone
   	        FROM bdinteg:si_telefonos_actual tel 
           WHERE tel.numcte = v_numcte  
             AND tel.tipo_tel = 1 
             AND tel.cofetel ='V'
             AND tel.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
            											 where numcte = tel.numcte  and tipo_tel = 1 and cofetel ='V');
                                        
   	      
   	      SELECT year(today) - year(fecha_apertura) --years_credit_exp
            INTO v_years_credit_exp  
            FROM bdicred:sd_maecred  
           WHERE empresa = pEmpresa  
           	 AND num_credito = v_num_solicitud;  
   	      
   	     SELECT
          	   case when k.elemento = '5' then 'O'   
          		      when k.elemento = '6' then 'X'   
          		      when k.elemento = '7' then 'X'   
          		      when k.elemento = '8' then 'R'   
          		      when k.elemento = '9' then 'X'   
          	   end type_residence
          INTO v_type_residence  
          from bdisolic:ss_detalle_scoring  j   
        	      join bdisolic:ss_scoring_element k on k.empresa = j.empresa and k.grupo = j.grupo and k.seccion = j.seccion and k.elemento = j.elemento 
                       and k.activa = '1'   
         where j.empresa= pEmpresa  
           and j.seccion = '2'  
           and j.grupo = '5'  
           and j.tpo_persona = '01'  
           and j.num_solicitud = v_num_solicitud; 
   	      
   	    
         --SELECT g.ingreso_mensual Monthly_Income,    
         SELECT g.ingreso_mensual,
          	  (case when g.evalua_cc = '0' then '0'  
          		      when g.evalua_cc = '1' then '1'  
          		      when g.evalua_cc = '2' then '1'  
          		      when g.evalua_cc = '3' then '1'  
          		      when g.evalua_cc = 'X' then '999'  
          		end) Number_Debt_Obli 
   	      INTO v_monthly_income, v_number_debt_obli
          FROM bdisolic:ss_resum_scor_fin g 
         WHERE g.empresa = pEmpresa   
           AND g.num_solicitud = v_num_solicitud;
           
          LET v_age = trunc((round((year(v_fecha_insert) - year(v_fecha_nac)),2)),0); 
   
   	      
     	       BEGIN WORK;
    	           INSERT INTO bdicred:originations(application_id, application_date, application_status, requested_amount, term, down_payment, 
                 postal_code, postal_code4, last_name, first_name, middle_name, name_suffix, character_blanks, house_number, nombrezona, thoroughfare_name,
                 thoroughfare_type, apartment_number, city_name, state, gender, age, job_type, type_residence, telephone, presence_ckn_svn, time_residence,
                 time_job, monthly_income, monthly_expense, number_dependents, number_people_house, yearly_house_income, number_debt_obli, years_credit_exp, 
                 number_prev_loans_bank)
                 VALUES(v_num_solicitud, v_application_date, v_application_status, v_requested_amount, v_term, v_down_payment, v_postal_code, 
                   v_postal_code4, v_last_name, v_first_name, v_middle_name, v_name_suffix, v_character_blanks, v_house_number, v_nombrezona, v_thoroughfare_name,
                   v_thoroughfare_type, v_apartment_number, v_city_name, v_state, v_gender, v_age, v_job_type, v_type_residence, v_telephone, v_presence_ckn_svn,
                   v_time_residence, v_time_job, v_monthly_income, v_monthly_expense, v_number_dependents, v_number_people_house, v_yearly_house_income,
                   v_number_debt_obli, v_years_credit_exp, v_number_prev_loans_bank);
             COMMIT WORK;
             
       END FOREACH;
	     
	     UPDATE statistics medium FOR TABLE "informix".originations;
	     
	     DROP TABLE base_solicitudes;
	     
	     let cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/archivoscartera/' || trim(NombreArchivo) ||
                ' DELIMITER ' || '''|'''  || ' select * from originations;" > /resplogifx/archivoscartera/QueryOriginations.sql'; 
        system cSql;

        let cSql='';
        let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/QueryOriginations.sql';
        system cSql;
        let cSql = 'rm /resplogifx/archivoscartera/QueryOriginations.sql';
        system cSql;

        let cont = cont + 1;

        update bdicred:sd_param
           set valor = cont
         where empresa = pEmpresa and cod_param = '038';

        
    end if;

    if(cont=4) then
    	let NombreArchivoCifras = trim('OriginationsCifrasControl_' || trim(vdia) || trim(vMes) || trim(vAnio) || '.txt');
        let cSql = 'echo "UNLOAD TO /resplogifx/archivoscartera/' || trim(NombreArchivoCifras) ||
            ' DELIMITER ' || '''|'''  || ' select count(*)::integer from originations;" > /resplogifx/archivoscartera/QueryOriginationsCifrasControl.sql';
        system cSql;

        let cSql='';
        let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/QueryOriginationsCifrasControl.sql';
        system cSql;
        let cSql = 'rm /resplogifx/archivoscartera/QueryOriginationsCifrasControl.sql';
        system cSql;

        let cont = cont + 1;

        update bdicred:sd_param
           set valor = cont
         where empresa = pEmpresa and cod_param = '038';
    end if;

--IPCB 03092013/ inicializa valor para proxima ejecución del reporte completo
    update bdicred:sd_param
       set valor = '1'
     where empresa = pEmpresa and cod_param = '038';

	return SCodRet,cMensajeRet ;
end;
end procedure;
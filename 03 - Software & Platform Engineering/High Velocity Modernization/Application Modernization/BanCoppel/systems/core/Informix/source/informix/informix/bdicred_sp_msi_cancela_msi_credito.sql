CREATE PROCEDURE "informix".sp_msi_cancela_msi_credito(pempresa CHAR(3), pFolioMovto CHAR(20) default "", pNum_Credito_Msi CHAR(20) default "", pCanal SMALLINT, pSucursal CHAR(4), pUsuario CHAR(20))
   RETURNING CHAR(6), CHAR(80);
	 
	--DECLARACION DE VARIABLES.
	DEFINE iSqlErr                       	INTEGER;
	DEFINE iIsamErr                      	INTEGER;
	DEFINE cErrorInfo                    	CHAR(100);
	DEFINE CodRet                        	CHAR(6);
	DEFINE Mensaje                  	 	CHAR(80);
	DEFINE cNum_Cred_tdc, cNum_Cred_MSI  	CHAR(20);
	DEFINE v_monto_actual, v_monto_int_iva	DECIMAL(14,2);
	DEFINE cfolio_mov_promo,cfolio_suc_promo CHAR(16);
	DEFINE cCharAux          			 	CHAR(80);
	DEFINE dtDateAux         			 	DATE;
	DEFINE dDecAux           			 	DECIMAL(18,2);
	DEFINE iIntAux           			 	INTEGER;
	DEFINE dIntDevengado,dIvaIntDevengado	DECIMAL(18,2);
	DEFINE vcap_vig,dSdoAdeudTotalAct		DECIMAL(18,2);
	DEFINE dIntVig, dIvaIntVig 				DECIMAL(18,2);
	DEFINE dtFechaApertura,dtFechaProxPago  DATE;
	DEFINE dPagoMinAct        			 	DECIMAL(18,2);
	DEFINE cStatus						 	CHAR(23);
	DEFINE cStatus_tar					 	CHAR(1);
	DEFINE dFecha_hoy					 	DATE;
	DEFINE dFecha_credisol				 	DATE;
	DEFINE cTipo_promo					 	CHAR(2);
	DEFINE sStatus_cancel1				 	SMALLINT;
	DEFINE sBand				 		 	SMALLINT;
	DEFINE cStatus_promo				 	CHAR(1);
	DEFINE cDivisa             			 	CHAR(2);
	DEFINE cNumProducto   				 	CHAR(4); 
	DEFINE cSucursal 					 	CHAR(4);
	DEFINE cNumCte						 	CHAR(20);
	DEFINE dSdoRet_Orig 				 	DECIMAL(18,2);		
	DEFINE dSdoRet_Aux	 				 	DECIMAL(18,2);		
	DEFINE dSdoRet_Nvo	 				 	DECIMAL(18,2);		
	DEFINE cFolioMovto					 	CHAR(20);
	
	--INICIALIZACION DE VARIABLES.
	LET iSqlErr      		= 0;
	LET iIsamErr     		= 0;
	LET cErrorInfo   		= "";
	LET CodRet       		= "000000";
	LET Mensaje   	 		= "Se realizo proceso exitosamente";
	LET cNum_Cred_tdc		= '';
	LET cNum_Cred_MSI 		= '';
	LET v_monto_actual		= 0;
	LET v_monto_int_iva 	= 0;
	LET cfolio_mov_promo	= '';
	LET cfolio_suc_promo 	= '';
	LET cCharAux       		= "";
	LET dtDateAux      		= DATE(1);
	LET dDecAux        		= 0; 
	LET iIntAux 			= 0; 
	LET dIntDevengado 		= 0; 
	LET dIvaIntDevengado 	= 0; 
	LET vcap_vig 			= 0; 
	LET dIntVig 			= 0; 
	LET dIvaIntVig 			= 0;
	LET dtFechaApertura  	= DATE(1); 
	LET dtFechaProxPago 	= DATE(1); 
	LET dPagoMinAct 		= 0; 
	LET dSdoAdeudTotalAct 	= 0;
	LET cStatus 		 	= "";
	LET cStatus_tar 	 	= "";
	LET dFecha_hoy 	 	 	= "";
	LET dFecha_credisol  	= "";
	LET cTipo_promo 	 	= "";
	LET sStatus_cancel1  	= 0;
	LET sBand      			= 0;
	LET cStatus_promo 		= "";
	LET cDivisa				= "";
	LET cNumProducto   		= "";
	LET cSucursal 			= "";
	LET cNumCte				= 0;
	LET dSdoRet_Orig 		= 0;
	LET dSdoRet_Aux			= 0;
	LET dSdoRet_Nvo			= 0;	
	LET cFolioMovto			= '';
	
	
	BEGIN

		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		   IF iSqlErr != 0 THEN
				LET CodRet  = iSqlErr;
				LET Mensaje = cErrorInfo;
				RETURN CodRet, TRIM(Mensaje);
		   END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/informix/mahr/sp_msi_cancela_msi_credito.out";
		--TRACE ON;
	  
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- Se toma la fecha de hoy.
		SELECT fecha_hoy INTO dFecha_hoy FROM "informix".sd_fechas WHERE empresa = '001';
		
		-- Se obtienen los estatus de credisoluciones que si se puedan cancelar
		SELECT valor_numerico INTO sStatus_cancel1 FROM bdicred:sd_param_campania WHERE empresa = '001' AND tipo_campania = 2 AND grupo_parametro = 'MSI' AND num_parametro = 1;

		-- Valida parametros de entrada
		IF nvl(pFolioMovto, '') = '' AND nvl(pNum_Credito_Msi, '') = '' THEN
			LET CodRet  = '000001';
			LET Mensaje = 'PARAMETROS INVALIDOS. CREDITO MSI NO VALIDO PARA CANCELARSE';
			RETURN CodRet, TRIM(Mensaje);		
		END IF;
		
		IF nvl(pFolioMovto, '') != '' THEN
			SELECT first 1 folio_movto INTO cFolioMovto FROM bdicred:sd_promocion_credito WHERE folio_movto = pFolioMovto;
			IF nvl(cFolioMovto, '') = '' THEN
				LET CodRet  = '000002';
				LET Mensaje = 'FOLIO NO VALIDO. CREDITO MSI NO VALIDO PARA CANCELARSE';
				RETURN CodRet, TRIM(Mensaje);					
			END IF;
		ELIF nvl(pNum_Credito_Msi, '') != '' THEN
			SELECT first 1 folio_movto INTO cFolioMovto FROM bdicred:sd_promocion_credito WHERE num_sol_prestamo = pNum_Credito_Msi;
			IF nvl(cFolioMovto, '') = '' THEN
				LET CodRet  = '000003';
				LET Mensaje = 'CREDITO NO VALIDO. CREDITO MSI NO VALIDO PARA CANCELARSE';
				RETURN CodRet, TRIM(Mensaje);					
			END IF;			
		ELSE
			LET CodRet  = '000001';
			LET Mensaje = 'PARAMETROS INVALIDOS. CREDITO MSI NO VALIDO PARA CANCELARSE';
			RETURN CodRet, TRIM(Mensaje);
		END IF;
		
		SELECT count(*) INTO sBand FROM bdicred:sd_promocion_credito WHERE folio_movto = cFolioMovto AND status = sStatus_cancel1;
		IF sBand != 1 THEN
			LET CodRet  = '000004';
			LET Mensaje = 'FOLIO DUPLICADO. CREDITO MSI NO VALIDO PARA CANCELARSE';
			RETURN CodRet, TRIM(Mensaje);		
		END IF;
		LET sBand = 0;
		
	
		-- Se obtienen los datos de los creditos MSI que se van a cancelar de acuerdo al folio_movto
		FOREACH
		  SELECT  {+avoid_full (bdicred:sd_promocion_credito)}
				  b.num_credito  , a.num_sol_prestamo, a.monto_actual, a.monto_int_iva, a.folio_movto   , a.folio_suc     , a.fecha        , a.num_promo, a.status     , 
				  b.num_producto , b.sucursal        , b.divisa      , b.numcte
		    INTO  cNum_Cred_tdc  , cNum_Cred_MSI     , v_monto_actual, v_monto_int_iva, cfolio_mov_promo, cfolio_suc_promo, dFecha_credisol, cTipo_promo, cStatus_promo, 
		          cNumProducto   , cSucursal         , cDivisa       , cNumCte 
		    FROM bdicred:"informix".sd_promocion_credito a
		    INNER JOIN bdicred:"informix".sd_maecred b ON (a.num_credito = b.num_credito and a.folio_movto = cFolioMovto and status = sStatus_cancel1 and a.sistema = '06' )
			INNER JOIN bdicred:"informix".sd_maesdos d ON (b.num_credito = d.num_credito)
		   WHERE b.status_cred IN ('AA','E1')
		     AND (d.monto_vencido + d.mto_venc_trasp) = 0
	
				
			-- El credito MSI no se puede cancelar el mismo dia que se dio de alta.		PENDIENTE DE CONFIRMAR
			/*IF dFecha_hoy <= dFecha_credisol THEN				
				CONTINUE FOREACH;
			END IF				
			*/

			-- Se obtiene el adeudo del credito MSI hasta le momento
			EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(pEmpresa,cNum_Cred_MSI)
				INTO CodRet, Mensaje, cCharAux, cCharAux, dtFechaApertura, dtFechaProxPago, dPagoMinAct, dtDateAux, iIntAux, iIntAux, dDecAux, dDecAux, dDecAux, dDecAux, vcap_vig, dDecAux, 
				dDecAux, dDecAux,dDecAux, dIntVig, dDecAux, dDecAux, dDecAux, dDecAux, dIvaIntVig, dDecAux, dDecAux, dDecAux, dDecAux, dDecAux, dDecAux, dDecAux,  dSdoAdeudTotalAct, 
				dIntDevengado, dIvaIntDevengado, dDecAux, dDecAux, cCharAux, iIntAux, cCharAux, cCharAux, cCharAux, cCharAux, iIntAux, cCharAux, cCharAux, iIntAux, cCharAux;

			IF dSdoAdeudTotalAct > 0 THEN
			
				-- Se realiza el pago por el monto correspondiente del credito MSI.     4210 Credisoluciones.   4250 Meses sin intereses
				CALL "informix".sp_cargo_abono_palzo(pEmpresa, cNum_Cred_MSI, '', dSdoAdeudTotalAct, USER, '9290', '4250', 3, '') RETURNING CodRet, Mensaje;

				IF CodRet::INTEGER <> 0 THEN
					RETURN CodRet, TRIM(Mensaje);
				ELSE
					LET CodRet = "000000";
				END IF;
				
				LET sBand = 1;
				
				SELECT sdo_retenido INTO dSdoRet_Orig FROM "informix".sd_maesdos WHERE num_credito = cNum_Cred_tdc;
				LET dSdoRet_Aux = dSdoRet_Orig - (v_monto_actual + v_monto_int_iva);
				IF dSdoRet_Aux < 0 THEN
					LET dSdoRet_Nvo = 0;
				ELSE
					LET dSdoRet_Nvo = dSdoRet_Aux;
				END IF;
				
				UPDATE bdicred:"informix".sd_maesdos SET sdo_retenido = dSdoRet_Nvo
				 WHERE num_credito = cNum_Cred_tdc;

				-- Se cambia estatus a 7 = Cancelado
				UPDATE bdicred:"informix".sd_promocion_credito SET status = 7
				 WHERE folio_movto = cFolioMovto
				   AND num_sol_prestamo = cNum_Cred_MSI;

				UPDATE bdicred:"informix".sd_maeretenido SET estatus = 'S'
				 WHERE empresa = '001'
				   AND num_credito = cNum_Cred_tdc
				   AND folio_suc = cfolio_mov_promo;

				UPDATE bdicred:"informix".sd_maeretenido SET estatus = 'S'
				 WHERE empresa = '001'
				   AND num_credito = cNum_Cred_tdc
				   AND NVL(SUBSTR(referencia,1,16),'') = cfolio_suc_promo;
				   
				UPDATE bdicred:"informix".sd_amortiza_creditocrd
				   SET capital_status = 5,
					   capital_status_ant = 1, 
					   interes_pagado = interes_debe,
					   interes_fecha_pago = dFecha_hoy,
					   iva_pagado = iva_debe,
					   iva_fecha_pago = dFecha_hoy							   
				 WHERE fecha_cuota = dFecha_hoy
				   AND num_credito = cNum_Cred_MSI;   
				   
				LET cStatus = 'A SOLICITUD DEL CLIENTE'; 
				   
				-- Si es por proceso BATCH si la tarjeta esta vencida es la descripcion que se registra en la tabla sd_cancela_credito_msi 
				IF NVL(cFolioMovto, '') = '' THEN 
				   
					LET pSucursal = '9250';
				   
					SELECT status_tar INTO cStatus_tar
				 	  FROM "informix".sd_tarjeta 
					 WHERE empresa = '001'
					   AND num_credito = cNum_Cred_tdc
					   AND tipo_tarjeta = 'T'
					   AND secuencia = (SELECT MAX(secuencia) FROM "informix".sd_tarjeta WHERE empresa = '001' AND num_credito = cNum_Cred_tdc AND tipo_tarjeta = 'T');
					IF cStatus_tar <> 'A' THEN
						LET cStatus = 'TARJETA VENCIDA';
					END IF							   
				END IF							   
				   
				-- Se agrega un registro cada vez que se cancela un credito MSI a la tabla sd_msi_cancela_credito_msi
				INSERT INTO bdicred:"informix".sd_msi_cancela_credito_msi (empresa , num_credito , folio_movto, fecha_cancela, motivo_de_cancelacion, tipo_promo , canal , sucursal , fecha_insert, user_insert)
				                                            VALUES (pempresa, cNum_Cred_MSI, TRIM(cFolioMovto), CURRENT      , TRIM(cStatus)        , cTipo_promo, pCanal, pSucursal, dFecha_hoy  , pUsuario);				

				-- Valida cuando es el mismo dia del mesiversario
				-- Realiza el cargo a la TDC de los montos pendientes de pago del credito MSI
				IF dtFechaProxPago - dFecha_hoy = 0 THEN 
					IF dIvaIntVig <> 0 THEN
						CALL "informix".sp_cargo_abono_palzo(pEmpresa, cNum_Cred_tdc, '', dIvaIntVig, USER, '9290', '4254', 1, cNum_Cred_MSI) RETURNING CodRet, Mensaje;
						IF CodRet::INTEGER <> 0 THEN
							RETURN CodRet, TRIM(Mensaje);
						ELSE
							LET CodRet = "000000";
						END IF;
					END IF; 

					IF dIntVig <> 0 THEN
						CALL "informix".sp_cargo_abono_palzo(pEmpresa, cNum_Cred_tdc, '', dIntVig, USER, '9290', '4255', 1, cNum_Cred_MSI) RETURNING CodRet, Mensaje;
						IF CodRet::INTEGER <> 0 THEN
						   RETURN CodRet, TRIM(Mensaje);
						ELSE
						 LET CodRet = "000000";
						END IF;
					END IF;

				ELSE 
					IF dIvaIntDevengado <> 0 THEN
						CALL "informix".sp_cargo_abono_palzo(pEmpresa, cNum_Cred_tdc, '', dIvaIntDevengado, USER, '9290', '4254', 1, cNum_Cred_MSI) RETURNING CodRet, Mensaje;
						IF CodRet::INTEGER <> 0 THEN
							RETURN CodRet, TRIM(Mensaje);
						ELSE
							LET CodRet = "000000";
						END IF;
					END IF;

					IF dIntDevengado <> 0 THEN
						CALL "informix".sp_cargo_abono_palzo(pEmpresa, cNum_Cred_tdc, '', dIntDevengado, USER, '9290', '4255', 1, cNum_Cred_MSI) RETURNING CodRet, Mensaje;
						IF CodRet::INTEGER <> 0 THEN
							RETURN CodRet, TRIM(Mensaje);
						ELSE
							LET CodRet = "000000";
						END IF;
					END IF;
				END IF;

				IF vcap_vig <> 0 THEN
					CALL "informix".sp_cargo_abono_palzo(pEmpresa, cNum_Cred_tdc, '', vcap_vig, USER, '9290', '4256', 1, cNum_Cred_MSI) RETURNING CodRet, Mensaje;
					IF CodRet::INTEGER <> 0 THEN
					   RETURN CodRet, TRIM(Mensaje);
					ELSE
						LET CodRet = "000000";
					END IF;
				END IF;
			END IF;

			LET dSdoAdeudTotalAct = 0;
			LET vcap_vig = 0;
			LET dIntDevengado = 0;
			LET dIvaIntDevengado = 0;

		END FOREACH;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 OR sBand = 0 THEN
			LET CodRet = '000001';
			IF cNumProducto = '6900' THEN
				LET Mensaje = 'CREDISOLUCION NO VALIDA PARA CANCELARSE';
			ELSE
				LET Mensaje = 'MSI NO VALIDA PARA CANCELARSE';
			END IF;	
		ELSE
			LET CodRet = '000000';
			IF cNumProducto = '6900' THEN
				Let Mensaje = 'CREDISOLUCIÓN CANCELADA CORRECTAMENTE';
			ELSE
				Let Mensaje = 'MSI CANCELADA CORRECTAMENTE';
			END IF;		
		END IF;		

		RETURN CodRet, TRIM(Mensaje);
	END;
END PROCEDURE
DOCUMENT
'--------------------------------------------------------------------------------------------------------------',
'Fecha: Octubre 2021																						   ',
'Descripcion: Se genera sp para realizar la cancelacion de creditos de Meses Sin Intereses: 8900			   ',
' se inserta registro en bitacora de cancelacion de MSI: sd_msi_cancela_credito_msi							   ',
'BD:BDICRED																									   ',
'--------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_msi_confirma_sms_msi(pEmpresa CHAR(3))
RETURNING CHAR(5);       -- Codigo de Retorno


	---DECLARACIONES
    DEFINE iSqlErr				INTEGER;
    DEFINE iIsamErr				INTEGER;
    DEFINE cErrorInfo			CHAR(80);
    DEFINE cCodRet				CHAR(5);
	DEFINE cCod_retIB			CHAR(6);
    DEFINE cMensajeRet			CHAR(80);
	DEFINE cProceso             CHAR(4);
	DEFINE dtFechaHoy			DATE;
	DEFINE cNumCredito          CHAR(20);
	DEFINE iRowID				INTEGER;	
	DEFINE cTipoMsgSms			CHAR(1);
	DEFINE cFolioPromo			CHAR(16);
	DEFINE cFolioComp_sms		CHAR(16);
	DEFINE cNumCel				CHAR(20);
	DEFINE sStatus_sms			SMALLINT;
	DEFINE cResp_Cte_sms		CHAR(1);
	DEFINE cEnvio_r_sms			CHAR(1);
	DEFINE sDiasEspera_sms		SMALLINT; 
	DEFINE dFechaCanc_sms		DATE;	 
	DEFINE cSucursal 			CHAR(4);
	DEFINE sNumPromocion		SMALLINT;
	DEFINE sPFijosSaldoSMS		SMALLINT;
	DEFINE dFecha_Invita		DATE;	 
	DEFINE dFecha_Aux			DATE;	 
	DEFINE dMontoCompra			DECIMAL(18,2);
	DEFINE sMensualidad			DECIMAL(18,2);
	DEFINE sPlazo				SMALLINT;
	DEFINE cNumCred_MSI			CHAR(20);
	DEFINE sTasa				DECIMAL(18,6);


	-------------------
	---INICIALIZACIONES
	
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= '';
	LET cCodRet				= '00000';
	LET cCod_retIB			= '';
	LET cMensajeRet			= 'PROCESO EXITOSO';
	LET cProceso			= '';	
	LET dtFechaHoy			= DATE(1);
	LET cNumCredito			= '';
	LET iRowID				= 0;
	LET cTipoMsgSms			= '';
	LET cFolioPromo			= '';
	LET cFolioComp_sms		= '';
	LET cNumCel				= '';
	LET sStatus_sms			= 0;
	LET cResp_Cte_sms		= 0;
	LET cEnvio_r_sms		= '';
	LET sDiasEspera_sms		= 0;	
	LET dFechaCanc_sms		= 0; 
	LET cSucursal			= '';
	LET sNumPromocion		= 0;
	LET sPFijosSaldoSMS		= 0;
	LET dFecha_Invita		= DATE(1);
	LET dFecha_Aux			= DATE(1);
	LET dMontoCompra		= 0;
	LET sMensualidad		= 0;
	LET sPlazo				= 0;
	LET cNumCred_MSI		= '';
	LET sTasa				= 0;
	

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||iIsamErr::CHAR||cNumCredito, '02') Returning cCod_retIB;
			RETURN cCodRet;
       END IF;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    --SET DEBUG FILE TO '/informix/mahr/sp_msi_confirma_sms_msi.out';
	--TRACE ON;
	
	--Se obtiene la fecha de hoy.
	SELECT fecha_hoy INTO dtFechaHoy FROM "informix".sd_fechas WHERE empresa = pEmpresa;
	
	
	--=====================================================================================================================
	-- Envio de sms por medio de latinia de forma batch. SMS que no fue posible enviar durante el proceso por estar fuera del horario permitido: 8 am a 8 pm. 			
	
	LET cProceso = '0116';
	LET cCodRet = '00000';
	LET cMensajeRet = '';
	CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, 'INICIA ENVIO (BATCH) DE SMS CON RESULTADO DEL PROCESO MSI.', '02') Returning cCod_retIB;
		
	LET dFecha_Aux = dtFechaHoy - 7 units day;
		 
	-- Identifica los creditos con mensajes pendientes de enviar.
	FOREACH WITH HOLD
        SELECT ROWID,  num_credito, folio_compra_sms, tipo_sms,    envio_result_sms, num_promo,	    fecha_invitacion
          INTO iRowID, cNumCredito, cFolioPromo, 	  sStatus_sms, cTipoMsgSms,      sNumPromocion, dFecha_Invita
          FROM bdicred:"informix".sd_promocion_credito_sms
         WHERE status_envio_r_sms = '0' AND num_promo = 10

		 -- Obtiene el numero de telefono ligado al credito 
		SELECT first 1 a.telefono INTO cNumCel
		  FROM bdinteg:si_telefonos a
		 INNER JOIN bdicred:sd_maecred b ON ( a.numcte = b.numcte ) -- and b.status_cred = 'AA' )
		 WHERE tipo_tel = 2
		   AND status_tel = 'A'
		   AND b.num_credito = cNumCredito;		
		   
		IF (cNumCel = '' OR cNumCel IS NULL) OR  (dFecha_Invita < dFecha_Aux )  THEN	-- Descarte el mensaje si no existe celular o fecha anterior.
		
			UPDATE bdicred:"informix".sd_promocion_credito_sms SET status_envio_r_sms = 'X'
			 WHERE num_credito = cNumCredito AND folio_compra_sms = cFolioPromo AND tipo_sms = sStatus_sms AND num_promo = sNumPromocion;
			CONTINUE FOREACH;
		END IF;
		   
	   
		IF NVL(cTipoMsgSms, '') = '1' THEN			-- Se envia mensaje de contratacion EXITOSA de Meses Sin Intereses

			SELECT monto_actual, mensualidad, plazo  , num_sol_prestamo 
			  INTO dMontoCompra, sMensualidad, sPlazo, cNumCred_MSI
			  FROM bdicred:sd_promocion_credito WHERE folio_movto = cFolioPromo AND num_credito = cNumCredito AND status = 2;

			SELECT tasa_interes INTO sTasa FROM bdicred:sd_maecredcrd WHERE num_credito = cNumCred_MSI;
			

			IF NVL(cNumCred_MSI, '') <> '' THEN
						
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','MSI_OK_1','000000000','', '',2, cFolioPromo, sPlazo, '', '', '', '', '', '', '', '', '',
																		cNumCel, dMontoCompra, sMensualidad, 0, sTasa, 0, current, current) INTO cCod_retIB;
				IF cCod_retIB <> '00000' THEN
					-- Se marca sms pendiente de enviar
					UPDATE bdicred:sd_promocion_credito_sms SET envio_result_sms = '1', status_envio_r_sms = '0' WHERE num_credito = cNumCredito AND folio_compra_sms = cFolioPromo;
					LET cCodRet = '00002';
					LET cMensajeRet = 'Error en envio de SMS de contratacion correcta.';
					CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCod_retIB, trim(cMensajeRet)||'-'||cNumCredito||'-'||cNumCel, '02') Returning cCod_retIB;
					RETURN cCodRet;
				END IF;
				
				-- Se marca sms enviado y numero de credito de Meses Sin Intereses generado.
				UPDATE bdicred:sd_promocion_credito_sms SET envio_result_sms = '1', status_envio_r_sms = '1', num_credisolucion = cNumCred_MSI	
				 WHERE num_credito = cNumCredito AND folio_compra_sms = cFolioPromo;		
			END IF;

	
		ELIF NVL(cTipoMsgSms, '') = '0' THEN		-- Se envia mensaje de error. No se pudo realizar la contratacion de Meses Sin Intereses
		
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','MSI_ERR_1','000000000','', '',2, '', '', '', '', '', '', '', '', '', '', '', 
																		cNumCel, 0, 0,0, 0, 0,current, current) INTO cCod_retIB;

			IF cCod_retIB <> '00000' THEN
				-- Se marca sms pendiente de enviar
				UPDATE bdicred:sd_promocion_credito_sms SET envio_result_sms = '0', status_envio_r_sms = '0' WHERE num_credito = cNumCredito AND folio_compra_sms = cFolioPromo;
				LET cCodRet = '00001';
				LET cMensajeRet = 'Error en envio de SMS de Error';
				CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCod_retIB, trim(cMensajeRet)||'-'||cNumCredito||'-'||cNumCel, '02') Returning cCod_retIB;
				RETURN cCodRet;
			END IF;
			-- Se marca sms enviado					
			UPDATE bdicred:sd_promocion_credito_sms SET envio_result_sms = '0', status_envio_r_sms = '1' WHERE num_credito = cNumCredito AND folio_compra_sms = cFolioPromo;		
		
		END IF;
		
		LET cCod_retIB = '00000';
		
	END FOREACH;

	LET cCodRet = '00000';
	LET cMensajeRet = '';
	CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, 'FINALIZA ENVIO (BATCH) DE SMS RESULTADO DEL PROCESO MSI.', '02') Returning cCod_retIB;
	
	
	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION:                            																														',
'	   Envio de sms por medio de latinia de forma batch. SMS que no fue posible enviar durante el proceso por estar fuera del horario permitido: 8 am a 8 pm. 	',
'FECHA DE CREACION:  Octubre 2021 																																',
'BD: bdicred																																					',
'	tipo_sms: 1 Invitacion realizada, 2 Espera conciliacion, 3 Conciliacion recibida, 4 Invit cancelada ERROR Dato Erroneo, 5 Invitacion Cancelada X vigencia, 	',
'			  6 Err en MSI  7 SMS con MSI																								        			   	',
'	envio_result_sms: 0.- Enviar SMS de Error, 1.- Mensaje sms OK: Se proceso MSI       														   				',	
'	status_envio_r_sms.- 0.- Msg sms pendiente de enviar, 1.- Msg sms enviado,  																	   			';

CREATE PROCEDURE "informix".sp_msi_proyecta_msi
(
	pTipo 			SMALLINT, 		-- 1- consulta proyeccion, 2-regresa el desglose, 3-guarda proyeccion
	pSucursal 		CHAR(4),
	pEjecutivo		CHAR(8),
	pNumPromocion 	SMALLINT, 		-- 10 Meses sin intereses
	pNumCredito 	CHAR(20),
	pNumTarjeta		CHAR(20),
	pMonto 			DECIMAL(18,2),
	pPlazo 			SMALLINT,
	pTasa			SMALLINT,
	pFolioMovto		CHAR(16)
)

RETURNING
	CHAR(6) 		AS cod_ret,
	CHAR(80)		AS descripcion,
	DECIMAL(18,2)	AS total_pagar,
	SMALLINT		AS num_plazo,
	DECIMAL(18,2)	AS pago_mensual,
	DECIMAL(18,2)	AS interes_iva,
	DECIMAL(18,2)	AS saldo_tdc,
	CHAR(16)		AS folio_promo,
	SMALLINT		AS Num_promocion;
	
	---DECLARACIONES
    DEFINE iSqlErr				INTEGER;
    DEFINE iIsamErr				INTEGER;
    DEFINE cErrorInfo			CHAR(80);
    DEFINE cCodRet				CHAR(5);
    DEFINE cMensajeRet			CHAR(80);
	DEFINE sNumPagos			SMALLINT;
	DEFINE dTasaAnual			DECIMAL(18,6);
	DEFINE dTasaAnualIva		DECIMAL(18,6);
	DEFINE dFactorIvaSucursal	DECIMAL(5,3);
	DEFINE dPagoMensual			DECIMAL(18,6);
	DEFINE dPagoPorPlazo		DECIMAL(18,6);
	DEFINE dInterIvaPlazoMax	DECIMAL(18,6);
	DEFINE dValorMinDiferir		DECIMAL(18,6);
	DEFINE dMontoDiferir		DECIMAL(18,6);
	DEFINE dTotalPagar			DECIMAL(18,6);
	DEFINE vcNumCte				VARCHAR(20);
	DEFINE cCodRetGF			CHAR(6);
	DEFINE cFolioSucGF			CHAR(16);
	DEFINE vcNomEjecutivo		VARCHAR(45);
	DEFINE vcNomPromocion		VARCHAR(50);
	DEFINE dSaldoTDC			DECIMAL(18,2);
	DEFINE cFolioPromo			CHAR(16);
	DEFINE dtFechaHoy			DATE;
	DEFINE dtFechaCorte			DATE;
	DEFINE dMontoPromo			DECIMAL(18,2);
	DEFINE cCodRetGenMov	  CHAR(10);
	DEFINE cMsjeGenMov		  CHAR(80);
    DEFINE vsucorig           CHAR(4);
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
	DEFINE cCsg_codigo_ret			CHAR(6);
	DEFINE dCsg_cap_vig				DECIMAL(18,2);	
	DEFINE dCsg_tot_liquidacion		DECIMAL(18,2);	
	DEFINE dCsg_linea_disp			DECIMAL(18,2);
    DEFINE vcompras                 SMALLINT;
	DEFINE dMontoDiferir_aux	    DECIMAL(18,6);
    DEFINE vdivisa                  CHAR(2);
    DEFINE v_dv                     CHAR(2);
    DEFINE v_tipocambio             DECIMAL(14,6);
    -- VARIABLES PARA OBTENER RESPUESTA DEL SP: sp_proyecta_prest_credisol
    DEFINE c_CodigoRet_pp           CHAR(6);
    DEFINE i_Periodo_pp             INTEGER;
    DEFINE d_FechaCouta_pp          DATE;
    DEFINE dd_SaldoInicial_pp       DECIMAL(18,2);
    DEFINE dd_Mensualidad_pp        DECIMAL(18,2);
    DEFINE dd_Mensualidad_aux_pp    DECIMAL(18,2);
    DEFINE dd_Intereses_pp          DECIMAL(18,2);
    DEFINE dd_IvaInteres_pp         DECIMAL(18,2);
    DEFINE dd_Capital_pp            DECIMAL(18,2);
    DEFINE dd_SaldoFinal_pp         DECIMAL(18,2);
    DEFINE dd_SaldoFinal_aux_pp     DECIMAL(18,2);
    DEFINE s_DiasPeriodo_pp         SMALLINT;
    DEFINE d_FechaAper_pp           DATE;
    DEFINE c_NumMesesPago_pp        CHAR(3);
    DEFINE i_Cont                   SMALLINT;
    DEFINE v_NumCredito             CHAR(20);
	DEFINE sCountExists				INTEGER;
	DEFINE sYield					INTEGER;	
	DEFINE cBandera268				CHAR(1);
	

	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= '';
	LET cCodRet				= '00000';
	LET cMensajeRet			= 'PROCESO EXITOSO';
	LET sNumPagos			= 0;
	LET dTasaAnual			= 0.0;
	LET dTasaAnualIva		= 0.0;
	LET dFactorIvaSucursal	= 0.0;
	LET dPagoMensual		= 0.0;
	LET dPagoPorPlazo		= 0.0;
	LET dInterIvaPlazoMax	= 0.0;
	LET dValorMinDiferir	= 0.0;
	LET dMontoDiferir		= 0.0;
	LET dTotalPagar			= 0.0;
	LET vcNumCte			= '';
	LET cCodRetGF			= '000000';
	LET cFolioSucGF			= '';
	LET vcNomEjecutivo		= '';
	LET vcNomPromocion		= '';
	LET dSaldoTDC			= 0.0;
	LET cFolioPromo			= '';
	LET dtFechaHoy			= DATE(1);
	LET dtFechaCorte		= DATE(1);
	LET dMontoPromo			= 0.0;
	LET cCodRetGenMov		= "";
	LET cMsjeGenMov		    = "";
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
	LET cCsg_codigo_ret				= "000000";
	LET dCsg_cap_vig				= 0.0;		
	LET dCsg_tot_liquidacion		= 0.0;
	LET dCsg_linea_disp				= 0.0;
    LET vcompras                    = 0;
	LET dMontoDiferir_aux	        = 0;
    LET vdivisa                     = '00';
    LET v_dv                        = "00";
    LET v_tipocambio                = 0;
    LET vsucorig                    = "";
    -- VARIABLES PARA OBTENER RESPUESTA DEL SP: sp_proyecta_prest_credisol
    LET c_CodigoRet_pp              = '';
    LET i_Periodo_pp                = 0;
    LET d_FechaCouta_pp             = MDY(1,1,1900);
    LET dd_SaldoInicial_pp          = 0.0;
    LET dd_Mensualidad_pp           = 0.0;
    LET dd_Mensualidad_aux_pp       = 0.0;
    LET dd_Intereses_pp             = 0.0;
    LET dd_IvaInteres_pp            = 0.0;
    LET dd_Capital_pp               = 0.0;
    LET dd_SaldoFinal_pp            = 0.0;
    LET dd_SaldoFinal_aux_pp        = 0.0;
    LET s_DiasPeriodo_pp            = 0;
    LET d_FechaAper_pp              = MDY(1,1,1900);
    LET c_NumMesesPago_pp           = '';
    LET i_Cont                      = 0;
    LET v_NumCredito                ='';
	LET sCountExists				= 0;
	LET sYield						= 0;
	LET cBandera268					= '0';


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet, cMensajeRet, NVL(dTotalPagar,0), NVL(pPlazo,0), NVL(dPagoMensual,0), NVL(dInterIvaPlazoMax,0), NVL(dSaldoTDC,0), NVL(cFolioPromo,''), NVL(pNumPromocion,0);
       END IF;
    END EXCEPTION;
	
	ON EXCEPTION IN (-268) SET iSqlErr, iIsamErr, cErrorInfo
		IF cBandera268 = '1' THEN  -- El error es por insertar en la tabla sd_promocion_credito
			SELECT
				year(current) || lpad(month(current),2,0) || lpad(day(current),2,0)
				|| substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,1,2)
				||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,4,2)
				||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,7,2)
				||lpad(bdicheq:sp_random(),2,'0'), sysmaster:yieldn( 1 )
			  INTO cFolioSucGF, sYield FROM sysmaster:sysshmvals;

			--SET DEBUG FILE TO '/informix/mahr/sp_proy_pfsms.out';
			--TRACE ON;
			LET cFolioPromo = cFolioSucGF;
			LET cCodRet = '00000';
			LET cMensajeRet = '';
		
			INSERT INTO "informix".sd_promocion_credito
				(empresa,sistema,num_promo,fecha,ejecutivo,num_cte,num_credito,num_tarjeta,plazo,folio_suc,monto_actual,monto_int_iva,mensualidad,status,nombre_promo,sucursal,num_sol_prestamo,num_pro_prestamo,folio_movto)
			VALUES ('001','06',pNumPromocion,dtFechaHoy,pEjecutivo,vcNumCte, pNumCredito,pNumTarjeta,pPlazo,cFolioSucGF,pMonto,dInterIvaPlazoMax,dPagoMensual,0,vcNomPromocion,pSucursal,'','6900',pFolioMovto);
	  
	  ELSE
			RETURN cCodRet, cMensajeRet, NVL(dTotalPagar,0), NVL(pPlazo,0), NVL(dPagoMensual,0), NVL(dInterIvaPlazoMax,0), NVL(dSaldoTDC,0), NVL(cFolioPromo,''), NVL(pNumPromocion,0);	  
	  END IF;
	END EXCEPTION WITH RESUME;
   

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    --SET DEBUG FILE TO '/tmp/sp_msi_proyecta_msi.out';
	--TRACE ON;
	  
	-- Obtiene la fecha del dia de hoy.
	SELECT fecha_hoy INTO dtFechaHoy FROM "informix".sd_fechas WHERE empresa = '001';	  

	-- Obtiene valores de tipos de cambio
	SELECT valor INTO v_dv FROM bdinteg:si_param WHERE cod_param = 17;
    SELECT precio_venta INTO v_tipocambio FROM bdinteg:"informix".si_tpcambio
	 WHERE empresa = "001" AND divisa = v_dv AND clase_tpcambio = "O" AND fecha_tpcambio = (SELECT MAX(fecha_tpcambio) FROM bdinteg:"informix".si_tpcambio
																						     WHERE empresa = "001" AND divisa = v_dv);

	-- Valida que los parametros no vengan vacios
    IF pTipo IS NULL OR NVL(pSucursal,'') = '' OR NVL(pEjecutivo,'') = '' OR pNumPromocion IS NULL
			OR (NVL(pNumCredito,'') = '' AND NVL(pNumTarjeta,'') = '') OR (pTipo = 1 AND pMonto IS NULL)
			OR (pTipo = 2 AND pMonto IS NULL) OR (pTipo = 3 AND NVL(pMonto,0) = 0)
			OR (pTipo = 1 AND pPlazo IS NULL) OR (pTipo = 2 AND pPlazo IS NULL )
			OR (pTipo = 3 AND NVL(pPlazo,0) = 0) THEN
		LET cCodRet = '00432';
		LET cMensajeRet = 'FALTA UNO O MAS PARAMETROS';
    END IF;
	
	-- Valida tipo de ejecucion
	IF cCodRet = '00000' AND pTipo NOT IN (1,2,3) THEN
		LET cCodRet = '00434';
		LET cMensajeRet = 'EL PARAMETRO TIPO NO ES VALIDO';
	END IF;
	
	-- Valida el ejecutivo y obtiene su nombre.
	/*IF cCodRet = '00000' THEN
		SELECT nombre INTO vcNomEjecutivo 
		  FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = pEjecutivo;
		IF NVL(vcNomEjecutivo,'') = '' THEN
			LET cCodRet = '00435';
			LET cMensajeRet = 'CODIGO DE EJECUTIVO NO ES VALIDO';
		END IF;
	END IF;*/

	/*
	-- Obtiene Valor de monto minimo a diferrir 
	IF cCodRet = '00000' THEN	
		SELECT TRIM(valor)::DECIMAL(18,2) INTO dValorMinDiferir				-- ???? PENDIENTE
		  FROM "informix".sd_param WHERE cod_param  = '029';
		IF dValorMinDiferir IS NULL THEN
			LET cCodRet = '00437';
			LET cMensajeRet = 'ERROR AL OBTENER EL PARAMETRO DEL VALOR MINIMO A DIFERIR';
		END IF;
	END IF;
	*/

	-- Proyeccion Especial (X tasa, X plazo)
	LET sCountExists = 0;
	
	-- Valida que al menos reciba el numero de credito o la tarjeta validos
    IF cCodRet = '00000' AND (NVL(pNumCredito,'') = '' OR NVL(pNumTarjeta,'') = '' ) THEN
		IF NVL(pNumCredito,'') <> '' THEN
            SELECT num_credito, numcte  , divisa , sucursal
			  INTO pNumCredito, vcNumCte, vdivisa, vsucorig
			  FROM bdicred:"informix".sd_maecred 
		     WHERE empresa = '001' AND num_credito = pNumCredito;
             --AND status_cred = 'AA';

            IF NVL(pNumCredito,'') = '' THEN
                LET cCodRet = '00439';
				LET cMensajeRet = 'NUMERO DE CREDITO NO ES VALIDO';
			END IF
        ELIF NVL(pNumTarjeta,'') <> '' THEN

            SELECT a.num_tarjeta, b.num_credito, a.numcte, b.divisa,sucursal
		  	  INTO pNumTarjeta, pNumCredito, vcNumCte,vdivisa,vsucorig
			  FROM "informix".sd_tarjeta a, "informix".sd_maecred b
			 WHERE a.empresa = b.empresa
               AND a.num_credito = b.num_credito
               AND a.num_tarjeta = pNumTarjeta
               AND a.tipo_tarjeta = 'T'
               AND a.status_tar IN ('A', 'I');
               --AND b.status_cred = 'AA';

            IF NVL(pNumTarjeta,'') = '' THEN
                LET cCodRet = '00440';
				LET cMensajeRet = 'NUMERO DE TARJETA NO ES VALIDO O SU CREDITO NO ES VALIDO';
			END IF;
		END IF;
	END IF;

    -- Valida el numero de promocion
    IF cCodRet = '00000' THEN
        SELECT nombre_promo INTO vcNomPromocion FROM "informix".sd_promocion WHERE num_promo = pNumPromocion;
        IF NVL(vcNomPromocion,'') = '' THEN
            LET cCodRet = '00436';
            LET cMensajeRet = 'EL PARAMETRO NUMERO DE PROMOCION NO ES VALIDO';
        END IF;
    END IF;

	--	Obtiene saldos del credito
    IF cCodRet = '00000' THEN
			
		SELECT sdo_capital,  (monto_otorgado - (sdo_cap_insoluto + sdo_retenido)), (sdo_cap_insoluto + sdo_retenido) 
		  INTO dCsg_cap_vig, dCsg_linea_disp,									   dCsg_tot_liquidacion
		  FROM bdicred:sd_maesdos WHERE num_credito = pNumCredito;			
		LET cCsg_codigo_ret = '000000';

		IF cCsg_codigo_ret::INTEGER <> 0 THEN
            LET cCodRet = '00441';
			LET cMensajeRet = 'OCURRIO UN ERROR LA CONSULTA DE SALDOS';
		ELSE
			IF pTipo = 1 THEN
				IF pPlazo = 0 THEN LET sNumPagos = 0; ELSE LET sNumPagos = pPlazo; END IF;
				LET sNumPagos = pPlazo;
                IF NVL(sNumPagos,0) = 0 THEN
					LET cCodRet = '00443';
					LET cMensajeRet = 'EL PLAZO NO ES VALIDO PARA LA PROMOCION';
				END IF;
			END IF;

				
            IF cCodRet = '00000' THEN
				LET dTasaAnual = pTasa;
					
				-- Valida que la sucursal exista y ademas obtiene el iva
				SELECT iva INTO dFactorIvaSucursal FROM bdinteg:"informix".si_sucursales WHERE sucursal = pSucursal;
				IF cCodRet = '00000' AND NVL(dFactorIvaSucursal,0.0) = 0.0 THEN
					LET cCodRet = '00444';
					LET cMensajeRet = 'SUCURSAL NO EXISTE O FALTA FACTOR DE IVA DE SUCURSAL';
				END IF;

				-- Calcula la tasa con iva
				LET dTasaAnualIva = (dTasaAnual/100) * (1 + dFactorIvaSucursal);
				IF cCodRet = '00000' THEN

					--ELIF pNumPromocion in (2, 5, 8 )THEN
                    IF pTipo = 1 THEN
						IF DAY(dtFechaHoy) > 20 THEN
							LET dtFechaCorte = MDY(MONTH(dtFechaHoy),20,YEAR(dtFechaHoy));
						ELSE
							EXECUTE PROCEDURE bdicred:"informix".monthadd(dtFechaHoy, -1) INTO dtFechaCorte;
							LET dtFechaCorte = MDY(MONTH(dtFechaCorte),20,YEAR(dtFechaCorte));
						END IF;
                        LET dtFechaCorte = dtFechaCorte + 1;

						IF NVL(dMontoDiferir,0) = 0 THEN
							-- Obtiene el monto maximo de las compras de creditos en los movimientos historicos
							LET sCountExists = 0;  -- Valida si busca en movdia o en movhis. sCountExists = 1 ==> Existe en movdia 
							FOREACH
								SELECT {AVOID_FULL("informix".sd_movdia)} nvl(monto,0) INTO dMontoDiferir_aux
								  FROM "informix".sd_movdia a 
								  JOIN bdinteg:"informix".si_transacc b ON (a.empresa = b.empresa and a.num_credito = pNumCredito and a.empresa = '001') 
								 WHERE a.num_credito = pNumCredito
								   AND a.fecha_mov = dtFechaHoy
								   AND a.codigo_ref IN (37,57)
								   AND a.folio_suc = pFolioMovto
								   AND a.reversado = 'N'
								   AND a.transacc_suc = b.numero
								   AND b.naturaleza = 'C'
								   AND b.sistema = '06'
							   
								IF dMontoDiferir_aux = 0 THEN
									LET dPagoMensual = 0;			LET dPagoPorPlazo = 0;			LET dInterIvaPlazoMax = 0;
                                    LET dTotalPagar = 0;			LET dMontoDiferir_aux = 0;
                                    CONTINUE FOREACH;
									
								--ELIF dMontoDiferir_aux <> 0 AND dCsg_tot_liquidacion >= dMontoDiferir_aux THEN
								ELIF dMontoDiferir_aux <> 0 THEN
								
									LET i_Cont = 0;						LET dd_SaldoFinal_pp = 0;		LET pPlazo = pPlazo;
									LET v_NumCredito = pNumCredito;		LET sCountExists = 1;
											
									FOREACH
										EXECUTE PROCEDURE bdicred:"informix".sp_proyecta_prest_credisol(pMonto,pPlazo::INTEGER,0,'6900',pSucursal,1,0,v_NumCredito,null,1,pNumPromocion::INTEGER, '1', pTasa) 
										   INTO c_CodigoRet_pp, i_Periodo_pp, d_FechaCouta_pp, dd_SaldoInicial_pp, dd_Mensualidad_aux_pp, dd_Intereses_pp, dd_IvaInteres_pp, 
                                                dd_Capital_pp, dd_SaldoFinal_aux_pp, s_DiasPeriodo_pp, d_FechaAper_pp, c_NumMesesPago_pp

										IF c_CodigoRet_pp != '000000' THEN
											LET cMensajeRet = 'ERROR AL EJECUTAR sp_proyecta_prest_credisol';
											RETURN c_CodigoRet_pp, TRIM(cMensajeRet), NVL(dTotalPagar,0), NVL(pPlazo,0), NVL(dPagoMensual,0), NVL(dInterIvaPlazoMax,0), NVL(dSaldoTDC,0), TRIM(cFolioPromo), NVL(pNumPromocion,0);
										END IF;

                                        LET i_Cont = i_Cont + 1;
                                        IF i_Cont = 1 THEN
											LET dd_Mensualidad_pp = dd_Mensualidad_aux_pp;
                                        END IF;
										LET dd_SaldoFinal_pp = dd_SaldoFinal_pp + dd_Mensualidad_aux_pp;
									END FOREACH;

									LET dPagoMensual = dd_Mensualidad_pp;
									LET dPagoPorPlazo = dd_SaldoFinal_pp;
									LET dInterIvaPlazoMax = dPagoPorPlazo - dMontoDiferir_aux;
									LET dTotalPagar = dd_SaldoFinal_pp;

									IF dCsg_linea_disp > (dInterIvaPlazoMax) THEN
										LET dPagoMensual = 0;		LET dPagoPorPlazo = 0;		LET dInterIvaPlazoMax = 0;		LET dTotalPagar = 0;		LET vcompras = 1;
										LET dMontoDiferir = dMontoDiferir_aux;
									ELSE
										CONTINUE FOREACH;
									END IF;
								END IF;
							END FOREACH;
							IF sCountExists = 0 THEN -- Busca en movhis
								FOREACH
									SELECT nvl(monto,0) INTO dMontoDiferir_aux
									  FROM "informix".sd_movhis a, bdinteg:"informix".si_transacc b
									 WHERE a.empresa = b.empresa
									   --AND a.fecha_mov >= dtFechaCorte
									   --AND a.fecha_mov <= dtFechaHoy
									   AND a.transacc_suc = b.numero
									   AND a.num_credito = pNumCredito
									   AND folio_suc = pFolioMovto
									   AND b.naturaleza = 'C'
									   AND b.sistema = '06'
									   AND a.reversado = 'N'
									   --AND a.codigo_ref IN (31,51)
									   AND a.codigo_ref IN (37,57)
									   --AND a.monto >= dValorMinDiferir
											   
									IF dMontoDiferir_aux = 0 THEN
										LET dPagoMensual = 0;		LET dPagoPorPlazo = 0;		LET dInterIvaPlazoMax = 0;		LET dTotalPagar = 0;		LET dMontoDiferir_aux = 0;
										CONTINUE FOREACH;
									--ELIF dMontoDiferir_aux <> 0 AND dCsg_tot_liquidacion >= dMontoDiferir_aux THEN
									ELIF dMontoDiferir_aux <> 0 THEN
										LET i_Cont = 0;					LET dd_SaldoFinal_pp = 0;	LET pPlazo = pPlazo;
										LET v_NumCredito=pNumCredito;

										FOREACH
											EXECUTE PROCEDURE bdicred:"informix".sp_proyecta_prest_credisol(pMonto,pPlazo::INTEGER,0,'6900',pSucursal,1,0,v_NumCredito,null,1,pNumPromocion::INTEGER, '1', pTasa) INTO
												c_CodigoRet_pp, i_Periodo_pp, d_FechaCouta_pp, dd_SaldoInicial_pp, dd_Mensualidad_aux_pp, dd_Intereses_pp, dd_IvaInteres_pp, 
												dd_Capital_pp, dd_SaldoFinal_aux_pp, s_DiasPeriodo_pp, d_FechaAper_pp, c_NumMesesPago_pp

											IF c_CodigoRet_pp != '000000' THEN
												LET cMensajeRet = 'ERROR AL EJECUTAR sp_proyecta_prest_credisol';
												RETURN c_CodigoRet_pp, TRIM(cMensajeRet), NVL(dTotalPagar,0), NVL(pPlazo,0), NVL(dPagoMensual,0), NVL(dInterIvaPlazoMax,0), NVL(dSaldoTDC,0), TRIM(cFolioPromo), NVL(pNumPromocion,0);
											END IF;

											LET i_Cont = i_Cont + 1;
											IF i_Cont = 1 THEN
												LET dd_Mensualidad_pp = dd_Mensualidad_aux_pp;
											END IF;
											LET dd_SaldoFinal_pp = dd_SaldoFinal_pp + dd_Mensualidad_aux_pp;
										END FOREACH;

										LET dPagoMensual = dd_Mensualidad_pp;
										LET dPagoPorPlazo = dd_SaldoFinal_pp;
										LET dInterIvaPlazoMax = dPagoPorPlazo - dMontoDiferir_aux;
										LET dTotalPagar = dd_SaldoFinal_pp;

										IF dCsg_linea_disp > (dInterIvaPlazoMax) THEN
											LET dPagoMensual = 0;		LET dPagoPorPlazo = 0;		LET dInterIvaPlazoMax = 0;		LET dTotalPagar = 0;		LET vcompras = 1;
											LET dMontoDiferir = dMontoDiferir_aux;
										ELSE
											CONTINUE FOREACH;
										END IF;
									END IF;
								END FOREACH;
							END IF;
						END IF;

                    ELIF pTipo IN (2,3) THEN
						LET dMontoDiferir = pMonto;
					END IF;

					IF (vcompras = 0 AND NVL(dMontoDiferir,0) = 0) THEN
						LET cCodRet = '05433';
						LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
					ELSE
						-- Calcula el pago mensual
						LET i_Cont = 0;			LET dd_SaldoFinal_pp = 0;		LET pPlazo = pPlazo;		LET v_NumCredito=pNumCredito;
						FOREACH
							EXECUTE PROCEDURE bdicred:"informix".sp_proyecta_prest_credisol(pMonto,pPlazo::INTEGER,0,'6900',pSucursal,1,0,v_NumCredito,null,1,pNumPromocion::INTEGER, '1', pTasa) INTO
								c_CodigoRet_pp, i_Periodo_pp, d_FechaCouta_pp, dd_SaldoInicial_pp, dd_Mensualidad_aux_pp, dd_Intereses_pp, dd_IvaInteres_pp, 
								dd_Capital_pp, dd_SaldoFinal_aux_pp, s_DiasPeriodo_pp, d_FechaAper_pp, c_NumMesesPago_pp

							IF c_CodigoRet_pp != '000000' THEN
								LET cMensajeRet = 'ERROR AL EJECUTAR sp_proyecta_prest_credisol';
								RETURN c_CodigoRet_pp, TRIM(cMensajeRet), NVL(dTotalPagar,0), NVL(pPlazo,0), NVL(dPagoMensual,0), NVL(dInterIvaPlazoMax,0), NVL(dSaldoTDC,0), TRIM(cFolioPromo), NVL(pNumPromocion,0);
							END IF;

							LET i_Cont = i_Cont + 1;
							IF i_Cont = 1 THEN
								LET dd_Mensualidad_pp = dd_Mensualidad_aux_pp;
							END IF;
							LET dd_SaldoFinal_pp = dd_SaldoFinal_pp + dd_Mensualidad_aux_pp;
						END FOREACH;
						LET dPagoMensual = dd_Mensualidad_pp;
						-- Calcula el pago por plazo
						LET dPagoPorPlazo = dd_SaldoFinal_pp;
						-- Calcula el interes e iva a plazo maximo
						LET dInterIvaPlazoMax = dPagoPorPlazo - dMontoDiferir;
						LET dTotalPagar = dd_SaldoFinal_pp;
						-- Valida si la proyeccion es de tipo consulta

						IF cCodRet = '00000' AND pTipo = 1 THEN
							IF dCsg_linea_disp < (dInterIvaPlazoMax) THEN
								LET cCodRet = '06433';
								LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
							END IF
							LET dTotalPagar = dTotalPagar;
							LET sNumPagos = sNumPagos;
							LET dPagoMensual = dPagoMensual;
							LET dInterIvaPlazoMax = dInterIvaPlazoMax;
						-- Valida si la proyeccion es para retornar el desglose
						ELIF cCodRet = '00000' AND pTipo = 2 THEN
							-- Valida que si trae el folio del movimiento que se recibe cuando se manda a llamar el proceso desde el proceso nocturno
							IF NVL(pFolioMovto,"") <> "" THEN
								-- Obtiene el monto de los intereses retenidos de la promocion por medio del folio del movto
								SELECT SUM(monto_actual + monto_int_iva) INTO dMontoPromo
								  FROM  "informix".sd_promocion_credito  
								 WHERE status = 0 AND fecha = dtFechaHoy AND num_credito = pNumCredito AND num_promo = pNumPromocion AND folio_movto = pFolioMovto;
								LET dMontoPromo = NVL(dMontoPromo,0.0);
							END IF;
							--IF dCsg_linea_disp < 0 THEN
							IF dCsg_linea_disp < dInterIvaPlazoMax THEN
								LET cCodRet = '07433';
								LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
							END IF;
                            -- Valida si la proyeccion es para guardar el desglose en tabla
						ELIF cCodRet = '00000' AND pTipo = 3 THEN
							IF dCsg_linea_disp < dInterIvaPlazoMax THEN
								LET cCodRet = '08433';
								LET cMensajeRet = 'EL CLIENTE NO ES VIABLE PARA DIFERIR ';
							ELSE
								-- Proceso generico para generar un folio
								LET cCodRetGF = '000000';
								SELECT --pEjecutivo 
									year(current) || lpad(month(current),2,0) || lpad(day(current),2,0)
									|| substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,1,2)
									||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,4,2)
									||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,7,2)
									||lpad(bdicheq:sp_random(),2,'0')
								INTO cFolioSucGF 
								FROM sysmaster:sysshmvals;
								-------
								-- Valida folio no exista y lo recalcula si existe
								LET sCountExists = 0;  
								SELECT COUNT(folio_suc) INTO sCountExists FROM bdicred:"informix".sd_promocion_credito 
								 WHERE empresa = '001' AND folio_suc = cFolioSucGF;
								IF sCountExists > 0 THEN
									SELECT --pEjecutivo 
										year(current) || lpad(month(current),2,0) || lpad(day(current),2,0)
										|| substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,1,2)
										||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,4,2)
										||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,7,2)
										||lpad(bdicheq:sp_random(),2,'0'), sysmaster:yieldn( 1 )
									  INTO cFolioSucGF, sYield FROM sysmaster:sysshmvals;
								END IF;
								-------											
									
								IF cCodRetGF::INTEGER <> 0 THEN
									LET cCodRet = '00447';
									LET cMensajeRet = 'OCURRIO UN ERROR EN EL PROCESO QUE GENERA EL FOLIO';
									LET dTotalPagar = 0;		LET sNumPagos = 0;		LET dPagoMensual = 0;		LET dInterIvaPlazoMax = 0;
								ELSE
									LET cFolioPromo = cFolioSucGF;
									-- Guarda los datos de la promocion
									LET cBandera268 = '1';
									INSERT INTO "informix".sd_promocion_credito
									   (empresa,sistema,num_promo,fecha,ejecutivo,num_cte,num_credito,num_tarjeta,plazo,folio_suc,monto_actual,monto_int_iva,mensualidad,status,nombre_promo,sucursal,num_sol_prestamo,num_pro_prestamo,folio_movto)
										VALUES ('001','06',pNumPromocion,dtFechaHoy,pEjecutivo,vcNumCte, pNumCredito,pNumTarjeta,pPlazo,cFolioSucGF,pMonto,dInterIvaPlazoMax,dPagoMensual,0,vcNomPromocion,pSucursal,'','8900',pFolioMovto);
									LET cBandera268 = '0';
									-- Realiza el retenido por el monto de los intereses e iva para evitar sobregiro 
									INSERT INTO "informix".sd_maeretenido
									   (empresa,num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori)
									   VALUES('001',pNumCredito,cFolioSucGF,dtFechaHoy,CURRENT HOUR TO FRACTION(3),'6837',0,dInterIvaPlazoMax,pEjecutivo,'R',cFolioSucGF||' RET. MESES SIN INTERESES',pSucursal,0);
									-- Actualiza el saldo retenido en el maestro de saldos
									UPDATE "informix".sd_maesdos SET sdo_retenido = sdo_retenido + dInterIvaPlazoMax
									 WHERE num_credito = pNumCredito AND empresa = '001';
									-- Genera el movimiento del retenido de los intereses
									EXECUTE PROCEDURE "informix".genmov_tc('001',pNumCredito,'6001',dtFechaHoy,dInterIvaPlazoMax,cFolioSucGF,pSucursal,vdivisa,'6837','','RET. de INT. e Iva MSI',v_tipocambio,0,pEjecutivo,vsucorig,'','')
									INTO cCodRetGenMov, cMsjeGenMov;
								END IF;
							END IF;
						END IF;
					END IF;
				END IF;
			END IF;
		END IF;
	END IF;

    IF cCodRet <> '00000' THEN
        INSERT INTO "informix".sd_bitacora_promocion VALUES('001', pNumCredito, 'sp_msi_proyecta_msi', dtFechaHoy, CURRENT, pTipo, pNumPromocion, cCodRet);
    END IF;

	RETURN cCodRet, TRIM(cMensajeRet), NVL(dTotalPagar,0), NVL(pPlazo,0), NVL(dPagoMensual,0), NVL(dInterIvaPlazoMax,0), NVL(dSaldoTDC,0), TRIM(cFolioPromo), NVL(pNumPromocion,0);

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obtener el desglose de informacion de saldos del credito y validar si es viable el cliente para Meses sin intereses',
'MODIFICO: Martha A Hernandez Rodiguez',
'BD: bdicred';

CREATE PROCEDURE "informix".calcula_meses_fin(o_empresa CHAR(3),
											  o_producto CHAR(4),
											  o_saldo_no_exigible DECIMAL (18,2),
                                              o_monto_otorgado DECIMAL (18,2),
                                              o_tasa DECIMAL (9,4),
                                              o_iva DECIMAL(9,4),
                                              o_fecha_calculo date)

	RETURNING CHAR(5) AS retorno_error,
              INTEGER AS meses_fin;

	-- *********************************************************************
	-- *                        DEFINICION DE VARIABLES                    *
	-- *********************************************************************
	DEFINE scod_ret                	CHAR(5);
	DEFINE p_cod_ret               	CHAR(6);
	DEFINE vsqlerr                 	INTEGER;
	DEFINE wfecha_hoy              	DATE;
    DEFINE vFactorPagoMin           SMALLINT;
    DEFINE TopeMinimo               DECIMAL(14,2);
    DEFINE vFactorPagoMinLinC       DECIMAL (4,4);
    DEFINE wmeses_fin               INTEGER;
    DEFINE wbandera                 SMALLINT;
    DEFINE MontoFinanciado          DECIMAL(14,2);
    DEFINE wfinincimainto           DECIMAL(14,2);
    DEFINE wdias                    SMALLINT;
    DEFINE vFactorPorcentual        DECIMAL(18,2);

	-- ****************************************************************************
	-- *                        ASIGNACION DE VARIABLES                           *
	-- ****************************************************************************

--    SET DEBUG FILE TO "calcula_meses_fin.out"; 
--    TRACE ON;

	LET scod_ret                = "00000";
	LET p_cod_ret               = "000000";
	LET vsqlerr                 = 0;
	LET wfecha_hoy             = DATE(1);
    LET vFactorPagoMin           = 0;
    LET TopeMinimo               = 0;
    LET vFactorPagoMinLinC       = 0;
    LET wmeses_fin               = 0;
    LET wbandera                 = 0;
    LET MontoFinanciado          = 0;
    LET wfinincimainto           = 0;
    LET wdias                    = 0;
    LET vFactorPorcentual        = 0;

	-- ****************************************************************************
	-- *                        CONTROL DE ERRORES                                *
	-- ****************************************************************************

	BEGIN
		ON EXCEPTION SET vsqlerr
		   IF vsqlerr != 0 THEN
			  LET scod_ret=vsqlerr;
			  RETURN scod_ret, 0;
		   END IF;
		END EXCEPTION;

	-- ****************************************************************************
	-- *                        PROGRAMA PRINCIPAL                                *
	-- ****************************************************************************

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        IF (o_saldo_no_exigible <= 0) THEN
            RETURN scod_ret, 0;
        END IF;

        SELECT factor_pago_min::SMALLINT, mto_pago_min::DECIMAL, fact_pag_min_lc 
          INTO vFactorPagoMin, TopeMinimo, vFactorPagoMinLinC 
          FROM bdicred:sd_definicion 
         WHERE empresa = o_empresa 
           and num_producto = o_producto;

        IF ( o_saldo_no_exigible <= TopeMinimo ) THEN
            RETURN scod_ret, 1; 
        END IF;

        WHILE wbandera = 0
            LET wmeses_fin = wmeses_fin + 1;
            LET vFactorPorcentual = vFactorPagoMin/100;
			
            LET MontoFinanciado = ROUND((o_saldo_no_exigible * vFactorPorcentual), -0);

            IF MontoFinanciado < ROUND((o_monto_otorgado * vFactorPagoMinLinC),-0) THEN 
                LET MontoFinanciado = ROUND((o_monto_otorgado * vFactorPagoMinLinC),-0); 
            END IF;

            IF ( MontoFinanciado < 0 ) THEN
                LET MontoFinanciado = 0;
            ELIF ( o_saldo_no_exigible < TopeMinimo ) THEN     
                IF ( o_saldo_no_exigible ) <= 0 THEN    
                    LET MontoFinanciado = 0;
                ELSE
                    LET MontoFinanciado = o_saldo_no_exigible;     
                END IF;
            ELIF ( MontoFinanciado < TopeMinimo ) THEN  
                LET MontoFinanciado = TopeMinimo;
            END IF

            IF ( o_saldo_no_exigible <= MontoFinanciado ) THEN   
                LET MontoFinanciado = o_saldo_no_exigible;   
                IF MontoFinanciado < 0 THEN
                    LET MontoFinanciado = 0;
                END IF;
            END IF;

            IF ( Round(MontoFinanciado,-1) - MontoFinanciado < 0 ) THEN
                LET MontoFinanciado = Round(MontoFinanciado,-1) + 10;
            ELSE
                LET MontoFinanciado = Round(MontoFinanciado,-1);
            END IF;


            IF ( MontoFinanciado > o_saldo_no_exigible ) THEN
                LET MontoFinanciado = o_saldo_no_exigible;
            END IF;

            LET wdias = monthadd(o_fecha_calculo,wmeses_fin) - monthadd(o_fecha_calculo,wmeses_fin - 1);

            -- Calcula financiamiento
            LET wfinincimainto = ((o_saldo_no_exigible * o_tasa / 360 * wdias) * (1 + o_iva));

            LET o_saldo_no_exigible = o_saldo_no_exigible - MontoFinanciado + wfinincimainto;
            
            IF ( o_saldo_no_exigible <= TopeMinimo ) THEN
                LET wmeses_fin = wmeses_fin + 1;
                LET wbandera = 1;
            END IF;
        END WHILE;
        

        RETURN scod_ret, wmeses_fin;
    END;
END PROCEDURE;
CREATE PROCEDURE "informix".sp_pago_credito_atm(pNumCredito CHAR(20), pMontoPago DECIMAL(18,2), pCajero CHAR(06), pTransaccion CHAR(04), pNumTarjetaDebito CHAR(20), pTipoPago CHAR(01))
RETURNING CHAR(05)       AS Codigo_Retorno,
          CHAR(25)       AS Folio,
		  CHAR(20)       AS Numero_tarjeta_credito;
	
--*******************************************************************************************************
-- Realizo   : 
-- Proyecto  : 
-- Actividad : 
-- Fecha     : 

--Autor: 
--Fecha: 09/05/2022
--Modificacion: 
--
-- pTipoPago:
-- 1 - pago minimo
-- 2 - pago para no generar intereses
-- 3 - pago total
-- 4 - otra cantidad
-- 5 - pago otra tdc
--*******************************************************************************************************

DEFINE cCodRet			CHAR(6);
DEFINE cCodRetEn		CHAR(6);
DEFINE cErrorInfo		CHAR(80);
DEFINE cErrorInfoR		CHAR(80);
DEFINE iSqlerr			INTEGER;
DEFINE sIsamErr			SMALLINT;
DEFINE iRegistros		INTEGER;
DEFINE iPagos			INTEGER;
DEFINE iPlazo			INTEGER;
DEFINE iPendientes		INTEGER;

DEFINE cNumCte			CHAR(20);
DEFINE cNumCredito		CHAR(20);
DEFINE cNumTarjeta		CHAR(20);
DEFINE cCodprod			CHAR(2);
DEFINE cEmpresa			CHAR(3);
DEFINE cTipoCredito		CHAR(2);
DEFINE cApellPaterno	CHAR(26);
DEFINE cApellMaterno	CHAR(26);
DEFINE cNombre1			CHAR(26);
DEFINE cNombre2			CHAR(26);

DEFINE g_Remanente		MONEY(14,2);
DEFINE g_IntMoraCob		MONEY(14,2);
DEFINE g_IntVencCob		MONEY(14,2);
DEFINE g_CapVencCob		MONEY(14,2);
DEFINE g_IntVigCob		MONEY(14,2);
DEFINE g_CapVigCob		MONEY(14,2);
DEFINE g_Impuesto		MONEY(14,2);
DEFINE g_Comision		MONEY(14,2);
DEFINE g_Seguro			MONEY(14,2);

DEFINE cFolio			CHAR(18);
DEFINE cFolio2			CHAR(25);
DEFINE dSdoCuentaCargo  DECIMAL(14,2);
DEFINE cStatusCuentaCargo   CHAR(1);
DEFINE cNumCuentaCargo	CHAR(20);
DEFINE cReferencia		CHAR(25);
DEFINE cCodRetAux		CHAR(6);
DEFINE cCodRetCtrl		CHAR(5);
DEFINE ChaAux			CHAR(20);
DEFINE DecAux			DECIMAL(18,2);
DEFINE cMensajeRet		CHAR(125);
DEFINE ChaAux1			CHAR(125);
DEFINE ChaAux2			CHAR(125);
DEFINE sSeAplicoReverso SMALLINT;
DEFINE dProxFechaPago	DATE;
--DEFINE cNumProducto		CHAR(04);
DEFINE cNumProd			CHAR(04);
DEFINE cNomProd			CHAR(30);
DEFINE cNumTDC          CHAR(16);
DEFINE cTransaccionTDC  CHAR(4);
DEFINE cTransaccionTDC2	CHAR(4);
DEFINE cTransaccionPP   CHAR(4);
DEFINE cTransaccionPP2  CHAR(4);

LET cCodRetEn       = '000000';
LET cCodRet         = '000000';
LET cErrorInfo      = "";
--LET cErrorInfoR     = "OPERACION EXITOSA";
LET iSqlerr         = 0;
LET iRegistros      = 0;

LET cNumCte			= 0;
LET cNumCredito     = '';
LET cNumTarjeta     = '';
LET cCodprod        = '';
LET cEmpresa		= '001';
LET cTipoCredito	= '';
LET cApellPaterno   = '';
LET cApellMaterno   = '';
LET cNombre1 	    = '';
LET cNombre2		= '';

LET g_Remanente		= 0;
LET g_IntMoraCob	= 0;
LET g_IntVencCob	= 0;
LET g_CapVencCob	= 0;
LET g_IntVigCob		= 0;
LET g_CapVigCob		= 0;
LET g_Impuesto		= 0;
LET g_Comision		= 0;
LET g_Seguro		= 0;

LET cFolio			= '';
LET cFolio2			= '';
LET dSdoCuentaCargo = 0;
LET cStatusCuentaCargo	= '';
LET cNumCuentaCargo	= 0;
LET cReferencia		= '';
LET cCodRetAux		= '';
LET cCodRetCtrl		= '';
LET ChaAux			= '';
LET DecAux			= '';
LET cMensajeRet		= '';
LET ChaAux1			= '';
LET ChaAux2			= '';
LET sSeAplicoReverso = 0;
LET dProxFechaPago	= DATE(1);
--LET cNumProducto	= '';
LET cNumProd    	= '';
LET cNomProd    	= "";
LET cNumTDC         = '';

LET iPagos			= 0;
LET iPlazo			= 0;
LET iPendientes		= 0;

LET cTransaccionTDC = '9854'; --Cgo a cuenta
LET cTransaccionTDC2 = '4356'; -- Efectivo
LET cTransaccionPP = '9888'; -- Cgo a cuenta
LET cTransaccionPP2 = '4320'; -- Efectivo


BEGIN

	ON EXCEPTION  SET iSqlerr, sIsamErr, cErrorInfo
		IF iSqlerr <> 0  THEN
			LET  cCodRet  = iSqlerr;
			LET cFolio = '0';
			LET cNumCredito = '0';	
			
			
			INSERT INTO "informix".sd_pagos_reporte_atm
			(emisor, cajero, num_tarjeta_tdd, num_cuenta_tdd, num_credito, num_producto, folio, codigo_retorno_bd, codigo_respuesta, fecha, hora, secuencia, red, concepto_monto_pagado, monto_pagado, transacc) 
			VALUES('T137', pCajero, pNumTarjetaDebito, cNumCuentaCargo, pNumCredito, cNumProd,cFolio2, cCodRet, cCodRet, TODAY, CURRENT, 0, 'T137', pTipoPago, pMontoPago, pTransaccion);
			
			RETURN cCodRet,cFolio,cNumCredito;

		END IF;
	END  EXCEPTION

--set debug file to '/informix/sysistbus/logs_sp/sp_pago_credito_atm.out';
--trace on;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF NVL(TRIM(pNumCredito),'') = '' OR pMontoPago <= 0 OR NVL(TRIM(pCajero),'') = '' OR NVL(TRIM(pTransaccion),'') = '' OR NVL(TRIM(pTipoPago),'') = '' THEN
		LET cCodRet     = '00001';	-- 'NO SE ESPECIFICAN TODOS LOS DATOS PARA EL PAGO'
		LET cFolio = '0';
		LET cNumCredito = '0';
		--REPORTE ATM
		INSERT INTO "informix".sd_pagos_reporte_atm
		(emisor, cajero, num_tarjeta_tdd, num_cuenta_tdd, num_credito, num_producto, folio, codigo_retorno_bd, codigo_respuesta, fecha, hora, secuencia, red, concepto_monto_pagado, monto_pagado, transacc) 
		VALUES('T137', pCajero, pNumTarjetaDebito, cNumCuentaCargo, pNumCredito, cNumProd,cFolio2, cCodRet, cCodRet, TODAY, CURRENT, 0, 'T137', pTipoPago, pMontoPago, pTransaccion);
		RETURN cCodRet,cFolio,cNumCredito;
	END IF; 


	SELECT nvl(m.num_producto,''), m.numcte, d.nombre_prod INTO cNumProd, cNumcte, cNomProd
	FROM bdicred:sd_maecredcrd m, bdicred:sd_definicion d WHERE  m.num_credito = pNumCredito
		 AND d.num_producto = m.num_producto;
	
	
	IF NVL(TRIM(cNumProd),'') = '' THEN 
		SELECT nvl(m.num_producto,''), m.numcte, d.nombre_prod INTO cNumProd, cNumcte, cNomProd
		FROM bdicred:sd_maecred m, bdicred:sd_definicion d WHERE  m.num_credito = pNumCredito
		 AND d.num_producto = m.num_producto;
	END IF;

	--Las primeras iniciales del folio2 se obtienen de acuerdo a cada tipo de producto(por transaccion)
	IF pTransaccion IN ('0552','0559') THEN
	  LET cTipoCredito = 'TC';
	ELIF pTransaccion IN ('0548','0555') THEN
	  LET cTipoCredito = 'PP';
	ELIF pTransaccion IN ('0550','0557') THEN
	  LET cTipoCredito = 'PN';
	ELIF pTransaccion IN ('0549','0556') THEN
	  LET cTipoCredito = 'PD';
	ELIF pTransaccion IN ('0551','0558') THEN
	  LET cTipoCredito = 'RD';
	ELIF pTransaccion IN ('0553','0560') THEN
	  LET cTipoCredito = 'PM';
	ELIF pTransaccion IN ('0554','0561') THEN
	  LET cTipoCredito = 'PT';
	END IF;
	



	--SELECT 'cobroATM'||pCajero||DAY(CURRENT)||MONTH(CURRENT)||SUBSTR(current,3,2)||SUBSTR(CURRENT,12,2)||substr(current,15,2)||SUBSTR(current,18,2) INTO cFolio2
	/*SELECT cTipoCredito||pCajero||SUBSTR(CURRENT,12,2)||substr(current,15,2)||SUBSTR(current,18,2)||SUBSTR(current,21,2) INTO cFolio2
	FROM dual;*/
	LET cFolio2 = cTipoCredito||pCajero||SUBSTR(CURRENT,12,2)||substr(current,15,2)||SUBSTR(current,18,2)||SUBSTR(current,21,2);
	
	--Valida la existencia de la tarjeta de debito
	IF NVL(TRIM(pNumTarjetaDebito),'') <> '' THEN
		IF pNumTarjetaDebito NOT IN ('************9999') THEN
			SELECT cuenta INTO cNumCuentaCargo 
			FROM bdicheq:sc_tarjeta
			WHERE num_tarjeta = pNumTarjetaDebito
			AND status_tar = 'A';
		END IF;
		EXECUTE PROCEDURE "informix".sp_enmascarado(pNumTarjetaDebito,2) INTO cCodRetEn,cNumTDC;
	ELSE
		LET cCodRet     = '00001';	-- 'NO SE ESPECIFICAN TODOS LOS DATOS PARA EL PAGO'
		LET cFolio = '0';
		LET cNumCredito = '0';
		
		INSERT INTO "informix".sd_pagos_reporte_atm
		(emisor, cajero, num_tarjeta_tdd, num_cuenta_tdd, num_credito, num_producto, folio, codigo_retorno_bd, codigo_respuesta, fecha, hora, secuencia, red, concepto_monto_pagado, monto_pagado, transacc) 
		VALUES('T137', pCajero, pNumTarjetaDebito, cNumCuentaCargo, pNumCredito, cNumProd,cFolio2, cCodRet, cCodRet, TODAY, CURRENT, 0, 'T137', pTipoPago, pMontoPago, pTransaccion);
		
		RETURN cCodRet,cFolio,cNumCredito;
	END IF;
		
	
	
	IF pTransaccion IN ('0552') THEN	-- Pago TDC con cargo a cuenta
			
			
		/*--Si el tipo es 5 se toma la cuenta cargo relacionada con la tarjeta de debito 
		IF pTipoPago = '5' THEN
		
			IF cNumProd = '8500' THEN
				SELECT cgo.num_cta INTO cNumCuentaCargo 
				FROM bdicred:sd_ctascarg cgo
				WHERE cgo.num_credito = pNumCredito
				AND cgo.naturaleza = 'A';
			ELSE
				SELECT cuenta INTO cNumCuentaCargo 
				FROM bdicheq:sc_tarjeta WHERE num_tarjeta = pNumTarjetaDebito;
			END IF;
		ELSE 
				SELECT cgo.num_cta INTO cNumCuentaCargo
				FROM bdicred:sd_ctascarg cgo
				WHERE cgo.num_credito = pNumCredito
				AND cgo.naturaleza = 'A';
		END IF;*/
			
		LET cReferencia = 'CRG. CTA. ';

		/*SELECT SUBSTR(pNumCredito,3,10)||SUBSTR(CURRENT,12,2)||SUBSTR(CURRENT,15,2)||SUBSTR(CURRENT,18,2)
		INTO cFolio
		FROM dual;*/
		LET cFolio = SUBSTR(pNumCredito,3,10)||SUBSTR(CURRENT,12,2)||SUBSTR(CURRENT,15,2)||SUBSTR(CURRENT,18,2);
		
		-- Se obtiene el saldo de la cuenta identificada.
		CALL bdicheq:"informix".cons_saldo(cNumCuentaCargo) RETURNING cCodRetAux,dSdoCuentaCargo,cStatusCuentaCargo;

		IF dSdoCuentaCargo <= pMontoPago THEN
			LET cCodRet     = '00003';	-- 'FONDOS INSUFICIENTES'
			LET cFolio ='0';
			LET cNumCredito = '0';
			
			-----------ATM_PAGN
			--ENVIO DE EMAIL											
			CALL bdimnsj:"informix".sp_registra_evento('1','P_TDC_ATM','ATM_PAGN',cNumcte,pNumCredito,cNumCuentaCargo,'1',
										pMontoPago,pNumCredito,'','', cNumProd, pCajero ,'',cNumTDC,cFolio2,'','','',0,0,0,
										pMontoPago,0,CURRENT,CURRENT) RETURNING cCodRetCtrl;
			
			
			INSERT INTO "informix".sd_pagos_reporte_atm
			(emisor, cajero, num_tarjeta_tdd, num_cuenta_tdd, num_credito, num_producto, folio, codigo_retorno_bd, codigo_respuesta, fecha, hora, secuencia, red, concepto_monto_pagado, monto_pagado, transacc) 
			VALUES('T137', pCajero, pNumTarjetaDebito, cNumCuentaCargo, pNumCredito, cNumProd,cFolio2, cCodRet, cCodRet, TODAY, CURRENT, 0, 'T137', pTipoPago, pMontoPago, pTransaccion);

			
			RETURN cCodRet,cFolio,cNumCredito;
		ELSE
			EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(cEmpresa, '9290', 'informix', '0552','0552', cFolio2, cNumCuentaCargo, 0,  pMontoPago, '01', LPAD(TRIM(pNumCredito),12,'0')||' '||cReferencia, '', 'informix')
			INTO cCodRetCtrl, ChaAux, ChaAux, DecAux, DecAux;
			LET cCodRetAux = '00'||cCodRetCtrl;

			IF cCodRetAux = '00000' THEN  

				EXECUTE PROCEDURE "informix".principal(cEmpresa, pNumCredito, 1, pMontoPago, 'informix', '9290', cFolio2, cTransaccionTDC)
				INTO cCodRetCtrl,DecAux,DecAux,DecAux,DecAux, DecAux, DecAux, DecAux, DecAux, DecAux;

				IF cCodRetCtrl <> "000" THEN 
					EXECUTE PROCEDURE bdicheq:"informix".reversion ('001','9290','informix', cFolio2,"A")
					INTO cCodRetAux;
					LET cMensajeRet = "Se realiza reverso correctamente";
					LET sSeAplicoReverso = 1;

					LET cCodRet = cCodRetCtrl;
					LET cFolio ='0';
					LET cNumCredito = '0';
					
					------------ATM_PAGN
					--ENVIO DE EMAIL											
					CALL bdimnsj:"informix".sp_registra_evento('1','P_TDC_ATM','ATM_PAGN',cNumcte,pNumCredito,cNumCuentaCargo,'1',
												pMontoPago,pNumCredito,'','', cNumProd, pCajero ,'',cNumTDC,cFolio2,'','','',0,0,0,
												pMontoPago,0,CURRENT,CURRENT) RETURNING cCodRetCtrl;
						
					INSERT INTO "informix".sd_pagos_reporte_atm
					(emisor, cajero, num_tarjeta_tdd, num_cuenta_tdd, num_credito, num_producto, folio, codigo_retorno_bd, codigo_respuesta, fecha, hora, secuencia, red, concepto_monto_pagado, monto_pagado, transacc) 
					VALUES('T137', pCajero, pNumTarjetaDebito, cNumCuentaCargo, pNumCredito, cNumProd,cFolio2, cCodRet, cCodRet, TODAY, CURRENT, 0, 'T137', pTipoPago, pMontoPago, pTransaccion);
			
					RETURN cCodRet,cFolio,cNumCredito;
				ELSE
					------------ATM_PAG
					--ENVIO DE EMAIL											
					CALL bdimnsj:"informix".sp_registra_evento('1','P_TDC_ATM','ATM_PAG',cNumcte,pNumCredito,cNumCuentaCargo,'1',
												pMontoPago,pNumCredito,'','', cNumProd, pCajero ,'',cNumTDC,cFolio2,'','','',0,0,0,
												pMontoPago,0,CURRENT,CURRENT) RETURNING cCodRetCtrl;
					
					INSERT INTO "informix".sd_pagos_reporte_atm
					(emisor, cajero, num_tarjeta_tdd, num_cuenta_tdd, num_credito, num_producto, folio, codigo_retorno_bd, codigo_respuesta, fecha, hora, secuencia, red, concepto_monto_pagado, monto_pagado, transacc) 
					VALUES('T137', pCajero, pNumTarjetaDebito, cNumCuentaCargo, pNumCredito, cNumProd,cFolio2, cCodRet, cCodRetCtrl, TODAY, CURRENT, 0, 'T137', pTipoPago, pMontoPago, pTransaccion);
					
					LET cMensajeRet = "Se realiza el pago correctamente";
				END IF;

			ELSE 
				EXECUTE PROCEDURE bdicheq:"informix".reversion ('001','9290','informix', cFolio2,"A")
				INTO cCodRetAux;
				LET cMensajeRet = "Se realiza reverso correctamente";
				LET sSeAplicoReverso = 1;

				LET cCodRet = cCodRetCtrl;
				LET cFolio ='0';
				LET cNumCredito = '0';
				
				-----------------ATM_PAGN
				--ENVIO DE EMAIL											
				CALL bdimnsj:"informix".sp_registra_evento('1','P_TDC_ATM','ATM_PAGN',cNumcte,pNumCredito,cNumCuentaCargo,'1',
											pMontoPago,pNumCredito,'','', cNumProd, pCajero ,'',cNumTDC,cFolio2,'','','',0,0,0,
											pMontoPago,0,CURRENT,CURRENT) RETURNING cCodRetCtrl;
											
				INSERT INTO "informix".sd_pagos_reporte_atm
				(emisor, cajero, num_tarjeta_tdd, num_cuenta_tdd, num_credito, num_producto, folio, codigo_retorno_bd, codigo_respuesta, fecha, hora, secuencia, red, concepto_monto_pagado, monto_pagado, transacc) 
				VALUES('T137', pCajero, pNumTarjetaDebito, cNumCuentaCargo, pNumCredito, cNumProd,cFolio2, cCodRet, cCodRet, TODAY, CURRENT, 0, 'T137', pTipoPago, pMontoPago, pTransaccion);
				
				RETURN cCodRet,cFolio,cNumCredito;
			END IF;
		END IF		
		--BEGIN WORK;

		--COMMIT WORK;
	ELIF pTransaccion IN ('0548','0549','0550','0551','0553','0554') THEN	-- Pago PPs y RRs con cargo a cuenta

		/*SELECT cgo.num_cta INTO cNumCuentaCargo--SE RECIBIÃ? UNA TARJETA DE DEBITO Y ES DONDE SE APLICARÃ? EL CARGO =======================
		FROM bdicred:sd_ctascarg cgo
		INNER JOIN bdicheq:"informix".sc_maechq chq on chq.cuenta = cgo.num_cta
		WHERE cgo.num_credito = pNumCredito
		AND cgo.naturaleza = 'A';*/

		--LET cReferencia = 'CRG. CTA. ';

		/*SELECT SUBSTR(pNumCredito,3,10)||SUBSTR(CURRENT,12,2)||SUBSTR(CURRENT,15,2)||SUBSTR(CURRENT,18,2)	INTO cFolio	FROM dual;*/
		LET cFolio = SUBSTR(pNumCredito,3,10)||SUBSTR(CURRENT,12,2)||SUBSTR(CURRENT,15,2)||SUBSTR(CURRENT,18,2);

		-- Se obtiene el saldo de la cuenta identificada.
		--CALL bdicheq:"informix".cons_saldo(cNumCuentaCargo) RETURNING cCodRetAux,dSdoCuentaCargo,cStatusCuentaCargo;

		--IF dSdoCuentaCargo >= pMontoPago THEN
		
		EXECUTE PROCEDURE "informix".sp_principal_suc_rr(cEmpresa,pNumCredito,cNumProd,0,pMontoPago,'informix','9290',cFolio2,cTransaccionPP)
		INTO cCodRetCtrl,cMensajeRet,ChaAux,ChaAux,ChaAux,ChaAux,ChaAux,DecAux,DecAux,DecAux,DecAux,ChaAux;
		
		IF cCodRetCtrl <> "000" THEN 
			EXECUTE PROCEDURE bdicheq:"informix".reversion ('001','9290','informix', cFolio2,"A")
			INTO cCodRetAux;
			LET cMensajeRet = "Se realiza reverso correctamente";
			LET sSeAplicoReverso = 1;
			
			LET cCodRet = cCodRetCtrl;
			LET cFolio ='0';
			LET cNumCredito = '0';
			
			
			-----ATM_PAGPRN
			--ENVIO DE EMAIL											
			CALL bdimnsj:"informix".sp_registra_evento('1','P_TDC_ATM','ATM_PAGPRN',cNumcte,pNumCredito,cNumCuentaCargo,'1',
										pMontoPago,pNumCredito,'','', cNumProd, pCajero ,'',cNumTDC,cFolio2,'','','',0,0,0,
										pMontoPago,0,CURRENT,CURRENT) RETURNING cCodRetCtrl;
			
			INSERT INTO "informix".sd_pagos_reporte_atm
					(emisor, cajero, num_tarjeta_tdd, num_cuenta_tdd, num_credito, num_producto, folio, codigo_retorno_bd, codigo_respuesta, fecha, hora, secuencia, red, concepto_monto_pagado, monto_pagado, transacc) 
					VALUES('T137', pCajero, pNumTarjetaDebito, cNumCuentaCargo, pNumCredito, cNumProd,cFolio2, cCodRet, cCodRet, TODAY, CURRENT, 0, 'T137', pTipoPago, pMontoPago, pTransaccion);
			
			RETURN cCodRet,cFolio,cNumCredito;
				
		--END IF;

		ELSE	
			-----------ATM_PAGPR
				--ENVIO DE EMAIL											
				CALL bdimnsj:"informix".sp_registra_evento('1','P_TDC_ATM','ATM_PAGPR',cNumcte,pNumCredito,cNumCuentaCargo,'1',
											pMontoPago,pNumCredito,'','', cNumProd, pCajero ,'',cNumTDC,cFolio2,'','','',0,0,0,
											pMontoPago,0,CURRENT,CURRENT) RETURNING cCodRetCtrl;
		END IF;
		   
		--END IF;
			
	ELIF pTransaccion IN ('0559') THEN	-- Pago TDC en efectivo
		/*SELECT SUBSTR(pNumCredito,3,10)||SUBSTR(CURRENT,12,2)||SUBSTR(CURRENT,15,2)||SUBSTR(CURRENT,18,2)
		INTO cFolio
		FROM dual;*/
		LET cFolio=SUBSTR(pNumCredito,3,10)||SUBSTR(CURRENT,12,2)||SUBSTR(CURRENT,15,2)||SUBSTR(CURRENT,18,2);
		
		EXECUTE PROCEDURE "informix".principal(cEmpresa, pNumCredito, 1, pMontoPago, 'informix', '9290', cFolio2, cTransaccionTDC2)
		INTO cCodRetCtrl,DecAux,DecAux,DecAux,DecAux, DecAux, DecAux, DecAux, DecAux, DecAux;
		
		IF cCodRetCtrl <> "000" THEN 
			--EXECUTE PROCEDURE bdicheq:"informix".reversion ('001','9290','informix', cFolio2,"A") --RevisiÃ³n por ser efectivo
			--INTO cCodRetAux;
			--LET cMensajeRet = "Se realiza reverso correctamente";
			LET cMensajeRet = "Error al realizar el pago a TDC";
			LET sSeAplicoReverso = 1;
			LET cCodRet = cCodRetCtrl;
			LET cFolio ='0';	   
			LET cNumCredito = '0';
			
			-----------ATM_PAGEFN
			--ENVIO DE EMAIL											
			CALL bdimnsj:"informix".sp_registra_evento('1','P_TDC_ATM','ATM_PAGEFN',cNumcte,pNumCredito,'','1',
										pMontoPago,pNumCredito,'','', cNumProd, pCajero ,'',cNumTDC,cFolio2,'','','',0,0,0,
										pMontoPago,0,CURRENT,CURRENT) RETURNING cCodRetCtrl;
			
			INSERT INTO "informix".sd_pagos_reporte_atm
			(emisor, cajero, num_tarjeta_tdd, num_cuenta_tdd, num_credito, num_producto, folio, codigo_retorno_bd, codigo_respuesta, fecha, hora, secuencia, red, concepto_monto_pagado, monto_pagado, transacc) 
			VALUES('T137', pCajero, pNumTarjetaDebito, cNumCuentaCargo, pNumCredito, cNumProd,cFolio2, cCodRet, cCodRet, TODAY, CURRENT, 0, 'T137', pTipoPago, pMontoPago, pTransaccion);
			
			
			RETURN cCodRet,cFolio,cNumCredito;
		ELSE
			
			-----------ATM_PAGEF
			--ENVIO DE EMAIL											
			CALL bdimnsj:"informix".sp_registra_evento('1','P_TDC_ATM','ATM_PAGEF',cNumcte,pNumCredito,'','1',
										pMontoPago,pNumCredito,'','', cNumProd, pCajero ,'',cNumTDC,cFolio2,'','','',0,0,0,
										pMontoPago,0,CURRENT,CURRENT) RETURNING cCodRetCtrl;
										
			LET cMensajeRet = "Se realiza el pago correctamente";
		END IF;

				  
	ELIF pTransaccion IN ('0555','0556','0557','0558','0560','0561') THEN	-- Pago PPs y RRs en efectivo

		/*SELECT SUBSTR(pNumCredito,3,10)||SUBSTR(CURRENT,12,2)||SUBSTR(CURRENT,15,2)||SUBSTR(CURRENT,18,2)
		INTO cFolio
		FROM dual;*/
		LET cFolio=SUBSTR(pNumCredito,3,10)||SUBSTR(CURRENT,12,2)||SUBSTR(CURRENT,15,2)||SUBSTR(CURRENT,18,2);
			
		EXECUTE PROCEDURE "informix".sp_principal_suc_rr(cEmpresa,pNumCredito,cNumProd,pMontoPago,0,'informix','9290',cFolio2,cTransaccionPP2)
		INTO cCodRetCtrl,cMensajeRet,ChaAux,ChaAux,ChaAux,ChaAux,ChaAux,DecAux,DecAux,DecAux,DecAux,ChaAux;
		
		IF cCodRetCtrl <> "000" THEN 
			-- EXECUTE PROCEDURE bdicheq:"informix".reversion ('001','9290','informix', cFolio2,"A")--RevisiÃ³n por ser efectivo
			-- INTO cCodRetAux;
			-- LET cMensajeRet = "Se realiza reverso correctamente";
			LET cMensajeRet = "Error al realizar pago a TDC";
			LET sSeAplicoReverso = 1;
			LET cCodRet = cCodRetCtrl;
			LET cFolio ='0';	   
			LET cNumCredito = '0';
			
			
			
			------------ATM_PAGPREFN
			--ENVIO DE EMAIL											
			CALL bdimnsj:"informix".sp_registra_evento('1','P_TDC_ATM','ATM_PAGPREFN',cNumcte,pNumCredito,'','1',
										pMontoPago,pNumCredito,'','', cNumProd, pCajero ,'',cNumTDC,cFolio2,'','','',0,0,0,
										pMontoPago,0,CURRENT,CURRENT) RETURNING cCodRetCtrl;
			
			INSERT INTO "informix".sd_pagos_reporte_atm
			(emisor, cajero, num_tarjeta_tdd, num_cuenta_tdd, num_credito, num_producto, folio, codigo_retorno_bd, codigo_respuesta, fecha, hora, secuencia, red, concepto_monto_pagado, monto_pagado, transacc) 
			VALUES('T137', pCajero, pNumTarjetaDebito, cNumCuentaCargo, pNumCredito, cNumProd,cFolio2, cCodRet, cCodRet, TODAY, CURRENT, 0, 'T137', pTipoPago, pMontoPago, pTransaccion);
			
			RETURN cCodRet,cFolio,cNumCredito;
		--END IF;
		ELSE 
			
			------------------ATM_PAGPREF
			--ENVIO DE EMAIL											
			CALL bdimnsj:"informix".sp_registra_evento('1','P_TDC_ATM','ATM_PAGPREF',cNumcte,pNumCredito,'','1',
										pMontoPago,pNumCredito,'','', cNumProd, pCajero ,'',cNumTDC,cFolio2,'','','',0,0,0,
										pMontoPago,0,CURRENT,CURRENT) RETURNING cCodRetCtrl;
				
		END IF;

	ELSE
		LET cCodRet     = '00002';	-- 'TRANSACCION NO VALIDA'
		LET cFolio      = '0';
		LET cNumCredito = '0';
		
		INSERT INTO "informix".sd_pagos_reporte_atm
		(emisor, cajero, num_tarjeta_tdd, num_cuenta_tdd, num_credito, num_producto, folio, codigo_retorno_bd, codigo_respuesta, fecha, hora, secuencia, red, concepto_monto_pagado, monto_pagado, transacc) 
		VALUES('T137', pCajero, pNumTarjetaDebito, cNumCuentaCargo, pNumCredito, cNumProd,cFolio2, cCodRet, cCodRet, TODAY, CURRENT, 0, 'T137', pTipoPago, pMontoPago, pTransaccion);
		
		RETURN cCodRet,cFolio,cNumCredito;
	END IF;

	  /*IF pTransaccion IN ('0552','0559') THEN	-- Pago TDC
		SELECT a.num_producto,b.prox_fecha_pago INTO cNumProducto,dProxFechaPago
		FROM bdicred:sd_maecred a
		INNER JOIN bdicred:sd_maecredanexo b ON  b.num_credito = a.num_credito
		WHERE a.num_credito = pNumCredito;
	  ELSE
		SELECT a.num_producto,b.prox_fecha_pago INTO cNumProducto,dProxFechaPago
		FROM bdicred:sd_maecredcrd a
		INNER JOIN bdicred:sd_maecredanexocrd b ON  b.num_credito = a.num_credito
		WHERE a.num_credito = pNumCredito;
	  END IF;
	  
	  IF pTransaccion IN ('0559', '0552') THEN
		SELECT plazo INTO iPlazo FROM bdicred:sd_maecred WHERE  num_credito = pNumCredito;
		SELECT count(*) INTO iPagos FROM bdicred:sd_amortiza_credito WHERE  num_credito = pNumCredito AND capital_status = 5;
	  ELSE
		SELECT plazo INTO iPlazo FROM bdicred:sd_maecredcrd WHERE  num_credito = pNumCredito;
		SELECT count(*) INTO iPagos FROM bdicred:sd_amortiza_creditocrd WHERE  num_credito = pNumCredito AND capital_status = 5;
	  END IF;*/ --Se comenta hasta identificar su funcionalidad
	  
	  /*IF NVL(iPlazo,0) = 0 THEN 
		LET iPlazo = 0;
	  END IF;
	  
	  IF NVL(iPagos,0) THEN
		LET iPagos = 0;
	  END IF;*/
	  
	  --LET iPendientes = iPlazo - iPagos;--Se comenta hasta identificar su funcionalidad

	INSERT INTO "informix".sd_pagos_reporte_atm
	(emisor, cajero, num_tarjeta_tdd, num_cuenta_tdd, num_credito, num_producto, folio, codigo_retorno_bd, codigo_respuesta, fecha, hora, secuencia, red, concepto_monto_pagado, monto_pagado, transacc) 
	VALUES('T137', pCajero, pNumTarjetaDebito, cNumCuentaCargo, pNumCredito, cNumProd,cFolio2, cCodRet, cCodRetCtrl, TODAY, CURRENT, 0, 'T137', pTipoPago, pMontoPago, pTransaccion);

	LET cNumCredito=pNumCredito;
	RETURN cCodRet,cFolio2,cNumCredito;

END;
END PROCEDURE;
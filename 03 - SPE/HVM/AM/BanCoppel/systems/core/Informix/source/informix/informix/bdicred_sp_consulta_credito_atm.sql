CREATE PROCEDURE "informix".sp_consulta_credito_atm(pTipoProducto CHAR(02), pNumCredito CHAR(20), pNumTarjetaDebito CHAR(20), pNumCliente CHAR(20))
RETURNING CHAR(05)       AS Codigo_Retorno,
          CHAR(02)       AS Tipo_Credito,
          VARCHAR(200)   AS Nombre_Cliente,
          CHAR(20)	 	 AS Numero_Credito,
--          MONEY(16,2)	 AS Pago_Corte,
          MONEY(16,2)	 AS Pago_Minimo,
--          MONEY(16,2)	 AS Total_a_Pagar,
          MONEY(16,2)	 AS Pago_No_Generar_Intereses,
          MONEY(16,2)	 AS Saldo_Total,
          DATE			 AS Fecha_Limite_Pago,
		  CHAR(16)	 	 AS Tarjeta_credito;
	
	
	
	
	

--*******************************************************************************************************
-- Realizo   : 
-- Proyecto  : 
-- Actividad : 
-- Fecha     : 

--Autor: 
--Fecha: 05/05/2022
--Modificacion: 
--*******************************************************************************************************

DEFINE cCodRet         CHAR(6);
DEFINE cErrorInfo      CHAR(80);
DEFINE cErrorInfoR     CHAR(80);
DEFINE iSqlerr         INTEGER;
DEFINE sIsamErr        SMALLINT;
DEFINE iRegistros      INTEGER;


DEFINE cNumCte			CHAR(20);
DEFINE cNumCredito     CHAR(20);
DEFINE cCodprod        CHAR(2);
DEFINE cEmpresa        CHAR(3);
DEFINE cTipoCredito	   CHAR(2);
DEFINE cApellPaterno   CHAR(26);
DEFINE cApellMaterno   CHAR(26);
DEFINE cNombre1 	   CHAR(26);
DEFINE cNombre2		   CHAR(26);
DEFINE cNomCliente		CHAR(200);

DEFINE auxNumCte		CHAR(20);
DEFINE auxCont			INTEGER;

DEFINE cMensajeRetornoCSG	CHAR(80);
DEFINE cNumeroCreditoCSG	CHAR(20);
DEFINE cCodigoTipcredCSG	CHAR(2);
DEFINE dFechaOrigenCSG		DATE;
DEFINE dFechaProxPagoCSG	DATE;
DEFINE dPagoMinimoCSG		DECIMAL(18,2);
DEFINE dFechaUltPagoCSG		DATE;
DEFINE iPlazoCSG			INTEGER;
DEFINE iPagosRealizadosCSG	INTEGER;
DEFINE dLineaOtorgadaCSG	DECIMAL(18,2);
DEFINE dTasaInteresCSG		DECIMAL(9,6);
DEFINE dTasaMoratoriosCSG	DECIMAL(9,6);
DEFINE dMontoSbcCSG			DECIMAL(14,2);
DEFINE dCapVigCSG			DECIMAL(18,2);
DEFINE dCapTransCSG			DECIMAL(18,2);
DEFINE dCapVdoExigCSG		DECIMAL(18,2);
DEFINE dCapVdoNoExigCSG		DECIMAL(18,2);
DEFINE dSdoActTotalCapCSG	DECIMAL(18,2);
DEFINE dIntVigCSG			DECIMAL(18,2);
DEFINE dIntVdoCSG			DECIMAL(18,2);
DEFINE dIntMoratoriosCSG	DECIMAL(18,2);
DEFINE dIntMesCSG			DECIMAL(18,2);
DEFINE dSdoActTotalIntCSG	DECIMAL(18,2);
DEFINE dIvaIntVigCSG		DECIMAL(18,2);
DEFINE dIvaIntVdoCSG		DECIMAL(18,2);
DEFINE dIvaIntMoratoriosCSG	DECIMAL(18,2);
DEFINE dIvaIntMesCSG		DECIMAL(18,2);
DEFINE dSdoActTotalIvaCSG	DECIMAL(18,2);
DEFINE dComPendCSG			DECIMAL(18,2);
DEFINE dIvaComCSG			DECIMAL(18,2);
DEFINE dSdoRetenidoCSG		DECIMAL(18,2);
DEFINE dTotalLiquidacionCSG	DECIMAL(18,2);
DEFINE dIntDevengadoCSG		DECIMAL(18,2);
DEFINE dIvaIntDevengadoCSG	DECIMAL(18,2);
DEFINE dLineaDisponibleCSG	DECIMAL(18,2);
DEFINE dPagosVdosCSG		DECIMAL(18,2);
DEFINE cDescStatusCredCSG	CHAR(60);
DEFINE iIdBloqueoCredCSG	INTEGER;
DEFINE cBloqueoCtaCSG		CHAR(60); 
DEFINE cIdCausaBloqueoCSG	CHAR(3);
DEFINE cCausaBloqueoCtaCSG	CHAR(50);
DEFINE cIdSitEspCteCSG		CHAR(1);
DEFINE iIdCausaEspCteCSG	INTEGER;
DEFINE cSitEspCteCSG		CHAR(75);
DEFINE cIdSitEspCredCSG		CHAR(1);
DEFINE iIdCausaEspCredCSG	INTEGER;
DEFINE cSitEspCredCSG		CHAR(75);
DEFINE dPagoCorte			DECIMAL(18,2);
DEFINE dPagoMinimo 			DECIMAL(18,2);
DEFINE dSdoTotalPagar 		DECIMAL(18,2);
DEFINE dPagoNoGenInteres 	DECIMAL(18,2);
DEFINE dSaldoTotal			DECIMAL(18,2);
DEFINE dFechaLimPago 		DATE;
DEFINE cNumProducto			CHAR(4);
DEFINE cNumProductoVal		CHAR(4);
DEFINE cStatusCred			CHAR(60);
DEFINE cStatusCta			CHAR(60);
DEFINE cTipoTarjeta			CHAR(1);
DEFINE cNumTarjetaCredito	CHAR(16);
DEFINE cNumTDC              CHAR(16);


LET cCodRet         = '000000';
LET cErrorInfo      = "";
--LET cErrorInfoR     = "OPERACION EXITOSA";
LET iSqlerr         = 0;
LET iRegistros      = 0;

LET cNumCte			= 0;
LET cNumCredito     = '';
LET cCodprod        = '';
LET cEmpresa		= '001';
LET cTipoCredito	= '';
LET cApellPaterno   = '';
LET cApellMaterno   = '';
LET cNombre1 	    = '';
LET cNombre2		= '';
LET cNomCliente		= '';

LET cMensajeRetornoCSG      = 'PROCESO EXITOSO';
LET cNumeroCreditoCSG		= '';
LET cCodigoTipcredCSG		= '';
LET dFechaOrigenCSG			= '';
LET dFechaProxPagoCSG		= '';
LET dPagoMinimoCSG			= 0	;
LET dFechaUltPagoCSG		= '';
LET iPlazoCSG				= 0;
LET iPagosRealizadosCSG		= 0;
LET dLineaOtorgadaCSG		= 0;
LET dTasaInteresCSG			= 0;
LET dTasaMoratoriosCSG		= 0;
LET dMontoSbcCSG			= 0;
LET dCapVigCSG				= 0;
LET dCapTransCSG			= 0;
LET dCapVdoExigCSG			= 0;
LET dCapVdoNoExigCSG		= 0;
LET dSdoActTotalCapCSG		= 0;
LET dIntVigCSG				= 0;
LET dIntVdoCSG				= 0;
LET dIntMoratoriosCSG		= 0;
LET dIntMesCSG				= 0;
LET dSdoActTotalIntCSG		= 0;
LET dIvaIntVigCSG			= 0;
LET dIvaIntVdoCSG			= 0;
LET dIvaIntMoratoriosCSG	= 0;
LET dIvaIntMesCSG			= 0;
LET dSdoActTotalIvaCSG		= 0;
LET dComPendCSG				= 0;
LET dIvaComCSG				= 0;
LET dSdoRetenidoCSG			= 0;
LET dTotalLiquidacionCSG	= 0;
LET dIntDevengadoCSG		= 0;
LET dIvaIntDevengadoCSG		= 0;
LET dLineaDisponibleCSG		= 0;
LET dPagosVdosCSG			= 0;
LET cDescStatusCredCSG		= '';
LET iIdBloqueoCredCSG		= 0;
LET cBloqueoCtaCSG			= '';
LET cIdCausaBloqueoCSG		= '';
LET cCausaBloqueoCtaCSG		= '';
LET cIdSitEspCteCSG			= '';
LET iIdCausaEspCteCSG		= 0;
LET cSitEspCteCSG			= '';
LET cIdSitEspCredCSG		= '';
LET iIdCausaEspCredCSG		= 0;
LET cSitEspCredCSG			= '';
LET dPagoCorte				= 0;
LET dPagoMinimo 			= 0;
LET dSdoTotalPagar 			= 0;
LET dPagoNoGenInteres 		= 0;
LET dSaldoTotal				= 0;
LET dFechaLimPago 			= DATE(1);
LET cNumProducto			= '';
LET cNumProductoVal			= '';
LET cStatusCred				= '';
LET cStatusCta				= '';
LET cTipoTarjeta			= '';
LET cNumTarjetaCredito		= '';
LET cNumTDC                 = '';
LET auxNumCte				= '';
LET auxCont					= 0;

BEGIN

ON EXCEPTION  SET iSqlerr, sIsamErr, cErrorInfo
	IF iSqlerr <> 0  THEN
		LET  cCodRet  = iSqlerr;
--		LET cErrorInfoR = cErrorInfo;
     RETURN cCodRet,cTipoCredito,cNomCliente,cNumCredito,dPagoMinimo,dPagoNoGenInteres,dSaldoTotal,dFechaLimPago,cNumTDC;

	END IF;
END  EXCEPTION

--SET DEBUG FILE TO '/home/e10000646/AJUSTES_SPS_APP/Base_de_Datos/informix/bdicred/SP/sp_consulta_credito_atm.out';
--TRACE ON;

IF NVL(TRIM(pTipoProducto),'') = '' THEN
	LET cCodRet     = '00001';	-- 'NO SE ESPECIFICA EL TIPO DE PRODUCTO'
	RETURN cCodRet,cTipoCredito,cNomCliente,cNumCredito,dPagoMinimo,dPagoNoGenInteres,dSaldoTotal,dFechaLimPago,cNumTDC;
END IF;

IF NVL(TRIM(pNumTarjetaDebito),'') = '' AND NVL(TRIM(pNumCredito),'') = '' AND NVL(TRIM(pNumCliente),'') = '' THEN
	LET cCodRet     = '00002';	-- 'NO SE ESPECIFICA NINGUN DATO DE CONSULTA DE ENTRADA'
	RETURN cCodRet,cTipoCredito,cNomCliente,cNumCredito,dPagoMinimo,dPagoNoGenInteres,dSaldoTotal,dFechaLimPago,cNumTDC;
END IF;

SET ISOLATION TO dirty READ;

	
IF pTipoProducto = 'TC' THEN
			
	IF NVL(TRIM(pNumTarjetaDebito),'') != '' THEN
	
		/*SELECT mae.num_producto,mae.status_cred,mae.num_credito,tar.numcte, sm.status_cta INTO cNumProducto,cStatusCred,cNumCredito,cNumCte,cStatusCta
		FROM bdicheq:sc_tarjeta tar
		INNER JOIN bdicred:sd_maecred mae ON mae.numcte = tar.numcte
		JOIN bdicheq:sc_maechq sm ON sm.cuenta = tar.cuenta
		WHERE tar.num_tarjeta = pNumTarjetaDebito ;*/
	
		SELECT tar.numcte INTO auxNumCte FROM bdicheq:sc_tarjeta tar --primero obtener el nÃºmero de cliente en bdicheq:sc_tarjeta
		WHERE tar.num_tarjeta = pNumTarjetaDebito;
		
		IF NVL(TRIM(auxNumCte),'') != '' THEN
						
			SELECT COUNT(*) INTO auxCont FROM bdicred:sd_maecred   --num cliente hacer el count a maecred
			WHERE numcte = auxNumCte AND status_cred IN ('E1','E2','E3') and num_producto <> '7800'; 
			
			IF auxCont > 1 THEN --si es mayor a 1 2o mÃ¡sâ  	hacer counts a maecred para todos los 6001
			
				LET auxCont = 0;
				
				SELECT COUNT(*) INTO auxCont FROM bdicred:sd_maecred   
				WHERE numcte = auxNumCte AND num_producto = '6001';
				
								
				IF auxCont = 1 THEN  --si es 1 se consulta el 6001
				
					SELECT mae.num_producto,mae.status_cred,mae.num_credito,tar.numcte, sm.status_cta INTO cNumProducto,cStatusCred,cNumCredito,cNumCte,cStatusCta
					FROM bdicheq:sc_tarjeta tar
					INNER JOIN bdicred:sd_maecred mae ON mae.numcte = tar.numcte
					JOIN bdicheq:sc_maechq sm ON sm.cuenta = tar.cuenta
					WHERE tar.num_tarjeta = pNumTarjetaDebito AND
					mae.num_producto = '6001' AND mae.status_cred IN ('E1','E2','E3');
					
				ELSE --	si son mÃ¡s se realiza el limit 1 quitar lo del 6001
					
					SELECT LIMIT 1 mae.num_producto,mae.status_cred,mae.num_credito,tar.numcte, sm.status_cta INTO cNumProducto,cStatusCred,cNumCredito,cNumCte,cStatusCta
					FROM bdicheq:sc_tarjeta tar
					INNER JOIN bdicred:sd_maecred mae ON mae.numcte = tar.numcte
					JOIN bdicheq:sc_maechq sm ON sm.cuenta = tar.cuenta
					WHERE tar.num_tarjeta = pNumTarjetaDebito AND mae.status_cred IN ('E1','E2','E3') and num_producto <> '7800';
					
				END IF;
			
			ELSE
				--1âhacer la consulta tal como se tiene .
				SELECT mae.num_producto,mae.status_cred,mae.num_credito,tar.numcte, sm.status_cta INTO cNumProducto,cStatusCred,cNumCredito,cNumCte,cStatusCta
				FROM bdicheq:sc_tarjeta tar
				INNER JOIN bdicred:sd_maecred mae ON mae.numcte = tar.numcte
				JOIN bdicheq:sc_maechq sm ON sm.cuenta = tar.cuenta
				WHERE tar.num_tarjeta = pNumTarjetaDebito AND
				mae.num_producto <> '7800' and mae.status_cred IN ('E1','E2','E3');
				
			END IF;
			
		END IF;
		
		
		
			--AGO - ValidaciÃ³n de Status
			IF (NVL(TRIM(cStatusCta),'') != '' and NVL(TRIM(cStatusCta),'') NOT IN ('1','4')) or NVL(TRIM(cNumCredito),'') != ''  THEN
				LET cCodRet     = '00004';	-- 'STATUS INCORRECTO CTA'
				RETURN cCodRet,cStatusCta,'nocta','','',0,0,0,DATE(1);
			END IF;
	
		
			SELECT st.num_tarjeta INTO cNumTDC FROM bdicred:sd_tarjeta st
				where st.secuencia = (SELECT MAX(sdt.secuencia) FROM bdicred:sd_tarjeta sdt WHERE sdt.num_credito=cNumCredito) 
				AND st.status_tar='A' AND st.num_credito=cNumCredito;

				
			EXECUTE PROCEDURE "informix".sp_enmascarado(cNumTDC,2) INTO cCodRet,cNumTDC;
	ELIF NVL(TRIM(pNumCredito),'') != '' THEN
		SELECT num_producto,status_cred,num_credito,numcte INTO cNumProducto,cStatusCred,cNumCredito,cNumCte
		FROM bdicred:sd_maecred
		WHERE num_credito = pNumCredito;
		
			SELECT st.num_tarjeta  INTO cNumTDC FROM bdicred:sd_tarjeta st
				where st.secuencia = (SELECT MAX(sdt.secuencia) FROM bdicred:sd_tarjeta sdt WHERE sdt.num_credito=pNumCredito) 
				AND st.status_tar='A' AND st.num_credito=pNumCredito;
				 
				EXECUTE PROCEDURE "informix".sp_enmascarado(cNumTDC,2) INTO cCodRet,cNumTDC;
	ELSE
		SELECT LIMIT 1 num_producto,status_cred,num_credito,numcte INTO cNumProducto,cStatusCred,cNumCredito,cNumCte
		FROM bdicred:sd_maecred
		WHERE numcte = pNumCliente;
	END IF;
	
	
	--AGO - ValidaciÃ³n de Status
	IF (NVL(TRIM(cStatusCred),'') NOT IN ('E1','E2','E3')) THEN
			LET cCodRet     = '00004';	-- 'STATUS INCORRECTO'
			RETURN cCodRet,'',cStatusCred,'','',0,0,0,DATE(1);
	END IF;

	
	--AGO - ValidaciÃ³n de producto 
	IF NVL(TRIM(cNumProducto),'') != '' AND NVL(TRIM(cNumProducto),'') in ('7800','6900','8900') THEN
			LET cCodRet     = '00004';	-- 'NO SE ACEPTA PRODUCTO 7800, 6900,8900'
			RETURN cCodRet,'','NO PROD 7800',cNumProducto,'',0,0,0,DATE(1);
	END IF;
	
	SELECT TRIM(NVL(apell_paterno,'')),TRIM(NVL(apell_materno,'')),TRIM(NVL(nombre1,'')),TRIM(NVL(nombre2,'')) INTO cApellPaterno,cApellMaterno,cNombre1,cNombre2
	FROM bdinteg:si_cliente 
	WHERE numcte = cNumCte;

	IF cNombre1 IS NOT NULL AND cNombre1 != '' THEN
		EXECUTE PROCEDURE "informix".sp_enmascarado(cNombre1,1) INTO cCodRet,cNombre1;
		LET cNomCliente = TRIM(cNomCliente) || ' ' || TRIM(cNombre1);
	ELSE
		LET cCodRet     = '00004';	-- 'NO SE OBTUVIERON RESULTADOS'
		RETURN cCodRet,'','sin datos','','',0,0,0,DATE(1);
	END IF;

	IF cNombre2 IS NOT NULL AND cNombre2 != '' THEN
		EXECUTE PROCEDURE "informix".sp_enmascarado(cNombre2,1) INTO cCodRet,cNombre2;
		LET cNomCliente = TRIM(cNomCliente) || ' ' || TRIM(cNombre2);
	END IF;

	IF cApellPaterno IS NOT NULL AND cApellPaterno != '' THEN
		EXECUTE PROCEDURE "informix".sp_enmascarado(cApellPaterno,1) INTO cCodRet,cApellPaterno;
		LET cNomCliente = TRIM(cNomCliente) || ' ' || TRIM(cApellPaterno);
	END IF;
	
	IF cApellMaterno IS NOT NULL AND cApellMaterno != '' THEN
		EXECUTE PROCEDURE "informix".sp_enmascarado(cApellMaterno,1) INTO cCodRet,cApellMaterno;
		LET cNomCliente = TRIM(cNomCliente) || ' ' || TRIM(cApellMaterno);
	END IF;

	FOREACH                
		EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(cEmpresa, cNumCredito) INTO
				cCodRet, cMensajeRetornoCSG, cNumeroCreditoCSG, cCodigoTipcredCSG, dFechaOrigenCSG, dFechaProxPagoCSG,
				dPagoMinimoCSG, dFechaUltPagoCSG, iPlazoCSG, iPagosRealizadosCSG, dLineaOtorgadaCSG, dTasaInteresCSG, dTasaMoratoriosCSG,
				dMontoSbcCSG, dCapVigCSG, dCapTransCSG, dCapVdoExigCSG, dCapVdoNoExigCSG, dSdoActTotalCapCSG, dIntVigCSG, dIntVdoCSG, dIntMoratoriosCSG,
				dIntMesCSG, dSdoActTotalIntCSG, dIvaIntVigCSG, dIvaIntVdoCSG, dIvaIntMoratoriosCSG, dIvaIntMesCSG, dSdoActTotalIvaCSG, dComPendCSG,
				dIvaComCSG, dSdoRetenidoCSG, dTotalLiquidacionCSG, dIntDevengadoCSG, dIvaIntDevengadoCSG, dLineaDisponibleCSG, dPagosVdosCSG,
				cDescStatusCredCSG, iIdBloqueoCredCSG, cBloqueoCtaCSG, cIdCausaBloqueoCSG, cCausaBloqueoCtaCSG, cIdSitEspCteCSG,
				iIdCausaEspCteCSG, cSitEspCteCSG, cIdSitEspCredCSG, iIdCausaEspCredCSG, cSitEspCredCSG

		LET iRegistros = iRegistros + 1;
		LET cTipoCredito = pTipoProducto;

		IF cCodRet::integer != 0 THEN
			IF cCodRet::integer != 2 THEN
				LET cCodRet     = '00006'; -- 'ERROR EN LA CONSULTA DE SALDOS'
			ELSE
				LET cCodRet     = '00007'; -- 'NO HAY INFORMACION DE SALDOS'
			END IF;
			LET iRegistros  = 0; 
			EXIT FOREACH;
		END IF;

		IF dPagoMinimoCSG <= 0 THEN
		LET dPagoMinimo = '0';
		ELSE
		LET dPagoMinimo = dPagoMinimoCSG;
		END IF;
		
		IF dTotalLiquidacionCSG <= 0 THEN
		LET dSaldoTotal = '0';
		ELSE
		LET dSaldoTotal = dTotalLiquidacionCSG;
		END IF;
		
		IF dSdoActTotalCapCSG <= 0 THEN
		LET dPagoNoGenInteres = '0';
		ELSE
		LET dPagoNoGenInteres = dSdoActTotalCapCSG;
		END IF;
		
		IF dFechaProxPagoCSG = '01-01-1900' THEN
		LET dFechaLimPago = '';
		ELSE
		LET dFechaLimPago = dFechaProxPagoCSG;
		END IF;
				
		RETURN cCodRet,cTipoCredito,cNomCliente,cNumCredito,dPagoMinimo,dPagoNoGenInteres,dSaldoTotal,dFechaLimPago,cNumTDC WITH RESUME;
	END FOREACH;			


ELIF pTipoProducto =  'OT' THEN    --Gabo
	
	IF NVL(TRIM(pNumTarjetaDebito),'') != '' THEN
		
		let cNumTarjetaCredito = pNumTarjetaDebito;
		
		SELECT creditodebito INTO cTipoTarjeta FROM intercard:bines -- Para obtener si es Credito o debito de acuerdo al bin de la tarjeta
		WHERE bin = SUBSTR (cNumTarjetaCredito,0,6);
		
		LET cTipoTarjeta = cTipoTarjeta; -- para ver el resultado de la variable
		
		IF cTipoTarjeta = 'D' THEN
			LET cCodRet     = '00009';	-- 'NO PUEDES BUSCAR UNA TDD PARA PAGO DE OTRA TARJETA'
			RETURN cCodRet,'','','','',0,0,0,DATE(1);
		ELIF cTipoTarjeta is null THEN
			LET cCodRet     = '00010';	-- 'TARJETA INVALIDA'
			RETURN cCodRet,'','','','',0,0,0,DATE(1);
		END IF;
				
			
		SELECT num_credito, numcte INTO cNumCredito,cNumCte    -- para obtener el numero de cliente de la tdc digitada
		FROM bdicred:sd_tarjeta 
		WHERE num_tarjeta  = cNumTarjetaCredito;
		
		EXECUTE PROCEDURE "informix".sp_enmascarado(cNumTarjetaCredito,2) INTO cCodRet,cNumTDC;
	ELSE
		LET cCodRet     = '00004';	-- 'NO SE OBTUVIERON RESULTADOS'
		RETURN cCodRet,'','sin RESULTADOS','','',0,0,0,DATE(1);
	END IF;				--Gabo
	
	SELECT TRIM(NVL(apell_paterno,'')),TRIM(NVL(apell_materno,'')),TRIM(NVL(nombre1,'')),TRIM(NVL(nombre2,'')) INTO cApellPaterno,cApellMaterno,cNombre1,cNombre2
	FROM bdinteg:si_cliente 
	WHERE numcte = cNumCte;

	IF cNombre1 IS NOT NULL AND cNombre1 != '' THEN
		EXECUTE PROCEDURE "informix".sp_enmascarado(cNombre1,1) INTO cCodRet,cNombre1;
		LET cNomCliente = TRIM(cNomCliente) || ' ' || TRIM(cNombre1);
	ELSE
		LET cCodRet     = '00004';	-- 'NO SE OBTUVIERON RESULTADOS'
		RETURN cCodRet,'','SIN RESULTADOS 2','','',0,0,0,DATE(1);
	END IF;

	IF cNombre2 IS NOT NULL AND cNombre2 != '' THEN
		EXECUTE PROCEDURE "informix".sp_enmascarado(cNombre2,1) INTO cCodRet,cNombre2;
		LET cNomCliente = TRIM(cNomCliente) || ' ' || TRIM(cNombre2);
	END IF;

	IF cApellPaterno IS NOT NULL AND cApellPaterno != '' THEN
		EXECUTE PROCEDURE "informix".sp_enmascarado(cApellPaterno,1) INTO cCodRet,cApellPaterno;
		LET cNomCliente = TRIM(cNomCliente) || ' ' || TRIM(cApellPaterno);
	END IF;
	
	IF cApellMaterno IS NOT NULL AND cApellMaterno != '' THEN
		EXECUTE PROCEDURE "informix".sp_enmascarado(cApellMaterno,1) INTO cCodRet,cApellMaterno;
		LET cNomCliente = TRIM(cNomCliente) || ' ' || TRIM(cApellMaterno);
	END IF;

	FOREACH                
		EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(cEmpresa, cNumCredito) INTO
				cCodRet, cMensajeRetornoCSG, cNumeroCreditoCSG, cCodigoTipcredCSG, dFechaOrigenCSG, dFechaProxPagoCSG,
				dPagoMinimoCSG, dFechaUltPagoCSG, iPlazoCSG, iPagosRealizadosCSG, dLineaOtorgadaCSG, dTasaInteresCSG, dTasaMoratoriosCSG,
				dMontoSbcCSG, dCapVigCSG, dCapTransCSG, dCapVdoExigCSG, dCapVdoNoExigCSG, dSdoActTotalCapCSG, dIntVigCSG, dIntVdoCSG, dIntMoratoriosCSG,
				dIntMesCSG, dSdoActTotalIntCSG, dIvaIntVigCSG, dIvaIntVdoCSG, dIvaIntMoratoriosCSG, dIvaIntMesCSG, dSdoActTotalIvaCSG, dComPendCSG,
				dIvaComCSG, dSdoRetenidoCSG, dTotalLiquidacionCSG, dIntDevengadoCSG, dIvaIntDevengadoCSG, dLineaDisponibleCSG, dPagosVdosCSG,
				cDescStatusCredCSG, iIdBloqueoCredCSG, cBloqueoCtaCSG, cIdCausaBloqueoCSG, cCausaBloqueoCtaCSG, cIdSitEspCteCSG,
				iIdCausaEspCteCSG, cSitEspCteCSG, cIdSitEspCredCSG, iIdCausaEspCredCSG, cSitEspCredCSG

		LET iRegistros = iRegistros + 1;
		LET cTipoCredito = pTipoProducto;

		IF cCodRet::integer != 0 THEN
			IF cCodRet::integer != 2 THEN
				LET cCodRet     = '00006'; -- 'ERROR EN LA CONSULTA DE SALDOS'
			ELSE
				LET cCodRet     = '00007'; -- 'NO HAY INFORMACION DE SALDOS'
			END IF;
			LET iRegistros  = 0; 
			EXIT FOREACH;
		END IF;
		
		IF dPagoMinimoCSG <= 0 THEN
		LET dPagoMinimo = '0';
		ELSE
		LET dPagoMinimo = dPagoMinimoCSG;
		END IF;
		
		IF dTotalLiquidacionCSG <= 0 THEN
		LET dSaldoTotal = '0';
		ELSE
		LET dSaldoTotal = dTotalLiquidacionCSG;
		END IF;
		
		IF dSdoActTotalCapCSG <= 0 THEN
		LET dPagoNoGenInteres = '0';
		ELSE
		LET dPagoNoGenInteres = dSdoActTotalCapCSG;
		END IF;
		
		IF dFechaProxPagoCSG = '01-01-1900' THEN
		LET dFechaLimPago = '';
		ELSE
		LET dFechaLimPago = dFechaProxPagoCSG;
		END IF;
				
		RETURN cCodRet,cTipoCredito,cNomCliente,cNumCredito,dPagoMinimo,dPagoNoGenInteres,dSaldoTotal,dFechaLimPago,cNumTDC WITH RESUME;
	END FOREACH;
	
	
ELIF pTipoProducto IN ('P2', 'PN', 'P8', 'P4', 'PT', 'PM', 'PD', 'RD') THEN
/*	IF NVL(TRIM(pNumCredito),'') = '' AND NVL(TRIM(pNumCliente),'') = '' THEN
		LET cCodRet     = '00002';	-- 'NO SE ESPECIFICA NINGUN DATO DE CONSULTA DE ENTRADA'
		RETURN cCodRet,cTipoCredito,cNomCliente,cNumCredito,dPagoMinimo,dPagoNoGenInteres,dSaldoTotal,dFechaLimPago;
	END IF;*/
	
		
	CASE pTipoProducto
		WHEN 'P2' THEN LET cNumProducto = '6300';
		WHEN 'PN' THEN LET cNumProducto = '6400';
		WHEN 'P8' THEN LET cNumProducto = '7600';
		WHEN 'P4' THEN LET cNumProducto = '7700';
		WHEN 'PT' THEN LET cNumProducto = '9100';
		WHEN 'PM' THEN LET cNumProducto = '9300';
		WHEN 'PD' THEN LET cNumProducto = '6800';
		WHEN 'RD' THEN LET cNumProducto = '6011';
	END CASE;

	IF NVL(TRIM(pNumTarjetaDebito),'') != '' THEN
		SELECT mae.num_credito, tar.numcte, mae.num_producto INTO cNumCredito,cNumCte,cNumProductoVal
		FROM bdicheq:sc_tarjeta tar
		INNER JOIN bdicred:sd_maecredcrd mae ON mae.numcte = tar.numcte
		WHERE num_tarjeta = pNumTarjetaDebito and mae.num_producto = cNumProducto;
	ELIF NVL(TRIM(pNumCredito),'') != '' THEN
		SELECT LIMIT 1 num_credito, numcte, num_producto INTO cNumCredito,cNumCte,cNumProductoVal
		FROM bdicred:sd_maecredcrd
		WHERE num_credito = pNumCredito;
	ELSE
		SELECT LIMIT 1 num_credito, numcte, num_producto INTO cNumCredito,cNumCte,cNumProductoVal
		FROM bdicred:sd_maecredcrd
		WHERE numcte = pNumCliente and num_producto = cNumProducto;
	END IF;
	
	--AGO - ValidaciÃ³n de producto 
	IF NVL(TRIM(cNumProductoVal),'') != '' AND NVL(TRIM(cNumProductoVal),'') IN ('6900','8900') THEN
			LET cCodRet     = '00004';	-- 'NO SE ACEPTA PRODUCTO '6900','8900''
			RETURN cCodRet,'','NO PROD 6900 8900',cNumProductoVal,'',0,0,0,DATE(1);
	END IF;

	SELECT TRIM(NVL(apell_paterno,'')),TRIM(NVL(apell_materno,'')),TRIM(NVL(nombre1,'')),TRIM(NVL(nombre2,'')) INTO cApellPaterno,cApellMaterno,cNombre1,cNombre2
	FROM bdinteg:si_cliente 
	WHERE numcte = cNumCte;

	IF cNombre1 IS NOT NULL AND cNombre1 != '' THEN
		EXECUTE PROCEDURE "informix".sp_enmascarado(cNombre1,1) INTO cCodRet,cNombre1;
		LET cNomCliente = TRIM(cNomCliente) || ' ' || TRIM(cNombre1);
	ELSE
		LET cCodRet     = '00004';	-- 'NO SE OBTUVIERON RESULTADOS'
		RETURN cCodRet,'','SIN RESULTADOS X3','','',0,0,0,DATE(1);
	END IF;

	IF cNombre2 IS NOT NULL AND cNombre2 != '' THEN
		EXECUTE PROCEDURE "informix".sp_enmascarado(cNombre2,1) INTO cCodRet,cNombre2;
		LET cNomCliente = TRIM(cNomCliente) || ' ' || TRIM(cNombre2);
	END IF;

	IF cApellPaterno IS NOT NULL AND cApellPaterno != '' THEN
		EXECUTE PROCEDURE "informix".sp_enmascarado(cApellPaterno,1) INTO cCodRet,cApellPaterno;
		LET cNomCliente = TRIM(cNomCliente) || ' ' || TRIM(cApellPaterno);
	END IF;
	
	IF cApellMaterno IS NOT NULL AND cApellMaterno != '' THEN
		EXECUTE PROCEDURE "informix".sp_enmascarado(cApellMaterno,1) INTO cCodRet,cApellMaterno;
		LET cNomCliente = TRIM(cNomCliente) || ' ' || TRIM(cApellMaterno);
	END IF;

	FOREACH                
		EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(cEmpresa, cNumCredito) INTO
				cCodRet, cMensajeRetornoCSG, cNumeroCreditoCSG, cCodigoTipcredCSG, dFechaOrigenCSG, dFechaProxPagoCSG,
				dPagoMinimoCSG, dFechaUltPagoCSG, iPlazoCSG, iPagosRealizadosCSG, dLineaOtorgadaCSG, dTasaInteresCSG, dTasaMoratoriosCSG,
				dMontoSbcCSG, dCapVigCSG, dCapTransCSG, dCapVdoExigCSG, dCapVdoNoExigCSG, dSdoActTotalCapCSG, dIntVigCSG, dIntVdoCSG, dIntMoratoriosCSG,
				dIntMesCSG, dSdoActTotalIntCSG, dIvaIntVigCSG, dIvaIntVdoCSG, dIvaIntMoratoriosCSG, dIvaIntMesCSG, dSdoActTotalIvaCSG, dComPendCSG,
				dIvaComCSG, dSdoRetenidoCSG, dTotalLiquidacionCSG, dIntDevengadoCSG, dIvaIntDevengadoCSG, dLineaDisponibleCSG, dPagosVdosCSG,
				cDescStatusCredCSG, iIdBloqueoCredCSG, cBloqueoCtaCSG, cIdCausaBloqueoCSG, cCausaBloqueoCtaCSG, cIdSitEspCteCSG,
				iIdCausaEspCteCSG, cSitEspCteCSG, cIdSitEspCredCSG, iIdCausaEspCredCSG, cSitEspCredCSG

		LET iRegistros = iRegistros + 1;
		LET cTipoCredito = pTipoProducto;

		IF cCodRet::integer != 0 THEN
			IF cCodRet::integer != 2 THEN
				LET cCodRet     = '00006'; -- 'ERROR EN LA CONSULTA DE SALDOS'
			ELSE
				LET cCodRet     = '00007'; -- 'NO HAY INFORMACION DE SALDOS'
			END IF;
			LET iRegistros  = 0; 
			EXIT FOREACH; 
		END IF;
        
		IF dPagoMinimoCSG <= 0 and dTotalLiquidacionCSG <= 0 and dSdoActTotalCapCSG <= 0 and dFechaProxPagoCSG = '01-01-1900'  THEN
		  LET cCodRet     = '00007';	-- 'NO HAY INFORMACION DE SALDOS'
		  RETURN cCodRet,'','','','',0,0,0,DATE(1);
		ELSE
		  LET dPagoMinimo = dPagoMinimoCSG;
		  LET dSaldoTotal = dTotalLiquidacionCSG;
		  LET dPagoNoGenInteres = dSdoActTotalCapCSG;
		  LET dFechaLimPago = dFechaProxPagoCSG;
		END IF;
		
        IF dPagoMinimoCSG <= 0 THEN
		LET dPagoMinimo = '0';
		ELSE
		LET dPagoMinimo = dPagoMinimoCSG;
		END IF;
		
		IF dTotalLiquidacionCSG <= 0 THEN
		LET dSaldoTotal = '0';
		ELSE
		LET dSaldoTotal = dTotalLiquidacionCSG;
		END IF;
		
		IF dSdoActTotalCapCSG <= 0 THEN
		LET dPagoNoGenInteres = '0';
		ELSE
		LET dPagoNoGenInteres = dSdoActTotalCapCSG;
		END IF;
		
		IF dFechaProxPagoCSG = '01-01-1900' THEN
		LET dFechaLimPago = '';
		ELSE
		LET dFechaLimPago = dFechaProxPagoCSG;
		END IF;

		RETURN cCodRet,cTipoCredito,cNomCliente,cNumCredito,dPagoMinimo,dPagoNoGenInteres,dSaldoTotal,dFechaLimPago,cNumTDC WITH RESUME;
	END FOREACH;			
ELSE
	LET cCodRet     = '00003';	-- 'TIPO DE CREDITO NO VALIDO'
	RETURN cCodRet,'','','','',0,0,0,DATE(1);
END IF;
   
IF iRegistros  = 0 THEN
	LET cCodRet     = '00004';	-- 'NO SE OBTUVIERON RESULTADOS'
	RETURN cCodRet,cTipoCredito,cNomCliente,cNumCredito,dPagoMinimo,dPagoNoGenInteres,dSaldoTotal,dFechaLimPago,cNumTDC;
END IF;

END;
END PROCEDURE;
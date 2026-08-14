CREATE PROCEDURE "informix".sp_prestamoflex_multicanal(pEmpresa   VARCHAR(3), pServicio CHAR(3),    pNum_tarjeta CHAR(20), pNum_Cte    CHAR(20), pNum_Telefono CHAR(20), 
													   pNum_Credito CHAR(20), pSaldo DECIMAL (18,2),pParametro1  CHAR(20), pParametro2 CHAR(20), pParametro3   CHAR(20))
													   -- pParametro1   -- Id de ATM cuando canal es ATM
													   -- pParametro2	-- Id de Canal de acuerdo a tabla si_canal
																			-- Canales: 8 ATM / 9 SMS / 23 WHATSAPP / 17 APP
									
RETURNING CHAR(6), DECIMAL (18,2), DECIMAL (18,2), DECIMAL (18,2), DATE, DECIMAL(9,6), CHAR(20), CHAR(20);

---DECLARACION DE VARIABLES
DEFINE iSqlErr 				INTEGER;
DEFINE isam_err 			INTEGER;
DEFINE error_info 			CHAR(80);
DEFINE cProceso         	CHAR(4);
DEFINE cCod_retBit      	CHAR(6);
DEFINE cCodRet				CHAR(6);
DEFINE cMensajeErr			CHAR(60);
DEFINE dSaldo1_Ret			DECIMAL (18,2);
DEFINE dSaldo2_Ret			DECIMAL (18,2);
DEFINE dSaldo3_Ret			DECIMAL (18,2); 
DEFINE sFecha_Ret			DATE;
DEFINE sTasaInt_Ret 		DECIMAL(9,6);
DEFINE sCta_Cheq_Ret		CHAR(20);
DEFINE sParam2_Ret			CHAR(20);
DEFINE dFechaHoy			DATE;
DEFINE sCtaCheques			CHAR(20);
DEFINE cNum_Credito			CHAR(20);
DEFINE cNum_CreditoTdc		CHAR(20);
DEFINE iContador			INTEGER;
DEFINE dMonto_linea			DECIMAL(18,2);
DEFINE dLin_disponible		DECIMAL(18,2);
DEFINE cMsjRet				CHAR(80);		-- Variables para consulta saldos general
DEFINE cNumCredito1			CHAR(20);
DEFINE cCodTCred			CHAR(2);
DEFINE dFechaOrig			DATE;
DEFINE dFechaProxPag 		DATE;
DEFINE dcPagoMin			DECIMAL(18,2);
DEFINE dFechaUltPag			DATE;
DEFINE iPlazo				INTEGER;
DEFINE iPagRealizados		INTEGER;
DEFINE dcLinOtorgada		DECIMAL(18,2);
DEFINE dcTasaInteres		DECIMAL(9,6);
DEFINE dcTasaMoratorios 	DECIMAL(9,6);
DEFINE dcMontoSbs			DECIMAL(14,2);
DEFINE dcCapVig				DECIMAL(18,2);
DEFINE dcCapTrans			DECIMAL(18,2);
DEFINE dcCapVdoExig			DECIMAL(18,2);
DEFINE dcCapVdoNoExig		DECIMAL(18,2);
DEFINE dcSdoActTotCap		DECIMAL(18,2);
DEFINE dcIntVig				DECIMAL(18,2);
DEFINE dcIntVdo				DECIMAL(18,2);
DEFINE dcIntMoratorio		DECIMAL(18,2);
DEFINE dcIntMes				DECIMAL(18,2);
DEFINE dcSodActTotInt		DECIMAL(18,2);
DEFINE dcIvaIntVig			DECIMAL(18,2);
DEFINE dcIvaIntVdo			DECIMAL(18,2);
DEFINE dcIvaIntMor			DECIMAL(18,2);
DEFINE dcIvaIntMes			DECIMAL(18,2);
DEFINE dcSdoActTotIva		DECIMAL(18,2);
DEFINE dcComPend			DECIMAL(18,2);
DEFINE dcIvaCom				DECIMAL(18,2);
DEFINE dcSdoRetenido		DECIMAL(18,2);
DEFINE dcTotalLiq			DECIMAL(18,2);
DEFINE dcIntDevengado		DECIMAL(18,2);
DEFINE dcIvaIntDevengado	DECIMAL(18,2);
DEFINE dcLinDisp			DECIMAL(18,2);
DEFINE dcPagosVdos			DECIMAL(18,2);
DEFINE cDescStatusCred		CHAR(60);
DEFINE iIdBloqueoCred		INTEGER;
DEFINE cBloqCta				CHAR(60);
DEFINE cIdCausaBloqCred		CHAR(3);
DEFINE cCausaBloqCta		CHAR(50);
DEFINE cIdSitEspCte			CHAR(1);
DEFINE iIdCausaEspCte		INTEGER;
DEFINE cSitEspCte			CHAR(75);
DEFINE cIdSitEspCred		CHAR(1);
DEFINE iIdCausaEspCred		INTEGER;
DEFINE cSitEspCred 			CHAR(75);		-- Fin consulta saldos genera
DEFINE iPorCondicionSupuesto2	INTEGER;
DEFINE iPorSupuesto1			INTEGER;
DEFINE iPorSupuesto2			INTEGER;
DEFINE iPorCondicionSupuesto3	INTEGER;
DEFINE dCalculoMntoSim 		DECIMAL(18,2);
DEFINE cPeriodo_Plazo		CHAR(1);
DEFINE cProducto			CHAR(4);
DEFINE cSucursal			CHAR(4);
DEFINE iFrecuencia			INTEGER;
DEFINE dTasa_Int			DECIMAL(9,6);
DEFINE iNum_periodos        INTEGER;
DEFINE dtFecha_cuota        DATE;
DEFINE dSdo_inicial         MONEY(14,2);
DEFINE dPago_mensual        DECIMAL(18,2);
DEFINE dMto_Interes         MONEY(14,2);
DEFINE dIva_interes         MONEY(14,2);
DEFINE dCapital             MONEY(14,2);
DEFINE dSdo_final           MONEY(14,2);
DEFINE sDias_periodo        SMALLINT;
DEFINE dtFecha_Aper			DATE;
DEFINE cNumMesesPagos   	CHAR(3);
DEFINE dTotalPagar			DECIMAL(18,2);
DEFINE dMensualidad			DECIMAL(18,2);
DEFINE dCanal				SMALLINT;
DEFINE cNumCel				CHAR(20);
DEFINE cNumCte				CHAR(20);
DEFINE iMontoMin			INTEGER;
DEFINE sFechaCancela		DATE;	
DEFINE inumpagos 			INTEGER;
DEFINE iNumpag_aux			INTEGER;
DEFINE sNumPagosReprest		SMALLINT;
DEFINE iNumDisp_pf			INTEGER;
DEFINE cStatusCred			CHAR(2);
DEFINE cNumeroFolio 		CHAR(16);

-- IFSR variables
DEFINE iAtr  INTEGER;


--SET DEBUG FILE TO "/informix/mahr/pf_app/sp_prestamoflex_multicanal.out";
--TRACE ON;


---INICIALIZACION DE VARIABLES
LET iSqlErr 			= 0;
LET isam_err 			= 0;
LET error_info 			= '';
LET cProceso			= '0109';
LET cCod_retBit			= '000000';
LET cCodRet  			= '000000';
LET cMensajeErr			= '';
LET dSaldo1_Ret			= 0;
LET dSaldo2_Ret			= 0;
LET dSaldo3_Ret			= 0;
LET sFecha_Ret			= date(1);
LET sTasaInt_Ret 		= 0;
LET sCta_Cheq_Ret		= '';
LET sParam2_Ret			= '';
LET dFechaHoy			= date(1);
LET sCtaCheques			= '';
LET cNum_Credito		= '';
LET cNum_CreditoTdc		= '';
LET iContador			= 0;
LET dMonto_linea		= 0;
LET dLin_disponible		= 0;
LET cMsjRet				= '';		-- Variables para consulta saldos general
LET cNumCredito1		= '';
LET cCodTCred			= '';
LET dFechaOrig			= date(1);
LET dFechaProxPag 		= date(1);
LET dcPagoMin			= 0;
LET dFechaUltPag		= date(1);
LET iPlazo				= 0;
LET iPagRealizados		= 0;
LET dcLinOtorgada		= 0;
LET dcTasaInteres		= 0;
LET dcTasaMoratorios 	= 0;
LET dcMontoSbs			= 0;
LET dcCapVig			= 0;
LET dcCapTrans			= 0;
LET dcCapVdoExig		= 0;
LET dcCapVdoNoExig		= 0;
LET dcSdoActTotCap		= 0;
LET dcIntVig			= 0;
LET dcIntVdo			= 0;
LET dcIntMoratorio		= 0;
LET dcIntMes			= 0;
LET dcSodActTotInt		= 0;
LET dcIvaIntVig			= 0;
LET dcIvaIntVdo			= 0;
LET dcIvaIntMor			= 0;
LET dcIvaIntMes			= 0;
LET dcSdoActTotIva		= 0;
LET dcComPend			= 0;
LET dcIvaCom			= 0;
LET dcSdoRetenido		= 0;
LET dcTotalLiq			= 0;
LET dcIntDevengado		= 0;
LET dcIvaIntDevengado	= 0;
LET dcLinDisp			= 0;
LET dcPagosVdos			= 0;
LET cDescStatusCred		= '';
LET iIdBloqueoCred		= 0;
LET cBloqCta			= '';
LET cIdCausaBloqCred	= '';
LET cCausaBloqCta		= '';
LET cIdSitEspCte		= '';
LET iIdCausaEspCte		= 0;
LET cSitEspCte			= '';
LET cIdSitEspCred		= '';
LET iIdCausaEspCred		= 0;
LET cSitEspCred 		= '';		-- Fin consulta saldos general
LET iPorCondicionSupuesto2			= 0;
LET iPorSupuesto1			= 0;
LET iPorSupuesto2			= 0;
LET iPorCondicionSupuesto3	= 0;
LET dCalculoMntoSim 	= 0;
LET cPeriodo_Plazo		= '';
LET cProducto			= '';
LET cSucursal			= '';
LET iFrecuencia			= 0;
LET dTasa_Int			= 0;
LET iNum_periodos       = 0;
LET dtFecha_cuota       = date(1);
LET dSdo_inicial        = 0;
LET dPago_mensual       = 0;
LET dMto_Interes        = 0;
LET dIva_interes        = 0;
LET dCapital            = 0;
LET dSdo_final          = 0;
LET sDias_periodo       = 0;
LET dtFecha_Aper		= date(1);
LET cNumMesesPagos   	= '';
LET dTotalPagar			= 0;
LET dMensualidad		= 0;
LET dCanal				= 0;
LET cNumCel				= '';
LET cNumCte				= '';
LET sFechaCancela		= date(1);
LET iMontoMin			= 0;
LET inumpagos			= 0;
LET iNumpag_aux			= 0;
LET sNumPagosReprest	= 0;
LET iNumDisp_pf			= 0;
LET cStatusCred			= '';
LET cNumeroFolio		= '';

-- IFSR variables
LET iAtr 			= 0;

BEGIN

ON EXCEPTION SET iSqlErr, isam_err, error_info
	LET cCodRet = iSqlErr;
	CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, "Error-"||isam_err||"-"||trim(error_info)||"-"||cNum_Credito, '02') Returning cCod_retBit;

	-- Registra en bitacora ejecucion solicitada
	INSERT INTO bdicred:"informix".sd_bitacora_prest_flex_multicanal VALUES(pEmpresa, pServicio, pNum_tarjeta, pNum_Cte, pNum_Telefono, pNum_Credito,
														pSaldo, pParametro1, pParametro2, pParametro3,cCodRet,trim(cMensajeErr)||"-"||error_info ,current);
	
	RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;
END EXCEPTION;

	-- Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	-- Valida los datos de entrada
	IF NVL(pNum_tarjeta,'') = '' AND NVL(pNum_Cte,'') = '' AND NVL(pNum_Telefono,'') = '' AND NVL(pNum_Credito,'') = '' THEN
		LET cCodRet = '000021';		LET dSaldo1_Ret = 0;	LET dSaldo2_Ret = 0;	LET dSaldo3_Ret = 0;	
		LET sFecha_Ret = dFechaHoy;	LET sTasaInt_Ret = 0;	LET sCta_Cheq_Ret = ''; LET sParam2_Ret	= '';
		RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;			
	END IF

	-- Realiza lectura de parametros iniciales
	SELECT fecha_hoy INTO dFechaHoy FROM bdicred:"informix".sd_fechas;

	
	-- Registra en bitacora ejecucion solicitada
	INSERT INTO bdicred:"informix".sd_bitacora_prest_flex_multicanal VALUES(pEmpresa, pServicio, pNum_tarjeta, pNum_Cte, pNum_Telefono, pNum_Credito,
				pSaldo, pParametro1, pParametro2, pParametro3, cCodRet, cMensajeErr, current);
	
	-- Realiza validaciones de los datos de entrada para identificar el credito y cuenta de cheques ligada.
	IF pNum_tarjeta IS NULL THEN LET pNum_tarjeta = ''; END IF;	
	IF pNum_Credito IS NULL THEN LET pNum_Credito = ''; END IF;	
	IF pNum_Telefono IS NULL THEN LET pNum_Telefono = ''; END IF;
	IF pNum_Cte IS NULL THEN LET pNum_Cte = ''; END IF;	
	
	-- IFSR se asigna el valor del ATR
	SELECT nvl(atr,0)
	INTO iAtr
	FROM bdicred:sd_maesdoscrd
	WHERE num_credito = pNum_Credito;
	
	-- Valida tarjeta enviada
	IF trim(pNum_tarjeta) != '' THEN
	
		-- Valida si la tarjeta es de cheques.
		SELECT cuenta, numcte INTO sCtaCheques, cNumCte FROM bdicheq:sc_tarjeta WHERE empresa = '001' AND num_tarjeta = pNum_tarjeta and status_tar = 'A';
		IF sCtaCheques IS NULL THEN LET sCtaCheques = ''; END IF;
		IF sCtaCheques != '' THEN							-- Tarjeta es de cheques. Se obtiene el numero de cuenta y credito.
			
			SELECT {+avoid_full (bdicred:sd_ctascarg)}  count(crd.num_credito) INTO iContador	-- Valida los creditos asignados. (Cancelados o activos)
			  FROM bdicred:sd_maecredcrd crd
			  JOIN bdicred:sd_linea_prestamo pf ON (crd.num_credito = pf.num_credito and crd.num_producto = '6800')
			  JOIN bdicred:sd_ctascarg cta ON (crd.num_credito = cta.num_credito)
			 WHERE cta.num_cta = sCtaCheques;
			   --AND pf.fecha_cancela IS NULL;
			   
			IF iContador = 0 THEN							-- Cliente no tiene asignado un credito Prestamo Flexible
				-- Evalua si existe solicitud en status AT
				LET iContador = 0;
				SELECT count(num_solicitud) INTO iContador FROM bdisolic:ss_solicitudes WHERE numcte = cNumCte AND num_producto = '6800' AND status_solicitud = 'AT';
				IF iContador > 0 THEN  
					LET cCodRet = '000007';		-- Existe solicitud autorizada, sin credito 6800, es decir, credito no activo
					RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;						
				END IF
				LET iContador = 0;
				SELECT count(num_solicitud) INTO iContador FROM bdisolic:ss_solicitudes WHERE numcte = cNumCte AND num_producto = '6800' AND status_solicitud in ('RT','CN');
				IF iContador > 0 THEN  
					LET cCodRet = '000008';		-- Existe solicitud 6800 rechazada
					RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;						
				END IF
				
				LET cCodRet = '000001';
				RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;		
			END IF;

			-- Cliente tiene al menos 1 credto (Al menos 1 credito asignado. Se verifica si son activos o cancelados)
			LET iContador = 0;
			SELECT {+avoid_full (bdicred:sd_ctascarg)}  count(crd.num_credito) INTO iContador	-- Valida los creditos asignados que se encuentren activos (Cte con activos y cancelados)
			  FROM bdicred:sd_maecredcrd crd
			  JOIN bdicred:sd_linea_prestamo pf ON (crd.num_credito = pf.num_credito and crd.num_producto = '6800')
			  JOIN bdicred:sd_ctascarg cta ON (crd.num_credito = cta.num_credito)
			 WHERE cta.num_cta = sCtaCheques
			   AND pf.fecha_cancela IS NULL;			
			   
			IF iContador = 0 THEN							-- El/los credito tiene fecha de cancelacion. No tiene credito activo.
				LET cCodRet = '000011';
				RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;		
			END IF;			   
				
			IF iContador = 1 THEN
															-- Obtiene el numero de credito de Prestamo Flexible
				SELECT{+avoid_full (bdicred:sd_ctascarg)}  crd.num_credito, pf.fecha_cancela INTO cNum_Credito, sFechaCancela		
				  FROM bdicred:sd_maecredcrd crd
				  JOIN bdicred:sd_linea_prestamo pf ON (crd.num_credito = pf.num_credito and crd.num_producto = '6800')
				  JOIN bdicred:sd_ctascarg cta ON (crd.num_credito = cta.num_credito)
				 WHERE cta.num_cta = sCtaCheques
				   AND pf.fecha_cancela IS NULL;
				   
				IF sFechaCancela IS NOT NULL THEN			-- Fecha de cancelacion no es nula, es decir, credito esta cancelado
					LET cCodRet = '000011';
					RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;		
				END IF;
				
			ELSE 											--- Es decir: iContador > 1 ==> Cliente tiene mas de un credito Prestamo Flexible activo
				LET cCodRet = '000021';
				RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;		
			END IF;
			
			IF cNum_Credito IS NULL THEN LET cNum_Credito = ''; END IF;
			IF cNum_Credito = '' THEN
				LET cCodRet = '000001';							-- Credito no se encuentra activo.
				RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;	
			END IF;
		
		-- Se busca informacion como tarjeta de credito.
		ELSE											
	
			SELECT num_credito, numcte INTO cNum_CreditoTdc, cNumCte FROM bdicred:sd_tarjeta WHERE empresa = '001' AND num_tarjeta = pNum_tarjeta and status_tar = 'A';
			IF cNum_CreditoTdc IS NULL THEN LET cNum_CreditoTdc = ''; END IF;
			IF cNum_CreditoTdc != '' THEN				-- Tarjeta es de credito. Obtiene numero de cliente
				SELECT numcte INTO cNumCte FROM bdicred:sd_maecred WHERE num_credito = cNum_CreditoTdc;

				SELECT count(crd.num_credito) INTO iContador
				 FROM bdicred:sd_maecredcrd crd
				 JOIN bdicred:sd_linea_prestamo pf ON (crd.num_credito = pf.num_credito and crd.num_producto = '6800')
				WHERE numcte = cNumCte;
				  --AND pf.fecha_cancela is null;
				  
				IF iContador = 0 THEN							-- Cliente no tiene asignado un credito Prestamo Flexible
				
					-- Evalua si existe solicitud en status AT
					LET iContador = 0;
					SELECT count(num_solicitud) INTO iContador FROM bdisolic:ss_solicitudes WHERE numcte = cNumCte AND num_producto = '6800' AND status_solicitud = 'AT';
					IF iContador > 0 THEN  
						LET cCodRet = '000007';		-- Existe solicitud autorizada, sin credito 6800, es decir, credito no activo
						RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;						
					END IF
					LET iContador = 0;
					SELECT count(num_solicitud) INTO iContador FROM bdisolic:ss_solicitudes WHERE numcte = cNumCte AND num_producto = '6800' AND status_solicitud in ('RT','CN');
					IF iContador > 0 THEN  
						LET cCodRet = '000008';		-- Existe solicitud 6800 rechazada
						RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;						
					END IF				
				
					LET cCodRet = '000001';
					RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;					
				END IF;

				-- Cliente tiene al menos 1 credto (Al menos 1 credito asignado. Se verifica si son activos o cancelados)
				LET iContador = 0;					
				SELECT count(crd.num_credito) INTO iContador	-- Valida los creditos asignados que se encuentren activos (Cte con activos y cancelados)
				  FROM bdicred:sd_maecredcrd crd
				  JOIN bdicred:sd_linea_prestamo pf ON (crd.num_credito = pf.num_credito and crd.num_producto = '6800')
				 WHERE numcte = cNumCte
				   AND pf.fecha_cancela is null;
				  
				IF iContador = 0 THEN							-- El/los credito tiene fecha de cancelacion. No tiene credito activo.
					LET cCodRet = '000011';
					RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;		
				END IF;			   
					
				IF iContador = 1 THEN				   			-- Obtiene el numero de credito de Prestamo Flexible
				
					SELECT crd.num_credito, pf.fecha_cancela INTO cNum_Credito, sFechaCancela
					 FROM bdicred:sd_maecredcrd crd
					 JOIN bdicred:sd_linea_prestamo pf ON (crd.num_credito = pf.num_credito and crd.num_producto = '6800')
					WHERE numcte = cNumCte
					  AND pf.fecha_cancela is null;	

					IF sFechaCancela IS NOT NULL THEN			-- Fecha de cancelacion no es nula, es decir, credito esta cancelado
						LET cCodRet = '000011';
						RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;		
					END IF;		

					IF cNum_Credito IS NULL THEN LET cNum_Credito = ''; END IF;
					IF cNum_Credito = '' THEN
						LET cCodRet = '000001';
						RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;					
					END IF;
			
					SELECT {+avoid_full (bdicred:sd_ctascarg)} num_cta INTO sCtaCheques FROM bdicred:sd_ctascarg WHERE num_credito = cNum_Credito;
					IF sCtaCheques IS NULL THEN LET sCtaCheques = ''; END IF;
					IF sCtaCheques = '' THEN
						LET cCodRet = '000001';
						RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;
					END IF;
				
				ELSE											-- Es decir: iContador > 1 ==> Cliente tiene mas de un credito Prestamo Flexible activo
					LET cCodRet = '000021';
					RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;		
				END IF;
				
			ELSE					-- No existe informacion en tarjeta de credito (previamente no existio en cheques). Num Tarjeta invalido
				LET cCodRet = '000021';
				RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;	
			END IF;
		END IF;
	
	-- Obtiene informacion en base al numero de cliente
	ELIF trim(pNum_Cte) != '' THEN
	
		SELECT count(crd.num_credito) INTO iContador
		 FROM bdicred:sd_maecredcrd crd
		 JOIN bdicred:sd_linea_prestamo pf ON (crd.num_credito = pf.num_credito and crd.num_producto = '6800')
		WHERE numcte = pNum_Cte;
		  --AND pf.fecha_cancela is null;
		  
		IF iContador = 0 THEN							-- Cliente no tiene asignado un credito Prestamo Flexible
		
			-- Evalua si existe solicitud en status AT
			LET iContador = 0;
			SELECT count(num_solicitud) INTO iContador FROM bdisolic:ss_solicitudes WHERE numcte = pNum_Cte AND num_producto = '6800' AND status_solicitud = 'AT';
			IF iContador > 0 THEN  
				LET cCodRet = '000007';		-- Existe solicitud autorizada, sin credito 6800, es decir, credito no activo
				RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;						
			END IF
			LET iContador = 0;
			SELECT count(num_solicitud) INTO iContador FROM bdisolic:ss_solicitudes WHERE numcte = pNum_Cte AND num_producto = '6800' AND status_solicitud in ('RT','CN');
			IF iContador > 0 THEN  
				LET cCodRet = '000008';		-- Existe solicitud 6800 rechazada
				RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;						
			END IF		
		
			LET cCodRet = '000001';
			RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;	
		END IF;

		-- Cliente tiene al menos 1 credto (Al menos 1 credito asignado. Se verifica si son activos o cancelados)			
		SELECT count(crd.num_credito) INTO iContador	-- Valida los creditos asignados que se encuentren activos (Cte con activos y cancelados)
		  FROM bdicred:sd_maecredcrd crd
		  JOIN bdicred:sd_linea_prestamo pf ON (crd.num_credito = pf.num_credito and crd.num_producto = '6800')
		 WHERE numcte = pNum_Cte
		   AND pf.fecha_cancela is null;	

		IF iContador = 0 THEN							-- El/los credito tiene fecha de cancelacion. No tiene credito activo.
			LET cCodRet = '000011';
			RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;		
		END IF;			   
		
		IF iContador = 1 THEN				
		
			SELECT crd.num_credito, pf.fecha_cancela INTO cNum_Credito, sFechaCancela			-- Obtiene el numero de credito de Prestamo Flexible
			 FROM bdicred:sd_maecredcrd crd
			 JOIN bdicred:sd_linea_prestamo pf ON (crd.num_credito = pf.num_credito and crd.num_producto = '6800')
			WHERE numcte = pNum_Cte
			  AND pf.fecha_cancela is null;
			  
			IF sFechaCancela IS NOT NULL THEN			-- Fecha de cancelacion no es nula, es decir, credito esta cancelado
				LET cCodRet = '000011';
				RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;		
			END IF;			  
			  
			IF cNum_Credito IS NULL THEN LET cNum_Credito = ''; END IF;
			IF cNum_Credito = '' THEN
				LET cCodRet = '000001';
				RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;			
			END IF;
			
			SELECT {+avoid_full (bdicred:sd_ctascarg)} num_cta INTO sCtaCheques FROM bdicred:sd_ctascarg WHERE num_credito = cNum_Credito;
			IF sCtaCheques IS NULL THEN LET sCtaCheques = ''; END IF;
			IF sCtaCheques = '' THEN
				LET cCodRet = '000001';
				RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;
			END IF;		
		
		ELSE 											-- Es decir: iContador > 1 ==> Cliente tiene mas de un credito Prestamo Flexible activo
			LET cCodRet = '000021';
			RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;		
		END IF;		
		
	
	-- Obtiene informacion en base al numero de telefono del cliente (celular).
	ELIF trim(pNum_Telefono) != '' THEN

		SELECT first 1 numcte INTO cNumCte FROM bdinteg:si_telefonos WHERE telefono = pNum_Telefono;
	
		SELECT count(crd.num_credito) INTO iContador
          FROM bdicred:sd_maecredcrd crd
          JOIN bdinteg:si_telefonos tel ON (crd.num_producto = '6800' AND crd.numcte = tel.numcte AND tel.tipo_tel = 2 AND tel.status_tel = 'A')
          JOIN bdicred:sd_linea_prestamo pf ON (crd.num_credito = pf.num_credito and crd.num_producto = '6800')
         WHERE tel.telefono = pNum_Telefono;
          --AND pf.fecha_cancela is null;		  
		  
		IF iContador = 0 THEN							-- Cliente no tiene asignado un credito Prestamo Flexible
		
			-- Evalua si existe solicitud en status AT
			LET iContador = 0;
			SELECT count(num_solicitud) INTO iContador FROM bdisolic:ss_solicitudes WHERE numcte = cNumCte AND num_producto = '6800' AND status_solicitud = 'AT';
			IF iContador > 0 THEN  
				LET cCodRet = '000007';		-- Existe solicitud autorizada, sin credito 6800, es decir, credito no activo
				RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;						
			END IF
			LET iContador = 0;
			SELECT count(num_solicitud) INTO iContador FROM bdisolic:ss_solicitudes WHERE numcte = cNumCte AND num_producto = '6800' AND status_solicitud in ('RT','CN');
			IF iContador > 0 THEN  
				LET cCodRet = '000008';		-- Existe solicitud 6800 rechazada
				RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;						
			END IF		
			
			LET cCodRet = '000001';
			RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;	
		END IF;

		-- Cliente tiene al menos 1 credto (Al menos 1 credito asignado. Se verifica si son activos o cancelados)
		LET iContador = 0;
		SELECT count(crd.num_credito) INTO iContador	-- Valida los creditos asignados que se encuentren activos (Cte con activos y cancelados)
          FROM bdicred:sd_maecredcrd crd
          JOIN bdinteg:si_telefonos tel ON (crd.num_producto = '6800' AND crd.numcte = tel.numcte AND tel.tipo_tel = 2 AND tel.status_tel = 'A')
          JOIN bdicred:sd_linea_prestamo pf ON (crd.num_credito = pf.num_credito and crd.num_producto = '6800')
         WHERE tel.telefono = pNum_Telefono
           AND pf.fecha_cancela is null;
		  
		IF iContador = 0 THEN							-- El/los credito tiene fecha de cancelacion. No tiene credito activo.
			LET cCodRet = '000011';
			RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;		
		END IF;			   
			
		IF iContador = 1 THEN

			SELECT crd.numcte, crd.num_credito, pf.fecha_cancela INTO cNumCte, cNum_Credito, sFechaCancela
			  FROM bdicred:sd_maecredcrd crd
			  JOIN bdinteg:si_telefonos tel ON (crd.num_producto = '6800' AND crd.numcte = tel.numcte AND tel.tipo_tel = 2 AND tel.status_tel = 'A')
			  JOIN bdicred:sd_linea_prestamo pf ON (crd.num_credito = pf.num_credito and crd.num_producto = '6800')
			 WHERE tel.telefono = pNum_Telefono
			  AND pf.fecha_cancela is null;
			  
			IF sFechaCancela IS NOT NULL THEN			-- Fecha de cancelacion no es nula, es decir, credito esta cancelado
				LET cCodRet = '000011';
				RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;		
			END IF;				  
			  
			IF cNum_Credito IS NULL THEN LET cNum_Credito = ''; END IF;
			IF cNum_Credito = '' THEN
				LET cCodRet = '000001';
				RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;			
			END IF;		 

			SELECT {+avoid_full (bdicred:sd_ctascarg)} num_cta INTO sCtaCheques FROM bdicred:sd_ctascarg WHERE num_credito = cNum_Credito;
			IF sCtaCheques IS NULL THEN LET sCtaCheques = ''; END IF;
			IF sCtaCheques = '' THEN
				LET cCodRet = '000001';
				RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;
			END IF;		 
		
		ELSE 											-- Es decir: iContador > 1 ==> Cliente tiene mas de un credito Prestamo Flexible activo
			LET cCodRet = '000021';
			RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;				
		END IF;
		

	-- Obtiene informacion en base al numero de credito.
	ELIF pNum_Credito != '' THEN

		SELECT crd.num_credito, pf.fecha_cancela, crd.numcte INTO cNum_Credito, sFechaCancela, cNumCte
		 FROM bdicred:sd_maecredcrd crd
		 JOIN bdicred:sd_linea_prestamo pf ON (crd.num_credito = pf.num_credito and crd.num_producto = '6800')
		WHERE crd.num_credito = pNum_Credito;
		  --AND pf.fecha_cancela is null;
		  
		IF sFechaCancela IS NOT NULL THEN			-- Fecha de cancelacion no es nula, es decir, credito esta cancelado
			LET cCodRet = '000011';
			RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;		
		END IF;		  
		  
		IF cNum_Credito IS NULL THEN LET cNum_Credito = ''; END IF;
		IF cNum_Credito = '' THEN
			-- Obtiene num de cliente
			SELECT numcte INTO cNumCte FROM bdisolic:ss_solicitudes WHERE num_solicitud = pNum_Credito;
		
			-- Evalua si existe solicitud en status AT
			LET iContador = 0;
			SELECT count(num_solicitud) INTO iContador FROM bdisolic:ss_solicitudes WHERE numcte = cNumCte AND num_producto = '6800' AND status_solicitud = 'AT';
			IF iContador > 0 THEN  
				LET cCodRet = '000007';		-- Existe solicitud autorizada, sin credito 6800, es decir, credito no activo
				RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;						
			END IF
			LET iContador = 0;
			SELECT count(num_solicitud) INTO iContador FROM bdisolic:ss_solicitudes WHERE numcte = cNumCte AND num_producto = '6800' AND status_solicitud in ('RT','CN');
			IF iContador > 0 THEN  
				LET cCodRet = '000008';		-- Existe solicitud 6800 rechazada
				RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;						
			END IF		
		
			LET cCodRet = '000001';
			RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;			
		END IF;		 

		SELECT {+avoid_full (bdicred:sd_ctascarg)} num_cta INTO sCtaCheques FROM bdicred:sd_ctascarg WHERE num_credito = cNum_Credito;
		IF sCtaCheques IS NULL THEN LET sCtaCheques = ''; END IF;
		IF sCtaCheques = '' THEN
			LET cCodRet = '000001';
			RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;
		END IF;	
		
	ELSE
		LET cCodRet = '000021';
		RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;			
	END IF;
	
		
	-- Valida el credito identificado es de Prestamo Digital Vigente. Si fecha_cancela es nula, el credito sigue activo
	IF trim(cNum_Credito) != '' AND trim(sCtaCheques) != '' THEN
		SELECT count(num_credito) INTO iContador FROM bdicred:sd_linea_prestamo WHERE num_credito = cNum_Credito AND fecha_cancela is null;
		IF iContador = 0 THEN
			LET cCodRet = '000001';
			RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;		
		END IF;
	ELSE
		LET cCodRet = '000001';
		RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;	
	END IF;
	
	-- Obtiene parametro de saldo minimo a disponer
	SELECT valor INTO iMontoMin
	  FROM bdisolic:"informix".ss_param WHERE empresa = '001' AND secuencia= 391;	

	
	-- Realiza el servicio 1 correspondiente a CONSULTA DE SALDO para ATM
	IF pServicio = '1' THEN
	
		SELECT monto_linea, linea_disponible INTO dMonto_linea, dLin_disponible
		  FROM bdicred:sd_linea_prestamo WHERE num_credito = cNum_Credito;
	

	    -- Consulta los saldos general del credito 6800
        EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general('001', TRIM(cNum_Credito))
        INTO cCod_retBit, cMsjRet, cNumCredito1, cCodTCred, dFechaOrig, dFechaProxPag, dcPagoMin, dFechaUltPag, iPlazo, iPagRealizados, dcLinOtorgada, dcTasaInteres, 
			 dcTasaMoratorios, dcMontoSbs, dcCapVig, dcCapTrans, dcCapVdoExig, dcCapVdoNoExig, dcSdoActTotCap, dcIntVig, dcIntVdo, dcIntMoratorio, dcIntMes, 
			 dcSodActTotInt, dcIvaIntVig, dcIvaIntVdo, dcIvaIntMor, dcIvaIntMes, dcSdoActTotIva, dcComPend, dcIvaCom, dcSdoRetenido, dcTotalLiq, dcIntDevengado, 
			 dcIvaIntDevengado, dcLinDisp, dcPagosVdos, cDescStatusCred, iIdBloqueoCred, cBloqCta, cIdCausaBloqCred, cCausaBloqCta, cIdSitEspCte, iIdCausaEspCte, 
			 cSitEspCte, cIdSitEspCred, iIdCausaEspCred, cSitEspCred;

        IF cCod_retBit <> '000000' THEN -- Numero de credito no existe	
			LET cCodRet = '000001';
			RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;			
		END IF;
	
		LET cCodRet = '000000';		LET dSaldo1_Ret = dLin_disponible;	LET dSaldo2_Ret = dcTotalLiq;	LET dSaldo3_Ret = 0;	
		LET sFecha_Ret = dFechaHoy;	LET sTasaInt_Ret = 0;				LET sCta_Cheq_Ret = '';			LET sParam2_Ret = '';
	
		RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;	
	
	
	-- Proporciona servicio SIMULACION MONTO DEL PRESTAMO
	ELIF pServicio = '2' THEN
	
		SELECT valor::INTEGER INTO iPorCondicionSupuesto2	--dPorcSimula			
		  FROM bdicred:sd_param WHERE cod_param = '60';
		  
		SELECT valor::INTEGER INTO iPorSupuesto1			
		  FROM bdicred:sd_param WHERE cod_param = '124';
  
		SELECT valor::INTEGER INTO iPorSupuesto2		
		  FROM bdicred:sd_param WHERE cod_param = '125';

		  SELECT valor::INTEGER INTO iPorCondicionSupuesto3	
		  FROM bdicred:sd_param WHERE cod_param = '126';
		  
		IF iPorCondicionSupuesto2 IS NULL THEN LET iPorCondicionSupuesto2 = ''; END IF;
		IF iPorSupuesto1 IS NULL THEN LET iPorSupuesto1 = ''; END IF;
		IF iPorSupuesto2 IS NULL THEN LET iPorSupuesto2 = ''; END IF;
		IF iPorCondicionSupuesto3 IS NULL THEN LET iPorCondicionSupuesto3 = ''; END IF;
		
		IF iPorCondicionSupuesto2 = '' OR iPorSupuesto1 = '' OR iPorSupuesto2 = '' OR iPorCondicionSupuesto3 = '' THEN
			LET cCodRet = '000012';		LET dSaldo1_Ret = 0;	LET dSaldo2_Ret = 0;		LET dSaldo3_Ret = 0;	
			LET sFecha_Ret = dFechaHoy;	LET sTasaInt_Ret = 0;	LET sCta_Cheq_Ret = '';		LET sParam2_Ret = '';				
			RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;			
		END IF;
		
		SELECT monto_linea, linea_disponible INTO dMonto_linea, dLin_disponible
		  FROM bdicred:sd_linea_prestamo WHERE num_credito = cNum_Credito;	
	
		-- Localiza el porcentaje de linea utilizado por el cliente y obtiene el monto simulado 

		-- Supuesto 1.- Cliente con 0% de su linea de credito ocupada
		IF dMonto_linea = dLin_disponible THEN 			
		 
			-- Linea Credito * (50%) = Monto final sugerido a disponer
			LET dCalculoMntoSim = dMonto_linea * (iPorSupuesto1/100);

			LET cCodRet = '000000';		LET dSaldo1_Ret = dLin_disponible;	LET dSaldo2_Ret = dCalculoMntoSim;		LET dSaldo3_Ret = 0;	
			LET sFecha_Ret = dFechaHoy;	LET sTasaInt_Ret = 0;				LET sCta_Cheq_Ret = '';		LET sParam2_Ret = '';

		--	Supuesto 2.- Cliente con disposicion mayor a 0% y menor 50% de su linea
		ELIF (dMonto_linea - dLin_disponible) > 0 AND ((dMonto_linea - dLin_disponible) < (dMonto_linea * (iPorCondicionSupuesto2/100))) THEN
				
			-- (Linea Credito * 50%)  - Monto dispuesto = Monto final sugerido a disponer
			LET dCalculoMntoSim	= (dMonto_linea * (iPorSupuesto2/100)) - (dMonto_linea - dLin_disponible); 
			
			LET cCodRet = '000000';		LET dSaldo1_Ret = dLin_disponible;	LET dSaldo2_Ret = dCalculoMntoSim;		LET dSaldo3_Ret = 0;	
			LET sFecha_Ret = dFechaHoy;	LET sTasaInt_Ret = 0;				LET sCta_Cheq_Ret = '';		LET sParam2_Ret = '';				
			
		--	Supuesto 3.- Cliente con disposicion mayor al 50 % de su linea
		ELIF ((dMonto_linea - dLin_disponible) >= (dMonto_linea * (iPorCondicionSupuesto3/100))) AND dLin_disponible > 0 THEN
		
			-- Linea Credito - Monto dispuesto = Monto final sugerido a disponer
			LET dCalculoMntoSim	= dMonto_linea - (dMonto_linea - dLin_disponible); 				

			LET cCodRet = '000000';		LET dSaldo1_Ret = dLin_disponible;	LET dSaldo2_Ret = dCalculoMntoSim;		LET dSaldo3_Ret = 0;	
			LET sFecha_Ret = dFechaHoy;	LET sTasaInt_Ret = 0;				LET sCta_Cheq_Ret = '';		LET sParam2_Ret = '';					
		
		-- Supuesto 4.- Si el cliente no cuenta con saldo disponible, no podra realizar disposicion
		ELIF dLin_disponible <= 0 THEN
		
			--Tu Prestamo Digital tiene una linea de credito disponible de $xxxx. No es suficiente para realizar una nueva disposicion
			LET cCodRet = '000004';		LET dSaldo1_Ret = dLin_disponible;	LET dSaldo2_Ret = dCalculoMntoSim;		LET dSaldo3_Ret = 0;	
			LET sFecha_Ret = dFechaHoy;	LET sTasaInt_Ret = 0;				LET sCta_Cheq_Ret = '';		LET sParam2_Ret = '';			
		
		ELSE

			LET cCodRet = '000004';		LET dSaldo1_Ret = dLin_disponible;	LET dSaldo2_Ret = dCalculoMntoSim;		LET dSaldo3_Ret = 0;	
			LET sFecha_Ret = dFechaHoy;	LET sTasaInt_Ret = 0;				LET sCta_Cheq_Ret = '';		LET sParam2_Ret = '';		
		
		END IF;
		
		IF (dLin_disponible < iMontoMin) OR (dCalculoMntoSim < iMontoMin)  THEN		-- Si la linea disponible es menor al minimo a disponer O el monto calculado menor al minimo
			--Tu Prestamo Digital tiene una linea de credito disponible de $xxxx. No es suficiente para realizar una nueva disposicion
			LET cCodRet = '000004';		LET dSaldo1_Ret = dLin_disponible;	LET dSaldo2_Ret = dCalculoMntoSim;		LET dSaldo3_Ret = 0;	
			LET sFecha_Ret = dFechaHoy;	LET sTasaInt_Ret = 0;				LET sCta_Cheq_Ret = '';		LET sParam2_Ret = '';			
		END IF;
	
		RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;	
		

	-- Servicio SIMULACION DISPOSICION (PROYECCION)
	ELIF pServicio = '3' THEN
	
		-- Saldo a calcular erroneo.
		IF NVL(pSaldo, 0) <= 0 THEN
			LET cCodRet = '000018';		LET dSaldo1_Ret = 0;	LET dSaldo2_Ret = 0;		LET dSaldo3_Ret = 0;	
			LET sFecha_Ret = dFechaHoy;	LET sTasaInt_Ret = 0;	LET sCta_Cheq_Ret = '';		LET sParam2_Ret = '';	
			
			RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;	
		END IF
		
		-- Obtiene informacion del credito para proyeccion
		SELECT tasa_interes, plazo , periodo_plazo , num_producto, sucursal
		  INTO dTasa_Int   , iPlazo, cPeriodo_Plazo, cProducto   , cSucursal 
		  FROM bdicred:sd_maecredcrd WHERE num_credito = cNum_Credito;

		IF cPeriodo_Plazo = 'M' THEN
			LET iFrecuencia = 1;
		ELSE
			LET iFrecuencia = 2;
		END IF;		

		-- Proyecta monto a disponer
		LET iContador = 0;			LET dTotalPagar = 0;		LET dMensualidad = 0;
		FOREACH 
			EXECUTE PROCEDURE bdisolic:"informix".sp_proyecta_prestamos (pSaldo, iPlazo, 0, cProducto, cSucursal, 1, 0, cNum_Credito, "", iFrecuencia)
			INTO cCod_retBit, iNum_periodos, dtFecha_cuota, dSdo_inicial, dPago_mensual, dMto_Interes, dIva_interes, dCapital, dSdo_final,
			     sDias_periodo, dtFecha_Aper, cNumMesesPagos
			
			-- Valida que el proyecta prestamo, se ejecuto correctamente
			IF cCod_retBit::INTEGER <> 0  THEN				
				LET cCodRet = '000006';		LET dSaldo1_Ret = 0;	LET dSaldo2_Ret = 0;		LET dSaldo3_Ret = 0;	
				LET sFecha_Ret = dFechaHoy;	LET sTasaInt_Ret = 0;	LET sCta_Cheq_Ret = '';		LET sParam2_Ret = '';
			
				RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;					
			END IF;
			
			--Se guarda la suma de las mensualidades
			LET dTotalPagar = dTotalPagar + dPago_mensual;
			
			IF iContador = 0 THEN
				LET dMensualidad =  dPago_mensual;
			END IF;
			
			LET iContador = iContador + 1;
		END FOREACH;		

		LET cCodRet    = '000000';	LET dSaldo1_Ret  = dMensualidad;	LET dSaldo2_Ret   = pSaldo;		LET dSaldo3_Ret = dTotalPagar;	
		LET sFecha_Ret = dFechaHoy;	LET sTasaInt_Ret = dTasa_Int;		LET sCta_Cheq_Ret = '';			LET sParam2_Ret = '';
		
		RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;	


	-- Servicio DISPOSICION PRESTAMO DIGITAL
	ELIF pServicio = '4' THEN
	
		-- Saldo a calcular erroneo.
		IF NVL(pSaldo, 0) <= 0 THEN		-- Valida que se haya enviado el id del atm.
			LET cCodRet = '000018';		LET dSaldo1_Ret = 0;	LET dSaldo2_Ret = 0;		LET dSaldo3_Ret = 0;	
			LET sFecha_Ret = dFechaHoy;	LET sTasaInt_Ret = 0;	LET sCta_Cheq_Ret = '';		LET sParam2_Ret = '';	
			RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;
		END IF;
	
		/*-- Valida que el id del atm sea un dato valido
		IF NVL(pParametro1, '') = '' THEN
			LET cCodRet = '000019';		LET dSaldo1_Ret = 0;	LET dSaldo2_Ret = 0;		LET dSaldo3_Ret = 0;	
			LET sFecha_Ret = dFechaHoy;	LET sTasaInt_Ret = 0;	LET sCta_Cheq_Ret = '';		LET sParam2_Ret = '';			
			RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;	
		END IF;*/
	
		-- Obtiene el canal: ATM
		--SELECT {+avoid_full (bdicred:si_canal)}  cve_canal INTO dCanal FROM bdinteg:si_canal WHERE nombre_canal = 'ATM';
		SELECT {+avoid_full (bdicred:si_canal)}  cve_canal INTO dCanal FROM bdinteg:si_canal WHERE cve_canal = pParametro2::SMALLINT;
		IF dCanal IS NULL THEN LET dCanal = 0; END IF;
		IF NVL(dCanal, 0) = 0 THEN
			LET cCodRet = '000020';		LET dSaldo1_Ret = 0;	LET dSaldo2_Ret = 0;		LET dSaldo3_Ret = 0;	
			LET sFecha_Ret = dFechaHoy;	LET sTasaInt_Ret = 0;	LET sCta_Cheq_Ret = '';		LET sParam2_Ret = '';				
			RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;	
		END IF;
		
		-- Obtiene el numero de celular del cliente
		SELECT tel.telefono INTO cNumCel
          FROM bdicred:sd_maecredcrd crd
          JOIN bdinteg:si_telefonos tel ON (crd.numcte = tel.numcte AND tel.tipo_tel = 2 AND tel.status_tel = 'A')
         WHERE crd.num_credito = cNum_Credito;
		IF cNumCel IS NULL THEN LET cNumCel = ''; END IF;
		IF cNumCel = '' THEN
			LET cCodRet = '000010';		LET dSaldo1_Ret = 0;	LET dSaldo2_Ret = 0;		LET dSaldo3_Ret = 0;	
			LET sFecha_Ret = dFechaHoy;	LET sTasaInt_Ret = 0;	LET sCta_Cheq_Ret = '';		LET sParam2_Ret = '';						
			RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;
		END IF;
		
		SELECT monto_linea, linea_disponible INTO dMonto_linea, dLin_disponible
		  FROM bdicred:sd_linea_prestamo WHERE num_credito = cNum_Credito;
	
		
		-- Ejecuta disposicion.
		--EXECUTE PROCEDURE bdisolic:"informix".sp_prestamoflex_sms(2, cNumCel, pSaldo, dCanal_atm::CHAR, pParametro1, '', '')
		EXECUTE PROCEDURE bdisolic:"informix".sp_prestamoflex_sms(2, cNumCel, pSaldo, pParametro2, pParametro1, '', '')
		   INTO cCodRet, cMensajeErr;   
		LET cCodRet = lpad(trim(cCodRet), 6, '0');
		
		
		-- Obtiene informacion para determinados mensajes a enviar a ATM
		IF cCodRet::integer = 4 THEN
		
			-- Tu Prestamo Digital tiene una linea de credito disponible de $xxxx. No es suficiente para realizar una nueva disposicion
			LET cCodRet = '000004';		LET dSaldo1_Ret  = dLin_disponible;	LET dSaldo2_Ret = 0;		LET dSaldo3_Ret = 0;	
			LET sFecha_Ret = dFechaHoy;	LET sTasaInt_Ret = 0;				LET sCta_Cheq_Ret = '';		LET sParam2_Ret = '';									

		ELIF cCodRet::integer = 9 THEN			
			
			-- Si deseas solicitar un prestamo, el monto debe ser mayor a $1,000 y menor a $X,XXX.XX. Verifica tu monto.
			LET cCodRet = '000009';		LET dSaldo1_Ret  = dLin_disponible;	LET dSaldo2_Ret = 0;		LET dSaldo3_Ret = 0;	
			LET sFecha_Ret = dFechaHoy;	LET sTasaInt_Ret = 0;				LET sCta_Cheq_Ret = '';		LET sParam2_Ret = '';

		
		ELIF cCodRet::integer = 0 THEN			
		
			-- Tu prestamo fue depositado en tu cuenta! Â¿Deseas realizar otra transaccion? 
			-- Tus 12 pagos mensuales seran de XXX y se abonara a tu cuenta a partir de XX/XX/XX"
			SELECT first 1 capital_mto_cuota, fecha_cuota INTO dMensualidad, dFechaProxPag FROM bdicred:sd_amortiza_creditocrd WHERE num_credito = cNum_Credito;

		
			IF dCanal = 17 THEN		-- Regresa informacion especifica para el canal :17 = APP
			
				-- Obtiene informacion del credito para proyeccion
				SELECT tasa_interes, plazo INTO dTasa_Int, iPlazo
				  FROM bdicred:sd_maecredcrd WHERE num_credito = cNum_Credito;

				SELECT first 1 folio_suc INTO cNumeroFolio FROM bdicred:sd_movdiacrd WHERE num_credito = cNum_Credito AND codigo_ref = 1; 
			
				LET cCodRet = '000000';			LET dSaldo1_Ret  = dMensualidad;	LET dSaldo2_Ret = pSaldo;			LET dSaldo3_Ret = iPlazo;	
				LET sFecha_Ret = dFechaProxPag;	LET sTasaInt_Ret = dTasa_Int;		LET sCta_Cheq_Ret = sCtaCheques;	LET sParam2_Ret = cNumeroFolio;					
			
			ELSE
				LET cCodRet = '000000';			LET dSaldo1_Ret  = dMensualidad;	LET dSaldo2_Ret = pSaldo;			LET dSaldo3_Ret = 0;	
				LET sFecha_Ret = dFechaProxPag;	LET sTasaInt_Ret = 0;				LET sCta_Cheq_Ret = sCtaCheques;	LET sParam2_Ret = '';
			END IF;	
		ELSE
		
			LET cCodRet = cCodRet;		LET dSaldo1_Ret  = 0;	LET dSaldo2_Ret = 0;		LET dSaldo3_Ret = 0;	
			LET sFecha_Ret = dFechaHoy;	LET sTasaInt_Ret = 0;	LET sCta_Cheq_Ret = '';		LET sParam2_Ret = '';
	
		END IF;
			
		RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;
		
	

	-- Servicio PRESTAMO + DISPONIBLE - Equivale a la solicitud PRESTAMO + DSIPONIBLE via SMS
	ELIF pServicio = '5' THEN
	
		-- Valida si el credito tiene saldo vencido.
		SELECT status_cred, sucursal INTO cStatusCred, cSucursal FROM bdicred:sd_maecredcrd WHERE num_credito = cNum_Credito;
		SELECT iva INTO dcIvaCom FROM bdinteg:si_sucursales WHERE sucursal = cSucursal;

		-- IFSR ajuste para que se consideren las etapas
		--IF cStatusCred in ('BA','BT') THEN
		IF  cStatusCred in ('BA','BT') or (cStatusCred in ('E1','E2','E3') AND iAtr >= 1) THEN
		
			SELECT sum(interes_debe - interes_pagado + iva_debe - iva_pagado + 
				       round((mora_provi_ordi + mora_sdo_ordi - mora_sdo_ordi_pag + mora_provi_cope + mora_sdo_cope - mora_sdo_cope_pag) * (1 + dcIvaCom),2)) INTO dcPagosVdos
		      FROM bdicred:sd_amortiza_creditocrd 
			 WHERE num_credito = cNum_Credito and capital_status in ('2','7','6');
		    
			SELECT mto_venc_trasp + monto_vencido + dcPagosVdos  INTO dcTotalLiq FROM bdicred:sd_maesdoscrd a WHERE num_credito = cNum_Credito;
				
			--	Tu Prestamo Flexible tiene saldo vencido de $${importe1}. Te invitamos a pon...			
			LET cCodRet = '000003';			LET dSaldo1_Ret  = dcTotalLiq;		LET dSaldo2_Ret = 0;		LET dSaldo3_Ret = 0;			-- PPF_SMS_ADP		
			LET sFecha_Ret = dFechaHoy;		LET sTasaInt_Ret = 0;				LET sCta_Cheq_Ret = '';		LET sParam2_Ret = '';				
			RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;		

		END IF;	
		
		SELECT valor::SMALLINT INTO sNumPagosReprest FROM bdicred:"informix".sd_param WHERE cod_param = '057';
		SELECT status_cred INTO cStatusCred FROM bdicred:sd_maecredcrd WHERE num_credito = cNum_Credito;
				
		IF cStatusCred != 'FF' THEN
			-- Valida # de meses de pago puntual
			SELECT MAX(num_pago) INTO iNumpag_aux
			 FROM bdicred:sd_amortiza_creditocrd WHERE empresa = '001' AND num_credito = cNum_Credito AND capital_status <> '3'; 
			LET iNumpag_aux = NVL(iNumpag_aux,0);
			LET iNumpag_aux = iNumpag_aux - 3;
										 
			SELECT COUNT(*) INTO inumpagos
			 FROM bdicred:sd_amortiza_creditocrd a WHERE empresa = '001' AND num_credito = cNum_Credito
			  AND num_pago >= iNumpag_aux AND capital_status = '5' AND capital_status_ant = 1;		
		ELSE
			LET inumpagos = 0;
		END IF;

		SELECT sec_credito, monto_linea, linea_disponible INTO iNumDisp_pf, dMonto_linea, dLin_disponible
		  FROM bdicred:sd_linea_prestamo WHERE num_credito = cNum_Credito;

		-- Si No cuenta con los # meses de pago puntual continuo  / Tienes un prestamo vigente.  Por el momento no puedes disponer de un prestamo nuevo.
		IF (inumpagos < sNumPagosReprest) AND iNumDisp_pf > 0 AND cStatusCred <> 'FF' THEN 
		
			LET cCodRet = '000002';		LET dSaldo1_Ret  = 0;		LET dSaldo2_Ret = 0;		LET dSaldo3_Ret = 0;			-- PPF_SMS_D3
			LET sFecha_Ret = dFechaHoy;	LET sTasaInt_Ret = 0;		LET sCta_Cheq_Ret = '';		LET sParam2_Ret = '';
			
			RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;
			
		END IF;			
		
		
		--	Si la linea disponible del cliente es menor al minimo (1000) /  Por el momento, no cuentas con saldo suficiente para solicitar un nuevo prestamo.
		EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general('001', TRIM(cNum_Credito))
        INTO cCod_retBit, cMsjRet, cNumCredito1, cCodTCred, dFechaOrig, dFechaProxPag, dcPagoMin, dFechaUltPag, iPlazo, iPagRealizados, dcLinOtorgada, dcTasaInteres, 
			 dcTasaMoratorios, dcMontoSbs, dcCapVig, dcCapTrans, dcCapVdoExig, dcCapVdoNoExig, dcSdoActTotCap, dcIntVig, dcIntVdo, dcIntMoratorio, dcIntMes, 
			 dcSodActTotInt, dcIvaIntVig, dcIvaIntVdo, dcIvaIntMor, dcIvaIntMes, dcSdoActTotIva, dcComPend, dcIvaCom, dcSdoRetenido, dcTotalLiq, dcIntDevengado, 
			 dcIvaIntDevengado, dcLinDisp, dcPagosVdos, cDescStatusCred, iIdBloqueoCred, cBloqCta, cIdCausaBloqCred, cCausaBloqCta, cIdSitEspCte, iIdCausaEspCte, 
			 cSitEspCte, cIdSitEspCred, iIdCausaEspCred, cSitEspCred;
			 
		IF NVL(iNumDisp_pf,0) = 0 THEN		-- Si el credito no ha tenido disposiciones previas
			LET dLin_disponible = dLin_disponible;
		ELSE								-- Si el credito tiene al menos una disposicion.
			LET dLin_disponible = (dMonto_linea - dcTotalLiq);		
		END IF;
		
		IF (dLin_disponible < imontomin) THEN
		
			LET cCodRet = '000004';		LET dSaldo1_Ret  = dLin_disponible;		LET dSaldo2_Ret = 0;		LET dSaldo3_Ret = 0;		-- PPF_SMS_LSD
			LET sFecha_Ret = dFechaHoy;	LET sTasaInt_Ret = 0;					LET sCta_Cheq_Ret = '';		LET sParam2_Ret = '';

			RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;
		
		END IF;				
		
		-- Si cuenta con sus 3 pagos continuos y su linea disponible es mayor o igual que el minimo (1000)	
		-- Tu linea de credito disponible actual es de $XXX.  Liquida tu Prestamo Flexible solo por hoy $XXX)
		-- Si deseas un nuevo Prestamo envia un SMS al 98000 con la palabra "FLEXIBLE" (espacio) monto que deseas sin signo de pesos.
		IF (inumpagos >= sNumPagosReprest) AND (dLin_disponible >= imontomin)THEN 
		
			LET cCodRet = '000022';		LET dSaldo1_Ret  = dLin_disponible;		LET dSaldo2_Ret = dcTotalLiq;	LET dSaldo3_Ret = 0;	-- PPF_SMS_LS / PPF_SMS_NNP
			LET sFecha_Ret = dFechaHoy;	LET sTasaInt_Ret = 0;					LET sCta_Cheq_Ret = '';			LET sParam2_Ret = '';

			RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;

		END IF;	
		
		-- Si la linea disponible = linea Otorgada / Tienes un Prestamo Flexible autorizado por $XXX, Envia un SMS al 98000 con la palabra FLEXIBLE (espacio)...	
		IF dMonto_linea = dLin_disponible THEN
		
			LET cCodRet = '000024';		LET dSaldo1_Ret  = dMonto_linea;		LET dSaldo2_Ret = 0;		LET dSaldo3_Ret = 0;		-- PPF_SMS_L1
			LET sFecha_Ret = dFechaHoy;	LET sTasaInt_Ret = 0;					LET sCta_Cheq_Ret = '';		LET sParam2_Ret = '';

			RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;
		
		END IF;
		
	
	-- Servicio FLEXIBLE + CONSULTA  - Equivale a la solicitud FLEXIBLE + CONSULTA via SMS
	ELIF pServicio = '6' THEN
	
		SELECT {+avoid_full (bdicred:si_canal)}  cve_canal INTO dCanal FROM bdinteg:si_canal WHERE cve_canal = pParametro2::SMALLINT;
		IF dCanal IS NULL THEN LET dCanal = 0; END IF;
		IF NVL(dCanal, 0) = 0 THEN
			LET cCodRet = '000020';		LET dSaldo1_Ret = 0;	LET dSaldo2_Ret = 0;		LET dSaldo3_Ret = 0;	
			LET sFecha_Ret = dFechaHoy;	LET sTasaInt_Ret = 0;	LET sCta_Cheq_Ret = '';		LET sParam2_Ret = '';				
			RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;	
		END IF;

		SELECT status_cred, sucursal INTO cStatusCred, cSucursal FROM bdicred:sd_maecredcrd WHERE num_credito = cNum_Credito;
		SELECT iva INTO dcIvaCom FROM bdinteg:si_sucursales WHERE sucursal = cSucursal;

		-- IFSR validacion para que considere las etapas
		--IF cStatusCred in ('BA','BT') THEN
		IF cStatusCred in ('BA','BT') or (cStatusCred in ('E1','E2','E3') AND iAtr >= 1) THEN
		
			SELECT sum(interes_debe - interes_pagado + iva_debe - iva_pagado + 
				       round((mora_provi_ordi + mora_sdo_ordi - mora_sdo_ordi_pag + mora_provi_cope + mora_sdo_cope - mora_sdo_cope_pag) * (1 + dcIvaCom),2)) INTO dcPagosVdos
		      FROM bdicred:sd_amortiza_creditocrd 
			 WHERE num_credito = cNum_Credito and capital_status in ('2','7','6');
		    
			SELECT mto_venc_trasp + monto_vencido + dcPagosVdos  INTO dcTotalLiq FROM bdicred:sd_maesdoscrd a WHERE num_credito = cNum_Credito;
				
			--	Tu Prestamo Flexible tiene saldo vencido de $${importe1}. Te invitamos a pon			
			LET cCodRet = '000003';			LET dSaldo1_Ret  = dcTotalLiq;		LET dSaldo2_Ret = 0;		LET dSaldo3_Ret = 0;			-- PPF_SMS_ADP		
			LET sFecha_Ret = dFechaHoy;		LET sTasaInt_Ret = 0;				LET sCta_Cheq_Ret = '';		LET sParam2_Ret = '';				
			RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;		

		END IF;

		
		SELECT limit 1 fecha_cuota, capital_mto_cuota INTO dFechaProxPag, dMensualidad
		  FROM bdicred:sd_amortiza_creditocrd WHERE num_credito = cNum_Credito AND capital_status = '3';

		LET cCodRet = '000000';			LET dSaldo1_Ret  = dMensualidad;	LET dSaldo2_Ret = 0;			LET dSaldo3_Ret = 0;	
		LET sFecha_Ret = dFechaProxPag;	LET sTasaInt_Ret = 0;				LET sCta_Cheq_Ret = '';			LET sParam2_Ret = '';
		
		RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;
	

	
	ELSE
		LET cCodRet = '000017';		LET dSaldo1_Ret = 0;	LET dSaldo2_Ret = 0;		LET dSaldo3_Ret = 0;	
		LET sFecha_Ret = dFechaHoy;	LET sTasaInt_Ret = 0;	LET sCta_Cheq_Ret = '';		LET sParam2_Ret = '';
	
		RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;		
	END IF;

	
	RETURN cCodRet, dSaldo1_Ret, dSaldo2_Ret, dSaldo3_Ret, sFecha_Ret, sTasaInt_Ret, sCta_Cheq_Ret, sParam2_Ret;	
	
	
END
END PROCEDURE
DOCUMENT
'Procedimiento para atender servicios para Prestamo Digital (Flexible) desde diferentes canales (inicialmente ATM)						',
'Servicio 1.- Consulta de Saldo ATM 																			   					  	',
'			Datos de Retorno: cCodRet, Linea_disponible, Sdo_Total_liquidacion, 0, date(1), 0, "", ""								  	',
'Servicio 2.- Monto Calculado para mostrar monto default para retiro en ATM															  	',			
'			Datos de Retorno: cCodRet, Linea_disponible, Monto_calculado, 0, date(1), 0, "", ""										  	',
'Servicio 3.- Proyeccion de monto de disposicion (Simulacion disposicion)															  	',
'			Datos de Retorno: cCodRet, Mensualidad, Monto_a_disponer, Total_a_pagar, Fecha_hoy/Fecha_proyeccion, Tasa_Interes, "", "" 	',
'Servicio 4.- Disposiccion Prestamo Digital/Flexible																				  	',
'			Datos de Retorno: cCodRet, Linea_disponible, 0, 0, date(1), 0, "", ""													  	',
'Servicio 5.- Servicio equivalente a la solicitud PRESTAMO + DSIPONIBLE via SMS												',
'																																		',
'Servicio 6.- Consulta de saldos. Equivale a la solicitud FLEXIBLE + CONSULTA via SMS													',
'			Datos de Retorno: cCodRet, Mensualidad, 0, 0, Fecha prox pago, 0, "", ""													',
'Fecha: Mayo 2020';

CREATE PROCEDURE "informix".sp_importa_catcentrosimp()
--EXECUTE PROCEDURE sp_importa_catcentrosimp();
RETURNING CHAR(6), CHAR(80);

-- Declaracion de variables
DEFINE sql_err 			        INTEGER;
DEFINE isam_err 		        INTEGER;
DEFINE error_info		        CHAR(80);
DEFINE cCod_ret                 CHAR(6);
DEFINE cMensaje                 CHAR(80);

DEFINE v_sql                  	CHAR(500);
DEFINE vRuta                    CHAR(60);
DEFINE vFecha					CHAR(06);
DEFINE cNombreArch				CHAR(50);
DEFINE totalCI					INTEGER;

LET sql_err   = 0;
LET cCod_ret  = '00000';
LET cMensaje  = 'Proceso Exitoso';
LET v_sql     = '';
LET vRuta     = ''; -- '/resplogifx/archivoscartera/'
LET vFecha	  = '';
LET cNombreArch = 'centros_impresion_coppel';
LET totalCI		= 0;

--SET DEBUG FILE TO '/informix/ulises/edc/Cat_CI/sp_importarcataloci.out';
--TRACE ON;

BEGIN
  
        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
			RETURN cCod_ret, cMensaje;
	    END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- Recupera la fecha con la que se va a generar el archivo
		SELECT LPAD(MONTH(fecha_hoy),2,0)||YEAR(fecha_hoy)
		INTO vFecha
		FROM bdicred:sd_fechas
		WHERE empresa = '001';
		
		--LET vFecha = '09'||'2021'; --para pruebas
		
		-- Obtiene la ruta donde se realiza la descarga del archivo.
		SELECT TRIM(valor) INTO vRuta FROM sd_param WHERE empresa = '001' AND cod_param = '033';
		
		--LET vRuta = '/informix/ulises/RQI/25_183/OLTP/'; -- PARA PRUEBAS
		
		IF trim(vRuta) = "" THEN
			LET cCod_ret= '00001';
			LET cMensaje= 'No existe la ruta /resplogifx/archivoscartera/';
			RETURN cCod_ret, cMensaje;
		END IF;
		
		-- Realiza validacion de que la tabla exista
		IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'sd_centrosimpresion_coppel'  AND dbsname = 'bdicred') THEN
                    truncate table bdicred:"informix".sd_centrosimpresion_coppel; -- borra la informacion de la tabla.
		else
				LET cCod_ret= '00002';
				LET cMensaje= 'No existe la tabla sd_centrosimpresion_coppel ';
				RETURN cCod_ret, cMensaje;
		END IF;	
		
/*		SELECT COUNT(*) INTO totalCI FROM "informix".sd_centrosimpresion_coppel;
			
		IF  totalCI > 0 THEN
			truncate table bdicred:"informix".sd_centrosimpresion_coppel;
		END IF;
*/			
		-- Realiza la insercion de los datos del archivo a la tabla bdicred:sd_centrosimpresion_coppel
		LET v_sql = '';	
		LET v_sql ='gunzip '||trim(vRuta) ||'centros_impr_coppel'|| trim(vFecha)||'.txt.gz';
		system v_sql;	
		
		LET v_sql = '';	
		LET v_sql ="sed 's/.$//g' "||trim(vRuta) ||'centros_impr_coppel' ||trim(vFecha)|| '.txt > ' ||trim(vRuta) ||TRIM(cNombreArch)||trim(vFecha)||'.unl';
		system v_sql;
		
		LET v_sql = '';		
		LET v_sql = ' echo "FILE '|| trim(vRuta) ||TRIM(cNombreArch)||trim(vFecha)||'.unl DELIMITER '''||'|'||''' 3; INSERT INTO "informix".sd_centrosimpresion_coppel; " > '|| trim(vRuta) ||'queryCargaCentroImpr.sql';
		system v_sql;							

		LET v_sql = '';	
		LET v_sql = 'dbload -d bdicred -c '|| trim(vRuta) ||'queryCargaCentroImpr.sql -l '|| trim(vRuta) ||'sd_centrosimpresion_coppel.log -n 1000 -k';
		system v_sql;
		
		LET v_sql = '';
		LET v_sql = 'gzip ' ||trim(vRuta) ||'centros_impr_coppel'|| trim(vFecha)||'.txt';
		system v_sql;
		
		LET v_sql = '';
		LET v_sql = 'rm ' || TRIM(vRuta) || 'sd_centrosimpresion_coppel.log';
		system v_sql;
		
		LET v_sql = '';
		LET v_sql = 'rm ' || TRIM(vRuta) || 'queryCargaCentroImpr.sql';
		system v_sql;
		
		LET v_sql = '';
		LET v_sql = 'rm ' || TRIM(vRuta) || TRIM(cNombreArch)||trim(vFecha)||'.unl';
		system v_sql;
		
RETURN cCod_ret, cMensaje;

END;
END PROCEDURE;
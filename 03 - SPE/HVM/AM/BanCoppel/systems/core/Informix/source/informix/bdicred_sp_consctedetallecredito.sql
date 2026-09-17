CREATE PROCEDURE "informix".sp_consctedetallecredito(pEmpresa CHAR(3), pNumCte CHAR(20), pNumCredito CHAR(20), pNumTarjeta CHAR(20)) 
RETURNING CHAR(6) 	    AS CodRet,
		  CHAR(150)     AS NomCteTitular,
		  DATE 		    AS FechaNAC,
		  CHAR(13) 	    AS RFC,
		  CHAR(20) 	    AS NumCte,
		  CHAR(20) 	    AS NumCredito, 
		  CHAR(20) 	    AS NumTarjeta,
		  CHAR(40) 	    AS NombreProducto,
		  DATE 		    AS FechaApertura,
		  CHAR(4)       AS CodigoEstatus, --Se agrega variable para retornar codigo de status
		  CHAR(60) 	    AS Estatus, 
		  DATE 		    AS FechaUltMovimiento,
		  DECIMAL(18,2) AS SaldoActual,
		  DECIMAL(18,2) AS SaldoRetenido; --Se agrega variable para retornar saldo retenido
		  
-- DEFINICION DE VARIABLES DEL PROCEDIMIENTO SP_CONSCTEDETALLECREDITO.
DEFINE cCodRet				CHAR(6);
DEFINE dFechaNAC			DATE;
DEFINE cRfc					CHAR(13);
DEFINE iSqlErr              INTEGER;
DEFINE iIsamErr             INTEGER;
DEFINE cErrorInfo           CHAR(80);
DEFINE cStatusCred          CHAR(4);

-- DEFINICION DE VARIABLES DE RETORNO DEL PROCEDIMIENTO. SP_CONSULTA_SALDOS_GENERAL
DEFINE cCodRetCSG			CHAR(6);
DEFINE cMsjRetCSG			CHAR(80);
DEFINE cNumCreditoCSG		CHAR(20);
DEFINE cCodTCredCSG			CHAR(2);
DEFINE dFechaOrigCSG		DATE;
DEFINE dFechaProxPagCSG 	DATE;
DEFINE dcPagoMinCSG			DECIMAL(18,2);
DEFINE dFechaUltPagCSG		DATE;
DEFINE iPlazoCSG			INTEGER;
DEFINE iPagRealizadosCSG	INTEGER;
DEFINE dcLinOtorgadaCSG		DECIMAL(18,2);
DEFINE dcTasaInteresCSG		DECIMAL(9,6);
DEFINE dcTasaMoratoriosCSG 	DECIMAL(9,6);
DEFINE dcMontoSbsCSG		DECIMAL(14,2);
DEFINE dcCapVigCSG			DECIMAL(18,2);
DEFINE dcCapTransCSG		DECIMAL(18,2);
DEFINE dcCapVdoExigCSG		DECIMAL(18,2);
DEFINE dcCapVdoNoExigCSG	DECIMAL(18,2);
DEFINE dcSdoActTotCapCSG	DECIMAL(18,2);
DEFINE dcIntVigCSG			DECIMAL(18,2);
DEFINE dcIntVdoCSG			DECIMAL(18,2);
DEFINE dcIntMoratorioCSG	DECIMAL(18,2);
DEFINE dcIntMesCSG			DECIMAL(18,2);
DEFINE dcSodActTotIntCSG	DECIMAL(18,2);
DEFINE dcIvaIntVigCSG		DECIMAL(18,2);
DEFINE dcIvaIntVdoCSG		DECIMAL(18,2);
DEFINE dcIvaIntMorCSG		DECIMAL(18,2);
DEFINE dcIvaIntMesCSG		DECIMAL(18,2);
DEFINE dcSdoActTotIvaCSG	DECIMAL(18,2);
DEFINE dcComPendCSG			DECIMAL(18,2);
DEFINE dcIvaComCSG			DECIMAL(18,2);
DEFINE dcSdoRetenidoCSG		DECIMAL(18,2);
DEFINE dcTotalLiqCSG		DECIMAL(18,2);
DEFINE dcIntDevengadoCSG	DECIMAL(18,2);
DEFINE dcIvaIntDevengadoCSG	DECIMAL(18,2);
DEFINE dcLinDispCSG			DECIMAL(18,2);
DEFINE dcPagosVdosCSG		DECIMAL(18,2);
DEFINE cDescStatusCredCSG	CHAR(60);
DEFINE iIdBloqueoCredCSG	INTEGER;
DEFINE cBloqCtaCSG			CHAR(60);
DEFINE cIdCausaBloqCredCSG	CHAR(3);
DEFINE cCausaBloqCtaCSG		CHAR(50);
DEFINE cIdSitEspCteCSG		CHAR(1);
DEFINE iIdCausaEspCteCSG	INTEGER;
DEFINE cSitEspCteCSG		CHAR(75);
DEFINE cIdSitEspCredCSG		CHAR(1);
DEFINE iIdCausaEspCredCSG	INTEGER;
DEFINE cSitEspCredCSG 		CHAR(75);

-- DECLARACION DE VARIABLES DE RETORNO DEL PROCEDIMIENTO SP_CONSULTACREDITOSCANCELAR
DEFINE cCodRetCCC			CHAR(6);
DEFINE cMsjRetCCC			CHAR(80);
DEFINE cNumCreditoCCC 		CHAR(20);
DEFINE cNumCteCCC 			CHAR(20);
DEFINE cNombreProductoCCC	CHAR(40);
DEFINE cNumTarjetaCCC 		CHAR(20);
DEFINE cNombreClienteCCC 	CHAR(150);

-- VARIABLES DE RETORNO DEL SP_DESC_RET
DEFINE vCodRet 	 		 	VARCHAR(5);
DEFINE vMsjRetorno 		 	VARCHAR(100);

-- INICIALIZACION DE VARIABLES DEL PROCEDIMIENTO SP_CONSCTEDETALLECREDITO.
LET cCodRet					= '00000';
LET dFechaNAC				= DATE(1);
LET cRfc					= '';
LET iSqlErr              	= 0;
LET iIsamErr             	= 0;
LET cErrorInfo           	= '';
LET cStatusCred             = '';

-- INICIALIZACION DE VARIABLES DE RETORNO DEL PROCEDIMIENTO. SP_CONSULTA_SALDOS_GENERAL
LET cCodRetCSG				= '000000';
LET cMsjRetCSG				= '';
LET cNumCreditoCSG			= '';
LET cCodTCredCSG			= '';
LET dFechaOrigCSG			= DATE(1);
LET dFechaProxPagCSG 		= DATE(1);
LET dcPagoMinCSG			= 0.00;
LET dFechaUltPagCSG			= DATE(1);
LET iPlazoCSG				= 0;
LET iPagRealizadosCSG		= 0;
LET dcLinOtorgadaCSG		= 0.00;
LET dcTasaInteresCSG		= 0.00;
LET dcTasaMoratoriosCSG 	= 0.00;
LET dcMontoSbsCSG			= 0.00;
LET dcCapVigCSG				= 0.00;
LET dcCapTransCSG			= 0.00;
LET dcCapVdoExigCSG			= 0.00;
LET dcCapVdoNoExigCSG		= 0.00;
LET dcSdoActTotCapCSG		= 0.00;
LET dcIntVigCSG				= 0.00;
LET dcIntVdoCSG				= 0.00;
LET dcIntMoratorioCSG		= 0.00;
LET dcIntMesCSG				= 0.00;
LET dcSodActTotIntCSG		= 0.00;
LET dcIvaIntVigCSG			= 0.00;
LET dcIvaIntVdoCSG			= 0.00;
LET dcIvaIntMorCSG			= 0.00;
LET dcIvaIntMesCSG			= 0.00;
LET dcSdoActTotIvaCSG		= 0.00;
LET dcComPendCSG			= 0.00;
LET dcIvaComCSG				= 0.00;
LET dcSdoRetenidoCSG		= 0.00;
LET dcTotalLiqCSG			= 0.00;
LET dcIntDevengadoCSG		= 0.00;
LET dcIvaIntDevengadoCSG	= 0.00;
LET dcLinDispCSG			= 0.00;
LET dcPagosVdosCSG			= 0.00;
LET cDescStatusCredCSG		= '';
LET iIdBloqueoCredCSG		= 0;
LET cBloqCtaCSG				= '';
LET cIdCausaBloqCredCSG		= '';
LET cCausaBloqCtaCSG		= '';
LET cIdSitEspCteCSG			= '';
LET iIdCausaEspCteCSG		= 0;
LET cSitEspCteCSG			= '';
LET cIdSitEspCredCSG		= '';
LET iIdCausaEspCredCSG		= 0;
LET cSitEspCredCSG 			= '';

-- INICIALIZACION DE VARIABLES DE RETORNO DEL PROCEDIMIENTO. SP_CONSULTACREDITOSCANCELAR
LET cCodRetCCC				= '000000';
LET cMsjRetCCC				= '';
LET cNumCreditoCCC 			= '';
LET cNumCteCCC 				= '';
LET cNombreProductoCCC		= '';
LET cNumTarjetaCCC 			= '';
LET cNombreClienteCCC 		= '';

-- INICIALIZACION DE VARIABLES DEL PROCEDIMIENTO SP_DESC_RET
LET vCodRet 	 			= '00000';
LET vMsjRetorno  			= '';

-- SET DEBUG FILE TO '/home/sysifx/vlv/sp_consctedetallecredito.out';
-- TRACE ON;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				LET cNombreClienteCCC = cErrorInfo;
				RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
					   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
					   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- VALIDAMOS LOS PARAMETROS DE ENTRADA.
		IF NVL(pEmpresa,'') = '' OR NVL(pNumCte,'') = '' AND NVL(pNumCredito,'') = '' AND NVL(pNumTarjeta,'') = '' THEN
			EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','590')
			INTO vCodRet, vMsjRetorno;
			
			LET cCodRet = '00001';
			LET cNombreClienteCCC = vMsjRetorno::CHAR(150);
			RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
				   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
				   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
		END IF
		
		IF NVL(pEmpresa,'') <> '' AND NVL(pNumCte,'') <> '' AND NVL(pNumCredito,'') <> '' AND NVL(pNumTarjeta,'') <> '' THEN
			EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','591')
			INTO vCodRet, vMsjRetorno;
			
			LET cCodRet = '00001';
			LET cNombreClienteCCC = vMsjRetorno::CHAR(150);
			RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
				   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
				   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
		END IF
		
		-- CONSULTAMOS SI EXISTE EL VALOR QUE SE DESEA CONSULTAR.
		IF TRIM(NVL(pNumCte,'')) <> '' THEN
			-- VALIDAMOS SI EXISTE EL CLIENTE
			IF NOT EXISTS( SELECT rfc FROM bdinteg:"informix".si_cliente WHERE numcte = TRIM(pNumCte) ) THEN 
				EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','592')
				INTO vCodRet, vMsjRetorno;
				
				LET cCodRet = '00002';
				LET cNombreClienteCCC = vMsjRetorno::CHAR(150);
				RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
					   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
					   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
			END IF
			
		ELIF TRIM(NVL(pNumCredito,'')) <> '' THEN
			-- VALIDAMOS SI EXISTE EL CREDITO.
			IF NOT EXISTS (SELECT num_credito, b.cod_prod FROM bdicred:"informix".sd_maecred a, bdicred:"informix".sd_tipprod b 
						   WHERE a.num_credito = TRIM(pNumCredito) AND a.empresa = TRIM(pEmpresa) AND a.empresa = b.empresa  AND a.num_producto = b.abrevia_prod ) THEN 
				EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','593')
				INTO vCodRet, vMsjRetorno;
				
				LET cCodRet = '00003';
				LET cNombreClienteCCC = vMsjRetorno::CHAR(150);
				RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
					   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
					   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
			END IF
		ELIF TRIM(NVL(pNumTarjeta,'')) <> '' THEN
			-- VALIDAMOS SI EXISTE LA TARJETA.
			IF NOT EXISTS (SELECT num_credito FROM bdicred:"informix".sd_tarjeta WHERE empresa = TRIM(pEmpresa) AND num_tarjeta = TRIM(pNumTarjeta) ) THEN 
				EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','594')
				INTO vCodRet, vMsjRetorno;
				
				LET cCodRet = '00004';
				LET cNombreClienteCCC = vMsjRetorno::CHAR(150);
				RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
					   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
					   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
			END IF
		END IF
		
		-- CONSULTAMOS LOS DATOS GENERALES DEL CLIENTE.
		FOREACH 
			EXECUTE PROCEDURE bdicred:"informix".sp_consultaCreditosCancelar(TRIM(pEmpresa), TRIM(pNumCte), TRIM(pNumCredito), TRIM(pNumTarjeta))
			INTO cCodRetCCC, cMsjRetCCC, cNumCreditoCCC, cNumCteCCC, cNombreProductoCCC, cNumTarjetaCCC, cNombreClienteCCC , cStatusCred
			
			IF cCodRetCCC = '000001' THEN 
				EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','590') -- DEBE ENVIAR AL MENOS UN PARAMETRO OBLIGATORIO
				INTO vCodRet, vMsjRetorno;
				
				LET cCodRet  = '00005';
				LET cNombreClienteCCC = vMsjRetorno::CHAR(150);
				RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
					   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
					   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
			ELIF cCodRetCCC = '000005' THEN 
				LET cCodRet  = '00011'; -- CLIENTE NO TIENE CREDITOS POR CANCELAR.
			ELIF cCodRetCCC = '000007' THEN 
				LET cCodRet  = '00013'; -- CREDITO NO PUEDE SER CANCELADO.
			ELIF cCodRetCCC = '000008' THEN 
				LET cCodRet  = '00014'; -- TARJETA NO PUEDE SER CANCELADA.
			ELIF cCodRetCCC = '000006' THEN 
				LET cCodRet  = '00012'; -- NO SE PUEDE CANCELAR CREDITO CON TARJETA ADICIONAL.
				
				RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
					   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
					   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
			ELIF cCodRetCCC::INTEGER < 0 THEN -- ERROR NO CONTROLADO EN EL BDICRED:"informix".SP_CONSULTACREDITOSCANCELAR
				EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','596')
				INTO vCodRet, vMsjRetorno;
				
				LET cCodRet  = '00007';
				LET cNombreClienteCCC = vMsjRetorno::CHAR(150);
				RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
					   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
					   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
			END IF
			
			 
				-- CONSULTAMOS EL SALDO GENERAL DEL CREDITO.
				EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(TRIM(pEmpresa), TRIM(cNumCreditoCCC))
				INTO cCodRetCSG, cMsjRetCSG, cNumCreditoCSG, cCodTCredCSG, dFechaOrigCSG, dFechaProxPagCSG, dcPagoMinCSG, dFechaUltPagCSG, iPlazoCSG, iPagRealizadosCSG, dcLinOtorgadaCSG, dcTasaInteresCSG, dcTasaMoratoriosCSG, dcMontoSbsCSG, 
					 dcCapVigCSG, dcCapTransCSG, dcCapVdoExigCSG, dcCapVdoNoExigCSG, dcSdoActTotCapCSG, dcIntVigCSG, dcIntVdoCSG, dcIntMoratorioCSG, dcIntMesCSG, dcSodActTotIntCSG, dcIvaIntVigCSG, dcIvaIntVdoCSG, dcIvaIntMorCSG, dcIvaIntMesCSG,
					 dcSdoActTotIvaCSG, dcComPendCSG, dcIvaComCSG, dcSdoRetenidoCSG, dcTotalLiqCSG, dcIntDevengadoCSG, dcIvaIntDevengadoCSG, dcLinDispCSG, dcPagosVdosCSG, cDescStatusCredCSG, iIdBloqueoCredCSG, cBloqCtaCSG, cIdCausaBloqCredCSG, 
					 cCausaBloqCtaCSG, cIdSitEspCteCSG, iIdCausaEspCteCSG, cSitEspCteCSG, cIdSitEspCredCSG, iIdCausaEspCredCSG, cSitEspCredCSG;
				
				IF cCodRetCSG = '000005' THEN -- OCURRIÓ UN ERROR AL REALIZAR CALCULO
					EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','597')
					INTO vCodRet, vMsjRetorno;
					
					LET cCodRet  = '00008';
					LET cNombreClienteCCC = vMsjRetorno::CHAR(150);
					RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
						   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
						   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
				ELIF cCodRetCSG = '000006' THEN -- NO SE ENCONTRÓ EL FACTOR DE LA COMISIÓN
					EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','598')
					INTO vCodRet, vMsjRetorno;
					
					LET cCodRet  = '00009';
					LET cNombreClienteCCC = vMsjRetorno::CHAR(150);
					RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
						   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
						   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
				ELIF cCodRetCSG::INTEGER < 0 THEN -- ERROR NO CONTROLADO EN EL BDICRED:"informix".SP_CONSULTA_SALDOS_GENERAL
					EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('06','599')
					INTO vCodRet, vMsjRetorno;
					
					LET cCodRet  = '00010';
					LET cNombreClienteCCC = vMsjRetorno::CHAR(150);
					RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
						   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
						   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00);
				END IF
				
				-- VALIDAMOS SI EXISTE EL CLIENTE Y CONSULTAMOS EL RFC DEL CLIENTE.
				SELECT rfc INTO cRfc FROM bdinteg:"informix".si_cliente WHERE numcte = TRIM(cNumCteCCC);
				
				-- CONSULTAMOS LA FECHA DE NACIMIENTO DEL CLIENTE.
				SELECT Fecha_NAC INTO dFechaNAC FROM bdinteg:"informix".si_ctepf WHERE numcte = TRIM(cNumCteCCC);
				
				RETURN TRIM(cCodRet), TRIM(NVL(cNombreClienteCCC,'')), NVL(dFechaNAC,DATE(1)), TRIM(NVL(cRfc,'')), TRIM(NVL(cNumCteCCC,'')), TRIM(NVL(cNumCreditoCCC,'')), 
					   TRIM(NVL(cNumTarjetaCCC,'')), TRIM(NVL(cNombreProductoCCC,'')), NVL(dFechaOrigCSG,DATE(1)), TRIM(NVL(cStatusCred,'')), TRIM(NVL(cDescStatusCredCSG,'')), 
					   NVL(dFechaUltPagCSG,DATE(1)), NVL(dcSdoActTotCapCSG,0.00),NVL(dcSdoRetenidoCSG,0.00) WITH RESUME;
				
		END FOREACH
		
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para consultar el detalle del credito',
'AUTOR: Valentin Lopez',
'FECHA DE CREACION: 12 de Octubre del 2012',
'VERSION: 20121012.1504',
'BD: bdicred',
'MODIFICÓ: Carlos Ochoa Valenzuela',
'DESCRIPCIÓN: Se declara e incluye una variable para Saldo Retenido y para obtener el codigo de descripcion e incluirlo dentro de los return.', 
'FECHA DE MODIFICACIÓN: 10 de Diciembre del 2012',
'VERSION: 20121210.1814',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_conspoliticacreditoprod (pEmpresa char(3),pNumProducto char(4), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING 	CHAR(5) AS CodRet,
				CHAR(4) AS Num_Producto,
				CHAR(1) AS Respuesta_Sic,
				CHAR(50) AS modelo,
				CHAR(1) AS Grupo,
				INT AS ScoreMin_grupo1,
				INT AS ScoreMax_grupo1,
				INT AS ProScoreMin_grupo1,
				INT AS ProScoreMax_grupo1,
				CHAR(2) AS Status_Sol;

	-- Declaracion de variables
	DEFINE iSqlErr          			INTEGER;
	DEFINE cCodRet           			CHAR(5);
	DEFINE cNumProducto					CHAR(4);
	DEFINE cRespuestaSic				CHAR(1);
	DEFINE cGrupo			          	CHAR(1);
	DEFINE cModelo			          	CHAR(50);
	DEFINE cStatusSol			     	CHAR(2);
	DEFINE iBcScoreMin1			    	INT;
	DEFINE iBcScoreMax1			    	INT;
	DEFINE iProScoreMin1		    	INT;
	DEFINE iProScoreMax1		    	INT;

	-- Asignacion variables
	LET iSqlErr             		= 0;
	LET cCodRet              		= '00000';
	LET cNumProducto				= '';
	LET cRespuestaSic				= '';
	LET cGrupo						= '';
	LET cModelo						= '';
	LET cStatusSol					= '';
	LET iBcScoreMin1				= 0;
	LET iBcScoreMax1				= 0;
	LET iProScoreMin1				= 0;
	LET iProScoreMax1				= 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumProducto,cRespuestaSic,cModelo,cGrupo,
					   iBcScoreMin1, iBcScoreMax1,iProScoreMin1,iProScoreMax1,cStatusSol;
		END EXCEPTION;

		--SET DEBUG FILE TO "/informix/JoseLuisG/Pruebas_Politicas_de_Credito/sp_conspoliticacreditoprod.out";
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF NVL(pEmpresa,'') = '' OR NVL(pNumProducto,'') = ''  THEN
			LET cCodRet = '00001';
			RETURN cCodRet, cNumProducto,cRespuestaSic,cModelo,cGrupo,
					   iBcScoreMin1, iBcScoreMax1,iProScoreMin1,iProScoreMax1,cStatusSol;
		ELSE
			--Obtiene las politicas de credito del producto seleccionado.
			FOREACH
				SELECT SKIP pRegistros FIRST pRecuperacion tot.num_producto,tot.respuesta_sic, CASE WHEN tot.respuesta_sic = '0' THEN 'HIT con InformaciÃ³n' ELSE (CASE WHEN tot.respuesta_sic = 'X' THEN 'NO HIT' ELSE 'HIT sin informaciÃ³n'END) END AS Modelo, tot.grupo,
				  tot.bc_scoremin as BcScoreMin, tot.bc_scoremax as BcScoreMax, tot.pro_scormin as ProScoreMin, tot.pro_scormax as ProScoreMax,
				   tot.status_sol
				INTO cNumProducto,cRespuestaSic,cModelo,cGrupo, iBcScoreMin1, iBcScoreMax1, iProScoreMin1, iProScoreMax1,cStatusSol
				FROM bdisolic:'informix'.ss_scoring_modelo2 tot
				WHERE tot.num_producto = pNumProducto AND tot.grupo IN (SELECT DISTINCT grupo FROM bdisolic:'informix'.ss_scoring_modelo2) order by grupo,respuesta_sic

				RETURN cCodRet,cNumProducto,cRespuestaSic,cModelo,cGrupo, iBcScoreMin1, iBcScoreMax1, iProScoreMin1, iProScoreMax1,cStatusSol WITH RESUME;

			END FOREACH;

		END IF;

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00001';
			RETURN cCodRet, cNumProducto,cRespuestaSic,cModelo,cGrupo,
					   iBcScoreMin1, iBcScoreMax1,iProScoreMin1,iProScoreMax1,cStatusSol;
		END IF;

	END;
END PROCEDURE
DOCUMENT
'Se crea el procedimiento almacenado "sp_conspoliticacreditoprod" para obtener la informaciÃÂÃÂ³n puntajes de Bcscore y Score propietario mÃÂÃÂ­nimo y mÃÂÃÂ¡ximo definidos para ser Autorizada o Rechazada que actualmente tiene registrada el producto',
'Base de datos: BDICRED';

CREATE PROCEDURE "informix".sp_consulta_conv_productos(pProducto CHAR(4), pTipoEjecucion CHAR(1))
	RETURNING 	CHAR(5) AS CodRet,
				CHAR(2) AS Sistema,
				CHAR(4) AS Num_producto,
				CHAR(40) AS Nombre_producto;

	-- Declaracion de variables
	DEFINE iSqlErr          			INTEGER;
	DEFINE isam_err         			INTEGER;
	DEFINE error_info       			VARCHAR(60);
	DEFINE cCodRet           			CHAR(5);
	DEFINE cNum_producto				CHAR(4);
	DEFINE cNombre_producto				CHAR(40);
	DEFINE cSistema     		    	CHAR(2);

	-- Asignacion variables
	LET iSqlErr             		= 0;
	LET isam_err            		= 0;
	LET error_info          		= "";
	LET cCodRet              		= '00000';
	LET cNum_producto				= '';
	LET cNombre_producto			= '';
	LET cSistema					= '';


	BEGIN
		ON EXCEPTION SET iSqlErr, isam_err, error_info
			LET cCodRet = iSqlErr;
			RETURN cCodRet,'','','';
		END EXCEPTION;

		--SET DEBUG FILE TO "/tmp/anj/sp_consulta_conv_productos.out";
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;

		IF pTipoEjecucion = '1' THEN
			--Consulta para obtener los productos crÃÂÃÂ©dito y debito disponibles
			FOREACH
				SELECT '06', num_producto,nombre_prod
					INTO cSistema, cNum_producto,cNombre_producto
					FROM bdicred:sd_definicion WHERE num_producto NOT IN ('7200','7300','7400','7500')
					AND num_producto NOT IN (SELECT {+INDEX(bdisolic:ss_tramite_productos_clasif idx_ss_tramite_productos_clasif)} prod_ofrecer FROM bdisolic:ss_tramite_productos_clasif
					   WHERE clasificacion IN (select clasificacion from bdisolic:ss_tramite_productos WHERE prod_actual = pProducto)
					AND sistema = '06')
					UNION ALL
					SELECT {+INDEX(bdicheq:sc_producto idx_producto1)} '01', producto,nombre FROM bdicheq:sc_producto WHERE producto NOT IN ('1200','9900','1600','9901','2200','2300','2500','2600','2700','2800','5000','8000','9999')
					AND producto NOT IN (SELECT {+INDEX(bdisolic:ss_tramite_productos_clasif idx_ss_tramite_productos_clasif)} prod_ofrecer FROM bdisolic:ss_tramite_productos_clasif
					   WHERE clasificacion IN (select clasificacion from bdisolic:ss_tramite_productos WHERE prod_actual = pProducto)
					AND sistema = '01')
										
					IF 	cNum_producto = pProducto THEN
						CONTINUE FOREACH;
					END IF;

				RETURN cCodRet, cSistema, cNum_producto,cNombre_producto WITH RESUME;
			END FOREACH;
		ELIF pTipoEjecucion = '2' THEN
			--Consulta para obtener los productos crÃÂÃÂ©dito y debito ya asignados
			FOREACH
				SELECT b.sistema, a.num_producto, a.nombre_prod
				INTO cSistema, cNum_producto, cNombre_producto
				FROM bdicred:sd_definicion a
				INNER JOIN bdisolic:ss_tramite_productos_clasif b ON (a.num_producto = b.prod_ofrecer)
				INNER JOIN bdisolic:ss_tramite_productos c ON (b.clasificacion = c.clasificacion AND c.prod_actual = pProducto)
				WHERE a.num_producto NOT IN ('7200','7300','7400','7500')
				UNION ALL
				SELECT DISTINCT b.sistema, a.producto, a.nombre
				FROM bdicheq:sc_producto a
				INNER JOIN bdisolic:ss_tramite_productos_clasif b ON (a.producto = b.prod_ofrecer)
				INNER JOIN bdisolic:ss_tramite_productos c ON (b.clasificacion = c.clasificacion AND c.prod_actual = pProducto)
				WHERE a.producto NOT IN ('1200','9900','1600','9901','2200','2300','2500','2600','2700','2800','5000','8000','9999')
				ORDER BY b.sistema

				RETURN cCodRet,cSistema, cNum_producto,cNombre_producto WITH RESUME;
			END FOREACH;
		END IF;

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00001';
			RETURN cCodRet,'','','';
		END IF;

	END;
END PROCEDURE
DOCUMENT
'Se crea el procedimiento almacenado "sp_consulta_conv_productos" que tendrÃÂÃÂ¡ como funciÃÂÃÂ³n principal asignar la convivencia con otros productos',
'Base de datos: BDICRED';

CREATE PROCEDURE "informix".sp_consulta_frecpago(pValor CHAR(2), pTipo_pago VARCHAR(20),pNum_producto CHAR(4),pTipoEjecucion CHAR(1))

RETURNING CHAR(5) AS CodRet,
          CHAR(2) AS Valor,
		  VARCHAR(20) AS TipoPago;
    
DEFINE cCodRet CHAR(5);
DEFINE cValor  CHAR(2);
DEFINE cTipoPago VARCHAR(15);
DEFINE vNum_producto CHAR(4);
DEFINE iSqlErr  INTEGER;

LET cCodRet = '00000';
LET cValor = '';
LET cTipoPago = '';
LET vNum_producto = '';
LET iSqlErr = 0;
    
	BEGIN
		-- // MANEJO DE EXCEPCIONES   
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cValor,cTipoPago;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/ifxsif01/home/e_efierro/sp_consulta_frecpago.out";
		--TRACE ON;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pTipoEjecucion = '1' THEN--Consulta Catalogo
			FOREACH
				SELECT valor,tipo_pago
				INTO cValor,cTipoPago
				FROM "informix".sd_cattipopago
			
				RETURN cCodRet, cValor,cTipoPago WITH RESUME;
			END FOREACH;
		
		ELIF pTipoEjecucion = '2' THEN --Guarda los valores seleccionados por el usuario de las frecuencias de pago 
			IF (pValor = '' AND pTipo_pago = '' AND pNum_producto = '') THEN
				LET cCodRet = '00001';
				ELSE
					SELECT COUNT (num_producto) 
					INTO vNum_producto
					FROM tmp_sd_frectipopago;
				
					IF vNum_producto >= 1 THEN
					
						IF vNum_producto <> pNum_producto THEN
							SELECT LIMIT 1 num_producto
							INTO pNum_producto
							FROM tmp_sd_frectipopago;
							--Se eliminan los registros que se crearon para obtener subproducto
							DELETE FROM tmp_sd_frectipopago
							WHERE num_producto = pNum_producto AND valor = 0;
						END IF;
					END IF;
				
					INSERT INTO "informix".tmp_sd_frectipopago(valor, tipo_pago, num_producto)
					VALUES(pValor, pTipo_pago, pNum_producto);
			END IF;
			RETURN cCodRet, TRIM(cValor), TRIM(cTipoPago);
		ELIF pTipoEjecucion = '3' THEN --Elima Opciones seleccionadas 
			DELETE FROM tmp_sd_frectipopago
			WHERE num_producto = pNum_producto AND valor = pValor;
					
			RETURN cCodRet, cValor,cTipoPago;
			
		ELIF pTipoEjecucion = '4' THEN --Consulta los valores asignados por usuario previamente registrados
			SELECT COUNT (num_producto) 
			INTO vNum_producto
			FROM tmp_sd_frectipopago;
			
			IF vNum_producto >= 1 THEN
				SELECT LIMIT 1 num_producto
				INTO pNum_producto
				FROM tmp_sd_frectipopago;
			END IF;
			
			FOREACH
				SELECT valor,tipo_pago
				INTO cValor,cTipoPago
				FROM "informix".sd_frectipopago
				WHERE num_producto = pNum_producto
				ORDER BY valor
			
				RETURN cCodRet, cValor,cTipoPago WITH RESUME;
			END FOREACH;
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet= '00002';  --No hay informacion
			RETURN cCodRet, TRIM(cValor), TRIM(cTipoPago);
			END IF;
		END IF;
	END
END PROCEDURE;
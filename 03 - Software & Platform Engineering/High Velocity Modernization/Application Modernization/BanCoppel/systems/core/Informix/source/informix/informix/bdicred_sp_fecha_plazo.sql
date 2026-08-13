CREATE PROCEDURE  "informix".sp_fecha_plazo(wempresa char(03), wdia smallint)

RETURNING CHAR(5) AS Codigo_de_Retorno,
		  DATE    AS Fecha_mesiver,
          DATE    AS Fecha_factura

--definicion de variables
	DEFINE sql_err 			INTEGER;
	DEFINE cCodret 			CHAR(6);
    define wfechahoy, wfechaultmes, wfechacorte date;
--Asignacion de variables
    LET sql_err 			= 0;
	LET cCodret				= "00000";
    let wfechahoy           = date(1);
    let wfechaultmes        = date(1);
    let wfechacorte         = date(1);


	BEGIN
			--Manejo de excepciones (errores)
			ON EXCEPTION SET sql_err
				IF sql_err <> 0 THEN
					let cCodret = sql_err;
					RETURN cCodret, date(1), date(1);
				END IF;
			END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;


			/*SET DEBUG FILE TO "/tmp/sp_ObtenProductoCredito.out";
			TRACE ON;*/
			--Este Procedimiento se utiliza en CARATARJ.exe para Obtener los productos de crédito que se podrá imprimir la reimpresion

            select fecha_hoy, ult_dia_mes
              into wfechahoy, wfechaultmes
              from bdicred:sd_fechas
             where empresa = wempresa;

            if ( day(wfechaultmes) < wdia ) then
                let wfechacorte = monthadd(wfechaultmes,-1);
            else
                if ( day(wfechahoy) < wdia ) then
                    let wfechacorte = monthadd(mdy(month(wfechahoy),wdia,year(wfechahoy)),-1);
                else
                    let wfechacorte = mdy(month(wfechahoy),wdia,year(wfechahoy));
                end if;
            end if;

            while day(wfechacorte) < wdia and  day(wfechacorte + 1 units day) <> 1
                let wfechacorte = wfechacorte + 1 units day;
            end while;

            return cCodret, wfechacorte, date(wfechacorte - 1 units day);

	END;
END PROCEDURE
DOCUMENT
'AUTOR      : ',
'BD         : BDICRED';

CREATE PROCEDURE "informix".sp_correcto_clonado_upgrade(pEmpresa CHAR(3))
RETURNING CHAR(6)    AS codigo_retorno,
          CHAR(150)  AS mensaje_retorno,
		  INTEGER AS exitoso,
		  INTEGER AS noexitoso;

--DEFINICION DE VARIABLES DE LOS CODIGOS DE ERROR Y EL RETORNO PRINCIPAL
DEFINE iSqlErr       		INTEGER;
DEFINE iIsamErr      		INTEGER;
DEFINE cErrorInfo    		CHAR(80);
DEFINE cCodRet       		CHAR(6);
DEFINE cMensajeRet   		CHAR(150);
DEFINE cExitoso 	 		INTEGER;
DEFINE cNoexitoso    		INTEGER;

-- DEFINICIÓN DE VARIABLES DE PARAMETROS DE ENTRADA Y RETORNOS DEL PROCEDIMIENTO. sp_correcto_clonado_upgrade
DEFINE vCodRet 		 		CHAR(6);
DEFINE vMsjRetorno   		CHAR(150);
DEFINE P_ERROR 				CHAR(5);
DEFINE P_MENSAJE			CHAR(100);
DEFINE cEmpresa      		CHAR(3);
DEFINE cNumCredito    	 	CHAR(20);
DEFINE cNumcte        	 	CHAR(20); 
DEFINE cNumProdUpgrade 		CHAR(4);
DEFINE cNumCredUpgrade		CHAR(20);
DEFINE cNumTarjUpgrade		CHAR(20);
DEFINE cCreditos			CHAR(600);
DEFINE cCreditosErr			CHAR(600);
DEFINE CstatusSol			CHAR(2);
DEFINE dFecha_Apert  		DATE;
DEFINE cDivisa            	CHAR(2);
DEFINE csucursal   			CHAR(4);
DEFINE cEjecutivo			CHAR(10);
DEFINE vFolio	            CHAR(16);
DEFINE Scodproducto			CHAR(3);
DEFINE cNumTarjeta			CHAR(20);
DEFINE cfechavenc			CHAR(4);
DEFINE cNomCte				CHAR(120);
DEFINE vmonto_aut 			MONEY(14,2);
DEFINE cFolio_canc  		CHAR(10);
DEFINE cidbinproducto		INTEGER;
DEFINE dfechavenc			DATE;
DEFINE cstatustarj			CHAR(3);
DEFINE cFechaNac			DATE;
DEFINE cclave_tipotarjeta	CHAR(2);
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

--INCIALIZACIÓN DE VARIABLES DE LOS CODIGOS DE ERROR Y EL RETORNO PRINCIPAL
LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = "";
LET cCodRet       = '000000';
LET cMensajeRet   = 'Se realizo la consulta correctamente.';
LET cExitoso 			= 0;
LET cNoexitoso 			= 0;

-- INICIALIZACION DE VARIABLES DE PARAMETROS DE ENTRADA Y RETORNOS DEL PROCEDIMIENTO. sp_correcto_clonado_upgrade
LET vCodRet       		= '000000';
LET vMsjRetorno	  		= "";
LET P_ERROR 			= "";
LET P_MENSAJE			= "";
LET cEmpresa      		= "";
LET cNumCredito   	 	= "";
LET cNumcte       	 	= "";
LET cNumProdUpgrade  	= "";
LET cNumCredUpgrade		= "";
LET cNumTarjUpgrade     = "";
LET cCreditos			= "";
LET cCreditosErr		= "";
LET CstatusSol			= "";
LET dFecha_Apert       = date(1);
LET cDivisa 			= "";
LET csucursal   		= "";
LET cEjecutivo			= "informix";
LET vFolio              = "";
LET Scodproducto		= "";
LET cNumTarjeta			= "";
LET cfechavenc			= "";
LET cNomCte				= "";
LET vmonto_aut			= 0.0;
LET cFolio_canc			= "";
LET cidbinproducto		= 0;
LET dfechavenc			=date(1);
LET cstatustarj			= "";
LET cFechaNac			= "";
LET cclave_tipotarjeta  = "";
-- INICIALIZACION DE VARIABLES DE RETORNO DEL PROCEDIMIENTO. SP_CONSULTA_SALDOS_GENERAL
LET cCodRetCSG				= '000000';
LET cMsjRetCSG				= "";
LET cNumCreditoCSG			= "";
LET cCodTCredCSG			= "";
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
LET cDescStatusCredCSG		= "";
LET iIdBloqueoCredCSG		= 0;
LET cBloqCtaCSG				= "";
LET cIdCausaBloqCredCSG		= "";
LET cCausaBloqCtaCSG		= "";
LET cIdSitEspCteCSG			= "";
LET iIdCausaEspCteCSG		= 0;
LET cSitEspCteCSG			= "";
LET cIdSitEspCredCSG		= "";
LET iIdCausaEspCredCSG		= 0;
LET cSitEspCredCSG 			= "";

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN cCodRet, cMensajeRet, cExitoso, cNoexitoso;
    END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/tmp/sp_correcto_clonado_upgrade.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT empresa
INTO cEmpresa
FROM bdinteg:si_empresas
WHERE empresa= pEmpresa;

IF TRIM(NVL(cEmpresa,'')) = '' THEN
  LET cCodRet = '000001';
  LET cMensajeRet = 'El parámetro no es valido';
  RETURN cCodRet, cMensajeRet, cExitoso, cNoexitoso;
END IF;

--EJECUCIÓN DE QUERY 
	FOREACH					
		SELECT numcte,num_credito,status_cred
		INTO cNumcte,cNumCredito,CstatusSol
		FROM bdicred:sd_maecred 
		WHERE empresa ='001' 
        AND status_cred IN('AA','FF')
		AND num_producto IN ('6001')
		AND numcte IN (SELECT numcte FROM bdicred:sd_maecred 
                WHERE empresa ='001' 
                AND status_cred='AA'
                AND num_producto IN ('6001','8100','7000')
                AND numcte IN (select numcte FROM bdicred:sd_credito_upgrade WHERE resultado IN(0,1,2))
                GROUP BY numcte
                HAVING COUNT(num_credito) >= 2)		

		IF ((SELECT COUNT(num_credito) FROM bdicred:"informix".sd_maecred WHERE numcte = cNumcte AND num_producto IN ('8100','7000') AND status_cred='AA') > 1) THEN				
							
			SELECT num_credito, num_producto, status_cred, sucursal 
			INTO cNumCredUpgrade, cNumProdUpgrade,CstatusSol, csucursal
			FROM bdicred:"informix".sd_maecred
			WHERE numcte = cNumcte
			AND num_producto IN ('8100','7000')
			AND status_cred='AA'
			AND rowid IN (SELECT MAX(rowid) FROM bdicred:sd_maecred 
							WHERE numcte = cNumcte 
							AND num_producto IN ('8100','7000')
							AND status_cred='AA');
	
			DELETE FROM bdicred:sd_maecred WHERE empresa = pEmpresa AND num_credito <> cNumCredUpgrade AND numcte = cNumcte AND num_producto = cNumProdUpgrade;
			DELETE FROM bdicred:sd_maesdos WHERE empresa = pEmpresa AND num_credito IN (SELECT num_credito FROM bdicred:sd_maecred WHERE num_credito <> cNumCredUpgrade AND numcte = cNumcte AND num_producto = cNumProdUpgrade);
			DELETE FROM bdicred:sd_maecredanexo WHERE empresa = pEmpresa AND num_credito IN (SELECT num_credito FROM bdicred:sd_maecred WHERE num_credito <> cNumCredUpgrade AND numcte = cNumcte AND num_producto = cNumProdUpgrade);
			DELETE FROM bdicred:sd_amortiza_credito WHERE empresa = pEmpresa AND num_credito IN (SELECT num_credito FROM bdicred:sd_maecred WHERE num_credito <> cNumCredUpgrade AND numcte = cNumcte AND num_producto = cNumProdUpgrade);
			DELETE FROM bdicred:sd_sdodiario WHERE fecha >= mdy(03,1,2018) AND num_credito IN (SELECT num_credito FROM bdicred:sd_maecred WHERE num_credito <> cNumCredUpgrade AND numcte = cNumcte AND num_producto = cNumProdUpgrade);
		ELSE 
			SELECT num_credito, num_producto, sucursal
			INTO cNumCredUpgrade, cNumProdUpgrade,csucursal
			FROM bdicred:"informix".sd_maecred
			WHERE numcte = cNumcte
			AND num_producto IN ('8100','7000');
		END IF;
		
		-- CONSULTAMOS EL SALDO GENERAL DEL CREDITO.
		EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(TRIM(pEmpresa), TRIM(cNumCredito))
		INTO cCodRetCSG, cMsjRetCSG, cNumCreditoCSG, cCodTCredCSG, dFechaOrigCSG, dFechaProxPagCSG, dcPagoMinCSG, dFechaUltPagCSG, iPlazoCSG, iPagRealizadosCSG, dcLinOtorgadaCSG, dcTasaInteresCSG, dcTasaMoratoriosCSG, dcMontoSbsCSG,
			 dcCapVigCSG, dcCapTransCSG, dcCapVdoExigCSG, dcCapVdoNoExigCSG, dcSdoActTotCapCSG, dcIntVigCSG, dcIntVdoCSG, dcIntMoratorioCSG, dcIntMesCSG, dcSodActTotIntCSG, dcIvaIntVigCSG, dcIvaIntVdoCSG, dcIvaIntMorCSG, dcIvaIntMesCSG,
			 dcSdoActTotIvaCSG, dcComPendCSG, dcIvaComCSG, dcSdoRetenidoCSG, dcTotalLiqCSG, dcIntDevengadoCSG, dcIvaIntDevengadoCSG, dcLinDispCSG, dcPagosVdosCSG, cDescStatusCredCSG, iIdBloqueoCredCSG, cBloqCtaCSG, cIdCausaBloqCredCSG,
			 cCausaBloqCtaCSG, cIdSitEspCteCSG, iIdCausaEspCteCSG, cSitEspCteCSG, cIdSitEspCredCSG, iIdCausaEspCredCSG, cSitEspCredCSG;

		IF cCodRetCSG::integer <> 0 THEN 	
		--ERROR AL CONSULTAR EL SALDO DEL CREDITO
				LET cCodRet='000002';
				-- Actualización de credito en bitacora de upgrade cuando pase un error
				UPDATE bdicred:"informix".sd_credito_upgrade  SET Resultado='2'
				WHERE numcte = cNumcte AND num_credito = cNumCredito;				
				LET cCreditos = cNumCredito || ", " || cCreditos;
				LET cCreditosErr = cCodRet || ", " || cCreditosErr;
				LET cNoexitoso = cNoexitoso + 1;		
			CONTINUE FOREACH;			
		ELIF CstatusSol IN ('AA') AND NVL(dcSdoRetenidoCSG,0) >0 AND cNumCreditoCSG <> '' THEN
			LET cCodRet='000003';
			LET cMensajeRet ='La cuenta presenta saldo retenido, por favor verifique';
			-- Actualización de credito en bitacora de upgrade cuando pase un error
			UPDATE bdicred:"informix".sd_credito_upgrade  SET Resultado='2'
			WHERE numcte = cNumcte AND num_credito = cNumCredito;

				LET cCreditos = cNumCredito || ", " || cCreditos;
				LET cCreditosErr = cCodRet || ", " || cCreditosErr;
				LET cNoexitoso = cNoexitoso + 1;			
			CONTINUE FOREACH;
		ELIF CstatusSol NOT IN ('AA','FF') THEN
			LET cCodRet='000004';
			LET cMensajeRet ='La cuenta se encuentra con atraso, o no esta vigente';
			-- Actualización de credito en bitacora de upgrade cuando pase un error
			UPDATE bdicred:"informix".sd_credito_upgrade  SET Resultado='2'
			WHERE numcte = cNumcte AND num_credito = cNumCredito;
			
				LET cCreditos = cNumCredito || ", " || cCreditos;
				LET cCreditosErr = cCodRet || ", " || cCreditosErr;
				LET cNoexitoso = cNoexitoso + 1;			
			CONTINUE FOREACH;			
		ELSE
			SELECT divisa
			INTO cDivisa 
			FROM "informix".sd_definicion
			WHERE num_producto ='6001';
			
			-- SE GENERA EL FOLIO
			CALL bdicheq:"informix".sp_generafolionomina(cEjecutivo) RETURNING cCodRet, vFolio;
			IF CstatusSol = 'AA' THEN
				-----------------------------------------
				--- PROCESO DE LIQUIDACION DE CREDITO CLASICA---
				-----------------------------------------
				CALL bdicred:"informix".sp_liquida_cred_upgrade (pEmpresa,cNumCredito,vFolio, dcTotalLiqCSG) RETURNING vCodRet;
			END IF;
			IF vCodRet::integer <> 0 THEN
				--AAME Se anexa reverso de operación
				EXECUTE PROCEDURE reversion(pEmpresa,csucursal,cEjecutivo,
				vFolio, "A")
				INTO  P_ERROR;			
				-- Actualización de credito en bitacora de upgrade cuando pase un error
				UPDATE bdicred:"informix".sd_credito_upgrade  SET Resultado='2'
				WHERE numcte = cNumcte AND num_credito = cNumCredito;

				LET cCodRet = '000005';
				LET cMensajeRet='Error en proceso de liquida credito upgrade';
				LET cCreditos = cNumCredito || ", " || cCreditos;
				LET cCreditosErr = cCodRet || ", " || cCreditosErr;
				LET cNoexitoso = cNoexitoso + 1;				
				--RETURN cCodRet, cMensajeRet;
				CONTINUE FOREACH;
			ELSE
				-- Actualización de credito de oro para relacionarlo con el Credito de clasica
				UPDATE "informix".sd_maecred SET credito_externo = cNumCredito WHERE num_credito = cNumCredUpgrade;
				IF NOT EXISTS (SELECT num_tarjeta FROM "informix".sd_tarjeta WHERE num_credito = cNumCredUpgrade) THEN 
					SELECT num_tarjeta,nombre
					INTO cNumTarjeta,cNomCte
					FROM "informix".sd_tarjeta 
					WHERE num_credito = cNumCredito 
					AND status_tar ='A'
					AND tipo_tarjeta ='T';		
					
					IF SUBSTR(cNumTarjeta,1,6) = '426807' OR NVL(cNumTarjeta,'') = '' THEN
						SELECT numtarjeta, fechaexp, codstatustarjeta
						INTO cNumTarjUpgrade, cfechavenc,cstatustarj
						FROM intercard:"informix".tarjeta 
						WHERE numcliente = cNumcte 
						AND substr(numtarjeta,1,6) IN('510148','554948');
						
						LET dfechavenc = substr(cfechavenc,3,2) || "/01/20" || substr(cfechavenc,1,2);
						IF cstatustarj = 'INA' THEN
						   SELECT fecha_nac
						   INTO cFechaNac
						   FROM bdinteg:"informix".si_ctepf
						   WHERE numcte = cNumcte;
							
							UPDATE  intercard:"informix".tarjeta 
							SET fechanacimiento= cFechaNac,CodStatusAsignada='SIA', fechaasignacion=current, CodStatusTarjeta='ACT', UsuarioUltModif=USER, FechaUltModif=current
							WHERE numtarjeta= cNumTarjUpgrade; 
							
							UPDATE intercard:"informix".tarjeta SET codstatustarjeta='CAN' WHERE numtarjeta=cNumTarjeta;

							INSERT INTO intercard:"informix".tarjetacuenta(NumCuenta, NumTarjeta)
							VALUES(cNumCredUpgrade, cNumTarjUpgrade);
							
							IF cNumProdUpgrade = '7000' THEN LET cclave_tipotarjeta = '9';
							ELIF cNumProdUpgrade = '8100' THEN LET cclave_tipotarjeta = '10';
							END IF;
							
							UPDATE intercard:"informix".sucursal_tipotarjeta SET existencia= existencia + -1 WHERE LPAD(clave_sucursal,6,'0') = LPAD(csucursal,6,'0') AND LPAD(clave_tipotarjeta,6,'0') = LPAD(cclave_tipotarjeta,6,'0');

							INSERT INTO intercard:"informix".estadisticatarjetasuc (consumo, fecha, clave_sucursal, clave_tipotarjeta) VALUES (1, current,csucursal, cclave_tipotarjeta);

							INSERT INTO intercard:"informix".bitasignacionactivaciontarjeta (numfolio, numcliente, numcuenta, numtarjeta, descripcion, usuario, canal, sucursal, fecharegistro) 
							SELECT MAX(numfolio)+1,cNumcte,cNumCredUpgrade,cNumTarjUpgrade,'REPOSICIÓN/RENOVACIÓN DE TARJETA DE CRÉDITO',USER,'OFI',csucursal,CURRENT FROM intercard:"informix".bitasignacionactivaciontarjeta;

							UPDATE intercard:"informix".paraminventarios SET folioasignacionactivacion=folioasignacionactivacion+1;
							
						END IF;
					ELSE 
						LET cNumTarjUpgrade = cNumTarjeta;
					END IF;
					
					IF NOT EXISTS (SELECT num_credito FROM bdicred:"informix".sd_tarjeta WHERE num_tarjeta =cNumTarjUpgrade) THEN	
						EXECUTE PROCEDURE bdicred:"informix".CancelaTarjeta(pEmpresa, cNumCredito, cNumTarjeta, cNumcte)INTO vCodRet,vmonto_aut,cFolio_canc;					
						Execute Procedure bdicred:"informix".altatarrepos_n(pEmpresa,cNumCredUpgrade,cNumTarjUpgrade,cNumcte,dfechavenc,'T','A',dcLinOtorgadaCSG,cNumProdUpgrade,cNomCte,6,'06',cNumTarjeta,'R','N',' ') INTO vCodRet;						
					END IF;

					-- Actualizacion de tarjeta de clasica por la cuenta de credito Oro
					UPDATE bdicred:"informix".sd_tarjeta  SET num_credito = cNumCredUpgrade, prodtarjeta=cNumProdUpgrade, secuencia=1 WHERE num_tarjeta = cNumTarjUpgrade;
					UPDATE intercard:"informix".tarjetacuenta SET numcuenta = cNumCredUpgrade WHERE numtarjeta = cNumTarjUpgrade;
					
					IF cNumProdUpgrade ='7000' THEN LET cidbinproducto =15;
					ELIF cNumProdUpgrade ='8100' THEN LET cidbinproducto =16;
					END IF;
					-- Actualiza producto de la tarjeta nueva en intercard INI
					select codproductotarjeta
					  into Scodproducto
					  from intercard:"informix".binproducto  
					  where idbinproducto = cidbinproducto;
								
					if (NVL(Scodproducto,'') <> '') then
						UPDATE intercard:"informix".tarjeta SET codproductotarjeta = Scodproducto WHERE numtarjeta = cNumTarjUpgrade;
					end if;
				END IF;	
				
				LET cExitoso = cExitoso + 1;
				-- Actualización de credito en bitacora de upgrade
				UPDATE bdicred:"informix".sd_credito_upgrade  SET numero_credito_upgrade = cNumCredUpgrade, numerotarjeta_upgrade= cNumTarjUpgrade, Resultado='1'
				WHERE numcte = cNumcte AND num_credito = cNumCredito;

			END IF;
			/*
			IF NOT EXISTS (SELECT num_credito FROM bdicred:"informix".sd_movhis WHERE num_credito = cNumCredUpgrade AND codigo_fun ='001' AND codigo_ref ='1') THEN 
			-- Genera el movimiento por la apertura de la línea de credito Oro
				EXECUTE PROCEDURE GENMOV( pEmpresa         , cNumCredUpgrade,
										  cNumProdUpgrade        , 1,
											"001"             , dFecha_Apert,
											dcLinOtorgadaCSG           , vFolio,
											csucursal       ,cDivisa,
											"0000")
				INTO P_ERROR, P_MENSAJE;
				
				IF P_ERROR::integer <> 0 THEN
					--AAME Se anexa reverso de operación
					EXECUTE PROCEDURE reversion(pEmpresa,csucursal,cEjecutivo,
					vFolio, "A")
					INTO  P_ERROR;
					-- Actualización de credito en bitacora de upgrade cuando pase un error
					UPDATE bdicred:"informix".sd_credito_upgrade  SET Resultado='2'
					WHERE numcte = cNumcte AND num_credito = cNumCredito;	

					LET cCodRet = '000006';
					LET cMensajeRet=P_MENSAJE;
					LET cCreditos = cNumCredito || ", " || cCreditos;
					LET cCreditosErr = cCodRet || ", " || cCreditosErr;
					LET cNoexitoso = cNoexitoso + 1;					
					--RETURN cCodRet, cMensajeRet;
					CONTINUE FOREACH;
				END IF;
			END IF;
			
				--Se revisa si se cuenta con saldo a favor
			IF dcSdoActTotCapCSG < 0 THEN -- Se crea codigo fun y codigo _ ref nuevo
				IF NOT EXISTS (SELECT num_credito FROM bdicred:"informix".sd_movhis WHERE num_credito = cNumCredUpgrade AND codigo_fun ='075' AND codigo_ref ='1') THEN 
					--MOVIMIENTO POR APERTURA CON SALDO A FAVOR 
					EXECUTE PROCEDURE GENMOV( pEmpresa         , cNumCredUpgrade,
							  cNumProdUpgrade        , 1,
								"075"             , dFecha_Apert,
								(dcSdoActTotCapCSG *-1)          , vFolio,
								csucursal       ,cDivisa,
								"0000")
					INTO P_ERROR, P_MENSAJE;
				
						IF P_ERROR::integer <> 0 THEN
							--AAME Se anexa reverso de operación
							EXECUTE PROCEDURE reversion(pEmpresa,csucursal,cEjecutivo,vFolio, "A")
							INTO  P_ERROR;				
							-- Actualización de credito en bitacora de upgrade cuando pase un error
							UPDATE bdicred:"informix".sd_credito_upgrade  SET Resultado='2'
							WHERE numcte = cNumcte AND num_credito = cNumCredito;		

							LET cCodRet = '000007';
							LET cMensajeRet=P_MENSAJE;
							LET cCreditos = cNumCredito || ", " || cCreditos;
							LET cCreditosErr = cCodRet || ", " || cCreditosErr;
							LET cNoexitoso = cNoexitoso + 1;							
							--RETURN cCodRet, cMensajeRet;
							CONTINUE FOREACH;
						END IF;
				END IF;
			END IF;

			IF dcTotalLiqCSG > 0 THEN -- Se crea codigo fun y codigo _ ref nuevo
				IF NOT EXISTS (SELECT num_credito FROM bdicred:"informix".sd_movhis WHERE num_credito = cNumCredUpgrade AND codigo_fun ='002' AND codigo_ref ='112') THEN  				
				-- Se realiza el cargo del movimiento del total del adeudo
					EXECUTE PROCEDURE GENMOV( pEmpresa         , cNumCredUpgrade,
						  cNumProdUpgrade        , 112,
							"002"             , dFecha_Apert,
							(dcTotalLiqCSG *1)          , vFolio,
							csucursal       ,cDivisa,
							"0000")
					INTO P_ERROR, P_MENSAJE;
				
					IF P_ERROR::integer <> 0 THEN
						--AAME Se anexa reverso de operación
						EXECUTE PROCEDURE reversion(pEmpresa,csucursal,cEjecutivo,vFolio, "A")
						INTO  P_ERROR;
						-- Actualización de credito en bitacora de upgrade cuando pase un error
						UPDATE bdicred:"informix".sd_credito_upgrade  SET Resultado='2'
						WHERE numcte = cNumcte AND num_credito = cNumCredito;
						
						LET cCodRet = '000008';
						LET cMensajeRet=P_MENSAJE;
						LET cCreditos = cNumCredito || ", " || cCreditos;
						LET cCreditosErr = cCodRet || ", " || cCreditosErr;
						LET cNoexitoso = cNoexitoso + 1;							
						--RETURN cCodRet, cMensajeRet;
						CONTINUE FOREACH;
					END IF;
				END IF;
			END IF;*/
		
		END IF;
	
	END FOREACH;

	IF cNoexitoso > 0 THEN
		SET DEBUG FILE TO '/tmp/CreditosconError.out';
		TRACE ON;
			LET cCreditos = cCreditos;
			LET cCreditosErr = cCreditosErr;			
		TRACE OFF;	
	END IF;	
	RETURN cCodRet, cMensajeRet, cExitoso, cNoexitoso;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para ejecutar de forma masiva la correción de créditos con upgrades generados con mas de un crédito Oro o Platino', 
'por repetidas ejecuciones del clonado del producto',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 22/03/2018',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_identificar_clientes_pba(pEmpresa CHAR(3),pFechaHoyAumlincred DATE)
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno;          
---DECLARACIONES          
DEFINE cEmpresa             CHAR(3);
DEFINE cNumCte              CHAR(20);
DEFINE cNum_cred            CHAR(20);
DEFINE cCreditoDirty        CHAR(20);
DEFINE cCreditoClean 		CHAR(20);
DEFINE cRiesgo              CHAR(02);
DEFINE dMontoOtor           DECIMAL(18,2);
DEFINE dMontoReserva        DECIMAL(18,2);
DEFINE pNum_Vencidos        INTEGER;
DEFINE p_FechaHoy           DATE;
DEFINE p_PriDiaMes          DATE;
DEFINE p_UltDiaMesAnt       DATE;
DEFINE p_FechaMinApertCrd   DATE;
DEFINE p_FechaAnt1m         DATE;
DEFINE p_FechaAnt2m         DATE;
DEFINE p_FechaAnt3m         DATE;
DEFINE p_FechaAnt4m         DATE;
DEFINE p_FechaAnt6m         DATE;
DEFINE p_FechaAnt7m         DATE;
DEFINE p_FechaAnt12m        DATE;
DEFINE FechaAnt             DATE;
DEFINE dFechaCob            DATE;
DEFINE dtfechains           DATE;
DEFINE cCodRet              CHAR(6); 
DEFINE cCodRet2              CHAR(6); 
DEFINE cCod_RetIB           CHAR(6);
DEFINE cMensajeRet          CHAR(80);
DEFINE cMensajeRet2         CHAR(80);
DEFINE cComentario          CHAR(80);
DEFINE iSqlErr              INTEGER;
DEFINE iIsamErr             INTEGER;
DEFINE cErrorInfo           CHAR(80);
DEFINE LinUtil80            DECIMAL(18,2);
DEFINE valorsm              DECIMAL(18,2);
DEFINE cantidadsm           DECIMAL(18,2);
DEFINE valorsmzonac         DECIMAL(18,2);
DEFINE cSuc                 CHAR(4);
DEFINE Incprev              SMALLINT;
DEFINE Incprev6m            SMALLINT;
DEFINE iNumIncrTope         SMALLINT;
DEFINE utili                DECIMAL(18,2);
DEFINE vStatus              CHAR(2);
DEFINE vCausa               CHAR(3);
DEFINE valorlinutilcred     DECIMAL(18,2);
DEFINE valorreserva         DECIMAL(18,2);
DEFINE valor_reserva        DECIMAL(18,2);
DEFINE diasvigencia         INTEGER;
DEFINE regvigentes          INTEGER;
DEFINE numprod              CHAR(4);
DEFINE cUser                CHAR(20);
DEFINE sCommit              SMALLINT;
DEFINE contador_commit      INTEGER;
DEFINE sDiasMinimosAper     SMALLINT;
DEFINE sLineaCreditoMin     SMALLINT;
DEFINE sLineaCredito        SMALLINT;
DEFINE sNumIncremPrevios    SMALLINT;
DEFINE sLineaUtilizacion    SMALLINT;
DEFINE sNumVencidos         SMALLINT;
DEFINE sSolicitudBC         SMALLINT;
DEFINE sMesesTrancurridos   SMALLINT;
DEFINE cIncreAuto           CHAR(1);
DEFINE dtFechaMesesTranscurridos DATE;
DEFINE dtFecha_apertura     DATE;
DEFINE porc_uso             DECIMAL(18,2);
DEFINE int_cred_ven         DECIMAL(18,2);
DEFINE may_porc_uso6        DECIMAL(18,2);
DEFINE may_porc_usoProm        DECIMAL(18,2);
DEFINE dFechaVencto         DATE;
DEFINE dtFechaCuotaAnt      DATE;
DEFINE vproceso				CHAR(4);
DEFINE dLineaSugerida   DECIMAL(18,2);
DEFINE dAum1            DECIMAL(18,2);
DEFINE dAum2            DECIMAL(18,2);
DEFINE dAum3            DECIMAL(18,2);
DEFINE dAux0            DECIMAL(18,2);
DEFINE smblinsug		DECIMAL(18,2);
DEFINE sLineaCreditoMax	INTEGER;
DEFINE sScore	INTEGER;

DEFINE sLineaCreditoBC  SMALLINT;
DEFINE sLineaCreditoCAC INTEGER;
DEFINE cPregunta        CHAR(200);
DEFINE dtFechaCuota             DATE;
DEFINE dtFechaPago            DATE;
DEFINE dtFechaAux            DATE;
DEFINE sMinScoreCteDir   SMALLINT;
DEFINE sNumDecartIncr   SMALLINT;
DEFINE cCalifBuro   CHAR(2);
DEFINE cStatus_bit   CHAR(2);

DEFINE cMedioRes CHAR(1);
DEFINE cEjecutivo CHAR(10);
DEFINE cRespCte CHAR(1);
DEFINE iNumvencidos INTEGER;
DEFINE cGrupo CHAR(1);
DEFINE iMesesHistoria INTEGER;
DEFINE dSituacionPago DECIMAL(5,2);

DEFINE dFechaReporteBHVR	DATE;
DEFINE dPagado            DECIMAL(18,2);
DEFINE dPagoMin            DECIMAL(18,2);
DEFINE dPorcMaxUti          DECIMAL(18,2);
DEFINE iFlagRtPagMin    INTEGER;
		
---INICIALIZACIONES
LET cEmpresa                = "";
LET cNumCte                 = "";
LET cNum_cred               = "";
LET cCreditoDirty           = "";
LET cCreditoClean 			= "";
LET cRiesgo                 = "";
LET dMontoOtor              = 0;
LET dMontoReserva           = 0;
LET pNum_Vencidos           = 0;
LET p_FechaHoy              = DATE(1);
LET p_PriDiaMes             = DATE(1);
LET p_UltDiaMesAnt          = DATE(1);
LET p_FechaMinApertCrd      = DATE(1);
LET dtfechains              = DATE(1);
LET p_FechaAnt1m            = DATE(1);
LET p_FechaAnt2m            = DATE(1);
LET p_FechaAnt3m            = DATE(1);
LET p_FechaAnt4m            = DATE(1);
LET p_FechaAnt6m            = DATE(1);
LET p_FechaAnt7m            = DATE(1);
LET p_FechaAnt12m           = DATE(1);
LET FechaAnt                = DATE(1);
LET dFechaCob               = DATE(1);
LET LinUtil80               = 0;
--LET paramsm               = "013";
--LET paramcantsm           = "012";
--LET paramlinutilcred      = "019";
--LET paramvigencia         = "011";
--LET paramreserva          = "018";
LET valorsm                 = 0;
LET cantidadsm              = 0;
LET valorlinutilcred        = 0;
LET cSuc                    = "";
LET Incprev                 = 0;
LET Incprev6m               = 0;
LET iNumIncrTope            = 0;
LET utili                   = 0;
LET vStatus                 = "";
LET vCausa                  = "";
LET valorreserva            = 0;
LET valor_reserva           = 0;
LET diasvigencia            = 0;
LET regvigentes             = 0;
LET cComentario             = "";
LET numprod                 = "";
LET cUser                   = USER;
LET iSqlErr                 = 0;
LET iIsamErr                = 0;
LET cErrorInfo              = "";
LET cCodRet                 = "000000";
LET cCodRet2                = "000000";
LET cMensajeRet             = "Se realizó la consulta correctamente";
LET cMensajeRet2             = "Se realizó la consulta correctamente";
LET sCommit                 = 0;
LET contador_commit         = 0;
LET sDiasMinimosAper        = 0;
LET sLineaCreditoMin        = 0;
LET sLineaCredito           = 0;
LET sNumIncremPrevios       = 0;
LET sLineaUtilizacion       = 0;
LET sNumVencidos            = 0;
LET sSolicitudBC            = 0;
LET sMesesTrancurridos      = 0;
LET cIncreAuto              = "";
LET dtFechaMesesTranscurridos = DATE(1);
LET dtFecha_apertura = DATE(1);
LET porc_uso                = 0;
LET int_cred_ven            = 0;
LET may_porc_uso6           = 0;
LET may_porc_usoProm          = 0;
LET dFechaVencto            = DATE(1);
LET dtFechaCuotaAnt         = DATE(1);
LET vproceso                = '0501';
LET dLineaSugerida  	= 0;
LET dAum1  		 		= 0;
LET dAum2 				= 0;
LET dAum3               = 0;
LET dAux0             = 0;
LET smblinsug			= 0;
LET sLineaCreditoBC     = 0;
LET sLineaCreditoCAC    = 0;
LET cPregunta           = "";
LET sLineaCreditoMax    = 0;
LET sScore    = 0;
LET sMinScoreCteDir    = 0;
LET sNumDecartIncr    = 0;
LET dtFechaCuota        =     DATE(1);
LET dtFechaPago         =   DATE(1);
LET dtFechaAux         =   DATE(1);
LET cCalifBuro         =  "";
LET cStatus_bit  =  "";
LET cMedioRes = "";
LET cEjecutivo = "";
LET cRespCte = "";
LET iNumvencidos  = 0;
LET cGrupo = '';
LET iMesesHistoria = 0;
LET dSituacionPago = 0;

LET dFechaReporteBHVR =DATE(1);

LET dPagado      = 0;
LET dPagoMin     = 0;
LET dPorcMaxUti     = 0;
LET iFlagRtPagMin     = 0;


--SET DEBUG FILE TO '/informix/jesus/sp_identificar_clientes_pba.out';
--TRACE ON;

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        LET cCodRet= iSqlErr;
        LET cMensajeRet= cErrorInfo;
        IF (sCommit = -1) THEN
            rollback work;
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, trim(cMensajeRet) || "-" || iIsamErr::CHAR, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, cMensajeRet, '01') Returning cCod_RetIB;

--SET DEBUG FILE TO '/informix/jesus/RQM09407-2/sp_identificar_clientes_pba.out';
--TRACE ON;
    SELECT pri_dia_mes INTO p_PriDiaMes
    FROM bdicred:"informix".sd_fechas
    WHERE empresa = pEmpresa;
--TRACE OFF;
    IF NVL(pEmpresa,"") = "" THEN
        LET cCodRet     = "000011";
        LET cMensajeRet = "Parámetro requerido esta vacío";
        RETURN cCodRet, cMensajeRet;
    END IF;

    --rss temporal para pruebas
    --let p_PriDiaMes = mdy('08','01','2015');
    --rss temporal para pruebas
----Obtencion de parametros
    -- obtener el valor del salario minimo de la zona C
    SELECT valor INTO valorsm
     FROM bdicred:"informix".sd_param 
    WHERE cod_param = '013' AND empresa   = pEmpresa;
    -- validacion de los parametros.
    IF NVL(valorsm,"")  = "" THEN
        LET cCodRet     = "000001";
        LET cMensajeRet = "Error al obtener el parámetro del valor del salario mínimo";
        RETURN cCodRet, cMensajeRet;
    END IF;

    -- obtener el valor de la cantidad de salarios minimos zona C =1.27
    SELECT valor INTO cantidadsm
      FROM bdicred:"informix".sd_param 
     WHERE cod_param = '012' AND empresa   = pEmpresa;
    -- validacion de los parametros.
    IF NVL(cantidadsm,"") = "" THEN
        LET cCodRet     = "000002";
        LET cMensajeRet = "Error al obtener el parámetro de la cantidad de salarios mínimos";
        RETURN cCodRet, cMensajeRet;
    END IF;

    -- posteriormente multiplicarlo para obtener la cantidad a numeros reales
    LET valorsmzonac = (valorsm * 30.42) * cantidadsm;

    -- obtener el valor del procentaje de utilizacion para los créditos
    SELECT valor INTO valorlinutilcred
      FROM bdicred:"informix".sd_param 
     WHERE cod_param = '019' AND empresa   = pEmpresa;
    -- validacion de los parametros.
    IF NVL(valorlinutilcred,"") = "" THEN
        LET cCodRet     = "000003";
        LET cMensajeRet = "Error al obtener el parámetro de la cantidad de utilización de la línea de crédito";
        RETURN cCodRet, cMensajeRet;
    END IF;

    -- obtener el valor del de la reserva
    SELECT valor INTO valor_reserva
      FROM bdicred:"informix".sd_param 
     WHERE cod_param = '018' AND empresa = pEmpresa;
    -- validacion de los parametros.
    IF NVL(valor_reserva,"") = "" THEN
        LET cCodRet     = "000007";
        LET cMensajeRet = "Error al obtener el parámetro del monto de reserva";
        RETURN cCodRet, cMensajeRet;
    END IF;

    LET valorreserva = (valor_reserva * valorsm) * 30.42;

    -- obtener el valor de los dias de vigencia de los créditos
    SELECT valor INTO diasvigencia
      FROM bdicred:"informix".sd_param 
     WHERE cod_param = '011' AND empresa = pEmpresa ;
    -- validación de los parametros.
    IF NVL(diasvigencia,"") = "" THEN
        LET cCodRet     = "000008";
        LET cMensajeRet = "Error al obtener el parámetro de los días de vigencia del crédito";
        RETURN cCodRet, cMensajeRet;
    END IF; 

    -- Días mínimos de apertura de créditos
    SELECT valor INTO sDiasMinimosAper
      FROM bdicred:"informix".sd_param 
     WHERE cod_param = '021' AND empresa = pEmpresa ;
    IF NVL(sDiasMinimosAper,"") = "" THEN
        LET cCodRet     = "000009";
        LET cMensajeRet = "Error al obtener los días mínimos de apertura de créditos";
        RETURN cCodRet, cMensajeRet;
    END IF;

    -- Línea de crédito mínimo para incrementos de línea
    SELECT valor INTO sLineaCreditoMin
      FROM bdicred:"informix".sd_param 
     WHERE cod_param = '022' AND empresa = pEmpresa ;
    IF NVL(sLineaCreditoMin,"") = "" THEN
        LET cCodRet     = "000010";
        LET cMensajeRet = "Error al obtener la línea de crédito mínima para incrementos de línea";
        RETURN cCodRet, cMensajeRet;
    END IF;
  
    -- Compara créd con lín créd MN para increm línea
    SELECT valor INTO sLineaCredito
      FROM bdicred:"informix".sd_param 
     WHERE cod_param = '023' AND empresa = pEmpresa ;
    IF NVL(sLineaCredito,"") = "" THEN
        LET cCodRet     = "000011";
        LET cMensajeRet = "Error al obtener la línea de crédito a comparar para incrementos de línea";
        RETURN cCodRet, cMensajeRet;
    END IF;

    -- Número incrementos previos para increm línea
    SELECT valor INTO sNumIncremPrevios
      FROM bdicred:"informix".sd_param 
     WHERE cod_param = '024' AND empresa = pEmpresa ;
    IF NVL(sNumIncremPrevios,"") = "" THEN
        LET cCodRet     = "000012";
        LET cMensajeRet = "Error al obtener el número incrementos previos para incrementos de línea";
        RETURN cCodRet, cMensajeRet;
    END IF;

    -- Número de vencidos 
    SELECT valor INTO slineautilizacion
      FROM bdicred:"informix".sd_param 
     WHERE cod_param = '025' AND empresa = pEmpresa ;
    IF NVL(slineautilizacion,"") = "" THEN
        LET cCodRet     = "000013";
        LET cMensajeRet = "Error al obtener el número de vencidos para incrementos de línea";
        RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT TRIM(valor)::integer INTO sMesesTrancurridos
      FROM bdicred:"informix".sd_param 
     WHERE cod_param = '001' AND empresa = pEmpresa ;
    IF NVL(sMesesTrancurridos,"") = "" THEN
        LET cCodRet     = "000014";
        LET cMensajeRet = "Error al obtener el número de meses transcurridos para incrementos automáticos";
        RETURN cCodRet, cMensajeRet;
    END IF;
-- Línea de crédito Maxima para incrementos de línea
    SELECT valor INTO sLineaCreditoMax
      FROM bdicred:"informix".sd_param 
     WHERE cod_param = '046' AND empresa = pEmpresa ; ---checar parametro
    IF NVL(sLineaCreditoMax,"") = "" THEN
        LET cCodRet     = "000015";
        LET cMensajeRet = "Error al obtener la línea de crédito maxima para incrementos de línea";
        RETURN cCodRet, cMensajeRet;
    END IF;	
	
-- Compara línea crédito para enviar a BC 
SELECT valor 
  INTO sLineaCreditoBC
  FROM "informix".sd_param 
 WHERE cod_param = '027'
   AND empresa = pEmpresa ;

IF NVL(sLineaCreditoBC,"") = "" THEN
    LET cCodRet     = "000009";
	LET cMensajeRet = "Error al obtener la línea crédito para enviar a BC para incrementos de línea";
	RETURN cCodRet, cMensajeRet;
END IF;

-- Compara línea crédito para enviar aL CAC 
SELECT valor 
  INTO sLineaCreditoCAC
  FROM "informix".sd_param 
 WHERE cod_param = '028'
   AND empresa = pEmpresa ;

IF NVL(sLineaCreditoCAC,"") = "" THEN
    LET cCodRet     = "000010";
	LET cMensajeRet = "Error al obtener la línea crédito para enviar al CAC para incrementos de línea";
	RETURN cCodRet, cMensajeRet;
END IF;
	
SELECT valor 
  INTO iNumIncrTope
  FROM "informix".sd_param 
 WHERE cod_param = '047'
   AND empresa = pEmpresa ;

IF NVL(iNumIncrTope,"") = "" THEN
    LET cCodRet     = "000017";
	LET cMensajeRet = "Error al obtener el tope de maximo de incrementos";
	RETURN cCodRet, cMensajeRet;
END IF;
	
-- obtencion del porcentaje para calcuar la linea de clientes con su linea actual mayor o igual a 1.27 sm 
SELECT valor 
  INTO dAum1
  FROM "informix".sd_param 
 WHERE empresa = pEmpresa 
   AND cod_param = '016';

-- validacion de los parametros.
IF NVL(dAum1,"") = "" THEN
    LET cCodRet     = "000006";
	LET cMensajeRet = "Error al obtener el parametro de porcentaje de incremento para salarios minimos mayores a 1.27";
	RETURN cCodRet, cMensajeRet;
END IF;

-- obtencion del porcentaje para calcuar la linea de clientes con su linea actual mayor o igual a 1.27 sm 
SELECT valor 
  INTO dAum3
  FROM "informix".sd_param 
 WHERE empresa = pEmpresa 
   AND cod_param = '092';

-- validacion de los parametros.
IF NVL(dAum3,"") = "" THEN
    LET cCodRet     = "000016";
	LET cMensajeRet = "Error al obtener el parametro de porcentaje de incremento para salarios minimos mayores a 1.27";
	RETURN cCodRet, cMensajeRet;
END IF;

--Dic 2015 Se toma la última base de los clientes clean procesados
SELECT MAX(fecha_reporte) INTO dFechaReporteBHVR FROM bdicred:"informix".sd_clientes_clean_behavior WHERE status_bit IS NULL;

SELECT trim(valor)::SMALLINT INTO sMinScoreCteDir FROM bdicred:sd_param WHERE cod_param = 106; --Nivel de riesgo a procesar (score minimo para descartar)
	
	SELECT valor INTO dPorcMaxUti
FROM bdicred:"informix".sd_param 
WHERE cod_param = '112' AND empresa   = pEmpresa;
	
    --LET FechaAnt = p_FechaHoy - diasvigencia UNITS DAY;
    --LET FechaAnt = pFechaHoyAumlincred - diasvigencia UNITS DAY;
	CALL bdicred:"informix".monthadd(pFechaHoyAumlincred,-1)  RETURNING p_FechaAnt1m; -- 30 días
    CALL bdicred:"informix".monthadd(pFechaHoyAumlincred,-2)  RETURNING p_FechaAnt2m; -- 60 días
    CALL bdicred:"informix".monthadd(pFechaHoyAumlincred,-3)  RETURNING p_FechaAnt3m; -- 90 días
    CALL bdicred:"informix".monthadd(pFechaHoyAumlincred,-4)  RETURNING p_FechaAnt4m; -- 120 días
    CALL bdicred:"informix".monthadd(pFechaHoyAumlincred,-6)  RETURNING p_FechaAnt6m; -- 180 días
	CALL bdicred:"informix".monthadd(pFechaHoyAumlincred,-7)  RETURNING p_FechaAnt7m; -- 210 días
    CALL bdicred:"informix".monthadd(pFechaHoyAumlincred,-12) RETURNING p_FechaAnt12m; -- 360 días
    -- obtener la fecha de los meses que se tienen q pasar para los incrementos automaticos
    CALL bdicred:"informix".monthadd(pFechaHoyAumlincred,-sMesesTrancurridos) RETURNING dtFechaMesesTranscurridos; 

--SET DEBUG FILE TO '/RESPALDOS/ipcb/pruebas/sp_identificar_clientes_pba.out';
--TRACE ON;	
	
    -- Almacena en una temporal los creditos a tratar en el foreach - creditos al corriente de pagos
    LET p_UltDiaMesAnt =  p_PriDiaMes - 1 units day;
	LET dtFechaCuotaAnt = MONTH(p_FechaAnt1m)||'-'||day(20)||'-'||YEAR(p_FechaAnt1m);
    LET p_FechaMinApertCrd = pFechaHoyAumlincred - sDiasMinimosAper;
--TRACE OFF;	
----------Fin parametros
   							
		SELECT a.num_solicitud, a.numcte, b.sucursal, a.num_producto, a.ajuste_de_cuota, 
		c.monto_otorgado,b.fecha_apertura, d.grupo,
        d.meses_historia, d.situacion_pago		--,ctes.num_credito, ctes.score
		FROM bdisolic:"informix".ss_solicitudes a 
		INNER JOIN bdicred:"informix".sd_maecredcont b ON (b.fecha = p_UltDiaMesAnt AND b.empresa = a.empresa AND b.num_credito = a.num_solicitud AND b.status_cred = "AA" AND NVL(b.id_unidad_prod ,'') = ''	AND NVL(b.cod_caract ,'') = '' AND NVL(b.cod_caract_2 ,'') = '')
		INNER JOIN bdicred:"informix".sd_maesdos c ON (c.empresa= a.empresa AND c.num_credito = a.num_solicitud AND c.monto_otorgado BETWEEN sLineaCreditoMin AND sLineaCreditoMax)
		INNER JOIN bdisolic:ss_resum_scor_fin d ON (d.empresa = a.empresa AND d.num_solicitud = a.num_solicitud)
		WHERE a.empresa = '001'
		AND a.num_solicitud = b.num_credito		
        INTO TEMP CreditosIncrLcr WITH NO LOG;

        CREATE INDEX inx_cred_increm ON CreditosIncrLcr (num_solicitud);
        UPDATE STATISTICS medium FOR TABLE CreditosIncrLcr;
				
      
    -- Elimina los registros que ya tengan registro correspondiente de incremento
    DELETE FROM CreditosIncrLcr WHERE num_solicitud IN (select {+INDEX(bdicred:"informix".sd_bitacora_aumlincred idx_bitacora_fhinsert)} num_solicitud from bdicred:"informix".sd_bitacora_aumlincred where empresa=pEmpresa and fecha_insert = pFechaHoyAumlincred);
    -- Elimina los registros que ya hayan tenido una solicitud RT en los dos meses previos
    DELETE FROM CreditosIncrLcr WHERE num_solicitud IN (select num_solicitud from bdicred:"informix".sd_bitacora_aumlincred where empresa=pEmpresa and fecha_status BETWEEN p_FechaAnt2m AND pFechaHoyAumlincred and status = 'RT');
    --Elimina los registros que tengan una registro previo con status: PC,BC,CC,AC,EC            
    DELETE FROM CreditosIncrLcr WHERE num_solicitud IN (SELECT num_solicitud FROM bdicred:"informix".sd_bitacora_aumlincred WHERE empresa= pEmpresa AND status IN ("PC","BC","CC","AC","EC","AT","IN"));
	--    -- Elimina los clientes que esten marcados como "dirty" en el proceso behavior. // se modifica sp: sp_calcularaumlincred
--    DELETE FROM CreditosIncrLcr WHERE num_credito IN ( Select num_credito from bdicred:sd_clientes_dirty_behavior );

    --  Se eliminan los clientes que cuentan con incrementos automaticos autorizados Y se valida que el número de meses transcurridos de la fecha del último incremento
    --   o la fecha de alta del crédito (lo último que haya sucedido) sea mayor al valor obtenido en la variable dtFechaMesesTranscurridos // ( Se elimina condicion**1)
	 
    DELETE FROM CreditosIncrLcr WHERE ajuste_de_cuota = 'S' AND fecha_apertura >= dtFechaMesesTranscurridos;
    -- Se eliminan los creditos de Tarjetas Garantizadas. (condicion**2)
	
    DELETE FROM CreditosIncrLcr WHERE num_solicitud IN (SELECT num_credito FROM bdicred:"informix".sd_tarjeta_garantizada WHERE empresa = pEmpresa AND garantizada = 'S');
	
	-- Se eliminan los creditos que no tienen mas de 180 dias y que su monto sea mayor al minimo 3000 RQM 09 320
	DELETE FROM CreditosIncrLcr WHERE  fecha_apertura >= p_FechaMinApertCrd;
	
	DELETE FROM CreditosIncrLcr WHERE monto_otorgado = sLineaCreditoMax ;
	-- Se eliminan los creditos que se originaron como grupo 6 para que no sean candidatos a ofertarles un incremento RQM 09320-1 PIQV
	--DELETE FROM CreditosIncrLcr WHERE grupo = '6'; RQM 09 407-2
	DELETE FROM CreditosIncrLcr WHERE grupo in ('6','8');
    UPDATE STATISTICS medium FOR TABLE CreditosIncrLcr;

    -- Foreach que obtiene créditos al corriente de pagos
    --se modifica la consulta principal para obtener el valor  que indica si el cliente cuenta con incremento automatico activo.
    FOREACH WITH HOLD

	SELECT num_solicitud, numcte,   sucursal, num_producto,ajuste_de_cuota,monto_otorgado, fecha_apertura,c.num_credito, NVL(c.score,0), grupo, NVL(meses_historia,0), NVL(situacion_pago,0)
          INTO cNum_cred, cNumCte,  cSuc, numprod,cIncreAuto,dMontoOtor,dtFecha_apertura,cCreditoClean, sScore, cGrupo, iMesesHistoria, dSituacionPago
          FROM CreditosIncrLcr 	
		  LEFT JOIN  bdicred:"informix".sd_clientes_clean_behavior c ON (c.num_credito =num_solicitud 
			 																AND month(c.fecha_reporte)  = month(dFechaReporteBHVR) 
				 															AND year(c.fecha_reporte) = year(dFechaReporteBHVR) )
--			 																AND month(c.fecha_reporte)  = month(pFechaHoyAumlincred) 
--				 															AND year(c.fecha_reporte) = year(pFechaHoyAumlincred) )

     /*    --rss ENE 2011 TEMPORAL en lo que se implementan las respuestas de Buró de Crédito
        SELECT {+INDEX(bdicred:"informix".sd_bitacora_aumlincred idx_bitacora_status)} NVL(count(*),0)
            INTO sSolicitudBC
            FROM bdicred:"informix".sd_bitacora_aumlincred 
            WHERE numcte  = cNumCte
            AND empresa = pEmpresa
            AND status = 'BC';

            IF sSolicitudBC > 0 THEN CONTINUE FOREACH; END IF;
        --rss ENE 2011 TEMPORAL en lo que se implementan las respuestas de Buró de Crédito */

        LET cMensajeRet = cNum_cred || '  identificacion_clientes';

        IF (sCommit = 0) THEN
            BEGIN WORK;
            LET contador_commit = 0;
            LET sCommit = -1;
        END IF; 

        IF cRiesgo IS NULL THEN LET cRiesgo = ""; END IF;

        --Se hace commit y update statistics a los 1000 registros insertados en tablas
        IF (contador_commit >= 1000) THEN
            COMMIT WORK;
            --       UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_bitacora_aumlincred;
            --       UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_autorizacion_aumlincred;
            LET contador_commit = 0;
            BEGIN WORK;
        END IF;

        LET contador_commit = contador_commit  + 1;
        LET regvigentes  = 0;
        LET Incprev6m    = 0;
        LET Incprev      = 0;
        LET vStatus = "";
        LET vCausa  = "";
		LET may_porc_uso6 = 0;
		LET int_cred_ven  = 0;
		LET utili = 0;
		LET cMedioRes = "";
		LET cEjecutivo = "";
		LET cRespCte = "";
		LET cPregunta= "";
		
		IF NVL(cGrupo,'') = '' THEN
			IF ((iMesesHistoria >= 13 AND dSituacionPago >= 85) OR
			   (iMesesHistoria >= 6 AND dSituacionPago >= 0 AND dSituacionPago < 85)) THEN
			   LET cGrupo = '1';
			ELIF iMesesHistoria >= 6 AND iMesesHistoria < 13 AND dSituacionPago >= 85 THEN
			   LET cGrupo = '2';
			ELIF ((iMesesHistoria < 6 AND dSituacionPago > 0) OR (iMesesHistoria > 0 AND iMesesHistoria < 6 AND dSituacionPago <= 0) OR
				 (dSituacionPago = -1)) THEN
			   LET cGrupo = '3';
			ELIF iMesesHistoria = 0 and dSituacionPago = 0 THEN
			   LET cGrupo = '5';
			END IF;
		END IF;
			
        --IF NVL(cGrupo,'') = '3' THEN	RQM 09 407-2
        IF NVL(cGrupo,'') in ('3','5') THEN		
	
		   LET dAux0 = dAum3;
		ELSE
		   LET dAux0 = dAum1;
		END IF;		

		--Trae la fecha del último incremento del crédito para validar si fue en los últimos 6 meses, si es así no se considera para el análisis de incremento de línea
        --Cuenta los incrementos que ha tenido el crédito
        SELECT {+INDEX(bdicred:"informix".sd_bitacora_aumlincred idx_bitacora_status)} 
				MAX(fecha_status),nvl(count(status),0)
            INTO dtfechains,Incprev
            FROM bdicred:"informix".sd_bitacora_aumlincred 
            WHERE numcte  = cNumCte
            AND empresa = pEmpresa
            AND status = 'AP';

        IF dtfechains IS NULL OR dtfechains = '' THEN LET dtfechains = date(1); END IF;

        IF cIncreAuto ='S' AND dtfechains >= dtFechaMesesTranscurridos  AND dtfechains <= today THEN
            CONTINUE FOREACH;
        END IF;

		IF Incprev >= iNumIncrTope THEN		
			CONTINUE FOREACH;
		END IF;
		
		--IF dtfechains >= p_FechaAnt6m AND dtfechains <= today THEN--RQM 09 407
		IF dtfechains >= p_FechaAnt12m AND dtfechains <= today THEN
      
           CONTINUE FOREACH;
        END IF;

		--INI validacion del behavior clean
		
		IF NVL(cCreditoClean,'') = ''  THEN
				
				LET dLineaSugerida  = round(dMontoOtor + (dMontoOtor * dAux0),-2);
				LET smblinsug = dLineaSugerida / (30.42 * valorsm);
				--LET dMontoIncrem = dLineaSugerida - dMontoOtor;
				LET vstatus = 'RT';
				LET vCausa  = 'RDB';
				
				--validar si califico para ir a buro
				IF (dLineaSugerida >= sLineaCreditoBC) THEN
					LET cCalifBuro = "SI";
					LET cStatus_bit = 'BC';
				ELSE
					LET cCalifBuro = "NO";
					LET cStatus_bit = 'AT';
				END IF;
				--- LET cComentario = 'Se rechaza incremento por ser Cliente Dirty en proceso Behavior';

				INSERT INTO bdicred:"informix".sd_bitacora_aumlincred(empresa, num_solicitud, numcte, num_producto, status, causa_status,         fecha_status,  hora_status, sucursal, lincred_actual, lincred_sugerida, smb_lincred, grado_riesgo, monto_reserva, califica_buro, resp_cte, mensaje, ejecutivo, sucursal_at, origen, user_insert, fecha_insert, num_inc_prev, num_per_porutimay_806, num_per_porutimay_8012, medio_res, cte_noestit_p, cte_noestit_v, porc_uso, int_cred_ven, may_porc_uso6,dfecha_cobranza) 
				VALUES(pEmpresa, cNum_cred   , cNumCte, numprod    , vStatus,       vCausa,   pFechaHoyAumlincred,     current,      cSuc,     dMontoOtor,             dLineaSugerida,           smblinsug,      cRiesgo, dMontoReserva,            '',      '',      '',        '',          '',    'C', cUser, pFechaHoyAumlincred, Incprev, utili, utili, '', 0, 0, porc_uso, int_cred_ven, may_porc_uso6,DATE(1));
				   

				-- Registra el movimiento de la cancelacion.
				INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
				 VALUES(pEmpresa, cNum_cred, "PC", "", cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);
				
				INSERT INTO bdicred:informix.sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
				VALUES(pEmpresa, cNum_cred,cStatus_bit , "", cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);

				INSERT INTO bdicred:informix.sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
				VALUES(pEmpresa, cNum_cred, vstatus, vCausa, cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);

				SELECT count(num_credito) INTO sNumDecartIncr  FROM bdicred:"informix".sd_clientes_clean_behavior
				WHERE num_credito = cNum_cred AND status_bit IS NOT NULL;

				LET sNumDecartIncr = sNumDecartIncr + 1; -- Suma 1, ya que toma como 1 el proceso que se esta ejecutando.
		

				-- Actualiza informacion de cliente Dirty en la tabla que almacena estos clientes.
				INSERT INTO bdicred:"informix".sd_clientes_clean_behavior (fecha_reporte,num_credito,score,status_bit,monto_lcr_original,incremento_sugerido,
				increm_otorgados_actual,num_descartes_increm,candidato_buro)
				VALUES(pFechaHoyAumlincred,cNum_cred,sScore,vstatus,dMontoOtor,dLineaSugerida - dMontoOtor,Incprev,sNumDecartIncr,cCalifBuro); 
				
				  CONTINUE FOREACH;
		 END IF;
		--fin validacion del behavior clean
	
		--INI validacion del behavior
		
		
			/*IF sScore >= sMinScoreCteDir AND NVL(cCreditoDirty,'') <> ''  THEN
				
				LET dLineaSugerida  = round(dMontoOtor + (dMontoOtor * dAux0),-2);
				LET smblinsug = dLineaSugerida / (30.42 * valorsm);
				--LET dMontoIncrem = dLineaSugerida - dMontoOtor;
				LET vstatus = 'RT';
				LET vCausa  = 'RDB';*/
				
				/*--validar si califico para ir a buro
				IF (dLineaSugerida >= sLineaCreditoBC) THEN
					LET cCalifBuro = "SI";
					LET cStatus_bit = 'BC';
				ELSE
					LET cCalifBuro = "NO";
					LET cStatus_bit = 'AT';
				END IF;
				--- LET cComentario = 'Se rechaza incremento por ser Cliente Dirty en proceso Behavior';

				INSERT INTO bdicred:"informix".sd_bitacora_aumlincred(empresa, num_solicitud, numcte, num_producto, status, causa_status,         fecha_status,  hora_status, sucursal, lincred_actual, lincred_sugerida, smb_lincred, grado_riesgo, monto_reserva, califica_buro, resp_cte, mensaje, ejecutivo, sucursal_at, origen, user_insert, fecha_insert, num_inc_prev, num_per_porutimay_806, num_per_porutimay_8012, medio_res, cte_noestit_p, cte_noestit_v, porc_uso, int_cred_ven, may_porc_uso6,dfecha_cobranza) 
				VALUES(pEmpresa, cNum_cred   , cNumCte, numprod    , vStatus,       vCausa,   pFechaHoyAumlincred,     current,      cSuc,     dMontoOtor,             dLineaSugerida,           smblinsug,      cRiesgo, dMontoReserva,            '',      '',      '',        '',          '',    'C', cUser, pFechaHoyAumlincred, Incprev, utili, utili, '', 0, 0, porc_uso, int_cred_ven, may_porc_uso6,DATE(1));
				   
*/
				-- Registra el movimiento de la cancelacion.
				/*INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
				 VALUES(pEmpresa, cNum_cred, "PC", "", cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);
				
				INSERT INTO bdicred:informix.sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
				VALUES(pEmpresa, cNum_cred,cStatus_bit , "", cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);

				INSERT INTO bdicred:informix.sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
				VALUES(pEmpresa, cNum_cred, vstatus, vCausa, cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);

				SELECT count(num_credito) INTO sNumDecartIncr  FROM bdicred:"informix".sd_clientes_dirty_behavior
				WHERE num_credito = cNum_cred AND status_bit IS NOT NULL;

				LET sNumDecartIncr = sNumDecartIncr + 1; -- Suma 1, ya que toma como 1 el proceso que se esta ejecutando.
		
*/
				-- Actualiza informacion de cliente Dirty en la tabla que almacena estos clientes.
				/*UPDATE bdicred:"informix".sd_clientes_dirty_behavior
				SET status_bit = cStatus_bit,
					monto_lcr_original = dMontoOtor,
					incremento_sugerido = dLineaSugerida - dMontoOtor,
					increm_otorgados_actual = Incprev,
					num_descartes_increm = sNumDecartIncr,
					candidato_buro = cCalifBuro
				WHERE  num_credito = cNum_cred
				AND month(fecha_reporte) = month(pFechaHoyAumlincred) 
				AND year(fecha_reporte) = year(pFechaHoyAumlincred);
				  CONTINUE FOREACH;*/
		 --END IF;
		--fin validacion del behavior
		--RQM 09 407
		 --se mueve seccion de codigo con la finalidad de validar tanto para lineas menos o mayores del minimo que el cliente no presente vencidos
		 LET sNumVencidos =0;
			SELECT COUNT(num_credito) 
				INTO sNumVencidos 
				FROM bdicred:"informix".sd_maesdoshist
				WHERE empresa        = pEmpresa
				AND num_credito    = cNum_cred
				--AND fecha BETWEEN p_FechaAnt6m AND pFechaHoyAumlincred   
				AND fecha BETWEEN p_FechaAnt12m AND pFechaHoyAumlincred   --RQM 09 407
				AND mto_fin_ven_trasp > 0;
					
				IF sNumVencidos = 0 THEN--Se valida que el cliente no presente vencidos en prestamos					
			    
					SELECT COUNT(SolPresVenc)
					INTO sNumVencidos
					FROM TABLE (MULTISET (
								SELECT 
								CASE WHEN status_cred IN ("BA","BT") THEN status_cred END AS SolPresVenc
								FROM bdicred:"informix".sd_maecredcrd
							   WHERE numcte = cNumCte
								 AND empresa = "001" ));
				END IF;   
				   
				IF(  sNumVencidos > pNum_Vencidos) THEN
					LET vStatus = "RT";
					LET vCausa  = "RBE";
					INSERT INTO bdicred:"informix".sd_bitacora_aumlincred(empresa, num_solicitud, numcte, num_producto, status, causa_status,         fecha_status,  hora_status, sucursal, lincred_actual, lincred_sugerida, smb_lincred, grado_riesgo, monto_reserva, califica_buro, resp_cte, mensaje, ejecutivo, sucursal_at, origen, user_insert, fecha_insert, num_inc_prev, num_per_porutimay_806, num_per_porutimay_8012, medio_res, cte_noestit_p, cte_noestit_v, porc_uso, int_cred_ven, may_porc_uso6) 
						 VALUES(pEmpresa, cNum_cred   , cNumCte, numprod    , vStatus,       vCausa,   pFechaHoyAumlincred,     current,      cSuc,     dMontoOtor,                0,           0,      cRiesgo, dMontoReserva,            '',      '',      '',        '',          '',    'C', cUser, pFechaHoyAumlincred, Incprev, utili, utili, '', 0, 0, porc_uso, int_cred_ven, may_porc_uso6);
					INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
						 VALUES(pEmpresa, cNum_cred, vStatus, vCausa, cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);
					CONTINUE FOREACH;
				END IF;
		
		
        --Si la línea de crédito actual del crédito es menor a 2100 MN (1.27 SM zona C aproximadamente) se precalifica
        IF dMontoOtor < sLineaCredito THEN -- compara la linea de credito en pesos y ya no en salarios mínimos  
            LET vStatus     = "AT";          
			--LET cComentario = "Requiere autorización del cliente para su aplicación";
			LET dLineaSugerida  = round(dMontoOtor + (dMontoOtor * dAux0),-2);
			LET smblinsug = dLineaSugerida / (30.42 * valorsm);
			
			IF dLineaSugerida < sLineaCredito THEN --RQM 09 320 
				LET dLineaSugerida = sLineaCredito;
			END IF 
				/*	
            --se inserta el registro de la precalificacion
            INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
                VALUES(pEmpresa, cNum_cred, "PC", "", cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);
			--se inserta el registro de la preautorización
			INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
                VALUES(pEmpresa, cNum_cred, vStatus, vCausa, cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);
			
			
					--se agrega validacion para ver si el cliente cuenta con incrementos automaticos, si es asi se manda llamar al procedimiento sp_registrarrespuestacte para simular la respuesta de autorizacion del cliente.
			IF cIncreAuto ='S' AND  vStatus= "AT" THEN
			
				LET cPregunta= "Autorizo expresamente a BanCoppel a incrementar mi linea de crédito a $" ||dLineaSugerida|| ", así mismo, acepto las nuevas condiciones y términos aplicables a partir de esta fecha.";
				LET cMedioRes = 'P';
				LET cEjecutivo = 'sistema';
				LET cRespCte = '1';
				LET vStatus     = "AP";
				LET vCausa      = "";
			--se inserta el registro de la autorización
			INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
					VALUES(pEmpresa, cNum_cred, vStatus, vCausa, cUser, today, pFechaHoyAumlincred, 0);
			END IF; 
			
			--se inserta el registro en la bitacora con el resultado final.
			INSERT INTO bdicred:"informix".sd_bitacora_aumlincred(empresa, num_solicitud, numcte, num_producto, status, causa_status, fecha_status,          hora_status, sucursal, lincred_actual, lincred_sugerida, smb_lincred, grado_riesgo, monto_reserva, califica_buro, resp_cte, mensaje, ejecutivo, sucursal_at, origen, user_insert, fecha_insert, num_inc_prev, num_per_porutimay_806, num_per_porutimay_8012, medio_res, cte_noestit_p, cte_noestit_v, porc_uso, int_cred_ven, may_porc_uso6,dfecha_cobranza) 
                VALUES(pEmpresa, cNum_cred   , cNumCte, numprod    , vStatus,       vCausa,   pFechaHoyAumlincred,     current,      cSuc,     dMontoOtor, dLineaSugerida,          smblinsug,     cRiesgo,  dMontoReserva, '', cRespCte, cPregunta, '', '',    'C', cUser, pFechaHoyAumlincred, Incprev, utili, utili, cMedioRes, 0, 0, porc_uso, int_cred_ven, may_porc_uso6,pFechaHoyAumlincred);
        				
			IF cIncreAuto ='S' AND  vStatus= "AP" THEN --se coloca aqui para que primero inserte el registro en la bitacora y despues se asigne el incremento.
		
			EXECUTE PROCEDURE bdicred:"informix".sp_grabarincrementolincred(pEmpresa, cNum_cred) INTO cCodRet, cMensajeRet;
				IF cCodRet <> "00000" THEN
					LET cCodRet = "00001";
					LET cMensajeRet = "Error al realizar incremento automático de línea para el crédito  " || cNum_cred;			
					RETURN cCodRet, cMensajeRet;
				END IF;	

			END IF; 			
				
           CONTINUE FOREACH;*/
        END IF;

		SELECT grado_riesgo,nvl(reserva_calificacion,0),porcentaje_uso
			INTO  cRiesgo,dMontoReserva,porc_uso
		  FROM bdicred:"informix".sd_hist_reserva  
		  WHERE empresa = pEmpresa 
		  AND num_credito = cNum_cred
		  AND fecha_cierre = p_UltDiaMesAnt;     
		
		
        --Se descartan los créditos con grado de riesgo D, E y C (para este último con monto de reserva mayor a 600 MN (0.37 SM zona C aproximadamente))
        --IF (cRiesgo NOT IN ("A","B1","B2")) OR ((cRiesgo = "C") AND (dMontoReserva > 600)) THEN -- se compara en pesos y ya no en salarios mínimos
        IF (cRiesgo NOT IN ("A1","A2","B1","B2","B3","C1","C2")) THEN -- PIQV RQM 09 320-4
            LET vStatus = "RT";
            LET vCausa  = "RGR";
			--Se realiza cambio por incidencia 
            INSERT INTO bdicred:"informix".sd_bitacora_aumlincred(empresa, num_solicitud, numcte, num_producto, status, causa_status, fecha_status,           hora_status, sucursal, lincred_actual, lincred_sugerida, smb_lincred, grado_riesgo, monto_reserva, califica_buro, resp_cte, mensaje, ejecutivo, sucursal_at, origen, user_insert, fecha_insert, num_inc_prev, num_per_porutimay_806, num_per_porutimay_8012, medio_res, cte_noestit_p, cte_noestit_v, porc_uso, int_cred_ven, may_porc_uso6) 
                 VALUES(pEmpresa, cNum_cred   , cNumCte, numprod    , vStatus,       vCausa,   pFechaHoyAumlincred,     current,      cSuc,     dMontoOtor,                0,           0,      cRiesgo,  dMontoReserva,            '',      '',      '',        '',          '',    'C', cUser, pFechaHoyAumlincred, Incprev, utili, utili, '', 0, 0, porc_uso, int_cred_ven, may_porc_uso6);
            INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
                 VALUES(pEmpresa, cNum_cred, vStatus, vCausa, cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);
            CONTINUE FOREACH; 
        END IF;

        --Selecciona el mayor porcentaje de uso en los ultimos 6 meses que presenta el credito
      /*
		SELECT MAX(porcentaje_uso), nvl(count(porcentaje_uso),0)
			INTO may_porc_uso6,utili
          FROM bdicred:"informix".sd_hist_reserva
	     WHERE empresa     = pEmpresa
	       AND num_credito = cNum_cred
	       AND fecha_cierre BETWEEN p_FechaAnt6m AND pFechaHoyAumlincred;
			--AND porcentaje_uso >= valorlinutilcred;  
			*/
			
			SELECT MAX(round(((b.sdo_cap_insoluto + (b.sdo_contab_mora + b.sdo_moratorio) * (select 1 + nvl(iva,0) from bdinteg:si_sucursales where empresa='001' and sucursal = cSuc)
			+ amo.campo_trabajo1 + case when b.int_tra_no_exig - b.sdo_int_anticip >= 0 then  b.int_tra_no_exig - b.sdo_int_anticip else b.int_tra_no_exig end) / monto_otorgado)*100,2)), 
			nvl(count(round(((b.sdo_cap_insoluto + (b.sdo_contab_mora + b.sdo_moratorio) * (select 1 + nvl(iva,0) from bdinteg:si_sucursales where empresa='001' and sucursal = cSuc)
			+ amo.campo_trabajo1 + case when b.int_tra_no_exig - b.sdo_int_anticip >= 0 then  b.int_tra_no_exig - b.sdo_int_anticip else b.int_tra_no_exig end) / monto_otorgado)*100,2)),0),
			Round(AVG(round(((b.sdo_cap_insoluto + (b.sdo_contab_mora + b.sdo_moratorio) * (select 1 + nvl(iva,0) from bdinteg:si_sucursales where empresa='001' and sucursal = cSuc)
			+ amo.campo_trabajo1 + case when b.int_tra_no_exig - b.sdo_int_anticip >= 0 then  b.int_tra_no_exig - b.sdo_int_anticip else b.int_tra_no_exig end) / monto_otorgado)*100,2)),0) 			
			INTO may_porc_uso6,utili,may_porc_usoProm
			FROM bdicred:sd_maesdoshist b
			LEFT OUTER JOIN bdicred:sd_amortiza_credito amo on amo.empresa = b.empresa and amo.num_credito = b.num_credito and amo.fecha_cuota = b.fecha
			WHERE b.fecha     BETWEEN p_FechaAnt12m AND pFechaHoyAumlincred
			AND b.empresa     = pEmpresa              
			AND b.num_credito = cNum_cred;
			
	 
	   
		  --RQM 09 407-2
		 --  IF NVL(may_porc_uso6,0) >= valorlinutilcred THEN --JMAH RQM 09 320							
		 IF NVL(may_porc_uso6,0) >= valorlinutilcred AND  NVL(may_porc_uso6,0) <=dPorcMaxUti THEN 	--RQM 09 407-2					
							 
				--validacion del pago minimo
				LET iFlagRtPagMin =0;
				FOREACH WITH HOLD
					SELECT fecha, monto_financiado
						INTO dtFechaPago,dPagoMin 
					FROM bdicred:"informix".sd_maesdoshist
					WHERE empresa        = pEmpresa
					AND num_credito    = cNum_cred	
					AND fecha BETWEEN p_FechaAnt4m AND pFechaHoyAumlincred 
					ORDER BY fecha DESC
					
					
					LET  dtFechaAux = monthadd (dtFechaPago,-1) + 1 units day;
					SELECT SUM(monto)
						INTO dPagado
					FROM bdicred:sd_movhis a
					WHERE a.empresa       = pEmpresa
					AND num_credito     = cNum_cred
					AND reversado       = 'N'					
					AND a.codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanual)		      
					AND fecha_mov BETWEEN dtFechaAux AND  dtFechaPago;

					IF dPagado <= dPagoMin  THEN
						LET iFlagRtPagMin= 1;
						EXIT FOREACH;
					END IF 
					
				END FOREACH;

				IF iFlagRtPagMin= 1 THEN 
					LET vStatus = "RT";
					LET vCausa  = "RPM";					--Se realiza cambio por incidencia 
					INSERT INTO bdicred:"informix".sd_bitacora_aumlincred(empresa, num_solicitud, numcte, num_producto, status, causa_status, fecha_status,           hora_status, sucursal, lincred_actual, lincred_sugerida, smb_lincred, grado_riesgo, monto_reserva, califica_buro, resp_cte, mensaje, ejecutivo, sucursal_at, origen, user_insert, fecha_insert, num_inc_prev, num_per_porutimay_806, num_per_porutimay_8012, medio_res, cte_noestit_p, cte_noestit_v, porc_uso, int_cred_ven, may_porc_uso6,prom_porc_uso12) 
					 VALUES(pEmpresa, cNum_cred   , cNumCte, numprod    , vStatus,       vCausa,   pFechaHoyAumlincred,     current,      cSuc,     dMontoOtor,                0,           0,      cRiesgo,  dMontoReserva,            '',      '',      '',        '',          '',    'C', cUser, pFechaHoyAumlincred, Incprev, utili, utili, '', 0, 0, porc_uso, int_cred_ven, may_porc_uso6,may_porc_usoProm);
					INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
					 VALUES(pEmpresa, cNum_cred, vStatus, vCausa, cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);
					CONTINUE FOREACH; 
				END IF 
				
				LET int_cred_ven		   = 0;

				SELECT fecha_vencto INTO dFechaVencto
				 FROM bdicred:sd_maecredanexo 
				WHERE empresa = pEmpresa AND num_credito  = cNum_cred;

				IF dFechaVencto IS NULL OR dFechaVencto = '' THEN LET dFechaVencto = DATE(1); END IF;

				IF dFechaVencto != DATE(1) THEN
					SELECT {+INDEX(sd_movhis inx_movhis)} sum(monto)
					INTO int_cred_ven
					FROM bdicred:sd_movhis mov
					WHERE mov.empresa = pEmpresa
					AND mov.fecha_mov = dFechaVencto
					AND mov.num_credito = cNum_cred
					AND mov.codigo_fun  = '605'
					AND mov.codigo_ref  = 2
					AND mov.reversado   = 'N';
			--        AND mov.fecha_mov = (SELECT fecha_vencto FROM bdicred:sd_maecredanexo 
			--                             WHERE empresa    = pEmpresa
			--                             AND num_credito  = cNum_cred)
				END IF;

		   
				--se obtiene el monto del incremento
				LET dLineaSugerida = round(dMontoOtor + (dMontoOtor * dAux0),-2);
				IF dLineaSugerida > sLineaCreditoMax THEN
					LET dLineaSugerida =sLineaCreditoMax;
				END IF
				LET smblinsug = dLineaSugerida / (30.42 * valorsm);
				--Si la línea sugerida es mayor a 10,000 (6 SM zona C aproximadamente) se va a consultar a Buró de Crédito				
				IF (dLineaSugerida >= sLineaCreditoBC) THEN --se compara en pesos y no en salarios mínimos
					LET vstatus     = "BC";
					LET dFechaCob   = DATE(1);
					
					EXECUTE PROCEDURE bdiburo:"informix".sp_generarespaldoshistoricosic_bc(cNumCte,vstatus)
					INTO cCodRet2,cMensajeRet2; 
					
				ELSE
				--Si la línea sugerida es mayor a 21,000 (12 SM zona C aproximadamente) se va a consultar al CAC
				   IF (dLineaSugerida >= sLineaCreditoCAC) THEN --se compara en pesos y no en salarios mínimos
					   LET vstatus     = "AC";					
					   LET dFechaCob   = DATE(1);
					ELSE
					   LET vstatus     = "AT";					   
					   LET dFechaCob = pFechaHoyAumlincred;
					END IF;
				END IF;					   
		     
					 --se inserta el registro de la precalificacion
				INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
					VALUES(pEmpresa, cNum_cred, "PC", "", cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);
				--se inserta el registro de la preautorización
				INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
					VALUES(pEmpresa, cNum_cred, vStatus, vCausa, cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);
				
				
		--se agrega validacion para ver si el cliente cuenta con incrementos automaticos, si es asi se manda llamar al procedimiento sp_registrarrespuestacte para simular la respuesta de autorizacion del cliente.
				IF cIncreAuto ='S' AND  vStatus= "AT" THEN
				
					LET cPregunta= "Autorizo expresamente a BanCoppel a incrementar mi linea de crédito a $" ||dLineaSugerida|| ", así mismo, acepto las nuevas condiciones y términos aplicables a partir de esta fecha.";
					LET cMedioRes = 'P';
					LET cEjecutivo = 'sistema';
					LET cRespCte = '1';
					LET vStatus     = "AP";
					LET vCausa      = "";
				--se inserta el registro de la autorización
				INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
						VALUES(pEmpresa, cNum_cred, vStatus, vCausa, cUser, today, pFechaHoyAumlincred, 0);
				END IF; 
				
				--se inserta el registro en la bitacora con el resultado final.
							
				INSERT INTO bdicred:"informix".sd_bitacora_aumlincred(empresa, num_solicitud, numcte, num_producto, status, causa_status,         fecha_status, hora_status, sucursal, lincred_actual, lincred_sugerida, smb_lincred, grado_riesgo, monto_reserva, califica_buro, resp_cte, mensaje, ejecutivo, sucursal_at, origen, user_insert, fecha_insert, num_inc_prev, num_per_porutimay_806, num_per_porutimay_8012, medio_res, cte_noestit_p, cte_noestit_v, porc_uso, int_cred_ven, may_porc_uso6,dfecha_cobranza,prom_porc_uso12) 
						VALUES(pEmpresa, cNum_cred   , cNumCte, numprod    , vStatus,       vCausa,   pFechaHoyAumlincred,    current,      cSuc,     dMontoOtor,dLineaSugerida, smblinsug,      cRiesgo, dMontoReserva, '', cRespCte, cPregunta,  '', '',    'C', cEjecutivo, pFechaHoyAumlincred, Incprev, utili, 'N/A', cMedioRes, 0, 0, porc_uso, int_cred_ven, may_porc_uso6,dFechaCob,may_porc_usoProm);
			   
				IF cIncreAuto ='S' AND  vStatus= "AP" THEN --se coloca aqui para que primero inserte el registro en la bitacora y despues se asigne el incremento.
			
					EXECUTE PROCEDURE bdicred:"informix".sp_grabarincrementolincred(pEmpresa, cNum_cred) INTO cCodRet, cMensajeRet;
					IF cCodRet <> "00000" THEN
						LET cCodRet = "00001";
						LET cMensajeRet = "Error al realizar incremento automático de línea para el crédito  " || cNum_cred;			
						RETURN cCodRet, cMensajeRet;
					END IF;
				END IF
				   CONTINUE FOREACH;										    		
            ELSE
               LET vStatus = "CN";
               LET vCausa  = "CUL";
               INSERT INTO bdicred:"informix".sd_bitacora_aumlincred(empresa, num_solicitud, numcte, num_producto, status, causa_status,         fecha_status, hora_status, sucursal, lincred_actual, lincred_sugerida, smb_lincred, grado_riesgo, monto_reserva, califica_buro, resp_cte, mensaje, ejecutivo, sucursal_at, origen, user_insert, fecha_insert, num_inc_prev, num_per_porutimay_806, num_per_porutimay_8012, medio_res, cte_noestit_p, cte_noestit_v, porc_uso, int_cred_ven, may_porc_uso6,prom_porc_uso12) 
                    VALUES(pEmpresa, cNum_cred   , cNumCte, numprod    , vStatus,       vCausa,   pFechaHoyAumlincred,    current,      cSuc,     dMontoOtor,                0,           0,      cRiesgo, dMontoReserva,            '',      '',      '',        '',          '',    'C', cUser, pFechaHoyAumlincred, Incprev, utili, 'N/A', '', 0, 0, porc_uso, int_cred_ven, may_porc_uso6,may_porc_usoProm);
               INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
                    VALUES(pEmpresa, cNum_cred, vStatus, vCausa, cUser, pFechaHoyAumlincred, pFechaHoyAumlincred, 0);
               CONTINUE FOREACH;
            END IF;
       
    END FOREACH;

    IF sCommit = -1 THEN
        COMMIT WORK;
    END IF;
    LET sCommit = 0;

    UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_bitacora_aumlincred;
    UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_autorizacion_aumlincred;
	 -- Elimina los creditos que no fueron considerados para el incremento de lcr (el proceso normal de incrementos los rechazo)
	/* DELETE FROM bdicred:"informix".sd_clientes_dirty_behavior WHERE month(fecha_reporte) = month(pFechaHoyAumlincred) 
        AND year(fecha_reporte) = year(pFechaHoyAumlincred) AND status_bit IS NULL;*/
		
    LET cMensajeRet            = "Se realizó la consulta correctamente";
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, cMensajeRet, '03') Returning cCod_RetIB;

    RETURN cCodRet, cMensajeRet;

END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener clientes prospectos para incremento de linea de crédito',
'de acuerdo a las validaciones propias de la empresa',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 09/JUNIO/2010',
'BD    : BDICRED',
'Se modifica para contemplar la nueva funcionalidad de incrementos automáticos para clientes que tengan activa esta opcion',
'MODIFICO : Jesús Manuel Aguilar Heredia',
'FECHA : 14/MARZO/2011',
'BD    : BDICRED',
'VERSION:20110314.1530',
'Se modifica para insertar campos agregados a tabla sd_bitacora_aumlincred y para obtener incrementos previos',
'MODIFICO : Rochin Rocha Edgar Ivan',
'FECHA : 27/JUNIO/2011',
'BD    : BDICRED',
'VERSION:20110627.1530',
'Se modifica para no contemplar TDC Garantizadas en el proceso de incrementos automáticos',
'MODIFICO : Jesús Manuel Aguilar Heredia',
'FECHA : 25/ENERO/2012',
'BD    : BDICRED',
'VERSION:20120125.1530',
'Se modifica para contemplar las solicitudes de incrementos automaticos desde sucursal',
'MODIFICO : Jesús Manuel Aguilar Heredia',
'FECHA : 14/NOVIEMBRE/2011',
'BD    : BDICRED',
'VERSION:20111114.1530';

CREATE PROCEDURE "informix".cons_sdos2(pempresa CHAR(3),
                            pcuenta  CHAR(20))

RETURNING CHAR(5)       AS cod_retorno,	     -- Codigo de Retorno
	      CHAR(20)      AS num_credito,	     -- Numero de Credito
 	      CHAR(20)      AS cta_captacion,	     -- Numero de Cueta de Ahorros
	      CHAR(10)      AS fecha_apertura,	     -- Fecha apertura
	      CHAR(10)      AS fecha_pago,	     -- Fecha de Pago
	      smallint      AS abono,      -- abono
          smallint      AS plazo,      -- plazo
          DECIMAL(14,2) AS capital_deudor, -- Monto del prestamo 
          DECIMAL(14,2) AS interes_reestructura, -- Monto del prestamo 
          DECIMAL(14,2) AS iva_reestructura, -- Monto del prestamo
	      DECIMAL(14,2) AS total_liquidacion, -- total liquidacion
          DECIMAL(14,2) AS pago_minimo;

   DEFINE vCodRet             CHAR(5);
   DEFINE sql_err             INTEGER;
   DEFINE vNumCte             CHAR(20);
   DEFINE vctaaho             CHAR(20);
   DEFINE vNombreCte          CHAR(60);
   DEFINE vSdoDisponible      DECIMAL(14,2);
   DEFINE vPagoMin            DECIMAL(14,2);
   DEFINE vdescuento          DECIMAL(14,2);
   DEFINE vauxiliar           DECIMAL(14,2);
   DEFINE vauxilia1           DECIMAL(14,2);
   DEFINE vFechaCorte         CHAR(10);
   DEFINE vFechaPago          CHAR(10);
   DEFINE vFechaApert         CHAR(10);
   DEFINE vDisponible         DECIMAL(14,2);
   DEFINE vSdoRetenido        DECIMAL(14,2);
   define vSucursal           char(4);
   define vPorcIva            decimal(14,2);
   define vMoraConIva         decimal(14,2);
   define vabono              smallint;
   define vtotabono           smallint;
   DEFINE vFechaHoy           DATE;
   DEFINE vsec                SMALLINT;
   DEFINE vDireccion          CHAR(80);
   DEFINE vMtoCuota           decimal(14,2);
   DEFINE vIvaSuc             CHAR(5);

   -- SOLO SE DEFINEN PARA LA UTILIZACION DEL sp_consulta_saldos_general
   DEFINE pMensaje              CHAR(80);
   DEFINE pCodTipCred           CHAR(2);
   DEFINE pFechaProxPago        DATE;
--   DEFINE pPagosRealizados      INTEGER;
   DEFINE pTasaInteres          DECIMAL(9,6);
   DEFINE pTasaMoratorios       DECIMAL(9,6);
   DEFINE pMontoSBC             DECIMAL(14,2);
   DEFINE pCapVig               DECIMAL(18,2);
   DEFINE pCapTrans             DECIMAL(18,2);
   DEFINE pCapVdoExig           DECIMAL(18,2);
   DEFINE pCapVdoNoExig         DECIMAL(18,2);
   DEFINE pSdoActCap            DECIMAL(18,2);
   DEFINE pIntVig               DECIMAL(18,2);
   DEFINE pIntVdo               DECIMAL(18,2);
   DEFINE pIntMoratorio         DECIMAL(18,2);
   DEFINE pIntMes               DECIMAL(18,2);
   DEFINE pSdoActInt            DECIMAL(18,2);
   DEFINE pIvaIntVig            DECIMAL(18,2);
   DEFINE pIvaIntVdo            DECIMAL(18,2);
   DEFINE pIvaIntMoratorio      DECIMAL(18,2);
   DEFINE pIvaIntMes            DECIMAL(18,2);
   DEFINE pSdoActIvaInt         DECIMAL(18,2);
   DEFINE pComPend              DECIMAL(18,2);
   DEFINE pIvaCom               DECIMAL(18,2);
   DEFINE pSdoRetenido          DECIMAL(18,2);
   DEFINE pIntDevengado         DECIMAL(18,2);
   DEFINE pIvaIntDevengado      DECIMAL(18,2);
   DEFINE pLineaDisponible      DECIMAL(18,2);
   DEFINE pPagosVdos            DECIMAL(18,2);
   DEFINE pDescStatusCred       CHAR(60);
   DEFINE pIdUnidadProd         INTEGER;
   DEFINE pDescBloqueoCta       CHAR(60);
   DEFINE pCodCaract2           CHAR(3);
   DEFINE pDescCausaBloqueoCta  CHAR(50);
   DEFINE pSitCte               CHAR(1);
   DEFINE pCausaCte             INTEGER;
   DEFINE pDescSitEspCte        CHAR(75);
   DEFINE pSitCred              CHAR(1);
   DEFINE pCausaCred            INTEGER;
   DEFINE pDescSitEspCred       CHAR(75);

---INI CAS
   DEFINE pinterestotal         DECIMAL(18,2); 
   DEFINE pivatotal             DECIMAL(18,2); 
   DEFINE pcapitaltotal         DECIMAL(18,2); 
--FIN CAS

    DEFINE vind_cierre          CHAR(1);
    DEFINE vind_disponible      CHAR(1);

--- Inicializa Variables de Salida
    LET vCodRet        = "000";
    LET vSdoDisponible = 0;
    LET vNumCte        = " ";
    LET vNombreCte     = " ";
    LET vPagoMin       = 0;
    LET vFechaCorte    = "";
    LET vFechaPago     = "";
    LET vFechaApert    = "";
    LET vDisponible    = 0;
    LET vSdoRetenido   = 0;
    Let vSucursal      = '0000';
    Let vPorcIva       = 0;
    Let vMoraConIva    = 0;
    let vdescuento     = 0;
    let vabono         = 0;
    let vtotabono      = 0;
    let vctaaho        = "";
    let vFechaHoy      = "";
    LET vsec           = 0;
    LET vDireccion     = "";
    LET vMtoCuota      = 0;

   -- SOLO SE DECLARA PARA LA UTILIZACION DEL sp_consulta_saldos_general
    LET pMensaje              = "";
    LET pCodTipCred           = "";
    LET pFechaProxPago        = DATE(1);
--    LET pPagosRealizados      = 0;
    LET pTasaInteres          = 0;
    LET pTasaMoratorios       = 0;
    LET pMontoSBC             = 0;
    LET pCapVig               = 0;
    LET pCapTrans             = 0;
    LET pCapVdoExig           = 0;
    LET pCapVdoNoExig         = 0;
    LET pSdoActCap            = 0;
    LET pIntVig               = 0;
    LET pIntVdo               = 0;
    LET pIntMoratorio         = 0;
    LET pIntMes               = 0;
    LET pSdoActInt            = 0;
    LET pIvaIntVig            = 0;
    LET pIvaIntVdo            = 0;
    LET pIvaIntMoratorio      = 0;
    LET pIvaIntMes            = 0;
    LET pSdoActIvaInt         = 0;
    LET pComPend              = 0;
    LET pIvaCom               = 0;
    LET pSdoRetenido          = 0;
    LET pIntDevengado         = 0;
    LET pIvaIntDevengado      = 0;
    LET pLineaDisponible      = 0;
    LET pPagosVdos            = 0;
    LET pDescStatusCred       = '';
    LET pIdUnidadProd         = 0;
    LET pDescBloqueoCta       = '';
    LET pCodCaract2           = '';
    LET pDescCausaBloqueoCta  = '';
    LET pSitCte               = '';
    LET pCausaCte             = 0;
    LET pDescSitEspCte        = '';
    LET pSitCred              = '';
    LET pCausaCred            = 0;
    LET pDescSitEspCred       = '';
    LET pinterestotal         = 0;
    LET pivatotal             = 0;
    LET pcapitaltotal         = 0;
    LET vind_cierre           = '0';
    LET vind_disponible       = '0';

BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET vCodRet = sql_err;
         RETURN vCodRet,pcuenta,vctaaho,vFechaApert,vFechaPago,vabono,vtotabono,pcapitaltotal,pinterestotal,pivatotal,vDisponible,vPagoMin;
      END IF;
   END EXCEPTION;

SET ISOLATION TO DIRTY READ ;
SET LOCK MODE TO WAIT 3 ;

 --  set debug file to "/tmp/cons_sdos2.out";
 --  trace on;
--SE OBTIENE EL I.V.A DE SD_PARAM
   SELECT TRIM(valor) INTO vIvaSuc FROM sd_param
   WHERE cod_param = "12"
   AND empresa = pempresa;


   SELECT fecha_hoy, ind_cierre, ind_disponible
     INTO vFechaHoy, vind_cierre, vind_disponible
     FROM sd_fechas;
     
    IF vind_cierre = '0' OR vind_disponible = '0' THEN
        LET vCodRet = "040";
        RETURN vCodRet,pcuenta,vctaaho,vFechaApert,vFechaPago,vabono,vtotabono,pcapitaltotal,pinterestotal,pivatotal,vSdoDisponible,vPagoMin;
    END IF;
    
   LET pcuenta = pcuenta;
   LET pempresa = pempresa;
    
   SELECT numcte
   INTO   vNumCte
   FROM   sd_maecredcrd
   WHERE  empresa = pempresa
   AND    num_credito = pcuenta;

   IF vNumCte IS NULL THEN
      LET vCodRet ="004";
         RETURN vCodRet,pcuenta,vctaaho,vFechaApert,vFechaPago,vabono,vtotabono,pcapitaltotal,pinterestotal,pivatotal,vSdoDisponible,vPagoMin;
   end if;

   IF pcuenta IS NULL OR LENGTH(pcuenta) = 0 THEN
      LET vCodRet ="004";
         RETURN vCodRet,pcuenta,vctaaho,vFechaApert,vFechaPago,vabono,vtotabono,pcapitaltotal,pinterestotal,pivatotal,vSdoDisponible,vPagoMin;
   END IF

   select num_cta into vctaaho
   from   bdicred:sd_ctascarg
   where  num_credito = pcuenta;


        EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(pempresa , pcuenta)
                INTO      vCodRet,              --CHAR(6)       AS codigo_retorno,
                          pMensaje,             --CHAR(80)      AS mensaje_retorno,
                          pcuenta,              --CHAR(20)      AS numero_credito,
                          pCodTipCred,          --CHAR(2)       AS codigo_tipcred,
                          vFechaApert,          --DATE          AS fecha_origen,
                          vFechaPago    ,       --DATE          AS fecha_prox_pago,
                          vPagoMin,             --DECIMAL(18,2) AS pago_minimo,
                          vFechaPago,           --DATE          AS fecha_ult_pago,
                          vtotabono,            --INTEGER       AS plazo,
                          vabono,               --INTEGER       AS pagos_realizados,
                          vDisponible,          --DECIMAL(18,2) AS linea_otorgada,
                          pTasaInteres,         --DECIMAL(9,6)  AS tasa_interes,
                          pTasaMoratorios,      --DECIMAL(9,6)  AS tasa_moratorios,
                          pMontoSBC,            --DECIMAL(14,2) AS monto_sbc,
                          pCapVig,              --DECIMAL(18,2) AS cap_vig,
                          pCapTrans,            --DECIMAL(18,2) AS cap_trans,
                          pCapVdoExig,          --DECIMAL(18,2) AS cap_vdo_exig,
                          pCapVdoNoExig,        --DECIMAL(18,2) AS cap_vdo_no_exig,
                          pSdoActCap,           --DECIMAL(18,2) AS sdo_act_total_cap,
                          pIntVig,              --DECIMAL(18,2) AS int_vig,
                          pIntVdo,              --DECIMAL(18,2) AS int_vdo,
                          pIntMoratorio,        --DECIMAL(18,2) AS int_moratorios,
                          pIntMes,              --DECIMAL(18,2) AS int_mes,
                          pSdoActInt,           --DECIMAL(18,2) AS sdo_act_total_int,
                          pIvaIntVig,           --DECIMAL(18,2) AS iva_int_vig,
                          pIvaIntVdo,           --DECIMAL(18,2) AS iva_int_vdo,
                          pIvaIntMoratorio,     --DECIMAL(18,2) AS iva_int_moratorios,
                          pIvaIntMes,           --DECIMAL(18,2) AS iva_int_mes,
                          pSdoActIvaInt,        --DECIMAL(18,2) AS sdo_act_total_iva,
                          pComPend,             --DECIMAL(18,2) AS com_pend,
                          pIvaCom,              --DECIMAL(18,2) AS iva_com,
                          pSdoRetenido,         --DECIMAL(18,2) AS sdo_retenido,
                          vSdoDisponible,       --DECIMAL(18,2) AS total_liquidacion,
                          pIntDevengado,        --DECIMAL(18,2) AS int_devengado,
                          pIvaIntDevengado,     --DECIMAL(18,2) AS iva_int_devengado,
                          pLineaDisponible,     --DECIMAL(18,2) AS linea_disponible,
                          pPagosVdos,           --DECIMAL(18,2) AS pagos_vdos,
                          pDescStatusCred,      --CHAR(60)      AS desc_status_cred,
                          pIdUnidadProd,        --INTEGER       AS id_bloqueo_cred,
                          pDescBloqueoCta,      --CHAR(60)      AS bloqueo_cta,
                          pCodCaract2,          --CHAR(3)       AS id_causa_bloqueo_cred,
                          pDescCausaBloqueoCta, --CHAR(50)      AS causa_bloqueo_cta,
                          pSitCte,              --CHAR(1)       AS id_sit_esp_cte,
                          pCausaCte,            --INTEGER       AS id_causa_esp_cte,
                          pDescSitEspCte,       --CHAR(75)      AS sit_esp_cte,
                          pSitCred,             --CHAR(1)       AS id_sit_esp_cred,
                          pCausaCred,           --INTEGER       AS id_causa_esp_cred,
                          pDescSitEspCred;      --CHAR(75)      AS sit_esp_cred;

    LET pinterestotal         = pIntVig + pIntVdo + pIntMes + pIntDevengado;
    LET pivatotal             = pIvaIntVig + pIvaIntVdo + pIvaIntMes + pIvaIntDevengado;
    LET pcapitaltotal         = pSdoActCap;

    select fecha_vencim 
      into vFechaPago
      from bdicred:sd_maecredcrd
     where empresa=pempresa
       and num_credito=pcuenta;

         RETURN vCodRet,pcuenta,vctaaho,vFechaApert,vFechaPago,vabono,vtotabono,pcapitaltotal,pinterestotal,pivatotal,vSdoDisponible,vPagoMin;

END
END PROCEDURE
DOCUMENT
'Consulta de Saldos y Pago minimo en plataforma',
'FECHA : 04/Mayo/2009',
'VERSION: 1.00.000',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_carga_ctes_clean_behavior(pEmpresa CHAR(3))

RETURNING 
          CHAR(06) AS resultado,    CHAR(80) AS mensaje;
--GEV 201502 Proceso para realizar la carga del archivo de ctes clean behavior.

DEFINE vproceso         CHAR(4);
DEFINE cCod_RetIB       CHAR(6);
DEFINE dFechaHoy        DATE;
DEFINE dFechaAumLinCrd  DATE;
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      CHAR(80);
DEFINE cRutaArch        CHAR(100);
DEFINE cParamNomArch    CHAR(100);
DEFINE cNomArchivo      CHAR(150);
DEFINE cNomArchivo2		CHAR(150);
DEFINE cNomArchEjecSql  CHAR(100);
DEFINE cSQL             CHAR(1500);
DEFINE vDiaRegistro		SMALLINT;

DEFINE cArchivo_dbld	CHAR(50);
DEFINE cArchivo_log		CHAR(50);
DEFINE cArchivo_out		CHAR(50);


--	SET DEBUG FILE TO "/respaldos/Israel/sp_carga_ctes_clean_behavior.out";
--	TRACE ON;

LET vproceso        = '3402';
LET cCod_RetIB      = '000000';
LET dFechaHoy       = DATE(0); 
LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = '000000';
LET cMensajeRet     = 'PROCESO EXITOSO';    
LET cRutaArch       = '';
LET cNomArchivo     = '';
LET cNomArchivo2	= '';
LET cNomArchEjecSql = '';
LET cSQL            = '';
LET vDiaRegistro	= 0;

LET cArchivo_dbld	= "f_datosctes_clean.cmd";
LET cArchivo_log	= "f_datosctes_clean.log";
LET cArchivo_out	= "f_datosctes_clean.out";

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        LET cCodRet = iSqlErr;
        LET cMensajeRet = cErrorInfo;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, trim(cMensajeRet) || "-" || iIsamErr::CHAR, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO WAIT 3;

    CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '01') Returning cCod_RetIB;

    IF ( NVL(pEmpresa,"") = "" ) THEN
        LET cCodRet= '102005'; 
        SELECT descripcion INTO cMensajeRet
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
	END IF;

    SELECT fecha_hoy INTO dFechaHoy FROM bdicred:sd_fechas WHERE empresa = pempresa;
    IF ( dFechaHoy IS NULL ) THEN
        LET cCodRet= '20013'; 
        SELECT descripcion INTO cMensajeRet
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
	END IF;

--IPCB Dic2015 se cambia la extracciÃÂ³n de fecha de la sd_fechas_aumlincred x sd_fechas, manejando como constante el dia 10 a lo largo del mes
	SELECT valor::SMALLINT INTO vDiaRegistro
	  FROM bdicred:"informix".sd_param 
	 WHERE cod_param = '049' AND empresa   = pEmpresa;
 
    --SELECT fecha_hoy INTO dFechaAumLinCrd FROM bdicred:"informix".sd_fechas_aumlincred  WHERE empresa = pEmpresa;
	SELECT mdy(month(fecha_hoy),vDiaRegistro, year(fecha_hoy)) INTO dFechaAumLinCrd  FROM bdicred:"informix".sd_fechas WHERE empresa = pEmpresa;
    IF dFechaAumLinCrd IS NULL OR dFechaAumLinCrd = date(1) OR dFechaAumLinCrd = date(0) THEN
        LET dFechaAumLinCrd = dFechaHoy;
    END IF
	
    SELECT trim(valor) INTO cParamNomArch FROM bdicred:sd_param WHERE cod_param = 107;
    IF ( NVL(cParamNomArch, "") = "" ) THEN
        LET cCodRet= '104006';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT trim(valor) INTO cRutaArch  FROM bdicred:sd_param WHERE cod_param = 103;
	
    IF ( NVL(cRutaArch, "") = "" ) THEN
        LET cCodRet = '104005';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END IF;
	

    LET cNomArchivo = trim(cParamNomArch) || lpad(month(dFechaHoy),2,'0') || lpad(year(dFechaHoy),4,'0') || '.txt';
	LET cNomArchivo2 = trim(cParamNomArch) || lpad(month(dFechaHoy),2,'0') || lpad(year(dFechaHoy),4,'0') || '_2.txt';

	system ' echo "FILE ' ||TRIM(cRutaArch) ||  TRIM(cNomArchivo2) ||' DELIMITER '|| "'" || '|' || "'" || ' 9;' || '">' || TRIM(cRutaArch) || TRIM(cArchivo_dbld);  
	system ' echo "INSERT INTO sd_clientes_clean_behavior;' || '">>' || TRIM(cRutaArch) || TRIM(cArchivo_dbld);
	system 'chmod 777 ' ||TRIM(cRutaArch) || TRIM(cArchivo_dbld);

	system ' echo "cat ' ||TRIM(cRutaArch) || TRIM(cNomArchivo) || ' | sed ' || "'" ||'s/ //g'|| "'" ||' | cut -d\| -f1,2 | awk -F \"|\" '|| "'" ||'{if(NF>0) print \"'||dFechaHoy|| '|\"'||'\$1'|| '\"|\"' ||'\$2\"'||'|||||||\"}'|| "'" ||' > '|| TRIM(cRutaArch)|| TRIM(cNomArchivo2)||';'|| '">' || TRIM(cRutaArch) || 'dbload_clean.sh';	
	system ' echo "date | tee -a ' ||TRIM(cRutaArch) || TRIM(cArchivo_out) || '">>' || TRIM(cRutaArch) || 'dbload_clean.sh';
	system ' echo "dbload -d bdicred -c '||TRIM(cRutaArch)|| TRIM(cArchivo_dbld)||' -l '||TRIM(cRutaArch)||TRIM(cArchivo_log)||' -e 20000000 -n 1000 -k | tee -a '||TRIM(cRutaArch) || TRIM(cArchivo_out) || '">>' || TRIM(cRutaArch)|| 'dbload_clean.sh'; 
	system ' echo "date | tee -a ' ||TRIM(cRutaArch) || TRIM(cArchivo_out) || '">>' || TRIM(cRutaArch) || 'dbload_clean.sh';       
	system 'chmod 777 ' || TRIM(cRutaArch)|| 'dbload_clean.sh';
	system TRIM(cRutaArch)|| 'dbload_clean.sh';


    CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '03') Returning cCod_RetIB;

    RETURN cCodRet,cMensajeRet;

END
END PROCEDURE;
CREATE PROCEDURE "informix".sp_cons_credisoluciones (pEmpresa CHAR(3), pTarjeta CHAR(20), pRegistros INT, pTransacc INT)
RETURNING CHAR (5)      AS CodRet,
		  DATE          AS Fecha,
		  CHAR (50)     AS NombrePromo,
		  CHAR (20)     AS NumSolPrestamo,
		  DECIMAL(18,2) AS MontoActual,
		  DECIMAL(18,2) AS TotalLiquidacion,
		  DECIMAL(18,2) AS IntDevengado,
		  DATE          AS FechaProxPago,
		  CHAR (4)      AS NumProducto;


		--DECLARACION DE VARIABLES
        DEFINE iSqlErr           INT;
		DEFINE cCodRet           CHAR(5);
        DEFINE dFecha            DATE;
		DEFINE cNombrePromo      CHAR(50);
		DEFINE cNumSolPres       CHAR(20);
		DEFINE dMontoActual      DECIMAL(18,2);
		DEFINE dFecha2           DATE;
		DEFINE cNombrePromo2     CHAR(50);
		DEFINE cNumSolPres2      CHAR(20);
		DEFINE dMontoActual2     DECIMAL(18,2);
		DEFINE dLiquidacion      DECIMAL(18,2);
		DEFINE dDevengado        DECIMAL(18,2);
		DEFINE dFechaProxPa      DATE;
		DEFINE cNumProducto      CHAR(4);
		DEFINE cNumProducto2     CHAR(4);
		DEFINE cNumCredito       CHAR(20);
		DEFINE cNumCredito2      CHAR(20);
		DEFINE iBandCon          INT;
		DEFINE iBandEst          INT;
		DEFINE iBandExp          INT;
		DEFINE iLimit            INT;
	    ---------------------------------------
		DEFINE CodRet2           CHAR(6);
		DEFINE MenRet            CHAR(80);
		DEFINE NumCred           CHAR(20);
		DEFINE CodTipCred        CHAR(2);
		DEFINE FechaOrigen       DATE;
		DEFINE PagoMinimo        DECIMAL(18,2);
		DEFINE FechaUltPago      DATE;
		DEFINE Plazo             INTEGER;
		DEFINE PagosRealizados   INTEGER;
		DEFINE LineaOtorgada     DECIMAL(18,2);
		DEFINE TasaInteres       DECIMAL(9,6);
		DEFINE TasaMoratorios    DECIMAL(9,6);
		DEFINE Montosbc          DECIMAL(14,2);
		DEFINE CapVig            DECIMAL(18,2);
		DEFINE CapTrans          DECIMAL(18,2);
		DEFINE CapVdoExig        DECIMAL(18,2);
		DEFINE CapVdoNoExig      DECIMAL(18,2);
		DEFINE SdoActTotalCap    DECIMAL(18,2);
		DEFINE IntVig            DECIMAL(18,2);
		DEFINE IntVdo            DECIMAL(18,2);
		DEFINE IntMoratorios     DECIMAL(18,2);
		DEFINE IntMes            DECIMAL(18,2);
		DEFINE SdoActTotalInt    DECIMAL(18,2);
		DEFINE IvaIntVig         DECIMAL(18,2);
		DEFINE IvaIntVdo         DECIMAL(18,2);
		DEFINE IvaIntMoratorios  DECIMAL(18,2);
		DEFINE IvaIntMes         DECIMAL(18,2);
		DEFINE SdoActTotalIva    DECIMAL(18,2);
		DEFINE ComPend           DECIMAL(18,2);
		DEFINE IvaCom            DECIMAL(18,2);
		DEFINE SdoRetenido       DECIMAL(18,2);
		DEFINE IvaIntDevengado   DECIMAL(18,2);
		DEFINE IvaIntNoDevengado DECIMAL(18,2);
		DEFINE LineaDisponible   DECIMAL(18,2);
		DEFINE PagosVdos         DECIMAL(18,2);
		DEFINE DescStatusCred    CHAR(60);
		DEFINE IdBloqueoCred     INTEGER;
		DEFINE BloqueoCta        CHAR(60);
		DEFINE IdCausaBloqCred   CHAR(3);
		DEFINE CausaBloqueoCta   CHAR(50);
		DEFINE IdSitEspCte       CHAR(1);
		DEFINE IdCausaEspCte     INTEGER;
		DEFINE SitEspCte         CHAR(75);
		DEFINE IdSitEspCred      CHAR(1);
		DEFINE IdCausaEspCred    INTEGER;
		DEFINE SitEspCred        CHAR(75);

		--INICIALIZACIÒN DE VARIABLES
        LET iSqlErr          = 0;
		LET cCodRet          = '00000';
        LET dFecha           = DATE(1);
		LET cNombrePromo     = '';
		LET cNumSolPres      = '';
		LET dMontoActual     = 0.00;
		LET dFecha2          = DATE(1);
		LET cNombrePromo2    = '';
		LET cNumSolPres2     = '';
		LET dMontoActual2    = 0.00;
		LET dLiquidacion     = 0.00;
		LET dDevengado       = 0.00;
		LET dFechaProxPa     = DATE(1);
		LET cNumProducto     = '';
		LET cNumProducto2    = '';
		LET cNumCredito      = '';
		LET cNumCredito2     = '';
		LET iBandCon         = 0;
		LET iBandEst         = 0;
		LET iBandExp         = 0;
		LET iLimit           = 20;
		---------------------------------------
		LET CodRet2          = '';
		LET MenRet           = '';
		LET NumCred          = '';
		LET CodTipCred       = '';
		LET FechaOrigen      = DATE(1);
		LET PagoMinimo       = 0.00;
		LET FechaUltPago     = DATE(1);
		LET Plazo            = 0;
		LET PagosRealizados  = 0;
		LET LineaOtorgada    = 0.00;
		LET TasaInteres      = 0.00;
		LET TasaMoratorios   = 0.00;
		LET Montosbc         = 0.00;
		LET CapVig           = 0.00;
		LET CapTrans         = 0.00;
		LET CapVdoExig       = 0.00;
		LET CapVdoNoExig     = 0.00;
		LET SdoActTotalCap   = 0.00;
		LET IntVig           = 0.00;
		LET IntVdo           = 0.00;
		LET IntMoratorios    = 0.00;
		LET IntMes           = 0.00;
		LET SdoActTotalInt   = 0.00;
		LET IvaIntVig        = 0.00;
		LET IvaIntVdo        = 0.00;
		LET IvaIntMoratorios = 0.00;
		LET IvaIntMes        = 0.00;
		LET SdoActTotalIva   = 0.00;
		LET ComPend          = 0.00;
		LET IvaCom           = 0.00;
		LET SdoRetenido      = 0.00;
		LET IvaIntDevengado  = 0.00;
		LET LineaDisponible  = 0.00;
		LET PagosVdos        = 0.00;
		LET DescStatusCred   = '';
		LET IdBloqueoCred    = 0;
		LET BloqueoCta       = '';
		LET IdCausaBloqCred  = '';
		LET CausaBloqueoCta  = '';
		LET IdSitEspCte      = '';
		LET IdCausaEspCte    = 0;
		LET SitEspCte        = '';
		LET IdSitEspCred     = '';
		LET IdCausaEspCred   = 0;
		LET SitEspCred       = '';
		LET IvaIntNoDevengado= 0.00;



BEGIN

	ON EXCEPTION SET iSqlErr
			IF (iSqlErr != 0) then
				LET cCodRet = CAST(iSqlErr AS CHAR);
				RETURN  cCodRet, dFecha, cNombrePromo, cNumSolPres, dMontoActual, dLiquidacion, dDevengado, dFechaProxPa, cNumProducto WITH RESUME;
			END IF;
	END EXCEPTION;

--SET DEBUG FILE TO '/respaldosbd/Efrain/188-lib29/sp_cons_credisoluciones.out';
--TRACE ON;
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;


	IF TRIM(NVL(pEmpresa,'')) <> '' AND TRIM(NVL(pTarjeta,'')) <> '' THEN

			SELECT numcuenta
				INTO cNumCredito2
			FROM intercard: "informix".tarjetacuenta
			where numtarjeta = pTarjeta;

		FOREACH
			SELECT SKIP pRegistros LIMIT iLimit
			fecha, nombre_promo, num_sol_prestamo, monto_actual,monto_int_iva, num_pro_prestamo
			INTO dFecha2, cNombrePromo2, cNumSolPres2, dMontoActual2, IvaIntNoDevengado, cNumProducto2
			FROM bdicred:"informix".sd_promocion_credito
			WHERE empresa = pEmpresa
			AND num_credito = cNumCredito2
			AND num_pro_prestamo = '6900'
			AND status = 2
			AND monto_actual > 0

			LET iBandCon = 1;

			IF pTransacc = 2 then		--  pTransacc = 1 (618-pago),  2 (619-consulta)
				SELECT num_credito
				INTO cNumCredito
				FROM  bdicred:"informix".sd_maecred
				WHERE empresa = pEmpresa
				AND num_credito = cNumCredito2;
			ELSE
				SELECT a.num_credito
				INTO cNumCredito
				FROM  bdicred:"informix".sd_maecred a 
				INNER JOIN bdicred:"informix".sd_maesdos b ON (a.num_credito = b.num_credito)
				WHERE a.empresa = pEmpresa
				AND a.num_credito = cNumCredito2
				AND a.status_cred IN ('AA','E1')
				AND (b.monto_vencido + b.mto_venc_trasp) = 0;
			END IF;


			IF dbinfo("sqlca.sqlerrd2") = 1 THEN

				LET iBandEst = 1;

				EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(pEmpresa, cNumSolPres2)
				INTO CodRet2, MenRet, NumCred, CodTipCred, FechaOrigen, dFechaProxPa, PagoMinimo, FechaUltPago, Plazo, PagosRealizados,
					LineaOtorgada, TasaInteres, TasaMoratorios, Montosbc, CapVig, CapTrans, CapVdoExig, CapVdoNoExig, SdoActTotalCap,
					IntVig, IntVdo, IntMoratorios, IntMes, SdoActTotalInt, IvaIntVig, IvaIntVdo, IvaIntMoratorios, IvaIntMes, SdoActTotalIva,
					ComPend, IvaCom, SdoRetenido, dLiquidacion, dDevengado, IvaIntDevengado, LineaDisponible, PagosVdos, DescStatusCred,
					IdBloqueoCred, BloqueoCta, IdCausaBloqCred, CausaBloqueoCta, IdSitEspCte, IdCausaEspCte, SitEspCte, IdSitEspCred,
					IdCausaEspCred, SitEspCred;

				IF  CodRet2 = '000000' THEN

					LET iBandExp      = 1;
					LET dFecha        = dFecha2;
					LET cNombrePromo  = cNombrePromo2;
					LET cNumSolPres   = cNumSolPres2;
					LET dMontoActual  = dMontoActual2;
					LET cNumProducto  = cNumProducto2;

					LET dDevengado = dDevengado + IvaIntDevengado+IntVig+IvaIntVig;
					--AAME Se agrega variable para obtener intereses no devengados
					LET IvaIntNoDevengado = IvaIntNoDevengado - dDevengado;

					RETURN cCodRet, NVL(dFecha, DATE(1)), NVL(cNombrePromo,''), NVL(cNumSolPres,''), NVL(dMontoActual,0.00), NVL(dLiquidacion,0.00), NVL(IvaIntNoDevengado,0.00), NVL(dFechaProxPa, DATE(1)), NVL(cNumProducto,'') WITH RESUME;

				END IF;

			END IF;

			LET dFecha        = DATE(1);
			LET cNombrePromo  = '';
			LET cNumSolPres   = '';
			LET dMontoActual  = 0.00;
			LET cNumProducto = '';
			LET dFecha2       = DATE(1);
			LET cNombrePromo2 = '';
			LET cNumSolPres2  = '';
			LET dMontoActual2 = 0.00;
			LET cNumProducto2 = '';

		END FOREACH;

		IF iBandCon = 0 THEN
			LET cCodRet = '00002';
		ELSE
			IF iBandEst = 0 THEN
				LET cCodRet = '00003';
			ELSE
				IF iBandExp = 0 THEN
					LET cCodRet = '00004';
				END IF;
			END IF;
		END IF;
	ELSE
		LET cCodRet = '00001';
	END IF;
	IF cCodRet <> '00000' THEN
		RETURN cCodRet, NVL(dFecha,DATE(1)), NVL(cNombrePromo,''), NVL(cNumSolPres,''), NVL(dMontoActual,0.00), NVL(dLiquidacion,0.00), NVL(dDevengado,0.00), NVL(dFechaProxPa, DATE(1)), NVL(cNumProducto,'') WITH RESUME;
	END IF;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: llena grid de credisoluciones en BCSCJ0010024',
'00000 - Èxito',
'00001 - Error en Parametros de Entrada',
'00002 - No se encontró información',
'00003 - No Hay Creditos AA Activo',
'00004 - sp_consulta_saldos_general Tubo un Error',
'AUTOR : Felipe Urias',
'FECHA : 19/11/2015',
'BD    : bdicred',
'----------------------------------------------------------------------------',
'Descripcion : Se modifica para que realice consultas de cualquier tipo de credisoluciones',
'Modifico    : 95451706 - Efrain Miranda',
'Fecha       : 08/003/2017',
'BD          : bdicred';

CREATE PROCEDURE "informix".sp_conscreportnom_bpi(pNumCte CHAR(20), pNumCta CHAR(20))
											  
-- DESCRIPCIÃN 	: Se crea SP para identificar si la cuenta de nÃ³mina BanCoppel cuenta con algÃºn producto de 
--					PrÃ©stamo Directo de NÃ³mina y/o Anticipo de NÃ³mina en estatus Activo, Vigente y/o con Adeudo.
-- AUTOR		: Keevyn Adrian Gil Valenzuela
-- FECHA 		: 09/01/2017
-- BD    		: BDICRED


	-- Retornos
	RETURNING
		CHAR(6);

	-- Declarar variables 
	DEFINE cCodRet 				CHAR(6);
	DEFINE iSql_err 			INTEGER;
	
	DEFINE cNumSoliAnticipo		CHAR(20);
	DEFINE cNumSoliPrestamo		CHAR(20);
	DEFINE cStatusCredAnticipo 	CHAR(2);
	DEFINE cStatusCredPrestamo 	CHAR(2);
	DEFINE cMto6400				DECIMAL(18,2);
	DEFINE cMto7800				DECIMAL(18,2);
	
	-- AsignaciÃ³n
	LET cCodRet = "00000";
	LET iSql_err = 0;
	LET cNumSoliAnticipo = "";
	LET cNumSoliPrestamo = "";
	LET cStatusCredAnticipo = "";
	LET cStatusCredPrestamo = "";
	LET cMto6400			= 0;
	LET cMto7800			= 0;


	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				let cCodRet = iSql_err;
				RETURN cCodRet;
			END IF;
		END EXCEPTION ;
		
		SET LOCK MODE TO WAIT 3;
		
	--	SET DEBUG FILE TO "/sp_conscreportnom_bpi.out";
	--	TRACE ON;
		
		SELECT num_solicitud INTO cNumSoliPrestamo FROM bdisolic:"informix".ss_sol_nomina WHERE numcte = pNumCte AND cuenta = pNumCta; --6400
		SELECT num_solicitud INTO cNumSoliAnticipo FROM bdisolic:"informix".ss_adn_solicitudcuenta WHERE numcte = pNumCte AND cuenta_nomina = pNumCta; --7800
				
		IF TRIM(cNumSoliPrestamo) != "" OR TRIM(cNumSoliPrestamo) IS NOT NULL OR TRIM(cNumSoliAnticipo) != "" OR TRIM(cNumSoliAnticipo) IS NOT NULL THEN
			
			-- Producto 6400 (PrÃ©stamo Directo de NÃ³mina)
		   SELECT a.status_cred, NVL(b.monto_vencido + b.mto_venc_trasp,0)
			 INTO cStatusCredPrestamo, cMto6400 
			 FROM bdicred:"informix".sd_maecredcrd a 
			 INNER JOIN bdicred:"informix".sd_maesdoscrd b ON (a.num_credito = b.num_credito) 
			WHERE a.num_producto = "6400" 
			  AND a.numcte = pNumCte 
			  AND a.num_credito = cNumSoliPrestamo;
			
			-- Producto 7800 (Anticipo de NÃ³mina)
		   SELECT a.status_cred, NVL(b.monto_vencido + b.mto_venc_trasp,0) 
			 INTO cStatusCredAnticipo, cMto7800 
			 FROM bdicred:"informix".sd_maecred a 
			INNER JOIN bdicred:"informix".sd_maesdos b ON (a.num_credito = b.num_credito)
			WHERE a.num_producto = "7800" 
			  AND a.numcte = pNumCte 
			  AND a.num_credito = cNumSoliAnticipo;
			
			IF cStatusCredPrestamo IN ("AA","E1") AND cStatusCredAnticipo IN ("AA","E1") AND (cMto6400 + cMto7800) = 0  THEN -- Anticipo y PrÃ©stamo Activos (6400 Y 7800)
				LET cCodRet = "00002";
			ELIF cStatusCredPrestamo IN ("AA","E1") AND cMto6400 = 0 THEN  -- 6400 Activo
				LET cCodRet = "00001";
			ELIF cStatusCredAnticipo IN ("AA","E1") AND cMto7800 = 0 THEN -- 7800 Activo
				LET cCodRet = "00003";
			ELIF cStatusCredAnticipo IN ("BA","BT","E1","E3") AND cMto7800 > 0 THEN	-- 7800 con Adeudo Ã³ Adeudo Vencido
				LET cCodRet = "00004";
			END IF;
			
		ELSE
			LET cCodRet = "00000"; -- No tiene adeudo.
		END IF;

		RETURN cCodRet;
	END;
END PROCEDURE;
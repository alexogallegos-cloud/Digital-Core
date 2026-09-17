CREATE PROCEDURE "informix".sp_cancelarcredito_si(pEmpresa CHAR(3), pNumCredito CHAR(20), pMotivoCancel CHAR(3),
pEjecutivo CHAR(8),pSupervisor CHAR(8), pTipoCancel CHAR(1), pSucursal CHAR(4) )

RETURNING
	CHAR(5) AS CodRet,
	CHAR(16) AS FolioSuc;

-- DECLARACIONES
DEFINE cCodRet		   		    CHAR(5);
DEFINE iSqlErr					INTEGER;    
DEFINE cCodigoCancel			CHAR(3);
DEFINE cProducto				CHAR(4);
DEFINE cSucursal				CHAR(4);
DEFINE cStaCredito				CHAR(2);
DEFINE dLineaCredito			DECIMAL(18,2);
DEFINE cDivisa					CHAR(2);
DEFINE dSdoRetenido				DECIMAL(18,2);
DEFINE dCapVig					DECIMAL(18,2);
DEFINE dMontoSBC				DECIMAL(18,2);
DEFINE dSdoActTotalCap			DECIMAL(18,2);
DEFINE dSdoActTotalInt			DECIMAL(18,2);
DEFINE dSdoActTotalIva			DECIMAL(18,2);
DEFINE dIva						DECIMAL(5,3);
DEFINE cCodRetGM				CHAR(10);
DEFINE cMensaje				    CHAR(80);
DEFINE cCodRet2				    CHAR(5);
DEFINE cFolioSuc				CHAR(16);
DEFINE cFolioSuc2				CHAR(16);
DEFINE cNumTarjeta				CHAR(20);
DEFINE mMontoAutTarjeta			MONEY(14,2);
DEFINE cNumCte					CHAR(20);
DEFINE cCodProdTarjeta			CHAR(3);
DEFINE dFechaHoy				DATE;
DEFINE cBandTrans				CHAR(1);
DEFINE iUnidadProd				INTEGER;
DEFINE cCodCaracter				CHAR(3);
DEFINE cCodCaracter2			CHAR(3);
DEFINE cCliente                  CHAR(20);

-- INICIALIZACIONES
LET cCodRet 				= "00000";
LET iSqlErr 				= 0;
LET cCodigoCancel			= "";
LET cProducto				= "";
LET cSucursal				= "";
LET cStaCredito				= "";
LET dLineaCredito			= 0.0;
LET cDivisa					= "";
LET dSdoRetenido			= 0.0;
LET dCapVig					= 0.0;
LET dMontoSBC				= 0.0;
LET dSdoActTotalCap			= 0.0;
LET dSdoActTotalInt			= 0.0;
LET dSdoActTotalIva			= 0.0;
LET dIva					= 0.0;
LET cCodRetGM				= "";
LET cMensaje				= "";
LET cCodRet2				= "";
LET cFolioSuc				= "";
LET cFolioSuc2				= "";
LET cNumTarjeta				= "";
LET mMontoAutTarjeta		= 0.0;
LET cNumCte					= "";
LET cCodProdTarjeta			= "";
LET dFechaHoy				= MDY(1, 1, 1900);
LET cBandTrans				= "0";
LET iUnidadProd				= 0;
LET cCodCaracter    		= "";
LET cCodCaracter2   		= "";
LET cCliente                = "";
	
BEGIN

	ON EXCEPTION
        SET iSqlErr
        IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
        END IF;
		IF cBandTrans = '1' THEN
			-- EN CASO DE ERROR DE INFORMIX ABORTA LA TRANSACCION
			ROLLBACK WORK;
		END IF
        RETURN TRIM(cCodRet), TRIM(cFolioSuc);
    END EXCEPTION;
	 
--SET DEBUG FILE TO "/informix/cristo/sp_cancelarcredito.out";
--TRACE ON;
	 
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 5;
	
	-- VALIDA QUE NO ESTEN VACIOS LOS PARAMETROS
    IF TRIM(NVL(pEmpresa, '')) = '' OR TRIM(NVL(pNumCredito, '')) = '' OR TRIM(NVL(pMotivoCancel,'')) = '' OR TRIM(NVL(pEjecutivo, '')) = '' OR TRIM(NVL(pSupervisor, '')) = '' OR TRIM(NVL(pTipoCancel, '')) = '' OR TRIM(NVL(pSucursal,'')) = '' THEN 
		LET cCodRet = '00001';
		RETURN TRIM(cCodRet), TRIM(cFolioSuc);
	END IF
	
	-- SE VALIDA LA EXISTENCIA DEL MOTIVO EN EL CATALOGO DE NO CANCELACIONES
	IF pTipoCancel = "3" THEN -- SI ES POR SUCURSAL CONSULTA POR CODIGO
		SELECT codigo
		INTO cCodigoCancel
		FROM "informix".sd_cat_cancred 
		WHERE codigo = pMotivoCancel;
	ELSE	-- SI ES POR CENTRAL CONSULTA POR LA CLAVE
		SELECT codigo
		INTO cCodigoCancel
		FROM "informix".sd_cat_cancred 
		WHERE clave = pMotivoCancel::SMALLINT;	
	END IF;
	
	IF TRIM(NVL(cCodigoCancel,'')) = '' THEN
		LET cCodRet = '00002'; -- MOTIVO NO EXISTE
		RETURN TRIM(cCodRet), TRIM(cFolioSuc);
	END IF;
	
	-- OBTIENE EL PRODUCTO ,  LA SUCURSAL DEL CREDITO Y EL ESTATUS DEL CREDITO
	SELECT num_producto, sucursal, status_cred, divisa, numcte, id_unidad_prod, cod_caract, cod_caract_2
	INTO cProducto, cSucursal, cStaCredito, cDivisa, cNumCte, iUnidadProd, cCodCaracter, cCodCaracter2
	FROM "informix".sd_maecred 
	WHERE num_credito = pNumCredito;

	
	-- VALIDA QUE EL CREDITO EXISTA
	IF TRIM(NVL(cNumCte,'')) = '' THEN
		LET cCodRet = '00003'; -- CREDITO NO EXISTE
		RETURN cCodRet, cFolioSuc;
	END IF
	
	-- VALIDA QUE SEA UN PRODUCTO DE TARJETA DE CREDITO
	IF TRIM(cProducto) <> '6001' THEN
		LET cCodRet = '00004';
		RETURN TRIM(cCodRet), TRIM(cFolioSuc);
	END IF
	
-- OBTIENE LA FECHA DEL DIA
	SELECT FECHA_HOY
	INTO dFechaHoy
	FROM "informix".sd_fechas
	WHERE empresa = '001';
	
	IF cStaCredito = 'FF' THEN 
		SELECT DISTINCT(num_cte) --SE CONSULTA A VER SI EL CRÉDITO ESTA CANCELADO
		INTO cCliente
		FROM "informix".sd_cred_can
		WHERE num_credito = pNumCredito
		AND folio_cancelacion <> "" ;
		
		IF NVL(cCliente, "") = "" THEN --SI NO HAY REGISTROS DE QUE ESTE CANCELADO ENTRA AQUI
			LET cCodRet = '00017'; -- CREDITO SALDADO NORMAL (NO CANCELADO)
			LET cCodigoCancel = '009';	
		ELSE --SI HAY REGISTROS QUIERE DECIR QUE ESTA CANCELADO
			LET cCodRet = '00011'; -- CREDITO CANCELADO
			LET cCodigoCancel = '002';	
        END IF		
	ELIF cStaCredito = 'CV' THEN
		LET cCodRet = '00012'; -- CREDITO VENCIDO
		LET cCodigoCancel = '003';		
	ELIF (cStaCredito = 'BA') THEN
		LET cCodRet = '00013'; -- CREDITO VENCIDO NORMAL
		LET cCodigoCancel = '005';	
	ELIF (cStaCredito IN ('BT','E2','E3')) THEN
		LET cCodRet = '00014'; -- CREDITO VENCIDO TRASPASADO
		LET cCodigoCancel = '006';	
	ELIF cStaCredito = 'FC' THEN
		LET cCodRet = '00015'; -- CREDITO SALDADO RESTRUCTURADO CONSOLIDADO
		LET cCodigoCancel = '007';	
	ELIF iUnidadProd IS NOT NULL OR cCodCaracter <> '' OR cCodCaracter2 <> '' THEN
		LET cCodRet = '00010'; -- CREDITO BLOQUEADO
		LET cCodigoCancel = '004';
	END IF
	
	IF cCodRet='00000' THEN 
			-- OBTIENE EL SALDO RETENIDO, EL CAPITAL VIGENTE Y EL CAPITAL INSOLUTO
			SELECT NVL(sdo_retenido,0), NVL(sdo_capital,0), NVL(sdo_cap_insoluto,0)
			INTO dSdoRetenido, dCapVig, dSdoActTotalCap
			FROM "informix".sd_maesdos
			WHERE num_credito = pNumCredito;

			IF dSdoRetenido > 0 THEN
				LET cCodRet = '00016'; -- CREDITO SALDO RETENIDO
				LET cCodigoCancel = '008';	
			END IF

			IF cCodRet = '00000' THEN
				-- VALIDA QUE LOS SALDOS NO ESTEN EN CEROS Y QUE TENGA ESTATUS VIGENTE
				IF dCapVig <> 0 OR dSdoActTotalCap <> 0 THEN
					LET cCodRet = '00005'; -- CREDITO CON SALDO
					LET cCodigoCancel = '001';		
				ELSE		
					-- OBTIENE EL MONTO DE SALVO BUEN COBRO
					SELECT NVL(SUM(monto),0)
					INTO dMontoSBC
					FROM bdicheq:"informix".sc_docret 
					WHERE empresa = pEmpresa
					AND cuenta = pNumCredito
					AND siglas  = 'SD'
					AND cancelado = 'T';

				IF dMontoSBC = 0 THEN
					-- OBTIENE EL SALDO ACTUAL TOTAL INTERES
					SELECT NVL(SUM(NVL(interes_debe,0) - NVL(interes_pagado,0)) + 
					SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) 
					+ NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)),0)
					INTO dSdoActTotalInt
					FROM "informix".sd_amortiza_credito 
					WHERE empresa = pEmpresa
					AND num_credito = pNumCredito
					AND capital_status IN ('2','7','6');

					IF dSdoActTotalInt = 0 THEN
						-- OBTIENE EL IVA DE LA SUCURSAL
						SELECT iva
						INTO dIva
						FROM bdinteg:"informix".si_sucursales
						WHERE sucursal = cSucursal;

						-- OBTIENE EL SALDO ACTUAL TOTAL IVA
						SELECT NVL(SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) 
						+ NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)) * dIva,0)
						INTO dSdoActTotalIva
						FROM "informix".sd_amortiza_credito 
						WHERE empresa = pEmpresa
						AND num_credito = pNumCredito
						AND capital_status IN ('2','7','6');

						IF dSdoActTotalIva <> 0 THEN
							LET cCodRet = '00005'; -- CREDITO CON SALDO
							LET cCodigoCancel = '001';
						END IF;					
					ELSE
						LET cCodRet = '00005'; -- CREDITO CON SALDO
						LET cCodigoCancel = '001';
					END IF				
				ELSE
					LET cCodRet = '00005'; -- CREDITO CON SALDO
					LET cCodigoCancel = '001';
				END IF			
			END IF		
	      END IF

			LET cFolioSuc = TRIM(cCodigoCancel);

			IF cCodRet = '00000' THEN

				LET cFolioSuc = '';

				-- PROCESO GENERICO PARA FORMATEAR UN FOLIO POR MEDIO DEL EJECUTIVO
				EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina(pSupervisor)
				INTO cCodRet2, cFolioSuc2;

				-- VALIDA QUE NO HAYA TENIDO ERROR LA GENERACÓN DEL FOLIO NOMINA.
				IF cCodRet2::INTEGER <> 0 THEN
					LET cCodRet = '00006';
					LET cFolioSuc = '';
					RETURN TRIM(cCodRet), TRIM(cFolioSuc);
				END IF

				-- OBTIENE LA LINEA DE CREDITO ANTES DE PONERLA EN CEROS
				SELECT monto_otorgado
				INTO dLineaCredito
				FROM "informix".sd_maesdos 
				WHERE num_credito = pNumCredito;

				/*-- VALIDAMOS LA SESION DE LA CANCELACIÓN SI ES DE CENTRAL O SUCURSAL.
				IF TRIM(NVL(pSucursal,'')) = '9250' THEN
					-- INICIA LA TRANSACCION
					BEGIN WORK;
					LET cBandTrans = '1';
				END IF;
				*/
				-- ACTUALIZA LA LINEA DE CREDITO A CERO
				UPDATE "informix".sd_maesdos 
				SET monto_otorgado = 0
				WHERE num_credito = pNumCredito;

				-- ACTUALIZA EL STATUS DEL CREDITO A CANCELADO NORMAL DE CENTRAL
				UPDATE "informix".sd_maecred 
				SET status_cred = 'FI',
					credito_externo = 'CANCELADO POR CTE', --PIQV
					fecha_vencim = dFechaHoy --PIQV
				WHERE numcte = cNumCte
				AND num_credito = pNumCredito;
				

				-- VALIDA QUE NO HAYA TENIDO ERROR
				IF cCodRetGM::INTEGER <> 0 THEN
					--ROLLBACK WORK;
					LET cCodRet = '00007';
					LET cFolioSuc = '';
					RETURN TRIM(cCodRet), TRIM(cFolioSuc);
				END IF

				-- CICLO PARA OBTENER LAS TARJETAS ASIGNADAS A UN NUMERO DE CREDITO QUE NO ESTAN CANCELADAS		
				FOREACH
					SELECT num_tarjeta, numcte
					INTO cNumTarjeta, cNumCte --Se agrega la seleccion del nuevo numero de cliente generado para la tarjeta adicional/CARLOS OCHOA
					FROM "informix".sd_tarjeta 
					WHERE num_credito = pNumCredito
					AND status_tar <> 'C'

					-- PROCESO PARA CANCELAR TARJETA EN CREDITO
					EXECUTE PROCEDURE "informix".cancelatarjeta(pEmpresa,pNumCredito,cNumTarjeta,cNumCte)
					INTO cCodRet2, mMontoAutTarjeta;

					-- VALIDA QUE NO HAYA TENIDO ERROR
					IF cCodRet2::INTEGER <> 0 AND cCodRet2::INTEGER <> 101 THEN			
						--ROLLBACK WORK;
						LET cCodRet = '00008';
						LET cFolioSuc = '';
						RETURN TRIM(cCodRet), TRIM(cFolioSuc);
					END IF

					-- OBTIENE EL CODIGO DE PRODUCTO DE TARJETA DE INTERCARD
					SELECT codproductotarjeta
					INTO cCodProdTarjeta
					FROM intercard:"informix".tarjeta 
					WHERE numtarjeta = cNumTarjeta;
					/*
					-- PROCESO PARA CANCELAR TARJETA EN INTERCARD
					EXECUTE PROCEDURE intercard:"informix".sp_cancelacion_tarjeta(cNumTarjeta, cCodProdTarjeta, pEjecutivo)
					INTO cCodRet2, cMensaje;

					-- VALIDA QUE NO HAYA TENIDO ERROR
					IF cCodRet2::INTEGER <> 0 AND cCodRet2::INTEGER <> 2 THEN
						--ROLLBACK WORK;
						LET cCodRet = '00009';
						LET cFolioSuc = '';
						RETURN TRIM(cCodRet), TRIM(cFolioSuc);
					END IF
					*/
				END FOREACH;

				END IF

				IF cCodRet <> '00000' THEN
					LET cFolioSuc2 = '';
				ELSE
					LET cFolioSuc = cFolioSuc2;
			END IF
	END IF;
	-- SE GRABA EN LA BITACORA DE LOS CREDITOS CANCELADOS Y LOS NO CANCELADOS.
 	INSERT INTO "informix".sd_cred_can(empresa, num_credito, num_cte, motivo_can, num_producto, ejecutivo, supervisor, fecha_can, tipo_can, sucursal, folio_cancelacion) 
	VALUES (TRIM(pEmpresa), TRIM(pNumCredito), TRIM(cNumCte), TRIM(cCodigoCancel), TRIM(cProducto), TRIM(pEjecutivo), TRIM(pSupervisor), dFechaHoy, TRIM(pTipoCancel), TRIM(pSucursal), TRIM(cFolioSuc2));
	IF pMotivoCancel::SMALLINT = 2 and cCodRet::INTEGER =0 THEN
		--SE realiza el marcaje del cliente RQI 27 100 JMAH
		EXECUTE PROCEDURE bdisitesp:"informix".sp_marcajesitesp('001',4,cNumCte, pEjecutivo)
		INTO cCodRet, cMensaje;
	END IF;
	
	IF cBandTrans = '1' THEN
		-- APLICA LA TRANSACCION
		--COMMIT WORK;
	END IF
	
	RETURN TRIM(cCodRet), TRIM(cFolioSuc);
	
END  
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para ', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'FECHA: 21 Mayo 2014',
'VERSION: 20140521.1645',
'BD: bdicred';

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
CREATE PROCEDURE "informix".sp_compra_promo()
RETURNING
	CHAR(6) 	AS cod_ret,
	CHAR(80) 	AS descripcion


	---DECLARACIONES
    DEFINE iSqlErr				INTEGER;
    DEFINE iIsamErr				INTEGER;
    DEFINE cErrorInfo			CHAR(80);
    DEFINE cCodRet				CHAR(6);
    DEFINE cMensajeRet			CHAR(80);
	DEFINE dMonto				DECIMAL(18,2);
	DEFINE sPlazo				SMALLINT;
	DEFINE vcNumCredito			VARCHAR(20);
	DEFINE vcNumCte				CHAR(20);
	DEFINE cEjecutivo			CHAR(8);
	DEFINE cSucursal			CHAR(4);
	DEFINE sNumPromocion		SMALLINT;
	DEFINE cNomPromocion		CHAR(50);
	DEFINE iRowID				INTEGER;
	DEFINE cFolioApertua		CHAR(16);
	DEFINE cFolioMovto			CHAR(16);

    DEFINE dMonto1				DECIMAL(18,2);
	DEFINE sPlazo1				SMALLINT;
	DEFINE vcNumCredito1		VARCHAR(20);
	DEFINE cEjecutivo1			CHAR(8);
	DEFINE cSucursal1			CHAR(4);
	DEFINE sNumPromocion1		SMALLINT;
	DEFINE cNomPromocion1		CHAR(50);
	DEFINE iRowID1				INTEGER;
	DEFINE cFolioApertua1		CHAR(16);
	DEFINE cFolioMovto1			CHAR(16);

	-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO QUE GENERA EL FOLIO
	DEFINE cCodRetGF			CHAR(6);
	DEFINE cFolioSucGF			CHAR(16);

	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE LA PROYECCION
	DEFINE cCodRetPP			CHAR(5);
    DEFINE cMensajeRetPP		CHAR(80);
	DEFINE dTotalPagarPP		DECIMAL(18,2);
	DEFINE sNumPlazoPP			SMALLINT;
	DEFINE dPagoMensualPP		DECIMAL(18,2);
	DEFINE dInteresIvaPP		DECIMAL(18,2);
	DEFINE dSaldoTdcPP			DECIMAL(18,2);
	DEFINE cFolioPromoPP		CHAR(16);

	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE principal
	DEFINE cCodRetPrin			CHAR(5);
	DEFINE dRemanentePrin		DECIMAL(18,2);
	DEFINE dIntMoratorioPrin	DECIMAL(18,2);
	DEFINE dIntVencidoPrin		DECIMAL(18,2);
	DEFINE dCapVencidoPrin		DECIMAL(18,2);
	DEFINE dIntVigentePrin		DECIMAL(18,2);
	DEFINE dCapVigentePrin		DECIMAL(18,2);
	DEFINE dImpuestoPrin		DECIMAL(18,2);
	DEFINE dComisionesPrin		DECIMAL(18,2);
	DEFINE dSeguroPrin			DECIMAL(18,2);

	-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO DE ASIGNACION DE NUMERO DE SOLICITUD
	DEFINE cCodRetANS			CHAR(5);
	DEFINE cNumSolANS			CHAR(20);

	-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO DE APERTURA DE PRESTAMO
	DEFINE cCodRetAP			CHAR(6);
	DEFINE dTasaInteres			DECIMAL(18,2);
	DEFINE dTasaMora			DECIMAL(18,2);
	DEFINE dCatIva		    	DECIMAL(18,2);
	DEFINE cMercadeo			CHAR(1);

	-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO DE REVERSION
	DEFINE cCodRetRev			CHAR(5);

	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE REVERSION PROMO
	DEFINE cCodRetRP			CHAR(5);
    DEFINE cMensajeRetRP		CHAR(80);

	--VARIABLES PARA CACHAR EL VALOR DEL PROCEDIMIENTO DE LA APERTURA DE LA COMPRA A MESES.
	DEFINE cCodRetGenMov		CHAR(10);
	DEFINE cMsjeGenMov		    CHAR(80);
    DEFINE vDivisa              CHAR(2);
    DEFINE vDivisa1              CHAR(2);
    DEFINE v_dv                 CHAR(2);
    DEFINE v_tipocambio         DECIMAL(14,6);
    DEFINE vsucorig             CHAR(4);
    DEFINE vsucorig1             CHAR(4);
    DEFINE vc_dtFechaHoy        DATE;    --> FMV 4-AGO-14: Fecha  Apertura
	DEFINE cResp_Cte_sms		CHAR(1); -- SMS
	DEFINE sCountExists			SMALLINT;
	DEFINE sYield				INTEGER;
	DEFINE sTasa				DECIMAL(9,6);
	DEFINE cNumProm_proy		SMALLINT;

	-- JHQS INC 27 127 {
	DEFINE dMontoIntIVA			DECIMAL(18,2);
	DEFINE dFechaPromo			DATE;
	DEFINE dMontoIntIVA1		DECIMAL(18,2);
	DEFINE dFechaPromo1			DATE;
	DEFINE vReferencia			VARCHAR(40);
	DEFINE vReferencia2			VARCHAR(40);
	DEFINE vRef					VARCHAR(40);
	DEFINE vFolio				VARCHAR(16);
	DEFINE vProducto			CHAR(4);
	DEFINE Id_Bloqueo			INTEGER;
	DEFINE cTipoContrato		CHAR(3);
	DEFINE dPorcReducTp3 		DECIMAL(18,2);
	DEFINE dSdoDisponible       DECIMAL(18,2);
	DEFINE dSdoReduccion        DECIMAL(18,2);
	DEFINE cCodRetCanc 			CHAR(5);
	DEFINE cMensajeRetCanc      CHAR(100);
	DEFINE cBajaApoyo			CHAR(1);
	DEFINE dMonto_LinOrig		DECIMAL(18,2);	
	DEFINE dMonto_LinNva 		DECIMAL(18,2);	
	DEFINE dFecha_Invitacion    DATE;
	
	
	LET dMontoIntIVA 		= 0.0;
	LET dFechaPromo			= DATE(1);
	LET dMontoIntIVA1 		= 0.0;
	LET dFechaPromo1		= DATE(1);
	LET vReferencia 		= '';
	LET	vReferencia2 		= '';
	LET vRef 				= '';
	LET	vFolio 				= '';
	-- } JHQS INC 27 127
	
	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= '';
	LET cCodRet				= '000000';
	LET cMensajeRet			= 'PROCESO EXITOSO';
	LET dMonto				= 0.0;
	LET sPlazo				= 0;
	LET vcNumCredito		= '';
	LET vcNumCte			= '';
	LET cEjecutivo			= '';
	LET cSucursal			= '';
	LET sNumPromocion		= 0;
	LET cNomPromocion		= '';
	LET iRowID				= 0;
	LET cFolioApertua		= '';
	LET cFolioMovto			= '';

    LET dMonto1				= 0.0;
	LET sPlazo1				= 0;
	LET vcNumCredito1		= '';
	LET cEjecutivo1			= '';
	LET cSucursal1			= '';
	LET sNumPromocion1		= 0;
	LET cNomPromocion1		= '';
	LET iRowID1				= 0;
	LET cFolioApertua1		= '';
	LET cFolioMovto1		= '';

	-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO QUE GENERA EL FOLIO
	LET cCodRetGF			= '000000';
	LET cFolioSucGF			= '';

	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE LA PROYECCION
	LET cCodRetPP			= '';
    LET cMensajeRetPP		= '';
	LET dTotalPagarPP		= 0.0;
	LET sNumPlazoPP			= 0;
	LET dPagoMensualPP		= 0.0;
	LET dInteresIvaPP		= 0.0;
	LET dSaldoTdcPP			= 0.0;
	LET cFolioPromoPP		= '';

	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE principal
	LET cCodRetPrin			= '';
	LET dRemanentePrin		= 0.0;
	LET dIntMoratorioPrin	= 0.0;
	LET dIntVencidoPrin		= 0.0;
	LET dCapVencidoPrin		= 0.0;
	LET dIntVigentePrin		= 0.0;
	LET dCapVigentePrin		= 0.0;
	LET dImpuestoPrin		= 0.0;
	LET dComisionesPrin		= 0.0;
	LET dSeguroPrin			= 0.0;

	-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO DE ASIGNACION DE NUMERO DE SOLICITUD
	LET cCodRetANS			= '';
	LET cNumSolANS			= '';

	-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO DE APERTURA DE PRESTAMO
	LET cCodRetAP			= '000000';
	LET dTasaInteres		= 0.0;
	LET dTasaMora			= 0.0;
	LET dCatIva		    	= 0.0;
	LET cMercadeo			= '';

	-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO DE REVERSION
	LET cCodRetRev			= '00000';

	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE REVERSION PROMO
	LET cCodRetRP			= '00000';
    LET cMensajeRetRP		= '';

	--VARIABLES PARA CACHAR EL VALOR DEL PROCEDIMIENTO DE LA APERTURA DE LA COMPRA A MESES.
	LET cCodRetGenMov		= "";
	LET cMsjeGenMov		    = "";
    LET vDivisa             = "00";
    LET vDivisa1             = "00";
    LET v_dv                = "00";
    LET v_tipocambio        = 0;
    LET vsucorig            = "";
    LET vsucorig1            = "";
    LET vc_dtFechaHoy       = DATE(1);
	LET cResp_Cte_sms		= '';		-- SMS
	LET sCountExists		= 0;
	LET sYield 				= 0;
	LET sTasa				= 0;
	LET cNumProm_proy		= 0;
	LET vProducto			='';
	LET Id_Bloqueo			= 0;
	LET cTipoContrato		= '';
	LET dPorcReducTp3 		= 0;
	LET dSdoDisponible      = 0;
	LET dSdoReduccion       = 0;
	LET cCodRetCanc 		= '';
	LET cMensajeRetCanc     = '';
	LET cBajaApoyo			= '';
	LET dMonto_LinOrig		= 0;
	LET dMonto_LinNva 		= 0;
	LET dFecha_Invitacion	= DATE(1);
	

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet, NVL(cMensajeRet,'');
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/mahr/sp_compra_promo.out';
	--SET DEBUG FILE TO '/ifxsif01/mahr/IFRS-Credito/prueba/sp_compra_promo.out';
	--TRACE ON;

    SELECT valor INTO v_dv
      FROM bdinteg:si_param
     WHERE cod_param = 17;

    SELECT precio_venta INTO v_tipocambio
      FROM bdinteg:si_tpcambio
     WHERE empresa = "001"
       AND divisa = v_dv
       AND clase_tpcambio = "O"
       AND fecha_tpcambio = (SELECT MAX(fecha_tpcambio) FROM bdinteg:si_tpcambio WHERE empresa = "001" AND divisa = v_dv);

    SELECT fecha_hoy INTO vc_dtFechaHoy
      FROM "informix".sd_fechas
     WHERE empresa = '001';

	-- BARRE LOS CREDITOS A CONFIRMAR LAS PROMOCIONES DE CREDISOLUCION
    FOREACH WITH HOLD
        SELECT a.ROWID   , a.monto_actual , a.plazo    , a.num_promo   , a.nombre_promo  , a.num_credito, a.ejecutivo, a.sucursal, a.folio_suc  , a.folio_movto, divisa , 
			   b.sucursal, a.monto_int_iva, a.fecha    , b.num_producto, b.id_unidad_prod, b.numcte												-- INC 27 127 JHQS 20190626

		  INTO iRowID    , dMonto         , sPlazo     , sNumPromocion , cNomPromocion   , vcNumCredito , cEjecutivo , cSucursal , cFolioApertua, cFolioMovto  , vDivisa, 
		       vsucorig  , dMontoIntIVA   , dFechaPromo, vProducto     , Id_Bloqueo      , vcNumCte   											-- INC 27 127 JHQS 20190626
          FROM bdicred:"informix".sd_promocion_credito a, 
		       bdicred:sd_maecred b,
		       bdicred:sd_maesdos c
         WHERE a.empresa = b.empresa
           AND a.num_credito = b.num_credito
		   AND b.num_credito = c.num_credito
           AND a.status = 0         -->FMV 4ago14: Pendiente de aperturar
           AND b.status_cred IN ('AA','E1') 
		   AND (c.monto_vencido + c.mto_venc_trasp) = 0
		   AND b.num_producto in ('6001', '6600', '7000', '8100', '8500') --> RQM 10 1365
		   AND a.num_pro_prestamo = '6900'
		   
		-- INICIALIZA VARIABLES QUE REGRESAN LOS PROCESOS DE LA PROYECCION Y EL PRINCIPAL
		LET cCodRetPP			= '';
	    LET cMensajeRetPP		= '';
		LET dTotalPagarPP		= 0.0;
		LET sNumPlazoPP			= 0;
		LET dPagoMensualPP		= 0.0;
		LET dInteresIvaPP		= 0.0;
		LET cCodRetPrin			= '';
		LET dRemanentePrin		= 0.0;
		LET dIntMoratorioPrin	= 0.0;
		LET dIntVencidoPrin		= 0.0;
		LET dCapVencidoPrin		= 0.0;
		LET dIntVigentePrin		= 0.0;
		LET dCapVigentePrin		= 0.0;
		LET dImpuestoPrin		= 0.0;
		LET dComisionesPrin		= 0.0;
		LET dSeguroPrin			= 0.0;

		-- JHQS 20190628 INC 27 127 {
		LET cFolioApertua = TRIM(NVL(cFolioApertua,''));
		LET cFolioMovto = TRIM(NVL(cFolioMovto,''));
		
		
		-- Se consulta referencias de retenidos en la tabla sd_maeretenido (en caso de que requiera actualizarse estatus por error [sd_promocion_credito.status = 4])	
		FOREACH
			
			SELECT referencia, folio_suc INTO vRef, vFolio
			  FROM "informix".sd_maeretenido
		     WHERE empresa = '001' 
		       AND num_credito = vcNumCredito
			   AND estatus = 'R'
			   AND monto IN(dMonto,dMontoIntIVA)
			   AND fecha = dFechaPromo
			   
			LET vRef = NVL(vRef,'');
			LET vFolio = NVL(vFolio,'');
			
			IF vFolio = cFolioMovto THEN
				LET vReferencia = vRef;
			ELIF LEFT(vRef,16) = cFolioApertua THEN
				LET vReferencia2 = vRef;
			END IF;
			
		END FOREACH
		-- } JHQS 20190628 INC 27 127
		
		--Identifica folios duplicados
		LET sCountExists = 0;
		SELECT count(folio_movto) INTO sCountExists FROM bdicred:"informix".sd_promocion_credito WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto;
		IF sCountExists != 1 THEN
		
			-- Valida estatus de registro previo, si ya esta procesado 0 pendiente o 2 procesado (Credisol Compras), se cancela MSI, de lo contrario se elimina registro previo.
			SELECT count(folio_movto) INTO sCountExists FROM bdicred:"informix".sd_promocion_credito WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto AND num_promo != 8 AND status not in (4,5,8);
			IF sCountExists > 0  THEN
				UPDATE bdicred:"informix".sd_promocion_credito SET status = 4 WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto AND status = 0 AND num_promo = 8;
				INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',vcNumCredito,'sp_compra_promo-3',vc_dtFechaHoy,CURRENT,'',sNumPromocion,cCodRet);				
				LET sCountExists = 0;
				CONTINUE FOREACH;
			END IF;
			
			-- Valida registros previos marcados pero no procesados, se eliminan para procesar MSI
			SELECT count(folio_movto) INTO sCountExists FROM bdicred:"informix".sd_promocion_credito WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto AND num_promo != 8 AND status in (4,5,8);
			IF sCountExists > 0  THEN
				--DELETE FROM bdicred:sd_promocion_credito WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto AND num_promo != 8;
				--DELETE FROM bdicred:sd_promocion_credito_sms WHERE num_credito = vcNumCredito AND folio_compra_sms = cFolioMovto;
				LET sCountExists = 0;
			END IF;
		END IF;	

		-- Identifica si el cliente es por contratacion de SMS
		LET cTipoContrato = '';
		IF sNumPromocion in (2, 5, 8) THEN
			SELECT first 1 respuesta_cte_sms, tasa, tipo_contrato INTO cResp_Cte_sms, sTasa, cTipoContrato FROM bdicred:sd_promocion_credito_sms 
			 WHERE num_credito = vcNumCredito AND folio_compra_sms = cFolioMovto;
		ELIF sNumPromocion in (3, 6, 9) THEN
			SELECT max(fecha_invitacion) INTO dFecha_Invitacion FROM bdicred:sd_promocion_credito_sms WHERE num_credito = vcNumCredito AND num_promo = sNumPromocion AND mnto_compra = dMonto AND plazo = sPlazo; 
			SELECT first 1 respuesta_cte_sms, tasa, tipo_contrato INTO cResp_Cte_sms, sTasa, cTipoContrato FROM bdicred:sd_promocion_credito_sms 
			 WHERE num_credito = vcNumCredito AND num_promo = sNumPromocion AND mnto_compra = dMonto AND plazo = sPlazo AND fecha_invitacion = dFecha_Invitacion; 
		END IF;	

		-- Desbloquea credito si es contrato Sdo Inmediato sms Apoyo 2020
		IF cTipoContrato IS NULL THEN LET cTipoContrato = ''; END IF;
		IF cTipoContrato = '3' THEN	
			UPDATE bdicred:sd_maecred SET id_unidad_prod = NULL WHERE num_credito = vcNumCredito;
			
			-- Elimina registro de programa de apoyo en caso de encontrarse en apoyo para liberar retenidos
			-- Cancela programa apoyo si la TDC se encuentra registrada y se liberan retenidos por programa de apoyo 2020.
			EXECUTE PROCEDURE "informix".sp_diferir_cancela_credito(vcNumCte, vcNumCredito, 1, 22) INTO cCodRetCanc, cMensajeRetCanc;
			IF cCodRetCanc = '00000' THEN LET cBajaApoyo = '1'; ELSE LET cBajaApoyo = '0'; END IF;			
		END IF;
		
		-- MANDA A LLAMAR AL PROCESO DE LA PROYECCION DE CREDISOLUCIONES
		IF NVL(cResp_Cte_sms,'') = 'S' THEN										-- Proyecta para credisoluciones generadas desde SMS 
			EXECUTE PROCEDURE bdicred:"informix".sp_proyecta_pfsms(2,cSucursal,cEjecutivo,sNumPromocion,vcNumCredito,'',dMonto,sPlazo, sTasa, cFolioMovto)
			   INTO cCodRetPP, cMensajeRetPP, dTotalPagarPP, sNumPlazoPP, dPagoMensualPP, dInteresIvaPP, dSaldoTdcPP, cFolioPromoPP, cNumProm_proy;		
		ELSE
																				-- Proyecta para credisoluciones generadas en sucursal
			EXECUTE PROCEDURE bdicred:"informix".sp_proyecta_promo(2,cSucursal,cEjecutivo,sNumPromocion,vcNumCredito,'',dMonto,sPlazo, cFolioMovto)
			   INTO cCodRetPP, cMensajeRetPP, dTotalPagarPP, sNumPlazoPP, dPagoMensualPP, dInteresIvaPP, dSaldoTdcPP, cFolioPromoPP;		
		END IF;

		IF cCodRetPP::INTEGER = 443 THEN        -- 00443 - EL PLAZO NO ES VALIDO PARA LA PROMOCION

			-- LLAMA AL REVERSO PROMO PARA LIBERAR EL RETENIDO DE LOS INTERESES
			/*EXECUTE PROCEDURE bdicred:"informix".sp_reverso_promo(vcNumCredito, cFolioMovto, 1) INTO cCodRetRP, cMensajeRetRP;
			IF cCodRetRP::INTEGER <> 0 THEN
				LET cCodRet = '000005';
				LET cMensajeRet = 'OCURRIO UN ERROR EN EL PROCESO DE REVERSA PROMO';
				-- EXIT FOREACH;
			END IF
			CONTINUE FOREACH;*/
            INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',vcNumCredito,'sp_compra_promo-1',vc_dtFechaHoy,CURRENT,'',sNumPromocion,cCodRetPP);
            LET cCodRet = cCodRetPP;
            LET cMensajeRet = cMensajeRetPP;
            --EXIT FOREACH;
			CONTINUE FOREACH;

        --ELIF cCodRetPP::INTEGER <> 0 THEN  --- 03433, 07433, 11433 - EL CLIENTE NO ES VIABLE PARA DIFERIR (cuando se sobregira con la credisol)
             -- sp_proyecta_promo, no rechace la credisol desde el proceso nocturno, cuando ya se registro con status 0
        ELIF cCodRetPP::INTEGER <> 0 AND cCodRetPP NOT IN ('03433','07433','11433') THEN

			--Registra error en bitacora
            INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',vcNumCredito,'sp_compra_promo-2',vc_dtFechaHoy,CURRENT,'',sNumPromocion,cCodRetPP);
            --LET cCodRet = cCodRetPP;
            --LET cMensajeRet = cMensajeRetPP;
            --EXIT FOREACH;

            -- LLAMA AL REVERSO PROMO PARA LIBERAR EL RETENIDO DE LOS INTERESES
			EXECUTE PROCEDURE bdicred:"informix".sp_reverso_promo(vcNumCredito, cFolioMovto, 1) INTO cCodRetRP, cMensajeRetRP;
			
			-- ACTUALIZA EL ESTATUS COMO ERROR DE LA PROYECCION
            IF cCodRetRP::INTEGER <> 0 THEN
                UPDATE bdicred:"informix".sd_promocion_credito SET status = 4  -->FMV 4ago14 :Genero Error en la apertura
                 WHERE empresa = '001'
				   AND num_credito = vcNumCredito
				   AND num_promo = sNumPromocion
                   AND ROWID = iRowID;
				
				-- JHQS 20190626 INC 27 127 {
				-- Se agrega cambio de estatus de la tabla sd_maeretenido
				UPDATE "informix".sd_maeretenido SET estatus = 'S'
				 WHERE empresa = '001' 
				   AND num_credito = vcNumCredito
				   AND referencia IN(vReferencia, vReferencia2)
				   AND estatus = 'R'
				   AND fecha = dFechaPromo;
				-- } JHQS 20190626 INC 27 127
			
                LET cCodRet = '000005';
                LET cMensajeRet = 'OCURRIO UN ERROR EN EL PROCESO DE REVERSA PROMO';
                --EXIT FOREACH;
            END IF;
			IF NVL(cResp_Cte_sms,'') = 'S' THEN
				IF sNumPromocion in (2, 5, 8) THEN
					UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '6', envio_result_sms = '0', status_envio_r_sms = '0' WHERE num_credito = vcNumCredito AND folio_compra_sms = cFolioMovto;
				ELIF sNumPromocion in (3, 6, 9) THEN
					UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '6', envio_result_sms = '0', status_envio_r_sms = '0' 
					 WHERE num_credito = vcNumCredito AND num_promo = sNumPromocion AND mnto_compra = dMonto AND plazo = sPlazo AND fecha_invitacion = dFecha_Invitacion;					 
				END IF;	
			END IF;		
			CONTINUE FOREACH;
		END IF

		--- PROCESO GENERICO PARA GENERAR UN FOLIO
		--EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina(cEjecutivo)
		--INTO cCodRetGF,cFolioSucGF;
		LET cCodRetGF = '000000';
		SELECT cEjecutivo || substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,1,2)
			||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,4,2)
			||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,7,2)
			||lpad(bdicheq:sp_random(),2,'0')
		INTO cFolioSucGF 
		FROM sysmaster:sysshmvals;
			-------
			-- Valida folio no exista
			LET sCountExists = 0;  
			SELECT COUNT(folio_suc) INTO sCountExists FROM bdicred:"informix".sd_maeretenido 
			 WHERE empresa = '001' AND num_credito = vcNumCredito AND folio_suc = cFolioSucGF;
			IF sCountExists > 0 THEN
				SELECT cEjecutivo || substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,1,2)
					||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,4,2)
					||substr(DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND,7,2)
					||lpad(bdicheq:sp_random(),2,'0'), sysmaster:yieldn( 1 )
				  INTO cFolioSucGF, sYield FROM sysmaster:sysshmvals;
			END IF;
			-------

		IF cCodRetGF::INTEGER <> 0 THEN
			LET cCodRet = '000001';
			LET cMensajeRet = 'OCURRIO UN ERROR EN EL PROCESO QUE GENERA EL FOLIO';
			--EXIT FOREACH;
            CONTINUE FOREACH;
		ELSE

			-- MANDA A LLAMAR AL PROCESO LLAMADO PRINCIPAL PARA REALIZAR EL ABONO POR EL MONTO A DIFERIR
--			EXECUTE PROCEDURE bdicred:"informix".principal('001',vcNumCredito,1,dMonto,cEjecutivo,cSucursal,cFolioSucGF,'7772')
			EXECUTE PROCEDURE bdicred:"informix".principal('001',vcNumCredito,1,dMonto,cEjecutivo,cSucursal,cFolioSucGF,'6030')
			INTO cCodRetPrin,dRemanentePrin,dIntMoratorioPrin,dIntVencidoPrin,dCapVencidoPrin,dIntVigentePrin,dCapVigentePrin,dImpuestoPrin,dComisionesPrin,dSeguroPrin;

			IF cCodRetPrin::INTEGER <> 0 THEN
				-- ACTUALIZA EL ESTATUS A 4 COMO  CREDITO QUE SE TRABAJO Y OBTUVO UN ERROR
			   UPDATE bdicred:"informix".sd_promocion_credito
				  SET status = 4      -->FMV 4ago14 :Genero Error en la apertura
				WHERE empresa = '001'
				  AND num_credito = vcNumCredito
				  AND num_promo = sNumPromocion
				  AND ROWID = iRowID;
				
				-- JHQS 20190626 INC 27 127 {
				-- Se agrega cambio de estatus de la tabla sd_maeretenido
				UPDATE "informix".sd_maeretenido SET estatus = 'S'
				 WHERE empresa = '001' 
				   AND num_credito = vcNumCredito
				   AND referencia IN(vReferencia, vReferencia2)
				   AND estatus = 'R'
				   AND fecha = dFechaPromo;
				-- } JHQS 20190626 INC 27 127
				
				IF NVL(cResp_Cte_sms,'') = 'S' THEN
					IF sNumPromocion in (2, 5, 8) THEN
						UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '6', envio_result_sms = '0', status_envio_r_sms = '0' WHERE num_credito = vcNumCredito AND folio_compra_sms = cFolioMovto;
					ELIF sNumPromocion in (3, 6, 9) THEN
						UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '6', envio_result_sms = '0', status_envio_r_sms = '0' 
						 WHERE num_credito = vcNumCredito AND num_promo = sNumPromocion AND mnto_compra = dMonto AND plazo = sPlazo AND fecha_invitacion = dFecha_Invitacion; 						 
					END IF;	
				END IF;	
				-- SE PASA AL SIGUIENTE CREDITO
				CONTINUE FOREACH;
			ELSE
				LET cCodRetGF = '000000';

				IF cCodRetGF::INTEGER <> 0 THEN
					LET cCodRet = '000003';
					LET cMensajeRet = 'OCURRIO UN ERROR EN EL PROCESO QUE GENERA EL FOLIO';
					-- EXIT FOREACH;
                    CONTINUE FOREACH;
				ELSE

					INSERT INTO bdicred:"informix".sd_maeretenido(empresa,num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori)
					VALUES('001',vcNumCredito,cFolioSucGF,vc_dtFechaHoy,CURRENT HOUR TO FRACTION(3),'6837',0,dMonto,cEjecutivo,'R',cFolioApertua||' PAGOS DIFERIDOS',cSucursal,0);

					-- GENERAMOS EL MOVIMIENTO DE LA APERTURA DE LA COMPRA A MESES.
					EXECUTE PROCEDURE bdicred:"informix".genmov_tc('001',vcNumCredito,vProducto,vc_dtFechaHoy,dMonto,cFolioSucGF,cSucursal,vDivisa,'6837','','PAGOS DIFERIDOS',v_tipocambio,0,cEjecutivo,vsucorig,'','')
					INTO cCodRetGenMov, cMsjeGenMov;

					IF cCodRetGenMov::INTEGER <> 0 THEN
						LET cCodRet = '000006';
						LET cMensajeRet = 'OCURRIO UN ERROR EN EL PROCESO DE MOVIMIENTO DE APERTURA DE LA COMPRA A MESES';
						-- EXIT FOREACH;
                        CONTINUE FOREACH;
					END IF

					-- ACTUALIZA EL SALDO RETENIDO EN EL MAESTRO DE SALDOS
					UPDATE bdicred:"informix".sd_maesdos
					   SET sdo_retenido = sdo_retenido + dMonto
					 WHERE empresa = '001'
					   AND num_credito = vcNumCredito;

					-- ACTUALIZA EL ESTATUS A 1
					UPDATE bdicred:"informix".sd_promocion_credito
				       SET status = 1
					 WHERE empresa = '001'
					   AND num_credito = vcNumCredito
					   AND num_promo = sNumPromocion
					   AND ROWID = iRowID;

					-- MANDA A LLAMAR A EL PROCESO DE ASIGNACION DE SOLICITUD
					EXECUTE PROCEDURE bdisolic:"informix".asigna_numsol('001','6900')
					INTO cCodRetANS, cNumSolANS;

					IF cCodRetANS::INTEGER <> 0 THEN
						LET cCodRet = '000004';
						LET cMensajeRet = 'OCURRIO UN ERROR EN EL PROCESO DE LA ASIGNACION DE LA SOLICITUD';
					ELSE
						-- ACTUALIZA EL NUMERO DE SOLICITUD DEL PRESTAMO EN LA TABLA DE LAS PROMOCIONES
						UPDATE bdicred:"informix".sd_promocion_credito
						   SET num_sol_prestamo = cNumSolANS,
						       tipo_contrato = cTipoContrato
						 WHERE empresa = '001'
						   AND num_credito = vcNumCredito
						   AND num_promo = sNumPromocion
						   AND ROWID = iRowID;

						-- MANDA A LLAMAR AL PROCESO DE APERTURA DE CREDITO DE PRESTAMOS
						EXECUTE PROCEDURE bdicred:"informix".sp_apercred1_credisol('001', cNumSolANS, cEjecutivo, sPlazo, cNomPromocion, dMonto, '', dPagoMensualPP)
						INTO cCodRetAP, dTasaInteres, dTasaMora, dCatIva, cMercadeo;

						IF cCodRetAP::INTEGER <> 0 THEN
							EXECUTE PROCEDURE bdicred:"informix".reversion('001', cSucursal, cEjecutivo, cFolioSucGF, "M")
							INTO cCodRetRev;

							-- ACTUALIZA EL ESTATUS A 4 COMO  CREDITO QUE SE TRABAJO Y OBTUVO UN ERROR
							UPDATE bdicred:"informix".sd_promocion_credito
							   SET status = 4, num_sol_prestamo = ''
							 WHERE empresa = '001'
							   AND num_credito = vcNumCredito
							   AND num_promo = sNumPromocion
						 	   AND ROWID = iRowID;
				
							-- JHQS 20190626 INC 27 127 {
							-- Se agrega cambio de estatus de la tabla sd_maeretenido
							UPDATE "informix".sd_maeretenido SET estatus = 'S'
							 WHERE empresa = '001' 
							   AND num_credito = vcNumCredito
							   AND referencia IN(vReferencia, vReferencia2)
							   AND estatus = 'R'
							   AND fecha = dFechaPromo;
							-- } JHQS 20190626 INC 27 127
							
							-- REGRESA LA SECUENCIA  ANTERIOR
							UPDATE bdisolic:"informix".ss_solic_producto
							   SET secuencia_prod = secuencia_prod - 1
							 WHERE empresa = '001'
							   AND num_producto = '6900';

							IF NVL(cResp_Cte_sms,'') = 'S' THEN
								IF sNumPromocion in (2, 5, 8) THEN
									UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '6', envio_result_sms = '0', status_envio_r_sms = '0' WHERE num_credito = vcNumCredito AND folio_compra_sms = cFolioMovto;
								ELIF sNumPromocion in (3, 6, 9) THEN
									UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '6', envio_result_sms = '0', status_envio_r_sms = '0' 
									 WHERE num_credito = vcNumCredito AND num_promo = sNumPromocion AND mnto_compra = dMonto AND plazo = sPlazo AND fecha_invitacion = dFecha_Invitacion; 									 
								END IF;	
							END IF;	
							CONTINUE FOREACH;
						ELSE
							-- ACTUALIZA EL ESTATUS A 2
							UPDATE bdicred:"informix".sd_promocion_credito
							   SET status = 2,     --> FMV 4ago14: Aperturado
                                   fecha = vc_dtFechaHoy
							 WHERE empresa = '001'
							   AND num_credito = vcNumCredito
							   AND num_promo = sNumPromocion
							   AND ROWID = iRowID;

                            -- ACTUALIZA REGISTRO DE MOV_DIA CON LA APERTURA DEL CREDITO (CREDISOLUCION) APERTURADO
                            UPDATE bdicred:sd_movdia SET referencia = cFolioSucGF || ' ' || cNumSolANS
                             WHERE num_credito = vcNumCredito AND folio_suc = cFolioSucGF
                               AND codigo_fun = '060' AND codigo_ref = 10;
							   							   
							-- Marca registro de apertura OK si es contratacion por SMS, para su envio posterior de SMS correspondiente.
							IF NVL(cResp_Cte_sms,'') = 'S' THEN
								IF sNumPromocion in (2, 5, 8) THEN
									UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '7', envio_result_sms = '1', status_envio_r_sms = '0', num_credisolucion = cNumSolANS
								 	 WHERE num_credito = vcNumCredito AND folio_compra_sms = cFolioMovto;
								ELIF sNumPromocion in (3, 6, 9) THEN
									UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '7', envio_result_sms = '1', status_envio_r_sms = '0', num_credisolucion = cNumSolANS
									 WHERE num_credito = vcNumCredito AND num_promo = sNumPromocion AND mnto_compra = dMonto AND plazo = sPlazo AND fecha_invitacion = dFecha_Invitacion; 									 
								END IF;	
							END IF;
							LET cCodRet = '000000';
							-- Reduce al 50% la linea disponible para clientes contratados por Pagos Fijos Saldo Inmediato - Apoyo 2020.
							IF cTipoContrato = '3' THEN
								-- Obtiene parametros para reduccion.
								SELECT valor_numerico INTO dPorcReducTp3 FROM bdicred:sd_param_campania WHERE empresa = '001' AND tipo_campania = 2 AND grupo_parametro = 'PAGOSFIJOS' AND num_parametro = 23;

								-- Obtiene linea disponible de TDC
								SELECT monto_otorgado, (monto_otorgado - (sdo_cap_insoluto + sdo_retenido)) INTO dMonto_LinOrig, dSdoDisponible 
								  FROM bdicred:sd_maesdos WHERE num_credito = vcNumCredito;			
								LET dSdoReduccion = dSdoDisponible * (dPorcReducTp3/100);  -- Monto a reducir
								--	Actualiza el mont de la nueva linea de  credito.
								IF dSdoReduccion > 0 THEN
								
									LET dMonto_LinNva = dMonto_LinOrig - dSdoReduccion;
									UPDATE bdicred:sd_maesdos SET monto_otorgado = dMonto_LinNva WHERE num_credito = vcNumCredito;
									-- Genera transaccion de reduccion
									EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina(TRIM("informix"))INTO cCodRetGenMov, vFolio;
									EXECUTE PROCEDURE GENMOV('001', vcNumCredito, vProducto, 2, '008', vc_dtFechaHoy, dSdoReduccion, vFolio, vsucorig, vDivisa, '6697')
									   INTO cCodRetGenMov, cMsjeGenMov;
									   
									IF cCodRetGenMov::INTEGER <> 0 THEN	-- Si existio un error continua con el siguiente credito	
										UPDATE bdicred:sd_maesdos SET monto_otorgado = dMonto_LinOrig WHERE num_credito = vcNumCredito;
									ELSE
										UPDATE bdicred:"informix".sd_promocion_credito SET sdo_disp_reducido = dSdoReduccion		-- Actualiza informacion en la credisolucion
										 WHERE empresa = '001' AND num_credito = vcNumCredito AND num_promo = sNumPromocion AND ROWID = iRowID;
										 
										-- Inserta registro en bitacora de incremento/reduccion de lineas de credito 
										INSERT INTO bdicred:sd_incremento_reduccion(empresa, tp_parametrico, numcte  , num_credito , meses_ina, bc_score, rango, linea_original, linea_nueva  , 
																					total_mov    , fecha_insert , transaccion_mov, describe_mov                        , descripcion)
																			 VALUES('001',   'R'           , vcNumCte, vcNumCredito, 0        , 0       , ''   , dMonto_LinOrig, dMonto_LinNva, 
																			        dSdoReduccion, vc_dtFechaHoy, '6697'         , 'DISMINUCION PAGOS-FIJOS APOYO 2020', 'Transaccion exitosa');
									END IF;
								END IF;	 
							END IF;
						END IF
					END IF
				END IF
			END IF
		END IF
	END FOREACH

	--RQM 10 1365 Se comenta foreach para no cancelar crÃ©ditos de otras tdc
    /*FOREACH WITH HOLD
        SELECT a.ROWID, a.monto_actual, a.plazo, a.num_promo   , a.nombre_promo, a.num_credito, a.ejecutivo, a.sucursal, a.folio_suc   , a.folio_movto, divisa  , b.sucursal, a.monto_int_iva, a.fecha -- INC 27 127 JHQS 20190626
          INTO iRowID1, dMonto1	      , sPlazo1, sNumPromocion1, cNomPromocion1, vcNumCredito1, cEjecutivo1, cSucursal1, cFolioApertua1, cFolioMovto1 , vDivisa1, vsucorig1 , dMontoIntIVA1  , dFechaPromo1 -- INC 27 127 JHQS 20190626
          FROM bdicred:"informix".sd_promocion_credito a, 
		       bdicred:sd_maecred b,
		       bdicred:sd_maesdos c
         WHERE a.empresa = b.empresa
           AND a.num_credito = b.num_credito
		   AND b.num_credito = c.num_credito
           AND a.status =  0         -->FMV 4ago14: Pendiente de aperturar
           AND b.status_cred <> 'AA'
		   AND (c.monto_vencido + c.mto_venc_trasp) > 0
		   AND a.num_pro_prestamo = '6900'
		UNION
		SELECT a.ROWID, a.monto_actual, a.plazo, a.num_promo   , a.nombre_promo, a.num_credito, a.ejecutivo, a.sucursal, a.folio_suc   , a.folio_movto, divisa  , b.sucursal, a.monto_int_iva, a.fecha -- INC 27 127 JHQS 2019062
          FROM bdicred:"informix".sd_promocion_credito a, bdicred:sd_maecred b
         WHERE a.empresa = b.empresa
           AND a.num_credito = b.num_credito
           AND a.status =  0         -->FMV 4ago14: Pendiente de aperturar
           AND b.num_producto <>'6001'
		   AND a.num_pro_prestamo = '6900'									
		
		-- JHQS 20190628 INC 27 127 {
		LET cFolioApertua1 = TRIM(NVL(cFolioApertua1,''));
		LET cFolioMovto1 = TRIM(NVL(cFolioMovto1,''));
		
        UPDATE bdicred:"informix".sd_promocion_credito SET status = 7
         WHERE empresa = '001' AND num_credito = vcNumCredito1 AND folio_suc = cFolioApertua1 AND num_promo = sNumPromocion1
           AND plazo = sPlazo1 AND folio_movto = cFolioMovto1;
		
		-- Se consulta referencias de retenidos en la tabla sd_maeretenido (para cancelarse por Credito no vigente [sd_promocion_credito.status = 7])
		-- Obtiene referencia de Retenido de la compra
		FOREACH
			
			SELECT referencia, folio_suc INTO vRef, vFolio 
			  FROM "informix".sd_maeretenido
		     WHERE empresa = '001' 
		       AND num_credito = vcNumCredito
			   AND estatus = 'R'
			   AND monto IN(dMonto,dMontoIntIVA)
			   AND fecha = dFechaPromo
			   
			LET vRef = NVL(vRef,'');
			LET vFolio = NVL(vFolio,'');
			
			IF vFolio = cFolioMovto1 THEN
				LET vReferencia = vRef;
			ELIF LEFT(vRef,16) = cFolioApertua1 THEN
				LET vReferencia2 = vRef;
			END IF;
			
		END FOREACH
		
		-- Se agrega cambio de estatus de la tabla sd_maeretenido
		UPDATE "informix".sd_maeretenido SET estatus = 'S'
		 WHERE empresa = '001' 
		   AND num_credito = vcNumCredito1
		   AND referencia IN(vReferencia, vReferencia2)
		   AND estatus = 'R'
		   AND fecha = dFechaPromo1;
		-- } JHQS 20190628 INC 27 127
		   
    END FOREACH*/
       	
	IF cCodRet <> '00000' THEN
        INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',vcNumCredito,'sp_compra_promo',vc_dtFechaHoy,CURRENT,'',sNumPromocion,cCodRet);
    END IF;

	--RETURN cCodRet, TRIM(cMensajeRet);
	RETURN cCodRet, cMensajeRet;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso que realiza la confirmacion de los pagos diferidos',
'AUTOR: Mohamed Carreno ',
'FECHA DE CREACION: 07 de Febrero del 2012',
'VERSION: 20120207.1137',
'BD: bdicred',
'DESCRIPCION: Se agrego la ejecucion del movimiento de la apertura de la compra a meses (genmov_tc)',
'MODIFICO: Valentin Lopez ',
'FECHA: 03 Abril 2012',
'DESCRIPCION MODIFICACION: Se cambia el proceso para agregar la actualizacion del movimiento del retenido de los intereses como reversado para el caso de promotoria y ventanilla',
'MODIFICO: Mohamed Carreno',
'VERSION: 20120608.0909',
'BD: bdicred',
'--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------',
'MODIFICACION',
'RQ         : INC 27 127 Correccion de error en credisoluciones',
'FECHA      : 26 de Junio de 2019',
'DESCRIPCION: Se agrego el cambio de estatus en tabla sd_maeretenido al cancelar por error y al cancelar por credito no vigente',
'MODIFICO   : Jorge Humberto Quintana Santiesteban',
'CC         : 33906',
'--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_ics_obligacion_cred(p_num_ejecucion INTEGER)

	RETURNING
		CHAR(5)							AS cod_ret;


	--Variables--
	DEFINE sql_err 						INTEGER;
	DEFINE v_cod_ret 					CHAR(5);
	--Variables generales--
	DEFINE v_num_cliente				VARCHAR(20);
	DEFINE v_saldo_retenido				DECIMAL;
	DEFINE v_dias_gracia_mora			SMALLINT;
	DEFINE v_fecha_clean_behavior 		DATE;
	DEFINE v_fecha_dirty_behavior 		DATE;
	DEFINE v_behaviour_score_obtenida 	SMALLINT;
	DEFINE v_num_tarjeta 				VARCHAR(20);
	DEFINE v_longitud_tarjeta 			SMALLINT;
	DEFINE v_max_secuencia_tarjeta		INTEGER;
	DEFINE v_fecha_validacion			DATE;
	--Variables para Insertar--
	DEFINE v_identity_code				VARCHAR(13);
	DEFINE v_acc_customer_id			VARCHAR(20);
	DEFINE v_product_id					VARCHAR(20);
	DEFINE v_account_number				VARCHAR(20);
	DEFINE v_cust_branch_id				VARCHAR(15);
	DEFINE c_account_status				VARCHAR(10);
	DEFINE v_work_type					VARCHAR(15);
	DEFINE v_last_entrance_date			DATE;
	DEFINE v_last_entrance_date_char	CHAR(10);
	DEFINE v_days_delinquent			SMALLINT;
	DEFINE v_balance					DECIMAL(15,2);
	DEFINE v_delinquency				DECIMAL(15,2);
	DEFINE v_original_balance			DECIMAL(15,2);
	DEFINE v_principal_balance			DECIMAL(15,2);
	DEFINE v_interest_balance			DECIMAL(15,2);
	DEFINE v_principal_delinquent		DECIMAL(15,2);
	DEFINE v_interest_delinquent		DECIMAL(15,2);
	DEFINE v_overlimit					DECIMAL(15,2);
	DEFINE v_credit_limit				DECIMAL(15,2);
	DEFINE v_insurance_amount			DECIMAL(15,2);
	DEFINE v_collection_chargue			DECIMAL(15,2);
	DEFINE v_disputed_amount			DECIMAL(15,2);
	DEFINE v_provisioned_amount			VARCHAR(10);
	DEFINE v_interest_rate				DECIMAL(8,5);
	DEFINE v_cycle_day					SMALLINT;
	DEFINE v_billing_day				SMALLINT;
	DEFINE v_payment_frequency          SMALLINT;
	DEFINE v_payment_frequency_char		CHAR(1);
	DEFINE v_credit_score				SMALLINT;
	DEFINE v_behaviour_score			SMALLINT;
	DEFINE v_principal_delinquency_0	DECIMAL(15,2);
	DEFINE v_principal_delinquency_1	DECIMAL(15,2);
	DEFINE v_principal_delinquency_2	DECIMAL(15,2);
	DEFINE v_principal_delinquency_3	DECIMAL(15,2);
	DEFINE v_principal_delinquency_4	DECIMAL(15,2);
	DEFINE v_principal_delinquency_5	DECIMAL(15,2);
	DEFINE v_principal_delinquency_6	DECIMAL(15,2);
	DEFINE v_delinquency_0				DECIMAL(15,2);
	DEFINE v_delinquency_1				DECIMAL(15,2);
	DEFINE v_delinquency_2				DECIMAL(15,2);
	DEFINE v_delinquency_3				DECIMAL(15,2);
	DEFINE v_delinquency_4				DECIMAL(15,2);
	DEFINE v_delinquency_5				DECIMAL(15,2);
	DEFINE v_delinquency_6				DECIMAL(15,2);
	DEFINE v_due_date_0					DATE;
	DEFINE v_due_date_0_char			CHAR(10);
	DEFINE v_due_date_1					DATE;
	DEFINE v_due_date_1_char			CHAR(10);
	DEFINE v_due_date_2					DATE;
	DEFINE v_due_date_2_char			CHAR(10);
	DEFINE v_due_date_3					DATE;
	DEFINE v_due_date_3_char			CHAR(10);
	DEFINE v_due_date_4					DATE;
	DEFINE v_due_date_4_char			CHAR(10);
	DEFINE v_due_date_5					DATE;
	DEFINE v_due_date_5_char			CHAR(10);
	DEFINE v_due_date_6					DATE;
	DEFINE v_due_date_6_char			CHAR(10);
	DEFINE v_opening_date				DATE;
	DEFINE v_opening_date_char			CHAR(10);
	DEFINE v_wite_off_date 				DATE;
	DEFINE char_v_wite_off_date 		CHAR(10);
	DEFINE v_payment_date				DATE;
	DEFINE v_payment_date_char			CHAR(10);
	DEFINE v_prescription_date			DATE;
	DEFINE v_prescription_date_char		CHAR(10);
	DEFINE v_last_rest_date				DATE;
	DEFINE v_last_rest_date_char		CHAR(10);
	DEFINE v_return_id 					VARCHAR(80);
	DEFINE v_user_defined1				VARCHAR(16);
	DEFINE v_qualification				VARCHAR(10);
	DEFINE v_session_id					VARCHAR(200);
	DEFINE v_update_online				DATE;
	DEFINE c_fecha_ejecucion			DATE;
	DEFINE v_fecha_inicial				DATE;
	DEFINE v_fecha_final				DATE;
	DEFINE v_valor_inicial 				INT8;
	DEFINE v_valor_final				INT8;
	
	--Valores por Default--
	DEFINE c_reviewed					CHAR(1);
	DEFINE c_expiration_date			DATE;
	DEFINE char_expiration_date			CHAR(10);
	
	--Variables de definiciÃ?ÃÂ³n SP
	DEFINE codRet_sp_sdos				CHAR(6);
	DEFINE v_cap_trans 					DECIMAL(18,2);
	DEFINE v_cap_vdo_exig 				DECIMAL(18,2);
	DEFINE v_int_vdo 					DECIMAL(18,2);
	DEFINE v_int_moratorios 			DECIMAL(18,2);
	DEFINE v_iva_int_vdo 				DECIMAL(18,2);
	DEFINE v_iva_int_moratorios 		DECIMAL(18,2);
	DEFINE v_com_pend 					DECIMAL(18,2);
	DEFINE v_iva_com 					DECIMAL(18,2);
	DEFINE v_total_liquidacion 			DECIMAL(18,2);
	DEFINE v_tiempo_obligaciones		VARCHAR(20);
	
	DEFINE v_comodin_char_sp 			CHAR(80);
	DEFINE v_comodin_date_sp 			DATE;
	DEFINE v_comodin_decimal_sp 		DECIMAL(18,2);
	DEFINE v_comodin_int_sp 			INTEGER;
	DEFINE v_capital_debe				DECIMAL(18,2);
	DEFINE v_capital_pagado				DECIMAL(18,2);
	DEFINE v_proceso 					VARCHAR(50);				
	DEFINE iContador 					INTEGER;
	
	DEFINE horaActual					DATETIME YEAR TO FRACTION(5);
	DEFINE iContador1 					INTEGER;
	DEFINE v_transaccion				INTEGER;
	DEFINE v_activo_ics					BOOLEAN;
	DEFINE v_overdue_payments			INTEGER;
	DEFINE v_fecha_desactivado_ics		DATE;
	
	LET v_cod_ret 						= '00000';
	LET sql_err 						= NULL;
	
	--Variables generales--
	LET v_capital_debe					= 0.0;
	LET v_capital_pagado				= 0.0;
	LET v_num_cliente					= NULL;
	LET v_saldo_retenido				= 0.0;
	LET v_dias_gracia_mora				= 0;
	LET v_fecha_clean_behavior 			= NULL;
	LET v_fecha_dirty_behavior 			= NULL;
	LET v_behaviour_score_obtenida 		= 0;
	LET v_num_tarjeta 					= NULL;
	LET v_longitud_tarjeta 				= 0;
	LET v_max_secuencia_tarjeta			= NULL;
	LET v_payment_frequency_char  		= NULL;
	LET v_fecha_validacion				= NULL;
	--Variables para Insertar--
	LET v_identity_code					= NULL;
	LET v_acc_customer_id				= NULL;
	LET v_product_id					= NULL;
	LET v_account_number				= NULL;
	LET v_cust_branch_id				= NULL;
	LET v_work_type						= NULL;
	LET v_last_entrance_date			= NULL;
	LET v_last_entrance_date_char		= NULL;
	LET v_days_delinquent				= NULL;
	LET v_balance						= 0.0;
	LET v_delinquency					= 0.0;
	LET v_original_balance				= 0.0;
	LET v_principal_balance				= 0.0;
	LET v_interest_balance				= 0.0;
	LET v_principal_delinquent			= 0.0;
	LET v_interest_delinquent			= 0.0;
	LET v_overlimit						= 0.0;
	LET v_credit_limit					= 0.0;
	LET v_insurance_amount				= 0.0;
	LET v_disputed_amount				= 0.0;
	LET v_provisioned_amount			= NULL;
	LET v_interest_rate					= 0.0;
	LET v_collection_chargue			= 0.0; 
	LET v_cycle_day						= 0;
	LET v_billing_day					= 0;
	LET v_payment_frequency				= 0;
	LET v_credit_score					= 0;
	LET v_behaviour_score				= 0;
	LET v_principal_delinquency_0		= 0.0;
	LET v_principal_delinquency_1		= 0.0;
	LET v_principal_delinquency_2		= 0.0;
	LET v_principal_delinquency_3		= 0.0;
	LET v_principal_delinquency_4		= 0.0;
	LET v_principal_delinquency_5		= 0.0;
	LET v_principal_delinquency_6		= 0.0;
	LET v_delinquency_0					= 0.0;
	LET v_delinquency_1					= 0.0;
	LET v_delinquency_2					= 0.0;
	LET v_delinquency_3					= 0.0;
	LET v_delinquency_4					= 0.0;
	LET v_delinquency_5					= 0.0;
	LET v_delinquency_6					= 0.0;
	LET v_due_date_0					= NULL;
	LET v_due_date_0_char				= NULL;
	LET v_due_date_1					= NULL;
	LET v_due_date_1_char				= NULL;
	LET v_due_date_2					= NULL;
	LET v_due_date_2_char				= NULL;
	LET v_due_date_3					= NULL;
	LET v_due_date_3_char				= NULL;
	LET v_due_date_4					= NULL;
	LET v_due_date_4_char				= NULL;
	LET v_due_date_5					= NULL;
	LET v_due_date_5_char				= NULL;
	LET v_due_date_6					= NULL;
	LET v_due_date_6_char				= NULL;
	LET v_wite_off_date					= mdy(01,01,1900);
	LET char_v_wite_off_date			= NULL;
	LET v_payment_date					= NULL;
	LET v_opening_date_char				= NULL;
	LET v_prescription_date				= NULL;
	LET v_prescription_date_char		= NULL;
	LET v_last_rest_date				= NULL;
	LET v_last_rest_date_char			= NULL;
	LET v_return_id 					= NULL;
	LET v_user_defined1					= NULL;
	LET v_qualification					= NULL;
	LET v_session_id 					= 'PENDING';
	LET v_update_online					= NULL;
	LET c_fecha_ejecucion				= NULL;
	
	LET c_reviewed						= 'N';
	LET c_expiration_date				= mdy(01,01,1900);
	LET c_account_status 				= 'ACTIVE';
	LET char_expiration_date			= NULL;
	
	LET iContador 						= 0;
	
	LET horaActual						= NULL;
	LET iContador1 						= 0;
	LET v_valor_inicial 				= 0;
	LET v_valor_final				    = 0;
	LET v_fecha_inicial					= NULL;
	LET v_fecha_final					= NULL;
	LET v_transaccion					= 0;
	LET v_activo_ics					= NULL;
	LET v_proceso ='';
	LET v_overdue_payments				= 0;
	LET v_fecha_desactivado_ics			= NULL;
        
        --SET DEBUG FILE TO "//resplogifx/cobranza/obligacion_pruebas.out"; --Este es el SP actual y funcional
        --TRACE ON;	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION SET sql_err
			
			INSERT INTO "informix".ics_control_errores(num_credito, numcte, num_producto, descripcion_error, proceso, fecha_insert)
				VALUES(v_account_number, v_num_cliente, v_acc_customer_id, sql_err, v_proceso, CURRENT);
			
			IF v_transaccion = 1 Then
				COMMIT WORK;
			End IF
			
			IF sql_err <> 0 THEN
				LET v_cod_ret = sql_err;
				RETURN v_cod_ret;
		    END IF;
		END EXCEPTION;
		ON EXCEPTION IN (-535)
			  --ROLLBACK WORK;
			  --COMMIT WORK;

			  --BEGIN WORK;
			  LET v_transaccion = 1;
			  INSERT INTO "informix".ics_control_errores(num_credito, numcte, num_producto,descripcion_error, proceso, fecha_insert)
			  VALUES( v_account_number, v_num_cliente, v_acc_customer_id, 'ERROR -535 obligaciones',v_proceso, CURRENT);
			    COMMIT WORK;
				BEGIN WORK;

		 END EXCEPTION WITH RESUME;
		--SELECT fecha_hoy 
		--	INTO c_fecha_ejecucion
		--FROM bdinteg:si_fechas;
		
		--TRUNCATE TABLE ics_obligacion_2;
		
		
		/*DROP INDEX IF EXISTS informix.ics_obligacion_idx_fec_eje_2 ONLINE;
		DROP INDEX IF EXISTS informix.index_primerio ONLINE;
		DROP INDEX IF EXISTS informix.ics_obligacion_idx_acc_2 ONLINE;
		DROP INDEX IF EXISTS informix.ics_obligacion_idx_user_defined_2 ONLINE;*/
		LET v_tiempo_obligaciones = 'IN_OBLIGACION'||'_'||p_num_ejecucion;
		
		SELECT DBINFO("utc_to_datetime", sh_curtime) 
			INTO horaActual 
		FROM sysmaster:sysshmvals;
		INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (iContador1, horaActual, v_tiempo_obligaciones);
		
		BEGIN WORK;
			 LET v_transaccion = 1;
			 LET v_proceso = 'Creditos Revolventes ObligaciÃÂ³n';
			SELECT valor_inicial, valor_final, fecha_ejecucion
				INTO v_valor_inicial, v_valor_final, c_fecha_ejecucion
			FROM ics_numero_proceso 
			WHERE numero_hilo = p_num_ejecucion and tipo_cred='1';
			
				/*SELECT 
					mc.numcte, mc.num_producto, mc.num_credito, mc.sucursal, mc.status_cred, 
					mc.tasa_interes, mc.bandera_ministra, mc.fecha_apertura, mc.balance, mc.delinquency, mc.principal_delinquent, 
					mc.interest_delinquent, mc.collection_chargue, mc.rfc
				INTO
					v_num_cliente, v_acc_customer_id, v_account_number, v_cust_branch_id, v_work_type, 
					v_interest_rate, v_payment_frequency_char, v_opening_date, v_balance, v_delinquency, v_principal_delinquent, v_interest_delinquent, v_collection_chargue
				FROM ics_clientes_2 mc WHERE mc.tipo_cred = '1' AND ics_consecutivo BETWEEN v_valor_inicial AND v_valor_final
				INTO TEMP temp_obligaciones_cred WITH NO LOG;*/
			
			
			
			FOREACH WITH HOLD
			
			
				--Select num_credito  INTO v_account_number FROM ics_creditos_obligaciones
			
				SELECT 
					mc.numcte, mc.num_producto, mc.num_credito, mc.sucursal, mc.status_cred, 
					mc.tasa_interes, mc.bandera_ministra, mc.fecha_apertura, mc.balance, mc.delinquency, mc.principal_delinquent, mc.interest_delinquent, 
					mc.collection_chargue, mc.rfc, mc.pagos_vencidos
				INTO
					v_num_cliente, v_acc_customer_id, v_account_number, v_cust_branch_id, v_work_type, 
					v_interest_rate, v_payment_frequency_char, v_opening_date, v_balance, v_delinquency, v_principal_delinquent, v_interest_delinquent, 
					v_collection_chargue, v_identity_code, v_overdue_payments
				FROM ics_clientes mc WHERE mc.tipo_cred = '1' AND /*proceso = p_num_ejecucion--*/ num_credito BETWEEN v_valor_inicial AND v_valor_final
				
				/*SELECT df.num_producto
					INTO v_product_id
				FROM sd_definicion df 
				WHERE num_producto= v_acc_customer_id;*/
				
				 
				
				SELECT limit 1 activo_ics, fecha_desactivado_ics into v_activo_ics, v_fecha_desactivado_ics FROM ics_maectrl where num_credito = v_account_number;
				
				IF v_activo_ics = 'f' AND v_fecha_desactivado_ics = (c_fecha_ejecucion + 1) THEN
					LET c_account_status 				= 'INACTIVE';
				ELSE
					LET c_account_status 				= 'ACTIVE';
				END IF;
				
				
				LET v_product_id = v_acc_customer_id;
				
				IF v_acc_customer_id IN ('6001','6011','6500','6600','6900','7000','7200','7500','8100','8500', '5400') THEN
					LET v_acc_customer_id = 'TARJETA DE CREDITO';
				END IF;
				
				IF v_acc_customer_id IN ('6300','6800','7300','7600','7700','8600','9100','9300') THEN
					LET v_acc_customer_id = 'PRESTAMO PERSONAL';
				END IF;
				
				IF v_acc_customer_id IN ('6400','7400','7800') THEN
					LET v_acc_customer_id = 'NOMINA';
				END IF;
				
				/*SELECT rfc
					INTO v_identity_code
				FROM bdinteg:si_cliente 
				WHERE numcte = v_num_cliente;*/
				
				SELECT limit 1 dias_atraso, intereses_periodo_ch
					INTO v_days_delinquent, v_interest_balance
				FROM sd_indicador_cred
				WHERE num_credito = v_account_number;
				
				SELECT limit 1 monto_otorgado, sdo_cap_insoluto, sdo_retenido
					INTO v_original_balance, v_principal_balance, v_saldo_retenido
				FROM sd_maesdos
				WHERE num_credito = v_account_number;
				
				SELECT limit 1 dia_corte, dias_gracia_mora, prox_fecha_pago
					INTO v_cycle_day, v_dias_gracia_mora, v_payment_date
				FROM sd_maecredanexo
				WHERE num_credito = v_account_number;
				
				Select limit 1 bs_score 
					INTO v_credit_score
				FROM  bdisolic:ss_revision_determinacion	
					WHERE num_solicitud = v_account_number;
					
				IF v_principal_balance < 0 THEN --Si el Capital Insoluto es Negativo, solo se resta el Saldo Retenido
					LET v_credit_limit = v_original_balance - v_saldo_retenido;
				ELSE
					LET v_credit_limit = v_original_balance - v_principal_balance - v_saldo_retenido;
				END IF
				
				IF v_payment_frequency_char = 'M' THEN --Revisar que valores se deben insertar para los periodos
					LET v_payment_frequency = 30;
				ELSE
					LET v_payment_frequency = 15;
				END IF
				
				LET v_billing_day = v_cycle_day - v_dias_gracia_mora;
				
				/*SELECT balance, delinquency, principal_delinquent, interest_delinquent, collection_chargue
					INTO v_balance, v_delinquency, v_principal_delinquent, v_interest_delinquent, v_collection_chargue
				FROM ics_clientes_2
				WHERE num_credito = v_account_number;*/
				--
				
				--ObtenciÃÂ³n del Behavor_score
				SELECT MAX(fecha_reporte) 
					INTO v_fecha_clean_behavior
				FROM sd_clientes_clean_behavior 
					WHERE num_credito = v_account_number AND status_bit IS NULL;

				SELECT MAX(fecha_reporte) 
					INTO v_fecha_dirty_behavior
				FROM sd_clientes_dirty_behavior 
					WHERE num_credito = v_account_number AND status_bit IS NULL;
				
				IF v_fecha_dirty_behavior IS NULL THEN
					SELECT limit 1 REPLACE(score,CHR (13))::SMALLINT as score -- JVG G4
						INTO v_behaviour_score
					FROM sd_clientes_clean_behavior
					WHERE num_credito = v_account_number 
						AND fecha_reporte = v_fecha_clean_behavior;
					
					LET v_behaviour_score_obtenida = 1;
				END IF
				
				IF v_fecha_clean_behavior IS NULL THEN
					SELECT limit 1 REPLACE(score,CHR (13))::SMALLINT as score
						INTO v_behaviour_score
					FROM sd_clientes_dirty_behavior
					WHERE num_credito = v_account_number 
						AND fecha_reporte = v_fecha_dirty_behavior;
					
					LET v_behaviour_score_obtenida = 1;
				END IF
				
				IF v_behaviour_score_obtenida = 0 THEN
					IF v_fecha_dirty_behavior > v_fecha_dirty_behavior THEN
						SELECT limit 1 REPLACE(score,CHR (13))::SMALLINT as score
							INTO v_behaviour_score
						FROM sd_clientes_dirty_behavior
						WHERE num_credito = v_account_number 
							AND fecha_reporte = v_fecha_dirty_behavior;
					ELSE
						SELECT limit 1 REPLACE(score,CHR (13))::SMALLINT as score
							INTO v_behaviour_score
						FROM sd_clientes_clean_behavior
						WHERE num_credito = v_account_number 
							AND fecha_reporte = v_fecha_clean_behavior;
					END IF
				END IF
				--Fin ObtenciÃÂ³n del Behavor_score
				
				--ObtenciÃÂ³n monto en disputa (aclaraciones)
				-- SELECT SUM(importereclamado) 
					-- INTO v_disputed_amount
				-- FROM bdiaclaracion:acl_aclaracion 
					-- WHERE fky_estatus_aclaracion = 2 and num_cliente = v_num_cliente;
					
				---==== Se obtienen todos los registros de la amortiza por numero de credito
				/*Select * FROM sd_amortiza_credito 
					WHERE num_credito = v_account_number INTO TEMP ics_amortiza_credito WITH NO LOG;*/
					
				LET v_fecha_inicial =c_fecha_ejecucion;
				LET v_fecha_final = add_months(c_fecha_ejecucion, 1);
				
				--Principal_delinquency_0 
				SELECT limit 1 fecha_cuota, capital_debe, capital_pagado
					INTO  v_due_date_0, v_capital_debe, v_capital_pagado
				FROM sd_amortiza_credito 
					WHERE num_credito = v_account_number AND capital_status in (1,2,6,7)
					and fecha_cuota between v_fecha_inicial and v_fecha_final;
				
				LET v_principal_delinquency_0 = v_capital_debe - v_capital_pagado;
				LET v_delinquency_0 = v_principal_delinquency_0;
				--Final Principal_delinquency_0
				
				
				LET v_fecha_inicial = add_months(c_fecha_ejecucion, -1);
				LET v_fecha_final = c_fecha_ejecucion;
				
				--Principal_delinquency_1 
				SELECT limit 1 fecha_cuota, capital_debe, capital_pagado
					INTO  v_due_date_1, v_capital_debe, v_capital_pagado
				FROM sd_amortiza_credito 
					WHERE num_credito = v_account_number AND capital_status in (1,2,6,7)
					and fecha_cuota between v_fecha_inicial and v_fecha_final;
				
				LET v_principal_delinquency_1 = v_capital_debe - v_capital_pagado;
				LET v_delinquency_1 = v_principal_delinquency_0 + v_principal_delinquency_1;
				--Final Principal_delinquency_1
				
				SELECT MIN(fecha_cuota) 
					INTO v_due_date_6
				FROM sd_amortiza_credito 
					WHERE num_credito = v_account_number AND capital_status in (1,2,6,7);
				
				LET v_fecha_validacion = add_months(v_due_date_0,-2);
				
				--Principal_delinquency_2 
				IF v_fecha_validacion >= v_due_date_6 THEN 
					LET v_fecha_inicial = add_months(c_fecha_ejecucion, -2);
					LET v_fecha_final = add_months(c_fecha_ejecucion, -1);
				
				
					SELECT limit 1 fecha_cuota, capital_debe, capital_pagado
						INTO  v_due_date_2, v_capital_debe, v_capital_pagado
					FROM sd_amortiza_credito 
						WHERE num_credito = v_account_number AND capital_status in (2,6,7)
						and fecha_cuota between v_fecha_inicial and v_fecha_final;
				
					LET v_principal_delinquency_2 = v_capital_debe - v_capital_pagado;
					LET v_delinquency_2 = v_principal_delinquency_0 + v_principal_delinquency_1 + v_principal_delinquency_2;
				ELSE
					LET v_due_date_2 = NULL;
					LET v_principal_delinquency_2= NULL;
					LET v_delinquency_2 = NULL;
				END IF;
				--Final Principal_delinquency_2
				
				LET v_fecha_validacion = add_months(v_due_date_0,-3);
				
				--Principal_delinquency_3 
				IF v_fecha_validacion >= v_due_date_6 THEN
					
					LET v_fecha_inicial = add_months(c_fecha_ejecucion, -3);
					LET v_fecha_final = add_months(c_fecha_ejecucion, -2);
					
					
					SELECT limit 1 fecha_cuota, capital_debe, capital_pagado
						INTO  v_due_date_3, v_capital_debe, v_capital_pagado
					FROM sd_amortiza_credito 
						WHERE num_credito = v_account_number AND capital_status in (2,6,7)
						and fecha_cuota between v_fecha_inicial and v_fecha_final;
				
					LET v_principal_delinquency_3 = v_capital_debe - v_capital_pagado;
					LET v_delinquency_3 = v_principal_delinquency_0 + v_principal_delinquency_1 + v_principal_delinquency_2 + v_principal_delinquency_3;
				ELSE
					LET v_due_date_3 = NULL;
					LET v_principal_delinquency_3= NULL;
					LET v_delinquency_3 = NULL;
				END IF;
				--Final Principal_delinquency_3
				
				LET v_fecha_validacion = add_months(v_due_date_0,-4);
				
				--Principal_delinquency_4
				IF v_fecha_validacion >= v_due_date_6 THEN
					
					LET v_fecha_inicial = add_months(c_fecha_ejecucion, -4);
					LET v_fecha_final = add_months(c_fecha_ejecucion, -3);
					
					SELECT limit 1 fecha_cuota, capital_debe, capital_pagado
						INTO  v_due_date_4, v_capital_debe, v_capital_pagado
					FROM sd_amortiza_credito 
						WHERE num_credito = v_account_number AND capital_status in (2,6,7)
						and fecha_cuota between v_fecha_inicial and v_fecha_final;
					
					LET v_principal_delinquency_4 = v_capital_debe - v_capital_pagado;
					LET v_delinquency_4 = v_principal_delinquency_0 + v_principal_delinquency_1 + v_principal_delinquency_2 + v_principal_delinquency_3 + v_principal_delinquency_4;
				ELSE
					LET v_due_date_4 = NULL;
					LET v_principal_delinquency_4= NULL;
					LET v_delinquency_4 = NULL;
				END IF;
				--Final Principal_delinquency_4
				
				LET v_fecha_validacion = add_months(v_due_date_0,-5);
				
				--Principal_delinquency_5
				IF v_fecha_validacion >= v_due_date_6 THEN
					
					LET v_fecha_inicial = add_months(c_fecha_ejecucion, -5);
					LET v_fecha_final = add_months(c_fecha_ejecucion, -4);
					
					SELECT limit 1 fecha_cuota, capital_debe, capital_pagado
						INTO  v_due_date_5, v_capital_debe, v_capital_pagado
					FROM sd_amortiza_credito 
						WHERE num_credito = v_account_number AND capital_status in (2,6,7)
						and fecha_cuota between v_fecha_inicial and v_fecha_final;
				
					LET v_principal_delinquency_5 = v_capital_debe - v_capital_pagado;
					LET v_delinquency_5 = v_principal_delinquency_0 + v_principal_delinquency_1 + v_principal_delinquency_2 + v_principal_delinquency_3 + v_principal_delinquency_4 +
									  v_principal_delinquency_5;
				ELSE
					LET v_due_date_5 = NULL;
					LET v_principal_delinquency_5= NULL;
					LET v_delinquency_5 = NULL;
				END IF;
				--Final Principal_delinquency_5
				
			
				--Principal_delinquency_6
				IF v_principal_delinquency_5 IS NOT NULL THEN
					--LET v_fecha_inicial = add_months(c_fecha_ejecucion, -5);
					LET v_fecha_final = add_months(c_fecha_ejecucion, -5);
					
					SELECT SUM(capital_debe), SUM(capital_pagado)
						INTO  v_capital_debe, v_capital_pagado
					FROM sd_amortiza_credito 
						WHERE num_credito = v_account_number AND capital_status in (2,6,7)
						and fecha_cuota between v_due_date_6 and v_fecha_final;
					
					LET v_principal_delinquency_6 = v_capital_debe - v_capital_pagado;
					LET v_delinquency_6 = v_principal_delinquency_0 + v_principal_delinquency_1 + v_principal_delinquency_2 + v_principal_delinquency_3 + v_principal_delinquency_4 +
										  v_principal_delinquency_5 + v_principal_delinquency_6;
				ELSE
					LET v_due_date_6 = NULL;
					LET v_principal_delinquency_6= NULL;
					LET v_delinquency_6 = NULL;
				END IF;
				--Final Principal_delinquency_6
				
				IF v_work_type = 'CV' OR v_work_type = 'FC' THEN
					SELECT limit 1 fecha 
						INTO v_prescription_date
					FROM sd_maecred_vendida 
						WHERE num_credito = v_account_number;
				END IF
				
				IF v_work_type = 'FC' THEN
					
					LET v_last_rest_date = v_prescription_date;
					/*SELECT fecha 
						INTO v_last_rest_date
					FROM sd_maecred_vendida 
						WHERE num_credito = v_account_number;*/
				END IF
				
				--OJO: Los tamaÃ?ÃÂ±os de las variables no son las mismas; sin embargo, el tamaÃ?ÃÂ±o real de la variable es de 9:
				LET v_user_defined1 = TRIM(v_num_cliente);

				
				--Ultimo 4 digistos de la tarjeta
				SELECT MAX(secuencia)
					INTO v_max_secuencia_tarjeta
				FROM sd_tarjeta 
					WHERE num_credito = v_account_number AND tipo_tarjeta = 'T';
				
				SELECT limit 1 num_tarjeta
					INTO v_num_tarjeta
				FROM sd_tarjeta 
					WHERE num_credito = v_account_number AND tipo_tarjeta = 'T' 
						AND secuencia = v_max_secuencia_tarjeta;
				
				
				LET v_longitud_tarjeta = length(trim(v_num_tarjeta)); 
				LET v_qualification = SUBSTR(v_num_tarjeta,(v_longitud_tarjeta-3),v_longitud_tarjeta);
				
				SELECT FIRST 1 reserva	
					INTO v_provisioned_amount
				FROM ics_reserva_credito
					WHERE num_credito = v_account_number;
					
				LET v_provisioned_amount = replace(replace(v_provisioned_amount,chr(13),''),chr(10),'');
				LET v_last_entrance_date = c_fecha_ejecucion;
				LET v_last_entrance_date_char = TO_CHAR(v_last_entrance_date,'%d/%m/%Y');
				LET v_due_date_0_char = TO_CHAR(v_due_date_0,'%d/%m/%Y');
				LET v_due_date_1_char = TO_CHAR(v_due_date_1,'%d/%m/%Y');
				LET v_due_date_2_char = TO_CHAR(v_due_date_2,'%d/%m/%Y');
				LET v_due_date_3_char = TO_CHAR(v_due_date_3,'%d/%m/%Y');
				LET v_due_date_4_char = TO_CHAR(v_due_date_4,'%d/%m/%Y');
				LET v_due_date_5_char = TO_CHAR(v_due_date_5,'%d/%m/%Y');
				LET v_due_date_6_char = TO_CHAR(v_due_date_6,'%d/%m/%Y');
				LET v_opening_date_char = TO_CHAR(v_opening_date,'%d/%m/%Y');
				LET v_payment_date_char = TO_CHAR(v_payment_date,'%d/%m/%Y');
				LET v_prescription_date_char = TO_CHAR(v_prescription_date,'%d/%m/%Y');
				LET v_last_rest_date_char = TO_CHAR(v_last_rest_date,'%d/%m/%Y');
				LET char_expiration_date = TO_CHAR(c_expiration_date,'%d/%m/%Y');
				LET char_v_wite_off_date = TO_CHAR(v_wite_off_date,'%d/%m/%Y');
				
				
				
				IF v_credit_limit < 0 THEN
					LET v_credit_limit = 0;
				END IF;
				
				INSERT INTO ics_obligacion
					(identity_code, acc_customer_id, product_id, account_number, cust_branch_id, account_status, work_type, 
					reviewed, last_entrance_date, days_delinquent, balance, delinquency, original_balance, principal_balance, interest_balance, 
					principal_delinquent, interest_delinquent, over_limit, credit_limit, insurance_amount, collection_chargue, disputed_amount, provisioned_amount, interest_rate, 
					cycle_day, billing_day, payment_frequency, credit_score, behaviour_score, principal_delinquency_0, 
					principal_delinquency_1, principal_delinquency_2, principal_delinquency_3, principal_delinquency_4, 
					principal_delinquency_5, principal_delinquency_6, delinquency_0, delinquency_1, delinquency_2, 
					delinquency_3, delinquency_4, delinquency_5, delinquency_6, due_date_0, due_date_1, due_date_2, 
					due_date_3, due_date_4, due_date_5, due_date_6, opening_date, wite_off_date, payment_date, prescription_date, 
					expiration_date, last_rest_date, return_id, user_defined1, qualification, session_id, update_online, fecha_ejecucion, overdue_payments)
				VALUES
					(v_identity_code,v_acc_customer_id, v_product_id, v_account_number, v_cust_branch_id, c_account_status, v_work_type, 
					c_reviewed, v_last_entrance_date_char, v_days_delinquent, v_balance, v_delinquency, v_original_balance, v_principal_balance, v_interest_balance, 
					v_principal_delinquent, v_interest_delinquent, v_overlimit, v_credit_limit, v_insurance_amount, v_collection_chargue, v_disputed_amount, v_provisioned_amount, v_interest_rate, 
					v_cycle_day, v_billing_day, v_payment_frequency, v_credit_score, v_behaviour_score, v_principal_delinquency_0, 
					v_principal_delinquency_1, v_principal_delinquency_2, v_principal_delinquency_3, v_principal_delinquency_4, 
					v_principal_delinquency_5, v_principal_delinquency_6, v_delinquency_0, v_delinquency_1, v_delinquency_2, 
					v_delinquency_3, v_delinquency_4, v_delinquency_5, v_delinquency_6, v_due_date_0_char, v_due_date_1_char, v_due_date_2_char, 
					v_due_date_3_char, v_due_date_4_char, v_due_date_5_char, v_due_date_6_char, v_opening_date_char, char_v_wite_off_date, v_payment_date_char, v_prescription_date_char, 
					char_expiration_date, v_last_rest_date_char, v_return_id, v_user_defined1, v_qualification, v_session_id, v_update_online, c_fecha_ejecucion, v_overdue_payments);
				
				
				
				--IF v_valor_inicial = v_valor_final THEN
				--	EXIT FOREACH;
				--END IF;
				
				--LET v_valor_inicial = v_valor_inicial + 1;
				
				--LET v_valor_inicial = 
				
				LET iContador1 = iContador1 + 1;
				--DROP  TABLE ics_amortiza_credito;
				/*IF iContador1 >= 100000 THEN
					SELECT DBINFO("utc_to_datetime", sh_curtime) 
						INTO horaActual 
					FROM sysmaster:sysshmvals;
					INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (iContador1, horaActual, 'CICLO_OBLIGACION');
					LET iContador1 = 0;
				END IF; */
				
				LET iContador = iContador + 1;
				
				IF iContador >= 5000 THEN
					COMMIT WORK;
					LET iContador = 0;
					BEGIN WORK;
				END IF; 
				
			END FOREACH;
			
			LET v_tiempo_obligaciones = 'FIN__OBLIGACION'||'_'||p_num_ejecucion;
			
			SELECT DBINFO("utc_to_datetime", sh_curtime) 
				INTO horaActual 
			FROM sysmaster:sysshmvals;
			INSERT INTO ics_tiempos (num_registro, hora, proceso) VALUES (iContador1, horaActual, v_tiempo_obligaciones);
			
			
		COMMIT WORK;
		
		LET v_transaccion = 0;
		
	/*CREATE INDEX informix.ics_obligacion_idx_fec_eje_2  ON "informix".ics_obligacion_2(fecha_ejecucion);
	
	CREATE INDEX informix.index_primerio ON "informix".ics_obligacion_2(identity_code, account_number, fecha_ejecucion);
	
	CREATE INDEX informix.ics_obligacion_idx_acc_2   ON "informix".ics_obligacion_2(account_number);
	
	CREATE INDEX informix.ics_obligacion_idx_user_defined_2  ON "informix".ics_obligacion_2(user_defined1);*/
		
		
		
		
	
		RETURN v_cod_ret;
			
	END;
END PROCEDURE
DOCUMENT
'Sistema		:	iCS',
'CreaciÃÂ³n		:	BanCoppel',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Oct 2021',
'Requerimiento	:	RQM 09 596',
'VERSION		: 	1.0.0';

CREATE PROCEDURE "informix".sp_obtiene_info_rep_edc_tdc(v_num_credito CHAR(20), v_numcte CHAR(20), v_fecha_consul DATE, v_fecha_corte_edc DATE, v_sin_servicio CHAR(1),
														v_view_down	CHAR(1), v_no_view_down CHAR(1), v_si_serv_sin_view CHAR(1),v_canal CHAR(4)
														)

RETURNING 	--CHAR(255) AS Mensaje_Salida, 
			CHAR(5) AS Codigo_Retorno;
-- CANAL MAIL: 5000
-- CANAL APP : 5011
-- CANAL BPI : 5003

-- ************************************************************
-- *** DECLARACION DE VARIABLES INTERNAS DEL STORED PROCEDURE ***
-- ************************************************************
DEFINE iSqlErr                  INTEGER;     
DEFINE iIsamErr                 INTEGER; 
DEFINE cCodRet                  CHAR(5);
DEFINE cErrorInfo               VARCHAR(255); 
DEFINE cMensajeSalida			CHAR(150);
DEFINE v_x_mail                 CHAR(2);
DEFINE v_x_app_movil            CHAR(2);
DEFINE v_x_suc_web              CHAR(2);
DEFINE v_mto_comi               DECIMAL(18,2);
DEFINE v_mto_mora               DECIMAL(18,2);	
DEFINE v_fecha_hoy              DATE;
DEFINE v_ult_dia_mes            DATE;
DEFINE vCanal_aprob				CHAR(4);
DEFINE v_num_proceso			CHAR(4);

-- ************************************************************
-- *** INICIALIZACION DE VARIABLES ***
-- ************************************************************

LET iSqlErr                     = 0;
LET iIsamErr                    = 0;
LET cCodRet                     = '00000';
LET cErrorInfo                  = '';
LET cMensajeSalida              = 'PROCESO EXITOSO';
LET v_x_mail                    = '';
LET v_x_app_movil               = '';
LET v_x_suc_web                 = '';
LET v_mto_comi                  = 0;
LET v_mto_mora                  = 0;
LET v_fecha_hoy                 = DATE(1);
LET vCanal_aprob				= '';
LET v_num_proceso				= '0017';

-- ************************************************************
-- *** BLOQUE PRINCIPAL DEL STORED PROCEDURE ***
-- ************************************************************
BEGIN -- Inicio del bloque principal del SP

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			DROP TABLE IF EXISTS tmp_canales;
			--LET cMensajeSalida = cErrorInfo;
			RETURN TRIM('00000');
			
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;  
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
--SET DEBUG FILE TO "/informix/David/RQM_10_1790/sp_obtiene_info_rep_edc_tdc.out";
--TRACE ON;

	SELECT CURRENT::DATE 
		INTO v_fecha_hoy 
	FROM systables WHERE tabid = 1;
	
	SELECT id_canal, cc_canal
	FROM bdinteg:"informix".si_canales WHERE id_canal IN('03','17')
	INTO TEMP tmp_canales WITH NO LOG;
	
	SELECT cc_canal INTO vCanal_aprob 
	FROM tmp_canales WHERE cc_canal = v_canal;

	--WHILE 1 = 1
	
	IF vCanal_aprob = v_canal THEN 
		IF v_fecha_hoy = v_fecha_consul THEN 
			IF NOT EXISTS (
				SELECT num_credito FROM "informix".sd_info_rep_edc 
				WHERE num_credito = v_num_credito AND fecha_consul = v_fecha_consul AND fecha_corte_edc = v_fecha_corte_edc AND canal = v_canal 
			  ) THEN
						 INSERT INTO "informix".sd_info_rep_edc
									(
									num_credito,					numcte,						fecha_consul,					fecha_corte_edc,				sin_servicio,
									view_down,						no_view_down,               si_serv_sin_view,				canal	    				
									)
							 VALUES(
									NVL(v_num_credito,''),			NVL(v_numcte,''),			NVL(v_fecha_consul,DATE(1)),	NVL(v_fecha_corte_edc,DATE(1)),	NVL(v_sin_servicio,''),			
									NVL(v_view_down,''),			NVL(v_no_view_down,''),     NVL(v_si_serv_sin_view,''),		NVL(v_canal,'')
									);
				--EXIT WHILE;
			ELSE 
				LET cMensajeSalida = 'Ya existe un registro durante el dia.';
				--EXIT WHILE;
			END IF;
		ELSE 
			LET cMensajeSalida = 'La fecha de consulta no es igual al dia de hoy.';
			LET cCodRet = '00001';
			--EXIT WHILE;
		END IF;
	ELSE 
		LET cMensajeSalida = 'El canal no es valido.';
		LET cCodRet = '00002';
		--EXIT WHILE;
	END IF;
	
	IF cCodRet != '00000' THEN
	
		INSERT INTO bdicred:sd_bitacora_mec (
					empresa, 		num_proceso, 	fecha_ejecucion, 	cod_ret, 	mensaje,
					user_insert, 	fecha_insert, 	hora_insert
					) 
			VALUES (
					'001',			v_num_proceso,	TODAY, 				cCodRet,	TRIM(cMensajeSalida) || ' Para el credito: ' || TRIM(v_num_credito) || ' con canal: ' || v_canal,
					user, 			TODAY,			CURRENT
					);
	END IF;
	DROP TABLE IF EXISTS tmp_canales;
			
	RETURN '00000';

END; 

END PROCEDURE;
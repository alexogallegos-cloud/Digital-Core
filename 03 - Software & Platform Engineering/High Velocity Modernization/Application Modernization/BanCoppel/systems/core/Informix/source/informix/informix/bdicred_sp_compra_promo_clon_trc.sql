CREATE PROCEDURE "informix".sp_compra_promo_clon_trc()
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

	--SET DEBUG FILE TO '/resplogifx/archivoscartera/sp_compra_promo_clon_trc.out';
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
          FROM bdicred:"informix".sd_promocion_credito a, bdicred:sd_maecred b
         WHERE a.empresa = b.empresa
           AND a.num_credito = b.num_credito
           AND a.status = 0         -->FMV 4ago14: Pendiente de aperturar
           AND b.status_cred = 'AA'
		   AND b.num_producto='6001'
		   AND a.num_credito in ('600193193338','600248619378','600004200942','600005113490')
		   
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
		
		-- Identifica si el cliente es por contratacion de SMS
		LET cTipoContrato = '';
		IF sNumPromocion in (2, 5, 8) THEN
			SELECT first 1 respuesta_cte_sms, tasa, tipo_contrato INTO cResp_Cte_sms, sTasa, cTipoContrato FROM bdicred:sd_promocion_credito_sms 
			 WHERE num_credito = vcNumCredito AND folio_compra_sms = cFolioMovto;
		ELIF sNumPromocion in (3, 6, 9) THEN
			SELECT first 1 respuesta_cte_sms, tasa, tipo_contrato INTO cResp_Cte_sms, sTasa, cTipoContrato FROM bdicred:sd_promocion_credito_sms 
			 WHERE num_credito = vcNumCredito AND num_promo = sNumPromocion AND mnto_compra = dMonto AND plazo = sPlazo; 
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
					 WHERE num_credito = vcNumCredito AND num_promo = sNumPromocion AND mnto_compra = dMonto AND plazo = sPlazo; 
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
						 WHERE num_credito = vcNumCredito AND num_promo = sNumPromocion AND mnto_compra = dMonto AND plazo = sPlazo; 
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
									 WHERE num_credito = vcNumCredito AND num_promo = sNumPromocion AND mnto_compra = dMonto AND plazo = sPlazo; 
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
									 WHERE num_credito = vcNumCredito AND num_promo = sNumPromocion AND mnto_compra = dMonto AND plazo = sPlazo; 
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

    FOREACH WITH HOLD
        SELECT a.ROWID, a.monto_actual, a.plazo, a.num_promo   , a.nombre_promo, a.num_credito, a.ejecutivo, a.sucursal, a.folio_suc   , a.folio_movto, divisa  , b.sucursal, a.monto_int_iva, a.fecha -- INC 27 127 JHQS 20190626
          INTO iRowID1, dMonto1	      , sPlazo1, sNumPromocion1, cNomPromocion1, vcNumCredito1, cEjecutivo1, cSucursal1, cFolioApertua1, cFolioMovto1 , vDivisa1, vsucorig1 , dMontoIntIVA1  , dFechaPromo1 -- INC 27 127 JHQS 20190626
          FROM bdicred:"informix".sd_promocion_credito a, bdicred:sd_maecred b
         WHERE a.empresa = b.empresa
           AND a.num_credito = b.num_credito
           AND a.status =  0         -->FMV 4ago14: Pendiente de aperturar
           AND b.status_cred <> 'AA'
		UNION
		SELECT a.ROWID, a.monto_actual, a.plazo, a.num_promo   , a.nombre_promo, a.num_credito, a.ejecutivo, a.sucursal, a.folio_suc   , a.folio_movto, divisa  , b.sucursal, a.monto_int_iva, a.fecha -- INC 27 127 JHQS 2019062
          FROM bdicred:"informix".sd_promocion_credito a, bdicred:sd_maecred b
         WHERE a.empresa = b.empresa
           AND a.num_credito = b.num_credito
           AND a.status =  0         -->FMV 4ago14: Pendiente de aperturar
           AND b.num_producto <>'6001'
		
		-- JHQS 20190628 INC 27 127 {
		LET cFolioApertua1 = TRIM(NVL(cFolioApertua1,''));
		LET cFolioMovto1 = TRIM(NVL(cFolioMovto1,''));
		
        UPDATE bdicred:"informix".sd_promocion_credito SET status = 7
         WHERE empresa = '001' AND num_credito = vcNumCredito1 AND folio_suc = cFolioApertua1 AND num_promo = sNumPromocion1
           AND plazo = sPlazo1 AND folio_movto = cFolioMovto1;
		
		-- Se consulta referencias de retenidos en la tabla sd_maeretenido (para cancelarse por CrÃ?Â?Ã?Â?Ã?Â?Ã?Â©dito no vigente [sd_promocion_credito.status = 7])
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
		   
    END FOREACH
       	
	IF cCodRet <> '00000' THEN
        INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',vcNumCredito,'sp_compra_promo',vc_dtFechaHoy,CURRENT,'',sNumPromocion,cCodRet);
    END IF;

	--RETURN cCodRet, TRIM(cMensajeRet);
	RETURN cCodRet, cMensajeRet;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso que realiza la confirmaciÃ?Â?Ã?Â?Ã?Â?Ã?Â³n de los pagos diferidos',
'AUTOR: Mohamed CarreÃ?Â?Ã?Â?Ã?Â?Ã?Â³n ',
'FECHA DE CREACION: 07 de Febrero del 2012',
'VERSION: 20120207.1137',
'BD: bdicred',
'DESCRIPCIÃ?Â?Ã?Â?Ã?Â?Ã?Â?N: Se agrego la ejecuciÃ?Â?Ã?Â?Ã?Â?Ã?Â²n del movimiento de la apertura de la compra a meses (genmov_tc)',
'MODIFICO: Valentin Lopez ',
'FECHA: 03 Abril 2012',
'DESCRIPCION MODIFICACION: Se cambia el proceso para agregar la actualizaciÃ?Â?Ã?Â?Ã?Â?Ã?Â³n del movimiento del retenido de los intereses como reversado para el caso de promotoria y ventanilla',
'MODIFICO: Mohamed CarreÃ?Â?Ã?Â?Ã?Â?Ã?Â³n',
'VERSION: 20120608.0909',
'BD: bdicred',
'--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------',
'MODIFICACIÃ?Â?Ã?Â?Ã?Â?Ã?Â?N',
'RQ         : INC 27 127 CorrecciÃ?Â?Ã?Â?Ã?Â?Ã?Â³n de error en credisoluciones',
'FECHA      : 26 de Junio de 2019',
'DESCRIPCIÃ?Â?Ã?Â?Ã?Â?Ã?Â?N: Se agregÃ?Â?Ã?Â?Ã?Â?Ã?Â³ el cambio de estatus en tabla sd_maeretenido al cancelar por error y al cancelar por crÃ?Â?Ã?Â?Ã?Â?Ã?Â©dito no vigente',
'MODIFICO   : Jorge Humberto Quintana Santiesteban',
'CC         : 33906',
'--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_proyecta_credisoluciones_web(
pSucursal 		CHAR(4),
pNumPromocion 	SMALLINT, -- 1-efectivo, 2-compras, 3-saldos
pSaldoDisp		DECIMAL(18,2),
pMonto 			DECIMAL(18,2),
pPlazo 			SMALLINT
)

RETURNING  CHAR(5)          AS Codigo, 		  -- CODIGO DE RETORNO
            INTEGER         AS Periodo,       -- PERIODO ACTUAL
            DATE            AS FechaCouta,	  -- FECHA DEL PAGO
            DECIMAL(18,2)   AS SaldoInicial,  -- SALDO INICIAL
            DECIMAL(18,2)   AS Mensualidad,	  -- MENSUALIDAD
            DECIMAL(18,2)   AS Intereses,	  -- INTERESES
            DECIMAL(18,2)   AS IvaInteres,	  -- IVA DE INTERESES
            DECIMAL(18,2)   AS Capital,		  -- CAPITAL
            DECIMAL(18,2)   AS ComisionTotal,	  -- COMISION POR DISPOSICION
            SMALLINT        AS DiasPeriodo,	  -- DIAS DEL PERIODO
            DATE            AS FechaAper,	  -- FECHA DE APERTURA
			CHAR(3)         AS NumMesesPago;  -- NUMERO DE MESES

	---DECLARACIONES
    DEFINE iSqlErr				INTEGER;
    DEFINE iIsamErr				INTEGER;
    DEFINE cErrorInfo			CHAR(80);
    DEFINE cCodRet				CHAR(5);
    DEFINE cMensajeRet			CHAR(80);
	DEFINE dFactorIvaSucursal	DECIMAL(5,3);
	DEFINE dComisDisposicion	DECIMAL(18,6);
	DEFINE dIvaComision			DECIMAL(18,6);
	DEFINE dFactorComDispEfect	DECIMAL(18,6);
	DEFINE cCodComDispEfectivo	CHAR(4);
	DEFINE dValorMinDiferir		DECIMAL(18,6);
	DEFINE dComisionTotal       DECIMAL(18,6);
	DEFINE dTotalPagar			DECIMAL(18,6);
	DEFINE dFechaAper           DATE;
	DEFINE mSdoInicial        DECIMAL(18,6);
	DEFINE mSdoFinal          DECIMAL(18,6);
	DEFINE mMensualidad  	DECIMAL(18,6);
	DEFINE mMensualidad2 	DECIMAL(18,6);
	DEFINE mIntereses       DECIMAL(18,6);
	DEFINE mPeriodo		    INTEGER;
	DEFINE dFechaCouta      DATE;
	DEFINE mIvaInt			DECIMAL(18,6);
	DEFINE mCapital			DECIMAL(18,6);	
	DEFINE sDiasPeriodo		SMALLINT;
	DEFINE Contador         INTEGER;	
	
	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= '';
	LET cCodRet				= '00000';
	LET cMensajeRet			= 'PROCESO EXITOSO';
	LET dFactorIvaSucursal	= 0.0;
	LET dComisDisposicion	= 0.0;
	LET dIvaComision		= 0.0;
	LET dFactorComDispEfect	= 0.0;
	LET cCodComDispEfectivo	= '';
	LET dValorMinDiferir	= 0.0;
	LET dComisionTotal      = 0.0;
	LET dTotalPagar			= 0.0;
	LET dFechaAper          = DATE(1);
	LET mSdoInicial         = 0.0;
	LET mSdoFinal           = 0;
	LET mMensualidad  	    = 0.0; 
	LET mMensualidad2       = 0.0;
	LET mIntereses		= 0.0;
	LET mIvaInt			= 0.0;
	LET mCapital		= 0.0;	
	LET mPeriodo 			= 0;	
	LET dFechaCouta         = DATE(1);
	LET sDiasPeriodo		= 0;
	LET Contador            = 0;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, dComisionTotal, sDiasPeriodo, dFechaAper, pPlazo;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/Malena/sp_proyecta_credisoluciones.out';
	--TRACE ON;

	-- OBTIENE EL VALOR MINIMO CONTEMPLADO PARA EL MONTO A DIFERIR EN LAS PROMOCIONES DE CREDISOLUCION
	SELECT TRIM(valor)::DECIMAL(18,2)
	INTO dValorMinDiferir
	FROM bdicred:"informix".sd_param
	WHERE cod_param  = '029';
	-- VALIDA QUE EL MONTO A DIFERIR SEA MAYOR AL VALOR MINIMO DE LA PROMOCION 
	IF pMonto < dValorMinDiferir THEN
		LET cCodRet = '00016';
		LET cMensajeRet = 'EL MONTO A DIFERIR ES MENOR AL MONTO MINIMO PERMITIDO ';		
	ELSE 
		-- VALIDA QUE LA SUCURSAL EXISTA Y ADEMAS OBTIENE EL IVA
		SELECT iva
		INTO dFactorIvaSucursal
		FROM bdinteg:"informix".si_sucursales
		WHERE sucursal = pSucursal;
					
		--SI EL FACTOR DEL IVA DE SUCURSAL ES IGUAL A 0 SE ASIGNA EL VALOR 0.16 POR DEFAULT
		IF dFactorIvaSucursal = 0 THEN
			LET dFactorIvaSucursal = 0.16;
		END IF;
			
		-- VALIDA SI SE TRATA DE PROMOCION DE EFECTIVO
		IF pNumPromocion = 1 THEN
			-- OBTIENE EL CODIGO PARA LA COMISION DE LA DISPOSICION DE EFECTIVO
			SELECT TRIM(valor)::CHAR(4)
			INTO cCodComDispEfectivo
			FROM bdicred:"informix".sd_param
			WHERE cod_param  = '334';
			IF NVL(cCodComDispEfectivo,'') = '' THEN
				LET cCodRet = '00017';
				LET cMensajeRet = 'ERROR AL OBTENER EL PARAMETRO DEL CODIGO DE LA COMISION DE DISP. DE EFECTIVO';
			ELSE 
			-- OBTIENE EL FACTOR PARA LA COMISION DE LA DISPOSICION DE EFECTIVO
				SELECT apli_factor
				INTO dFactorComDispEfect
				FROM bdicred:"informix".sd_tpcomis
				WHERE cod_comis = cCodComDispEfectivo;
				IF NVL(dFactorComDispEfect,0.0) = 0.0 THEN
					LET cCodRet = '00018';
					LET cMensajeRet = 'ERROR AL OBTENER EL PARAMETRO DEL FACTOR DE LA COMISION DE DISP. DE EFECTIVO';
				ELSE 								
					-- CALCULA LA COMISION POR LA DISPOSICION
					LET dComisDisposicion = pMonto * (dFactorComDispEfect/100);
					-- CALCULA EL IVA DE LA COMISION
					LET dIvaComision = dComisDisposicion * dFactorIvaSucursal;
					-- CALCULA LA COMISION TOTAL
					LET dComisionTotal= dComisDisposicion + dIvaComision;								
				END IF;						
			END IF;
		END IF;	
		LET Contador = 0;
		LET mSdoInicial = 0;

		FOREACH                
			EXECUTE PROCEDURE bdicred:"informix".sp_proyecta_prest_credisol(pMonto,pPlazo::INTEGER,0,'6900',pSucursal,1,0,'',null,1,pNumPromocion::INTEGER) 
			INTO cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad2, mIntereses, mIvaInt,mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, pPlazo
			LET dTotalPagar = dTotalPagar + mMensualidad2;
		END FOREACH;			
		IF pSaldoDisp <= dTotalPagar THEN
			IF pPlazo = 6 THEN
				LET cCodRet = '00019';
				LET cMensajeRet = 'NO CUENTA CON SALDO SUFICIENTE PARA CONTRATAR';
			ELSE
				LET cCodRet = '00019';
				LET cMensajeRet = 'NO CUENTA CON SALDO SUFICIENTE PARA CONTRATAR, POR FAVOR INTENTE POR UN PLAZO O MONTO DIFERENTE';
			END IF;
		END IF;		
		IF cCodRet = '00000' THEN 
		-- RQM 10 452 AAME 20150610 se solicita cambiar la forma de obtener las mensualidades de una credisolucion.
			LET Contador = 0;
			LET mSdoInicial = 0;

			FOREACH                

				EXECUTE PROCEDURE bdicred:"informix".sp_proyecta_prest_credisol(pMonto,pPlazo::INTEGER,0,'6900',pSucursal,1,0,'',null,1,pNumPromocion::INTEGER) 
				INTO cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad2, mIntereses, mIvaInt,mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, pPlazo

				LET Contador = Contador + 1;

				IF Contador = 1 THEN

					LET mMensualidad = mMensualidad2;

				END IF;

				LET dTotalPagar = dTotalPagar + mMensualidad2;
				
				RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad2, mIntereses, mIvaInt, mCapital, dComisionTotal, sDiasPeriodo, dFechaAper, pPlazo WITH RESUME;

			END FOREACH;
	
		END IF;
	END IF;
	IF Contador=0 THEN
		RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, ROUND(mMensualidad2,2), mIntereses, mIvaInt, mCapital, dComisionTotal, sDiasPeriodo, dFechaAper, pPlazo;		
	END IF;
END
END PROCEDURE
DOCUMENT 
'DESCRIPCION: Realiza el desglose de la proyecciÃ³n para credisoluciones ',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 15/Octubre/2013',
'BD    : BDICRED',
'Version: 20131015.1614';

CREATE PROCEDURE "informix".sp_actualiza_lincred_central_masivo(P_empresa CHAR(3), P_num_credito CHAR(20), Pmonto DECIMAL(18,2) , Ptipo CHAR(1),Pstatus CHAR(1),Pusuario CHAR(20))
              
RETURNING CHAR(6),
          VARCHAR(80);  
--Héctor Manuel Bojórquez Ruelas
--08  DE Junio DE 2011
--actualiza la linea de credito central y genera un movimiento en la movdia, así como tambien genera un registro del crédito en sd_bitacora_aumlincred y en  sd_autorizacion_aumlincred
--Folio 1258-BitácoraIncrementoLinCred

		  
--Roque Enrique Solis Campaña 
--20  DE DICIEMBRE DE 2008
--actualiza la linea de credito central y genera un movimiento en la movdia 
--19 DE FEBRERO DE 2009
--El movimiento se genera con la cantidad la diferencia del monto actual y el monto nuevo


--Modificación	  
--Juan Daniel Lazalde Centeno
--12  DE FEBRERO DE 2014
--Identificar si el usuario, que esta realizando la operación esta registrado en la tabla bdicred:sd_perfiles_cac_aumlincred y ponga en el campo roigen = "S" Sucursal 
--*************************************************************************
--                         DEFINICION DE VARIABLES
--*************************************************************************
DEFINE scod_ret 		CHAR(6);
DEFINE cCod_ret 		CHAR(6);
DEFINE vsqlerr 			INTEGER;

DEFINE c_num_producto 	CHAR(4);
DEFINE c_divisa 		CHAR(2);
DEFINE c_sucursal 		CHAR(4);
DEFINE d_fecha_hoy 		DATE;
DEFINE c_transacc_suc 	CHAR(4);
DEFINE c_folio_suc 		VARCHAR(20);
DEFINE p_cod_ret 		VARCHAR(10);
DEFINE p_mensaje 		VARCHAR(80);
DEFINE d_hora           DATETIME HOUR TO SECOND;
DEFINE cDif			    CHAR (1);
DEFINE mMontoanterior   DECIMAL(18,2);
DEFINE cNum_cte         CHAR(20);
DEFINE cNombre_cte      CHAR(100);
DEFINE mMontoMov        DECIMAL(18,2);
DEFINE mMontoDif        DECIMAL(18,2);
DEFINE v_nombre_usuario CHAR(100);
DEFINE cNumCte          CHAR(20);
DEFINE cGradoRiesgo     CHAR(2);
DEFINE dMontoReserva    DECIMAL(18,2);
DEFINE valorsm			DECIMAL(18,2);
DEFINE smblinsug		DECIMAL(18,2);
DEFINE cCalifBuro       CHAR(1);
DEFINE cMotivoRechazo   CHAR(255);
DEFINE cCompromiso      DECIMAL(14,2);
DEFINE iReg             INTEGER;
DEFINE cOrigen          CHAR(1);


-- *************************************************************************
-- *                        ASIGNACION DE VARIABLES
-- **************************************************************************

LET scod_ret		 = "000000";
LET cCod_ret		 = "000000";
LET vsqlerr			 = 0;
LET c_num_producto	 ="";
LET c_divisa		 ="";
LET c_sucursal		 ="";
LET d_fecha_hoy		 = DATE(1);
LET c_transacc_suc	 ="";
LET c_folio_suc		 ="";
LET p_cod_ret		 ="";
LET p_mensaje		 =""; 	
LET d_hora           = CURRENT HOUR TO SECOND;
LET cDif			 ="";
LET mMontoanterior	 = 0;
LET cNum_cte		 ="";
LET cNombre_cte		 ="";
LET mMontoMov 	     = 0;
LET mMontoDif        = 0;
LET v_nombre_usuario = "";
LET cNumCte          = "";
LET cGradoRiesgo     = "";
LET dMontoReserva    = 0;
LET valorsm			 = 0;
LET smblinsug	     = 0;
LET cCalifBuro       = ""; 
LET cMotivoRechazo   = "";
LET cCompromiso      = 0;
LET cOrigen          = "";

-- **********************************************************************
-- *                        CONTROL DE ERRORES
-- ***********************************************************************
BEGIN
    ON EXCEPTION SET vsqlerr
       IF vsqlerr != 0 THEN
          LET scod_ret=vsqlerr;
		  ROLLBACK WORK;
          RETURN scod_ret, p_mensaje ;
       END IF;
    END EXCEPTION;

	--SET DEBUG FILE TO "/respaldosbd/hectorb/actualiza_lincred.out";
	--TRACE ON;

    -- **********************************************************************
    -- *                        PROGRAMA PRINCIPAL
    -- **********************************************************************
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    SELECT monto_otorgado
    INTO mMontoanterior
    FROM "informix".sd_maesdos 
    where num_credito=P_num_credito;

	IF (mMontoanterior is not null) THEN
	   
--	   EXECUTE PROCEDURE bdicred:"informix".sp_consultacredito_central( P_empresa, P_num_credito) INTO p_cod_ret, p_mensaje, cNum_cte,cNombre_cte,mMontoanterior ;
        
		UPDATE "informix".sd_maesdos
		SET monto_otorgado=Pmonto
		WHERE empresa=P_empresa AND num_credito=P_num_credito;
		
		SELECT num_producto, sucursal , divisa, numcte 
		INTO   c_num_producto, c_sucursal, c_divisa, cNum_cte
		FROM   "informix".sd_maecred
		WHERE  empresa     = P_empresa
		AND    num_credito = P_num_credito;

		--Obtener la fecha del dia	
		SELECT fecha_hoy
		INTO   d_fecha_hoy
		FROM   "informix".sd_fechas
		WHERE  empresa = P_empresa;
        
		-- obtener el valor del salario minimo de la zona C
		SELECT valor 
		INTO valorsm
		FROM "informix".sd_param 
		WHERE empresa   = P_empresa 
		AND cod_param = '013';
		
		
		SELECT grado_riesgo,NVL(reserva_calificacion,0.00)
		INTO cGradoRiesgo, dMontoReserva
		FROM "informix".sd_hist_reserva
		WHERE  empresa     = P_empresa
		AND    num_credito = P_num_credito
		AND   fecha_cierre = (SELECT  MAX(fecha_cierre)
                    FROM "informix".sd_hist_reserva
                    WHERE  empresa     = P_empresa
                    AND    num_credito = P_num_credito);
		
		
	    LET  c_transacc_suc  = '0000';
		LET  c_folio_suc = 'Act LineaCredito';
        
        IF mMontoanterior < Pmonto THEN
		    LET cDif = '1';
            LET mMontoDif = Pmonto-mMontoanterior;
		ELSE
		    LET cDif = '2';
            LET mMontoDif = mMontoanterior-Pmonto;
		END IF;

		EXECUTE PROCEDURE "informix".GENMOV( P_empresa, P_num_credito
                                 , c_num_producto , cDif
                                 ,'008' , d_fecha_hoy
                                 , mMontoDif , c_folio_suc
                                 , c_sucursal, c_divisa
                                 , c_transacc_suc
                                 ) INTO p_cod_ret, p_mensaje;

		IF p_cod_ret::INTEGER > 0 THEN
			LET scod_ret= '000002'; 
			LET p_mensaje="Ocurrio un error al guardar los movimientos del credito en el SP bdicred:genmov";	   	
			RETURN scod_ret, p_mensaje;   
		END IF;

		LET smblinsug = Pmonto / (30.42 * valorsm);
				
		---Obtiene la  calificacion buro para actualizar el campo  califica_buro de la tabla sd_bitacora_aumlincred
		EXECUTE PROCEDURE bdisolic:"informix".cal_circulocredito_cjunk(P_empresa, cNum_cte, P_num_credito) 
		INTO  cCod_ret, 	    -- Codigo de Retorno
              cCalifBuro,	    -- Calificacion 1 Aprobado, 0 Rechazado
		      cCompromiso,      -- Compromisos > 0 si Calificacion es 1
		      cMotivoRechazo;   -- Descripcion de Creditos Motivo de Rechazo
		
		
		--Lazalde: Validar si el usuario existe en sd_perfiles_cac_aumlincred para identificar a que origen "SUCURSAL ó CENTRAL" se esta realizando el incremento de linea de crédito
		IF EXISTS(SELECT ejecutivo FROM "informix".sd_perfiles_cac_aumlincred where empresa = P_empresa AND ejecutivo = Pusuario) THEN
			LET cOrigen = 'S';
		ELSE
			LET cOrigen = 'C';
		END IF
		
		
		INSERT INTO "informix".sd_bitacora_aumlincred
		(empresa, num_solicitud,numcte,num_producto,status,causa_status,fecha_status,hora_status,sucursal,lincred_actual,lincred_sugerida,
		smb_lincred,grado_riesgo,monto_reserva,califica_buro,resp_cte,mensaje,ejecutivo,sucursal_at,origen,user_insert,fecha_insert)
		VALUES (P_empresa,P_num_credito,cNum_cte,'6001','AP','',d_fecha_hoy,d_hora,c_sucursal,mMontoanterior,Pmonto,smblinsug,
		cGradoRiesgo,dMontoReserva,cCalifBuro,'1',Ptipo, Pusuario,'0000',cOrigen,Pusuario,d_fecha_hoy);

		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET scod_ret = "000004";
			LET p_mensaje = "Ocurrio un error al guardar la información en la bitacora de aumento de linea de crédito";
			RETURN scod_ret, p_mensaje;   
		END IF;
		

		INSERT INTO "informix".sd_autorizacion_aumlincred 
		(empresa, num_solicitud, status,causa_status,user_insert,fecha_status,fecha_insert, revision_cac)     		
		VALUES(P_empresa,P_num_credito,'AP','',Pusuario,d_fecha_hoy,d_fecha_hoy,0);
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET scod_ret = "000005";
			LET p_mensaje = "Ocurrio un error al guardar la información en la bitacora de autorización de aumento de linea de crédito";
			RETURN scod_ret, p_mensaje;   
		END IF;

	ELSE
       LET scod_ret= '000001'; 
       LET p_mensaje="No es posible realizar la actualizacion";	   
	END IF
	

    RETURN scod_ret, p_mensaje;   
          
END;
END PROCEDURE;
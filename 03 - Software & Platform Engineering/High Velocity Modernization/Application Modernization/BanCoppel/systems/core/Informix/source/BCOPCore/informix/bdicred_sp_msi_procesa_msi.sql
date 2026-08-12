CREATE PROCEDURE "informix".sp_msi_procesa_msi()
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
	DEFINE cFolioApertua		CHAR(16);
	DEFINE cFolioMovto			CHAR(16);

    DEFINE dMonto1				DECIMAL(18,2);
	DEFINE sPlazo1				SMALLINT;
	DEFINE vcNumCredito1		VARCHAR(20);
	DEFINE cEjecutivo1			CHAR(8);
	DEFINE cSucursal1			CHAR(4);
	DEFINE sNumPromocion1		SMALLINT;
	DEFINE cNomPromocion1		CHAR(50);
	DEFINE cFolioApertua1		CHAR(16);
	DEFINE cFolioMovto1			CHAR(16);

	-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO QUE GENERA EL FOLIO
	DEFINE cCodRetGF			CHAR(6);
	DEFINE cFolioSucGF			CHAR(16);

	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE LA PROYECCION
	DEFINE cCodRetPP			CHAR(6);
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
    DEFINE vDivisa1             CHAR(2);
    DEFINE v_dv                 CHAR(2);
    DEFINE v_tipocambio         DECIMAL(14,6);
    DEFINE vsucorig             CHAR(4);
    DEFINE vsucorig1            CHAR(4);
    DEFINE vc_dtFechaHoy        DATE;
	DEFINE cResp_Cte_sms		CHAR(1);
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
	DEFINE vStatus_cred			CHAR(2);
	DEFINE vTransaccPrincp		CHAR(4);
	DEFINE dCsg_cap_vig			DECIMAL(18,2);	
	DEFINE dCsg_tot_liquidacion	DECIMAL(18,2);	
	DEFINE dCsg_linea_disp		DECIMAL(18,2);
	DEFINE sCamp_Activa_Msi		SMALLINT;
	DEFINE sContador_sms		SMALLINT;
	DEFINE dMnto_Vencido    	DECIMAL(18,2);
	DEFINE dMnto_Venc_Trasp   	DECIMAL(18,2);
	
	-- Variable para monto minimo
	DEFINE dmontoValido			DECIMAL(18,2);
	
	
	
	LET dMontoIntIVA 			= 0.0;
	LET dFechaPromo				= DATE(1);
	LET dMontoIntIVA1 			= 0.0;
	LET dFechaPromo1			= DATE(1);
	LET vReferencia 			= '';
	LET	vReferencia2 			= '';
	LET vRef 					= '';
	LET	vFolio 					= '';
	---INICIALIZACIONES	
	LET iSqlErr					= 0;
	LET iIsamErr				= 0;
	LET cErrorInfo				= '';
	LET cCodRet					= '000000';
	LET cMensajeRet				= 'PROCESO EXITOSO';
	LET dMonto					= 0.0;
	LET sPlazo					= 0;
	LET vcNumCredito			= '';
	LET vcNumCte				= '';
	LET cEjecutivo				= '';
	LET cSucursal				= '';
	LET sNumPromocion			= 0;
	LET cNomPromocion			= '';
	LET cFolioApertua			= '';
	LET cFolioMovto				= '';
    LET dMonto1					= 0.0;
	LET sPlazo1					= 0;
	LET vcNumCredito1			= '';
	LET cEjecutivo1				= '';
	LET cSucursal1				= '';
	LET sNumPromocion1			= 0;
	LET cNomPromocion1			= '';
	LET cFolioApertua1			= '';
	LET cFolioMovto1			= '';
	-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO QUE GENERA EL FOLIO
	LET cCodRetGF				= '000000';
	LET cFolioSucGF				= '';
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE LA PROYECCION
	LET cCodRetPP				= '';
    LET cMensajeRetPP			= '';
	LET dTotalPagarPP			= 0.0;
	LET sNumPlazoPP				= 0;
	LET dPagoMensualPP			= 0.0;
	LET dInteresIvaPP			= 0.0;
	LET dSaldoTdcPP				= 0.0;
	LET cFolioPromoPP			= '';
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE principal
	LET cCodRetPrin				= '';
	LET dRemanentePrin			= 0.0;
	LET dIntMoratorioPrin		= 0.0;
	LET dIntVencidoPrin			= 0.0;
	LET dCapVencidoPrin			= 0.0;
	LET dIntVigentePrin			= 0.0;
	LET dCapVigentePrin			= 0.0;
	LET dImpuestoPrin			= 0.0;
	LET dComisionesPrin			= 0.0;
	LET dSeguroPrin				= 0.0;
	-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO DE ASIGNACION DE NUMERO DE SOLICITUD
	LET cCodRetANS			= '';
	LET cNumSolANS			= '';
	-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO DE APERTURA DE PRESTAMO
	LET cCodRetAP				= '000000';
	LET dTasaInteres			= 0.0;
	LET dTasaMora				= 0.0;
	LET dCatIva		    		= 0.0;
	LET cMercadeo				= '';
	-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO DE REVERSION
	LET cCodRetRev				= '00000';
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE REVERSION PROMO
	LET cCodRetRP				= '00000';
    LET cMensajeRetRP			= '';
	--VARIABLES PARA CACHAR EL VALOR DEL PROCEDIMIENTO DE LA APERTURA DE LA COMPRA A MESES.
	LET cCodRetGenMov			= "";
	LET cMsjeGenMov		    	= "";
    LET vDivisa             	= "00";
    LET vDivisa1            	= "00";
    LET v_dv                	= "00";
    LET v_tipocambio        	= 0;
    LET vsucorig            	= "";
    LET vsucorig1           	= "";
    LET vc_dtFechaHoy       	= DATE(1);
	LET cResp_Cte_sms			= '';
	LET sCountExists			= 0;
	LET sYield 					= 0;
	LET sTasa					= 0;
	LET cNumProm_proy			= 0;
	LET vProducto				='';
	LET cTipoContrato			= '';
	LET dPorcReducTp3 			= 0;
	LET dSdoDisponible      	= 0;
	LET dSdoReduccion       	= 0;
	LET cCodRetCanc 			= '';
	LET cMensajeRetCanc     	= '';
	LET cBajaApoyo				= '';
	LET dMonto_LinOrig			= 0;
	LET dMonto_LinNva 			= 0;
	LET dFecha_Invitacion		= DATE(1);
	LET vTransaccPrincp			= '';
	LET dCsg_cap_vig			= 0;
	LET dCsg_tot_liquidacion	= 0;
	LET dCsg_linea_disp			= 0;
	LET sCamp_Activa_Msi		= 0;
	LET sContador_sms			= 0;
	LET dMnto_Vencido    		= 0;
	LET dMnto_Venc_Trasp   		= 0;
	--VARIABLE PARA CACHAR EL MONTO MINIMO DEL PROCESO
	LET dmontoValido			= 0;

	

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = trim(cFolioMovto) || cErrorInfo;
			RETURN cCodRet, NVL(cMensajeRet,'');
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/mahr/sp_msi_procesa_msi.out';

	--TRACE ON;

	-- Parametros de tipo de cambio
    SELECT valor INTO v_dv FROM bdinteg:si_param WHERE cod_param = 17;
    SELECT precio_venta INTO v_tipocambio FROM bdinteg:si_tpcambio WHERE empresa = "001" AND divisa = v_dv AND clase_tpcambio = "O"
       AND fecha_tpcambio = (SELECT MAX(fecha_tpcambio) FROM bdinteg:si_tpcambio WHERE empresa = "001" AND divisa = v_dv);

	-- Tasa de Interes para MSI
	SELECT valor_numerico INTO sTasa FROM bdicred:sd_param_campania WHERE grupo_parametro = 'MSI' AND num_parametro = 2;
	   
	-- Obtiene fecha del dia de hoy		
    SELECT fecha_hoy INTO vc_dtFechaHoy FROM "informix".sd_fechas WHERE empresa = '001';
	
	-- Obtien el estatus de campaÃ±a activa de Meses Sin Intereses
	SELECT activo INTO sCamp_Activa_Msi FROM bdicred:sd_promocion WHERE num_promo = 10;
	
	-- Obtiene el monto minimo para el proceso
	SELECT valor INTO dmontoValido FROM bdicred:sd_param WHERE cod_param = 337;

	-- Barre los contratos pendientes por generar / Creditos MSI pendientes por generar
    FOREACH WITH HOLD
		SELECT a.monto_actual , a.plazo    , a.num_promo   , a.nombre_promo, a.num_credito, a.ejecutivo, a.sucursal, a.folio_suc  , a.folio_movto, divisa , 
			   b.sucursal, a.monto_int_iva, a.fecha    , b.num_producto, b.numcte      , b.status_cred, c.monto_vencido, c.mto_venc_trasp
		  INTO  dMonto         , sPlazo     , sNumPromocion , cNomPromocion , vcNumCredito , cEjecutivo, cSucursal , cFolioApertua, cFolioMovto  , vDivisa, 
		       vsucorig  , dMontoIntIVA   , dFechaPromo, vProducto     , vcNumCte      , vStatus_cred , dMnto_Vencido  , dMnto_Venc_Trasp 
          FROM bdicred:"informix".sd_promocion_credito a, bdicred:sd_maecred b, bdicred:sd_maesdos c    
         WHERE a.empresa = b.empresa
           AND a.num_credito = b.num_credito
		   AND a.num_credito = c.num_credito
           AND a.status = 0
		   AND a.num_pro_prestamo = '8900'
		   --AND folio_movto in ('i121914061300742') -- BORRA
		
		-- Valida que el producto sea diferente de 6001, de lo contrario se descarta
		IF vProducto != 6001 THEN 
			UPDATE bdicred:"informix".sd_promocion_credito SET status = 8 WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto;
			INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',vcNumCredito,'sp_msi_proces_msi1',vc_dtFechaHoy,CURRENT,'',sNumPromocion,cCodRet);
			CONTINUE FOREACH;
		END IF;
		
		-- Valida que si el plazo es nulo se descarta.
		IF nvl(sPlazo,0) = 0 THEN 
			UPDATE bdicred:"informix".sd_promocion_credito SET status = 8 WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto;
			INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',vcNumCredito,'sp_msi_proces_msi2',vc_dtFechaHoy,CURRENT,'',sNumPromocion,cCodRet);
			CONTINUE FOREACH;
		END IF;
		
		-- Valida que si el plazo es nulo, cero se descarta o si el monto es menor a 50.
		IF nvl(dMonto,0) = 0 or nvl(dMonto,0) < dmontoValido THEN 
			UPDATE bdicred:"informix".sd_promocion_credito SET status = 8 WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto;
			INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',vcNumCredito,'sp_msi_proces_msi3',vc_dtFechaHoy,CURRENT,'',sNumPromocion,cCodRet);
			CONTINUE FOREACH;
		END IF;
		
		-- Valida que si el folio es nulo se descarta.
		IF nvl(cFolioApertua,'') = '' THEN 
			UPDATE bdicred:"informix".sd_promocion_credito SET status = 8 WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto;
			INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',vcNumCredito,'sp_msi_proces_msi4',vc_dtFechaHoy,CURRENT,'',sNumPromocion,cCodRet);
			CONTINUE FOREACH;
		END IF;
		   
		-- Valida que la campaÃ±a MSI este activa, de lo contrario se descarta
		IF nvl(sCamp_Activa_Msi,0) = 0 THEN
			UPDATE bdicred:"informix".sd_promocion_credito SET status = 8 WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto;
			INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',vcNumCredito,'sp_msi_proces_msi5',vc_dtFechaHoy,CURRENT,'',sNumPromocion,cCodRet);
			CONTINUE FOREACH;
		END IF;
		   
		-- No procesa msi de creditos tdc con status diferente de vigente/ Etapa 1, es decir con algun atraso.
		--IF (vStatus_cred != 'AA' and vStatus_cred != 'E1') OR (dMnto_Vencido + dMnto_Venc_Trasp) > 0 THEN  
		IF (dMnto_Vencido + dMnto_Venc_Trasp) > 0 THEN  
			UPDATE bdicred:"informix".sd_promocion_credito SET status = 8 WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto;
			INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',vcNumCredito,'sp_msi_proces_msi6',vc_dtFechaHoy,CURRENT,'',sNumPromocion,cCodRet);
			CONTINUE FOREACH;
		END IF;
		
		-- Valida que el folio de la compra no se encuentre repetido en la tabla. Solo debe de existir el registro insertado por concliador de msi
		LET sCountExists = 0;
		SELECT count(folio_movto) INTO sCountExists FROM bdicred:"informix".sd_promocion_credito WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto;
		IF sCountExists != 1 THEN
		
			-- Valida estatus de registro previo, si ya esta procesado 0 pendiente o 2 procesado (Credisol Compras), se cancela MSI, de lo contrario se elimina registro previo.
			SELECT count(folio_movto) INTO sCountExists FROM bdicred:"informix".sd_promocion_credito WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto AND num_promo != 10 AND status not in (4,5,8);
			IF sCountExists > 0  THEN
				UPDATE bdicred:"informix".sd_promocion_credito SET status = 8 WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto AND status = 0 AND num_promo = 10;
				INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',vcNumCredito,'sp_msi_proces_msi7',vc_dtFechaHoy,CURRENT,'',sNumPromocion,cCodRet);				
				LET sCountExists = 0;
				CONTINUE FOREACH;
			END IF;
			
			-- Valida registros previos marcados pero no procesados, se eliminan para procesar MSI
			SELECT count(folio_movto) INTO sCountExists FROM bdicred:"informix".sd_promocion_credito WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto AND num_promo != 10 AND status in (4,5,8);
			IF sCountExists > 0  THEN
				DELETE FROM bdicred:sd_promocion_credito WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto AND num_promo != 10;
				DELETE FROM bdicred:sd_promocion_credito_sms WHERE num_credito = vcNumCredito AND folio_compra_sms = cFolioMovto;
				LET sCountExists = 0;
			END IF;
		END IF;		

		-- Valida el monto de la deuda de la tdc vs monto de la compra msi
	    SELECT sdo_capital,  (monto_otorgado - (sdo_cap_insoluto + sdo_retenido)), (sdo_cap_insoluto + sdo_retenido) 
		  INTO dCsg_cap_vig, dCsg_linea_disp,									   dCsg_tot_liquidacion
		  FROM bdicred:sd_maesdos WHERE num_credito = vcNumCredito;	

		IF dCsg_cap_vig <= 0 THEN
			UPDATE bdicred:"informix".sd_promocion_credito SET status = 8 WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto;
			INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',vcNumCredito,'sp_msi_proces_msi8',vc_dtFechaHoy,CURRENT,'',sNumPromocion,cCodRet);
			CONTINUE FOREACH;
		ELIF dCsg_linea_disp < dMontoIntIVA THEN 		-- Si la linea disponible no cubre los intereses (0)
			UPDATE bdicred:"informix".sd_promocion_credito SET status = 8 WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto;
			INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',vcNumCredito,'sp_msi_proces_msi9',vc_dtFechaHoy,CURRENT,'',sNumPromocion,cCodRet);			
			CONTINUE FOREACH;
		ELIF dCsg_cap_vig < dMonto THEN					-- Si la deuda de la tdc es menor al monto del registro de MSI se actualiza el monto
			UPDATE bdicred:"informix".sd_promocion_credito SET monto_actual = dCsg_cap_vig WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto;
			LET dMonto = dCsg_cap_vig;
			IF nvl(dMonto,0) = 0 or nvl(dMonto,0) < dmontoValido THEN 
				UPDATE bdicred:"informix".sd_promocion_credito SET status = 8 WHERE num_credito = vcNumCredito AND folio_movto = cFolioMovto;
				INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',vcNumCredito,'sp_msi_proces_msi13',vc_dtFechaHoy,CURRENT,'',sNumPromocion,cCodRet);
				CONTINUE FOREACH;
			END IF;
		END IF;
		
	
		-- Inicializa varaibles que regresan los procesos de la proyeccion y sp principal.
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

		LET cFolioApertua = TRIM(NVL(cFolioApertua,''));
		LET cFolioMovto = TRIM(NVL(cFolioMovto,''));
		
		
		-- Se consulta referencias de retenidos en la tabla sd_maeretenido (en caso de que requiera actualizarse estatus por error [sd_promocion_credito.status = 4])	
		FOREACH
			SELECT referencia, folio_suc INTO vRef, vFolio FROM "informix".sd_maeretenido
		     WHERE empresa = '001' AND num_credito = vcNumCredito AND estatus = 'R' AND monto IN(dMonto,dMontoIntIVA) AND fecha = dFechaPromo
			   
			LET vRef = NVL(vRef,'');
			LET vFolio = NVL(vFolio,'');
			
			IF vFolio = cFolioMovto THEN
				LET vReferencia = vRef;
			ELIF LEFT(vRef,16) = cFolioApertua THEN
				LET vReferencia2 = vRef;
			END IF;
		END FOREACH
		
		
		-- Valida si existe previo registro por compra descartada para pf.
		SELECT count(*) INTO sContador_sms FROM bdicred:sd_promocion_credito_sms WHERE folio_compra_sms = cFolioMovto AND num_credito = vcNumCredito;
		IF sContador_sms > 0 THEN
			DELETE FROM bdicred:sd_promocion_credito_sms WHERE folio_compra_sms = cFolioMovto AND num_credito = vcNumCredito;
		END IF;
		
		-- Inserta registro en tabla sd_promocion_credito_sms para manejo de sms y proyecciones
		INSERT INTO bdicred:sd_promocion_credito_sms(empresa, num_credito , num_cte,  mnto_compra, folio_compra_sms, fecha_invitacion, tipo_sms, num_promo    , fecha_env_sms_inv, plazos_invita, tasas_invita, fecha_insert )
		                                        VALUES('001', vcNumCredito, vcNumCte, dMonto     , cFolioMovto     , vc_dtFechaHoy   , '1'     , sNumPromocion, CURRENT          , sPlazo       , sTasa		  , CURRENT);		
		
		-- Ejecuta proceso de proyeccion para MSI  
		EXECUTE PROCEDURE bdicred:"informix".sp_msi_proyecta_msi(2, cSucursal, cEjecutivo, sNumPromocion, vcNumCredito, '', dMonto, sPlazo, sTasa, cFolioMovto)
		   INTO cCodRetPP, cMensajeRetPP, dTotalPagarPP, sNumPlazoPP, dPagoMensualPP, dInteresIvaPP, dSaldoTdcPP, cFolioPromoPP, cNumProm_proy;		
			   
		IF cCodRetPP::INTEGER = 443 OR cCodRetPP = '000005' THEN        -- 00443 - El plazo no es valido para la promocion

            INSERT INTO bdicred:sd_bitacora_promocion VALUES('001', vcNumCredito, 'sp_msi_proces_msi10', vc_dtFechaHoy, CURRENT, '', sNumPromocion, cCodRetPP);
            LET cCodRet = cCodRetPP;
            LET cMensajeRet = cMensajeRetPP;
			
			UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '4', envio_result_sms = '0', status_envio_r_sms = '0' WHERE num_credito = vcNumCredito AND folio_compra_sms = cFolioMovto;
			UPDATE bdicred:"informix".sd_promocion_credito SET status = 8 WHERE num_credito = vcNumCredito AND num_promo = sNumPromocion AND folio_movto = cFolioMovto;
			LET cCodRet = '000000';
			CONTINUE FOREACH;

        ELIF cCodRetPP::INTEGER <> 0 AND cCodRetPP NOT IN ('03433','07433','11433') THEN 	-- El cliente no es viable para diferir (cuando se sobregira con la credisol)

			--Registra error en bitacora
            INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',vcNumCredito,'sp_msi_proces_msi11',vc_dtFechaHoy,CURRENT,'',sNumPromocion,cCodRetPP);
            -- LLAMA AL REVERSO PROMO PARA LIBERAR EL RETENIDO DE LOS INTERESES
			EXECUTE PROCEDURE bdicred:"informix".sp_reverso_promo(vcNumCredito, cFolioMovto, 1) INTO cCodRetRP, cMensajeRetRP;
			
			-- Actualiza el estatus como error de la proyeccion
            IF cCodRetRP::INTEGER <> 0 THEN
			
                UPDATE bdicred:"informix".sd_promocion_credito SET status = 4
                 WHERE num_credito = vcNumCredito
				   AND num_promo = sNumPromocion
                   AND folio_movto = cFolioMovto;
				
				UPDATE "informix".sd_maeretenido SET estatus = 'S'
				 WHERE num_credito = vcNumCredito
				   AND referencia IN(vReferencia, vReferencia2)
				   AND estatus = 'R'
				   AND fecha = dFechaPromo;
			
                LET cCodRet = '000005';
                LET cMensajeRet = 'OCURRIO UN ERROR EN EL PROCESO DE REVERSA PROMO';
            END IF;
			
			UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '6', envio_result_sms = '0', status_envio_r_sms = '0' WHERE num_credito = vcNumCredito AND folio_compra_sms = cFolioMovto;
			LET cCodRet = '000000';
			CONTINUE FOREACH;
			
		ELIF cCodRetPP::INTEGER <> 0 THEN
		
			--Registra error en bitacora
            INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',vcNumCredito,'sp_msi_proces_msi12',vc_dtFechaHoy,CURRENT,'',sNumPromocion,cCodRetPP);
			
			UPDATE bdicred:"informix".sd_promocion_credito SET status = 8 WHERE num_credito = vcNumCredito AND num_promo = sNumPromocion AND folio_movto = cFolioMovto;
			UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '4', envio_result_sms = '0', status_envio_r_sms = '0' WHERE num_credito = vcNumCredito AND folio_compra_sms = cFolioMovto;
			LET cCodRet = '000000';
			CONTINUE FOREACH;
			
		END IF;

		--- Proceso generico para generar un folio
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
            CONTINUE FOREACH;
		ELSE

			-- Manda a llamar al proceso llamado principal para realizar el abono por el monto a diferir
			--EXECUTE PROCEDURE bdicred:"informix".principal('001',vcNumCredito,1,dMonto,cEjecutivo,cSucursal,cFolioSucGF,'6030')
			EXECUTE PROCEDURE bdicred:"informix".principal('001', vcNumCredito, 1, dMonto, cEjecutivo, cSucursal, cFolioSucGF, '4404')
			INTO cCodRetPrin,dRemanentePrin,dIntMoratorioPrin,dIntVencidoPrin,dCapVencidoPrin,dIntVigentePrin,dCapVigentePrin,dImpuestoPrin,dComisionesPrin,dSeguroPrin;

			IF cCodRetPrin::INTEGER <> 0 THEN
				-- Actualiza el status a 4 como error en el proceso
			   UPDATE bdicred:"informix".sd_promocion_credito SET status = 4 
                 WHERE num_credito = vcNumCredito
				   AND num_promo = sNumPromocion
                   AND folio_movto = cFolioMovto;				  
				
				UPDATE "informix".sd_maeretenido SET estatus = 'S'
				 WHERE num_credito = vcNumCredito
				   AND referencia IN(vReferencia, vReferencia2)
				   AND estatus = 'R'
				   AND fecha = dFechaPromo;
				
				-- Marca el registro para el envio de sms no exitoso
				UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '6', envio_result_sms = '0', status_envio_r_sms = '0' WHERE num_credito = vcNumCredito AND folio_compra_sms = cFolioMovto;
				CONTINUE FOREACH;
			ELSE
				LET cCodRetGF = '000000';
				IF cCodRetGF::INTEGER <> 0 THEN
					LET cCodRet = '000003';
					LET cMensajeRet = 'OCURRIO UN ERROR EN EL PROCESO QUE GENERA EL FOLIO';
                    CONTINUE FOREACH;
				ELSE
																																						
					INSERT INTO bdicred:"informix".sd_maeretenido(empresa,num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori)
					VALUES('001',vcNumCredito,cFolioSucGF,vc_dtFechaHoy,CURRENT HOUR TO FRACTION(3),'4246',0,dMonto,cEjecutivo,'R',cFolioApertua||' MESES SIN INTERESES',cSucursal,0);

					-- Se genera el movimiento de la apertura de la compra a meses.																		
					EXECUTE PROCEDURE bdicred:"informix".genmov_tc('001',vcNumCredito,vProducto,vc_dtFechaHoy,dMonto,cFolioSucGF,cSucursal,vDivisa,'4246','','MESES SIN INTERESES',v_tipocambio,0,cEjecutivo,vsucorig,'','')
					INTO cCodRetGenMov, cMsjeGenMov;

					IF cCodRetGenMov::INTEGER <> 0 THEN
						LET cCodRet = '000006';
						LET cMensajeRet = 'OCURRIO UN ERROR EN EL PROCESO DE MOVIMIENTO DE APERTURA DE LA COMPRA A MESES';
                        CONTINUE FOREACH;
					END IF

					-- Actualiza el saldo retenido en la tabla de saldos
					UPDATE bdicred:"informix".sd_maesdos
					   SET sdo_retenido = sdo_retenido + dMonto
					 WHERE num_credito = vcNumCredito;

					-- Actualiza el status a 1
					UPDATE bdicred:"informix".sd_promocion_credito SET status = 1
					 WHERE num_credito = vcNumCredito
					   AND num_promo = sNumPromocion
					   AND folio_movto = cFolioMovto;					   

					-- Manda a llamar a el proceso de asignacion de solicitud
					EXECUTE PROCEDURE bdisolic:"informix".asigna_numsol('001','8900') INTO cCodRetANS, cNumSolANS;
					IF cCodRetANS::INTEGER <> 0 THEN
						LET cCodRet = '000004';
						LET cMensajeRet = 'OCURRIO UN ERROR EN EL PROCESO DE LA ASIGNACION DE LA SOLICITUD';
					ELSE
						-- Actualiza el numero de solicitud del prestamo en la tabla de las promociones
						let cNumSolANS = cNumSolANS;
						let vcNumCredito = vcNumCredito;
						let cFolioMovto = cFolioMovto;
						LET sNumPromocion = sNumPromocion;
						
						UPDATE bdicred:"informix".sd_promocion_credito SET num_sol_prestamo = cNumSolANS
						 WHERE num_credito = vcNumCredito
						   AND num_promo = sNumPromocion
						   AND folio_movto = cFolioMovto;

						-- Manda llamar al proceso de apertura de credito de prestamos.
						--EXECUTE PROCEDURE bdicred:"informix".sp_apercred1_credisol('001', cNumSolANS, cEjecutivo, sPlazo, cNomPromocion, dMonto, '', dPagoMensualPP)
						EXECUTE PROCEDURE bdicred:"informix".sp_msi_apercred1_msi('001', cNumSolANS, cEjecutivo, sPlazo, cNomPromocion, dMonto, '', dPagoMensualPP)
						INTO cCodRetAP, dTasaInteres, dTasaMora, dCatIva, cMercadeo;

						IF cCodRetAP::INTEGER <> 0 THEN
							EXECUTE PROCEDURE bdicred:"informix".reversion('001', cSucursal, cEjecutivo, cFolioSucGF, "M") INTO cCodRetRev;

							-- Actualiza el estatus a 4 como credito que se trabajo y obtuvo un error
							UPDATE bdicred:"informix".sd_promocion_credito
							   SET status = 4, num_sol_prestamo = ''
							 WHERE num_credito = vcNumCredito
							   AND num_promo = sNumPromocion
						       AND folio_movto = cFolioMovto;
				
							-- Se agrega cambio de estatus de la tabla sd_maeretenido
							UPDATE "informix".sd_maeretenido SET estatus = 'S'
							 WHERE empresa = '001' 
							   AND num_credito = vcNumCredito
							   AND referencia IN(vReferencia, vReferencia2)
							   AND estatus = 'R'
							   AND fecha = dFechaPromo;
							
							-- Regresa la secuencia anterior
							UPDATE bdisolic:"informix".ss_solic_producto SET secuencia_prod = secuencia_prod - 1
							 WHERE empresa = '001' AND num_producto = '8900';

							UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '6', envio_result_sms = '0', status_envio_r_sms = '0' 
							 WHERE num_credito = vcNumCredito AND folio_compra_sms = cFolioMovto;

							CONTINUE FOREACH;
						ELSE
							-- Actualiza el status a 2, es decir credisolucion vigente (creada correctamente)
							UPDATE bdicred:"informix".sd_promocion_credito SET status = 2, mensualidad = dPagoMensualPP, fecha = vc_dtFechaHoy
							WHERE num_credito = vcNumCredito AND num_promo = sNumPromocion AND folio_movto = cFolioMovto;

                            -- Actualiza registro de mov_dia con la apertura del credito
                            UPDATE bdicred:sd_movdia SET referencia = cFolioSucGF || ' ' || cNumSolANS
                             WHERE empresa = '001' AND num_credito = vcNumCredito 
                               AND codigo_fun = '060' AND codigo_ref = 10 AND folio_suc = cFolioSucGF;
							   							   
							-- Marca registro de apertura OK si es contratacion por SMS, para su envio posterior de SMS correspondiente.
							 UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '7', envio_result_sms = '1', status_envio_r_sms = '0', num_credisolucion = cNumSolANS
							 WHERE num_credito = vcNumCredito AND folio_compra_sms = cFolioMovto;
							LET cCodRet = '000000';
							
						END IF
					END IF
				END IF
			END IF
		END IF
	END FOREACH
	
	IF cCodRet <> '00000' THEN
        INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',vcNumCredito,'sp_msi_procesa_msi',vc_dtFechaHoy,CURRENT,'',sNumPromocion,cCodRet);
    END IF;

	RETURN cCodRet, cMensajeRet;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso que realiza la confirmacion de Meses sin Intereses',
'FECHA DE CREACION: Octubre 2021',
'--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------';

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
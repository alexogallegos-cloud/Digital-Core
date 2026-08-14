CREATE PROCEDURE "informix".sp_apercred1_credisol(
			 pEmpresa       VARCHAR(3), 	-- EMPRESA
             pSolicitud     VARCHAR(20), 	-- NUMERO DE SOLICITUD
		 	 pEjecutivo     CHAR(8),		-- EJECUTIVO
			 pPlazo			INTEGER,		-- PLAZO EN MESES PARA PAGAR EL CREDITO
			 pNombrePres	CHAR(50),		-- NOMBRE DEL PRESTAMO
			 pMonto			DECIMAL(18,2),	-- MONTO APROBADO
			 pCuentaCap		CHAR(20),		-- CUENTA DE CAPTACION
			 pMensualidad	MONEY(18,2),		-- IMPORTE MENSUAL
			 pCanal 		SMALLINT  	DEFAULT 0 -- CANAL       
			 )

RETURNING CHAR(6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),CHAR(1);


--MODIFICO: Paul Ivan Quintero Varela
--Descripcion: Se modificÃ³ para realizar la validaciÃ³n de los dÃ­as inhabiles.
--Fecha: 2010/01/27
--Version: 20100127.1100

--MODIFICO: JesÃºs Manuel Aguilar Heredia
--Descripcion: Se modificÃ³ para implemtentar la apertura de credisoluciones
--Fecha: 2012/01/12
--Version: 20120112.1100

--MODIFICO: Andrea Mariana Urrea Urias 
--Descripcion: Se agrego adecuaciones para permitir las promociones desde otros canales (bdinteg:si_canales)
--Fecha:2025/07/30
--Version: 20250730.1100

--*****************************************************
--DECLARACION DE VARIABLES
--*****************************************************
DEFINE cCodRet				VARCHAR(6);		-- CODIGO DE RETORNO
DEFINE cErrorInfo           VARCHAR(80);	-- MENSAJE DE ERROR
DEFINE mTasaInteres         DECIMAL(18,2);	-- TASA DE INTERES
DEFINE mTasaMora            DECIMAL(18,2);	-- TASA MORATORIA
DEFINE mSobreTasa           DECIMAL(18,2);	-- SOBRETASA
DEFINE mTasaFavor           DECIMAL(18,2);	-- TASA A FAVOR
DEFINE mSobreTasaFAV        DECIMAL(18,2);	-- SOBRETASA A FAVOR DEL CLIENTE
DEFINE cFactor	            CHAR(1);		-- FACTOR
DEFINE dFechaApert          DATE;			-- FECHA DE INICIO DEL PRESTAMO
DEFINE dFechaVenc           DATE;			-- FECHA DE TERMINACIÃN DEL PRESTAMO
DEFINE iSqlErr              INTEGER;		-- CODIGO DE ERROR
DEFINE iIsamError           INTEGER;		-- CODIGO DE ERROR
DEFINE cNumCte              CHAR(20);		-- NUMERO DE CLIENTE
DEFINE cTpCte               CHAR(1);		-- TIPO DE CLIENTE
DEFINE mIngreso             DECIMAL(18,2);	-- INGRESO DEL CLIENTE
DEFINE cFactorFAV           CHAR(1);		-- FACTOR A FAVOR DEL CLIENTE
DEFINE cProducto            CHAR(4);		-- CODIGO DE PRODUCTO
DEFINE cDivisa              CHAR(2);		-- DIVISA
DEFINE cSucursal            CHAR(4);		-- CODIGO DE SUCURSAL
DEFINE cFolio	            CHAR(16);		-- FOLIO PARA GENERACION DE MOVIMIENTOS DIARIOS
DEFINE cMensaje             CHAR(200);		-- MENSAJE MAS NOMBRE DE EJECUTIVO
DEFINE dFechaT              DATE;			-- FECHA DEL MES POSTERIOR A LA APERTURA
DEFINE sDiaCorte            SMALLINT;		-- DIA DE CORTE
DEFINE i		     		SMALLINT;		-- VARIABLE PARA ITERACION
DEFINE mCatIva		    	DECIMAL(18,2);	-- VALOR DEL CAT DEL IVA
DEFINE cMercadeo            CHAR(1);		-- PUBLICACION
DEFINE sSecIngreso 			SMALLINT;		-- SECUENCIA DE INGRESOS

DEFINE mTasaInteresProd		DECIMAL(18,2);	-- TASA DE INTERES DEL PRODUCTO
DEFINE mTasaMoraProd		DECIMAL(18,2);	-- TASA DE INTERES DEL PRODUCTO
DEFINE cPeriodoPag			CHAR(1);		-- PERIODICIDAD DEL PAGO
DEFINE iDiasTraspCap		INTEGER;		-- DIAS PARA TRASPASO DE CAPITAL
DEFINE iDiasTraspInt		INTEGER;		-- DIAS PARA TRASPASO DE INTERESES
DEFINE cNumeroFolio 		CHAR(16);		-- FOLIO PARA REGISTRAR EL ABONO
DEFINE cTransacc 			CHAR(4);	 	-- FOLIO DE TRANSACCION DEL ABONO
DEFINE iNumReg				INTEGER;		-- NUMERO DE REGISTROS DE UNA OPERACION
DEFINE dIvaSuc              DECIMAL(5,3);   -- IVA DE LA SUCURSAL DONDE SE GENERÃ LA SOLICITUD
DEFINE idAbono              CHAR(1);
DEFINE bandesp              SMALLINT;
DEFINE v_tasainteres        DECIMAL(18,2);   
DEFINE sCountExist          SMALLINT;
DEFINE sContPaso	        SMALLINT;
DEFINE sNumPromocion		SMALLINT;
DEFINE sCountExstCred		SMALLINT;
DEFINE sCountExstDos		SMALLINT;
DEFINE sCountExstAnexo		SMALLINT;
DEFINE sCountCtasCarg		SMALLINT;
DEFINE sCountAmortiz		SMALLINT;
DEFINE sCountAutoriz		SMALLINT;
DEFINE sCountExistSms		SMALLINT;
DEFINE cStatus_cred 		CHAR(2);
DEFINE cIFRS				CHAR(1);
DEFINE iAtr_Act_ifrs		INTEGER;
DEFINE iDisposicionEfectivoApp      SMALLINT;  
DEFINE iComprasApp          SMALLINT; 
DEFINE iCanalApp			SMALLINT;
DEFINE pNumCredito         	CHAR(20);
DEFINE pPromo              	INTEGER;
DEFINE tasaPref 			DECIMAL(18,6);


--***********************
--INICIALIZA VARIABLES
--***********************

LET cCodRet      		= '000000';
LET cErrorInfo    		= 'PROCESO EXITOSO';
LET mTasaInteres 		= 0;
LET mTasaMora 			= 0;
LET mSobreTasa   		= 0;
LET mTasaFavor   		= 0;
LET mSobreTasaFAV		= 0;
LET cFactor	  			= "";
LET dFechaApert 		= DATE(1);
LET dFechaVenc 			= DATE(1);
LET iSqlErr    			= 0;
LET iIsamError 			= 0;
LET cErrorInfo 			= "";
LET cNumCte    			= "";
LET cTpCte     			= "";
LET mIngreso   			= 0;
LET cFactorFAV 			= "";
LET cProducto  			= "";
LET cDivisa    			= "";
LET cSucursal			= "";
LET cFolio				= "";
LET cMensaje 			= "";
LET dFechaT  			= DATE(1);
LET sDiaCorte			= 0;
LET i 					= 0;
LET mCatIva				= 0;
LET cMercadeo 			= "";
LET sSecIngreso			= 0;

LET mTasaInteresProd	= 0;
LET cPeriodoPag			= "";
LET iDiasTraspCap		= 0;
LET iDiasTraspInt		= 0;
LET cNumeroFolio		= "";
LET cTransacc			= "";
LET iNumReg				= 0;

LET dIvaSuc             = 0;
LET idAbono             = "N";
LET bandesp             = 0;
LET v_tasainteres       = 0;
LET sCountExist			= 0;
LET sContPaso	        = 0;
LET sNumPromocion		= 0;
LET sCountExstCred		= 0;
LET sCountExstDos		= 0;
LET sCountExstAnexo		= 0;
LET sCountCtasCarg		= 0;
LET sCountAmortiz		= 0;
LET sCountAutoriz		= 0;
LET sCountExistSms		= 0;
LET cIFRS				= '';
LET iAtr_Act_ifrs		= 0;
LET cStatus_cred 		= '';
LET iDisposicionEfectivoApp = 7;
LET iComprasApp 		= 8;
LET iCanalApp 			= 17;
LET pNumCredito         = '';
LET pPromo              = 0;
LET tasaPref 			= 0;



--Set debug file to  '/tmp/apercred_pp.out';
--trace on;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamError, cErrorInfo
		LET cErrorInfo  = cErrorInfo;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		

		DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
	    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
		DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM bdicred:"informix".sd_ctascarg WHERE num_credito = pSolicitud;
        DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
        IF idAbono = "S" THEN
             CALL bdicheq:reversion(pEmpresa,cSucursal,pEjecutivo,cNumeroFolio,'R') RETURNING cCodRet;
             IF cCodRet <> "000" THEN
                LET cCodRet    = "000004";
             END IF;
        END IF;
        LET cCodRet    = iSqlErr;
        RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
    END EXCEPTION;
	
	
	SELECT NVL(valor,'I') INTO cIFRS FROM bdicred:sd_param WHERE cod_param = '700';
	IF cIFRS = 'A' THEN
		LET cStatus_cred = 'E1';
		LET iAtr_Act_ifrs = 0;
	ELSE
		LET cStatus_cred = 'AA';
		LET iAtr_Act_ifrs = NULL;
	END IF;	

	--SE VALIDA QUE LOS DATOS DE ENTRADA SEAN CORRECTOS
    IF pSolicitud > '690000000000' THEN
        IF NVL(pEmpresa,"") = "" OR NVL(pSolicitud,"") = "" OR NVL(pEjecutivo,"") = "" OR NVL(pPlazo,0) = 0 OR NVL(pNombrePres,"") = "" OR
           NVL(pMonto,0) = 0 THEN
            LET cCodRet = "000002";
            RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
        END IF
    ELSE
        IF NVL(pEmpresa,"") = "" OR NVL(pSolicitud,"") = "" OR NVL(pEjecutivo,"") = "" OR NVL(pPlazo,0) = 0 OR NVL(pNombrePres,"") = "" OR
           NVL(pMonto,0) = 0 OR NVL(pCuentaCap,"") = "" THEN
            LET cCodRet = "000002";
            RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
        END IF
    END IF;

-- SE OBTIENEN LAS FECHAS DE INICIO, Y FIN DEL PRESTAMO Y LA FECHA DEL SIGUIENTE MES DESPUES DE LA APERTURA DEL CREDITO
    SELECT fecha_hoy INTO dFechaApert FROM bdicred:"informix".sd_fechas WHERE empresa = pEmpresa;

    CALL bdicred:"informix".monthadd(dFechaApert,pPlazo) RETURNING dFechaVenc;

	CALL bdicred:"informix".monthadd(dFechaApert,1) RETURNING dFechaT;
    CALL bdicred:"informix".sp_valfechabil(dFechaT,'+') RETURNING cCodRet, dFechaT;

    IF cCodRet <> "000" THEN
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
    END IF;

	--SE VALIDA QUE NO EXISTA EL CREDITO
	SELECT count(num_credito) INTO sCountExstCred FROM bdicred:"informix".SD_MAECREDCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	SELECT count(num_credito) INTO sCountExstDos FROM bdicred:"informix".SD_MAESDOSCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	SELECT count(num_credito) INTO sCountExstAnexo FROM bdicred:"informix".SD_MAECREDANEXOCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	SELECT count(num_credito) INTO sCountCtasCarg FROM bdicred:"informix".sd_ctascarg WHERE empresa = pEmpresa AND Naturaleza = 'A' AND num_credito = pSolicitud;
	SELECT count(num_credito) INTO sCountAmortiz FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND fecha_cuota = dFechaT AND num_credito = pSolicitud;
	SELECT count(num_solicitud) INTO sCountAutoriz FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
	


	--IF EXISTS (SELECT num_credito FROM bdicred:"informix".SD_MAECREDCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud) THEN
	IF sCountExstCred >= 1 THEN
		LET cCodRet = "000001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	--ELIF EXISTS (SELECT num_credito FROM bdicred:"informix".SD_MAESDOSCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud) THEN
	ELIF sCountExstDos >= 1 THEN
		LET cCodRet = "000001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	--ELIF EXISTS (SELECT num_credito FROM bdicred:"informix".SD_MAECREDANEXOCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud) THEN
	ELIF sCountExstAnexo >= 1 THEN
		LET cCodRet = "000001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	--ELIF EXISTS (SELECT num_credito FROM bdicred:"informix".sd_ctascarg WHERE empresa = pEmpresa AND Naturaleza = 'A' AND num_credito = pSolicitud) THEN
	ELIF sCountCtasCarg >= 1 THEN
		LET cCodRet = "000001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	--ELIF EXISTS (SELECT num_credito FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND fecha_cuota = dFechaT AND num_credito = pSolicitud) THEN
	ELIF sCountAmortiz >= 1 THEN
		LET cCodRet = "000001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	--ELIF EXISTS (SELECT num_solicitud FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP") THEN
	ELIF sCountAutoriz >= 1 THEN
		LET cCodRet = "000001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	END IF;

	--   Asigna el Valor del CAT con IVA para el Contrato TC MEL 15 May 2008
	SELECT valor INTO mCatIva
	FROM  bdicred:'informix'.sd_param
	WHERE  cod_param = '034';
	IF mCatIva IS NULL THEN
	   LET mCatIva = 0;
	END IF
	
	---Validar que el credito exista en las tablas de promociones, en casod e existir se se tomara la informacion de las tablas de promociones.
	SELECT count(num_sol_prestamo) INTO sCountExist FROM bdicred:"informix".sd_promocion_credito WHERE num_sol_prestamo = pSolicitud;
	
	--IF EXISTS (SELECT num_sol_prestamo  FROM bdicred:"informix".sd_promocion_credito WHERE num_sol_prestamo = pSolicitud) THEN
	IF sCountExist > 0 THEN
		-- SE DETERMINAN LAS DIFERENTES TASAS DE INTERES		
		
		-- Valida si son credisoluciones por medio de SMS
		SELECT num_promo INTO sNumPromocion FROM bdicred:"informix".sd_promocion_credito WHERE num_sol_prestamo = pSolicitud;
		IF sNumPromocion in (2, 5, 8) THEN
		
			SELECT COUNT(a.tasa) INTO sCountExistSms FROM sd_promocion_credito_sms a INNER JOIN sd_promocion_credito b ON (a.num_credito = b.num_credito and a.folio_compra_sms = b.folio_movto)
			 WHERE b.num_sol_prestamo = pSolicitud and a.mnto_compra = pMonto;
			IF sCountExistSms > 0 THEN
				SELECT first 1 a.tasa INTO v_tasainteres FROM sd_promocion_credito_sms a INNER JOIN sd_promocion_credito b ON (a.num_credito = b.num_credito and a.folio_compra_sms = b.folio_movto)
				WHERE b.num_sol_prestamo = pSolicitud and a.mnto_compra = pMonto;
				LET bandesp = 1;
			END IF;
		ELIF sNumPromocion in (3, 6, 9) THEN
		
			SELECT COUNT(a.tasa) INTO sCountExistSms FROM bdicred:sd_promocion_credito_sms a JOIN bdicred:sd_promocion_credito b ON (a.num_credito = b.num_credito and a.num_promo = b.num_promo and mnto_compra = monto_actual and a.plazo = b.plazo )
			 WHERE num_sol_prestamo = pSolicitud;
			IF sCountExistSms > 0 THEN
				SELECT first 1 a.tasa INTO v_tasainteres
				  FROM bdicred:sd_promocion_credito_sms a JOIN bdicred:sd_promocion_credito b ON (a.num_credito = b.num_credito and a.num_promo = b.num_promo and mnto_compra = monto_actual and a.plazo = b.plazo )
				  WHERE num_sol_prestamo = pSolicitud;
				  LET bandesp = 1;
			END IF;
		END IF;	
		--IF NVL(v_tasainteres, 0) != 0 THEN
		--	LET bandesp = 1;		
		--END IF;
		
		-- Valida si son credisoluciones por carga de archivo 
		SELECT COUNT(a.tasa) INTO sContPaso FROM sd_credpaso a INNER JOIN sd_promocion_credito b ON a.num_credito = b.num_credito WHERE b.num_sol_prestamo = pSolicitud and a.monto_actual = pMonto;
        --IF EXISTS(SELECT a.tasa FROM sd_credpaso a INNER JOIN sd_promocion_credito b  ON a.num_credito=b.num_credito WHERE b.num_sol_prestamo = pSolicitud and a.monto_actual = pMonto) THEN
		IF sContPaso > 0 THEN
            SELECT first 1 a.tasa INTO v_tasainteres FROM sd_credpaso a INNER JOIN sd_promocion_credito b  ON a.num_credito=b.num_credito WHERE b.num_sol_prestamo=pSolicitud and a.monto_actual=pMonto; 
            LET bandesp=1;
        END IF;
		
		
		
		--Correccion
		IF (snumpromocion IN (iDisposicionEfectivoApp, iComprasApp) AND pCanal == iCanalApp) THEN		
		
			SELECT c.tasa, a.factor_sobretasa, a.sobretasa, a.dia_cuota, a.periodo_plazo,b.num_credito,b.num_promo 
			INTO mTasaInteres, cFactor, mSobreTasa, sDiaCorte, cPeriodoPag, pNumCredito, pPromo
			FROM bdicred:"informix".sd_definicion a
			   INNER JOIN bdicred:"informix".sd_promocion_credito b ON b.empresa = a.empresa AND b.num_pro_prestamo = a.num_producto
			   INNER JOIN bdicred:"informix".sd_maecred mae ON b.num_credito = mae.num_credito
			   INNER JOIN bdicred:"informix".sd_tasa_plazo_app c ON (c.plazo = b.plazo AND b.num_promo = c.num_promo AND c.plazo_activo = 1  AND c.num_producto = mae.num_producto)
			WHERE b.empresa = pEmpresa AND b.num_sol_prestamo = pSolicitud;

			-- BUSCAMOS EN LA sd_prospectos SI LA TASA ES MAYOR A 0
				  SELECT NVL(tasa, 0.00) INTO tasaPref
				  FROM "informix".sd_prospectos
				  WHERE empresa = pEmpresa
				  AND num_credito = pNumCredito
				  AND num_producto = '6900'
				  AND num_promo = pPromo;
				  
			if tasaPref > 0 THEN 
				LET mTasaInteres = tasaPref;
			END IF;
		
		ELSE
				
			--INTERES ORDINARIO --se liga con la tabla sd_promocion_credito
			SELECT c.tasa, a.factor_sobretasa, a.sobretasa, a.dia_cuota, a.periodo_plazo
			INTO mTasaInteres, cFactor, mSobreTasa, sDiaCorte, cPeriodoPag
			FROM bdicred:"informix".sd_definicion a
				INNER JOIN bdicred:"informix".sd_promocion_credito b ON b.empresa = a.empresa AND b.num_pro_prestamo = a.num_producto
				INNER JOIN bdicred:"informix".sd_tasa_plazo c ON (c.plazo = b.plazo AND b.num_promo =c.num_promo AND c.plazo_activo = 1 )
			WHERE b.empresa = pEmpresa AND b.num_sol_prestamo = pSolicitud;

		END IF;



        IF (bandesp=1 AND pCanal <> iCanalApp) THEN 
            LET mTasaInteresProd = v_tasainteres;
            LET mTasaInteres = v_tasainteres;

			IF NVL(cPeriodoPag,'') = '' THEN		-- Si el plazo no existe, es sms y ya cambiaron los plazos.
				SELECT a.factor_sobretasa, a.sobretasa, a.dia_cuota, a.periodo_plazo
				INTO   cFactor           , mSobreTasa , sDiaCorte  , cPeriodoPag
				FROM bdicred:"informix".sd_definicion a
					INNER JOIN bdicred:"informix".sd_promocion_credito b ON b.empresa = a.empresa AND b.num_pro_prestamo = a.num_producto
				WHERE b.empresa = pEmpresa AND b.num_sol_prestamo = pSolicitud;			
			END IF;
        ELSE
			LET mTasaInteresProd = mTasaInteres;
        END IF;

		IF cFactor = "+" THEN
			LET mTasaInteres = mTasaInteres + mSobreTasa;
		ELIF cFactor = "-" THEN
			LET mTasaInteres = mTasaInteres - mSobreTasa;
		ELIF cFactor = "*" THEN
			LET mTasaInteres = mTasaInteres * mSobreTasa;
		ELSE
			LET mTasaInteres = mTasaInteres / mSobreTasa;
		END IF

		--INTERES MORATORIO
		SELECT c.valor, a.fact_sobret_mora, a.sobretasa_mora
		INTO mTasaMora, cFactor, mSobreTasa
		FROM bdicred:"informix".sd_definicion a
			INNER JOIN bdicred:"informix".sd_promocion_credito b ON b.empresa = a.empresa AND b.num_pro_prestamo = a.num_producto
			INNER JOIN bdinteg:"informix".si_fechavalor c ON c.empresa = a.empresa AND c.tasa = a.cod_tasa_mora
		WHERE b.empresa = pEmpresa AND b.num_sol_prestamo = pSolicitud
		AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r WHERE r.empresa = pEmpresa AND r.tasa = a.cod_tasa_mora);

		LET mTasaMoraProd = mTasaMora;

		IF cFactor = "+" THEN
				LET mTasaMora = mTasaMora + mSobreTasa;
		ELIF cFactor = "-" THEN
				LET mTasaMora = mTasaMora - mSobreTasa;
		ELIF cFactor = "*" THEN
				LET mTasaMora = mTasaMora * mSobreTasa;
		ELSE
				LET mTasaMora = mTasaMora / mSobreTasa;
		END IF

		--INTERES A FAVOR DEL CLIENTE
		SELECT c.valor, a.factor_sobretasa, a.sobretasa
		INTO mTasaFavor, cFactorFAV, mSobreTasaFAV
		FROM bdicred:"informix".sd_anexodefinicion a
			INNER JOIN bdicred:"informix".sd_promocion_credito b ON b.empresa = a.empresa AND b.num_pro_prestamo = a.num_producto
			INNER JOIN bdinteg:"informix".si_fechavalor c ON c.empresa = a.empresa AND c.tasa = a.cod_tasa_base
		WHERE b.empresa = pEmpresa AND b.num_sol_prestamo = pSolicitud
		AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r WHERE r.empresa = pEmpresa AND r.tasa = a.cod_tasa_base);


		IF cFactorFAV = "+" THEN
				LET mTasaFavor = mTasaFavor + mSobreTasaFAV;
		ELIF cFactorFAV = "-" THEN
				LET mTasaFavor = mTasaFavor - mSobreTasaFAV;
		ELIF cFactorFAV = "*" THEN
				LET mTasaFavor = mTasaFavor * mSobreTasaFAV;
		ELSE
				LET mTasaFavor = mTasaFavor / mSobreTasaFAV;
		END IF

		-- SE OBTIENE LA CLAVE DEL PRODUCTO, EL CODIGO DE DIVISA, EL MONTO DEL PRESTAMO SOLICITADO Y LA SUCURSAL
		SELECT a.num_producto, a.divisa, b.sucursal
		INTO cProducto, cDivisa, cSucursal
		FROM bdicred:"informix".sd_promocion_credito b
		  INNER JOIN bdicred:"informix".sd_definicion a ON a.empresa = b.empresa AND a.num_producto = b.num_pro_prestamo
		WHERE b.empresa = pEmpresa AND b.num_sol_prestamo = pSolicitud;

		SELECT a.iva
			INTO dIvaSuc
		FROM bdinteg:"informix".si_sucursales a
		WHERE a.sucursal = cSucursal
		AND a.empresa  = pEmpresa;

		  --***** SE INSERTA INFORMACION EN SD_MAECREDCRD
		INSERT INTO bdicred:"informix".sd_maecredcrd
			   (empresa,                        num_credito,
				num_producto,                   ejecutivo,
				numcte,                         aval_cte,
				aval_linea,                     divisa,
				sucursal,                       id_origen,
				origen,                         cod_tipo_linea,
				cod_linea,                      status_cred,
				bandera_renovac,                bandera_prorroga,
				periodo_plazo,                  plazo,
				fecha_apertura,                 fecha_vencim,
				period_pago_cap,                period_pag_int,
				dias_trasp_cap,                 dias_trasp_int,
				tasa_fija_o_var,                cod_tasa_base,
				factor_sobretasa,               sobretasa,
				tasa_interes,                   cod_tasa_mora,
				sobretasa_mora,                 fact_sobret_mora,
				tasa_moratorios,                tasa_preferencial,
				sobretasa_preferencial,         factor_preferencial,
				valor_preferencial,             fecha_pago_cap,
				fecha_pago_int,                 es_fisica,
				bandera_fi_fo,                  actividad,
				tipo_calculo,                   num_aper_ant,
				rev_tasa_var_per,               dia_para_revisar,
				cod_prod,                       bandera_ministra,
				credito_externo,                califica_riesgo,
				cod_agricola,                   pagos_sostenidos,
				campo_trab1,                    campo_trab2,
				campo_trab3,                    campo_trab4
			   )
		SELECT  sol.empresa                		,pSolicitud
			   ,sol.num_pro_prestamo            ,pEjecutivo
			   ,sol.num_cte                      ,''
			   ,''                              ,NVL(def.divisa,1)
			   ,NVL(sol.sucursal,'')            ,''
			   ,''                              ,''
			   --IFRS,''                              ,'AA'
			   ,''								,cStatus_cred
			   ,'S'                             ,'N'
			   ,NVL(def.periodo_plazo,'')       ,pPlazo
			   ,dFechaApert  					,dFechaVenc
			   ,NVL(def.period_pago_cap,'')     ,NVL(def.period_pag_int,'')
			   ,NVL(def.dias_traspaso_cap,0)    ,NVL(def.dias_traspaso_int,0)
			   ,NVL(def.tasa_fija_o_var,'')     ,NVL(def.cod_tasa_base,'')
			   ,NVL(def.factor_sobretasa,'')    ,NVL(def.sobretasa,'')
			   ,mTasaInteresProd                ,NVL(def.cod_tasa_mora,'')
			   ,NVL(def.sobretasa_mora,0)       ,NVL(def.fact_sobret_mora,'')
			   ,NVL(mTasaMoraProd,0)            ,''
			   ,0                               ,''
			   ,0                               ,dFechaT
			   ,dFechaT							,NVL(tip.es_fisica,'')
			   ,''                              ,''
			   ,NVL(def.tipo_calculo,'')        ,dIvaSuc
			   ,''                              ,NVL(def.dia_para_revisar,0)
			   ,''                              ,cPeriodoPag
			   ,''                              ,''
			   ,''                              ,0
			   ,0                               ,0
			   ,''                              ,''
		FROM bdicred:"informix".sd_promocion_credito sol
		INNER JOIN bdicred:"informix".sd_definicion def ON def.empresa = sol.empresa AND def.num_producto = sol.num_pro_prestamo
		INNER JOIN bdinteg:"informix".si_cliente cli ON cli.empresa = sol.empresa AND cli.numcte = sol.num_cte
		INNER JOIN bdinteg:"informix".si_tipper tip ON tip.tpo_persona = cli.tpo_persona
		WHERE  sol.num_sol_prestamo = pSolicitud AND sol.empresa = pEmpresa;


		LET iNumReg = dbinfo("sqlca.sqlerrd2");

		IF iNumReg = 0 THEN
			LET cCodRet = "000003";
			DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
            DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
			RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
		END IF;

		 --***** SE INSERTA INFORMACION EN SD_MAECREDANEXOCRD (DATOS PARA TARJETA DE CREDITO)
		BEGIN
			ON EXCEPTION SET iSqlErr, iIsamError, cErrorInfo
				 LET cCodRet    = iSqlErr;

				 LET cErrorInfo  = cErrorInfo;
				 RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			END EXCEPTION;


			INSERT INTO bdicred:"informix".sd_maecredanexocrd
				(empresa, 				 		num_credito,
				 localidad,              		dia_corte,
				 dias_gracia_mora, 		 		tp_dias_calc_mora,
				 dias_fecha_max_pago,	 		tp_dias_fecha_pago,
				 cod_tasa_base_cte, 	 		factor_sobretasa_cte,
				 sobretasa_cte, 		 		tasa_interes_cte,
				 fecha_vencto, 			 		prox_fecha_pago,
				 fecha_proceso,			 		fecha_ult_pago,
				 nombre_pres)
			SELECT pEmpresa              		,pSolicitud,
				   ""                    		,DAY(dFechaApert),
				   NVL(def.gracia_calc_mora,0)  ,'',
				   DAY(dFechaApert)      		,NVL(def.maneja_linea,''),
				   NVL(def.cod_tasa_base,'')	,NVL(def.factor_sobretasa,''),
				   NVL(def.sobretasa,0)    		,mTasaInteresProd,
				   ""                    		,dFechaT,
				   dFechaApert           		,"",
				   pNombrePres
			FROM bdicred:"informix".sd_definicion def
				INNER JOIN bdicred:"informix".sd_promocion_credito c ON c.empresa = def.empresa AND c.num_pro_prestamo = def.num_producto
			WHERE c.empresa = pEmpresa AND c.num_sol_prestamo = pSolicitud;
		END;
		  --***** SE INSERTA INFORMACION EN SD_MAESDOSCRD

		LET iNumReg = dbinfo("sqlca.sqlerrd2");

		IF iNumReg = 0 THEN
			LET cCodRet = "000003";

			DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
            DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
			RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
		END IF;


		BEGIN
			ON EXCEPTION SET iSqlErr, iIsamError, cErrorInfo
				 LET cCodRet    = iSqlErr;
				 LET cErrorInfo  = cErrorInfo;
				 RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			END EXCEPTION;

			INSERT INTO bdicred:"informix".sd_maesdoscrd
					(
						empresa, 			num_credito,		fecha_ult_mov, 		sdo_int_anticip,
						sdo_int_ant_dev, 	sdo_intereses,		sdo_dia_ant_int, 	sdo_mes_ant_int,
						sdo_acum_mes_int, 	sdo_retenido,		sdo_acum_cap_int, 	sdo_exig_int,
						sdo_no_exig, 		provision_normal,	dias_acum_int, 		sdo_moratorio,
						sdo_dia_ant_mor, 	sdo_mes_ant_mor,	sdo_contab_mora, 	dias_acum_mora,
						sdo_capital, 		sdo_cap_insoluto,	sdo_dia_ant_cap, 	sdo_mes_ant_cap,
						sdo_acum_mes_cap, 	mto_capitalizado,	mto_ministra_cap, 	cargos_dia_cap,
						abonos_dia_cap, 	cargos_mes_cap,		abonos_mes_cap, 	dias_acum_cap,
						monto_vencido, 		mto_venc_trasp,		monto_financiado, 	monto_reservado,
						sdo_acum_vencido, 	dias_acum_intper,	sdo_global_int, 	sdo_acum_intper,
						monto_otorgado, 	provi_venc_normal,	provi_venc_anticip, cap_tras_no_venci,
						mto_venc_int, 		mto_venc_tra_int,	mto_finan_vdo, 		mto_reser_int,
						mto_fin_ven_trasp, 	mto_fin_vig_trasp,	int_tra_no_exig, 	sdo_trab4,
						atr
					)
			VALUES
					(
						pEmpresa                ,pSolicitud, 	dFechaApert            ,0
						,0                      ,0				,0                      ,0
						,0                      ,0				,0                      ,0
						,0                      ,0				,0                      ,0
						,0                      ,0				,0                      ,0
						,pMonto                 ,pMonto			,0                      ,0
						,0                      ,0				,0                      ,0
						,0                      ,0				,0                      ,0
						,0                      ,0				,0                      ,0
						,0                      ,0				,0                      ,0
						,pMonto					,0				,0                      ,0
						,0                      ,0				,0                      ,0
						,0                      ,0				,0                      ,0
						,iAtr_Act_ifrs
					);
		END;

		LET iNumReg = dbinfo("sqlca.sqlerrd2");
		IF iNumReg = 0 THEN
			LET cCodRet = "000003";

			DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
            DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
			RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
		END IF;

		-- SE GENERA EL FOLIO
		CALL bdicheq:"informix".sp_generafolionomina(pEjecutivo) RETURNING cCodRet, cNumeroFolio;

		-- SE ASIGNA EL FOLIO DE LA TRANSACCION
		LET cTransacc = "0247";

		EXECUTE PROCEDURE "informix".genmovcrd(pEmpresa         , pSolicitud,	cProducto        , 3,
									"001"            , dFechaApert,
									pMonto           , cNumeroFolio,
									cSucursal        , cDivisa,
									"0000",'APERTURA','')
		INTO cCodRet, cErrorInfo;

		IF cCodRet <> "000000" THEN
			DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
            DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
			RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
		END IF

		EXECUTE PROCEDURE "informix".genmovcrd(pEmpresa         , pSolicitud,
									cProducto        , 66,
									"002"            , dFechaApert,
									pMonto           , cNumeroFolio,
									cSucursal        , cDivisa,
									"0000",'DISPOSICION','')
		INTO cCodRet, cErrorInfo;

		IF cCodRet <> "000000" THEN
			DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
            DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
			RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
		END IF


		-- SE INSERTA INSERTA INFORMACION EN LA TABLA DE AMORTIZACIONES
		INSERT INTO bdicred:"informix".sd_amortiza_creditocrd
			(
				empresa, 			num_credito,
				fecha_cuota, 		tipo_cuota,
				capital_mto_cuota, 	capital_debe,
				capital_pagado, 	capital_status,
				capital_status_ant, capital_fecha_pago,
				interes_debe, 		interes_pagado,
				interes_status, 	interes_status_ant,
				interes_fecha_pago, iva_debe,
				iva_pagado, 		iva_status,
				iva_status_ant, 	iva_fecha_pago,
				mora_provi_ordi, 	mora_provi_cope,
				mora_sdo_ordi, 		mora_sdo_ordi_pag,
				mora_sdo_cope, 		mora_sdo_cope_pag,
				mora_bonificado, 	mora_status,
				mora_iva_debe, 		mora_iva_pagado,
				mora_iva_status, 	mora_iva_fecha_pago,
				num_pago, 			campo_trabajo1,
				campo_trabajo2, 	campo_trabajo3,
				campo_trabajo4
			)
		VALUES
			(
				pEmpresa,			pSolicitud,
				dFechaT,			"3",
				pMensualidad,		0,
				0,					"3",
				"3",				"",
				0,					0,
				"1",				"1",
				"",					0,
				0,					"1",
				"1",				"",
				0,					0,
				0,					0,
				0,					0,
				0,					"1",
				0,					0,
				"1",				"",
				1,					0,
				0,					"",
				""
			);

	ELSE---proceso productivo de apertura de prestamos...	o se sigue el flujo normal....

		    -- SE DETERMINAN LAS DIFERENTES TASAS DE INTERES

			--INTERES ORDINARIO
			SELECT c.valor, a.factor_sobretasa, a.sobretasa, a.dia_cuota, a.periodo_plazo
			INTO mTasaInteres, cFactor, mSobreTasa, sDiaCorte, cPeriodoPag
			FROM bdicred:"informix".sd_definicion a
				INNER JOIN bdisolic:"informix".ss_solicitudes b ON b.empresa = a.empresa AND b.num_producto = a.num_producto
				INNER JOIN bdinteg:"informix".si_fechavalor c ON c.empresa = a.empresa AND c.tasa = a.cod_tasa_base
			WHERE b.empresa = pEmpresa AND b.num_solicitud = pSolicitud
				AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r WHERE r.empresa = pEmpresa AND r.tasa = a.cod_tasa_base);

			LET mTasaInteresProd = mTasaInteres;

			IF cFactor = "+" THEN
				LET mTasaInteres = mTasaInteres + mSobreTasa;
			ELIF cFactor = "-" THEN
				LET mTasaInteres = mTasaInteres - mSobreTasa;
			ELIF cFactor = "*" THEN
				LET mTasaInteres = mTasaInteres * mSobreTasa;
			ELSE
				LET mTasaInteres = mTasaInteres / mSobreTasa;
			END IF

			--INTERES MORATORIO
			SELECT c.valor, a.fact_sobret_mora, a.sobretasa_mora
			INTO mTasaMora, cFactor, mSobreTasa
			FROM bdicred:"informix".sd_definicion a
			    INNER JOIN bdisolic:"informix".ss_solicitudes b ON b.empresa = a.empresa AND b.num_producto = a.num_producto
				INNER JOIN bdinteg:"informix".si_fechavalor c ON c.empresa = a.empresa AND c.tasa = a.cod_tasa_mora
			WHERE b.empresa = pEmpresa AND num_solicitud = pSolicitud
			    AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r WHERE r.empresa = pEmpresa AND r.tasa = a.cod_tasa_mora);

			LET mTasaMoraProd = mTasaMora;

			IF cFactor = "+" THEN
					LET mTasaMora = mTasaMora + mSobreTasa;
			ELIF cFactor = "-" THEN
					LET mTasaMora = mTasaMora - mSobreTasa;
			ELIF cFactor = "*" THEN
					LET mTasaMora = mTasaMora * mSobreTasa;
			ELSE
					LET mTasaMora = mTasaMora / mSobreTasa;
			END IF

			--INTERES A FAVOR DEL CLIENTE
			SELECT c.valor, a.factor_sobretasa, a.sobretasa
			INTO mTasaFavor, cFactorFAV, mSobreTasaFAV
			FROM bdicred:"informix".sd_anexodefinicion a
				INNER JOIN bdisolic:"informix".ss_solicitudes b ON b.empresa = a.empresa AND b.num_producto = a.num_producto
				INNER JOIN bdinteg:"informix".si_fechavalor c ON c.empresa = a.empresa AND c.tasa = a.cod_tasa_base
			WHERE b.empresa = pEmpresa AND num_solicitud = pSolicitud
				AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r WHERE r.empresa = pEmpresa AND r.tasa = a.cod_tasa_base);

			IF cFactorFAV = "+" THEN
					LET mTasaFavor = mTasaFavor + mSobreTasaFAV;
			ELIF cFactorFAV = "-" THEN
					LET mTasaFavor = mTasaFavor - mSobreTasaFAV;
			ELIF cFactorFAV = "*" THEN
					LET mTasaFavor = mTasaFavor * mSobreTasaFAV;
			ELSE
					LET mTasaFavor = mTasaFavor / mSobreTasaFAV;
			END IF

			-- SE OBTIENE LA CLAVE DEL PRODUCTO, EL CODIGO DE DIVISA, EL MONTO DEL PRESTAMO SOLICITADO Y LA SUCURSAL
			SELECT a.num_producto, a.divisa, b.sucursal
			INTO cProducto, cDivisa, cSucursal
			FROM bdisolic:"informix".ss_solicitudes b
			  INNER JOIN bdicred:"informix".sd_definicion a ON a.empresa = b.empresa AND a.num_producto = b.num_producto
			WHERE b.empresa = pEmpresa AND b.num_solicitud = pSolicitud;

		       SELECT a.iva
		         INTO dIvaSuc
		         FROM bdinteg:"informix".si_sucursales a
		        WHERE a.sucursal = cSucursal
		          AND a.empresa  = pEmpresa;

		      --***** SE INSERTA INFORMACION EN SD_MAECREDCRD
			INSERT INTO bdicred:"informix".sd_maecredcrd
				   (empresa,                        num_credito,
					num_producto,                   ejecutivo,
					numcte,                         aval_cte,
					aval_linea,                     divisa,
					sucursal,                       id_origen,
					origen,                         cod_tipo_linea,
					cod_linea,                      status_cred,
					bandera_renovac,                bandera_prorroga,
					periodo_plazo,                  plazo,
					fecha_apertura,                 fecha_vencim,
					period_pago_cap,                period_pag_int,
					dias_trasp_cap,                 dias_trasp_int,
					tasa_fija_o_var,                cod_tasa_base,
					factor_sobretasa,               sobretasa,
					tasa_interes,                   cod_tasa_mora,
					sobretasa_mora,                 fact_sobret_mora,
					tasa_moratorios,                tasa_preferencial,
					sobretasa_preferencial,         factor_preferencial,
					valor_preferencial,             fecha_pago_cap,
					fecha_pago_int,                 es_fisica,
					bandera_fi_fo,                  actividad,
					tipo_calculo,                   num_aper_ant,
					rev_tasa_var_per,               dia_para_revisar,
					cod_prod,                       bandera_ministra,
					credito_externo,                califica_riesgo,
					cod_agricola,                   pagos_sostenidos,
					campo_trab1,                    campo_trab2,
					campo_trab3,                    campo_trab4
				   )
			SELECT  sol.empresa                		,pSolicitud
				   ,sol.num_producto                ,NVL(anx.ejecutivo_sol,'')
				   ,sol.numcte                      ,''
				   ,''                              ,NVL(def.divisa,1)
				   ,NVL(sol.sucursal,'')            ,''
				   ,''                              ,''
				   --IFRS,''                              ,'AA'
				   ,''                              ,cStatus_cred
				   ,'S'                             ,'N'
				   ,NVL(def.periodo_plazo,'')       ,pPlazo
				   ,dFechaApert  					,dFechaVenc
				   ,NVL(def.period_pago_cap,'')     ,NVL(def.period_pag_int,'')
				   ,NVL(def.dias_traspaso_cap,0)    ,NVL(def.dias_traspaso_int,0)
				   ,NVL(def.tasa_fija_o_var,'')     ,NVL(def.cod_tasa_base,'')
				   ,NVL(def.factor_sobretasa,'')    ,NVL(def.sobretasa,'')
				   ,mTasaInteresProd                ,NVL(def.cod_tasa_mora,'')
				   ,NVL(def.sobretasa_mora,0)       ,NVL(def.fact_sobret_mora,'')
				   ,NVL(mTasaMoraProd,0)            ,''
				   ,0                               ,''
				   ,0                               ,dFechaT
				   ,dFechaT							,NVL(tip.es_fisica,'')
				   ,''                              ,''
				   ,NVL(def.tipo_calculo,'')        ,dIvaSuc
				   ,''                              ,NVL(def.dia_para_revisar,0)
				   ,''                              ,cPeriodoPag
				   ,''                              ,''
				   ,''                              ,0
				   ,0                               ,0
				   ,''                              ,''
			FROM bdisolic:"informix".ss_solicitudes sol
				INNER JOIN bdicred:"informix".sd_definicion def ON def.empresa = sol.empresa AND def.num_producto = sol.num_producto
				INNER JOIN bdisolic:"informix".ss_anexosol anx ON anx.num_solicitud = sol.num_solicitud AND anx.empresa = sol.empresa
				INNER JOIN bdinteg:"informix".si_cliente cli ON cli.empresa = sol.empresa AND cli.numcte = sol.numcte
				INNER JOIN bdinteg:"informix".si_tipper tip ON tip.tpo_persona = cli.tpo_persona
				WHERE  sol.num_solicitud = pSolicitud AND sol.empresa = pEmpresa;

			LET iNumReg = dbinfo("sqlca.sqlerrd2");

			IF iNumReg = 0 THEN
				LET cCodRet = "000003";
				DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
			    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
				DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_ctascarg WHERE num_credito = pSolicitud;
                DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
				RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			END IF;

		     --***** SE INSERTA INFORMACION EN SD_MAECREDANEXOCRD (DATOS PARA TARJETA DE CREDITO)
		    BEGIN
			    ON EXCEPTION SET iSqlErr, iIsamError, cErrorInfo
			         LET cCodRet    = iSqlErr;

			         LET cErrorInfo  = cErrorInfo;
			         RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			    END EXCEPTION;


				INSERT INTO bdicred:"informix".sd_maecredanexocrd
					(empresa, 				 		num_credito,
					 localidad,              		dia_corte,
			         dias_gracia_mora, 		 		tp_dias_calc_mora,
			         dias_fecha_max_pago,	 		tp_dias_fecha_pago,
			         cod_tasa_base_cte, 	 		factor_sobretasa_cte,
			         sobretasa_cte, 		 		tasa_interes_cte,
			         fecha_vencto, 			 		prox_fecha_pago,
			         fecha_proceso,			 		fecha_ult_pago,
			         nombre_pres)
				SELECT pEmpresa              		,pSolicitud,
		               ""                    		,DAY(dFechaApert),
					   NVL(def.gracia_calc_mora,0)  ,'',
					   DAY(dFechaApert)      		,NVL(def.maneja_linea,''),
					   NVL(def.cod_tasa_base,'')	,NVL(def.factor_sobretasa,''),
					   NVL(def.sobretasa,0)    		,mTasaInteresProd,
					   ""                    		,dFechaT,
					   dFechaApert           		,"",
					   pNombrePres
				FROM bdicred:"informix".sd_definicion def
		            INNER JOIN bdisolic:"informix".ss_solicitudes c ON c.empresa = def.empresa AND c.num_producto = def.num_producto
		     --       INNER JOIN bdicred:"informix".sd_anexodefinicion b ON b.empresa = def.empresa AND b.num_producto = c.num_producto
			--			AND b.cod_prod = def.cod_tipcred
				WHERE c.empresa = pEmpresa AND c.num_solicitud = pSolicitud;
		    END;
		      --***** SE INSERTA INFORMACION EN SD_MAESDOSCRD

			LET iNumReg = dbinfo("sqlca.sqlerrd2");

			IF iNumReg = 0 THEN
				LET cCodRet = "000003";
				DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
			    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
				DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_ctascarg WHERE num_credito = pSolicitud;
                DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
				RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			END IF;


		    BEGIN
			    ON EXCEPTION SET iSqlErr, iIsamError, cErrorInfo
			         LET cCodRet    = iSqlErr;
			         LET cErrorInfo  = cErrorInfo;
			         RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			    END EXCEPTION;

		        INSERT INTO bdicred:"informix".sd_maesdoscrd
						(
							empresa, 			num_credito,
							fecha_ult_mov, 		sdo_int_anticip,
							sdo_int_ant_dev, 	sdo_intereses,
							sdo_dia_ant_int, 	sdo_mes_ant_int,
							sdo_acum_mes_int, 	sdo_retenido,
							sdo_acum_cap_int, 	sdo_exig_int,
							sdo_no_exig, 		provision_normal,
							dias_acum_int, 		sdo_moratorio,
							sdo_dia_ant_mor, 	sdo_mes_ant_mor,
							sdo_contab_mora, 	dias_acum_mora,
							sdo_capital, 		sdo_cap_insoluto,
							sdo_dia_ant_cap, 	sdo_mes_ant_cap,
							sdo_acum_mes_cap, 	mto_capitalizado,
							mto_ministra_cap, 	cargos_dia_cap,
							abonos_dia_cap, 	cargos_mes_cap,
							abonos_mes_cap, 	dias_acum_cap,
							monto_vencido, 		mto_venc_trasp,
							monto_financiado, 	monto_reservado,
							sdo_acum_vencido, 	dias_acum_intper,
							sdo_global_int, 	sdo_acum_intper,
							monto_otorgado, 	provi_venc_normal,
							provi_venc_anticip, cap_tras_no_venci,
							mto_venc_int, 		mto_venc_tra_int,
							mto_finan_vdo, 		mto_reser_int,
							mto_fin_ven_trasp, 	mto_fin_vig_trasp,
							int_tra_no_exig, 	sdo_trab4,
							atr
		                )
		        SELECT 		 sol.empresa             ,pSolicitud
							,dFechaApert            ,0
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,pMonto                 ,pMonto
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,pMonto					,0
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,0                      ,0
							,iAtr_Act_ifrs
				FROM   bdisolic:"informix".ss_solicitudes sol
				WHERE  sol.num_solicitud = pSolicitud AND sol.empresa = pEmpresa;
			END;

			IF iNumReg = 0 THEN
				LET cCodRet = "000003";
				DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
			    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
				DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_ctascarg WHERE num_credito = pSolicitud;
                DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
				RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			END IF;

			-- SE GENERA EL FOLIO
			CALL bdicheq:"informix".sp_generafolionomina(pEjecutivo) RETURNING cCodRet, cNumeroFolio;

			-- SE ASIGNA EL FOLIO DE LA TRANSACCION
			LET cTransacc = "0247";

		    EXECUTE PROCEDURE "informix".genmovcrd(pEmpresa         , pSolicitud,
										cProducto        , 3,
		                                "001"            , dFechaApert,
		                                pMonto           , cNumeroFolio,
		                                cSucursal        , cDivisa,
		                                "0000",'APERTURA','')
			INTO cCodRet, cErrorInfo;

			IF cCodRet <> "000000" THEN
				DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
			    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
				DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_ctascarg WHERE num_credito = pSolicitud;
                DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
				RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			END IF

		    EXECUTE PROCEDURE "informix".genmovcrd(pEmpresa         , pSolicitud,
										cProducto        , 66,
		                                "002"            , dFechaApert,
		                                pMonto           , cNumeroFolio,
		                                cSucursal        , cDivisa,
		                                "0000",'DISPOSICION','')
			INTO cCodRet, cErrorInfo;

			IF cCodRet <> "000000" THEN
				DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
			    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
				DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_ctascarg WHERE num_credito = pSolicitud;
                DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
				RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			END IF


			-- SE INSERTA INSERTA INFORMACION EN LA TABLA DE AMORTIZACIONES
			INSERT INTO bdicred:"informix".sd_amortiza_creditocrd
				(
					empresa, 			num_credito,
					fecha_cuota, 		tipo_cuota,
					capital_mto_cuota, 	capital_debe,
					capital_pagado, 	capital_status,
					capital_status_ant, capital_fecha_pago,
					interes_debe, 		interes_pagado,
					interes_status, 	interes_status_ant,
					interes_fecha_pago, iva_debe,
					iva_pagado, 		iva_status,
					iva_status_ant, 	iva_fecha_pago,
					mora_provi_ordi, 	mora_provi_cope,
					mora_sdo_ordi, 		mora_sdo_ordi_pag,
					mora_sdo_cope, 		mora_sdo_cope_pag,
					mora_bonificado, 	mora_status,
					mora_iva_debe, 		mora_iva_pagado,
					mora_iva_status, 	mora_iva_fecha_pago,
					num_pago, 			campo_trabajo1,
					campo_trabajo2, 	campo_trabajo3,
					campo_trabajo4
				)
			VALUES
				(
					pEmpresa,			pSolicitud,
					dFechaT,			"3",
					pMensualidad,		0,
					0,					"3",
					"3",				"",
					0,					0,
					"1",				"1",
					"",					0,
					0,					"1",
					"1",				"",
					0,					0,
					0,					0,
					0,					0,
					0,					"1",
					0,					0,
					"1",				"",
					1,					0,
					0,					"",
					""
				);

			--SE INSERTA EN LA TABLA bdicred:"informix".sd_ctascarg
			INSERT INTO bdicred:"informix".sd_ctascarg (empresa, numero, con_cap_inte, naturaleza, num_credito, tipo_cta, num_cta, num_nomina)
			VALUES(pEmpresa,0,'','A',pSolicitud,'',pCuentaCap,'');

		    -- SE ACTUALIZA EL ESTATUS DE LA SOLICITUD
		    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AP"
		    WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;

            --FMV 23abr13: Inserta cascaron para indicadores de prestamo a plazo
            INSERT INTO bdicred:sd_indicador_cred_crd
                        (empresa, num_credito, fecha_alta)
                VALUES (pEmpresa, pSolicitud, dFechaApert);



		    SELECT nombre INTO cMensaje FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = pEjecutivo AND empresa = pEmpresa;

		    LET cMensaje = "Apertura de Credito Autorizada por: " || TRIM(cMensaje);

			-- SE INSERTA EN LA TABLA DE AUTORIZACIONES DE SOLICITUD
		    INSERT INTO bdisolic:"informix".ss_autorizacion
				(empresa, ejecutivo_auto, num_solicitud, status_solicitud, comentario, fecha_entrada, fecha_salida, user_insert, fecha_insert)
		     VALUES(pEmpresa, pEjecutivo, pSolicitud, "AP", cMensaje, dFechaApert, dFechaApert, USER, TODAY);

			-- SE GENERA EL ABONO
			CALL bdicheq:"informix".abono_ref (pEmpresa, cSucursal, pEjecutivo, cTransacc, cTransacc, cNumeroFolio, pCuentaCap, 0,
				pMonto, pMonto, 0, 0, 0, "01", pNombrePres, '0', pEjecutivo) RETURNING cCodRet;

			-- SI NO SE PUDO GENERAR EL ABONO SE REVERSAN TODOS LOS MOVIMIENTOS QUE SE HABIAN ECHO
			IF cCodRet <> "000" THEN
				DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
			    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
				DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_ctascarg WHERE num_credito = pSolicitud;
                DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
				RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
		    ELSE
		        LET idAbono = "S";
			END IF;

			 -- SE ACTUALIZAN LOS DATOS DEL CLIENTE
			SELECT a.numcte, tipo_cliente, NVL(ingreso_mensual,0)
			INTO cNumCte, cTpCte, mIngreso
			FROM bdinteg:"informix".si_cliente a
				INNER JOIN bdisolic:"informix".ss_solicitudes b ON b.numcte = a.numcte
				INNER JOIN bdisolic:"informix".ss_resum_scor_fin c ON c.empresa = b.empresa AND c.num_solicitud = b.num_solicitud
			WHERE b.empresa = pEmpresa AND b.num_solicitud = pSolicitud;
			 -- Saca la Publicacion de si_ctepf Jose Luis Puebla
		    SELECT string1 INTO cMercadeo
		    FROM   bdinteg:"informix".si_ctepf
		    WHERE  numcte = cNumCte;

		    IF cTpCte = "1" THEN
				SELECT MAX(sec_ingreso) INTO sSecIngreso FROM bdinteg:"informix".si_ingresos WHERE empresa = pEmpresa AND numcte = cNumCte AND tipo_ingreso = 'T';

				UPDATE bdinteg:"informix".si_ingresos SET ingreso_mensual = mIngreso
				WHERE empresa = pEmpresa AND numcte = cNumCte AND tipo_ingreso = "T" AND sec_ingreso = sSecIngreso;
		    ELSE

				UPDATE bdinteg:"informix".si_cliente SET tipo_cliente = "1" WHERE numcte = cNumCte;

				SELECT NVL(MAX(sec_ingreso), 0) + 1 INTO sSecIngreso
				FROM bdinteg:"informix".si_ingresos
				WHERE empresa = pEmpresa AND numcte = cNumCte AND tipo_ingreso = "T";

				INSERT INTO bdinteg:"informix".si_ingresos (empresa, numcte, sec_ingreso, tipo_ingreso, ingreso_mensual)
				VALUES (pEmpresa, cNumCte, sSecIngreso, "T", mIngreso);
		    END IF

	END IF;

    -- Resta el Valor de la Tasa Moratoria con la de Intereses
    -- Solicitado por el Banco JLP 23May2008
    LET mTasaMora = mTasaMora - mTasaInteres;
    IF mTasaMora < 0 THEN --Si es Menor a Cero la vuelve Positivo
       LET mTasaMora = mTasaMora * -1;
    END IF
    RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
END;
END PROCEDURE;
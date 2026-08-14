CREATE PROCEDURE "informix".sp_pf_consulta_tasa_plazo_preferenciales(pBandera SMALLINT, pEmpresa CHAR(3), pCanal SMALLINT, pCredito CHAR(20), pProducto CHAR(4), pPromocion SMALLINT, pMonto DECIMAL(18, 2), pPlazo SMALLINT, pFecha DATE)
RETURNING
	CHAR(5)				AS CodRet, 
	DECIMAL(18,2)		AS oTasa, 
	INTEGER				AS oPlazo;
	
	--DECLARACION DE VARIABLES.
	DEFINE iSqlErr		INTEGER;	
	DEFINE cCodRet		CHAR(5);
	DEFINE oTasa		DECIMAL(18, 2);
	DEFINE oPlazo		INTEGER;
	DEFINE iTasa_aux	DECIMAL(10,2); 
	
	--INICIALIZACION DE VARIABLES.
	LET iSqlErr			= 0;	
	LET cCodRet			= '00000';	
	LET oTasa			= 0.00;	
	LET oPlazo			= 0; 
	LET iTasa_aux		= 0.0;

	BEGIN
				
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= '00005';	
				RETURN TRIM(cCodRet), NVL(oTasa,0.00), NVL(oPlazo,0);
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/home/e99806751/sp_pf_consulta_tasa_plazo_preferenciales.out";
		--TRACE ON;	
		
		SET LOCK MODE TO WAIT 3;		
		SET ISOLATION TO DIRTY READ;		
		
		--SE VALIDAN LOS PARAMETROS DE ENTRADA.
		IF (pBandera < 0 OR pBandera > 3) OR pBandera IS NULL OR NVL(pEmpresa, '') = '' OR pCanal IS NULL OR NVL(pCredito, '') = '' OR NVL(pProducto, '') = '' OR pPromocion <= 0 OR pMonto < 0 OR pPlazo < 0 OR pPlazo IS NULL  THEN
			LET cCodRet = '00001';
			RETURN TRIM(cCodRet), NVL(oTasa,0.00), NVL(oPlazo,0);
		END IF;
		
		IF pBandera = 0 THEN
		
			FOREACH
			
				SELECT {+INDEX ("informix".sd_promocion idx_promocion ),
						+INDEX ("informix".sd_tasa_plazo_app idx_sd_tasa_plazo_app)}
						plazo, tasa
				INTO oPlazo, oTasa
				FROM 'informix'.sd_promocion a  
				INNER JOIN bdicred:"informix".sd_tasa_plazo_app  b 
				   ON a.num_promo = b.num_promo
				WHERE a.num_promo = pPromocion 
				AND b.plazo = b.plazo
				AND b.num_producto = pProducto
				AND a.activo = 1 
				AND pMonto BETWEEN monto_ini AND monto_fin
				AND pFecha >= fechaini_promo 
				AND pFecha <= fechafin_promo
				AND b.plazo > 1
				ORDER BY plazo ASC

				-- BUSCAMOS EN LA sd_prospectos si la tasa es mayor a 0
				SELECT nvl(tasa,0)
				INTO iTasa_aux
				FROM "informix".sd_prospectos
				WHERE empresa = pEmpresa
				AND num_credito = pCredito
				AND num_producto = '6900'
				AND num_promo = pPromocion;

				IF iTasa_aux > 0 THEN 
					LET oTasa = iTasa_aux;
				END IF;
				
				IF (oTasa > 0 and oPlazo > 1) THEN
				    RETURN TRIM(cCodRet), NVL(oTasa,0.00), NVL(oPlazo,0) WITH RESUME;
				END IF;
					
			END FOREACH;
		ELSE
			
			IF pBandera = 1 THEN

				SELECT {+INDEX ("informix".sd_promocion idx_promocion ),
						+INDEX ("informix".sd_tasa_plazo_app idx_sd_tasa_plazo_app)}
						plazo, tasa
				INTO oPlazo, oTasa
				FROM 'informix'.sd_promocion a  
				INNER JOIN bdicred:"informix".sd_tasa_plazo_app  b 
				   ON a.num_promo = b.num_promo
				WHERE a.num_promo = pPromocion 
				AND b.plazo = pPlazo
				AND b.num_producto = pProducto
				AND a.activo = 1 
				AND pMonto BETWEEN monto_ini AND monto_fin
				AND pFecha >= fechaini_promo 
				AND pFecha <= fechafin_promo
				AND b.plazo > 1;
				
				-- BUSCAMOS EN LA sd_prospectos si la tasa es mayor a 0
				SELECT nvl(tasa,0) 
				INTO iTasa_aux 
				FROM "informix".sd_prospectos
				WHERE empresa = pEmpresa
				AND num_credito = pCredito
				AND num_producto = '6900'
				AND num_promo = pPromocion;

				IF iTasa_aux > 0 AND NVL(oPlazo, 0) > 1 THEN 
					LET oTasa = iTasa_aux;
					LET oPlazo = pPlazo;
				END IF;
							
				IF oTasa <= 0 OR oTasa IS NULL OR oPlazo <= 0 OR oPlazo IS NULL THEN
					LET cCodRet = '00005';
					LET oTasa = 0;
					LET oPlazo = 0;
					RETURN TRIM(cCodRet), NVL(oTasa,0.00), NVL(oPlazo,0);
				END IF;
				
				RETURN TRIM(cCodRet), NVL(oTasa,0.00), NVL(oPlazo,0);
			
			ELSE
				
				IF pBandera IN (2, 3) THEN
				
					-- BUSCAMOS EN LA sd_prospectos si la tasa es mayor a 0
                    SELECT nvl(tasa,0) 
                    INTO iTasa_aux 
                    FROM "informix".sd_prospectos
                    WHERE empresa = pEmpresa
                    AND num_credito = pCredito
                    AND num_producto = '6900'
                    AND num_promo = pPromocion;

					IF iTasa_aux > 0 THEN 
						
						IF pBandera = 2 THEN
							SELECT MIN(plazo) INTO pPlazo FROM bdicred:"informix".sd_tasa_plazo_app WHERE num_promo = pPromocion AND num_producto = pProducto AND plazo > 1 AND pMonto BETWEEN monto_ini AND monto_fin;
						END IF;
						
						IF pBandera = 3 THEN
							 SELECT MIN(plazo) INTO pPlazo FROM bdicred:"informix".sd_tasa_plazo_app WHERE num_promo = pPromocion AND num_producto = pProducto AND plazo > 1;
						END IF;
						
						LET oTasa = iTasa_aux;
						LET oPlazo = pPlazo; 
					ELSE
						
						IF pBandera = 2 THEN
							 SELECT MIN(plazo) INTO pPlazo FROM bdicred:"informix".sd_tasa_plazo_app WHERE num_promo = pPromocion AND num_producto = pProducto AND plazo > 1 AND tasa > 0 AND pMonto BETWEEN monto_ini AND monto_fin;
							
							  SELECT {+INDEX ("informix".sd_promocion idx_promocion ),
                                    +INDEX ("informix".sd_tasa_plazo_app idx_sd_tasa_plazo_app)}
                                    plazo, tasa
                            INTO oPlazo, oTasa
                            FROM 'informix'.sd_promocion a  
                            INNER JOIN bdicred:"informix".sd_tasa_plazo_app  b 
                               ON a.num_promo = b.num_promo
                            WHERE a.num_promo = pPromocion 
                            AND b.plazo = pPlazo
                            AND b.num_producto = pProducto
                            AND a.activo = 1 
                            AND pMonto BETWEEN monto_ini AND monto_fin
                            AND pFecha >= fechaini_promo 
                            AND pFecha <= fechafin_promo
                            AND b.tasa > 0
                            AND b.plazo > 1;
							
						END IF;
						
						IF pBandera = 3 THEN 
							 SELECT MIN(plazo) INTO pPlazo FROM bdicred:"informix".sd_tasa_plazo_app WHERE num_promo = pPromocion AND num_producto = pProducto AND plazo > 1 AND tasa > 0;
							 
							   SELECT {+INDEX ("informix".sd_promocion idx_promocion ),
                                    +INDEX ("informix".sd_tasa_plazo_app idx_sd_tasa_plazo_app)}
                                    plazo, tasa
                            INTO oPlazo, oTasa
                            FROM 'informix'.sd_promocion a  
                            INNER JOIN bdicred:"informix".sd_tasa_plazo_app  b 
                               ON a.num_promo = b.num_promo
                            WHERE a.num_promo = pPromocion 
                            AND b.plazo = pPlazo
                            AND b.num_producto = pProducto
                            AND a.activo = 1 
                            AND pFecha >= fechaini_promo 
                            AND pFecha <= fechafin_promo
                            AND b.plazo > 1;
							
						END IF;
						
					END IF;

					IF oTasa <= 0 OR oTasa IS NULL OR oPlazo <= 0 OR oPlazo IS NULL THEN
						LET cCodRet = '00005';
						LET oTasa = 0;
						LET oPlazo = 0;
						RETURN TRIM(cCodRet), NVL(oTasa,0.00), NVL(oPlazo,0);
					END IF;
				
					RETURN TRIM(cCodRet), NVL(oTasa,0.00), NVL(oPlazo,0);
				
				END IF;
				
			END IF;
			
		END IF;
		
	END
END PROCEDURE
DOCUMENT
'FECHA:02-09-2025',
'DESCRIPCION: Consulta la taza y plazo preferencial de pagos fijos.',
'AUTOR: Alexi Sitlali Hernandez Sauceda',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_proyecta_prest_credisol(pMonto_Autorizado  DECIMAL(18,6),  -- MONTO DEL CREDITO
                                                   pPlazo 			 INTEGER, 	     --PLAZO EN MESES PARA PAGAR
                                                   pCapacidad_Pres	 DECIMAL(18,6),  -- CAPACIDAD DE PAGO DEL CLIENTE
                                                   pProducto 		 CHAR(4), 	     -- CODIGO DE PRODUCTO
                                                   pSucursal 		 CHAR(4),	     -- CODIGO DE SUCURSAL
                                                   pTipoRetorno 	 SMALLINT,	     -- DETERMINA COMO SE VAN A RETORNAR LOS DATOS:
                                                                                                --	0  RESUMEN
                                                                                                --	1   DETALLE
                                                                                                --	2  REIMPRESION DE CARATULA
                                                                                                --	3  CON DIFERENTE FECHA DE INICIO DE PROYECCION
                                                                                                --	4  RESUMEN CON DIFERENTE FECHA DE INICIO DE PROYECCION
                                                   pSolicitudes 	 SMALLINT,	     -- PARA PAGINACION
                                                   pNumCred			 CHAR(20),	     -- NUMERO DE CREDITO
                                                   pFecha			 DATE,		     -- FECHA PARA INICIAR LA PROYECCION
												   pFrecuencia       INTEGER,         --Frecuencia de pago   
																						--0.- Mensual(prestamo)
																						--1.- Mensual credinomina
																						--2.- Quincenal credinomina
                                                   pnum_promo        INTEGER,
						pPagFig_sms		 CHAR(1) DEFAULT '0',
						pTasaPfSms		 DECIMAL(18,6) DEFAULT 0
                                                   )

RETURNING   CHAR(6)         AS Codigo, 		  -- CODIGO DE RETORNO
            INTEGER         AS Periodo,       -- PERIODO ACTUAL
            DATE            AS FechaCouta,	  -- FECHA DEL PAGO
            DECIMAL(18,2)   AS SaldoInicial,  -- SALDO INICIAL
            DECIMAL(18,2)   AS Mensualidad,	  -- MENSUALIDAD
            DECIMAL(18,2)   AS Intereses,	  -- INTERESES
            DECIMAL(18,2)   AS IvaInteres,	  -- IVA DE INTERESES
            DECIMAL(18,2)   AS Capital,		  -- CAPITAL
            DECIMAL(18,2)   AS SaldoFinal,	  -- SALDO FINAL
            SMALLINT        AS DiasPeriodo,	  -- DIAS DEL PERIODO
            DATE            AS FechaAper,	  -- FECHA DE APERTURA
			CHAR(3)         AS NumMesesPago;	  -- FECHA DE APERTURA

--  CONTROL DE CAMBIOS
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Martha A Hernandez Rodriguez
--Descripcion: Se clona el sp: sp_proyecta_prestamos que realiza la proyecció? ¤e Prestamo Personal, para 
--             adecuarlo al producto de Credisoluciones, el cual tiene tasa dependiendo de la 
--             campañH i el plazo.
--Fecha: 2015/06
--Version: 
---------------------------------------------------------------------------------------------------------------

-- VARIABLES DE CONTROL DE ERRORES
DEFINE isqlerr      	INTEGER;			-- CODIGO DE ERROR
-- VARIABLES PARA RETORNO DE DATOS
DEFINE cCodRet     		CHAR(6); 			-- CODIGO DE RETORNO DE ERROR
DEFINE mPeriodo			INTEGER;			-- PERIODO DE PAGO
DEFINE dFechaCouta		DATE;				-- FECHA
DEFINE mSdoInicial		DECIMAL(18,6);		-- SALDO INICIAL
DEFINE mMensualidad		DECIMAL(18,6);		-- MENSUALIDAD
DEFINE mIntereses		DECIMAL(18,6);		-- INTERESES
DEFINE mIvaInt			DECIMAL(18,6);		-- IVA DE INTERESES
DEFINE mCapital			DECIMAL(18,6);		-- CAPITAL
DEFINE mSdoFinal		DECIMAL(18,6);		-- SALDO FINAL
DEFINE sDiasPeriodo		SMALLINT;			-- DIAS DEL PERIODO
DEFINE mMontoMin		DECIMAL(18,6);		-- MONTO MINIMO
DEFINE mMontoMax		DECIMAL(18,6);		-- MONTO MAXIMO
DEFINE sPlazoMin		SMALLINT;			-- PLAZO MINIMO
DEFINE sPlazoMax		SMALLINT;			-- PLAZO MAXIMO
DEFINE dFechaAper		DATE;				-- FECHA DE APERTURA

-- VARIABLES AUXILIARES
DEFINE Contador 		INTEGER; 			-- PARA CONTROLAR LAS INTERACIONES DEL CICLO
DEFINE mTasaInt 		DECIMAL(18,6);		-- TASA DE INTERES
DEFINE mIVA				DECIMAL(18,6);    	-- IVA
DEFINE mTasa			DECIMAL(18,6);		-- TASA ANUAL
DEFINE dFechaActual		DATE;				-- FECHA DEL CAMPO  fecha_hoy DE LA TABLA sd_fechas
DEFINE sPlazo			SMALLINT;			-- PLAZO
DEFINE mTasaMensual		DECIMAL(18,6);      -- TASA MENSUAL
DEFINE mTasaIVA			DECIMAL(18,6);		-- TASA ANUAL CON IVA
DEFINE mTasaMensualIVA	DECIMAL(18,6);		-- TASA MENSUAL CON IVA
DEFINE dFechaInicial	DATE;				-- FECHA QUE SE TOMA COMO INICIO PARA CALCULAR LAS DEMAS FECHAS
DEFINE dtDiaprimero 	DATE;				-- FECHA QUE SE TOMA COMO INICIO PARA CALCULAR LAS DEMAS FECHAS
DEFINE dFechaAnt		DATE;				-- FECHA ANTERIOR DE COUTA
DEFINE dFechaFinMes		DATE;				-- FECHA ANTERIOR DE COUTA

-- VARIABLES PARA CAPTURAR LOS VALORES DE PLAZO, PAGO MENSUAL Y MONTO APROBADO
DEFINE mMontoAut 		DECIMAL(18,6); 		-- MONTO DEL CREDITO
DEFINE mPlazo  	 		DECIMAL(18,6);		--PLAZO EN MESES PARA PAGAR
DEFINE mCapacidadPres	DECIMAL(18,6); 		-- CAPACIDAD DE PAGO DEL CLIENTE

DEFINE cEmpresa         CHAR(3);
DEFINE dLimites         DECIMAL(18,6);
DEFINE dDiferencia      DECIMAL(18,6);
DEFINE mMensualidadAux  DECIMAL(18,6);
DEFINE mMontoAutAux		DECIMAL(18,6);

DEFINE iTpoPago         INTEGER;
DEFINE cTipo            CHAR(15);
DEFINE iDiaPago      	INTEGER;
DEFINE mPlazoAux      	DECIMAL(18,6);
DEFINE sContinua      	INTEGER;
DEFINE v_bandesp        SMALLINT;
DEFINE sCountExists		SMALLINT;

LET iSqlErr 		= 0;
LET cCodRet 		= "000000";
LET dFechaCouta		= DATE(1);
LET mPeriodo		= 0;
LET mSdoInicial		= 0;
LET mMensualidad	= 0;
LET mIntereses		= 0;
LET mIvaInt			= 0;
LET mCapital		= 0;
LET mSdoFinal		= 0;
LET sDiasPeriodo	= 0;
LET dFechaAper		= DATE(1);

LET Contador 		= 0;
LET mTasaInt    	= 0;
LET mIVA			= 0;
LET mTasa			= 0;
LET dFechaActual	= DATE(1);
LET mTasaMensual	= 0;
LET mTasaIVA 		= 0;
LET dFechaInicial	= DATE(1);
LET dtDiaprimero   = DATE(1);
LET dFechaAnt		= DATE(1);
LET dFechaFinMes	= DATE(1);

LET mMontoAut 		= pMonto_Autorizado;
LET mPlazo  	 	= pPlazo;
LET mCapacidadPres	= pCapacidad_Pres;
LET mMontoMin		= 0;
LET mMontoMax		= 0;
LET sPlazoMin    	= 0;
LET sPlazoMax		= 0;

LET cEmpresa        = '001';
LET dLimites        = 0.05;
LET dDiferencia     = 0.20;
LET mMensualidadAux = 0;
LET mMontoAutAux		= 0;

LET iTpoPago       = 0;
LET cTipo             = ''; 
LET iDiaPago       = 0; 
LET mPlazoAux       = 0; 
LET sContinua       = 0; 
LET v_bandesp       = 0;
LET sCountExists	= 0;
  
BEGIN

	ON EXCEPTION  SET iSqlErr
		IF iSqlErr <> 0  THEN
			LET  cCodRet  = iSqlErr;
			RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
		END IF;
	END  EXCEPTION

    --SET DEBUG FILE TO "/home/e99806218/TRACES/sp_proyecta_prest_credisol_new.out";
    --TRACE ON;

 -- ***********************************************************************
 -- ******************** ERRORES CONTROLADOS **************************
 -- ***********************************************************************
	-- 000001 	VALORES DE ENTRADA INCORRECTOS
	-- 000002	SOLO SE PERMITE RECIBIR 2 DE LOS 3 PARAMETROS SIGUIENTES pMonto_Autorizado, pPlazo, pCapacidad_Pres
	-- 000003	LA CANTIDAD DEL PAGO MENSUAL NO ES SUFICIENTE PARA PAGAR LOS INTERESES
	-- 000004	EL MONTO DEL PRESTAMO SE ENCUENTRA FUERA DEL RANGO PERMITIDO
	-- 000005	EL PLAZO DEL PRESTAMO SE ENCUENTRA FUERA DEL RANGO PERMITIDO
	-- 000006	EL NUMERO DE CREDITO NO EXISTE
	-- 000007	FALTA LA NUEVA FECHA DE INICIO DE LA PROYECCION
	-- 000008	EL PARAMETRO DE FECHA NO ES NECESARIO
	-- 000009	EL CALCULO DEL MONTO NO SE PUEDE REALIZAR CON LOS PARAMETROS ACTUALES
	-- 000010	EL CALCULO DE LA CAPACIDAD NO SE PUEDE REALIZAR CON LOS PARAMETROS ACTUALES
	-- 000011	EL CALCULO DE EL PLAZO NO SE PUEDE REALIZAR CON LOS PARAMETROS ACTUALES
	-- 000012   NO ES POSIBLE REALIZAR UNA PROYECCIÓ? CON LAS CONDICIONES INDICADAS. (Este có¤I§o de retorno llega desde el sp_obtiene_aproximacion)
	-- 000013   LOS PARAMETROS PARA VALIDAR EL MONTO Y EL PLAZO DEL CREDITO OBTENIDOS SON INCORRECTOS
	-- 000014   EL PARAMETRO DE FRCUENCIA DE PAGO RECIBIDO NO ES VALIDO
	-- 000015 Ocurrio un Error al obtener la fecha de pago del cré¤Ito para credinomina.
 -- ***********************************************************************
 -- ******************** ERRORES CONTROLADOS **************************
 -- *********************************** ************************************

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	--Se valida si la frecuencia recibida es correcta

    if (pFrecuencia is null or pFrecuencia = 0) then
	  SELECT nvl(frecuencia_pgo,0) INTO pFrecuencia 
	  FROM "informix".ss_sol_nomina  
	  WHERE num_solicitud = pNumCred;
    end if;    

	SELECT tipo_pago
	INTO cTipo
	FROM  bdicred:sd_cattipopago 
	WHERE valor = pFrecuencia;

	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '000014';
		RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
	END IF;

	-- SE OBTIENEN LOS PARAMETROS PARA VALIDAR EL MONTO Y EL PLAZO DEL CREDITO
	/*SELECT monto_min_cred, monto_max_cred, plazo_min_cred, plazo_max_cred
	  INTO mMontoMin, mMontoMax, sPlazoMin, sPlazoMax
	  FROM bdicred:"informix".sd_definicion
     WHERE num_producto = pProducto
       AND empresa      = cEmpresa;*/
	
	SELECT TRIM(valor)::DECIMAL(18,2), 999999.99 INTO mMontoMin, mMontoMax FROM "informix".sd_param WHERE cod_param  = '029';
	IF pPagFig_sms = '1' THEN				-- Si es proyeccion para SMS toma plazos minimos y maximos de parametros
		SELECT valor_alfabetico::SMALLINT INTO sPlazoMin FROM bdicred:sd_param_campania WHERE empresa = cEmpresa AND tipo_campania = 2 AND grupo_parametro = 'PAGOSFIJOS' AND num_parametro = 15;
		SELECT valor_alfabetico::SMALLINT INTO sPlazoMax FROM bdicred:sd_param_campania WHERE empresa = cEmpresa AND tipo_campania = 2 AND grupo_parametro = 'PAGOSFIJOS' AND num_parametro = 16;
	
	ELIF pPagFig_sms = '2' THEN	
		SELECT MIN(plazo), MAX(plazo) INTO sPlazoMin, sPlazoMax FROM bdicred:sd_tasa_plazo_app WHERE num_promo = pnum_promo and plazo_activo = 1 and plazo > 1;
	
	ELSE
		SELECT MIN(plazo), MAX(plazo) INTO sPlazoMin, sPlazoMax FROM bdicred:sd_tasa_plazo;
	END IF;	

    IF NVL(mMontoMin,0) = 0 OR NVL(mMontoMax,0) = 0 OR NVL(sPlazoMin,0)= 0 OR NVL(sPlazoMax,0) = 0 THEN
        LET cCodRet = '000013';
        RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
    END IF;

	-- SE VERIFICA QUE LOS VALORES DE ENTRADA SEAN CORRECTOS
    IF pTipoRetorno <> '2' THEN
        IF (NVL(mPlazo,0) = 0 AND NVL(mCapacidadPres,0) = 0 AND NVL(mMontoAut,0) = 0) OR NVL(pProducto,"") = "" OR NVL(pSucursal,"") = "" THEN
            LET  cCodRet  = "000001";
            RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
        ELIF NVL(mPlazo,0) = 0 AND NVL(mCapacidadPres,0) = 0 THEN
            LET  cCodRet  = "000001";
            RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
        ELIF NVL(mPlazo,0) = 0 AND NVL(mMontoAut,0) = 0 THEN
            LET  cCodRet  = "000001";
            RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
        ELIF NVL(mCapacidadPres,0) = 0 AND NVL(mMontoAut,0) = 0 THEN
            LET  cCodRet  = "000001";
            RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
        ELIF (NVL(mPlazo,0) > 0 AND NVL(mCapacidadPres,0) > 0 AND NVL(mMontoAut,0) > 0) THEN
            LET  cCodRet  = "000002";
            RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
        ELIF (NVL(mPlazo,0) > 0 AND NVL(mPlazo,0) < CASE WHEN pFrecuencia = 2 THEN sPlazoMin * 2 ELSE sPlazoMin END) OR (NVL(mPlazo,0) > CASE WHEN pFrecuencia = 2 THEN sPlazoMax * 2 ELSE sPlazoMax END) THEN
            LET cCodRet = "000005";
            RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
        ELIF NVL(mMontoAut,0) >0 AND (NVL(mMontoAut,0) < mMontoMin OR NVL(mMontoAut,0) > mMontoMax) THEN
            LET cCodRet = "000004";
            --FMV 26-SEP-13: Monto minimo = Autorizado para continuar con la proyeccion
            LET mMontoMin = mMontoAut;
            LET cCodRet = "000000";
            --RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
        END IF;
    ELSE
        IF (NVL(mPlazo,0) <> 0 AND NVL(mCapacidadPres,0) <> 0 AND NVL(mMontoAut,0) <> 0)  THEN
             LET  cCodRet  = "000001";
             RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
        END IF;
    END IF;

	IF (pTipoRetorno = 0 AND NVL(pFecha,"") <> "") OR (pTipoRetorno = 1 AND NVL(pFecha,"") <> "") THEN
		LET  cCodRet  = "000008";
		RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
	END IF;

	IF pTipoRetorno = 2 THEN
		SELECT a.fecha_apertura, a.plazo, a.tasa_interes, b.capital_mto_cuota, c.monto_otorgado, a.num_aper_ant AS Iva
			INTO dFechaAper, mPlazo, mTasa, mCapacidadPres, mMontoAut, mIVA
		FROM bdicred:"informix".sd_maecredcrd a
		INNER JOIN bdicred:"informix".sd_amortiza_creditocrd b ON b.empresa = a.empresa AND b.num_credito = a.num_credito AND num_pago = 1
		INNER JOIN bdicred:"informix".sd_maesdoscrd c ON c.empresa = a.empresa AND c.num_credito = a.num_credito
		WHERE a.num_credito = pNumCred;

		IF NVL(dFechaAper,'') = '' THEN
				LET  cCodRet  = "000006";
			 RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
		END IF;
	ELSE
		-- SE OBTIENE EL IVA DE LA SUCURSAL
		SELECT iva
		  INTO mIVA
		  FROM bdinteg:"informix".si_sucursales
		 WHERE sucursal = pSucursal
		   AND empresa = cEmpresa;

		-- SE OBTIENE LA TASA ANUAL DE ACUERDO A LA CAMPAÑ  (PROMOCION) Y PLAZO A CONTRATAR.
		/*SELECT c.valor -- INTO mTasa
		FROM bdicred:"informix".sd_definicion a 
		INNER JOIN bdinteg:"informix".si_fechavalor c ON (c.tasa = a.cod_tasa_base
               AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r WHERE r.tasa = a.cod_tasa_base
                                 AND r.fecha = r.fecha AND r.empresa = a.empresa) AND c.empresa = a.empresa)
		WHERE a.num_producto = pProducto AND a.empresa      = cEmpresa;	*/

		LET sCountExists = 0;
		SELECT count(num_credito) INTO sCountExists FROM "informix".sd_credpaso WHERE num_credito = pNumCred and num_promo = pnum_promo and monto_actual = pMonto_Autorizado and plazo = pplazo and activo = 1;

        --IF EXISTS(SELECT num_credito FROM "informix".sd_credpaso WHERE num_credito=pNumCred and num_promo=pnum_promo and monto_actual=pMonto_Autorizado and plazo=pplazo and activo=1) THEN
		IF sCountExists > 0 THEN	-- Existe registro en credpaso
            SELECT tasa INTO mTasa FROM "informix".sd_credpaso WHERE num_credito=pNumCred and num_promo=pnum_promo and monto_actual=pMonto_Autorizado and plazo=pplazo and activo=1;
            UPDATE "informix".sd_credpaso
			SET activo=0
			WHERE num_credito = pNumCred 
			AND num_promo=pnum_promo
			AND monto_actual=pMonto_Autorizado 
			AND plazo=pplazo;
            LET v_bandesp = 1;
        ELSE
			IF pPagFig_sms = '1' THEN -- Es proyeccion para SMS 
				LET mTasa = pTasaPfSms;

			ELIF pPagFig_sms = '2' THEN -- Es proyeccion para APP
				--SELECT tasa FROM bdicred:sd_tasa_plazo_app WHERE num_promo = pnum_promo AND plazo = pPlazo;
				LET mTasa = pTasaPfSms;
			
			ELSE		-- Es proyeccion normal 
				SELECT tasa INTO mTasa FROM bdicred:sd_tasa_plazo WHERE num_promo = pnum_promo AND plazo = pPlazo;
			END IF;	
        END IF;
	END IF;

	IF mPlazo = 0 AND pPagFig_sms = '0' THEN
		LET mPlazo = case when pFrecuencia = 2 then sPlazoMax * 2 else sPlazoMax end;
	ELSE		
		LET mPlazo = pPlazo;
	END IF;

	IF pProducto = '6400' AND  pFrecuencia = 1  THEN ---Frecuencia Mensual
		LET iTpoPago = 1;
		LET mPlazo = mPlazo * 1;
		LET sDiasPeriodo = 30;
	ELIF pProducto = '6400' AND  pFrecuencia = 2 THEN	---Frecuencia Quincenal
		LET iTpoPago = 2;
--		LET mPlazo = mPlazo * 2;
		LET sDiasPeriodo = 15;
	ELSE ---Frecuencia Mensual
		LET iTpoPago = 0;
		LET mPlazo = mPlazo * 1;
		LET sDiasPeriodo = 30;	
	END IF;	
		
		-- SE OBTIENE LA TASA ANUAL CON IVA
		LET mTasaIVA = (mTasa * (1 + mIVA))/100;  ---  
		LET mTasaInt = mTasa/100;                 ---

		-- SE CALCULA LA TASA DE INTERES MENSUAL
		LET mTasaMensual = mTasaInt/mPlazo;
		LET mTasaMensualIVA = mTasaIVA/mPlazo;
		

	IF mCapacidadPres > 0 AND mMontoAut > 0 THEN
		-- SI ESTA FORMULA REGRESA UN VALOR NEGATIVO SIGNIFICA QUE EL MONTO MENSUAL NO ES SUFICIENTE PARA PAGAR LOS INTERESES QUE SE GENERAN
		IF (((mMontoAut*(mTasaMensualIVA)/mCapacidadPres)-1)/-1) < 0 THEN
			LET cCodRet = "000003";
			RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
		END IF;
	END IF;

	-- SI EL PARAMETRO QUE DEFINE EL RETORNO TIENE EL VALOR DE 2 SE OBTIENE LA FECHA DE APERTURA DEL CREDITO PARA REIMPRESION
	IF pTipoRetorno = 2 THEN
		LET dFechaActual = dFechaAper;
	ELIF pTipoRetorno = 3 OR pTipoRetorno = 4 THEN -- DIFERENTE FECHA PARA INICIO DE PROYECCION
		IF NVL(pFecha,"") = "" THEN
			LET  cCodRet  = "000007";
			RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
		ELSE
			LET dFechaActual = pFecha;
		END IF;
	ELSE
		-- SE OBTIENE LA FECHA
		SELECT fecha_hoy
          INTO dFechaActual
          FROM bdicred:"informix".sd_fechas;

	END IF;

	LET dFechaCouta = dFechaActual;
--JOM	LET mPlazoAux=mPlazo/pFrecuencia;
	LET mPlazoAux=mPlazo;
    IF v_bandesp=1 THEN
        LET pNumCred='';
    END IF;

	IF pTipoRetorno <> 2 THEN
		-- SI TENEMOS EL PLAZO Y EL PAGO MENSUAL PERO NOS FALTA EL MONTO AUTORIZADO
		IF NVL(mPlazo,0) > 0 AND NVL(mCapacidadPres,0) > 0 AND NVL(mMontoAut,0) = 0 THEN
			CALL bdisolic:"informix".sp_obtiene_aproximacion(0,mPlazo,mCapacidadPres,mTasaInt,mTasaIVA,dFechaCouta,mIVA,dLimites,dDiferencia,iTpoPago,pNumCred) RETURNING cCodRet, mMontoAut;
			IF cCodRet <> "000000" THEN
					IF cCodRet < 0  THEN
						LET  cCodRet  = "000009";
						RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
					ELSE
						RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
					END IF;
			END IF;
		-- SI TENEMOS EL PLAZO Y EL MONTO AUTORIZADO PERO NOS FALTA EL PAGO MENSUAL
		ELIF NVL(mPlazo,0) > 0 AND NVL(mMontoAut,0) > 0 AND NVL(mCapacidadPres,0) = 0 THEN
			CALL bdisolic:"informix".sp_obtiene_aproximacion(mMontoAut,mPlazo,0,mTasaInt,mTasaIVA,dFechaCouta,mIVA,dLimites,dDiferencia,iTpoPago,pNumCred) RETURNING cCodRet, mCapacidadPres;
			IF cCodRet <> "000000" THEN
					IF cCodRet < 0  THEN
						LET  cCodRet  = "000010";
						RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
					ELIF cCodRet = "000012" THEN
							LET mPlazoAux =mPlazo;
						WHILE  sContinua = 0	
							LET mPlazoAux = mPlazoAux - pFrecuencia;
							CALL bdisolic:"informix".sp_obtiene_aproximacion(mMontoAut,mPlazoAux,0,mTasaInt,mTasaIVA,dFechaCouta,mIVA,dLimites,dDiferencia,iTpoPago,pNumCred) RETURNING cCodRet, mCapacidadPres;			
							IF cCodRet <> "000000" THEN
								IF cCodRet < 0  THEN
									LET  cCodRet  = "000011";
									RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
								ELIF cCodRet = "000012" THEN
									LET sContinua =0;
								ELSE
									LET  cCodRet  = "000010";
									RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
								END IF;
							ELSE							
								LET sContinua =1;
								LET mPlazo = mPlazoAux;			
--JOM								LET mPlazoAux=mPlazo/pFrecuencia;								
							END IF;
						
						END WHILE;
					ELSE				
						RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
					END IF;
			END IF			
			
		-- SI TENEMOS EL MONTO AUTORIZADO Y EL PAGO MENSUAL PERO DESCONOCEMOS EL PLAZO
		ELIF NVL(mCapacidadPres,0) > 0 AND NVL(mMontoAut,0) > 0 AND NVL(pPlazo,0) = 0 THEN
                       
			CALL bdisolic:"informix".sp_obtiene_aproximacion(mMontoAut,mPlazo,mCapacidadPres,mTasaInt,mTasaIVA,dFechaCouta,mIVA,dLimites,dDiferencia,iTpoPago,pNumCred) RETURNING cCodRet, mPlazo;
			IF cCodRet <> "000000" THEN
					IF cCodRet < 0  THEN
						LET  cCodRet  = "000011";
						RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
					ELSE
						RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
					END IF;
			END IF;
--JOM			LET mPlazoAux=mPlazo/pFrecuencia;	
            LET mPlazoAux=mPlazo;	
		END IF;
	END IF;

	-- SE VALIDA QUE EL MONTO DEL PRESTAMO SE ENCUENTRE DENTRO DEL RANGO PERMITIDO
    IF pTipoRetorno <> 0 THEN  -- Para el resumen no es necesario debido a que se realiza desde el procedimiento de calificació? ¤e la solicitud.
        IF mMontoAut < mMontoMin OR mMontoAut > mMontoMax THEN
            LET  cCodRet  = "000004";
                 --FMV 26-SEP-13: Monto minimo = Autorizado para continuar con la proyeccion
                    LET mMontoMin = mMontoAut;
                    LET cCodRet = "000000";
            --RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
        END IF;
    END IF;

	-- SE VALIDA QUE EL PLAZO DEL PRESTAMO SE ENCUENTRE DENTRO DEL RANGO PERMITIDO
	IF pFrecuencia = 0 THEN
		IF mPlazo < sPlazoMin OR mPlazo > sPlazoMax THEN
			LET  cCodRet  = "000005";
			RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
		END IF;
	ELSE
		IF (mPlazo/pFrecuencia) < sPlazoMin OR (mPlazo/pFrecuencia) > sPlazoMax THEN
			LET  cCodRet  = "000005";
			RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
		END IF;
	END IF;

	LET mSdoInicial = mMontoAut;
	LET mMensualidad = ROUND(mCapacidadPres,0);

	-- SI EL TIPO DE RETORNO ES 0 REGRESAMOS SOLO UN REGISTRO
	IF pTipoRetorno = 0 OR pTipoRetorno = 4 THEN
		LET mPeriodo = mPlazo;
		RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
	ELSE -- SI EL TIPO DE RETORNO ES 1 REGRESAMOS TODO EL DETALLE DEL COMPORTAMIENTO DEL PRESTAMO
		-- EL CICLO TENDRA EL NUMERO DE ITERACIONES IGUAL AL PLAZO DE PAGOS
		LET dFechaInicial = dFechaCouta;			
		LET dFechaAnt = dFechaCouta;			
			
		FOR Contador = 1 TO mPlazo STEP 1

			-- SE OBTIENE EL SALDO INICIAL DEL PERIODO, SI EL SALDO FINAL ES CERO QUIERE DECIR QUE ES EL PRIMER PERIODO Y EL SALDO INICIAL ES IGUAL AL MONTO APROBADO
			IF mSdoFinal > 0 THEN
				LET mSdoInicial = mSdoFinal;
			END IF;

			IF mSdoFinal <= 0 AND Contador > 1 THEN
				EXIT FOR;
			END IF;		
			
			-- SE ASIGNA EL PERIODO
			LET mPeriodo = Contador;

			-- ********************************************************************************************************************
			-- ************************** SE OBTIENE LA SIGUIENTE FECHA DE CUOTA Y LOS DIAS DEL PERIODO **********************
			--*********************************************************************************************************************
 			IF pProducto = '6400' THEN  --Periodo de pago  credinomina		
					--se obtiene la fecha de la proxima cuota.
						EXECUTE PROCEDURE bdisolic:"informix".sp_obtienefechapago('001',dFechaCouta,pNumCred)
							INTO cCodRet,dFechaCouta,iDiaPago;	
							
							IF cCodRet::INTEGER <> 0  THEN	
								LET cCodRet    = "000015";	--Ocurrio un Error al obtener la fecha de pago del cré¤Ito para credinomina.
								RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
							END IF;		
							
					   IF (MONTH(dFechaCouta) = 1 AND DAY(dFechaCouta) = 1) OR (MONTH(dFechaCouta) = 12 AND DAY(dFechaCouta) = 25) THEN
							LET dFechaCouta = dFechaCouta + 1;
						END IF;						
						IF (MONTH(dFechaAnt) = 1 AND DAY(dFechaAnt) = 1) OR (MONTH(dFechaAnt) = 12 AND DAY(dFechaAnt) = 25) THEN
							LET dFechaAnt = dFechaAnt + 1;
						END IF;
						LET sDiasPeriodo = dFechaCouta - dFechaAnt;	--se obtienen los dias del periodo
						LET dFechaAnt = dFechaCouta;	
			ELSE   ---Periodo de pago Mensual prestamo 
			
				CALL bdicred:"informix".monthadd(dFechaInicial,Contador) RETURNING dFechaCouta;
				CALL bdicred:"informix".monthadd(dFechaInicial,Contador-1) RETURNING dFechaAnt;

				IF (MONTH(dFechaCouta) = 1 AND DAY(dFechaCouta) = 1) OR (MONTH(dFechaCouta) = 12 AND DAY(dFechaCouta) = 25) THEN
					LET dFechaCouta = dFechaCouta + 1;
				END IF;

				IF (MONTH(dFechaAnt) = 1 AND DAY(dFechaAnt) = 1) OR (MONTH(dFechaAnt) = 12 AND DAY(dFechaAnt) = 25) THEN
					LET dFechaAnt = dFechaAnt + 1;
				END IF;

				LET sDiasPeriodo = dFechaCouta - dFechaAnt;
			END IF;	

			-- ********************************************************************************************************************
			-- ************************** SE OBTIENE LA SIGUIENTE FECHA DE CUOTA Y LOS DIAS DEL PERIODO **********************
			--*********************************************************************************************************************

			-- SE OBTIENE LA FECHA POR PLAZO
			--LET dFechaCouta = bdicred:monthadd(dFechaCouta,Contador);

			--SE CALCULAN LOS INTERESES
			LET mIntereses = mSdoInicial * (mTasaInt/360) * sDiasPeriodo;

			-- SE CALCULA EL IVA DE LOS INTERESES
			LET mIvaInt = ROUND(mIntereses * mIVA,2);
			--LET mMontoAutAux = mMontoAut + mIntereses + mIvaInt;
			
			IF mMontoAut < mMensualidad THEN
				LET mMensualidad = mMontoAut + mIntereses + mIvaInt;
				LET mCapital = mMontoAut;
			ELSE											
					LET mCapital = mMensualidad - (mIntereses + mIvaInt);
					LET mIntereses = mIntereses ;
					LET mIvaInt  = mIvaInt ;
					LET sDiasPeriodo= sDiasPeriodo;
			END IF;
			
			IF NVL(mCapital,0) < 0 AND Contador = 1  THEN
				LET cCodRet = '000012';
				RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
			END IF;
			
			-- SE CALCULA EL SALDO FINAL
			LET mSdoFinal = mSdoInicial - mCapital;
			LET mMontoAut = mSdoInicial - mCapital;
			
			-- SE UTILIZA PARA PODER PAGINAR
	        IF Contador <= pSolicitudes THEN
	            CONTINUE FOR;
	        END IF;	
		
		RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux WITH RESUME;
		END FOR;
	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR: Jose Luis Pulido Zepeda',
'Descripcion: Simula el comportamiento de un prestamo durante el plazo seleccionado',
'Fecha: 2009/09/09',
'Version: 20090909.1750';

CREATE PROCEDURE "informix".sp_carga_datos_camp() 
RETURNING CHAR(6);
--RETURNING CHAR(6), CHAR(80);

DEFINE iSqlErr 		INTEGER;
DEFINE cCodRet 		CHAR(6);
DEFINE cCodRetSms 	CHAR(6);
DEFINE cMensajeRet	CHAR(80);
DEFINE cCadena  	CHAR (500);
DEFINE cRuta 		CHAR (50);
DEFINE cDatosProsp 	CHAR (50);
DEFINE cBitCamp 	CHAR (50);
DEFINE vnum_cred 	CHAR (20);
DEFINE vnum_cte 	CHAR (20);
DEFINE vnum_promo 	INTEGER;
DEFINE vtipo_tar 	CHAR (3);
DEFINE vnombre 		CHAR (106);
DEFINE vnombre_emb 	CHAR (21);
DEFINE vnum_prod 	CHAR (4);
DEFINE cmiembro 	CHAR (2);
DEFINE dtCampAct 	DATETIME YEAR TO SECOND;
DEFINE dtCampIni 	DATETIME YEAR TO SECOND;
DEFINE dtCampFin 	DATETIME YEAR TO SECOND;
DEFINE dFechaIniCred	DATETIME YEAR TO SECOND;
DEFINE wBegin			CHAR(1);
DEFINE cArchivo_dbld	CHAR(50);
DEFINE cArchivo_log     CHAR(50);
DEFINE sCteInvSMS		CHAR(1);
DEFINE sCountExist		SMALLINT;
DEFINE sContador 		SMALLINT;
DEFINE dTasa        	DECIMAL(10,2);
DEFINE iPlazo       	INTEGER;



LET iSqlErr 		= 0;
LET cCodRet 		= '000001';
LET cCodRetSms 		= '000000';
LET cMensajeRet		= '';
LET cCadena 		= '';
LET cRuta 			= '';
LET cDatosProsp 	= '';
LET cBitCamp 		= '';
LET vnum_cred 		= '';
LET vnum_cte 		= '';
LET vnum_promo 		= 0;
LET vtipo_tar 		= '';
LET vnombre 		= '';
LET vnombre_emb 	= '';
LET vnum_prod 		= '';
LET cmiembro 		= '';
LET wBegin 			= '';
LET dtCampAct 		= CURRENT;
LET cArchivo_dbld	= "f_datosprosp.com";
LET cArchivo_log    = "f_datosprosp.log";
LET sCteInvSMS		= '';
LET sCountExist		= 0;
LET sContador 		= 0;
LET dTasa        	= 0;
LET iPlazo       	= 0;


BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			--LET cMensajeRet = cErrorInfo;
		END IF;
		RETURN cCodRet;
	END EXCEPTION;
   	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;  

	--SET DEBUG FILE TO '/informix/IvanZazueta/sp_carga_datos_camp.out';
	--TRACE ON;

    LET cDatosProsp = "datosprospectos";
    LET cBitCamp = "bitacoracamp";
    LET cRuta = "/resplogifx/archivoscredito/";                                                    
	
	IF NVL(cRuta,'') <> '' THEN
		IF NVL(cDatosProsp,'') <> '' THEN

			LET dtCampAct = CURRENT;
			--	LET cDatosProsp = TRIM(cDatosProsp)||'_'||YEAR(dtCampAct)||LPAD(MONTH(dtCampAct),2,0)||LPAD(DAY(dtCampAct),2,0)||'.txt';      
            LET cDatosProsp = TRIM(cDatosProsp)||'_'||YEAR(dtCampAct)||LPAD(MONTH(dtCampAct),2,0)||LPAD(DAY(dtCampAct),2,0)||'.unl';                
            LET cBitCamp= TRIM(cBitCamp)||'_'||YEAR(dtCampAct)||LPAD(MONTH(dtCampAct),2,0)||LPAD(DAY(dtCampAct),2,0)||'.txt'; 

			TRUNCATE TABLE "informix".sd_carga_datos_pros;
				               
            system ' echo "FILE ' ||  TRIM(cRuta) ||  TRIM(cDatosProsp) ||' DELIMITER '|| "'" || '|' || "'" || ' 11;' || '">' || TRIM(cRuta) || TRIM(cArchivo_dbld);  
			system ' echo "INSERT INTO sd_carga_datos_pros;' || '">>' || TRIM(cRuta) || TRIM(cArchivo_dbld);
			system 'chmod 777 ' || TRIM(cRuta) || TRIM(cArchivo_dbld);

			system ' echo "date ' || '">' || TRIM(cRuta) || 'dbload_datospros.sh';
			system ' echo "dbload -d bdicred -c ' || TRIM(cRuta) || TRIM(cArchivo_dbld)  ||' -l ' || TRIM(cRuta) || TRIM(cArchivo_log) || ' -n 1000 ' || ' " >> ' || TRIM(cRuta)|| 'dbload_datospros.sh'; 
			system ' echo "date ' || '">>' || TRIM(cRuta)|| 'dbload_datospros.sh';
			system ' echo "dbaccess bdicred -<<EOF ' || '">>' || TRIM(cRuta)|| 'dbload_datospros.sh';             
			system ' echo "set pdqpriority 0;' || '">>' || TRIM(cRuta)|| 'dbload_datospros.sh';          
			system ' echo "update statistics medium for table sd_carga_datos_pros; ' || '">>' || TRIM(cRuta)|| 'dbload_datospros.sh';           
			system ' echo "EOF' || '">>' || TRIM(cRuta)|| 'dbload_datospros.sh';           
			system 'chmod 777 ' || TRIM(cRuta)|| 'dbload_datospros.sh';

			system '/usr/bin/sh ' || TRIM(cRuta)|| 'dbload_datospros.sh';

			/*
			--LET cCadena = '/usr/bin/echo "LOAD FROM ''' || SUBSTR(cRuta,1,LENGTH(cRuta)) || SUBSTR(cDatosProsp,1,LENGTH(cDatosProsp)) ||'''  delimiter ''|'' INSERT INTO bdicred:"informix".sd_carga_datos_pros" >' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'datos_prospecto.sql';
			--SYSTEM cCadena;	
			--LET cCadena='chmod 777 '|| TRIM(cRuta)||'datos_prospecto.sql';
			--System cCadena;
			--let cCadena = 'dbaccess bdicred ' || TRIM(cRuta) || 'datos_prospecto.sql';
			--System cCadena;	
			--LET cCadena = '' ;
			--LET cCadena = '/usr/bin/rm ' || TRIM(cRuta) || 'datos_prospecto.sql';
			--SYSTEM cCadena;
				*/               
				
			LET cCodRet = '000000';
		ELSE
			LET cCodRet = '000002';
		END IF;
            
        IF cCodRet = '000000' THEN 

			DELETE {+  AVOID_FULL("informix".sd_carga_datos_pros ) } 
			  FROM "informix".sd_carga_datos_pros a WHERE a.num_credito IN (SELECT num_credito FROM "informix".sd_maecred WHERE empresa = '001' AND numcte <> a.num_cte);
			  
			FOREACH WITH HOLD
                SELECT num_cte , num_credito, num_promo , fecha_Ini, fecha_Fin, envio_inv_sms, tasa , plazo
                  INTO vnum_cte, vnum_cred  , vnum_promo, dtCampIni, dtCampFin, sCteInvSMS   , dTasa, iPlazo
                  FROM sd_carga_datos_pros
               
				LET sCountExist = 0;
				IF (sContador = 0) THEN
					BEGIN WORK;
				END IF;  
			
				IF LENGTH(vnum_cte) != 9 THEN
					LET cCodRet = '000003';
					LET cMensajeRet = 'Error en la longitud del numero del cliente.';
					RETURN cCodRet;				END IF;

				IF LENGTH(vnum_cred) != 12 THEN
					LET cCodRet = '000004';
					LET cMensajeRet = 'Error en la longitud del numero de credito.';
					RETURN cCodRet;				END IF;
				SELECT count(num_credito) INTO sCountExist FROM "informix".sd_prospectos WHERE num_promo = vnum_promo AND num_credito = vnum_cred;
				--IF NOT EXISTS ( SELECT num_credito FROM "informix".sd_prospectos WHERE num_credito = vnum_cred and numcte = vnum_cte and num_promo = vnum_promo) THEN
				IF sCountExist = 0 THEN
					INSERT INTO  "informix".sd_prospectos (empresa, num_producto, num_promo, numcte, num_credito, fecha_ini,fecha_fin, envio_inv_sms, revis_invit_sms, tasa, plazo)
						 VALUES ('001' ,'6900',vnum_promo, vnum_cte,vnum_cred , dtCampIni, dtCampFin, sCteInvSMS, 1, dTasa, iPlazo);

                    UPDATE "informix".sd_carga_datos_pros SET cod_ret='000000', descripcion='Prospecto Exitoso' WHERE num_credito = vnum_cred AND num_cte = vnum_cte AND num_promo = vnum_promo;
                        
				ELSE-- YA EXISTE CREDITO						
						
					UPDATE "informix".sd_prospectos SET fecha_ini = dtCampIni, fecha_fin = dtCampFin, envio_inv_sms = sCteInvSMS, revis_invit_sms = 1, tasa = dTasa, plazo = iPlazo
					 WHERE num_promo = vnum_promo AND num_credito = vnum_cred;
					UPDATE "informix".sd_carga_datos_pros SET cod_ret = '000001', descripcion = 'Prospecto Actualizado' WHERE num_credito = vnum_cred AND num_promo = vnum_promo;

				END IF;
				
				LET sContador = sContador + 1;
				IF sContador >= 500 THEN
					COMMIT WORK;
					LET sContador = 0;
				END IF;
			
			END FOREACH;

			IF sContador > 0 THEN
				COMMIT WORK;
			END IF;

				  
			LET cCadena = '';
			LET cCadena = '/usr/bin/echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cBitCamp)  ||'  delimiter ''|'' SELECT num_credito,num_cte,num_promo,fecha_Ini,fecha_Fin,cod_ret,descripcion FROM bdicred:"informix".sd_carga_datos_pros" >'||TRIM(cRuta)||'bit_camp.sql';
			SYSTEM cCadena;				
			LET cCadena='chmod 777 '|| TRIM(cRuta)||'bit_camp.sql';
			System cCadena;				
			let cCadena = 'dbaccess bdicred ' || TRIM(cRuta) || 'bit_camp.sql';
			System cCadena;				
			LET cCadena = '' ;
			LET cCadena = 'rm ' || TRIM(cRuta) || 'bit_camp.sql';
			SYSTEM cCadena;
	
		ELSE			
			LET cMensajeRet = 'Error en la carga de archivo de prospectos.';
		END IF;	
	END IF;

	RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
'',
'AUTOR : CONCEPCION ALVAREZ CARRILLO',
'FECHA : 27/SEP/2017',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_genera_carteraenlinea_tab_plazo(pEmpresa char(3)) 

RETURNING  CHAR(6) AS Cod_Ret,  CHAR(80) AS Mens_Ret;

-- Creador por: MAHR. Abril 2012. Se crea la informacion de la Cartera en linea dentro de la tabla sd_sdos_cartera_linea, a fin de que los 
--             diversos procesos que explotan la misma informacion la obtengan de dicha tabla, optimizando los tiempos de consulta.
-- Servicios: 1.- Tarjeta de Credito, 2.- Prestamo Personal y Reestructura 3.- AMBOS.

-- Se modifica el proceso para agregar campos solicitados en el RQM 09 463 - Agosto 2017. ADLM.
--Declaracion de variables
-- V.2 JAHJ Septiembre 2023  
DEFINE sql_err          INTEGER;
DEFINE isam_err         INTEGER;
DEFINE error_info       CHAR(80);
DEFINE cEmpresa         CHAR(3);
DEFINE cProceso         CHAR(4);
DEFINE cCod_ret         CHAR(6);
DEFINE cCod_retBit      CHAR(6);
DEFINE cMensajeRet      CHAR(125);  
DEFINE cruta            CHAR(100);
DEFINE cSQL             CHAR(8204);
DEFINE cSQL1            CHAR(6204);
DEFINE cSQL2            CHAR(6204);
DEFINE vcliente         CHAR(20);
DEFINE vcredito         CHAR(20);
DEFINE vtarjeta         CHAR(20);
DEFINE vcta_eje         CHAR(20);
DEFINE vproducto        CHAR(4);
DEFINE vstatuscred      CHAR(2);
DEFINE vsucursal        CHAR(4);
DEFINE vcat             CHAR(6);
DEFINE dFecha_hoy       DATE;
DEFINE dFecha_max       DATE;
DEFINE dFecha_min       DATE;
DEFINE dFecha_ayer      DATE;
DEFINE dFecha_today 	DATE;
DEFINE vfechaultpago	DATE;
DEFINE vfch_apertura    DATE;
DEFINE vproxfchpago     DATE;
DEFINE cfechavencto, cfechavencto1, cfechavencto2, cfechavencto3, cfechavencto4, cfechavencto5 DATE;
DEFINE cfecha_habil1, cfecha_habil2, cfecha_habil3, cfecha_habil4, cfecha_habil5 DATE;
DEFINE vtasainteres     DECIMAL(9,6);
DEFINE ctasamora        DECIMAL(9,6);
DEFINE vmontootorgado,  vsdo_intereses, vmensualidad_act	 DECIMAL(18,2);
DEFINE vsdo_capital,   vmonto_vencido, vmtovenctrasp, vcaptrasnovenci, vsdocapinsoluto	DECIMAL(18,2);
DEFINE montofinanciado,vsdomoratorio,  vinteresiva,   vmoras,          pagounamora    	DECIMAL(18,2);
DEFINE cSaldovencido1, cSaldovencido2, cSaldovencido3,cSaldovencido4,  cSaldovencido5   MONEY(18,2);
DEFINE cSaldovencido6, cInteresmoratorio1, cInteresmoratorio2, cInteresmoratorio3       MONEY(18,2);
DEFINE cInteresmoratorio4, cInteresmoratorio5, cInteresmoratorio6, cInteresV            MONEY(18,2);
DEFINE mIvaSucursal     MONEY(5,3);
DEFINE sAbonosVdos      INTEGER;
DEFINE sDiasTrans       INTEGER;
DEFINE sDiaCorte        SMALLINT;
DEFINE vgrupo			CHAR(1);
DEFINE vantiguedad		INTEGER;
DEFINE vbcscore			DECIMAL(5,2);
DEFINE vscoreprop		DECIMAL(5,2);
DEFINE vficoscore		DECIMAL(5,2);
DEFINE vbhscore			DECIMAL(5,2);
DEFINE vnovencidos1		INTEGER;
DEFINE vnovencidos2		INTEGER;
DEFINE vnovencidos3		INTEGER;
DEFINE vnovencidos4		INTEGER;
DEFINE vnovencidos5		INTEGER;
DEFINE vnovencidos6		INTEGER;
DEFINE vcelular			CHAR(13);
DEFINE vivatrasp		DECIMAL(18,2);
DEFINE vretenido        DECIMAL(18,2);
DEFINE cAct                     INTEGER;
DEFINE cAtr                     INTEGER;

DEFINE v_fecha_vencido  DATE;
DEFINE v_num_vencidos   INTEGER;
DEFINE dPagosVdos       INTEGER;
DEFINE v_dias_vencido   INTEGER;
DEFINE dUltDisp_atm     DATE;
DEFINE dUltDisp_pos     DATE;
DEFINE dUltDisp_vnt     DATE;
DEFINE dUltima_Disposicion DATE;
DEFINE v_ejecutivo CHAR(8);
DEFINE v_cuenta_bloque  integer;

--SET DEBUG FILE TO "/ifxsif01/PEDRO/carteralinea/sp_genera_carteraenlinea_tab.out";
--TRACE ON;

--Inicializacion de variables
LET sql_err         = 0;
LET isam_err        = 0;
LET error_info      = "";
LET cEmpresa        = "";
LET cProceso        = '0202';
LET cCod_Ret        = '00000';
LET cCod_retBit     = '00000';
LET cMensajeRet     = 'PROCESO EXITOSO';
LET cSQL            = '';
LET cSQL1           = '';
LET cSQL2           = '';
LET cruta           = '';
LET	vcliente        = '';
LET	vcredito        = '';
LET	vtarjeta        = '';
LET	vcta_eje        = '';
LET	vproducto       = '';
LET	vstatuscred     = '';
LET	vsucursal       = '';
LET	vcat            = '';
LET	vsdo_capital    = 0;    LET vmonto_vencido	= 0;    LET vmtovenctrasp  = 0;     LET vcaptrasnovenci    = 0; LET vsdocapinsoluto     = 0; 
LET pagounamora     = 0;    LET montofinanciado = 0;    LET vsdomoratorio  = 0;     LET vinteresiva        = 0; LET vmoras              = 0; 
LET vmontootorgado  = 0;    LET vtasainteres    = 0;    LET ctasamora      = 0;     LET cSaldovencido1     = 0; LET cSaldovencido2      = 0; 
LET cSaldovencido3  = 0;    LET cSaldovencido4  = 0;    LET cSaldovencido5 = 0;     LET cSaldovencido6     = 0; LET cInteresmoratorio1  = 0; 
LET cInteresmoratorio2 = 0; LET cInteresmoratorio3 = 0; LET cInteresmoratorio4 = 0; LET cInteresmoratorio5 = 0; LET cInteresmoratorio6  = 0; 
LET mIvaSucursal       = 0; LET sAbonosVdos     = 0;    LET sDiasTrans     = 0;     LET vsdo_intereses     = 0; LET vmensualidad_act   = 0;
LET sDiaCorte          = 0; 
LET vgrupo			= "";
LET vantiguedad		= 0;
LET vbcscore		= 0;
LET vscoreprop		= 0;
LET vficoscore		= 0;
LET vbhscore		= 0;
LET vnovencidos1	= 0;
LET vnovencidos2	= 0;
LET vnovencidos3	= 0;
LET vnovencidos4	= 0;
LET vnovencidos5	= 0;
LET vnovencidos6	= 0;
LET vcelular		="";
LET vivatrasp		= 0;
LET vretenido       = 0;
LET dFecha_hoy      = date(1);
LET dFecha_max      = date(1);
LET dFecha_min      = date(1);
LET dFecha_ayer		= date(1);
LET dFecha_today	= date(1);
LET cAct                        = 0;
LET cAtr                        = 0;

LET v_fecha_vencido  = DATE(1);
LET v_num_vencidos   =0;
LET dPagosVdos       =0;
LET v_dias_vencido   =0; 
LET dUltDisp_atm  = DATE(1);
LET dUltDisp_pos  = DATE(1);
LET dUltDisp_vnt  = DATE(1);
LET dUltima_Disposicion = DATE(1);
LET v_ejecutivo ="";
LET v_cuenta_bloque = 0;

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensajeRet = error_info;        		
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet || ' Error en cart_tab', '02') RETURNING cCod_retBit;
        RETURN cCod_ret,cMensajeRet;
    END EXCEPTION;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, 'INICIA sp_genera_carteraenlinea_tab ', '02') RETURNING cCod_retBit;       

    --Directiva para lectura de tablas bloqueadas.
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- Obtener la fecha del dia de hoy
    SELECT fecha_hoy, fecha_ant INTO dFecha_hoy, dFecha_ayer FROM bdicred:"informix".sd_fechas WHERE empresa = pEmpresa; 
	IF dFecha_hoy IS NULL THEN
        LET dFecha_hoy = Today;
		LET dFecha_ayer = today - 1;
    END IF
    
    --LET dFecha_hoy = MDY(10,15,2025);
	--LET dFecha_ayer = MDY(10,14,2025);
	
	--Validacion de la empresa
    SELECT empresa INTO cEmpresa FROM bdinteg:"informix".si_empresas WHERE empresa = pEmpresa;
    IF NVL (cEmpresa, '') = '' OR cEmpresa IS NULL THEN
        LET pEmpresa = '001';
		LET dFecha_ayer = today - 1;
    END IF;

CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, 'Empresa validada', '02') RETURNING cCod_retBit;  
	--Obtener ruta del archivo
    SELECT TRIM(valor_alfabetico) INTO cruta
        FROM bdicobranza:"informix".cb_param_campania
        WHERE empresa = pEmpresa AND tipo_campania = 1
        AND grupo_parametro = 'ARCHIVOS'AND num_parametro = 34;  
    IF NVL (cruta,'') = '' THEN     --Valida que exista la carpeta
        LET cCod_Ret= '104005';
        SELECT descripcion INTO cMensajeRet
            FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensajeRet IS NULL THEN
            LET cMensajeRet = "";
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, 'Ruta incorrecta - sp_genera_carteraenlinea_tab', '02') RETURNING cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
    END IF;
	
--	LET cruta='/ifxsif01/90260202/marco/';							--  <--    ***********************  comentar esta linea 
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, 'ruta validada', '02') RETURNING cCod_retBit;  
	


 	
    -- | Cliente | Credito | Tarjeta | Cuenta eje | Producto | sdo_capital | monto_vencido | mto_venc_trasp | cap_tras_no_venci | sdo_cap_insoluto | 
    -- | monto financiado | Int moratorio | interes_iva | No moras | status_cred | fecha_ult_pago | pago una mora | Sucursal | Fecha_apertura |  
    -- | monto_otorgado | tasa_interes | prox_fecha_pago | Cat | saldovencido1 |saldovencido2 |saldovencido3 | saldovencido4 | saldovencido5 |
    -- | saldovencido6 | interesmoratorio1 | interesmoratorio2 | interesmoratorio3 | interesmoratorio4 | interesmoratorio5 | interesmoratorio6 |

	-- ********************************************************************************************************************
	-- ********************************************************************************************************************
	-- ********************************************************************************************************************

		--AAME RQM 10 393 20150624 Se solicita contemplar los dos nuevos productos de prestamo personal (7600,7700)
        --AAME RQM 10 1177 Se agregan nuevos prestamos 9100,9300 y Reestructura 8600
		
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, 'Paso 4: Obtiene info PLAZO', '02') RETURNING cCod_retBit;  
		
		DROP TABLE IF EXISTS tmp_creditos_crd;
		

		 create table bdicred:tmp_creditos_crd(
				 empresa char(3), 
				 num_credito char(20),
				 numcte char(20), 
				 num_producto char(4),
				 status_cred char(2), 
				 sucursal char(4), 
				 fecha_apertura date,
				 tasa_interes   decimal(9,6),
				 tasa_moratorios decimal(9,6),
				 credito_externo char(20), 
				 ejecutivo char(8) 
		 ); 
		SET ISOLATION TO DIRTY READ;
		INSERT  into tmp_creditos_crd	
		SELECT  a.empresa, a.num_credito,a.numcte, a.num_producto, a.status_cred ,a.sucursal,a.fecha_apertura,a.tasa_interes,a.tasa_moratorios,a.credito_externo,a.ejecutivo 
			FROM bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b
			WHERE a.num_credito = b.num_credito
			AND a.num_producto IN ('6011','6300','6400','6800','7600','7700','8600','9100','9300')
			and a.status_cred in ('E1','E2','E3','VP')  
			and (b.monto_vencido + b.mto_venc_trasp) > 0; 
		
  
          create unique index inx_creditossl_crd on tmp_creditos_crd(numcte,sucursal,num_credito);
          update statistics medium for table tmp_creditos_crd resolution 1.6; 


		--  ******************************************************    cambio jahj Julio 2023
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		

		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, 'Paso 5: Inicia Foreach Obtener info PLAZO monto,saldos,etc', '02') RETURNING cCod_retBit;  
        FOREACH with hold 
            SELECT a.numcte, a.num_credito, 0 num_tarjeta, (SELECT num_cta FROM bdicred:sd_ctascarg WHERE a.num_credito = num_credito 
                AND naturaleza= 'A') Cta_eje, a.num_producto, b.sdo_capital, b.monto_vencido, b.mto_venc_trasp, b.cap_tras_no_venci, 
                b.sdo_cap_insoluto, b.monto_financiado, round((b.sdo_moratorio + b.sdo_contab_mora) * (1 + s.iva),2) moratorio,
                (b.int_tra_no_exig + b.mto_venc_int + b.sdo_no_exig + b.mto_finan_vdo) interes_iva,
                b.mto_fin_ven_trasp::integer mora_actual, 
				(case when (a.status_cred = 'VP' and b.mto_fin_ven_trasp = 1 and nvl(b.atr,0) = 0) then 'BA'
				      when (a.status_cred = 'VP' and b.mto_fin_ven_trasp > 1 and nvl(b.atr,0) = 0) then 'BT' 
				      when (a.status_cred = 'VP' and nvl(b.atr,0) = 1) then 'E1'  
					  when (a.status_cred = 'VP' and nvl(b.atr,0) in (2,3)) then 'E2'  
					  when (a.status_cred = 'VP' and nvl(b.atr,0) > 3) then 'E3'  
					  when (a.status_cred <> 'VP') then a.status_cred end) Status_Cred, 
                d.fecha_ult_pago, (SELECT (capital_debe - capital_pagado) + (interes_debe - interes_pagado) + (iva_debe - iva_pagado) +
                ((( mora_provi_ordi + mora_provi_cope) + ( mora_sdo_ordi - mora_sdo_ordi_pag) + ( mora_sdo_cope - mora_sdo_cope_pag)) * (1+ s.iva)) 
                FROM bdicred:sd_amortiza_creditocrd amort 
				WHERE a.empresa = amort.empresa AND a.num_credito = amort.num_credito AND amort.fecha_cuota = (SELECT min (fecha_cuota) FROM bdicred:sd_amortiza_creditocrd WHERE amort.empresa = empresa 
                AND amort.num_credito = num_credito AND capital_status IN ('2','7','6'))) Pago_una_mora, a.sucursal, a.fecha_apertura, b.monto_otorgado, 
                a.tasa_interes, d.prox_fecha_pago, (SELECT cat.cat FROM bdicred:sd_tasa_cat cat WHERE a.empresa = cat.empresa 
                AND a.tasa_interes = cat.tasa AND a.num_producto = cat.producto) cat, 1 + s.iva, a.tasa_moratorios, --d.fecha_vencto,
                (Select min(fecha_cuota) from bdicred:sd_amortiza_creditocrd WHERE a.empresa = empresa and a.num_credito = num_credito 
                 and capital_status in ('2','7','6')) fecha_vencto, round(NVL(b.sdo_intereses,0) * (1+ s.iva),2),
                nvl((SELECT (nvl(capital_debe,0) - nvl(capital_pagado,0)) + (nvl(interes_debe,0) - nvl(interes_pagado,0)) +
                (nvl(iva_debe,0) - nvl(iva_pagado,0)) FROM bdicred:sd_amortiza_creditocrd WHERE a.empresa = empresa
                AND a.num_credito = num_credito AND capital_status = 1 ),0) Mensualidad_Actual, d.dia_corte,
				(select resum.grupo from bdisolic:ss_resum_scor_fin resum where a.num_credito=resum.num_solicitud) grupo,
				trunc((dfecha_hoy - a.fecha_apertura)/30) antiguedad, 

				case when a.num_producto <> '6011' then nvl(scr1.evaluacion,0) else nvl(sRe1.evaluacion,0) end, 
				case when a.num_producto <> '6011' then nvl(scr2.evaluacion,0) else nvl(sRe2.evaluacion,0) end, 
				case when a.num_producto <> '6011' then nvl(scr3.evaluacion,0) else nvl(sRe3.evaluacion,0) end, 
				case when a.num_producto <> '6011' then nvl(scr4.evaluacion,0) else nvl(sRe4.evaluacion,0) end,	

				nvl(mhre1.mto_fin_ven_trasp,0), nvl(mhre2.mto_fin_ven_trasp,0), nvl(mhre3.mto_fin_ven_trasp,0), nvl(mhre4.mto_fin_ven_trasp,0),
				nvl(mhre5.mto_fin_ven_trasp,0), nvl(mhre6.mto_fin_ven_trasp,0),

				cel.telefono, nvl((SELECT (nvl(interes_debe,0) - nvl(interes_pagado,0)) + (nvl(iva_debe,0) - nvl(iva_pagado,0)) FROM bdicred:sd_amortiza_creditocrd 
				WHERE a.empresa = empresa AND a.num_credito = num_credito AND capital_status = 1 ),0) iva_int_trasp,
				CASE WHEN nvl(b.sdo_retenido,0) > 0 then nvl(b.sdo_retenido,0) else 0.00 end sdo_retenido, 
				b.atr, 
				d.fecha_vencto  --  ***************    cambio jahj Julio 2023
                INTO
                vcliente, vcredito, vtarjeta, vcta_eje, vproducto, vsdo_capital, vmonto_vencido, vmtovenctrasp, vcaptrasnovenci, vsdocapinsoluto, 
                montofinanciado, vsdomoratorio, vinteresiva, vmoras, vstatuscred, vfechaultpago, pagounamora, vsucursal, vfch_apertura, 
                vmontootorgado, vtasainteres, vproxfchpago, vcat, mIvaSucursal, ctasamora, cfechavencto, vsdo_intereses, vmensualidad_act, sDiaCorte,
				vgrupo, vantiguedad, 
				vbcscore, vscoreprop, vficoscore, vbhscore,   --  ***************    cambio jahj Julio 2023
				vnovencidos1, vnovencidos2, vnovencidos3, vnovencidos4, vnovencidos5, vnovencidos6,   --  ***************    cambio jahj Julio 2023
				vcelular, vivatrasp,vretenido, cAtr, 
				v_fecha_vencido   --  ***************    cambio jahj Julio 2023  De acuerdo a la lectura solo es para bajarlo al foreach
                FROM tmp_creditos_crd a
                JOIN bdicred:sd_maesdoscrd b ON (a.empresa = b.empresa AND a.num_credito = b.num_credito)
                JOIN bdicred:sd_maecredanexocrd d ON (a.empresa = d.empresa AND a.num_credito = d.num_credito)
                JOIN bdinteg:si_sucursales s ON (s.empresa = a.empresa AND s.sucursal = a.sucursal)

				left outer join bdisolic:ss_resumen_scoring scr1 on (a.num_credito=scr1.num_solicitud and scr1.seccion=1)
				left outer join bdisolic:ss_resumen_scoring scr2 on (a.num_credito=scr2.num_solicitud and scr2.seccion=2)
				left outer join bdisolic:ss_resumen_scoring scr3 on (a.num_credito=scr3.num_solicitud and scr3.seccion=3)
				left outer join bdisolic:ss_resumen_scoring scr4 on (a.num_credito=scr4.num_solicitud and scr4.seccion=4) 
				left outer join bdisolic:ss_resumen_scoring sRe1 on (a.credito_externo=sRe1.num_solicitud and sRe1.seccion=1)
				left outer join bdisolic:ss_resumen_scoring sRe2 on (a.credito_externo=sRe2.num_solicitud and sRe2.seccion=2)
				left outer join bdisolic:ss_resumen_scoring sRe3 on (a.credito_externo=sRe3.num_solicitud and sRe3.seccion=3)
				left outer join bdisolic:ss_resumen_scoring sRe4 on (a.credito_externo=sRe4.num_solicitud and sRe4.seccion=4) 
				left outer join bdicred:sd_maesdoshistcrd mhre1 on(a.num_credito=mhre1.num_credito and mhre1.fecha=add_months((select max(b.fecha) from bdicred:sd_maesdoshistcrd b where b.num_credito=a.num_credito),-1)) 
				left outer join bdicred:sd_maesdoshistcrd mhre2 on(a.num_credito=mhre2.num_credito and mhre2.fecha=add_months((select max(b.fecha) from bdicred:sd_maesdoshistcrd b where b.num_credito=a.num_credito),-2))
				left outer join bdicred:sd_maesdoshistcrd mhre3 on(a.num_credito=mhre3.num_credito and mhre3.fecha=add_months((select max(b.fecha) from bdicred:sd_maesdoshistcrd b where b.num_credito=a.num_credito),-3))
				left outer join bdicred:sd_maesdoshistcrd mhre4 on(a.num_credito=mhre4.num_credito and mhre4.fecha=add_months((select max(b.fecha) from bdicred:sd_maesdoshistcrd b where b.num_credito=a.num_credito),-4))
				left outer join bdicred:sd_maesdoshistcrd mhre5 on(a.num_credito=mhre5.num_credito and mhre5.fecha=add_months((select max(b.fecha) from bdicred:sd_maesdoshistcrd b where b.num_credito=a.num_credito),-5))
				left outer join bdicred:sd_maesdoshistcrd mhre6 on(a.num_credito=mhre6.num_credito and mhre6.fecha=add_months((select max(b.fecha) from bdicred:sd_maesdoshistcrd b where b.num_credito=a.num_credito),-6))

				left outer join bdinteg:si_telefonos_actual cel on(a.numcte=cel.numcte and cel.secuencia=(select max(secuencia) 
								from bdinteg:si_telefonos_actual where a.numcte=numcte and tipo_tel=2 and status_tel='A'))
--              WHERE (b.monto_vencido + b.mto_venc_trasp) > 0
--				b.monto_vencido + b.mto_venc_trasp > 0
--              ORDER BY a.num_producto ASC limit 100

            IF NOT EXISTS (SELECT fecha, num_credito FROM bdicred:"informix".sd_sdos_cartera_linea 
                                                                      WHERE fecha = dFecha_hoy AND num_credito = vcredito) THEN

                -- Obtiene las fechas de meses de vencimiento
                IF cfechavencto IS NULL THEN LET cfechavencto = date(1); END IF;
                EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(cfechavencto, 1 , sDiaCorte) INTO cCod_Ret, cfechavencto1, sDiasTrans;
                EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(cfechavencto, 2 , sDiaCorte) INTO cCod_Ret, cfechavencto2, sDiasTrans;
                EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(cfechavencto, 3 , sDiaCorte) INTO cCod_Ret, cfechavencto3, sDiasTrans;
                EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(cfechavencto, 4 , sDiaCorte) INTO cCod_Ret, cfechavencto4, sDiasTrans;
                EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(cfechavencto, 5 , sDiaCorte) INTO cCod_Ret, cfechavencto5, sDiasTrans;

                -- Valida que las fechas sean fechas habiles, si no obtiene la fecha habil correcta.
                EXECUTE PROCEDURE bdicred:"informix".sp_valfechabil(cfechavencto1,'+') INTO cCod_Ret, cfecha_habil1;
                EXECUTE PROCEDURE bdicred:"informix".sp_valfechabil(cfechavencto2,'+') INTO cCod_Ret, cfecha_habil2;
                EXECUTE PROCEDURE bdicred:"informix".sp_valfechabil(cfechavencto3,'+') INTO cCod_Ret, cfecha_habil3;
                EXECUTE PROCEDURE bdicred:"informix".sp_valfechabil(cfechavencto4,'+') INTO cCod_Ret, cfecha_habil4;
                EXECUTE PROCEDURE bdicred:"informix".sp_valfechabil(cfechavencto5,'+') INTO cCod_Ret, cfecha_habil5;
                IF cfechavencto1 != cfecha_habil1 THEN LET cfechavencto1 = cfecha_habil1; END IF;
                IF cfechavencto2 != cfecha_habil2 THEN LET cfechavencto2 = cfecha_habil2; END IF;
                IF cfechavencto3 != cfecha_habil3 THEN LET cfechavencto3 = cfecha_habil3; END IF;
                IF cfechavencto4 != cfecha_habil4 THEN LET cfechavencto4 = cfecha_habil4; END IF;
                IF cfechavencto5 != cfecha_habil5 THEN LET cfechavencto5 = cfecha_habil5; END IF;


                SELECT
                    sum(case when fecha_cuota = cfechavencto then nvl((capital_debe-capital_pagado),0) + NVL((interes_debe-interes_pagado+iva_debe-iva_pagado),0) else 0 end),
                    sum(case when fecha_cuota = cfechavencto then NVL(((mora_provi_ordi+mora_provi_cope+mora_sdo_ordi-mora_sdo_ordi_pag+mora_sdo_cope-mora_sdo_cope_pag)*mIvaSucursal),0) + nvl(((capital_debe-capital_pagado) * ctasamora / 36000) * 17.25,0)  else 0 end),
                    sum(case when fecha_cuota = cfechavencto1 then nvl((capital_debe-capital_pagado),0) + NVL((interes_debe-interes_pagado+iva_debe-iva_pagado),0) else 0 end),
                    sum(case when fecha_cuota = cfechavencto1 then NVL(((mora_provi_ordi+mora_provi_cope+mora_sdo_ordi-mora_sdo_ordi_pag+mora_sdo_cope-mora_sdo_cope_pag)*mIvaSucursal),0) + nvl(((capital_debe-capital_pagado) * ctasamora / 36000) * 17.25,0)  else 0 end),
                    sum(case when fecha_cuota = cfechavencto2 then nvl((capital_debe-capital_pagado),0) + NVL((interes_debe-interes_pagado+iva_debe-iva_pagado),0) else 0 end),
                    sum(case when fecha_cuota = cfechavencto2 then NVL(((mora_provi_ordi+mora_provi_cope+mora_sdo_ordi-mora_sdo_ordi_pag+mora_sdo_cope-mora_sdo_cope_pag)*mIvaSucursal),0) + nvl(((capital_debe-capital_pagado) * ctasamora / 36000) * 17.25,0)  else 0 end),
                    sum(case when fecha_cuota = cfechavencto3 then nvl((capital_debe-capital_pagado),0) + NVL((interes_debe-interes_pagado+iva_debe-iva_pagado),0) else 0 end),
                    sum(case when fecha_cuota = cfechavencto3 then NVL(((mora_provi_ordi+mora_provi_cope+mora_sdo_ordi-mora_sdo_ordi_pag+mora_sdo_cope-mora_sdo_cope_pag)*mIvaSucursal),0) + nvl(((capital_debe-capital_pagado) * ctasamora / 36000) * 17.25,0)  else 0 end),
                    sum(case when fecha_cuota = cfechavencto4 then nvl((capital_debe-capital_pagado),0) + NVL((interes_debe-interes_pagado+iva_debe-iva_pagado),0) else 0 end),
                    sum(case when fecha_cuota = cfechavencto4 then NVL(((mora_provi_ordi+mora_provi_cope+mora_sdo_ordi-mora_sdo_ordi_pag+mora_sdo_cope-mora_sdo_cope_pag)*mIvaSucursal),0) + nvl(((capital_debe-capital_pagado) * ctasamora / 36000) * 17.25,0)  else 0 end),
                    sum(case when fecha_cuota >= cfechavencto5 then nvl((capital_debe-capital_pagado),0) + NVL((interes_debe-interes_pagado+iva_debe-iva_pagado),0) else 0 end),
                    sum(case when fecha_cuota >= cfechavencto5 then NVL(((mora_provi_ordi+mora_provi_cope+mora_sdo_ordi-mora_sdo_ordi_pag+mora_sdo_cope-mora_sdo_cope_pag)*mIvaSucursal),0) + nvl(((capital_debe-capital_pagado) * ctasamora / 36000) * 17.25,0)  else 0 end),
                    sum(NVL((interes_debe-interes_pagado+iva_debe-iva_pagado),0)), count(*)
                    INTO
                    cSaldovencido1, cInteresmoratorio1, cSaldovencido2, cInteresmoratorio2,cSaldovencido3, cInteresmoratorio3, cSaldovencido4, 
                    cInteresmoratorio4, cSaldovencido5, cInteresmoratorio5, cSaldovencido6, cInteresmoratorio6, cInteresV, sAbonosVdos
                    from bdicred:sd_amortiza_creditocrd b
                    where empresa = pEmpresa and num_credito = vcredito and fecha_cuota >= cfechavencto and capital_status in ('1','2','7','6');
                                        
                    SELECT  num_vencidos_ch, dias_atraso  --fecha_vencido,
                    INTO  v_num_vencidos, v_dias_vencido  --v_fecha_vencido,
                    FROM sd_indicador_cred_crd
                    WHERE num_credito=vcredito;
					
--  				***************    cambio jahj Julio 2023 recuperamos el dato en la consulta principal
--					select fecha_vencto
--					into v_fecha_vencido
--					from bdicred:sd_maecredanexocrd 
--					where num_credito=vcredito;
					
					
				IF vproducto='6800' THEN
					SELECT MAX(fecha_insert) INTO dUltima_Disposicion
					FROM sd_maecredcrd_flex
					where num_credito=vcredito;
				ELSE
					SELECT fecha_apertura INTO dUltima_Disposicion
					FROM sd_maecredcrd WHERE num_credito=vcredito;
				END IF;

--  				***************    cambio jahj Julio 2023 recuperamos el dato en la consulta principal
--					SELECT ejecutivo INTO v_ejecutivo
--					FROM sd_maecredcrd
--					WHERE num_credito=vcredito;


                BEGIN;
                INSERT INTO bdicred:"informix".sd_sdos_cartera_linea 
                    (fecha,numcte,num_credito,num_tarjeta,num_cta,num_producto,sdo_capital,monto_vencido,mto_venc_trasp,cap_tras_no_venci,
                    sdo_cap_insoluto,monto_financiado,moratorio,interes_iva,mto_fin_ven_trasp,status_cred,fecha_ult_pago,pago_una_mora,
                    sucursal,fecha_apertura,monto_otorgado,tasa_interes,prox_fecha_pago,cat,saldovencido1, saldovencido2, saldovencido3, 
                    saldovencido4, saldovencido5, saldovencido6, interesmoratorio1, interesmoratorio2, interesmoratorio3, interesmoratorio4, 
                    interesmoratorio5, interesmoratorio6, sdo_intereses, mensualidad_actual, grupo, antiguedad, bcscore, scoreprop, ficoscore,
					bhscore, novencidos1, novencidos2, novencidos3, novencidos4, novencidos5, novencidos6, celular, iva_int_trasp, sdo_retenido,
					dias_vencido, atr, act, fecha_vencido, fecha_ult_dispo, ejecutivo)
                    VALUES(dFecha_hoy, vcliente, vcredito, vtarjeta, vcta_eje, vproducto, vsdo_capital, vmonto_vencido, vmtovenctrasp, 
                    vcaptrasnovenci, vsdocapinsoluto, montofinanciado, vsdomoratorio, vinteresiva, vmoras, vstatuscred, vfechaultpago, 
                    pagounamora, vsucursal, vfch_apertura, vmontootorgado, vtasainteres, vproxfchpago, vcat, cSaldovencido1, cSaldovencido2, 
                    cSaldovencido3, cSaldovencido4, cSaldovencido5, cSaldovencido6, cInteresmoratorio1, cInteresmoratorio2, cInteresmoratorio3,  
                    cInteresmoratorio4, cInteresmoratorio5, cInteresmoratorio6, vsdo_intereses, vmensualidad_act, vgrupo, vantiguedad, vbcscore,
					vscoreprop, vficoscore, vbhscore, vnovencidos1, vnovencidos2, vnovencidos3, vnovencidos4, vnovencidos5, vnovencidos6, vcelular,
					vivatrasp, vretenido, v_dias_vencido, cAtr, 0, v_fecha_vencido, dUltima_Disposicion,v_ejecutivo);
                COMMIT;
					
				LET v_cuenta_bloque = v_cuenta_bloque+1;
				
				IF v_cuenta_bloque = 30000 THEN 
				   CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, '  Cuenta bloque PLAZO', '02') RETURNING cCod_retBit;   
				   LET v_cuenta_bloque = 0;
				END IF;	
					
            END IF;
			
        END FOREACH;     


		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, 'Paso 5: Termina Foreach Obtener info PLAZO monto,saldos,etc', '02') RETURNING cCod_retBit;  
		
        DROP TABLE bdicred:tmp_creditos_crd;

    LET cCod_Ret = '00000';
    LET cMensajeRet = 'PROCESO CONCLUIDO';
    
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, 'FINALIZA sp_genera_carteraenlinea_tab', '02') RETURNING cCod_retBit;       
    RETURN cCod_ret,cMensajeRet;

END;
END PROCEDURE;
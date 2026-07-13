CREATE PROCEDURE "informix".sp_proyecta_credisoluciones(
pSucursal 		CHAR(4),
pNumPromocion 	SMALLINT, -- 1-efectivo, 2-compras, 3-saldos
pSaldoDisp		DECIMAL(18,2),
pMonto 			DECIMAL(18,2),
pPlazo 			SMALLINT
)

RETURNING  CHAR(6)         AS Codigo, 		  -- CODIGO DE RETORNO
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
'DESCRIPCION: Realiza el desglose de la proyección para credisoluciones ',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 15/Octubre/2013',
'BD    : BDICRED',
'Version: 20131015.1614';

CREATE PROCEDURE "informix".sp_obt_cant_pagos_diferidos(pCuenta CHAR(20),pMes INTEGER, pAnio INTEGER)
	RETURNING CHAR(5), INTEGER;
-- Realizó   : Moisés Soriano Guerrero
-- Actividad : Obetener cantidad de pagos diferidos
-- Solicitó  : Alejandro Vazquez
-- Fecha     :  13/07/2015
DEFINE vcodret   	CHAR(5);
DEFINE vCantidad  	INTEGER;
DEFINE sql_err      INTEGER;
LET vcodret = '000';
LET vCantidad = 0;
BEGIN
	ON EXCEPTION SET sql_err
		   IF sql_err <> 0 THEN
			LET vcodret = sql_err;
			RETURN vcodret, vCantidad;
		   END IF;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
    SELECT COUNT(num_credito) AS cantidad
    INTO vCantidad
    FROM bdicred@pld_tcp:"informix".sd_detalle_dif_edocta
    WHERE num_credito = pCuenta
    AND MONTH(fecha_emision) = pMes
    AND YEAR(fecha_emision) = pAnio;
    RETURN vcodret, vCantidad;
END;
END PROCEDURE;
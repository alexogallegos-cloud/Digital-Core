CREATE PROCEDURE "informix".sp_adn_calculalinea(pEmpresa CHAR(3), pNumCte CHAR(20), pCuenta CHAR(20))
RETURNING	CHAR(6)		AS codigo_retorno,
		    SMALLINT	AS FlagValida, -- [0:malo; 1:bueno]
		    MONEY(14,2)	AS Monto;
		    
DEFINE cCodRet				CHAR(6);
DEFINE iSqlErr				INTEGER;
DEFINE iSamErr				INTEGER;
DEFINE cErrorInfo			VARCHAR(80,1);

DEFINE cCuenta				CHAR(20);
DEFINE iValida				INTEGER;
DEFINE iContador			INTEGER;
DEFINE dFechaAlta			DATE;
DEFINE dPorcentaje			DECIMAL(18,2);
DEFINE dMontoMin			DECIMAL(18,2);
DEFINE dMontoMax			DECIMAL(18,2);
DEFINE dLinea				DECIMAL(18,2);
DEFINE iFrecuenciaPago		INTEGER;
DEFINE dtFechaHoy			DATE;

DEFINE nMeses				INTEGER;
DEFINE cProducto			CHAR(4);
-- DEFINE fMov					CHAR(10);
-- DEFINE nMov					CHAR(10);
-- DEFINE iSecuenciaMonto		INTEGER;
-- DEFINE iSecuenciaPorc		INTEGER;

-- RQM 09 654
DEFINE vCodRet              CHAR(6);
DEFINE vSegmento            CHAR(3);
DEFINE dIngresoMin          INTEGER;
DEFINE dIngresoCte          DECIMAL(18,2);

LET cCodRet			= "000000";
LET iSqlErr			= 0;
LET iSamErr			= 0;
LET cErrorInfo		= "";

LET cCuenta			= "";
LET iContador		= 0;
LET iValida			= 0;
LET dFechaAlta		= DATE(1);
LET dPorcentaje		= 0;
LET dMontoMin		= 0;
LET dMontoMax		= 0;
LET dLinea			= 0;
LET iFrecuenciaPago	= 0;
LET nMeses			= 0;
LET dtFechaHoy		= DATE(1);

LET cProducto		= "";
--LET fMov			= "";
--LET nMov			= "";
--LET iSecuenciaMonto = 0;
--LET iSecuenciaPorc 	= 0;

-- RQM 09 654
LET vCodRet         = "000000";
LET vSegmento       = "";
LET dIngresoMin     = 0;
LET dIngresoCte     = 0;

BEGIN
ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
IF iSqlErr != 0 THEN
	LET cCodRet = iSqlErr::CHAR(8);
	RETURN NVL(cCodRet, ''), 0, 0;
END IF;
END EXCEPTION; 	

  --SET DEBUG FILE TO "/home/e90317801/jlopez/sp_adn_calculalinea" || pCuenta || ".out";
  --TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	IF TRIM(NVL(pEmpresa, "")) = "" OR TRIM(NVL(pNumCte, "")) = "" OR TRIM(NVL(pCuenta, "")) = "" THEN
		LET cCodRet = "000001";
		RETURN NVL(cCodRet, ''), iValida, dLinea;
	END IF;

	SELECT fecha_hoy
	INTO dtFechaHoy
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = pEmpresa;
	
	FOREACH WITH HOLD
		SELECT mae.cuenta, noc.fecha_alta, mae.producto
		INTO cCuenta, dFechaAlta, cProducto
		FROM bdicheq:"informix".sc_maechq mae
		INNER JOIN bdicheq:"informix".sc_maenoc noc ON mae.empresa = noc.empresa AND mae.cuenta = noc.cuenta
		WHERE mae.empresa = pEmpresa
        AND mae.num_cte = pNumcte
		AND mae.cuenta = pCuenta

			IF NOT EXISTS (SELECT 1 FROM "informix".ss_producto_credcap WHERE empresa = pEmpresa AND num_producto = '7800' AND producto_cap = cProducto) THEN
				CONTINUE FOREACH;
			END IF;
					
			SELECT valor
			INTO dMontoMin
			FROM "informix".ss_param
			WHERE empresa = pEmpresa
			AND secuencia = 412;
	
			SELECT valor
			INTO dIngresoMin
			FROM bdisolic:ss_param
			WHERE empresa = '001'
			AND secuencia = 383;
		
			LET dPorcentaje = 0;
		
			-- Calcula cantidad de meses a partir de la fecha de alta de la cuenta
			EXECUTE PROCEDURE bdisolic:monthsdiff(dtFechaHoy, dFechaAlta) INTO nMeses;
			
			-- IF nMeses >= 4 THEN
			-- 	-- Cantidad de movimientos en los ultimos 90 dias
			-- 	SELECT COUNT (*)
			-- 	INTO iFrecuenciaPago
			-- 	FROM
			-- 		(SELECT num_serial
			-- 		 FROM bdicheq:"informix".sc_movhis mh
			-- 		 WHERE mh.cuenta = cCuenta
			-- 		 AND mh.transacc IN ('0293', '0287')
			-- 		 AND mh.fech_alt >= dtFechaHoy - 90
			-- 		 AND mh.empresa = pEmpresa
			-- 		 AND mh.cancelad <> 'S'
			-- 		 UNION
			-- 		 SELECT num_serial
			-- 		 FROM bdicheq:"informix".sc_movhis mh
			-- 		 WHERE mh.cuenta = cCuenta
			-- 		 AND mh.transacc IN ('0273', '0274')
			-- 		 AND mh.referencia LIKE ('%NNNN%')
			-- 		 AND mh.fech_alt >= dtFechaHoy - 90
			-- 		 AND mh.empresa = pEmpresa
			-- 		 AND mh.cancelad <> 'S'
			-- 		 UNION
			-- 		 SELECT num_serial
			-- 		 FROM bdicheq:"informix".sc_movhis_old mh
			-- 		 WHERE mh.cuenta = cCuenta
			-- 		 AND mh.transacc IN ('0293', '0287')
			-- 		 AND mh.fech_alt >= dtFechaHoy - 90
			-- 		 AND mh.empresa = pEmpresa
			-- 		 AND mh.cancelad <> 'S'
			-- 		 UNION
			-- 		 SELECT num_serial
			-- 		 FROM bdicheq:"informix".sc_movhis_old mh
			-- 		 WHERE mh.cuenta = cCuenta
			-- 		 AND mh.transacc IN ('0273', '0274')
			-- 		 AND mh.referencia LIKE ('%NNNN%')
			-- 		 AND mh.fech_alt >= dtFechaHoy - 90
			-- 		 AND mh.empresa = pEmpresa
			-- 		 AND mh.cancelad <> 'S');
		
			-- ELIF nMeses <= 3 THEN
			-- 	-- Cantidad de movimientos en los ultimos 31 dias
			-- 	SELECT COUNT (*)
			-- 	INTO iFrecuenciaPago
			-- 	FROM
			-- 		(SELECT num_serial
			-- 		 FROM bdicheq:"informix".sc_movhis mh
			-- 		 WHERE mh.cuenta = cCuenta
			-- 		 AND mh.transacc IN ('0293', '0287')
			-- 		 AND mh.fech_alt >= dtFechaHoy - 31
			-- 		 AND mh.empresa = pEmpresa
			-- 		 AND mh.cancelad <> 'S'
			-- 		 UNION
			-- 		 SELECT num_serial
			-- 		 FROM bdicheq:"informix".sc_movhis mh
			-- 		 WHERE mh.cuenta = cCuenta
			-- 		 AND mh.transacc IN ('0273', '0274')
			-- 		 AND mh.referencia LIKE ('%NNNN%')
			-- 		 AND mh.fech_alt >= dtFechaHoy - 31
			-- 		 AND mh.empresa = pEmpresa
			-- 		 AND mh.cancelad <> 'S'
			-- 		 UNION
			-- 		 SELECT num_serial
			-- 		 FROM bdicheq:"informix".sc_movhis_old mh
			-- 		 WHERE mh.cuenta = cCuenta
			-- 		 AND mh.transacc IN ('0293', '0287')
			-- 		 AND mh.fech_alt >= dtFechaHoy - 31
			-- 		 AND mh.empresa = pEmpresa
			-- 		 AND mh.cancelad <> 'S'
			-- 		 UNION
			-- 		 SELECT num_serial
			-- 		 FROM bdicheq:"informix".sc_movhis_old mh
			-- 		 WHERE mh.cuenta = cCuenta
			-- 		 AND mh.transacc IN ('0273', '0274')
			-- 		 AND mh.referencia LIKE ('%NNNN%')
			-- 		 AND mh.fech_alt >= dtFechaHoy - 31
			-- 		 AND mh.empresa = pEmpresa
			-- 		 AND mh.cancelad <> 'S');
				
			-- END IF
			
			-- IF (iFrecuenciaPago >= 1 AND nMeses <= 3 AND cProducto = "1300") OR (iFrecuenciaPago > 0 AND iFrecuenciaPago <= 2 AND nMeses >= 4) THEN
				
			-- 	SELECT valor
			-- 	INTO dMontoMax
			-- 	FROM "informix".ss_param
			-- 	WHERE empresa = pEmpresa
			-- 	AND secuencia = 404;

			-- 	SELECT valor
			-- 	INTO dPorcentaje
			-- 	FROM "informix".ss_param
			-- 	WHERE empresa = pEmpresa
			-- 	AND secuencia = 405;

				
			-- ELIF iFrecuenciaPago >= 3 AND nMeses >= 4 THEN

			-- 	IF nMeses >= 4 AND nMeses <= 8 THEN
			-- 		IF cProducto = "1300" THEN
			-- 			LET iSecuenciaMonto = 406;
			-- 			LET iSecuenciaPorc = 407;
			-- 		ELSE
			-- 			LET iSecuenciaMonto = 404;
			-- 			LET iSecuenciaPorc = 405;
			-- 		END IF;
			-- 	ELIF nMeses >= 9 AND nMeses <= 11 THEN
			-- 		IF cProducto = "1300" THEN
			-- 			LET iSecuenciaMonto = 408;
			-- 			LET iSecuenciaPorc = 409;
			-- 		ELSE
			-- 			LET iSecuenciaMonto = 406;
			-- 			LET iSecuenciaPorc = 407;
			-- 		END IF;
			-- 	ELIF nMeses >= 12 THEN
			-- 		IF cProducto = "1300" THEN
			-- 			LET iSecuenciaMonto = 410;
			-- 			LET iSecuenciaPorc = 411;
			-- 		ELSE
			-- 			LET iSecuenciaMonto = 408;
			-- 			LET iSecuenciaPorc = 409;
			-- 		END IF;
			-- 	END IF; 

			-- 	SELECT valor
			-- 	INTO dMontoMax
			-- 	FROM "informix".ss_param
			-- 	WHERE empresa = pEmpresa
			-- 	AND secuencia = iSecuenciaMonto;

			-- 	SELECT valor
			-- 	INTO dPorcentaje
			-- 	FROM "informix".ss_param
			-- 	WHERE empresa = pEmpresa
			-- 	AND secuencia = iSecuenciaPorc;

			-- END IF;
		
			-- SELECT MAX(mov.fech_alt), MAX(mov.num_serial)
			-- INTO fMov, nMov
			-- FROM bdicheq:"informix".sc_movdia mov
			-- INNER JOIN bdicred:"informix".sd_transvalprod tran ON tran.transacc = mov.transacc AND tran.num_producto = '7800'
			-- WHERE mov.cuenta = cCuenta
			-- AND mov.empresa = pEmpresa
			-- AND mov.cancelad <> 'S'
			-- AND ((tran.activo = 2 AND tran.transacc NOT IN ('0273', '0274')) OR ((tran.transacc = '0274' AND mov.referencia LIKE ('%NNNN%')) OR (tran.transacc = '0273' AND mov.referencia LIKE ('%NNNN%'))));
			
			-- SELECT NVL(monto_tot, 0)
			-- INTO dLinea
			-- FROM bdicheq:"informix".sc_movdia mov
			-- INNER JOIN bdicred:"informix".sd_transvalprod tran ON tran.transacc = mov.transacc AND tran.num_producto = '7800'
			-- WHERE mov.cuenta = cCuenta
			-- AND mov.empresa = pEmpresa
			-- AND tran.activo = 2
			-- AND mov.cancelad <> 'S'
			-- AND mov.fech_alt = fMov
			-- AND mov.num_serial = nMov;
			
			-- IF NVL(dLinea, 0) = 0 THEN
			-- 	SELECT MAX(mov.fech_alt)
			-- 	INTO fMov
			-- 	FROM bdicheq:"informix".sc_movhis mov
			-- 	INNER JOIN bdicred:"informix".sd_transvalprod tran ON tran.transacc = mov.transacc AND tran.num_producto = '7800'
			-- 	WHERE mov.cuenta = cCuenta
			-- 	AND mov.empresa = pEmpresa
			-- 	AND mov.cancelad <> 'S'
			-- 	AND ((tran.activo = 2 AND tran.transacc NOT IN ('0273', '0274')) OR ((tran.transacc = '0274' AND mov.referencia LIKE ('%NNNN%')) OR (tran.transacc = '0273' AND mov.referencia LIKE ('%NNNN%'))));
				
			-- 	SELECT MAX(NVL(monto_tot,0))
			-- 	INTO dLinea
			-- 	FROM bdicheq:"informix".sc_movhis mov
			-- 	INNER JOIN bdicred:"informix".sd_transvalprod tran ON tran.transacc = mov.transacc AND tran.num_producto = '7800'
			-- 	WHERE mov.cuenta = cCuenta
			-- 	AND mov.empresa = pEmpresa
			-- 	AND mov.cancelad <> 'S'
			-- 	AND mov.fech_alt = fMov
			-- 	AND ((tran.activo = 2 AND tran.transacc NOT IN ('0273', '0274')) OR ((tran.transacc = '0274' AND mov.referencia LIKE ('%NNNN%')) OR (tran.transacc = '0273' AND mov.referencia LIKE ('%NNNN%'))));
				
			-- END IF;
		
			-- IF NVL(dLinea, 0) = 0 THEN
			-- 	SELECT MAX(mov.fech_alt)
			-- 	INTO fMov
			-- 	FROM bdicheq:"informix".sc_movhis_old mov
			-- 	INNER JOIN bdicred:"informix".sd_transvalprod tran ON tran.transacc = mov.transacc AND tran.num_producto = '7800'
			-- 	WHERE mov.cuenta = cCuenta
			-- 	AND mov.empresa = pEmpresa
			-- 	AND mov.cancelad <> 'S' 
			-- 	AND ((tran.activo = 2 AND tran.transacc NOT IN ('0273', '0274')) OR ((tran.transacc = '0274' AND mov.referencia LIKE ('%NNNN%')) OR (tran.transacc = '0273' AND mov.referencia LIKE ('%NNNN%'))));
				
			-- 	SELECT MAX(NVL(monto_tot, 0))
			-- 	INTO dLinea
			-- 	FROM bdicheq:"informix".sc_movhis_old mov
			-- 	INNER JOIN bdicred:"informix".sd_transvalprod tran ON tran.transacc = mov.transacc AND tran.num_producto = '7800'
			-- 	WHERE mov.cuenta = cCuenta
			-- 	AND mov.empresa = pEmpresa
			-- 	AND mov.cancelad <> 'S'
			-- 	AND mov.fech_alt = fMov
			-- 	AND ((tran.activo = 2 AND tran.transacc NOT IN ('0273', '0274')) OR ((tran.transacc = '0274' AND mov.referencia LIKE ('%NNNN%')) OR (tran.transacc = '0273' AND mov.referencia LIKE ('%NNNN%'))));
				
			-- END IF;
			
			--RQM 09 654
			IF nMeses >= 3 THEN
				--?cantidad de movimientos en los ultimos 3 meses
				LET iFrecuenciaPago = 2;

			ELIF nMeses <= 2 THEN
				--?cantidad de movimientos en el utimo mes
				LET iFrecuenciaPago = 0; 
			END IF;
		
			EXECUTE PROCEDURE bdisolic:"informix".sp_adn_evalua_ing(cCuenta, iFrecuenciaPago)
			INTO vCodRet,vSegmento,dIngresoCte, iFrecuenciaPago;
		
			IF NVL(vCodRet,'') != '000000' OR iFrecuenciaPago = 0 OR dIngresoCte < dIngresoMin THEN
				RETURN '000003', iValida, dLinea;
			END IF;
		
			IF iFrecuenciaPago >= 1 AND nMeses IN (1,2) THEN
				SELECT porc_max_disp, monto_maximo
				INTO dPorcentaje, dMontoMax
				FROM bdisolic:"informix".ss_adn_factores_calcred
				WHERE segmento = vSegmento
				AND nMeses BETWEEN antiguedad_min AND antiguedad_max;
			
			ELIF iFrecuenciaPago >= 3 THEN
				SELECT porc_max_disp, monto_maximo
				INTO dPorcentaje, dMontoMax
				FROM bdisolic:"informix".ss_adn_factores_calcred
				WHERE segmento = vSegmento
				AND nMeses BETWEEN antiguedad_min AND antiguedad_max;
				
			ELSE
				RETURN '000004', iValida, dLinea;
				
			END IF; 
			--RQM 09 654
		
		LET dLinea = ROUND((NVL(dIngresoCte, 0) * (dPorcentaje/100)), -2);
		
		IF NVL(dLinea, 0) = 0 OR NVL(dLinea, 0) < dMontoMin THEN -- RQI 27 102
			LET iValida = 0; -- Invalido; no procede para ADN
			LET dLinea = 0;
		END IF;
		
		IF NVL(dLinea, 0) > dMontoMax THEN -- Se topa la linea
			LET dLinea = dMontoMax;
		END IF;
		
		IF NVL(dLinea, 0) > 0 THEN
			LET iValida = 1; -- Cuenta valida
			RETURN NVL(cCodRet, ''), iValida, NVL(dLinea, 0);
		END IF;

		LET iContador = 1;
		
	END FOREACH;
	
	IF iContador = 0 THEN 
		RETURN '000002',iValida ,NVL(dLinea,0) ;
	END IF;
    
    RETURN NVL(cCodRet, ''), iValida, NVL(dLinea, 0);
    
END
END PROCEDURE

CREATE PROCEDURE "informix".sp_migracion_cuentas(tProcreso INTEGER)

RETURNING CHAR(6) AS codigo_retorno;

DEFINE cCodRet CHAR(6);

DEFINE --fechaAlta,
       fechaApertura,
	   --newPDate,
	   V_FECHA_APERT DATE;

DEFINE nCliente,
	   cCuenta,
	   eCuenta,
	   P_SOLICITUD VARCHAR(20);

DEFINE nMeses,
	   iFrecuenciaPago,
	   iSqlErr INTEGER;

DEFINE dPorcentaje,
	   dMontoAnterior,
       dMontoMax,
	   dMontoMin,
	   dLinea DECIMAL(18,2);

DEFINE cProducto,
       VV_SUCURSAL CHAR(4);

DEFINE VV_FOLIO CHAR(16);

DEFINE pEmpresa CHAR(3);

DEFINE VV_DIVISA CHAR(2);

DEFINE P_MENSAJE VARCHAR(80);

DEFINE dtFechaHoy	DATE;
DEFINE dSegmento    CHAR(3);
DEFINE dIngresoMin  INTEGER;
DEFINE dPeriodo     DATE;

LET cCodRet	= "00000";
LET P_MENSAJE = 'PROCESO EXITOSO';

--LET fechaAlta = DATE(1);
LET fechaApertura = DATE(1);
--LET newPDate = DATE(1);
LET V_FECHA_APERT = DATE(1);

LET nCliente = "";
LET cCuenta = "";
LET eCuenta = "";
LET cProducto = "";
LET nMeses = 0;
LET iFrecuenciaPago = 0;

LET dPorcentaje = 0;
LET dMontoAnterior = 0;
LET dMontoMax = 0;
LET dMontoMin = 0;
LET dLinea = 0;

LET iSqlErr	= 0;

LET VV_SUCURSAL = "";
LET VV_FOLIO = "";
LET P_SOLICITUD = "";
LET pEmpresa = "";
LET VV_DIVISA = "";

LET dtFechaHoy  = DATE(1);
LET dSegmento   = "";
LET dIngresoMin = 0;
LET dPeriodo    = DATE(1);


BEGIN
ON EXCEPTION SET iSqlErr
	DROP TABLE IF EXISTS cuentas_por_migrar;

	IF iSqlErr != 0 THEN
		LET cCodRet = iSqlErr::CHAR(8);
		RETURN NVL(cCodRet,'');
	END IF;
END EXCEPTION;

--    SET DEBUG FILE TO '/informix/OscarOjeda/Sps/sp_migracion_cuentas.out';
--    TRACE ON;

    SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	SELECT fecha_hoy
	INTO dtFechaHoy
	FROM bdicred:"informix".sd_fechas
	WHERE empresa ='001';
	
	SELECT  MAX(periodo)
    INTO    dPeriodo
    FROM    bdicheq:"informix".sc_bitacora_movnom
    WHERE   id_proceso = 'ingajustado'
    AND     fechahora_fin IS NOT NULL;

	SELECT valor
	INTO dMontoMin
	FROM bdisolic:"informix".ss_param
	WHERE empresa = '001'
	AND secuencia = 412;

	SELECT valor
	INTO dIngresoMin
	FROM bdisolic:"informix".ss_param
	WHERE empresa = '001'
	AND secuencia = 383;

	IF (tProcreso = 1) THEN

		--?Se optimizo el query para reducir costos.? --?INC 27 227?
		SELECT mr.fecha_apertura, mc.empresa, mc.num_cte, mc.cuenta, so.num_solicitud, mr.divisa, mr.sucursal, mc.producto, so.linea AS monto_anterior, mr.status_cred
        FROM bdisolic:"informix".ss_adn_solicitudcuenta so
        INNER JOIN bdicheq:"informix".sc_maechq mc ON so.cuenta_nomina = mc.cuenta
        --INNER JOIN bdicheq:"informix".sc_maenoc mn ON mc.empresa = mn.empresa AND mc.cuenta = mn.cuenta
        INNER JOIN bdicred:"informix".sd_maecred mr ON mr.empresa = so.empresa AND mr.num_credito = so.num_solicitud AND mr.num_producto ='7800'
        INNER JOIN  bdicheq:"informix".sc_nom_disp_cte nom ON nom.cuenta = so.cuenta_nomina AND nom.fecha_pago = dPeriodo
        WHERE mc.empresa = '001' AND mc.status_cta = 1
        --AND mc.producto IN ('1300','1700','1400','1900','2000')
        AND  mc.num_cte NOT IN (SELECT num_cte FROM bdisolic:"informix".ss_nuevas_politicas_disposicion  WHERE cuenta = mc.cuenta)
		INTO TEMP cuentas_por_migrar WITH NO LOG;

		CREATE INDEX "informix".idx_cuentas_por_migrar
        ON "informix".cuentas_por_migrar(status_cred); --IN datos04 ONLINE;
	
		FOREACH SELECT fecha_apertura, empresa, num_cte, cuenta,  num_solicitud, divisa, sucursal, producto, monto_anterior
				INTO fechaApertura, pEmpresa, nCliente, cCuenta, P_SOLICITUD, VV_DIVISA, VV_SUCURSAL, cProducto, dMontoAnterior
				FROM cuentas_por_migrar
				WHERE status_cred IN ('AA','BA','BT','E1','E2','E3')

						EXECUTE PROCEDURE bdisolic:"informix".monthsdiff(dtFechaHoy, fechaApertura)
						INTO nMeses;
						
						IF nMeses < 12 THEN
							CONTINUE FOREACH;
						END IF;
						
						LET iFrecuenciaPago = 2;

						EXECUTE PROCEDURE bdisolic:"informix".sp_adn_evalua_ing(cCuenta, iFrecuenciaPago)
						INTO cCodRet,dSegmento,dLinea, iFrecuenciaPago;
						
						IF NVL(cCodRet,'') != '000000' OR iFrecuenciaPago = 0 OR dLinea < dIngresoMin THEN
							CONTINUE FOREACH;
						END IF;
						
						IF iFrecuenciaPago >= 3 THEN
							SELECT porc_max_disp, monto_maximo
							INTO dPorcentaje, dMontoMax
							FROM bdisolic:"informix".ss_adn_factores_calcred
							WHERE segmento = dSegmento
							AND nMeses BETWEEN antiguedad_min AND antiguedad_max;
							
						ELSE
							CONTINUE FOREACH;
						END IF; 

						LET dLinea = ROUND((NVL(dLinea,0) *  (dPorcentaje/100)),-2);
			
			            IF NVL(dLinea,0) >  dMontoMax THEN --SE TOPA LA LINEA
			                    LET dLinea = dMontoMax;
			            END IF;
			
			            IF NVL(dLinea,0) != 0 AND NVL(dLinea,0) > dMontoMin AND NVL(dLinea,0) > dMontoAnterior THEN
		
							UPDATE bdisolic:"informix".ss_adn_solicitudcuenta SET linea = dLinea
							WHERE num_solicitud = P_SOLICITUD;

							UPDATE bdicred:"informix".sd_maesdos SET monto_otorgado = dLinea
							WHERE num_credito = P_SOLICITUD;
		
							SELECT fecha_hoy, USER
								|| REPLACE(REPLACE(CURRENT HOUR TO FRACTION,':',''),'.','') FOLIO
							INTO V_FECHA_APERT, VV_FOLIO
							FROM bdicred:"informix".sd_fechas
							WHERE empresa = pEmpresa;

							--?Se corrige producto para el movimiento de anticipo de nÃ³mina. --?INC 27 227
							--?Se corrige codigo del campo p_codigo_fun por '008' de incremento de linea de credito --?INC 27 232
							EXECUTE PROCEDURE bdicred:"informix".GENMOV(pEmpresa, P_SOLICITUD,
															"7800", 1,
															"008", V_FECHA_APERT,
															dLinea, VV_FOLIO,
															VV_SUCURSAL, VV_DIVISA,
															"0000")
							INTO cCodRet, P_MENSAJE;
							
							IF cCodRet != "00000" THEN
								UPDATE  bdisolic:"informix".ss_adn_solicitudcuenta SET linea = dMontoAnterior
								WHERE numcte = nCliente 
								AND cuenta_nomina = cCuenta;	
		
								UPDATE bdicred:"informix".sd_maesdos SET monto_otorgado = dMontoAnterior
								WHERE num_credito = P_SOLICITUD;
							
								RAISE EXCEPTION cCodRet, 0;
							END IF;
						
							INSERT INTO bdisolic:"informix".ss_nuevas_politicas_disposicion(num_cte, cuenta, fch_insrt) values(nCliente, cCuenta, TODAY);

						END IF;
		
		END FOREACH;

	ELIF (tProcreso = 2) THEN

		--?Se optimizo el query para reducir costos. --?INC 27 227
	 	SELECT  mr.fecha_apertura, 
				mc.empresa, 
				mc.num_cte, 
				mc.cuenta, 
				so.num_solicitud, 
				mr.divisa, 
				mr.sucursal, 
				mc.producto, 
				so.linea AS monto_anterior, 
				mr.status_cred
        FROM 		bdisolic:"informix".ss_adn_solicitudcuenta so
        INNER JOIN 	bdicheq:"informix".sc_maechq mc ON so.cuenta_nomina = mc.cuenta
        --INNER JOIN 	bdicheq:"informix".sc_maenoc mn ON mc.empresa = mn.empresa AND mc.cuenta = mn.cuenta
        INNER JOIN 	bdicred:"informix".sd_maecred mr ON mr.empresa = so.empresa AND mr.num_credito = so.num_solicitud AND mr.num_producto = '7800'
        INNER JOIN  bdicheq:"informix".sc_nom_disp_cte nom ON nom.cuenta = so.cuenta_nomina AND nom.fecha_pago = dPeriodo
		WHERE mc.status_cta = 1
		--AND 	mc.producto IN ('1300','1700','1400','1900','2000')
		AND   (DAY(dtFechaHoy) - DAY(mr.fecha_apertura)) = 0
		INTO  TEMP cuentas_por_migrar WITH NO LOG;

		CREATE INDEX "informix".idx_cuentas_por_migrar
        ON "informix".cuentas_por_migrar(status_cred); --IN datos04 ONLINE;
	
		FOREACH SELECT fecha_apertura, empresa, num_cte, cuenta,  num_solicitud, divisa, sucursal, producto, monto_anterior
				INTO fechaApertura, pEmpresa, nCliente, cCuenta, P_SOLICITUD, VV_DIVISA, VV_SUCURSAL, cProducto, dMontoAnterior
				FROM cuentas_por_migrar
				WHERE status_cred IN ('AA','BA','BT','E1','E2','E3')

						EXECUTE PROCEDURE bdisolic:"informix".monthsdiff(dtFechaHoy, fechaApertura)
						INTO nMeses;
					
						IF nMeses >= 3 THEN
							--?cantidad de movimientos en los ultimos 3 meses
							LET iFrecuenciaPago = 2;
				
						ELIF nMeses <= 2 THEN
							--?cantidad de movimientos en el utimo mes
							LET iFrecuenciaPago = 0; 
						END IF;
						
						EXECUTE PROCEDURE bdisolic:"informix".sp_adn_evalua_ing(cCuenta, iFrecuenciaPago)
						INTO cCodRet,dSegmento,dLinea, iFrecuenciaPago;
						
						IF NVL(cCodRet,'') != '000000' OR iFrecuenciaPago = 0 OR dLinea < dIngresoMin THEN
							CONTINUE FOREACH;
						END IF;
						
						IF iFrecuenciaPago >= 1 AND nMeses IN (1,2) THEN
							SELECT porc_max_disp, monto_maximo
							INTO dPorcentaje, dMontoMax
							FROM bdisolic:"informix".ss_adn_factores_calcred
							WHERE segmento = dSegmento
							AND nMeses BETWEEN antiguedad_min AND antiguedad_max;
						
						ELIF iFrecuenciaPago >= 3 THEN
							SELECT porc_max_disp, monto_maximo
							INTO dPorcentaje, dMontoMax
							FROM bdisolic:"informix".ss_adn_factores_calcred
							WHERE segmento = dSegmento
							AND nMeses BETWEEN antiguedad_min AND antiguedad_max;
							
						ELSE
							CONTINUE FOREACH;
						END IF; 
						
						LET dLinea = ROUND((NVL(dLinea,0) *  (dPorcentaje/100)),-2);

						IF NVL(dLinea,0) >  dMontoMax THEN --SE TOPA LA LINEA
							LET dLinea = dMontoMax;
						END IF;

                    	IF NVL(dLinea,0) != 0 AND NVL(dLinea,0) > dMontoMin AND NVL(dLinea,0) > dMontoAnterior THEN

							SELECT cuenta
							INTO eCuenta
							FROM bdisolic:"informix".ss_nuevas_politicas_disposicion
							WHERE num_cte = nCliente AND cuenta = cCuenta;

							IF NVL(eCuenta,"") = "" AND nMeses >= 12 THEN
								INSERT INTO bdisolic:ss_nuevas_politicas_disposicion(num_cte, cuenta, fch_insrt) values(nCliente, cCuenta, TODAY);
							END IF;

							UPDATE bdisolic:"informix".ss_adn_solicitudcuenta SET linea = dLinea
							WHERE num_solicitud = P_SOLICITUD;

							UPDATE bdicred:"informix".sd_maesdos SET monto_otorgado = dLinea
							WHERE num_credito = P_SOLICITUD;

							SELECT fecha_hoy, USER
								|| REPLACE(REPLACE(CURRENT HOUR TO FRACTION,':',''),'.','') FOLIO
							INTO V_FECHA_APERT, VV_FOLIO
							FROM bdicred:"informix".sd_fechas
							WHERE empresa = pEmpresa;

							--?Se corrige producto para el movimiento de anticipo de nÃ³mina. --?INC 27 227
							--?Se corrige codigo del campo p_codigo_fun por '008' de incremento de linea de credito --?INC 27 232
							EXECUTE PROCEDURE bdicred:"informix".GENMOV(pEmpresa, P_SOLICITUD,
															"7800", 1,
															"008", V_FECHA_APERT,
															dLinea, VV_FOLIO,
															VV_SUCURSAL, VV_DIVISA,
															"0000")
							INTO cCodRet, P_MENSAJE;
							
							IF cCodRet != "00000" THEN
								UPDATE  bdisolic:"informix".ss_adn_solicitudcuenta SET linea = dMontoAnterior
								WHERE numcte = nCliente 
								AND cuenta_nomina = cCuenta;	
	
								UPDATE bdicred:"informix".sd_maesdos SET monto_otorgado = dMontoAnterior
								WHERE num_credito = P_SOLICITUD;
							
								RAISE EXCEPTION cCodRet, 0;
							END IF;
							
						END IF;
		END FOREACH;

	END IF;

	DROP TABLE cuentas_por_migrar;

	RETURN NVL(cCodRet,'');

END
END PROCEDURE

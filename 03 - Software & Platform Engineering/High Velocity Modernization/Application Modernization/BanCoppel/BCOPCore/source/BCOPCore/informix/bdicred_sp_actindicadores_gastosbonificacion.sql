CREATE PROCEDURE "informix".sp_actindicadores_gastosbonificacion(pEmpresa CHAR(3), pNumCredito CHAR(20), pDiaCorte SMALLINT, pMonto DECIMAL(18,2), 
		pFecha DATE, pFechaProxAnualidad DATE, pAplicaBoniAnual CHAR(1), pBanderaReverso CHAR(1))
	RETURNING CHAR(5);   

---------------------------------------------------------------------------
--                         DEFINICION DE VARIABLES
---------------------------------------------------------------------------

--JRVT CAMBIOS BONIFICACION 29/10/2024
--DEFINE cNumProducto			CHAR(4);
DEFINE cMesAnterior			CHAR(1);
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE cCod_ret				CHAR(5);
DEFINE sAnioRegistro		SMALLINT;
DEFINE sCountReg			SMALLINT;
DEFINE dFechaCorte			DATE;
DEFINE sAnioRegistroAux		SMALLINT;


--LET cNumProducto			= '';
LET sCountReg			    = 0;
LET cMesAnterior			= '0';
LET cCod_ret      			= '00000';
LET sql_err       			= 0;
LET isam_err      			= 0;
LET sAnioRegistro			= 0;
LET dFechaCorte				= DATE(1);
LET sAnioRegistroAux 		= 0;
--JRVT

BEGIN
	ON EXCEPTION SET sql_err, isam_err
		LET cCod_ret = sql_err;
		RETURN cCod_ret;
	END EXCEPTION;
	
	LET dFechaCorte = MDY(MONTH(pFecha), pDiaCorte, YEAR(pFecha));
			
	IF MONTH(dFechaCorte) = 1 THEN
		IF pFecha < dFechaCorte THEN
			LET sAnioRegistro = YEAR(monthadd(pFecha, - 12));
		ELSE
			LET sAnioRegistro = YEAR(pFecha);
		END IF;
	ELSE 
		LET sAnioRegistro = YEAR(pFecha);
	END IF;
	
	IF pFecha <= dFechaCorte THEN
		LET cMesAnterior = '1';
	END IF;
	
	IF pAplicaBoniAnual = '1' OR pAplicaBoniAnual = '3' THEN -- SI ES BONIFICACION ANUAL O POR MESES
	
		SELECT COUNT(num_credito) INTO sCountReg FROM sd_gastos_bonificacion 
			WHERE empresa = pEmpresa AND num_credito = pNumCredito AND fecha_registro = pFechaProxAnualidad;
				  --AND anio_registro = sAnioRegistro;
				  
		IF sCountReg = 0 THEN
			INSERT INTO sd_gastos_bonificacion (empresa, fecha_registro,anio_registro,num_credito,gasto_total_anual)
				VALUES (pEmpresa, pFechaProxAnualidad, sAnioRegistro, pNumCredito, pMonto);
		ELSE
			IF sCountReg  = 2 THEN
				LET sAnioRegistroAux = sAnioRegistro - 1;
			ELSE
				SELECT anio_registro INTO sAnioRegistroAux FROM sd_gastos_bonificacion 
					WHERE empresa = pEmpresa AND num_credito = pNumCredito AND fecha_registro = pFechaProxAnualidad;
			END IF;
			
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_total_anual = NVL(gasto_total_anual,0) + pMonto 
					WHERE empresa = pEmpresa AND num_credito = pNumCredito AND fecha_registro = pFechaProxAnualidad 
						AND anio_registro = sAnioRegistroAux;
			ELSE --REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_total_anual = NVL(gasto_total_anual,0) - pMonto 
					WHERE empresa = pEmpresa AND num_credito = pNumCredito AND fecha_registro = pFechaProxAnualidad 
						AND anio_registro = sAnioRegistroAux;
			END IF;
		END IF;
	END IF;
	
	IF pAplicaBoniAnual = '2' OR pAplicaBoniAnual = '3' THEN -- SI ES BONIFICACION ANUAL O POR MESES
		
		IF MONTH(pFecha) = 1 AND cMesAnterior = '0' THEN--GASTOS ENERO
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_enero = NVL(gasto_enero, 0) + pMonto
					WHERE empresa = pEmpresa AND fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_enero = NVL(gasto_enero, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		ELIF MONTH(pFecha) = 1 AND cMesAnterior = '1' THEN--GASTOS DICIEMBRE
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_diciembre = NVL(gasto_diciembre, 0) + pMonto
					WHERE empresa = pEmpresa AND fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_diciembre = NVL(gasto_diciembre, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		END IF;
		
		IF MONTH(pFecha) = 2 AND cMesAnterior = '0' THEN--GASTOS FEBRERO
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_febrero = NVL(gasto_febrero, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_febrero = NVL(gasto_febrero, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		ELIF MONTH(pFecha) = 2 AND cMesAnterior = '1' THEN
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_enero = NVL(gasto_enero, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_enero = NVL(gasto_enero, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		END IF;
		
		IF MONTH(pFecha) = 3 AND cMesAnterior = '0' THEN--GASTOS MARZO
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_marzo = NVL(gasto_marzo, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_marzo = NVL(gasto_marzo, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		ELIF MONTH(pFecha) = 3 AND cMesAnterior = '1' THEN
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_febrero = NVL(gasto_febrero, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_febrero = NVL(gasto_febrero, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		END IF;
		
		IF MONTH(pFecha) = 4 AND cMesAnterior = '0' THEN--GASTOS ABRIL
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_abril = NVL(gasto_abril, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro =  sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_abril = NVL(gasto_abril, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		ELIF MONTH(pFecha) = 4 AND cMesAnterior = '1' THEN
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_marzo = NVL(gasto_marzo, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro =  sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_marzo = NVL(gasto_marzo, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		END IF;
		
		IF MONTH(pFecha) = 5 AND cMesAnterior = '0' THEN--GASTOS MAYO
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_mayo = NVL(gasto_mayo, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_mayo = NVL(gasto_mayo, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		ELIF MONTH(pFecha) = 5 AND cMesAnterior = '1' THEN
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_abril = NVL(gasto_abril, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_abril = NVL(gasto_abril, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		END IF;
		
		IF MONTH(pFecha) = 6 AND cMesAnterior = '0' THEN--GASTOS JUNIO
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_junio = NVL(gasto_junio, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_junio = NVL(gasto_junio, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		ELIF MONTH(pFecha) = 6 AND cMesAnterior = '1' THEN
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_mayo = NVL(gasto_mayo, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_mayo = NVL(gasto_mayo, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		END IF;
		
		IF MONTH(pFecha) = 7 AND cMesAnterior = '0' THEN--GASTOS JULIO
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_julio = NVL(gasto_julio, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_julio = NVL(gasto_julio, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		ELIF MONTH(pFecha) = 7 AND cMesAnterior = '1' THEN
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_junio = NVL(gasto_junio, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_junio = NVL(gasto_junio, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		END IF;
			
		IF MONTH(pFecha) = 8 AND cMesAnterior = '0' THEN--GASTOS AGOSTO
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_agosto = NVL(gasto_agosto, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_agosto = NVL(gasto_agosto, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		ELIF MONTH(pFecha) = 8 AND cMesAnterior = '1' THEN
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_julio = NVL(gasto_julio, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_julio = NVL(gasto_julio, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		END IF;
			
		IF MONTH(pFecha) = 9 AND cMesAnterior = '0' THEN--GASTOS SEPTIEMBRE
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_septiembre = NVL(gasto_septiembre, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_septiembre = NVL(gasto_septiembre, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		ELIF MONTH(pFecha) = 9 AND cMesAnterior = '1' THEN
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_agosto = NVL(gasto_agosto, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_agosto = NVL(gasto_agosto, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		END IF;
		
		IF MONTH(pFecha) = 10 AND cMesAnterior = '0' THEN--GASTOS OCTUBRE
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_octubre = NVL(gasto_octubre, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_octubre = NVL(gasto_octubre, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		ELIF MONTH(pFecha) = 10 AND cMesAnterior = '1' THEN
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_septiembre = NVL(gasto_septiembre, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_septiembre = NVL(gasto_septiembre, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		END IF;
			
		IF MONTH(pFecha) = 11 AND cMesAnterior = '0' THEN--GASTOS NOVIEMBRE
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_noviembre = NVL(gasto_noviembre, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_noviembre = NVL(gasto_noviembre, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		ELIF MONTH(pFecha) = 11 AND cMesAnterior = '1' THEN
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_octubre = NVL(gasto_octubre, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_octubre = NVL(gasto_octubre, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		END IF;
		
		IF MONTH(pFecha) = 12 AND cMesAnterior = '0' THEN--GASTOS DICIEMBRE
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_diciembre = NVL(gasto_diciembre, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_diciembre = NVL(gasto_diciembre, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		ELIF MONTH(pFecha) = 12 AND cMesAnterior = '1' THEN	
			IF pBanderaReverso = '0' THEN--CARGO
				UPDATE sd_gastos_bonificacion SET gasto_noviembre = NVL(gasto_noviembre, 0) + pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			ELSE--REVERSO
				UPDATE sd_gastos_bonificacion SET gasto_noviembre = NVL(gasto_noviembre, 0) - pMonto
					WHERE fecha_registro = pFechaProxAnualidad AND anio_registro = sAnioRegistro AND num_credito = pNumCredito;
			END IF;
		END IF;
	END IF;
	
	RETURN cCod_ret;
END;
END PROCEDURE
		
		
		
		
		
		
		
		
		
		
		
		
		
;
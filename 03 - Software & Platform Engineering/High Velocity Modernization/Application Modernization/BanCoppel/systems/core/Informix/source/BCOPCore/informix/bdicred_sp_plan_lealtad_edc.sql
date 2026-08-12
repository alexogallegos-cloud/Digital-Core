CREATE PROCEDURE "informix".sp_plan_lealtad_edc()
	RETURNING	 CHAR(6) as CodRet;
	
DEFINE cCodret				    CHAR(6);
DEFINE iSqlerr				    INTEGER;

DEFINE cCodret2				    CHAR(6);

DEFINE vNumCte					CHAR(20);
DEFINE vNumCred					CHAR(20);
DEFINE vDiaCorte				INT;
DEFINE vNumProducto				CHAR(20);
DEFINE vOrigen					CHAR(40);
DEFINE vPuntosGenerados			DECIMAL(18,2);
DEFINE vPuntosUtilizado			DECIMAL(18,2);
DEFINE vPuntosVencido			DECIMAL(18,2);
DEFINE vPuntosNoReconocidos		DECIMAL(18,2);
DEFINE pFechaMenosDia			DATE;
DEFINE vPorcentaje				DECIMAL(18,2);
DEFINE vExistNumCte 			CHAR(20);
DEFINE vPuntosInicial			DECIMAL(18,2);
DEFINE vPuntosFinal				DECIMAL(18,2);
DEFINE vEquivalencia			DECIMAL(18,2);
DEFINE vFechaCorteInicioAcu		DATETIME YEAR TO FRACTION(5);
DEFINE vFechaCortefinAcu		DATETIME YEAR TO FRACTION(5);
DEFINE vNumCredAcu				CHAR(20);
DEFINE vNumCteAcu				CHAR(20);
DEFINE vNumProductoAcu			CHAR(20);
DEFINE vPuntosInicialAcu		DECIMAL(18,2);
DEFINE vPuntosFinalAcu			DECIMAL(18,2);
DEFINE vEquivalenciaAcu			DECIMAL(18,2);
DEFINE vPuntosGeneradosAcu		DECIMAL(18,2);
DEFINE vPuntosUtilizadoAcu		DECIMAL(18,2);
DEFINE vPuntosVencidoAcu		DECIMAL(18,2);
DEFINE vPuntosNoReconocidosAcu	DECIMAL(18,2);
DEFINE vOrigenAcu				CHAR(40);
DEFINE vMontoPuntosV			DECIMAL(18,2);
DEFINE vMontoGastadosV			DECIMAL(18,2);
DEFINE vPuntosPorVencer			DECIMAL(18,2);
DEFINE vFechaInicio12meses		DATETIME YEAR TO FRACTION(5);
DEFINE vFechaFin12meses			DATETIME YEAR TO FRACTION(5);
DEFINE vFechaCorteInicioP		DATETIME YEAR TO FRACTION(5);
---------------------------------------
LET cCodret    			= "000000";
LET iSqlerr    			= 0;
---------------------------------------
LET vNumCte						= "";
LET vNumCred					= "";
LET vDiaCorte					= 0;
LET vNumProducto				= "";
LET vOrigen						= "";
LET vPuntosGenerados			= 0;
LET vPuntosUtilizado			= 0;
LET vPuntosVencido				= 0;
LET vPuntosNoReconocidos		= 0;
LET vPuntosFinal				= 0;
LET pFechaMenosDia				= "";
LET vPorcentaje					= 0;
LET vExistNumCte 				= "";
LET vPuntosInicial				= 0;
LET vEquivalencia				= 0;
LET vFechaCorteInicioAcu		= "";
LET vFechaCortefinAcu			= "";
LET vNumCredAcu					= "";
LET vNumCteAcu					= "";
LET vNumProductoAcu				= "";
LET vPuntosInicialAcu			= 0;
LET vPuntosFinalAcu				= 0;
LET vEquivalenciaAcu			= 0;
LET vPuntosGeneradosAcu			= 0;
LET vPuntosUtilizadoAcu			= 0;
LET vPuntosVencidoAcu			= 0;
LET vPuntosNoReconocidosAcu		= 0;
LET vOrigenAcu					= "";
LET vMontoPuntosV				= 0;
LET vMontoGastadosV				= 0;
LET vPuntosPorVencer			= 0;
LET vFechaInicio12meses			= "";
LET vFechaFin12meses			= "";
LET vFechaCorteInicioP			= "";
------------------



---------------------------------------
BEGIN
	ON EXCEPTION SET iSqlerr
	INSERT INTO bdicred:"informix".sd_plan_lealtad_log_errores_edc (mensaje, detalle)
	VALUES ('ExcepciÃ³n en SP', 'CÃ³digo error: ' || iSqlerr);
	IF iSqlerr <> 0 THEN
	    LET cCodret = iSqlerr;
	    rollback work;
	    RETURN cCodret;
	END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/informix/Fausto/Sps/genmov_principal_vigencia.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	SELECT fecha_ant, fecha_hoy
	INTO pFechaMenosDia, vFechaCorteInicioP
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = '001';

	foreach with hold
		--Filtramos los clientes con respecto al monedero para sacar los clientes activos en Coppel Max
		SELECT sub.numcte, sub.num_credito, sub.dia_corte, sub.num_producto, sub.origen,
			sub.puntos_generados,
			sub.puntos_utilizados,
			sub.puntos_vencidos,
			sub.de_no_reconocido,
			sub.saldo_total
		INTO vNumCte, vNumCred, vDiaCorte, vNumProducto, vOrigen, vPuntosGenerados, vPuntosUtilizado, vPuntosVencido, vPuntosNoReconocidos, vPuntosFinal
		FROM (
			SELECT
				a.numcte,
				b.num_credito,
				c.dia_corte,
				b.num_producto,
				a.origen,
				a.de_obtenido AS puntos_generados,
				a.de_utilizado AS puntos_utilizados,
				a.de_cancelado AS puntos_vencidos,
				a.de_no_reconocido,
				a.saldo_total,
				ROW_NUMBER() OVER (
					PARTITION BY a.numcte, a.origen
					ORDER BY CAST(d.prioridad_edc AS INT) ASC
				) AS rn
			FROM
				bdicred:"informix".sd_monedero_plan_lealtad a,
				bdicred:"informix".sd_maecred b,
				bdicred:"informix".sd_maecredanexo c,
				bdicred:"informix".sd_productos_permitidos_plan_lealtad d
			where b.empresa = '001'
				AND c.empresa = '001'
				AND c.num_credito = b.num_credito
				AND b.status_cred != 'FF'
				AND b.num_producto = d.num_producto
				AND b.numcte = a.numcte
				
		) AS sub
		WHERE
			sub.rn = 1
			
		
		-- Sacamos el porcentaje de conversion--
  		SELECT porcentaje_conversion
		INTO vPorcentaje
		FROM bdicred:informix.sd_plan_lealtad_configuracion_conversion
		WHERE producto = vNumProducto
			AND status = 'A'
			AND origen = vOrigen;
		
		--validamos si ya tiene un historial y obtenemos el saldo inicial
		select numcte, de_final
		INTO vExistNumCte, vPuntosInicial
		FROM bdicred:"informix".sd_plan_lealtad_acumulado_diario
		WHERE numcte = vNumCte
			AND num_credito = vNumCred
			AND num_producto = vNumProducto
			AND origen = vOrigen;
-----------------------------------------------------------------------------------------------------------------
		LET vPuntosInicial = vPuntosFinal;
		LET vEquivalencia = vPuntosFinal * vPorcentaje;
			
		if vExistNumCte is NULL THEN
			
			begin work;
				-- HACEMOS INSERT DIARIO
				--Insert por origen
				INSERT INTO bdicred:"informix".sd_plan_lealtad_acumulado_diario (
				    fecha_corte_inicio, fecha_corte_fin, num_credito, numcte, num_producto,
				    de_inicial, de_final, equivalente, 
				    de_obtenido, de_utilizado, 
				    de_cancelado, de_no_reconocido, origen, fecha_actualizacion
				) VALUES 	
				(vFechaCorteInicioP,pFechaMenosDia, vNumCred, vNumCte, vNumProducto,
				 vPuntosInicial, vPuntosFinal, vEquivalencia,
				 vPuntosGenerados, vPuntosUtilizado,
				 vPuntosVencido,vPuntosNoReconocidos,vOrigen,current);
			commit work;
		ELSE
			begin work;
		
			-- HACEMOS UPDATE DIARIO
			UPDATE bdicred:"informix".sd_plan_lealtad_acumulado_diario SET 
				fecha_corte_fin = pFechaMenosDia,
				de_final = vPuntosFinal, 
				equivalente = vEquivalencia,
				de_obtenido = vPuntosGenerados,
				de_utilizado = vPuntosUtilizado,
				de_cancelado = vPuntosVencido,
				de_no_reconocido = vPuntosNoReconocidos
			WHERE numcte = vNumCte
				AND num_credito = vNumCred
				AND num_producto = vNumProducto
				AND origen = vOrigen;
				
			commit work;
  		END IF		   
  		
		---------SE PASA A TABLA POR PERIODO-----------------------------------------------------------------------------
		--CUANDO DIA CORTE SEA IGUAL A FECHA CORTE  
		IF vDiaCorte = DAY(pFechaMenosDia) THEN 

			-- Calcula los rangos de fechas una sola vez
			LET vFechaInicio12meses = ADD_MONTHS(vFechaCorteInicioP, -12);
			LET vFechaFin12meses    = ADD_MONTHS(pFechaMenosDia, -11) +1; 
			
			IF vPuntosFinal > 0 THEN
				-- Puntos por vencer 
				select 
				NVL(sum (a.monto_abono), 0) as monto_abono,
				NVL(sum (a.monto_abono_recuperado), 0) as monto_abono_recuperado
				INTO vMontoPuntosV, vMontoGastadosV
				FROM bdicred:"informix".sd_vigencia_monedero_plan_lealtad a
				where
				fecha_insert >= vFechaInicio12meses and fecha_insert < vFechaFin12meses
				and a.numcte = vNumCte
				and a.estatus ='f'
				and a.origen = vOrigen;
				
				LET vPuntosPorVencer = vMontoPuntosV - vMontoGastadosV;
			ELSE 
				LET vPuntosPorVencer = 0;
			END IF;
					
			begin work;

			INSERT INTO bdicred:"informix".sd_plan_lealtad_estado_cuenta_hist (   
				fecha_corte_inicio, fecha_corte_fin, 
				num_credito, numcte, num_producto,
				de_inicial, de_final, equivalente, 
				de_obtenido, de_utilizado, 
				de_cancelado, origen, de_por_vencer, de_no_reconocido, fecha_actualizacion
				) VALUES
				(ADD_MONTHS(vFechaCorteInicioP, -1), pFechaMenosDia,
				 vNumCred, vNumCte, vNumProducto,
				 vPuntosInicial, vPuntosFinal, vEquivalencia,
				 vPuntosGenerados, vPuntosUtilizado,
				 vPuntosVencido,vOrigen,vPuntosPorVencer,vPuntosNoReconocidos,current);
			
			UPDATE bdicred:"informix".sd_plan_lealtad_acumulado_diario SET 
				fecha_corte_inicio = vFechaCorteInicioP,
				fecha_corte_fin = vFechaCorteInicioP,
				de_obtenido = 0,
				de_utilizado = 0,
				de_cancelado = 0,
				de_no_reconocido = 0
			WHERE numcte = vNumCte
				AND num_credito = vNumCred
				AND num_producto = vNumProducto
				AND origen = vOrigen;
			
			UPDATE bdicred:"informix".sd_monedero_plan_lealtad SET  
				de_obtenido = 0,
				de_utilizado = 0,
				de_cancelado = 0,
				de_no_reconocido = 0
			WHERE numcte = vNumCte
				AND origen = vOrigen;
			
		commit work;
			
		end if;

end foreach;
 ---------------------------------------
	return cCodret;
END;
--------------------------------------
END procedure;
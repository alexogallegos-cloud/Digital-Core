CREATE PROCEDURE "informix".sp_cierre_sucursal(inClaveSucursalOrigen VARCHAR(5), inClaveSucursalDestino VARCHAR(5), tipoProceso CHAR(1))
--	tipoProceso 
--		N = Proceso de aplicacion normal
--		R = Reverso 

RETURNING CHAR(5) AS outCodigoRetorno, CHAR(100) AS outMensajeRetorno;

	-- Variables manejo de errores
	DEFINE iIsamErr						INTEGER;
	DEFINE iErrorInfo					CHAR(40);
	DEFINE iSqlErr						INTEGER;
	DEFINE cCodigoRetorno				CHAR(5);
	DEFINE cMensajeRetorno				CHAR(100);
	
	-- Variables usadas en el proceso
	DEFINE vFlagTransaccion					CHAR(1);
	DEFINE vCommit							INTEGER;
	DEFINE vContadorCommit					INTEGER;
	DEFINE vClaveSucursalOrigen				VARCHAR(5);
	DEFINE vLote							INTEGER;
	DEFINE vConsecutivoSolicitud			INTEGER;
	DEFINE vCantidadTarjetasOrigen			INTEGER;
	DEFINE vCantidadTarjetasEncontradas		INTEGER;
	DEFINE vFecha							DATETIME YEAR to FRACTION(5);


	-- Inicializacion de variables manejo de error
	LET iIsamErr						= 0;
	LET iErrorInfo						= '';
	LET iSqlErr							= 0;
	LET cCodigoRetorno					= '00000';
	LET cMensajeRetorno					= 'PROCESO EXITOSO';

	-- Inicializacion de variables usadas en el proceso
	LET vFlagTransaccion				= 'F';
	LET vCommit							= 1000;
	LET vContadorCommit					= 0;
	LET vClaveSucursalOrigen			= '';
	LET vLote							= 0;
	LET vConsecutivoSolicitud			= 0;
	LET vCantidadTarjetasOrigen 		= 0;
	LET vCantidadTarjetasEncontradas	= 0;
	LET vFecha							= CURRENT;
	
	--SET DEBUG FILE TO "/home/c90265232/trace_manual_err_" || DAY(CURRENT) || MONTH(CURRENT) || YEAR(CURRENT) || ".out";
	--TRACE ON;
	
	BEGIN
	
		-- Manejo de error
		ON EXCEPTION SET iSqlErr, iIsamErr, iErrorInfo
			
			-- SET DEBUG FILE TO "/home/c90265232/trace_manual_err_" || DAY(CURRENT) || MONTH(CURRENT) || YEAR(CURRENT) || ".out";
			-- TRACE ON;


			-- En caso de error se certifica cerrar/terminar la transaccion iniciada a fin de no deja run proceso colgado
			IF vFlagTransaccion = 'V' THEN
				COMMIT;
				LET vFlagTransaccion = 'F';
			END IF;
			
			IF iSqlErr <> 0 THEN
				LET cCodigoRetorno = iSqlErr;
				LET cMensajeRetorno = 'ERROR EN EL PROCESO ' || iIsamErr || ' ' || iErrorInfo;
				RETURN cCodigoRetorno, cMensajeRetorno;
			END IF;
			
		END EXCEPTION;	
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF tipoProceso = 'N' THEN 
		
			BEGIN WORK;
			LET vFlagTransaccion = 'V';
			
			FOREACH WITH HOLD
				SELECT clave_sucursal, numlote, idsolmaquila
				INTO vClaveSucursalOrigen, vLote, vConsecutivoSolicitud
				FROM intercard:detalle_maquila
				WHERE clave_sucursal = inClaveSucursalOrigen
				GROUP BY 1, 2, 3


				UPDATE intercard:detalle_maquila
				SET clave_sucursal = inClaveSucursalDestino
				WHERE numlote = vLote;
				
				INSERT INTO bitacora_cierre_sucursal ( fecha, sucursalOrigen, sucursalDestino, tablaRegistro, numeroLote, consecutivoSolicitud, codigoRetorno, mensajeRetorno )
				VALUES(vFecha, inClaveSucursalOrigen, inClaveSucursalDestino, 'detalle_maquila', vLote, vConsecutivoSolicitud, '00000', 'Cambio exitoso lote');
			
				LET vContadorCommit = vContadorCommit + 1;
				
				IF vContadorCommit = vCommit THEN
					COMMIT;
					LET vFlagTransaccion = 'F';
					LET vContadorCommit = 0;
					BEGIN WORK;
					LET vFlagTransaccion = 'V';
				END IF;
				
			END FOREACH;
			
			IF vFlagTransaccion = 'V' THEN 
				COMMIT;
				LET vFlagTransaccion = 'F';
			END IF;
			
			FOREACH WITH HOLD
				SELECT a.numerolote, b.cantidadtarjetassol,  COUNT(*) as numero_tarjetas
				INTO vLote, vCantidadTarjetasOrigen, vCantidadTarjetasEncontradas
				FROM intercard:tarjeta a
				JOIN intercard:lote b
				ON a.numerolote = b.numerolote
				WHERE b.clave_sucursal = inClaveSucursalOrigen
				AND a.codstatustarjeta = 'INA'
				AND a.codstatusasignada = 'NOA'
				GROUP BY 1, 2


				EXECUTE PROCEDURE sp_move_lotedesucursal (vLote, inClaveSucursalOrigen, inClaveSucursalDestino) INTO cCodigoRetorno, cMensajeRetorno;
				
				INSERT INTO bitacora_cierre_sucursal 
				( fecha, sucursalOrigen, sucursalDestino, tablaRegistro, numeroLote, consecutivoSolicitud, codigoRetorno, mensajeRetorno )
				VALUES (vFecha, inClaveSucursalOrigen, inClaveSucursalDestino, 'lote', vLote, 0, cCodigoRetorno, TRIM(cMensajeRetorno) || ' - Cantidad tarjetas lote: ' || vCantidadTarjetasOrigen || ' Cantidad tarjetas encontradas: ' ||vCantidadTarjetasEncontradas);

			END FOREACH;

		END IF;
		
		IF tipoProceso = 'R' THEN 
		
			SELECT MAX(fecha)
			INTO vFecha
			FROM intercard:bitacora_cierre_sucursal
			WHERE sucursalDestino = inClaveSucursalOrigen;
			
			IF vFecha IS NULL THEN 
			
				LET cCodigoRetorno	= '00000';
				LET cMensajeRetorno	= 'PROCESO EXITOSO. NO EXISTEN DATOS RECIENTES A REVERSAR';
		
				RETURN cCodigoRetorno, cMensajeRetorno;
			
			ELSE 
				
				BEGIN WORK;
				LET vFlagTransaccion = 'V';


				FOREACH WITH HOLD
					SELECT numeroLote, consecutivoSolicitud
					INTO vLote, vConsecutivoSolicitud
					FROM intercard:bitacora_cierre_sucursal
					WHERE sucursalDestino = inClaveSucursalOrigen
					AND fecha = vFecha
					AND tablaRegistro LIKE 'detalle_maquila%'
					GROUP BY 1, 2
					
					UPDATE intercard:detalle_maquila
					SET clave_sucursal = inClaveSucursalDestino
					WHERE numlote = vLote;
					
					INSERT INTO bitacora_cierre_sucursal ( fecha, sucursalOrigen, sucursalDestino, tablaRegistro, numeroLote, consecutivoSolicitud, codigoRetorno, mensajeRetorno )
					VALUES(CURRENT, inClaveSucursalOrigen, inClaveSucursalDestino, 'detalle_maquila', vLote, vConsecutivoSolicitud, '00000', 'Cambio exitoso reverso lote');
				
					LET vContadorCommit = vContadorCommit + 1;
					
					IF vContadorCommit = vCommit THEN
						COMMIT;
						LET vFlagTransaccion = 'F';
						LET vContadorCommit = 0;
						BEGIN WORK;
						LET vFlagTransaccion = 'V';
					END IF;


				END FOREACH;
				
				IF vFlagTransaccion = 'V' THEN 
					COMMIT;
					LET vFlagTransaccion = 'F';
				END IF;

				FOREACH WITH HOLD
					SELECT numeroLote
					INTO vLote
					FROM intercard:bitacora_cierre_sucursal
					WHERE sucursalDestino = inClaveSucursalOrigen
					AND fecha = vFecha
					AND tablaRegistro LIKE 'lote%'
					GROUP BY 1
					
					EXECUTE PROCEDURE sp_move_lotedesucursal (vLote, inClaveSucursalOrigen, inClaveSucursalDestino) INTO cCodigoRetorno, cMensajeRetorno;
					
					INSERT INTO bitacora_cierre_sucursal ( fecha, sucursalOrigen, sucursalDestino, tablaRegistro, numeroLote, consecutivoSolicitud, codigoRetorno, mensajeRetorno )
					VALUES (CURRENT, inClaveSucursalOrigen, inClaveSucursalDestino, 'lote', vLote, 0, cCodigoRetorno, 'Reverso: ' || TRIM(cMensajeRetorno) );

				END FOREACH;

			END IF;
		
		END IF;
		
		LET cCodigoRetorno	= '00000';
		LET cMensajeRetorno	= 'PROCESO EXITOSO';
		
		RETURN cCodigoRetorno, cMensajeRetorno;
								
	END
	
END PROCEDURE;